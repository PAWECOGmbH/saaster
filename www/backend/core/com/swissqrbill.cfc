
component displayname="swissqrbill" output="false" {

    public any function init() {

        variables.returnStruct = {};
        variables.returnStruct['success'] = true;
        variables.returnStruct['message'] = "OK";

        return this;

    }

    public string function generateSwissBill(required struct qrData, required string output) {

        // Get the validated qr data
        variables.qrData = validateData(arguments.qrData);
        if (!variables.qrData.success) {
            return variables.qrData.message;
        }

        // Gererate the qr code as binary string base64
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


        // Generate pdf
        } else if (arguments.output eq "pdf") {

            return createPDF("pdf");


        // Generate pdf using a variable
        } else if (arguments.output eq "variable") {

            return createPDF("variable");

        }

        return "";


    }

    private struct function generateQRCode(required numeric qrSize, numeric logoSize=0.1) {

        try {

            // Load QRCodeWriter and other necessary classes
            local.qrCodeWriter = createObject("java", "com.google.zxing.qrcode.QRCodeWriter").init();
            local.hintMap = createObject("java", "java.util.Hashtable").init();
            local.errorCorrectionLevel = createObject("java", "com.google.zxing.qrcode.decoder.ErrorCorrectionLevel").H; // High fault tolerance
            local.hintMap.put(createObject("java", "com.google.zxing.EncodeHintType").ERROR_CORRECTION, local.errorCorrectionLevel);
            local.hintMap.put(createObject("java", "com.google.zxing.EncodeHintType").MARGIN, javaCast("int", 0));

            // Data for the QR code
            local.myData = generateQrDataString(variables.qrData);

            // Generate the QR code
            local.bitMatrix = local.qrCodeWriter.encode(local.myData, createObject("java", "com.google.zxing.BarcodeFormat").QR_CODE, arguments.qrSize, arguments.qrSize, local.hintMap);

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

            // Store or return the base64 encoded string as needed
            variables.returnStruct['base64String'] = local.base64String;


        } catch (any e) {

            variables.returnStruct['success'] = false;
            variables.returnStruct['message'] = e.message;

        }

        return variables.returnStruct;

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
                <title>Swiss QR-Bill</title>
                <style>
                    /* Generell */
                    body, p, div {
                        margin: 0;
                        padding: 0;
                        font-family: 'Arial';
                    }
                    ##bill {
                        width: 100%;
                        height: 240pt;
                        border-top: 1px dotted black;
                    }

                    /* Main boxes */
                    ##receipt,
                    ##payment {
                        float: left;
                    }
                    ##receipt {
                        width: 29%;
                        padding: 10pt;
                        border-right: 1px dotted black;
                    }
                    ##payment {
                        width: 71%;
                        padding: 10pt;
                    }

                    /* Receipt part boxes */
                    ##receipt .account {
                        height: 143pt;
                    }
                    ##receipt .money {
                        width: 100%;
                        height: 30pt;
                    }
                    ##receipt .currency {
                        float: left;
                        width: 40%;
                    }
                    ##receipt .amount {
                        width: 55%;
                    }
                    ##receipt .receiving {
                        text-align: right;
                        width: 100%;
                        height: 25pt;
                    }

                    /* Payment part boxes */
                    ##payment .top {
                        height: 143pt;
                    }
                    ##payment .payment_part {
                        width: 100%;
                    }
                    ##payment .left_part {
                        float: left;
                        width: 37%;
                    }
                    ##payment .right_part {
                        float: left;
                        width: 63%;
                    }

                    ##payment .qr_code {
                        width: 105pt;
                        height: 105pt;
                        clip-path: inset(10px);
                        display: block;
                    }

                    ##payment .qr_code img {
                        width: 100%;
                        height: auto;
                        display: block;
                    }

                    ##payment .money {
                        width: 100%;
                    }
                    ##payment .currency {
                        float: left;
                        width: 40%;
                    }
                    ##payment .amount {
                        width: 40%;
                    }

                    /* Font sizes and paddings */
                    ##receipt .title, .subtitle,
                    ##payment .title, .subtitle {
                        font-weight: bold;
                    }
                    ##payment .title, ##receipt .title {
                        font-size: 9pt;
                        padding-bottom: 10pt;
                    }

                    ##payment .title {
                        padding-bottom: 15pt;
                    }

                    ##receipt .subtitle {
                        font-size: 5pt;
                        padding-bottom: 1pt;
                    }
                    ##payment .subtitle {
                        font-size: 6pt;
                        padding-bottom: 1pt;
                    }
                    ##receipt .text {
                        font-size: 7pt;
                        padding-bottom: 8pt;
                    }
                    ##payment .text {
                        font-size: 8pt;
                        padding-bottom: 8pt;
                    }
                </style>
            </head>
            <body>
                <div id='bill'>
                    <div id='receipt'>
                        <div class='account'>
                            <p class='title'>Empfangsschein</p>
                            <p class='subtitle'>Konto / Zahlbar an</p>
                            <p class='text'>
                                " & variables.qrData.billerIBANformatted & "<br />
                                " & variables.qrData.billerName & "<br />
                                " & variables.qrData.billerStreet & "<br />
                                " & variables.qrData.billerZIPCity & "
                            </p>
                            #local.referenceNumberCode#
                            <p class='subtitle'>Zahlbar durch</p>
                            <p class='text'>
                                " & variables.qrData.debtorName & "<br />
                                " & variables.qrData.debtorStreet & "<br />
                                " & variables.qrData.debtorZIPCity & "
                            </p>
                        </div>
                        <div class='money'>
                            <div class='currency'>
                                <p class='subtitle'>Währung</p>
                                <p class='text'>" & variables.qrData.invoiceCurrency & "</p>
                            </div>
                            <div class='amount'>
                                <p class='subtitle'>Betrag</p>
                                <p class='text'>" & variables.qrData.invoiceAmountPDF & "</p>
                            </div>
                        </div>
                        <p class='receiving subtitle'>Annahmestelle</p>
                    </div>
                    <div id='payment'>
                        <div class='payment_part'>
                            <div class='left_part'>
                                <div class='top'>
                                    <p class='title'>Zahlteil</p>
                                    <div class='qr_code'>
                                        <img src='data:image/png;base64," & generateQRCode(500, 0.12).base64String & "'>
                                    </div>
                                </div>
                                <div class='money'>
                                    <div class='currency'>
                                        <p class='subtitle'>Währung</p>
                                        <p class='text'>" & variables.qrData.invoiceCurrency & "</p>
                                    </div>
                                    <div class='amount'>
                                        <p class='subtitle'>Betrag</p>
                                        <p class='text'>" & variables.qrData.invoiceAmountPDF & "</p>
                                    </div>
                                </div>
                            </div>
                            <div class='right_part'>
                                <p class='subtitle'>Konto / Zahlbar an</p>
                                <p class='text'>
                                    " & variables.qrData.billerIBANFormatted & "<br />
                                    " & variables.qrData.billerName & "<br />
                                    " & variables.qrData.billerStreet & "<br />
                                    " & variables.qrData.billerZIPCity & "
                                </p>
                                #local.referenceNumberCode#
                                <p class='subtitle'>Zusätzliche Informationen</p>
                                <p class='text'>" & variables.qrData.invoiceAddText & "</p>
                                <p class='subtitle'>Zahlbar durch</p>
                                <p class='text'>
                                    " & variables.qrData.debtorName & "<br />
                                    " & variables.qrData.debtorStreet & "<br />
                                    " & variables.qrData.debtorZIPCity & "
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </body>
        </html>";

        return local.html;

    }

    public any function createPDF(string pdfType) {

        // Create and open the PDF directly in the browser
        if (arguments.pdfType eq "pdf") {
            cfdocument(format="pdf", unit="pt", pageType="A4", marginLeft="0", marginRight="0", marginTop="540", marginBottom="0", type="classic") {
                writeOutput(buildHTML());
            }
            return;
        }

        // Create the PDF and save it into the memory
        if (arguments.pdfType eq "variable") {
            cfdocument(name="local.qrslip" format="pdf", unit="pt", pageType="A4", marginLeft="0", marginRight="0", marginTop="540", marginBottom="0", type="classic") {
                writeOutput(buildHTML());
            }
            return local.qrslip;
        }


        return "";


    }

    private struct function validateData(required struct qrData) {

        local.qrData = {};
        local.errorMessage = "";

        // Validate IBAN
        if (structKeyExists(arguments.qrData, "billerIBAN") and len(trim(arguments.qrData.billerIBAN))) {
            local.iban = formatIBAN(arguments.qrData.billerIBAN);
        } else {
            local.errorMessage =  "IBAN is not defined or empty!";
        }

        // Validate reference number
        if (structKeyExists(arguments.qrData, "billerQrReference")) {
            local.reference = formatReference(arguments.qrData.billerQrReference);
        } else {
            local.errorMessage = "QR reference is not defined!";
        }

        // Validate biller
        if (structKeyExists(arguments.qrData, "billerName") and len(trim(arguments.qrData.billerName))) {
            local.qrData["billerName"] = left(trim(arguments.qrData.billerName), 70);
        } else {
            local.errorMessage = "Please provide the account holder!";
        }
        if (structKeyExists(arguments.qrData, "billerStreetAndNumber") and len(trim(arguments.qrData.billerStreetAndNumber))) {
            local.qrData["billerStreet"] = left(trim(arguments.qrData.billerStreetAndNumber), 70);
        } else {
            local.errorMessage = "Biller street and number is not defined or empty!";
        }
        if (structKeyExists(arguments.qrData, "billerZipAndCity") and len(trim(arguments.qrData.billerZipAndCity))) {
            local.qrData["billerZIPCity"] = left(trim(arguments.qrData.billerZipAndCity), 70);
        } else {
            local.errorMessage = "Biller ZIP and/or city is not defined or empty!";
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
        if (structKeyExists(arguments.qrData, "debtorStreetAndNumber") and len(trim(arguments.qrData.debtorStreetAndNumber))) {
            local.qrData["debtorStreet"] = left(trim(arguments.qrData.debtorStreetAndNumber), 70);
        } else {
            local.errorMessage = "Debtor street and number is not defined or empty!";
        }
        if (structKeyExists(arguments.qrData, "debtorZipAndCity") and len(trim(arguments.qrData.debtorZipAndCity))) {
            local.qrData["debtorZIPCity"] = left(trim(arguments.qrData.debtorZipAndCity), 70);
        } else {
            local.errorMessage = "Debtor ZIP and/or city is not defined or empty!";
        }
        if (structKeyExists(arguments.qrData, "debtorCountryIso") and len(trim(arguments.qrData.debtorCountryIso))) {
            local.qrData["debtorCountry"] = left(trim(arguments.qrData.debtorCountryIso), 2)
        } else {
            local.errorMessage = "Debtor country iso is not defined or empty!";
        }

        // Validate amount and currency
        if (structKeyExists(arguments.qrData, "invoiceAmount") and isNumeric(arguments.qrData.invoiceAmount)) {
            local.qrData["invoiceAmountQRCode"] = formatAmount(arguments.qrData.invoiceAmount, "qrcode");
            local.qrData["invoiceAmountPDF"] = formatAmount(arguments.qrData.invoiceAmount, "pdf");
        } else {
            local.errorMessage = "Amount is not defined or not of type numeric!";
        }
        if (structKeyExists(arguments.qrData, "invoiceCurrency") and len(trim(arguments.qrData.invoiceCurrency))) {
            local.qrData["invoiceCurrency"] = left(arguments.qrData.invoiceCurrency, 3).toUpperCase();
        } else {
            local.errorMessage = "Currency is not defined or empty!";
        }

        // Return error message if needed
        if (len(local.errorMessage)) {
            variables.returnStruct['success'] = false;
            variables.returnStruct['message'] = local.errorMessage;
            return variables.returnStruct;
        }

        // Set transaction type
        local.qrData["transactionType"] = determineTransactionType(local.reference.billerReferenceClean);

        // Additional text
        local.qrData["invoiceAddText"] = structKeyExists(arguments.qrData, "invoiceAddText") ? left(trim(arguments.qrData.invoiceAddText), 140) : "";

        // Parse the size for the qr code
        local.qrData["qrSize"] = structKeyExists(arguments.qrData, "qrSize") and isNumeric(arguments.qrData.qrSize) ? arguments.qrData.qrSize : 200;

        // Path to the swiss cross logo
        local.qrData["qrLogo"] = structKeyExists(arguments.qrData, "qrLogo") and len(trim(arguments.qrData.qrLogo)) ? arguments.qrData.qrLogo : "";

        // Add message
        structAppend(local.qrData, variables.returnStruct);

        return local.qrData;

    }

    public struct function formatIBAN(required string iban) {

        local.cleanIBAN = replace(arguments.iban, " ", "", "all");
        local.formattedIBAN = "";

        // Length must be 21 characters
        if (len(local.cleanIBAN) neq 21) {
            variables.returnStruct['success'] = false;
            variables.returnStruct['message'] = "The character length of a Swiss IBAN must be 21!";
            return variables.returnStruct;
        }

        // Loop through every fourth index and insert spaces
        for (local.i = 1; local.i <= len(local.cleanIBAN); local.i += 4) {
            local.formattedIBAN &= mid(local.cleanIBAN, local.i, 4) & " ";
        }

        variables.returnStruct['billerIBANClean'] = local.cleanIBAN;
        variables.returnStruct['billerIBANFormatted'] = local.formattedIBAN;
        return variables.returnStruct;

    }

    private struct function formatReference(required string reference) {

        local.cleanReference = replace(arguments.reference, " ", "", "all");

        // Check for Creditor Reference (SCOR)
        if (left(local.cleanReference, 2) eq "RF") {

            local.formattedReference = "";

            // Format the SCOR reference
            for (local.pos = 1; local.pos <= len(local.cleanReference); local.pos += 4) {
                local.formattedReference &= mid(local.cleanReference, local.pos, 4) & " ";
            }

            variables.returnStruct['billerReferenceClean'] = local.cleanReference;
            variables.returnStruct['billerReferenceFormatted'] = local.formattedReference;

        // Check for QRR reference
        } else if (isNumeric(local.cleanReference)) {

            local.refLength = len(local.cleanReference);

            // Fill QR reference to 26 numbers with 0
            if (local.refLength lte 26) {

                // Calculate how many zeros need to be added
                local.zerosNeeded = 26 - local.refLength;

                // Add the required zeros if len is less than 26
                if (local.zerosNeeded gt 0) {
                    local.addZero = "";
                    for (local.i = 1; local.i <= local.zerosNeeded; local.i++) {
                        local.addZero &= "0";
                    }
                    local.cleanReference = local.addZero & local.cleanReference;
                }

                // Calculate checksum
                local.checksum = calculateChecksum(local.cleanReference);

                // Add checksum to the reference number
                local.fullReference = local.cleanReference & local.checksum;

                variables.returnStruct['billerReferenceClean'] = local.fullReference;
                variables.returnStruct['billerReferenceFormatted'] = formatReferenceNumber(local.fullReference);

            } else {

                // Reference number with checksum already set
                variables.returnStruct['billerReferenceClean'] = local.cleanReference;
                variables.returnStruct['billerReferenceFormatted'] = formatReferenceNumber(local.cleanReference);

            }

        } else {

            // Return of the unchanged reference if it does not correspond to any format
            variables.returnStruct['billerReferenceClean'] = local.cleanReference;
            variables.returnStruct['billerReferenceFormatted'] = local.cleanReference;

        }

        return variables.returnStruct;

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

    private string function calculateChecksum(required string number) {

        local.refNumber = arguments.number;

        // Determine the length of the reference number
        local.refLength = len(local.refNumber);

        // Check if the length of the reference number is less than 16
        if (local.refLength lt 16) {

            // If the reference number is less than 16 characters long,
            // add leading zeros to make it exactly 15 characters long
            local.refNumber = right("000000000000000" & local.refNumber, 15);

        } else {

            // If the reference number is 16 or more characters long,
            // add leading zeros to make it exactly 26 characters long
            local.refNumber = right("00000000000000000000000000" & local.refNumber, 26);

        }

        // Initialize the mapping for the checksum calculation algorithm
        local.alg = [0,9,4,6,8,2,7,1,3,5];

        // Update the length of the reference number after normalization
        local.refLength = len(local.refNumber);

        // Convert the reference number into an array,
        // where each element of the array corresponds to a digit of the reference number
        local.ro = listToArray(local.refNumber, "");

        // Initialize the variable ref, which is used in the checksum calculation
        local.ref = 0;

        // Iterate through each digit of the reference number to calculate the checksum
        loop from=1 to=local.refLength index="local.i" {

            // Add the current value of ref and the current digit of the reference number
            local.rpr = local.ref + local.ro[local.i];

            // Update ref based on the algorithm
            // The index in the alg array is calculated based on the remainder of the division
            // of rpr by 10 and increased by 1, as ColdFusion arrays start at 1
            local.ref = local.alg[(local.rpr % 10) + 1];

        }

        // Calculate the final check digit
        // This is the remainder of the division of the final ref by 10, subtracted from 10
        local.checksum = (10 - local.ref % 10);

        // Return the calculated check digit
        return local.checksum;



    }

    private string function formatAmount(required numeric amount, string output="qrcode") {

        // Prepare for qr code
        if (arguments.output eq "qrcode") {
            local.formattedAmount = numberFormat(arguments.amount, "___.__");

        // Prepare for PDF
        } else {
            local.amount = numberFormat(arguments.amount, "_,___.__");
            local.formattedAmount = replace(local.amount, ",", " ", "all");
        }

        return local.formattedAmount;

    }

    private string function determineTransactionType(required string reference) {

        // Determine the transaction type
        if (len(arguments.reference) eq 27) {
            return 'QRR';
        } else if (left(arguments.reference, 2) eq "RF") {
            return 'SCOR';
        }

        return 'NON';

    }

    private string function generateQrDataString() {

        // Generate the data string for the QR code
        local.dataString = "";
        local.dataString = "SPC" & chr(13) & chr(10) & "0200" & chr(13) & chr(10) & "1" & chr(13) & chr(10);
        local.dataString &= variables.qrData.billerIBANclean & chr(13) & chr(10);
        local.dataString &= "K" & chr(13) & chr(10);
        local.dataString &= variables.qrData.billerName & chr(13) & chr(10);
        local.dataString &= variables.qrData.billerStreet & chr(13) & chr(10);
        local.dataString &= variables.qrData.billerZIPCity & chr(13) & chr(10) & chr(13) & chr(10) & chr(13) & chr(10);
        local.dataString &= variables.qrData.billerCountry & chr(13) & chr(10);
        local.dataString &= chr(13) & chr(10) & chr(13) & chr(10) & chr(13) & chr(10) & chr(13) & chr(10) & chr(13) & chr(10) & chr(13) & chr(10) & chr(13) & chr(10); // 7 spaces
        local.dataString &= variables.qrData.invoiceAmountQRCode & chr(13) & chr(10);
        local.dataString &= variables.qrData.invoiceCurrency & chr(13) & chr(10);
        local.dataString &= "K" & chr(13) & chr(10);
        local.dataString &= variables.qrData.debtorName & chr(13) & chr(10);
        local.dataString &= variables.qrData.debtorStreet & chr(13) & chr(10);
        local.dataString &= variables.qrData.debtorZIPCity & chr(13) & chr(10) & chr(13) & chr(10) & chr(13) & chr(10);
        local.dataString &= variables.qrData.debtorCountry & chr(13) & chr(10);
        local.dataString &= variables.qrData.transactionType & chr(13) & chr(10);
        local.dataString &= variables.qrData.billerReferenceClean & chr(13) & chr(10);
        local.dataString &= variables.qrData.invoiceAddText & chr(13) & chr(10);
        local.dataString &= "EPD";

        return local.dataString;

    }


}