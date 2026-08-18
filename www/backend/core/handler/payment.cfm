
<cfscript>

// Delete payment method
if (structKeyExists(url, "del")) {

    if (isNumeric(url.del) and url.del gt 0) {

        objPayrexx = new backend.core.com.payrexx();

        selectedPaymentMethod = queryExecute(
            options: {datasource = application.datasource},
            params: {
                customerID: {type: "numeric", value: session.customer_id},
                id: {type: "numeric", value: url.del}
            },
            sql = "
                SELECT intPayrexxID, intTransactionID, blnDefault
                FROM payrexx
                WHERE intCustomerID = :customerID
                AND strStatus = 'authorized'
                AND intPayrexxID = :id
            "
        );

        // Enforce the same rule on the server that is shown in the UI.
        paymentMethodCount = queryExecute(
            options: {datasource = application.datasource},
            params: {
                customerID: {type: "numeric", value: session.customer_id}
            },
            sql = "
                SELECT COUNT(*) AS methodCount
                FROM payrexx
                WHERE intCustomerID = :customerID
                AND strStatus = 'authorized'
            "
        );

        if (!selectedPaymentMethod.recordCount or paymentMethodCount.methodCount lte 1) {

            getAlert('msgNeedOnePaymentType', 'info');
            logWrite("user", "warning", "Payment method could not be deleted, one is needed [CustomerID: #session.customer_id#, UserID: #session.user_id#]");
            location url="#application.mainURL#/account-settings/payment" addtoken="false";

        }

        // Delete the selected token on Payrexx, not an unrelated newest token.
        deleteTransaction = objPayrexx.callPayrexx({}, 'DEL', 'Transaction', selectedPaymentMethod.intTransactionID);
        if (!structKeyExists(deleteTransaction, "status") or deleteTransaction.status neq "success") {
            paymentErrorReference = uCase(left(replace(createUUID(), "-", "", "all"), 8));
            paymentErrorMessage = session.lng eq "de"
                ? "Die Zahlungsart konnte bei Payrexx nicht entfernt werden: #deleteTransaction.message# (Referenz: #paymentErrorReference#)."
                : "The payment method could not be removed from Payrexx: #deleteTransaction.message# (reference: #paymentErrorReference#).";
            getAlert(encodeForHTML(paymentErrorMessage), 'danger');
            logWrite("payrexx", "error", "Payment method could not be deleted on Payrexx [Reference: #paymentErrorReference#, CustomerID: #session.customer_id#, UserID: #session.user_id#, TransactionID: #selectedPaymentMethod.intTransactionID#, HTTP status: #deleteTransaction.httpStatus#, Error: #deleteTransaction.message#]", true);
            location url="#application.mainURL#/account-settings/payment" addtoken="false";
        }

        queryExecute(
            options: {datasource = application.datasource},
            params: {
                customerID: {type: "numeric", value: session.customer_id},
                id: {type: "numeric", value: selectedPaymentMethod.intPayrexxID}
            },
            sql = "
                DELETE FROM payrexx
                WHERE intCustomerID = :customerID
                AND intPayrexxID = :id
            "
        );

        if (selectedPaymentMethod.blnDefault) {
            queryExecute(
                options: {datasource = application.datasource},
                params: {
                    customerID: {type: "numeric", value: session.customer_id}
                },
                sql = "
                    UPDATE payrexx
                    SET blnDefault = 1
                    WHERE intCustomerID = :customerID
                    AND strStatus = 'authorized'
                    ORDER BY blnFailed ASC, dtmTimeUTC DESC
                    LIMIT 1
                "
            );
        }

        getAlert('msgPaymentMethodDeleted', 'success');
        logWrite("user", "info", "Payment method deleted [CustomerID: #session.customer_id#, UserID: #session.user_id#, TransactionID: #selectedPaymentMethod.intTransactionID#]");
        location url="#application.mainURL#/account-settings/payment" addtoken="false";

    }

}


