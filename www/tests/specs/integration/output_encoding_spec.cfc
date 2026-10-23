component extends="tests.support.integration_spec" {

    /*
        Output encoding of database values (stored XSS).

        The static part scans the core views, the themes and the frontend core for
        database fields written into a page without encoding - see rawOutputs() in
        support/security_scanner.cfc. The allowlist below holds the places where the
        value is not HTML output at all, each with its reason.

        The behaviour part renders the invoice address block with markup in the
        customer data: the sysadmin opens these invoices too.
    */

    variables.roots = ["backend/core/views", "frontend/themes", "frontend/core"];

    // file|expression -> reason. Lines that write a log entry are plain text and are skipped in general.
    variables.allowed = {
        "backend/core/views/dashboard.cfm|qUserWidgets.strFilePath": "Path for fileExists/cfinclude, set by the sysadmin - not HTML output",
        "backend/core/views/sysadmin/translations.cfm|qLanguages.strLanguageISO": "Part of a variable name inside evaluate(), language code from the database",
        "frontend/core/mail_design.cfm|customerData.companyName": "Address of the operator (sysadmin settings) in the mail footer"
    };

    private array function scan() {
        if (not structKeyExists(variables, "rawOutputs")) {
            variables.rawOutputs = new tests.support.security_scanner().rawOutputs(variables.roots);
        }
        return variables.rawOutputs;
    }

    function run() {

        describe("Database values in views", () => {

            it("are encoded everywhere except the reviewed places", () => {
                var raw = scan()
                    .filter((item) => not findNoCase("logWrite(", item.source))
                    .filter((item) => not structKeyExists(variables.allowed, item.file & "|" & item.expression))
                    .map((item) => item.file & ":" & item.line & "  " & item.source);

                if (arrayLen(raw)) {
                    fail("Database values written into the page without encodeForHTML():" & chr(10) & arrayToList(raw, chr(10)));
                }
            });

            for (var key in variables.allowed) {
                it(
                    title = variables.allowed[key] & "  [" & replace(key, "|", ": ") & "]",
                    data  = { file: listFirst(key, "|"), expression: listLast(key, "|") },
                    body  = (data) => {
                        var stillThere = scan()
                            .filter((item) => item.file eq data.file and item.expression eq data.expression);
                        expect(arrayLen(stillThere)).toBeGT(0, "No longer found - remove the entry from the allowlist");
                    }
                );
            }

        });

        describe("Invoice address block", () => {

            beforeEach(() => {
                variables.customerID = variables.fixtures.createCustomer(
                    companyName   = "<script>alert('company')</script>",
                    contactPerson = "<img src=x onerror=alert(1)>"
                );
                var invoice = new backend.core.com.invoices().createInvoice({ customerID: variables.customerID });
                expect(invoice.success).toBeTrue(invoice.message);
                variables.invoiceID = invoice.newInvoiceID;
            });

            it("encodes the company, person and address", () => {
                queryExecute(
                    "UPDATE customers SET strAddress = :address, strCity = :city, strBillingAccountName = '', strBillingAddress = '' WHERE intCustomerID = :customerID",
                    {
                        address: { type: "varchar", value: "<b>Street</b>" },
                        city: { type: "varchar", value: """><svg onload=alert(1)>" },
                        customerID: { type: "numeric", value: variables.customerID }
                    },
                    { datasource: application.datasource }
                );

                var block = new backend.core.com.invoices().getInvoiceAddress(variables.invoiceID);

                expect(block).notToInclude("<script");
                expect(block).notToInclude("<img");
                expect(block).notToInclude("<b>");
                expect(block).notToInclude("<svg");
                expect(block).toInclude("&lt;script&gt;");
            });

            it("encodes the billing address and keeps its line breaks", () => {
                queryExecute(
                    "UPDATE customers SET strBillingAccountName = :name, strBillingAddress = :address WHERE intCustomerID = :customerID",
                    {
                        name: { type: "varchar", value: "<script>alert('billing')</script>" },
                        address: { type: "varchar", value: "Line 1" & chr(13) & chr(10) & "<i>Line 2</i>" },
                        customerID: { type: "numeric", value: variables.customerID }
                    },
                    { datasource: application.datasource }
                );

                var block = new backend.core.com.invoices().getInvoiceAddress(variables.invoiceID);

                expect(block).notToInclude("<script");
                expect(block).notToInclude("<i>");
                expect(block).toInclude("Line 1<br />");
            });

        });

    }

}
