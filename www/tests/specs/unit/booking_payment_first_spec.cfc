component extends="testbox.system.BaseSpec" {

    /*
        Booking without a payment method - issue #521.

        Before: a paid plan or module without a payment method linked to the bare payment
        page. After adding the payment method the customer landed on the payment page
        again and had to go back to the plans and book once more.

        Now the booking buttons carry the booking link as redirect (book.cfc::paymentFirstLink).
        Application.cfc keeps it in session.redirect, handler/payment.cfm opens it right after
        the payment method was added successfully - for plans and modules.
    */

    function run() {

        var book = new backend.core.com.book();

        describe("paymentFirstLink", () => {

            it("leads to the payment page and carries the plan booking as redirect", () => {
                var bookingLink = application.mainURL & "/book?plan=eyJwbGFuSUQiOjF9+/=";

                var link = book.paymentFirstLink(bookingLink);

                expect(link).toBe(application.mainURL & "/account-settings/payment?redirect=" & urlEncodedFormat("book?plan=eyJwbGFuSUQiOjF9+/="));
            });

            it("gives back the exact booking link once Application.cfc has resolved the redirect", () => {
                var bookingLink = application.mainURL & "/book?module=abc+def/ghi==";
                var redirect = urlDecode(listLast(book.paymentFirstLink(bookingLink), "="));

                // Application.cfc: session.redirect = application.mainURL & "/" & url.redirect
                expect(application.mainURL & "/" & redirect).toBe(bookingLink);
            });

            it("accepts a booking link without the main URL", () => {
                expect(book.paymentFirstLink("/book?plan=xyz")).toBe(book.paymentFirstLink(application.mainURL & "/book?plan=xyz"));
            });

        });

        describe("Wiring (source)", () => {

            var scanner = new tests.support.security_scanner();

            it("books right after a successful setup of the payment method, for plans and modules", () => {
                var source = scanner.readSource("backend/core/handler/payment.cfm");
                expect(source).toInclude("paymentMethodAdded = true;");
                expect(source).toInclude("reFindNoCase(""[?&](plan|module)="", session.redirect)");
                expect(reFind("\(paymentMethodAdded \?: false\) and structKeyExists\(session, ""redirect""\)", source)).toBeGT(0, "The booking must wait for a successful setup");
            });

            it("lets every booking button without payment method carry the booking", () => {
                var plans = scanner.readSource("backend/core/views/customer/plans.cfm");
                var modules = scanner.readSource("backend/core/views/customer/modules.cfm");
                var planCalc = scanner.readSource("backend/core/views/plan_calc.cfm");

                expect(planCalc).toInclude("objBooking.paymentFirstLink(bookingLink)");
                expect(plans).toInclude("paymentFirstLink(");
                expect(reMatch("paymentFirstLink\(module\.(moduleData\.)?bookingLink[MYO]\)", modules)).toHaveLength(6);

                for (var source in [plans, modules, planCalc]) {
                    expect(reMatch("[""']##?application\.mainURL##?/account-settings/payment[""']|application\.mainURL & ""/account-settings/payment""", source)).toBeEmpty("A booking button still leads to the bare payment page");
                }
            });

            it("forgets the waiting booking when the payment setup is canceled", () => {
                var source = scanner.readSource("backend/core/views/customer/payment.cfm");
                var cancelBranch = mid(source, find("structKeyExists(url, ""cancel"")", source), 3000);
                expect(cancelBranch).toInclude("structDelete(session, ""redirect"");");
            });

        });

    }

}