// Add payment method
if (structKeyExists(url, "add")) {

    if (isNumeric(url.add) and url.add eq session.customer_id) {

        objPayrexx = new backend.core.com.payrexx();
        objPrices = new backend.core.com.prices();
        objCurrency = new backend.core.com.currency();

        // Returning from Payrexx
        if (structKeyExists(url, "psp")) {

            // If success, we try to get the webhook data
            if (url.psp eq "success") {

                // Only accept the webhook belonging to the gateway just created.
                // A generic "latest authorized" lookup can mistake an old card for the new one.
                if (structKeyExists(session, "payrexxPendingGatewayID") and isNumeric(session.payrexxPendingGatewayID)) {
                    getWebhook = objPayrexx.getWebhook(
                        customerID=session.customer_id,
                        status='authorized',
                        gatewayID=session.payrexxPendingGatewayID
                    );
                } else {
                    getWebhook = queryNew("intPayrexxID");
                }

                // The browser may return before the asynchronous webhook arrives.
                // Verify the expected Gateway via the authenticated API and import
                // its authorized transaction immediately when possible.
                if (
                    !getWebhook.recordCount
                    and structKeyExists(session, "payrexxPendingGatewayID")
                    and isNumeric(session.payrexxPendingGatewayID)
                ) {
                    gatewayResponse = objPayrexx.callPayrexx(
                        payload={},
                        method="GET",
                        object="Gateway",
                        thisID=session.payrexxPendingGatewayID
                    );
                    authorizedTransaction = {};

                    if (
                        gatewayResponse.status eq "success"
                        and structKeyExists(gatewayResponse, "data")
                        and isArray(gatewayResponse.data)
                        and arrayLen(gatewayResponse.data)
                        and structKeyExists(gatewayResponse.data[1], "id")
                        and gatewayResponse.data[1].id eq session.payrexxPendingGatewayID
                        and structKeyExists(gatewayResponse.data[1], "invoices")
                        and isArray(gatewayResponse.data[1].invoices)
                    ) {
                        for (gatewayInvoice in gatewayResponse.data[1].invoices) {
                            if (structKeyExists(gatewayInvoice, "transactions") and isArray(gatewayInvoice.transactions)) {
                                for (gatewayTransaction in gatewayInvoice.transactions) {
                                    if (
                                        structKeyExists(gatewayTransaction, "status")
                                        and gatewayTransaction.status eq "authorized"
                                    ) {
                                        authorizedTransaction = duplicate(gatewayTransaction);
                                    }
                                }
                            }
                        }
                    }

                    if (!structIsEmpty(authorizedTransaction)) {
                        authorizedTransaction.invoice = {
                            paymentRequestId: session.payrexxPendingGatewayID
                        };
                        request.payrexxWebhookPayload = {
                            transaction: authorizedTransaction
                        };
                        structDelete(request, "payrexxWebhookError");
                        include template="/frontend/core/handler/payrexx_webhook.cfm";
                        structDelete(request, "payrexxWebhookPayload");

                        getWebhook = objPayrexx.getWebhook(
                            customerID=session.customer_id,
                            status="authorized",
                            gatewayID=session.payrexxPendingGatewayID
                        );
                    } else if (
                        gatewayResponse.status neq "success"
                        and
                        structKeyExists(gatewayResponse, "message")
                        and len(trim(gatewayResponse.message))
                    ) {
                        request.payrexxWebhookError = gatewayResponse.message;
                    } else {
                        request.payrexxWebhookError = "The expected Gateway does not contain an authorized transaction yet.";
                    }
                }

                // If there is no data from the webhook, send the customer back and try again
                if (getWebhook.recordCount) {
                    getAlert('msgPaymentMethodAdded', 'success');
                    logWrite("user", "info", "Payment method added [CustomerID: #session.customer_id#, UserID: #session.user_id#, TransactionID: #getWebhook.intTransactionID#, paymentType: #getWebhook.strPaymentBrand#]");
                } else {
                    paymentErrorReference = uCase(left(replace(createUUID(), "-", "", "all"), 8));
                    pendingGatewayID = structKeyExists(session, "payrexxPendingGatewayID")
                        ? session.payrexxPendingGatewayID
                        : "unknown";
                    webhookError = structKeyExists(request, "payrexxWebhookError")
                        ? request.payrexxWebhookError
                        : "Payrexx returned successfully, but no authorized webhook matching the gateway was stored.";
                    paymentErrorMessage = session.lng eq "de"
                        ? "Payrexx hat den Vorgang abgeschlossen, aber die Zahlungsart wurde noch nicht synchronisiert. Bitte laden Sie die Seite in einigen Sekunden neu. Gateway-ID: #pendingGatewayID#, Referenz: #paymentErrorReference#."
                        : "Payrexx completed the process, but the payment method has not been synchronized yet. Please reload the page in a few seconds. Gateway ID: #pendingGatewayID#, reference: #paymentErrorReference#.";
                    if (structKeyExists(request, "payrexxWebhookError")) {
                        paymentErrorMessage &= session.lng eq "de"
                            ? " Technischer Grund: #request.payrexxWebhookError#"
                            : " Technical reason: #request.payrexxWebhookError#";
                    }
                    getAlert(encodeForHTML(paymentErrorMessage), 'warning');
                    logWrite("payrexx", "error", "Payment method could not be added [Reference: #paymentErrorReference#, CustomerID: #session.customer_id#, UserID: #session.user_id#, GatewayID: #pendingGatewayID#, Error: #webhookError#]");
                }

            } else {
                paymentErrorReference = uCase(left(replace(createUUID(), "-", "", "all"), 8));
                paymentErrorMessage = session.lng eq "de"
                    ? "Payrexx hat die Erfassung abgebrochen oder abgelehnt (Status: #url.psp#). Referenz: #paymentErrorReference#."
                    : "Payrexx cancelled or rejected the payment method setup (status: #url.psp#). Reference: #paymentErrorReference#.";
                getAlert(encodeForHTML(paymentErrorMessage), 'warning');
                logWrite("payrexx", "error", "Payment method could not be added [Reference: #paymentErrorReference#, CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: #url.psp#]");
            }

            structDelete(session, "payrexxPendingGatewayID");

            // If there is a plan to pay, charge right now
            if (structKeyExists(session, "redirect") and findNoCase("plan=", session.redirect)) {
                bookingPath = session.redirect;
                structDelete(session, "redirect");
                location url="#bookingPath#" addtoken=false;
            }

            location url="#application.mainURL#/account-settings/payment" addtoken=false;

        } else {

            paymentStruct = structNew();
            paymentStruct['skipResultPage'] = true;
            paymentStruct['referenceId'] = session.customer_id & "@" & createUUID() & "@" & getApplicationMetadata().name;
            paymentStruct['currency'] = objCurrency.getCurrency().iso;
            paymentStruct['successRedirectUrl'] = "#application.mainURL#/payment-settings?add=#session.customer_id#&psp=success";
            paymentStruct['failedRedirectUrl'] = "#application.mainURL#/payment-settings?add=#session.customer_id#&psp=failed";
            paymentStruct['cancelRedirectUrl'] = "#application.mainURL#/account-settings/payment?cancel";
            paymentStruct['lookAndFeelProfile'] = variables.payrexxDesignID; // config.cfm
            paymentStruct['purpose'] = "Validation test";
            paymentStruct['amount'] = 0;
            paymentStruct['preAuthorization'] = true;
            paymentStruct['chargeOnAuthorization'] = false;

            // Are there any specific PSPs defined?
            if (len(trim(variables.payrexxPSPs))) {
                paymentStruct['psp'] = variables.payrexxPSPs; // config.cfm
            }


            // Call Payrexx and create a gateway
            payrexxRespond = objPayrexx.callPayrexx(paymentStruct, "POST", "Gateway");

            if (payrexxRespond.status eq "success") {

                gatewayData = payrexxRespond.data[1];
                session.payrexxPendingGatewayID = gatewayData.id;

                // Build link to the payment terminal with the choosen language
                if (len(trim(variables.payrexxAPIinstance))) {
                    payrexxURL = "https://" & variables.payrexxAPIinstance & ".payrexx.com/" & session.lng & "/?payment=" & gatewayData.hash;
                } else {
                    payrexxURL = gatewayData.link;
                }

                logWrite("user", "info", "Sent the user to Payrexx [CustomerID: #session.customer_id#, UserID: #session.user_id#, GatewayID: #gatewayData.id#]");
                location url=payrexxURL addtoken="false";


            } else {

                paymentErrorReference = uCase(left(replace(createUUID(), "-", "", "all"), 8));
                paymentErrorMessage = session.lng eq "de"
                    ? "Payrexx konnte nicht gestartet werden: #payrexxRespond.message# (Referenz: #paymentErrorReference#)."
                    : "Payrexx could not be started: #payrexxRespond.message# (reference: #paymentErrorReference#).";
                getAlert(encodeForHTML(paymentErrorMessage), 'danger');
                logWrite("payrexx", "error", "Could not call Payrexx [Reference: #paymentErrorReference#, CustomerID: #session.customer_id#, UserID: #session.user_id#, HTTP status: #payrexxRespond.httpStatus#, Error: #payrexxRespond.message#]", true);
                location url="#application.mainURL#/account-settings/payment" addtoken="false";

            }

        }

    }

}


