component extends="testbox.system.BaseSpec" {

    /*
        PDF output on Lucee 7.

        Lucee 7 ships the "classic" PDF engine (PD4ML) only as demo: every page gets a
        "PD4ML DEMO MODE" watermark. The app therefore always uses "modern", and the
        templates are made for it - with floats and percentages the Swiss QR-bill broke
        into two pages there.
    */

    function run() {

        var scanner = new tests.support.security_scanner();

        describe("Swiss QR-bill", () => {

            it("fits on one page", () => {
                var qrData = {
                    billerIBAN: "CH44 3199 9123 0008 8901 2", billerQrReference: "RF18539007547034", billerName: "Test AG",
                    billerStreet: "Teststrasse", billerStreetNumber: "1", billerZip: "8000", billerCity: "Zürich", billerCountryIso: "CH",
                    debtorName: "Kunde GmbH", debtorStreet: "Bahnhofstrasse", debtorStreetNumber: "2", debtorZip: "3000", debtorCity: "Bern", debtorCountryIso: "CH",
                    invoiceAmount: 123.45, invoiceCurrency: "CHF", invoiceAddText: "Invoice 1001", qrLogo: "", qrSize: 166
                };
                var slip = new backend.core.com.swissqrbill().generateSwissBill(qrData, "variable");

                expect(isBinary(slip)).toBeTrue(isBinary(slip) ? "" : slip);
                cfpdf(action="getInfo", source=slip, name="local.info");
                expect(local.info.totalPages).toBe(1);
            });

        });

        describe("PDF engine (source)", () => {

            it("always uses the modern engine", () => {
                expect(scanner.readSource("Application.cfc")).toInclude('this.pdf.type = "modern";');
            });

            it("has no cfdocument with the classic engine", () => {
                for (var file in ["backend/core/com/swissqrbill.cfc", "backend/core/com/invoice_document.cfm"]) {
                    expect(reFindNoCase("type\s*=\s*[""']classic", scanner.readSource(file))).toBe(0, file);
                }
            });

            it("gives the invoice logo a fixed size (modern ignores max-width)", () => {
                var source = scanner.readSource("backend/core/com/invoice_document.cfm");
                expect(source).notToInclude('style="max-width');
                expect(source).toInclude('style="##local.logoSize##');
            });

        });

    }

}
