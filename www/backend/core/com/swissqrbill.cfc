
component displayname="swissqrbill" output="false" {

    public any function init() {
        return this;
    }

    public any function generateSwissBill(required struct qrData, required string output) {

        // Get the validated qr data
        variables.qrData = validateData(arguments.qrData);
        if (!variables.qrData.success) {
            return variables.qrData.message;
        }

        if (listFindNoCase("pdf,variable", arguments.output)) {
            return createPDF(arguments.output);
        }

        // Generate the QR code as a base64-encoded PNG.
        local.generatedQrCode = generateQRCode(variables.qrData.qrSize);

        if (!local.generatedQrCode.success) {
            return local.generatedQrCode.message;
        }

        // Generate qr code as an image
        if (arguments.output eq "img") {

            // Create image
            local.qrImage = "<img src='data:image/png;base64," & local.generatedQrCode.base64String & "'>";

            return local.qrImage;


        // Generate binary data
        } else if (arguments.output eq "binary") {

            // Just return the binary string
            return local.generatedQrCode.base64String;


        }

        return "";


    }

    private any function generateQRMatrix(required numeric size, required numeric margin) {
        local.hints = createObject("java", "java.util.Hashtable").init();
        local.hintType = createObject("java", "com.google.zxing.EncodeHintType");
        local.hints.put(local.hintType.ERROR_CORRECTION, createObject("java", "com.google.zxing.qrcode.decoder.ErrorCorrectionLevel").M);
        local.hints.put(local.hintType.CHARACTER_SET, "UTF-8");
        local.hints.put(local.hintType.MARGIN, javaCast("int", arguments.margin));
        local.writer = createObject("java", "com.google.zxing.qrcode.QRCodeWriter").init();
        return local.writer.encode(generateQrDataString(), createObject("java", "com.google.zxing.BarcodeFormat").QR_CODE, javaCast("int", arguments.size), javaCast("int", arguments.size), local.hints);
    }

    private struct function generateQRCode(required numeric qrSize, numeric logoSize=0.1) {

        try {

            local.bitMatrix = generateQRMatrix(arguments.qrSize, 4);

            // Convert QR code to a BufferedImage
            local.bufferedImage = createObject("java", "com.google.zxing.client.j2se.MatrixToImageWriter").toBufferedImage(local.bitMatrix);

            // Create a ColdFusion image from the BufferedImage for manipulation
            local.cfQrImage = imageNew(local.bufferedImage);

            // Only add the Swiss logo if specified
            if (len(trim(variables.qrData.qrLogo))) {

                // Load and scale the Swiss logo
                local.logoPath = expandPath(variables.qrData.qrLogo);
                local.logoImage = imageRead(local.logoPath);
                local.scaledWidth = local.cfQrImage.getWidth() * arguments.logoSize; // Scale the logo proportionally
                local.scaledHeight = local.cfQrImage.getHeight() * arguments.logoSize;
                imageScaleToFit(local.logoImage, local.scaledWidth, local.scaledHeight);

                // Calculate the position for the logo to be centered
                local.deltaHeight = (local.cfQrImage.height - local.logoImage.height) / 2;
                local.deltaWidth = (local.cfQrImage.width - local.logoImage.width) / 2;

                // Place the logo in the center of the QR code
                imagePaste(local.cfQrImage, local.logoImage, local.deltaWidth, local.deltaHeight);

            }

            // Convert the ColdFusion image back to a BufferedImage to use with ImageIO
            local.byteArrayOutputStream = createObject("java", "java.io.ByteArrayOutputStream").init();
            createObject("java", "javax.imageio.ImageIO").write(local.cfQrImage.getBufferedImage(), "png", local.byteArrayOutputStream);

            // Convert the ByteArrayOutputStream to a byte array and then to a Base64 string
            local.imageBytes = local.byteArrayOutputStream.toByteArray();
            local.base64String = toBase64(local.imageBytes, "binary");

            // Cleanup resources
            local.byteArrayOutputStream.close();

            return {success: true, base64String: local.base64String};
        } catch (any e) {
            return {success: false, message: e.message};
        }

    }

    private string function buildPrintQRCode() {
        // Use vector rectangles without padding so the printed symbol is exactly 46 mm wide.
        local.matrix = generateQRMatrix(0, 0);
        local.modules = local.matrix.getWidth();
        local.moduleSize = 46 / local.modules;
        local.markup = createObject("java", "java.lang.StringBuilder").init();
        loop from=0 to=local.modules - 1 index="local.y" {
            local.start = -1;
            loop from=0 to=local.modules index="local.x" {
                if (local.x lt local.modules and local.matrix.get(javaCast("int", local.x), javaCast("int", local.y))) {
                    if (local.start lt 0) local.start = local.x;
                } else if (local.start gte 0) {
                    local.markup.append("<div class='qr_modules' style='left:#local.start * local.moduleSize#mm;top:#local.y * local.moduleSize#mm;width:#(local.x - local.start) * local.moduleSize#mm;height:#local.moduleSize#mm'></div>");
                    local.start = -1;
                }
            }
        }
        local.logo = toBase64(fileReadBinary(expandPath("/assets/img/ch-cross.png")));
        local.markup.append("<img class='qr_cross' alt='' src='data:image/png;base64,#local.logo#' />");
        return local.markup.toString();
    }

    private string function buildHTML() {

        if (len(trim(variables.qrData.billerReferenceFormatted))) {
            local.referenceNumberCode = "
                <p class='subtitle'>Referenz</p>
                <p class='text'>" & variables.qrData.billerReferenceFormatted & "</p>
            ";
        } else {
            local.referenceNumberCode = "";
        }

        local.html = "

        <html>
            <head>
                <meta charset='UTF-8'>
                <title>Swiss QR-Bill</title>
                <style>
                    /*
                        Fixed sizes of the Swiss QR-bill (receipt 62mm, payment part 148mm, height 105mm)
                        as table: floats with percentages and padding break into two pages in the PDF
                        renderer of Lucee 7, which no longer has a free 'classic' engine.
                    */
                    body, p, div {
                        margin: 0;
                        padding: 0;
                        font-family: Arial, Helvetica, sans-serif;
                    }
                    table {
                        border-collapse: collapse;
                        table-layout: fixed;
                    }
                    td {
                        padding: 0;
                        vertical-align: top;
                    }
                    ##bill {
                        width: 210mm;
                        height: 105mm;
                        border-top: 1px dotted black;
                    }
                    ##receipt {
                        width: 62mm;
                        height: 105mm;
                        border-right: 1px dotted black;
                    }
                    ##payment {
                        width: 148mm;
                    }
                    .inner {
                        padding: 5mm;
                    }

                    /* Receipt part boxes */
                    ##receipt .account {
                        height: 56mm;
                    }
                    ##receipt .money {
                        height: 14mm;
                    }
                    ##receipt .receiving {
                        text-align: right;
                    }

                    /* Payment part boxes */
                    ##payment .left_part {
                        width: 51mm;
                    }
                    ##payment .top {
                        height: 70mm;
                    }
                    ##payment .qr_code {
                        width: 46mm;
                        height: 46mm;
                        position: relative;
                    }
                    .qr_modules {
                        position: absolute;
                        background-color: black;
                    }
                    .qr_cross {
                        position: absolute;
                        left: 19.5mm;
                        top: 19.5mm;
                        width: 7mm;
                        height: 7mm;
                    }
                    .qr_extended_text {
                        font-family: 'DejaVu Sans';
                    }
                    .currency {
                        width: 40%;
                    }

                    /* Font sizes and paddings */
                    .title, .subtitle {
                        font-weight: bold;
                    }
                    .title {
                        font-size: 11pt;
                        padding-bottom: 4mm;
                    }
                    ##receipt .subtitle {
                        font-size: 6pt;
                        padding-bottom: 1pt;
                    }
                    ##payment .subtitle {
                        font-size: 8pt;
                        padding-bottom: 1pt;
                    }
                    ##receipt .text {
                        font-size: 8pt;
                        padding-bottom: 8pt;
                    }
                    ##payment .text {
                        font-size: 10pt;
                        padding-bottom: 8pt;
                    }
                </style>
            </head>
            <body>
                <table id='bill'>
                    <tr>
                        <td id='receipt'>
                            <div class='inner'>
                                <div class='account'>
                                    <p class='title'>Empfangsschein</p>
                                    <p class='subtitle'>Konto / Zahlbar an</p>
                                    <p class='text'>
                                        " & variables.qrData.billerIBANformatted & "<br />
                                        " & printText(variables.qrData.billerName) & "<br />
                                        " & printText(trim(variables.qrData.billerStreet & " " & variables.qrData.billerStreetNumber)) & "<br />
                                        " & printText(variables.qrData.billerZIP & " " & variables.qrData.billerCity) & "
                                    </p>
                                    #local.referenceNumberCode#
                                    <p class='subtitle'>Zahlbar durch</p>
                                    <p class='text'>
                                        " & printText(variables.qrData.debtorName) & "<br />
                                        " & printText(trim(variables.qrData.debtorStreet & " " & variables.qrData.debtorStreetNumber)) & "<br />
                                        " & printText(variables.qrData.debtorZIP & " " & variables.qrData.debtorCity) & "
                                    </p>
                                </div>
                                <table class='money' width='100%'>
                                    <tr>
                                        <td class='currency'>
                                            <p class='subtitle'>Währung</p>
                                            <p class='text'>" & variables.qrData.invoiceCurrency & "</p>
                                        </td>
                                        <td>
                                            <p class='subtitle'>Betrag</p>
                                            <p class='text'>" & variables.qrData.invoiceAmountPDF & "</p>
                                        </td>
                                    </tr>
                                </table>
                                <p class='receiving subtitle'>Annahmestelle</p>
                            </div>
                        </td>
                        <td id='payment'>
                            <div class='inner'>
                                <table width='100%'>
                                    <tr>
                                        <td class='left_part'>
                                            <div class='top'>
                                                <p class='title'>Zahlteil</p>
                                                <div class='qr_code'>
                                                    " & buildPrintQRCode() & "
                                                </div>
                                            </div>
                                            <table width='100%'>
                                                <tr>
                                                    <td class='currency'>
                                                        <p class='subtitle'>Währung</p>
                                                        <p class='text'>" & variables.qrData.invoiceCurrency & "</p>
                                                    </td>
                                                    <td>
                                                        <p class='subtitle'>Betrag</p>
                                                        <p class='text'>" & variables.qrData.invoiceAmountPDF & "</p>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td class='right_part'>
                                            <p class='subtitle'>Konto / Zahlbar an</p>
                                            <p class='text'>
                                                " & variables.qrData.billerIBANFormatted & "<br />
                                                " & printText(variables.qrData.billerName) & "<br />
                                                " & printText(trim(variables.qrData.billerStreet & " " & variables.qrData.billerStreetNumber)) & "<br />
                                                " & printText(variables.qrData.billerZIP & " " & variables.qrData.billerCity) & "
                                            </p>
                                            #local.referenceNumberCode#
                                            <p class='subtitle'>Zusätzliche Informationen</p>
                                            <p class='text'>" & printText(variables.qrData.invoiceAddText) & "</p>
                                            <p class='subtitle'>Zahlbar durch</p>
                                            <p class='text'>
                                                " & printText(variables.qrData.debtorName) & "<br />
                                                " & printText(trim(variables.qrData.debtorStreet & " " & variables.qrData.debtorStreetNumber)) & "<br />
                                                " & printText(variables.qrData.debtorZIP & " " & variables.qrData.debtorCity) & "
                                            </p>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                </table>
            </body>
        </html>";

        return local.html;

    }

    private string function printText(required string value) {
        local.encoded = encodeForHTML(arguments.value);
        if (arguments.value.matches("[\x20-\x7E\xA0-\xFF]*")) return local.encoded;
        return "<span class='qr_extended_text'>" & local.encoded & "</span>";
    }

    public any function createPDF(string pdfType) {
        local.fontDirectory = expandPath("/assets/fonts/qr-bill");

        // Create and open the PDF directly in the browser
        if (arguments.pdfType eq "pdf") {
            cfdocument(format="pdf", unit="pt", pageType="A4", marginLeft="0", marginRight="0", marginTop="540", marginBottom="0", fontDirectory=local.fontDirectory, fontEmbed="true") {
                writeOutput(buildHTML());
            }
            return;
        }

        // Create the PDF and save it into the memory
        if (arguments.pdfType eq "variable") {
            cfdocument(name="local.qrslip" format="pdf", unit="pt", pageType="A4", marginLeft="0", marginRight="0", marginTop="540", marginBottom="0", fontDirectory=local.fontDirectory, fontEmbed="true") {
                writeOutput(buildHTML());
            }
            return local.qrslip;
        }


        return "";


    }

    private struct function validateData(required struct qrData) {

        local.qrData = {};
        local.errorMessage = "";

        local.qrData["invoiceCurrency"] = uCase(trim(arguments.qrData.invoiceCurrency ?: ""));
        local.payment = validatePaymentDetails(arguments.qrData.billerIBAN ?: "", arguments.qrData.billerQrReference ?: "", local.qrData.invoiceCurrency);
        if (!local.payment.success) return local.payment;
        local.qrData["billerIBANClean"] = local.payment.billerIBANClean;
        local.qrData["billerIBANFormatted"] = local.payment.billerIBANFormatted;
        local.qrData["transactionType"] = local.payment.reference.type;
        local.qrData["billerReferenceClean"] = local.payment.reference.clean;
        local.qrData["billerReferenceFormatted"] = local.payment.reference.formatted;

        // Validate biller
        if (structKeyExists(arguments.qrData, "billerName") and len(trim(arguments.qrData.billerName))) {
            local.qrData["billerName"] = left(trim(arguments.qrData.billerName), 70);
        } else {
            local.errorMessage = "Please provide the account holder!";
        }
        if (structKeyExists(arguments.qrData, "billerStreet") and len(trim(arguments.qrData.billerStreet))) {
            local.qrData["billerStreet"] = left(trim(arguments.qrData.billerStreet), 70);
        } else {
            local.errorMessage = "Biller street is not defined or empty!";
        }
        if (structKeyExists(arguments.qrData, "billerStreetNumber") and len(trim(arguments.qrData.billerStreetNumber))) {
            local.qrData["billerStreetNumber"] = left(trim(arguments.qrData.billerStreetNumber), 5);
        } else {
            local.qrData["billerStreetNumber"] = "";
        }
        if (structKeyExists(arguments.qrData, "billerZip") and len(trim(arguments.qrData.billerZip))) {
            local.qrData["billerZip"] = left(trim(arguments.qrData.billerZip), 4);
        } else {
            local.errorMessage = "Biller ZIP is not defined or empty!";
        }
        if (structKeyExists(arguments.qrData, "billerCity") and len(trim(arguments.qrData.billerCity))) {
            local.qrData["billerCity"] = left(trim(arguments.qrData.billerCity), 70);
        } else {
            local.errorMessage = "Biller city is not defined or empty!";
        }
        if (structKeyExists(arguments.qrData, "billerCountryIso") and len(trim(arguments.qrData.billerCountryIso))) {
            local.qrData["billerCountry"] = left(trim(arguments.qrData.billerCountryIso), 2);
        } else {
            local.errorMessage = "Biller country iso is not defined or empty!";
        }

        // Validate debtor
        if (structKeyExists(arguments.qrData, "debtorName") and len(trim(arguments.qrData.debtorName))) {
            local.qrData["debtorName"] = left(trim(arguments.qrData.debtorName), 70);
        } else {
            local.errorMessage = "Please provide the debtor name!";
        }
        // The Swiss QR-bill specification allows an empty debtor street field.
        local.qrData["debtorStreet"] = left(trim(arguments.qrData.debtorStreet ?: ""), 70);
        if (structKeyExists(arguments.qrData, "debtorStreetNumber") and len(trim(arguments.qrData.debtorStreetNumber))) {
            local.qrData["debtorStreetNumber"] = left(trim(arguments.qrData.debtorStreetNumber), 5);
        } else {
            local.qrData["debtorStreetNumber"] = "";
        }
        if (structKeyExists(arguments.qrData, "debtorZip") and len(trim(arguments.qrData.debtorZip))) {
            local.qrData["debtorZip"] = left(trim(arguments.qrData.debtorZip), 4);
        } else {
            local.errorMessage = "Debtor ZIP is not defined or empty!";
        }
        if (structKeyExists(arguments.qrData, "debtorCity") and len(trim(arguments.qrData.debtorCity))) {
            local.qrData["debtorCity"] = left(trim(arguments.qrData.debtorCity), 70);
        } else {
            local.errorMessage = "Debtor city is not defined or empty!";
        }
        if (structKeyExists(arguments.qrData, "debtorCountryIso") and len(trim(arguments.qrData.debtorCountryIso))) {
            local.qrData["debtorCountry"] = left(trim(arguments.qrData.debtorCountryIso), 2)
        } else {
            local.errorMessage = "Debtor country iso is not defined or empty!";
        }

        // Validate amount
        if (structKeyExists(arguments.qrData, "invoiceAmount") and isNumeric(arguments.qrData.invoiceAmount)
            and arguments.qrData.invoiceAmount gte 0.01 and arguments.qrData.invoiceAmount lte 999999999.99) {
            local.qrData["invoiceAmountQRCode"] = formatAmount(arguments.qrData.invoiceAmount, "qrcode");
            local.qrData["invoiceAmountPDF"] = formatAmount(arguments.qrData.invoiceAmount, "pdf");
        } else {
            local.errorMessage = "The QR-bill amount must be between 0.01 and 999999999.99.";
        }

        // Return error message if needed
        if (len(local.errorMessage)) {
            return {success: false, message: local.errorMessage};
        }

        // Additional text
        local.qrData["invoiceAddText"] = structKeyExists(arguments.qrData, "invoiceAddText") ? left(trim(arguments.qrData.invoiceAddText), 140) : "";

        // Validate each text field separately so embedded line breaks cannot shift the QR fields.
        loop list="billerName,billerStreet,billerStreetNumber,billerZIP,billerCity,billerCountry,debtorName,debtorStreet,debtorStreetNumber,debtorZIP,debtorCity,debtorCountry,invoiceAddText" item="local.field" {
            if (!local.qrData[local.field].matches("[\x20-\x7E\xA0-\xFF\u0100-\u017F\u0218-\u021B\u20AC]*")) {
                return {success: false, message: "Unsupported QR-bill characters in field: " & local.field & "."};
            }
        }

        // Parse the size for the qr code
        local.qrData["qrSize"] = structKeyExists(arguments.qrData, "qrSize") and isNumeric(arguments.qrData.qrSize) ? arguments.qrData.qrSize : 200;

        // Path to the swiss cross logo
        local.qrData["qrLogo"] = structKeyExists(arguments.qrData, "qrLogo") and len(trim(arguments.qrData.qrLogo)) ? arguments.qrData.qrLogo : "";

        local.qrData["success"] = true;

        return local.qrData;

    }

    public struct function validatePaymentDetails(required string iban, required string reference, string currency = "CHF") {
        local.payment = formatIBAN(arguments.iban);
        if (!local.payment.success) return local.payment;
        if (!listFind("CHF,EUR", arguments.currency)) {
            return {success: false, message: "The QR-bill currency must be CHF or EUR."};
        }
        local.iid = val(mid(local.payment.billerIBANClean, 5, 5));
        local.reference = formatReference(arguments.reference, local.iid gte 30000 and local.iid lte 31999, arguments.currency);
        if (!local.reference.success) return local.reference;
        local.payment.reference = local.reference;
        return local.payment;
    }

    public struct function formatIBAN(required string iban) {
        local.iban = uCase(reReplace(arguments.iban, "\s+", "", "all"));
        if (!reFind("^(CH|LI)[0-9]{7}[A-Z0-9]{12}$", local.iban) or !hasValidMod97(local.iban)) {
            return {success: false, message: "Enter a valid Swiss or Liechtenstein IBAN for the QR-bill."};
        }
        return {
            success: true,
            message: "OK",
            billerIBANClean: local.iban,
            billerIBANFormatted: trim(reReplace(local.iban, "(.{4})", "\1 ", "all"))
        };
    }

    private struct function formatReference(required string reference, required boolean qrIBAN, required string currency) {
        local.reference = uCase(reReplace(arguments.reference, "\s+", "", "all"));
        if (arguments.qrIBAN) {
            if (arguments.currency neq "CHF" or !reFind("^[0-9]{1,27}$", local.reference) or !reFind("[1-9]", local.reference)) {
                return {success: false, message: "A QR-IBAN requires a numeric QR reference and can only be used for CHF invoices. Check the IBAN and QR reference from your bank."};
            }
            local.base = right(repeatString("0", 26) & left(local.reference, 26), 26);
            local.complete = local.base & calculateChecksum(local.base);
            if (len(local.reference) eq 27 and compare(local.reference, local.complete) neq 0) {
                return {success: false, message: "The QR reference check digit is invalid."};
            }
            return {success: true, type: "QRR", clean: local.complete, formatted: formatReferenceNumber(local.complete)};
        }
        if (!len(local.reference)) {
            return {success: true, type: "NON", clean: "", formatted: ""};
        }
        if (!reFind("^RF[0-9]{2}[A-Z0-9]{1,21}$", local.reference) or !hasValidMod97(local.reference)) {
            return {success: false, message: "A standard IBAN requires a valid RF creditor reference or an empty reference."};
        }
        return {
            success: true,
            type: "SCOR",
            clean: local.reference,
            formatted: trim(reReplace(local.reference, "(.{4})", "\1 ", "all"))
        };
    }

    private boolean function hasValidMod97(required string value) {
        local.checkDigits = val(mid(arguments.value, 3, 2));
        if (local.checkDigits lt 2 or local.checkDigits gt 98) return false;

        local.rotated = mid(arguments.value, 5, len(arguments.value) - 4) & left(arguments.value, 4);
        local.remainder = 0;
        loop from=1 to=len(local.rotated) index="local.index" {
            local.code = asc(mid(local.rotated, local.index, 1));
            if (local.code gte 65) {
                local.remainder = (local.remainder * 100 + local.code - 55) % 97;
            } else {
                local.remainder = (local.remainder * 10 + local.code - 48) % 97;
            }
        }
        return local.remainder eq 1;
    }

    private string function formatReferenceNumber(required string reference) {

        // Festlegung der Gruppenlängen
        local.groupLengths = [2, 5, 5, 5, 5, 5];
        local.formattedNumber = "";
        local.currentIndex = 1;

        // Durchlaufen der Gruppenlängen und Formatieren der Nummer entsprechend
        for (local.length in local.groupLengths) {

            // Füge die entsprechende Zifferngruppe und ein Leerzeichen hinzu
            local.formattedNumber &= mid(arguments.reference, local.currentIndex, local.length) & " ";

            // Aktualisiere den aktuellen Index
            local.currentIndex += local.length;

        }

        return local.formattedNumber;

    }

    private numeric function calculateChecksum(required string number) {
        local.table = [0, 9, 4, 6, 8, 2, 7, 1, 3, 5];
        local.carry = 0;
        loop from=1 to=len(arguments.number) index="local.index" {
            local.digit = val(mid(arguments.number, local.index, 1));
            local.carry = local.table[((local.carry + local.digit) % 10) + 1];
        }
        return (10 - local.carry) % 10;
    }

    private string function formatAmount(required numeric amount, string output="qrcode") {

        // Prepare for qr code
        if (arguments.output eq "qrcode") {
            local.formattedAmount = numberFormat(arguments.amount, "_.__");

        // Prepare for PDF
        } else {
            local.amount = numberFormat(arguments.amount, "_,___.__");
            local.formattedAmount = replace(local.amount, ",", " ", "all");
        }

        return local.formattedAmount;

    }

    private string function generateQrDataString() {

        local.oneBreak = chr(13) & chr(10);

        // Generate the data string for the QR code
        local.dataString = "";
        local.dataString = "SPC" & local.oneBreak & "0200" & local.oneBreak & "1" & local.oneBreak;
        local.dataString &= variables.qrData.billerIBANclean & local.oneBreak;
        local.dataString &= "S" & local.oneBreak;
        local.dataString &= variables.qrData.billerName & local.oneBreak;
        local.dataString &= variables.qrData.billerStreet & local.oneBreak;
        local.dataString &= variables.qrData.billerStreetNumber & local.oneBreak;
        local.dataString &= variables.qrData.billerZIP & local.oneBreak;
        local.dataString &= variables.qrData.billerCity & local.oneBreak;
        local.dataString &= variables.qrData.billerCountry & local.oneBreak;
        local.dataString &= local.oneBreak & local.oneBreak & local.oneBreak & local.oneBreak & local.oneBreak & local.oneBreak & local.oneBreak; // 7 breaks
        local.dataString &= variables.qrData.invoiceAmountQRCode & local.oneBreak;
        local.dataString &= variables.qrData.invoiceCurrency & local.oneBreak;
        local.dataString &= "S" & local.oneBreak;
        local.dataString &= variables.qrData.debtorName & local.oneBreak;
        local.dataString &= variables.qrData.debtorStreet & local.oneBreak;
        local.dataString &= variables.qrData.debtorStreetNumber & local.oneBreak;
        local.dataString &= variables.qrData.debtorZIP & local.oneBreak
        local.dataString &= variables.qrData.debtorCity & local.oneBreak
        local.dataString &= variables.qrData.debtorCountry & local.oneBreak;
        local.dataString &= variables.qrData.transactionType & local.oneBreak;
        local.dataString &= variables.qrData.billerReferenceClean & local.oneBreak;
        local.dataString &= variables.qrData.invoiceAddText & local.oneBreak;
        local.dataString &= "EPD";

        return local.dataString;

    }


}