// Update default payment method
if (structKeyExists(url, "default")) {

    if (isNumeric(url.default) and url.default gt 0) {

        selectedPaymentMethod = queryExecute(
            options: {datasource = application.datasource},
            params: {
                customerID: {type: "numeric", value: session.customer_id},
                id: {type: "numeric", value: url.default}
            },
            sql = "
                SELECT intPayrexxID
                FROM payrexx
                WHERE intCustomerID = :customerID
                AND intPayrexxID = :id
                AND strStatus = 'authorized'
            "
        );

        if (!selectedPaymentMethod.recordCount) {
            paymentErrorReference = uCase(left(replace(createUUID(), "-", "", "all"), 8));
            paymentErrorMessage = session.lng eq "de"
                ? "Die gewählte Zahlungsart wurde nicht gefunden oder ist nicht autorisiert. Referenz: #paymentErrorReference#."
                : "The selected payment method was not found or is not authorized. Reference: #paymentErrorReference#.";
            getAlert(encodeForHTML(paymentErrorMessage), 'warning');
            logWrite("payrexx", "warning", "Default payment method could not be changed [Reference: #paymentErrorReference#, CustomerID: #session.customer_id#, UserID: #session.user_id#, PaymentMethodID: #url.default#]");
            location url="#application.mainURL#/account-settings/payment" addtoken="false";
        }

        queryExecute(
            options: {datasource = application.datasource},
            params: {
                customerID: {type: "numeric", value: session.customer_id},
                id: {type: "numeric", value: url.default}
            },
            sql = "

                UPDATE payrexx
                SET blnDefault = 0
                WHERE intCustomerID = :customerID;

                UPDATE payrexx
                SET blnDefault = 1,
                    blnFailed = 0
                WHERE intCustomerID = :customerID
                AND intPayrexxID = :id

            "
        )

        logWrite("user", "info", "User has changed the default payment method [CustomerID: #session.customer_id#, UserID: #session.user_id#]");
        location url="#application.mainURL#/account-settings/payment" addtoken="false";

    }

}


