component extends="tests.support.integration_spec" {

    /*
        Invoice language - issues #688, #693, #694.

        An invoice is a document in one language (invoices.strLanguageISO). The rule
        for a new invoice lives in invoices.cfc::getInvoiceLanguage: invoice person,
        main user of the customer, customer data, default language.

        Regressions:
          - Invoices were created in the default language when the caller passed none
            (e.g. a new invoice by the sysadmin).
          - Invoice titles of a booking ("Module", "Upgrade", "Cycle change") came from
            the session language - the sysadmin's language when the sysadmin booked.
          - The invoice view and the print mixed languages: stored texts in the invoice
            language, labels in the language of whoever looked at it (#694).
          - The total line was the stored text, so it did not follow a later change of
            the invoice language (#693).

        The test database knows "en" (default) and "de".
    */

    function run() {

        var invoices = new backend.core.com.invoices();

        describe("Invoice language", () => {

            beforeEach(() => {
                session.lng = "en";
                variables.customerID = variables.fixtures.createCustomer();
            });

            describe("getInvoiceLanguage", () => {

                it("takes the language of the invoice person", () => {
                    variables.fixtures.createUser(customerID = variables.customerID, language = "en");
                    var person = variables.fixtures.createUser(customerID = variables.customerID, language = "de");

                    expect(invoices.getInvoiceLanguage(variables.customerID, person.userID)).toBe("de");
                });

                it("takes the language of the main user when the invoice has no person", () => {
                    variables.fixtures.createUser(customerID = variables.customerID, language = "de");
                    variables.fixtures.createUser(customerID = variables.customerID, language = "en");

                    expect(invoices.getInvoiceLanguage(variables.customerID)).toBe("de");
                });

                it("takes the main user when the person has no language or an unknown one", () => {
                    variables.fixtures.createUser(customerID = variables.customerID, language = "de");
                    var withoutLanguage = variables.fixtures.createUser(customerID = variables.customerID, language = "");
                    var unknownLanguage = variables.fixtures.createUser(customerID = variables.customerID, language = "xx");

                    expect(invoices.getInvoiceLanguage(variables.customerID, withoutLanguage.userID)).toBe("de", "No language must not break the invoice");
                    expect(invoices.getInvoiceLanguage(variables.customerID, unknownLanguage.userID)).toBe("de");
                });

                it("falls back to the default language", () => {
                    expect(invoices.getInvoiceLanguage(variables.customerID)).toBe("en");
                });

            });

            describe("createInvoice", () => {

                it("uses the customer's language when the caller passes none (##688)", () => {
                    variables.fixtures.createUser(customerID = variables.customerID, language = "de");

                    var invoice = invoices.getInvoiceData(createInvoice({}));

                    expect(invoice.language).toBe("de");
                    expect(invoice.totaltext).toBe("Betrag inkl. Steuer");
                });

                it("uses the language of the invoice person", () => {
                    variables.fixtures.createUser(customerID = variables.customerID, language = "en");
                    var person = variables.fixtures.createUser(customerID = variables.customerID, language = "de");

                    expect(invoices.getInvoiceData(createInvoice({ userID: person.userID })).language).toBe("de");
                });

                it("keeps a language the caller passes", () => {
                    variables.fixtures.createUser(customerID = variables.customerID, language = "de");

                    expect(invoices.getInvoiceData(createInvoice({ language: "en" })).language).toBe("en");
                });

                it("replaces an unknown language by the default language", () => {
                    expect(invoices.getInvoiceData(createInvoice({ language: "xx" })).language).toBe("en");
                });

            });

            describe("Texts rendered at display time (##693)", () => {

                it("writes the total line for every VAT type in the invoice language", () => {
                    expect(invoices.getTotalText(1, "de")).toBe("Betrag inkl. Steuer");
                    expect(invoices.getTotalText(2, "de")).toBe("Betrag exkl. Steuer");
                    expect(invoices.getTotalText(3, "de")).toBe("Betrag von Steuer befreit", "VAT exempt invoices need their own text");
                    expect(invoices.getTotalText(1, "en")).toBe("Amount incl. tax");
                });

                it("writes the VAT line for net and gross prices", () => {
                    expect(invoices.getVatText(true, 8.1, "de")).toInclude("Zzgl. MwSt.");
                    expect(invoices.getVatText(false, 8.1, "en")).toInclude("Tax included in the price");
                });

                it("follows a later change of the invoice language", () => {
                    variables.fixtures.createUser(customerID = variables.customerID, language = "de");
                    var invoiceID = createInvoice({});

                    var update = invoices.updateInvoice({ invoiceID: invoiceID, customerID: variables.customerID, language: "en", vatType: 1, isNet: true });
                    expect(update.success).toBeTrue(update.message);

                    var invoice = invoices.getInvoiceData(invoiceID);
                    expect(invoice.language).toBe("en");
                    expect(invoices.getTotalText(invoice.vatType, invoices.getDocumentLanguage(invoice.language))).toBe("Amount incl. tax");
                });

            });

            describe("Booking with an invoice", () => {

                it("writes the invoice title in the booking language, not in the session language (##688)", () => {
                    session.lng = "en";
                    var moduleID = variables.fixtures.createModule("Invoice language");

                    var result = new backend.core.com.book("module", "de").checkBooking(
                        customerID = variables.customerID,
                        bookingData = {
                            moduleID: moduleID, name: "Sprachmodul", shortDescription: "", vat: 8.1, vatType: 1, isNet: true,
                            currency: "USD", testDays: 0, testDaysUpgrade: 0, itsFree: false,
                            priceMonthly: 10, priceYearly: 100, priceOnetime: 0, durationDays: 0, redirectPath: ""
                        },
                        recurring = "monthly",
                        makeBooking = true,
                        makeInvoice = true,
                        chargeInvoice = false
                    );

                    var invoice = queryExecute(
                        "SELECT strInvoiceTitle, strLanguageISO FROM invoices WHERE intCustomerID = :customerID",
                        { customerID: { type: "numeric", value: variables.customerID } },
                        { datasource: application.datasource }
                    );
                    expect(invoice.recordCount).toBe(1, result.message ?: "");
                    expect(invoice.strLanguageISO).toBe("de");
                    expect(invoice.strInvoiceTitle).toBe(application.objLanguage.getTrans("titModule", "de") & ": Sprachmodul");
                });

            });

            describe("Views and mails (source)", () => {

                var scanner = new tests.support.security_scanner();

                it("translate every label of the print in the invoice language (##694)", () => {
                    var source = scanner.readSource("backend/core/views/invoices/print.cfm");
                    expect(reMatch("getTrans\('[A-Za-z]+'\)", source)).toBeEmpty("Labels without the invoice language");
                    expect(source).toInclude("setLocale(application.objLanguage.toLocale(invoiceLng))");
                    expect(source).notToInclude("getInvoiceData.totaltext");
                    expect(source).notToInclude("vat.vatText");
                });

                it("show the invoice document in its own language and switch back for the page around it", () => {
                    var source = scanner.readSource("backend/core/views/invoices/invoice.cfm");
                    var start = find("uiLocale = setLocale(", source);
                    var stop = find("setLocale(uiLocale)", source);
                    expect(start).toBeGT(0);
                    expect(stop).toBeGT(start);
                    var documentPart = mid(source, start, stop - start);
                    expect(reMatch("getTrans\('[A-Za-z]+'\)", documentPart)).toBeEmpty("Labels of the invoice without the invoice language");
                    expect(source).notToInclude("getInvoiceData.totaltext");
                });

                it("send the invoice mails in the language of the invoice", () => {
                    var source = scanner.readSource("backend/core/com/invoices.cfc");
                    var mails = mid(source, find("function sendInvoice(", source), find("function getInvoice(", source) - find("function sendInvoice(", source));
                    expect(mails).notToInclude("customerData.language");
                    expect(mails).toInclude("getDocumentLanguage(local.invoiceData.language)");
                });

                it("translate the renewal titles in the customer's language", () => {
                    var source = scanner.readSource("frontend/core/scheduletasks/subscriptions.cfm");
                    expect(source).notToInclude("getTrans('titRenewal')");
                    expect(source).toInclude("objInvoice.getInvoiceLanguage(qRenewBookings.intCustomerID)");
                });

            });

        });

    }

    // An invoice of the spec customer; returns its ID
    private numeric function createInvoice(required struct extra) {
        var data = { customerID: variables.customerID, vatType: 1, title: "TestBox invoice" };
        structAppend(data, arguments.extra, true);
        var result = new backend.core.com.invoices().createInvoice(data);
        expect(result.success).toBeTrue(result.message);
        return result.newInvoiceID;
    }

}
