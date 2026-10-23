component extends="tests.support.integration_spec" {

    /*
        Invoices rendered in different languages - issue #694 and its neighbours.

        The invoice view and the print are rendered for real (support/invoice_render_probe.cfm)
        by a user whose interface language differs from the invoice language: the invoice
        must be entirely in its own language (labels, totals, VAT line, date), the page
        around it in the user's. The mails are sent and read back from Inbucket.

        A third language ("fr", created for this spec and removed again) is only partly
        translated: missing texts must fall back to the default language instead of
        leaving empty labels.
    */

    variables.probeUrl = "http://127.0.0.1/tests/support/invoice_render_probe.cfm";

    function run() {

        var invoices = new backend.core.com.invoices();

        describe("Invoices rendered in other languages", () => {

            beforeEach(() => {
                variables.customerID = variables.fixtures.createCustomer();
                // The first user is the main user of the customer
                variables.germanUser = variables.fixtures.createUser(customerID = variables.customerID, language = "de");
                variables.englishUser = variables.fixtures.createUser(customerID = variables.customerID, language = "en");
            });

            describe("Invoice view", () => {

                it("shows a German invoice in German to an English user, the page around it in English", () => {
                    var invoiceID = createInvoiceWithPosition("de");

                    var html = renderInvoice("invoice", invoiceID, variables.englishUser.userID, "en");
                    var invoicePart = documentPart(html);

                    expectGerman(invoicePart, invoiceID);
                    expect(invoicePart).notToInclude(trans("titInvoiceDate", "en"));
                    expect(html).toInclude(trans("txtPayInvoice", "en"));
                    expect(html).notToInclude(trans("txtPayInvoice", "de"));
                });

                it("shows an English invoice in English to a German user, the page around it in German", () => {
                    var invoiceID = createInvoiceWithPosition("en");

                    var html = renderInvoice("invoice", invoiceID, variables.germanUser.userID, "de");
                    var invoicePart = documentPart(html);

                    expectEnglish(invoicePart, invoiceID);
                    expect(invoicePart).notToInclude(trans("titInvoiceDate", "de"));
                    expect(html).toInclude(trans("txtPayInvoice", "de"));
                });

            });

            describe("Print", () => {

                it("prints a German invoice in German for an English user", () => {
                    var invoiceID = createInvoiceWithPosition("de");

                    var html = renderInvoice("print", invoiceID, variables.englishUser.userID, "en");

                    expectGerman(html, invoiceID);
                    expect(html).notToInclude(trans("titInvoiceDate", "en"));
                    expect(html).notToInclude(trans("txtTotalIncl", "en"));
                });

                it("prints an English invoice in English for a German user", () => {
                    var invoiceID = createInvoiceWithPosition("en");

                    var html = renderInvoice("print", invoiceID, variables.germanUser.userID, "de");

                    expectEnglish(html, invoiceID);
                    expect(html).notToInclude(trans("titInvoiceDate", "de"));
                });

            });

            describe(title = "Mails", skip = !len(mailCatcher()), body = () => {

                it("sends the invoice in the language of the invoice, whatever the session language", () => {
                    session.lng = "en";
                    var invoiceID = createInvoiceWithPosition("de");
                    clearMailbox();

                    var result = invoices.sendInvoice(invoiceID);

                    expect(result.success).toBeTrue(result.message);
                    var mail = waitForMail(trans("titInvoiceReady", "de"));
                    expect(mail.body).toInclude(trans("titHello", "de"));
                    expect(mail.body).toInclude(trans("txtDownloadInvoice", "de"));
                    expect(mail.body).notToInclude(trans("txtDownloadInvoice", "en"));
                });

                it("sends the payment request in the language of the invoice", () => {
                    session.lng = "de";
                    var invoiceID = createInvoiceWithPosition("en");
                    clearMailbox();

                    var result = invoices.sendPaymentRequest(invoiceID);

                    expect(result.success).toBeTrue(result.message);
                    var mail = waitForMail(trans("titInvoice", "en"));
                    expect(mail.body).toInclude(trans("txtPleasePayInvoice", "en"));
                    expect(mail.body).notToInclude(trans("txtPleasePayInvoice", "de"));
                });

            });

            describe(title = "A language that is only partly translated", skip = frenchExistsAlready(), body = () => {

                beforeEach(() => {
                    addFrench({ titInvoice: "Facture", txtTotalIncl: "Montant TTC", titHello: "Bonjour" });
                });

                afterEach(() => {
                    removeFrench();
                });

                it("shows the French texts and the default language where a translation is missing", () => {
                    var invoiceID = createInvoiceWithPosition("fr");

                    var html = renderInvoice("print", invoiceID, variables.germanUser.userID, "de");

                    expect(html).toInclude("Facture");
                    expect(html).toInclude("Montant TTC");
                    expect(html).toInclude(trans("titInvoiceDate", "en"), "Untranslated label must show the default language");
                    expect(html).notToInclude("--undefined--");
                });

                it("never answers with an empty text for a missing translation", () => {
                    expect(application.objLanguage.getTrans("titInvoiceDate", "fr")).toBe(trans("titInvoiceDate", "en"));
                    expect(application.objLanguage.getTrans("titInvoice", "fr")).toBe("Facture");
                });

                it("creates the invoice in French for a French customer", () => {
                    var frenchCustomer = variables.fixtures.createCustomer();
                    variables.fixtures.createUser(customerID = frenchCustomer, language = "fr");

                    expect(invoices.getInvoiceLanguage(frenchCustomer)).toBe("fr");
                });

            });

            it("falls back to the default language also when called like the views do (function reference)", () => {
                // The views call getTrans through a reference (Application.cfc: getTrans = application.objLanguage.getTrans).
                // Functions of language.cfc are not in reach there - the fallback must not call them unqualified.
                var getTransReference = application.objLanguage.getTrans;
                expect(getTransReference("titInvoice", "zz")).toBe(trans("titInvoice", "en"));
                expect(getTransReference("testboxNoSuchVariable", "de")).toBe("--undefined--");
            });

            it("does not fail on a language the translation cache does not know", () => {
                expect(application.objLanguage.getTrans("titInvoice", "zz")).toBe(trans("titInvoice", "en"));
            });

        });

    }

    // ---------- invoices ----------

    private numeric function createInvoiceWithPosition(required string language) {
        var objInvoices = new backend.core.com.invoices();
        var created = objInvoices.createInvoice({ customerID: variables.customerID, language: arguments.language, vatType: 1, isNet: true, title: "TestBox invoice" });
        expect(created.success).toBeTrue(created.message);

        var positions = objInvoices.insertInvoicePositions({
            invoiceID: created.newInvoiceID,
            append: false,
            positions: [{ title: "TestBox position", description: "", quantity: 1, discountPercent: 0, vat: 8.1, price: 100, unit: "x" }]
        });
        expect(positions.success).toBeTrue(positions.message);

        return created.newInvoiceID;
    }

    private void function expectGerman(required string html, required numeric invoiceID) {
        expect(arguments.html).toInclude(trans("titInvoice", "de"));
        expect(arguments.html).toInclude(trans("titInvoiceDate", "de"));
        expect(arguments.html).toInclude(trans("txtTotalIncl", "de"));
        expect(arguments.html).toInclude(trans("txtPlusVat", "de"));
        expect(arguments.html).toInclude(invoiceDate(arguments.invoiceID, "de"), "Date in the German format");
    }

    private void function expectEnglish(required string html, required numeric invoiceID) {
        expect(arguments.html).toInclude(trans("titInvoice", "en"));
        expect(arguments.html).toInclude(trans("titInvoiceDate", "en"));
        expect(arguments.html).toInclude(trans("txtTotalIncl", "en"));
        expect(arguments.html).toInclude(trans("txtPlusVat", "en"));
        expect(arguments.html).toInclude(invoiceDate(arguments.invoiceID, "en"), "Date in the English format");
    }

    // The invoice date as the view formats it in the locale of the given language
    private string function invoiceDate(required numeric invoiceID, required string language) {
        var invoiceData = new backend.core.com.invoices().getInvoiceData(arguments.invoiceID);
        var previous = setLocale(application.objLanguage.toLocale(arguments.language));
        try {
            return lsDateFormat(new backend.core.com.time(variables.customerID).utc2local(utcDate = invoiceData.date));
        } finally {
            setLocale(previous);
        }
    }

    private string function trans(required string key, required string language) {
        return application.objLanguage.getTrans(arguments.key, arguments.language);
    }

    // ---------- rendering ----------

    // The HTML of the view, or the text of the printed PDF
    private string function renderInvoice(required string view, required numeric invoiceID, required numeric userID, required string lng) {
        cfhttp(url = variables.probeUrl & "?view=" & arguments.view & "&invoiceID=" & arguments.invoiceID & "&userID=" & arguments.userID & "&lng=" & arguments.lng, method = "get", redirect = false, timeout = 60, getAsBinary = "yes", result = "local.response");

        if (arguments.view eq "print") {
            if (!isBinary(local.response.fileContent) or left(toString(local.response.fileContent), 4) neq "%PDF") {
                fail("No PDF from the render probe (" & local.response.statusCode & "): " & left(reReplace(toString(local.response.fileContent), "<[^>]+>", " ", "all"), 800));
            }
            var pdfPath = getTempDirectory() & "testbox-invoice-" & createUUID() & ".pdf";
            fileWrite(pdfPath, local.response.fileContent);
            try {
                cfpdf(action = "extracttext", source = pdfPath, name = "local.pdfText");
            } finally {
                fileDelete(pdfPath);
            }
            return reReplace(toString(local.pdfText), "<[^>]+>", " ", "all");
        }

        local.response.fileContent = toString(local.response.fileContent);
        if (!isJSON(local.response.fileContent)) {
            fail("No JSON from the render probe (" & local.response.statusCode & "): " & left(reReplace(local.response.fileContent, "<[^>]+>", " ", "all"), 800));
        }
        return deserializeJSON(local.response.fileContent).html;
    }

    // The invoice document inside the view: between the locale switch markers of invoice.cfm
    private string function documentPart(required string html) {
        var start = find("card card-lg", arguments.html);
        var stop = find("dropdown-toggle", arguments.html);
        expect(start).toBeGT(0, "Invoice card not found");
        return mid(arguments.html, start, (stop gt start ? stop : len(arguments.html)) - start);
    }

    // ---------- mails (Inbucket) ----------

    private string function mailCatcher() {
        return request.testSettings.mailCatcherUrl ?: "";
    }

    private string function mailbox() {
        var address = new backend.core.com.invoices().getInvoiceEmail(customerID = variables.customerID);
        return lCase(listFirst(address, "@"));
    }

    private void function clearMailbox() {
        cfhttp(url = mailCatcher() & "/api/v1/mailbox/" & mailbox(), method = "delete", timeout = 10);
    }

    // Waits up to 15 seconds for a mail with the given subject start; returns { subject, body }
    private struct function waitForMail(required string subjectStart) {
        for (var attempt = 1; attempt lte 30; attempt++) {
            cfhttp(url = mailCatcher() & "/api/v1/mailbox/" & mailbox(), method = "get", timeout = 10, result = "local.list");
            if (isJSON(local.list.fileContent)) {
                for (var entry in deserializeJSON(local.list.fileContent)) {
                    if (left(entry.subject, len(arguments.subjectStart)) eq arguments.subjectStart) {
                        cfhttp(url = mailCatcher() & "/api/v1/mailbox/" & mailbox() & "/" & entry.id, method = "get", timeout = 10, result = "local.message");
                        var message = deserializeJSON(local.message.fileContent);
                        return { subject: entry.subject, body: message.body.html ?: message.body.text ?: "" };
                    }
                }
            }
            sleep(500);
        }
        fail("No mail starting with [" & arguments.subjectStart & "] arrived in the mailbox " & mailbox());
    }

    // ---------- a third language ----------

    private boolean function frenchExistsAlready() {
        return queryExecute("SELECT COUNT(*) AS cnt FROM languages WHERE strLanguageISO = 'fr'", {}, { datasource: application.datasource }).cnt gt 0;
    }

    // Adds French like the sysadmin does (handler/sysadmin/languages.cfm), with a few translations
    private void function addFrench(required struct translations) {
        queryExecute("ALTER TABLE system_translations ADD COLUMN strStringFR longtext", {}, { datasource: application.datasource });
        queryExecute("ALTER TABLE custom_translations ADD COLUMN strStringFR longtext", {}, { datasource: application.datasource });
        queryExecute(
            "INSERT INTO languages (strLanguageISO, strLanguageEN, strLanguage, intPrio, blnDefault, blnChooseable) VALUES ('fr', 'TestBox French', 'Français', 999, 0, 0)",
            {},
            { datasource: application.datasource }
        );
        for (var key in arguments.translations) {
            queryExecute(
                "UPDATE system_translations SET strStringFR = :text WHERE strVariable = :key",
                { text: { type: "varchar", value: arguments.translations[key] }, key: { type: "varchar", value: key } },
                { datasource: application.datasource }
            );
        }
        application.langStruct = application.objLanguage.initLanguages();
    }

    private void function removeFrench() {
        queryExecute("DELETE FROM languages WHERE strLanguageISO = 'fr' AND strLanguageEN = 'TestBox French'", {}, { datasource: application.datasource });
        queryExecute("ALTER TABLE system_translations DROP COLUMN strStringFR", {}, { datasource: application.datasource });
        queryExecute("ALTER TABLE custom_translations DROP COLUMN strStringFR", {}, { datasource: application.datasource });
        application.langStruct = application.objLanguage.initLanguages();
    }

}