// Pay open invoice
if (structKeyExists(url, "pay")) {

    if (isNumeric(url.pay) and url.pay gt 0) {

        if (structKeyExists(url, "other")) {

            // Coming from PSP
            if (structKeyExists(url, "psp_response")) {

                // If we are in dev mode, call the JSON data from the given server
                if (application.environment eq "dev") {
                    include template="/frontend/core/handler/payrexx_webhook.cfm";
                }

                // Get the webhook data
                objPayrexx = new backend.core.com.payrexx();
                getWebhook = objPayrexx.getWebhook(session.customer_id, 'confirmed');

                // If there is no data from the webhook, send the customer back and try again
                if (getWebhook.recordCount) {

                    // Insert payment
                    payment = structNew();
                    payment['invoiceID'] = url.pay;
                    payment['customerID'] = session.customer_id;
                    payment['date'] = now();
                    payment['amount'] = getWebhook.decAmount;
                    payment['payrexxID'] = getWebhook.intPayrexxID;
                    payment['type'] = getWebhook.strPaymentBrand;

                    objInvoice = new backend.core.com.invoices();
                    insPayment = objInvoice.insertPayment(payment);
                    anyLanguage = application.objLanguage.getAnyLanguage(session.lng).iso;

                    // Set plans and modules as well as the custom settings into a session
                    application.objCustomer.setProductSessions(session.customer_id, anyLanguage);

                    getAlert('msgInvoicePaid', 'success');
                    logWrite("user", "info", "Invoice has been paid [CustomerID: #session.customer_id#, UserID: #session.user_id#, InvoiceID: #url.pay#, payment type: #getWebhook.strPaymentBrand#]");


                } else {

                    paymentErrorReference = uCase(left(replace(createUUID(), "-", "", "all"), 8));
                    paymentErrorMessage = session.lng eq "de"
                        ? "Die Zahlung wurde von Payrexx noch nicht bestätigt. Bitte prüfen Sie die Rechnung erneut. Referenz: #paymentErrorReference#."
                        : "The payment has not yet been confirmed by Payrexx. Please check the invoice again. Reference: #paymentErrorReference#.";
                    getAlert(encodeForHTML(paymentErrorMessage), 'warning');
                    logWrite("payrexx", "error", "Pay invoice: No confirmed webhook entry found [Reference: #paymentErrorReference#, CustomerID: #session.customer_id#, UserID: #session.user_id#, InvoiceID: #url.pay#]");

                }

            } else {

                // Get the invoice number
                objInvoices = new backend.core.com.invoices();
                incoiceData = objInvoices.getInvoiceData(url.pay);

                successLink = "#application.mainURL#/payment-settings?pay=#url.pay#&other&psp_response=success";
                cancelLink = "#application.mainURL#/account-settings/invoice/#url.pay#?psp_response=cancel";
                failLink = "#application.mainURL#/account-settings/invoice/#url.pay#?psp_response=failed";
                purpose = getTrans('titInvoiceNumber') & " " & incoiceData.number;
                amountToPay = incoiceData.amountOpen;
                currency = incoiceData.currency;

                logWrite("user", "info", "Pay invoice: Sent the user to Payrexx [CustomerID: #session.customer_id#, UserID: #session.user_id#, purpose: #purpose#, amountToPay: #currency# #amountToPay#]");
                include template="/backend/core/views/payment.cfm";

            }

        } else {

            // Get webhook data
            objPayrexx = new backend.core.com.payrexx();
            getWebhook = objPayrexx.getWebhook(session.customer_id, 'authorized');
            anyLanguage = application.objLanguage.getAnyLanguage(session.lng).iso;

            if (!getWebhook.recordCount) {
                logWrite("payrexx", "error", "Pay invoice: Invoice could not be paid [CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: No entry in webhook]");
                location url="#application.mainURL#/account-settings/payment" addtoken="false";
            }

            // Charge the amount now (Payrexx)
            chargeNow = new backend.core.com.invoices().payInvoice(url.pay);

            if (chargeNow.success) {

                // Set plans and modules as well as the custom settings into a session
                application.objCustomer.setProductSessions(session.customer_id, anyLanguage);

                getAlert('msgInvoicePaid');
                logWrite("user", "info", "Invoice has been paid via Payrexx [CustomerID: #session.customer_id#, UserID: #session.user_id#, InvoiceID: #chargeNow.invoiceID#]");

            } else {

                paymentErrorReference = uCase(left(replace(createUUID(), "-", "", "all"), 8));
                paymentErrorMessage = session.lng eq "de"
                    ? "Die Rechnung konnte nicht über die hinterlegten Zahlungsarten belastet werden: #chargeNow.message# (Referenz: #paymentErrorReference#)."
                    : "The invoice could not be charged using the saved payment methods: #chargeNow.message# (reference: #paymentErrorReference#).";
                getAlert(encodeForHTML(paymentErrorMessage), 'warning');
                logWrite("payrexx", "error", "Pay invoice: Invoice could not be paid [Reference: #paymentErrorReference#, CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: #chargeNow.message#]");

            }

        }

        location url="#application.mainURL#/account-settings/invoice/#url.pay#" addtoken="false";

    }

}


logWrite("user", "warning", "Access attempt to handler/payment.cfm without method [CustomerID: #session.customer_id#, UserID: #session.user_id#]");
location url="#application.mainURL#/dashboard" addtoken="false";

</cfscript>
