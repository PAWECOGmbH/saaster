component output="false" {
    // Record admission before sending the external request: a lost response must keep deletion blocked.
    public struct function create(required numeric customerID, required struct payload, numeric invoiceID=0) {
        local.payload = duplicate(arguments.payload);
        local.reference = arguments.customerID & "@" & createUUID() & "@" & getApplicationMetadata().name;
        local.payload.referenceId = local.reference;
        local.kind = (local.payload.preAuthorization ?: false) ? "authorization" : (arguments.invoiceID gt 0 ? "invoice" : "purchase");
        transaction {
            if (!new backend.core.com.account_lifecycle().lockActiveCustomer(arguments.customerID)) return failure("The account is being deleted.");
            if (arguments.invoiceID gt 0) {
                local.invoice = queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:arguments.invoiceID},customer:{type:"integer",value:arguments.customerID}},
                    sql="SELECT intInvoiceID FROM invoices WHERE intInvoiceID=:id AND intCustomerID=:customer FOR UPDATE");
                if (!local.invoice.recordCount) return failure("Invoice not found.");
            }
            if (queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:arguments.customerID}},
                sql="SELECT strReference FROM payrexx_checkouts WHERE intCustomerID=:id AND strStatus IN ('creating','uncertain') FOR UPDATE").recordCount) return failure("An earlier checkout requires payment verification.");
            queryExecute(options={datasource:application.datasource},params={reference:{type:"varchar",value:local.reference},customer:{type:"integer",value:arguments.customerID},
                invoice:{type:"integer",value:arguments.invoiceID,null:arguments.invoiceID lte 0},kind:{type:"varchar",value:local.kind},
                amount:{type:"decimal",scale:2,value:val(local.payload.amount)/100},currency:{type:"varchar",value:local.payload.currency}},
                sql="INSERT INTO payrexx_checkouts (strReference,intCustomerID,intInvoiceID,strKind,decAmount,strCurrency)
                    VALUES (:reference,:customer,:invoice,:kind,:amount,:currency)");
        }
        local.response = new backend.core.com.payrexx().callPayrexx(local.payload,"POST","Gateway");
        local.valid = local.response.status eq "success" and local.response.httpStatus gte 200 and local.response.httpStatus lt 300
            and isArray(local.response.data ?: "") and arrayLen(local.response.data) eq 1
            and isValid("integer",local.response.data[1].id ?: "") and val(local.response.data[1].id) gt 0;
        local.state = local.valid ? "open" : ((local.response.requestOutcomeUnknown ?: true) or local.response.status eq "success" ? "uncertain" : "rejected");
        transaction {
            queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:arguments.customerID}},
                sql="SELECT intCustomerID FROM customers WHERE intCustomerID=:id FOR UPDATE");
            local.current = queryExecute(options={datasource:application.datasource},params={reference:{type:"varchar",value:local.reference}},
                sql="SELECT intGatewayID FROM payrexx_checkouts WHERE strReference=:reference FOR UPDATE");
            if (local.valid and val(local.current.intGatewayID) and local.current.intGatewayID neq local.response.data[1].id) {
                throw(type="Payrexx.CheckoutMismatch",message="Conflicting gateway IDs require reconciliation; checkout remains blocked.");
            }
            queryExecute(options={datasource:application.datasource},params={reference:{type:"varchar",value:local.reference},state:{type:"varchar",value:local.state},gateway:{type:"bigint",value:local.valid ? local.response.data[1].id : 0,null:!local.valid}},
                sql="UPDATE payrexx_checkouts SET strStatus=:state,intGatewayID=COALESCE(intGatewayID,:gateway) WHERE strReference=:reference");
        }
        if (!local.valid and local.response.status eq "success") return failure("The checkout response is incomplete; payment verification is required.");
        return local.response;
    }

    private struct function failure(required string message) {
        return {status:"error",message:arguments.message,httpStatus:0,requestOutcomeUnknown:false};
    }

    // Called only after webhook authentication/project validation, or with authenticated API data.
    public boolean function receive(required struct event, required struct payment) {
        local.p = arguments.payment;
        local.customerID = local.p.customerID.value;
        local.reference = arguments.event.referenceId;
        local.currency = arguments.event.currency ?: (arguments.event.invoice.currency ?: "");
        transaction {
            // Same lock/order as deletion finalization. No post-deletion customer/payment-method resurrection.
            local.customer = queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:local.customerID}},
                sql="SELECT intCustomerID FROM customers WHERE intCustomerID=:id FOR UPDATE");
            local.deleting = !local.customer.recordCount or new backend.core.com.account_lifecycle().isDeleting(local.customerID);
            local.checkout = queryExecute(options={datasource:application.datasource},params={reference:{type:"varchar",value:local.reference},gateway:local.p.gatewayID},
                sql="SELECT * FROM payrexx_checkouts WHERE strReference=:reference OR intGatewayID=:gateway FOR UPDATE");
            if (local.checkout.recordCount and (local.checkout.recordCount neq 1 or compare(local.checkout.strReference,local.reference) neq 0 or local.checkout.intCustomerID neq local.customerID
                or (val(local.checkout.intGatewayID) gt 0 and local.checkout.intGatewayID neq local.p.gatewayID.value))) {
                throw(type="Payrexx.CheckoutMismatch",message="The webhook does not match its checkout.");
            }
            local.owner = queryExecute(options={datasource:application.datasource},params={id:local.p.transID},
                sql="SELECT intCustomerID FROM payrexx WHERE intTransactionID=:id UNION SELECT intCustomerID FROM payrexx_checkout_events WHERE intTransactionID=:id");
            if (local.owner.recordCount and (local.owner.recordCount neq 1 or local.owner.intCustomerID neq local.customerID)) throw(type="Payrexx.CheckoutMismatch",message="The transaction belongs to another account.");
            local.params = {id:local.p.transID,status:local.p.status,customer:local.p.customerID,gateway:local.p.gatewayID,
                reference:{type:"varchar",value:local.reference},amount:local.p.paymentAmount,currency:{type:"varchar",value:local.currency}};
            queryExecute(options={datasource:application.datasource},params=local.params,
                sql="INSERT IGNORE INTO payrexx_checkout_events (intTransactionID,strStatus,intCustomerID,intGatewayID,strReference,decAmount,strCurrency)
                    VALUES (:id,:status,:customer,:gateway,:reference,:amount,:currency)");
            local.saved = queryExecute(options={datasource:application.datasource},params=local.params,
                sql="SELECT * FROM payrexx_checkout_events WHERE intTransactionID=:id AND strStatus=:status FOR UPDATE");
            if (local.saved.intCustomerID neq local.customerID or compare(local.saved.strReference,local.reference) neq 0
                or local.saved.decAmount neq local.p.paymentAmount.value or local.saved.strCurrency neq local.currency) {
                throw(type="Payrexx.CheckoutMismatch",message="Conflicting duplicate webhook.");
            }
            if (local.saved.strResolution eq "done") return true;
            if (local.checkout.recordCount and !val(local.checkout.intGatewayID) and local.p.gatewayID.value gt 0) {
                queryExecute(options={datasource:application.datasource},params=local.params,
                    sql="UPDATE payrexx_checkouts SET intGatewayID=:gateway WHERE strReference=:reference");
            }
            local.state = local.p.status.value;
            local.resolution = "pending";
            // This applies after account deletion too: never revoke an already confirmed payment.
            local.terminal = queryExecute(options={datasource:application.datasource},params=local.params,
                sql="SELECT intTransactionID FROM payrexx_checkout_events WHERE intTransactionID=:id AND strStatus IN ('confirmed','refunded','partially-refunded','chargeback')");
            if (local.terminal.recordCount and listFind("waiting,authorized,reserved",local.state)) {
                local.resolution = "done";
            } else if (!local.customer.recordCount) {
                if (local.state eq "authorized") {
                    local.resolution = revoke(local.p.transID.value) ? "done" : "pending";
                } else if (listFind("cancelled,declined,expired",local.state)) {
                    local.resolution = "done";
                } else {
                    // Preserve minimal evidence for reconciliation; never modify the retained invoice.
                    local.resolution = "review";
                }
            } else {
                savePaymentRow(local.p);
                if (local.state eq "confirmed") {
                    if (local.checkout.recordCount and val(local.checkout.intInvoiceID)) {
                        if (local.p.paymentAmount.value neq local.checkout.decAmount or local.currency neq local.checkout.strCurrency) {
                            local.resolution = "review";
                        } else {
                            local.existing = queryExecute(options={datasource:application.datasource},params=local.params,
                                sql="SELECT p.intPaymentID FROM payments p INNER JOIN payrexx r ON r.intPayrexxID=p.intPayrexxID WHERE r.intTransactionID=:id");
                            if (!local.existing.recordCount) {
                                local.row = queryExecute(options={datasource:application.datasource},params=local.params,sql="SELECT intPayrexxID FROM payrexx WHERE intTransactionID=:id");
                                local.result = new backend.core.com.invoices().insertPayment({invoiceID:local.checkout.intInvoiceID,customerID:local.customerID,
                                    payrexxID:local.row.intPayrexxID,date:local.p.dateTime.value,amount:local.p.paymentAmount.value,type:local.p.paymentBrand.value});
                                if (!local.result.success) throw(type="Payrexx.PaymentImport",message=local.result.message);
                            }
                            local.resolution = "done";
                        }
                    } else {
                        local.resolution = local.deleting ? "review" : "done";
                    }
                } else if (local.state eq "authorized") {
                    if (local.deleting) {
                        if (!revoke(local.p.transID.value)) {
                            // Keep the durable event pending; the HTTP webhook asks Payrexx to retry.
                            return false;
                        }
                        queryExecute(options={datasource:application.datasource},params=local.params,sql="UPDATE payrexx SET strStatus='cancelled',blnDefault=0 WHERE intTransactionID=:id");
                    }
                    local.resolution = "done";
                } else if (listFind("cancelled,declined,expired",local.state)) {
                    local.resolution = "done";
                } else if (local.state neq "waiting") {
                    local.resolution = "review";
                }
            }
            local.params.resolution = {type:"varchar",value:local.resolution};
            queryExecute(options={datasource:application.datasource},params=local.params,
                sql="UPDATE payrexx_checkout_events SET strResolution=:resolution WHERE intTransactionID=:id AND strStatus=:status");
            if (listFind("confirmed,authorized,cancelled,declined,expired",local.state)) {
                queryExecute(options={datasource:application.datasource},params=local.params,
                    sql="UPDATE payrexx_checkout_events SET strResolution='done' WHERE intTransactionID=:id AND strStatus='waiting'");
            }
            if (local.resolution eq "review") application.objLog.logWrite("payrexx","warning",
                "Payment reconciliation required [CustomerID: #local.customerID#, TransactionID: #local.p.transID.value#, Status: #local.state#]");
            return !(local.state eq "authorized" and local.resolution eq "pending");
        }
    }

    private boolean function revoke(required numeric transactionID) {
        local.response = new backend.core.com.payrexx().callPayrexx({},"DEL","Transaction",arguments.transactionID);
        return (local.response.status eq "success" and local.response.httpStatus gte 200 and local.response.httpStatus lt 300) or val(local.response.httpStatus) eq 404;
    }

    // Called inside the deletion transaction, before archiving or running module hooks.
    public void function closeForDeletion(required numeric customerID) {
        local.params = {customer:{type:"integer",value:arguments.customerID}};
        local.checkouts = queryExecute(options={datasource:application.datasource},params=local.params,
            sql="SELECT * FROM payrexx_checkouts WHERE intCustomerID=:customer AND strStatus NOT IN ('closed','rejected') FOR UPDATE");
        loop query=local.checkouts {
            if (local.checkouts.strStatus eq "creating" or !val(local.checkouts.intGatewayID)) throw(type="Payrexx.CheckoutPending",message="Checkout creation outcome is unknown; reconcile its reference before deletion.");
            local.gateway = new backend.core.com.payrexx().callPayrexx({},"GET","Gateway",local.checkouts.intGatewayID);
            if (local.gateway.status eq "success" and local.gateway.httpStatus gte 200 and local.gateway.httpStatus lt 300 and isArray(local.gateway.data ?: "") and arrayLen(local.gateway.data) eq 1
                and val(local.gateway.data[1].id ?: 0) eq local.checkouts.intGatewayID and isArray(local.gateway.data[1].invoices ?: "")) {
                loop array=local.gateway.data[1].invoices item="local.invoice" {
                    if (!isArray(local.invoice.transactions ?: "")) throw(type="Payrexx.CheckoutPending",message="Incomplete gateway transaction evidence.");
                    loop array=local.invoice.transactions item="local.event" {
                        local.event = duplicate(local.event);
                        if (!structKeyExists(local.event,"referenceId")) local.event.referenceId = local.checkouts.strReference;
                        if (compare(local.event.referenceId,local.checkouts.strReference) neq 0) throw(type="Payrexx.CheckoutMismatch",message="Gateway reference mismatch.");
                        local.event.invoice = {paymentRequestId:local.checkouts.intGatewayID,currency:local.invoice.currency ?: ""};
                        importTransaction(local.event);
                    }
                }
            } else if (!(local.checkouts.blnGatewayDisabled and val(local.gateway.httpStatus) eq 404)) {
                throw(type="Payrexx.CheckoutPending",message="The gateway could not be verified. A missing gateway alone is not proof of payment completion.");
            }
            if (!local.checkouts.blnGatewayDisabled) {
                local.closed = new backend.core.com.payrexx().callPayrexx({},"DEL","Gateway",local.checkouts.intGatewayID);
                if (local.closed.status neq "success" or local.closed.httpStatus lt 200 or local.closed.httpStatus gte 300) {
                    throw(type="Payrexx.CheckoutPending",message="Gateway cancellation has not been confirmed.");
                }
                queryExecute(options={datasource:application.datasource},params={reference:{type:"varchar",value:local.checkouts.strReference}},
                    sql="UPDATE payrexx_checkouts SET blnGatewayDisabled=1 WHERE strReference=:reference");
            }
            local.unsettled = queryExecute(options={datasource:application.datasource},params={reference:{type:"varchar",value:local.checkouts.strReference}},
                sql="SELECT DISTINCT intTransactionID FROM payrexx_checkout_events WHERE strReference=:reference AND strResolution='pending'");
            loop query=local.unsettled {
                local.latest = new backend.core.com.payrexx().callPayrexx({},"GET","Transaction",local.unsettled.intTransactionID);
                if (local.latest.status neq "success" or local.latest.httpStatus lt 200 or local.latest.httpStatus gte 300 or !isArray(local.latest.data ?: "") or arrayLen(local.latest.data) neq 1
                    or val(local.latest.data[1].id ?: 0) neq local.unsettled.intTransactionID
                    or compare(local.latest.data[1].referenceId ?: "",local.checkouts.strReference) neq 0) {
                    throw(type="Payrexx.CheckoutPending",message="The transaction outcome could not be verified.");
                }
                local.event = duplicate(local.latest.data[1]);
                if (!isStruct(local.event.invoice ?: "")) local.event.invoice = {};
                local.event.invoice.paymentRequestId = local.checkouts.intGatewayID;
                importTransaction(local.event);
            }
            // Existing attempts may still settle after the gateway closes; never clear their hold on a timeout.
            local.pending = queryExecute(options={datasource:application.datasource},params={reference:{type:"varchar",value:local.checkouts.strReference}},
                sql="SELECT intTransactionID FROM payrexx_checkout_events WHERE strReference=:reference AND strResolution <> 'done'");
            if (local.pending.recordCount) throw(type="Payrexx.CheckoutPending",message="Waiting for checkout transaction settlement or payment reconciliation.");
            queryExecute(options={datasource:application.datasource},params={reference:{type:"varchar",value:local.checkouts.strReference}},
                sql="UPDATE payrexx_checkouts SET strStatus='closed' WHERE strReference=:reference");
        }
        // A purchase confirmation without an associated accounting payment must not disappear with its account.
        queryExecute(options={datasource:application.datasource},params=local.params,
            sql="UPDATE payrexx_checkout_events e SET e.strResolution='review' WHERE e.intCustomerID=:customer AND e.strStatus='confirmed'
                AND NOT EXISTS (SELECT 1 FROM payments p INNER JOIN payrexx r ON r.intPayrexxID=p.intPayrexxID WHERE r.intTransactionID=e.intTransactionID)");
        if (queryExecute(options={datasource:application.datasource},params=local.params,
            sql="SELECT intTransactionID FROM payrexx_checkout_events WHERE intCustomerID=:customer AND strResolution <> 'done'").recordCount) {
            throw(type="Payrexx.CheckoutPending",message="Unresolved payment events require verification before deletion.");
        }
    }

    public void function importTransaction(required struct event) {
        local.event = arguments.event;
        if (!isValid("integer",local.event.id ?: "") or val(local.event.id) lte 0
            or listLast(local.event.referenceId ?: "","@") neq getApplicationMetadata().name
            or !isValid("integer",listFirst(local.event.referenceId ?: "","@"))) throw(type="Payrexx.InvalidEvent",message="Invalid transaction reference or ID.");
        local.eventTime = isDate(local.event.time ?: "") ? new backend.core.com.time().local2utc(local.event.time,"Europe/Zurich") : now();
        local.p = {customerID:{type:"integer",value:listFirst(local.event.referenceId,"@")},transID:{type:"bigint",value:local.event.id},
            gatewayID:{type:"bigint",value:local.event.invoice.paymentRequestId ?: 0},paymentAmount:{type:"decimal",scale:2,value:val(local.event.amount ?: 0)/100},
            dateTime:{type:"datetime",value:local.eventTime},status:{type:"varchar",value:local.event.status ?: "unknown"},language:{type:"varchar",value:local.event.lang ?: "en"},
            serviceProvider:{type:"varchar",value:local.event.psp ?: ""},serviceProviderID:{type:"integer",value:val(local.event.pspId ?: 0)},
            payrexxFee:{type:"decimal",scale:2,value:val(local.event.payrexxFee ?: 0)/100},paymentBrand:{type:"varchar",value:local.event.payment.brand ?: "Payrexx"},
            cardNumber:{type:"varchar",value:local.event.payment.cardNumber ?: ""},default:{type:"boolean",value:0}};
        receive(local.event,local.p);
    }

    private void function savePaymentRow(required struct payment) {
        local.p = duplicate(arguments.payment);
        local.p.default.value = local.p.status.value eq "authorized" and !queryExecute(
            options={datasource:application.datasource},params={customer:local.p.customerID},
            sql="SELECT intPayrexxID FROM payrexx WHERE intCustomerID=:customer AND strStatus='authorized' AND blnDefault=1").recordCount;
        queryExecute(options={datasource:application.datasource},params=local.p,
            sql="
                            INSERT INTO payrexx
                            (
                                intCustomerID,
                                dtmTimeUTC,
                                intGatewayID,
                                intTransactionID,
                                strStatus,
                                strLanguage,
                                strPSP,
                                intPSPID,
                                decAmount,
                                decPayrexxFee,
                                strPaymentBrand,
                                strCardNumber,
                                blnDefault
                            )
                            VALUES (
                                :customerID,
                                :dateTime,
                                :gatewayID,
                                :transID,
                                :status,
                                :language,
                                :serviceProvider,
                                :serviceProviderID,
                                :paymentAmount,
                                :payrexxFee,
                                :paymentBrand,
                                :cardNumber,
                                :default
                            )
                            ON DUPLICATE KEY UPDATE
                                dtmTimeUTC = VALUES(dtmTimeUTC),
                                intGatewayID = VALUES(intGatewayID),
                                strStatus = VALUES(strStatus),
                                strLanguage = VALUES(strLanguage),
                                strPSP = VALUES(strPSP),
                                intPSPID = VALUES(intPSPID),
                                decAmount = VALUES(decAmount),
                                decPayrexxFee = VALUES(decPayrexxFee),
                                strPaymentBrand = VALUES(strPaymentBrand),
                                strCardNumber = VALUES(strCardNumber)

                        ");
        local.owner = queryExecute(options={datasource:application.datasource},params={id:local.p.transID},
            sql="SELECT intCustomerID FROM payrexx WHERE intTransactionID=:id FOR UPDATE");
        if (local.owner.intCustomerID neq local.p.customerID.value) {
            throw(type="Payrexx.CheckoutMismatch",message="The transaction belongs to another account.");
        }
    }
}
