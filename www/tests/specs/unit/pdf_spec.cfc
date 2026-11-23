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

            it("fits on one page with a grouped amount", () => {
                local.slip = new backend.core.com.swissqrbill().generateSwissBill(qrData(), "variable");

                expect(isBinary(local.slip)).toBeTrue(isBinary(local.slip) ? "" : local.slip);
                cfpdf(action="getInfo", source=local.slip, name="local.info");
                expect(local.info.totalPages).toBe(1);
            });

            it("encodes accented names and a zero QRR check digit", () => {
                local.data = qrData();
                local.data.billerIBAN = "CH44 3199 9123 0008 8901 2";
                local.data.billerQrReference = "11";
                local.encoded = new backend.core.com.swissqrbill().generateSwissBill(local.data, "binary");
                local.image = imageReadBase64(local.encoded).getBufferedImage();
                local.source = createObject("java", "com.google.zxing.client.j2se.BufferedImageLuminanceSource").init(local.image);
                local.binarizer = createObject("java", "com.google.zxing.common.HybridBinarizer").init(local.source);
                local.bitmap = createObject("java", "com.google.zxing.BinaryBitmap").init(local.binarizer);
                local.decoded = createObject("java", "com.google.zxing.qrcode.QRCodeReader").init().decode(local.bitmap);
                local.fields = listToArray(replace(local.decoded.getText(), chr(13), "", "all"), chr(10), true);
                expect(local.fields[10]).toBe("Zürich");
                expect(local.fields[22]).toBe("Łódź & Partner");
                expect(local.fields[28]).toBe("QRR");
                expect(local.fields[29]).toBe(repeatString("0", 24) & "110");
                expect(local.decoded.getResultMetadata().get(createObject("java", "com.google.zxing.ResultMetadataType").ERROR_CORRECTION_LEVEL)).toBe("M");
            });

            it("rejects incorrect IBANs and incompatible or invalid references", () => {
                local.cases = [
                    {iban: "CH5900791123000889012", reference: "", currency: "CHF", error: "valid Swiss or Liechtenstein IBAN"},
                    {iban: "CH0000791123000880065", reference: "", currency: "CHF", error: "valid Swiss or Liechtenstein IBAN"},
                    {iban: "CH4431999123000889012", reference: "RF18539007547034", currency: "CHF", error: "QR-IBAN requires"},
                    {iban: "CH4431999123000889012", reference: "", currency: "CHF", error: "QR-IBAN requires"},
                    {iban: "CH4431999123000889012", reference: "11", currency: "EUR", error: "QR-IBAN requires"},
                    {iban: "CH4431999123000889012", reference: repeatString("0", 24) & "111", currency: "CHF", error: "check digit is invalid"},
                    {iban: "CH5800791123000889012", reference: "11", currency: "CHF", error: "standard IBAN requires"},
                    {iban: "CH5800791123000889012", reference: "RF19539007547034", currency: "CHF", error: "standard IBAN requires"}
                ];
                local.generator = new backend.core.com.swissqrbill();
                loop array=local.cases item="local.case" {
                    local.data = qrData();
                    local.data.billerIBAN = local.case.iban;
                    local.data.billerQrReference = local.case.reference;
                    local.data.invoiceCurrency = local.case.currency;
                    expect(local.generator.generateSwissBill(local.data, "binary")).toInclude(local.case.error);
                }
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

    private struct function qrData() {
        return {
            billerIBAN: "CH58 0079 1123 0008 8901 2", billerQrReference: "RF18539007547034", billerName: "Test AG",
            billerStreet: "Teststrasse", billerStreetNumber: "1", billerZip: "8000", billerCity: "Zürich", billerCountryIso: "CH",
            debtorName: "Łódź & Partner", debtorStreet: "", debtorStreetNumber: "", debtorZip: "3000", debtorCity: "Bern", debtorCountryIso: "CH",
            invoiceAmount: 5000.00, invoiceCurrency: "CHF", invoiceAddText: "Invoice 1001", qrLogo: "", qrSize: 500
        };
    }

}
