component extends="tests.support.integration_spec" {

    /*
        Booking after adding a payment method - issue #521, real runs of the return from
        Payrexx (handler/payment.cfm) through support/payment_handler_probe.cfm.

        A booking button without payment method leads to the payment page and carries the
        booking as redirect (book.cfc::paymentFirstLink). After the payment method was
        added successfully, the handler must open that booking - for plans and modules.
        It must not book after a failed setup, without a waiting booking, or after the
        user canceled the setup.

        The setup at Payrexx is simulated by an authorized webhook row for the gateway the
        setup was started with; the redirect to the booking is checked, not followed.
    */

    variables.probeUrl = "http://127.0.0.1/tests/support/payment_handler_probe.cfm";

    function run() {

        describe("Booking after adding a payment method", () => {

            beforeEach(() => {
                variables.customerID = variables.fixtures.createCustomer();
                variables.user = variables.fixtures.createUser(customerID = variables.customerID);
                variables.gatewayID = randRange(900000000, 999999999);
            });

            it("books the plan right after a successful setup", () => {
                authorizePaymentMethod();

                var target = returnFromPayrexx("success", "book?plan=TESTBOXPLAN");

                expect(target).toBe(application.mainURL & "/book?plan=TESTBOXPLAN");
            });

            it("books the module right after a successful setup", () => {
                authorizePaymentMethod();

                var target = returnFromPayrexx("success", "book?module=TESTBOXMODULE");

                expect(target).toBe(application.mainURL & "/book?module=TESTBOXMODULE", "Modules were sent back to the payment page");
            });

            it("does not book after a failed setup", () => {
                var target = returnFromPayrexx("failed", "book?plan=TESTBOXPLAN");

                expect(target).toBe(application.mainURL & "/account-settings/payment");
            });

            it("stays on the payment page when no booking is waiting", () => {
                authorizePaymentMethod();

                var target = returnFromPayrexx("success", "");

                expect(target).toBe(application.mainURL & "/account-settings/payment");
            });

            it("forgets the waiting booking when the user canceled the setup", () => {
                authorizePaymentMethod();

                var target = returnFromPayrexx("success", "book?plan=TESTBOXPLAN", true);

                expect(target).toBe(application.mainURL & "/account-settings/payment", "A canceled booking ran on a later setup");
            });

            it("does not open a redirect that is not a booking", () => {
                authorizePaymentMethod();

                var target = returnFromPayrexx("success", "account-settings/users");

                expect(target).toBe(application.mainURL & "/account-settings/payment");
            });

        });

    }

    // The webhook Payrexx sends for an authorized payment method of the gateway
    private void function authorizePaymentMethod() {
        queryExecute(
            "INSERT INTO payrexx (intCustomerID, dtmTimeUTC, intGatewayID, intTransactionID, strStatus, strPaymentBrand, strCardNumber, blnDefault, blnFailed)
             VALUES (:customerID, UTC_TIMESTAMP(), :gatewayID, :gatewayID, 'authorized', 'visa', '4242', 1, 0)",
            { customerID: { type: "numeric", value: variables.customerID }, gatewayID: { type: "numeric", value: variables.gatewayID } },
            { datasource: application.datasource }
        );
    }

    // Runs the return from Payrexx and answers with the target of the handler's redirect
    private string function returnFromPayrexx(required string psp, required string redirect, boolean cancelFirst = false) {
        var query = "?customerID=" & variables.customerID
            & "&userID=" & variables.user.userID
            & "&gatewayID=" & variables.gatewayID
            & "&psp=" & arguments.psp
            & "&redirect=" & urlEncodedFormat(arguments.redirect)
            & (arguments.cancelFirst ? "&cancelFirst=1" : "");

        cfhttp(url = variables.probeUrl & query, method = "get", redirect = false, timeout = 60, result = "local.response");

        if (!structKeyExists(local.response.responseHeader, "Location")) {
            fail("The payment handler did not redirect (" & local.response.statusCode & "): " & left(reReplace(local.response.fileContent, "<[^>]+>", " ", "all"), 800));
        }
        return local.response.responseHeader.Location;
    }

}
