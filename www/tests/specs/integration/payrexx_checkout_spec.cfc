component extends="tests.support.integration_spec" {
    function run() {
        describe("External checkout lifetime and account deletion", () => {
            beforeEach(() => {
                recordLogs(); logout();
                variables.customer = variables.fixtures.createCustomer();
                variables.password = "Checkout deletion fixture 123!";
                variables.owner = variables.fixtures.createUser(customerID=variables.customer,superAdmin=true,passwordHash=application.objGlobal.hashPassword(variables.password));
                variables.originalPayrexx = duplicate(application.payrexxStruct);
                application.payrexxStruct = {payrexxAPIurl:"http://127.0.0.1/tests/support/payrexx_checkout_mock.cfm?route=/",payrexxAPIinstance:"regression",payrexxAPIkey:"test-key"};
                application.checkoutMock = {gateway:randRange(1000000,2000000000),events:[],calls:[]};
                variables.checkouts = new backend.core.com.payrexx_checkouts();
                variables.lifecycle = new backend.core.com.account_lifecycle();
                variables.cleanup = new backend.core.com.account_deletion();
                variables.invoices = new backend.core.com.invoices();
                variables.invoiceID = variables.invoices.createInvoice({customerID:variables.customer,currency:"CHF",title:"Checkout fixture"}).newInvoiceID;
                variables.invoices.insertInvoicePositions({invoiceID:variables.invoiceID,positions:[{title:"Service",quantity:1,price:100,vat:0,discountPercent:0,unit:"x",description:""}]});
                variables.invoices.setInvoiceStatus(variables.invoiceID,2);
                variables.pdf = hash(new backend.core.com.invoice_documents().download(variables.invoiceID));
            });
            afterEach(() => {
                application.payrexxStruct = variables.originalPayrexx;
                structDelete(application,"checkoutMock");
            });
            it("records checkout admission before calling Payrexx and cancels an unused gateway before deleting", () => {
                createCheckout();
                expect(application.checkoutMock.admitted).toBe("creating");
                requestDeletion();
                expect(variables.cleanup.process(variables.customer).success).toBeTrue();
                expect(application.checkoutMock.removed).toBeTrue();
                expect(rows("SELECT strStatus FROM payrexx_checkouts WHERE intCustomerID=:id").strStatus).toBe("closed");
                expect(rows("SELECT intCustomerID FROM customers WHERE intCustomerID=:id").recordCount).toBe(0);
                expect(hash(new backend.core.com.invoice_documents().download(variables.invoiceID))).toBe(variables.pdf);
            });
            it("cannot finalize deletion while gateway creation is in flight", () => {
                application.checkoutMock.deleteOnCreate = {actorID:variables.owner.userID,customerID:variables.customer,password:variables.password};
                createCheckout();
                expect(application.checkoutMock.deletionDuringCreate.success).toBeFalse();
                expect(variables.cleanup.process(variables.customer).success).toBeTrue();
            });
            it("blocks uncertain creation and refuses another gateway or deletion", () => {
                application.checkoutMock.failCreate=true;
                expect(variables.checkouts.create(variables.customer,{amount:10000,currency:"CHF"},variables.invoiceID).status).toBe("error");
                expect(rows("SELECT strStatus FROM payrexx_checkouts WHERE intCustomerID=:id").strStatus).toBe("uncertain");
                expect(variables.checkouts.create(variables.customer,{amount:10000,currency:"CHF"},variables.invoiceID).status).toBe("error");
                requestDeletion();
                expect(variables.cleanup.process(variables.customer).success).toBeFalse();
                expect(rows("SELECT intCustomerID FROM customers WHERE intCustomerID=:id").recordCount).toBe(1);
            });
            it("imports confirmation without browser return and tolerates duplicate and delayed waiting notifications", () => {
                createCheckout();
                variables.checkouts.importTransaction(event("confirmed"));
                variables.checkouts.importTransaction(event("confirmed"));
                variables.checkouts.importTransaction(event("waiting"));
                expect(variables.invoices.getInvoicePayments(variables.invoiceID).recordCount).toBe(1);
                expect(variables.invoices.getInvoiceData(variables.invoiceID).amountPaid).toBe(100);
                expect(rows("SELECT strStatus FROM payrexx WHERE intCustomerID=:id").strStatus).toBe("confirmed");
                expect(hash(new backend.core.com.invoice_documents().download(variables.invoiceID))).toBe(variables.pdf);
            });
            it("holds a waiting transaction after closing the gateway and imports settlement on retry", () => {
                createCheckout();
                application.checkoutMock.events = [event("waiting")];
                requestDeletion();
                expect(variables.cleanup.process(variables.customer).success).toBeFalse();
                expect(rows("SELECT blnGatewayDisabled FROM payrexx_checkouts WHERE intCustomerID=:id").blnGatewayDisabled).toBe(1);
                application.checkoutMock.events = [event("confirmed")];
                expect(variables.cleanup.process(variables.customer).success).toBeTrue(serializeJSON(variables.logRecorder.getCalls()));
                expect(variables.invoices.getInvoiceData(variables.invoiceID).customerID).toBe(0);
                expect(variables.invoices.getInvoiceData(variables.invoiceID).amountPaid).toBe(100);
                expect(variables.invoices.getInvoicePayments(variables.invoiceID).recordCount).toBe(1);
            });
            it("does not treat an unverified 404 or failed gateway cancellation as successful cleanup", () => {
                createCheckout(); requestDeletion();
                application.checkoutMock.missing=true;
                expect(variables.cleanup.process(variables.customer).success).toBeFalse();
                application.checkoutMock.missing=false; application.checkoutMock.failDelete=true;
                expect(variables.cleanup.process(variables.customer).success).toBeFalse();
                application.checkoutMock.failDelete=false;
                expect(variables.cleanup.process(variables.customer).success).toBeTrue();
            });
            it("rejects new checkouts once deletion starts", () => {
                requestDeletion();
                expect(variables.checkouts.create(variables.customer,{amount:10000,currency:"CHF"},variables.invoiceID).status).toBe("error");
                expect(arrayLen(application.checkoutMock.calls)).toBe(0);
            });
            it("revokes late authorizations without recreating data for a deleted customer", () => {
                createCheckout(); requestDeletion();
                expect(variables.cleanup.process(variables.customer).success).toBeTrue();
                variables.checkouts.importTransaction(event("authorized"));
                variables.checkouts.importTransaction(event("authorized"));
                expect(rows("SELECT intPayrexxID FROM payrexx WHERE intCustomerID=:id").recordCount).toBe(0);
                expect(rows("SELECT strResolution FROM payrexx_checkout_events WHERE intCustomerID=:id").strResolution).toBe("done");
                expect(arrayFind(application.checkoutMock.calls,"DELETE Transaction " & variables.transactionID)).toBeGT(0);
            });
            it("preserves a late payment for reconciliation without altering a deleted customer's invoice", () => {
                createCheckout(); requestDeletion(); expect(variables.cleanup.process(variables.customer).success).toBeTrue();
                variables.checkouts.importTransaction(event("confirmed"));
                variables.checkouts.importTransaction(event("confirmed"));
                expect(rows("SELECT strResolution FROM payrexx_checkout_events WHERE intCustomerID=:id").strResolution).toBe("review");
                expect(variables.invoices.getInvoicePayments(variables.invoiceID).recordCount).toBe(0);
                expect(variables.invoices.getInvoiceData(variables.invoiceID).amountPaid).toBe(0);
                expect(hash(new backend.core.com.invoice_documents().download(variables.invoiceID))).toBe(variables.pdf);
            });
            it("keeps amount mismatches pending for review", () => {
                createCheckout(); variables.badEvent=event("confirmed"); variables.badEvent.amount=12000;
                variables.checkouts.importTransaction(variables.badEvent);
                expect(variables.invoices.getInvoicePayments(variables.invoiceID).recordCount).toBe(0);
                requestDeletion(); expect(variables.cleanup.process(variables.customer).success).toBeFalse();
            });
            it("registers invoice gateways through the real handler and does not duplicate payment on browser return", () => {
                local.response=flow("invoice-start");
                expect(local.response.statusCode).toInclude("302",left(local.response.fileContent,400));
                expect(local.response.responseHeader.Location).toInclude("example.invalid/checkout");
                variables.reference=rows("SELECT strReference FROM payrexx_checkouts WHERE intCustomerID=:id").strReference;
                variables.transactionID=application.checkoutMock.gateway+1;
                application.checkoutMock.events=[event("confirmed")];
                expect(flow("invoice-return").statusCode).toInclude("302");
                expect(flow("invoice-return").statusCode).toInclude("302");
                expect(variables.invoices.getInvoicePayments(variables.invoiceID).recordCount).toBe(1);
            });
            it("registers authorization gateways through the real payment-settings handler", () => {
                local.response=flow("authorization-start");
                expect(local.response.statusCode).toInclude("302",left(local.response.fileContent,400));
                expect(rows("SELECT strKind FROM payrexx_checkouts WHERE intCustomerID=:id").strKind).toBe("authorization");
                expect(application.checkoutMock.admitted).toBe("creating");
            });
            it("authenticates real HTTP webhooks and imports duplicate notifications only once", () => {
                createCheckout();
                local.rejected = webhook(event("confirmed"),"wrong");
                expect(variables.invoices.getInvoicePayments(variables.invoiceID).recordCount).toBe(0);
                expect(webhook(event("confirmed")).statusCode).toInclude("200");
                expect(webhook(event("confirmed")).statusCode).toInclude("200");
                expect(variables.invoices.getInvoicePayments(variables.invoiceID).recordCount).toBe(1);
            });
            it("requests webhook redelivery if a late authorization cannot be revoked", () => {
                createCheckout(); requestDeletion(); expect(variables.cleanup.process(variables.customer).success).toBeTrue();
                application.checkoutMock.failRevoke=true;
                expect(webhook(event("authorized")).statusCode).toInclude("503");
                expect(rows("SELECT strResolution FROM payrexx_checkout_events WHERE intCustomerID=:id").strResolution).toBe("pending");
                application.checkoutMock.failRevoke=false;
                expect(webhook(event("authorized")).statusCode).toInclude("200");
                expect(rows("SELECT strResolution FROM payrexx_checkout_events WHERE intCustomerID=:id").strResolution).toBe("done");
                expect(rows("SELECT intPayrexxID FROM payrexx WHERE intCustomerID=:id").recordCount).toBe(0);
            });
            it("prevents the legacy deletion entry point from bypassing checkout holds", () => {
                createCheckout();
                expect(application.objCustomer.deleteAccount(variables.customer).success).toBeFalse();
                expect(rows("SELECT intCustomerID FROM customers WHERE intCustomerID=:id").recordCount).toBe(1);
            });
            it("holds a confirmed purchase without an accounting payment instead of silently discarding it", () => {
                local.result=variables.checkouts.create(variables.customer,{amount:10000,currency:"CHF"});
                expect(local.result.status).toBe("success");
                variables.reference=rows("SELECT strReference FROM payrexx_checkouts WHERE intCustomerID=:id").strReference;
                variables.transactionID=application.checkoutMock.gateway+1;
                variables.checkouts.importTransaction(event("confirmed"));
                requestDeletion();
                expect(variables.cleanup.process(variables.customer).success).toBeFalse();
                expect(rows("SELECT strResolution FROM payrexx_checkout_events WHERE intCustomerID=:id").strResolution).toBe("review");
            });
            it("retains unexpected currency confirmations for review", () => {
                createCheckout(); local.wrong=event("confirmed"); local.wrong.currency="EUR";
                variables.checkouts.importTransaction(local.wrong);
                expect(variables.invoices.getInvoicePayments(variables.invoiceID).recordCount).toBe(0);
                expect(rows("SELECT strResolution FROM payrexx_checkout_events WHERE intCustomerID=:id").strResolution).toBe("review");
            });
            it("handles a late legacy authorization without any checkout registry entry", () => {
                requestDeletion(); expect(variables.cleanup.process(variables.customer).success).toBeTrue();
                variables.reference=variables.customer & "@legacy@" & getApplicationMetadata().name;
                variables.transactionID=application.checkoutMock.gateway+1;
                expect(webhook(event("authorized")).statusCode).toInclude("200");
                expect(rows("SELECT intPayrexxID FROM payrexx WHERE intCustomerID=:id").recordCount).toBe(0);
                expect(rows("SELECT strResolution FROM payrexx_checkout_events WHERE intCustomerID=:id").strResolution).toBe("done");
            });
            it("never revokes a confirmed transaction when an older authorization notification arrives later", () => {
                createCheckout(); requestDeletion(); expect(variables.cleanup.process(variables.customer).success).toBeTrue();
                variables.checkouts.importTransaction(event("confirmed"));
                variables.checkouts.importTransaction(event("authorized"));
                expect(arrayFind(application.checkoutMock.calls,"DELETE Transaction " & variables.transactionID)).toBe(0);
                expect(rows("SELECT strResolution FROM payrexx_checkout_events WHERE intCustomerID=:id AND strStatus='authorized'").strResolution).toBe("done");
                expect(rows("SELECT strResolution FROM payrexx_checkout_events WHERE intCustomerID=:id AND strStatus='confirmed'").strResolution).toBe("review");
            });
            it("rejects another gateway using the checkout reference", () => {
                createCheckout(); variables.badEvent=event("confirmed"); variables.badEvent.invoice.paymentRequestId++;
                expect(() => variables.checkouts.importTransaction(variables.badEvent)).toThrow("Payrexx.CheckoutMismatch");
                expect(variables.invoices.getInvoicePayments(variables.invoiceID).recordCount).toBe(0);
            });
        });
    }
    private struct function flow(required string mode) {
        cfhttp(url="http://127.0.0.1/tests/support/payrexx_checkout_flow_probe.cfm?mode=" & arguments.mode
            & "&userID=" & variables.owner.userID & "&invoiceID=" & variables.invoiceID & "&gatewayID=" & application.checkoutMock.gateway,
            redirect=false,result="local.response",timeout=40);
        return local.response;
    }
    private struct function webhook(required struct event,string secret="fixture-webhook-secret") {
        cfhttp(url="http://127.0.0.1/tests/support/payrexx_webhook_probe.cfm?pass=" & urlEncodedFormat(arguments.secret),method="POST",result="local.response",timeout=40) {
            cfhttpparam(type="header",name="Content-Type",value="application/json");
            cfhttpparam(type="body",value=serializeJSON({transaction:arguments.event}));
        }
        return local.response;
    }
    private void function createCheckout() {
        local.result=variables.checkouts.create(variables.customer,{amount:10000,currency:"CHF"},variables.invoiceID);
        expect(local.result.status).toBe("success",serializeJSON(local.result));
        variables.reference=rows("SELECT strReference FROM payrexx_checkouts WHERE intCustomerID=:id").strReference;
        variables.transactionID=application.checkoutMock.gateway+1;
    }
    private struct function event(required string status) {
        return {id:variables.transactionID,status:arguments.status,referenceId:variables.reference,amount:10000,currency:"CHF",pspId:1,
            invoice:{paymentRequestId:application.checkoutMock.gateway,currency:"CHF"},payment:{brand:"Test card"}};
    }
    private void function requestDeletion() {
        expect(variables.lifecycle.requestDeletion(variables.owner.userID,variables.customer,variables.password).success).toBeTrue();
    }
    private query function rows(required string sql) {
        return queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:variables.customer}},sql=arguments.sql);
    }
}
