
<cfscript>

// This file is called up by Payrexx as soon as a payment has been made.
// The webhook contains a JSON with information about the customer's payment.
// The script saves the information from the JSON into the database.

if (application.environment eq "dev") {

    // For locale purpose: We get the JSON file via cfhttp
    cfhttp( url=variables.payrexxWebhookDev, result="httpRes", method="GET" ) {}

    if (isJSON(httpRes.filecontent)) {
        jsonData = deSerializeJSON(httpRes.filecontent);
    } else {
        throw('No JSON file found!');
    }

} else {

    if (!isDefined(form)) {
        abort;
    }

    jsonData = getHttpRequestData(form).content;
    jsonData = deSerializeJSON(jsonData);

}

if (structKeyExists(jsonData, "transaction")) {

    webhookData = jsonData.transaction;

    customerID = 0;
    internTransID = 0;
    gatewayID = 0;
    paymentAmount = 0;
    dateTime = now();
    status = "";
    language = "";
    serviceProvider = "";
    serviceProviderID = 0;
    payrexxFee = 0;
    paymentBrand = "";

    if (structKeyExists(webhookData, "referenceId") and isNumeric(webhookData.referenceId) and webhookData.referenceId gt 0) {
        customerID = webhookData.referenceId;
    }
    if (structKeyExists(webhookData, "id")) {
        internTransID = webhookData.id;
    }
    if (structKeyExists(webhookData, "invoice")) {
        invoiceData = webhookData.invoice;
        if (structKeyExists(invoiceData, "paymentRequestId") and isNumeric(invoiceData.paymentRequestId)) {
            gatewayID = invoiceData.paymentRequestId;
        }
    }
    if (structKeyExists(webhookData, "amount") and isNumeric(webhookData.amount) and webhookData.amount gt 0) {
        paymentAmount = numberFormat(webhookData.amount/100, "__.__");
    }
    if (structKeyExists(webhookData, "time") and isDate(webhookData.time)) {
        objTime = new com.time();
        dateTime = objTime.local2utc(webhookData.time, "Europe/Zurich");
    }
    if (structKeyExists(webhookData, "status")) {
        status = webhookData.status;
    }
    if (structKeyExists(webhookData, "lang")) {
        language = webhookData.lang;
    }
    if (structKeyExists(webhookData, "psp")) {
        serviceProvider = webhookData.psp;
    }
    if (structKeyExists(webhookData, "pspId") and isNumeric(webhookData.pspId) and webhookData.pspId gt 0) {
        serviceProviderID = webhookData.pspId;
    }
    if (structKeyExists(webhookData, "payrexxFee") and isNumeric(webhookData.pspId) and webhookData.pspId gt 0) {
        payrexxFee = numberFormat(webhookData.payrexxFee/100, "__.__");
    }
    if (structKeyExists(webhookData, "payment")) {
        if (structKeyExists(webhookData.payment, "brand")) {
            paymentBrand = webhookData.payment.brand;
            paymentBrand = left(uCase(paymentBrand), 1) & right(paymentBrand, len(paymentBrand) -1);
        }
    }


    try {

        queryExecute(

            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: customerID},
                transID: {type: "numeric", value: internTransID},
                gatewayID: {type: "numeric", value: gatewayID},
                paymentAmount: {type: "decimal", value: paymentAmount, scale: 2},
                dateTime: {type: "datetime", value: dateTime},
                status: {type: "varchar", value: status},
                language: {type: "varchar", value: language},
                serviceProvider: {type: "varchar", value: serviceProvider},
                serviceProviderID: {type: "numeric", value: serviceProviderID},
                payrexxFee: {type: "decimal", value: payrexxFee, scale: 2},
                paymentBrand: {type: "nvarchar", value: paymentBrand}
            },
            sql = "
                UPDATE payrexx
                SET intTransactionID = :transID,
                    dtmTimeUTC = :dateTime,
                    strStatus = :status,
                    strLanguage = :language,
                    strPSP = :serviceProvider,
                    intPSPID = :serviceProviderID,
                    decAmount = :paymentAmount,
                    decPayrexxFee = :payrexxFee,
                    strPaymentBrand = :paymentBrand
                WHERE intCustomerID = :customerID
                AND intGatewayID = :gatewayID
            "

        )

        writeOutput("OK");


    } catch (any e) {

        // todo: send error mail

        writeDump(e);

    }



}


</cfscript>

