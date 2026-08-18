
<cfscript>

// This file is called up by Payrexx as soon as a payment (preAuthorization) has been made.
// The webhook contains a JSON with information about the customer's payment.

// A trusted internal caller can provide a transaction retrieved directly from
// the authenticated Payrexx Gateway API. This also covers delayed webhooks.
if (structKeyExists(request, "payrexxWebhookPayload") and isStruct(request.payrexxWebhookPayload)) {

    jsonData = request.payrexxWebhookPayload;

// For local purpose: We get the JSON file via cfhttp
} else if (application.environment eq "dev") {

    cfhttp( url=variables.payrexxWebhookDev, result="httpRes", method="GET" ) {}
    if (isJSON(httpRes.filecontent)) {
        jsonData = deSerializeJSON(httpRes.filecontent);
    } else {
        request.payrexxWebhookError = "The development webhook source did not return valid JSON.";
        logWrite("payrexx", "warning", "DEV: No content found or JSON failure!");
        abort;
    }


// Called by Payrexx (Webhook)
} else {

    requestData = getHttpRequestData();

    // Validate the secret embedded in the configured webhook URL.
    if (structKeyExists(url, "pass") and url.pass eq variables.payrexxWebhookPassword) {

        if (!structKeyExists(requestData, "content")) {
            request.payrexxWebhookError = "The Payrexx webhook request did not contain a body.";
            logWrite("payrexx", "warning", "No content found or JSON failure!");
            abort;
        }

    } else {
        request.payrexxWebhookError = "The Payrexx webhook URL password is missing or invalid.";
        logWrite("payrexx", "warning", "Webhook password was not passed in or wrong password!");
        abort;
    }

    jsonData = requestData.content;
    if (!isJSON(jsonData)) {
        request.payrexxWebhookError = "The Payrexx webhook body is not valid JSON.";
        logWrite("payrexx", "warning", "jsonData is not of type JSON!");
        abort;
    }

    jsonData = deSerializeJSON(jsonData);

}


if (isStruct(jsonData) and structKeyExists(jsonData, "transaction")) {

    webhookData = jsonData.transaction;

    // The configured PSP list controls the methods offered by the Gateway.
    // Payrexx may process the payment through another internal PSP ID, so a
    // mismatch is diagnostic information and must not discard a valid webhook.
    if (structKeyExists(webhookData, "pspId") and isNumeric(webhookData.pspId) and webhookData.pspId gt 0) {

        if (len(trim(variables.payrexxPSPs)) and !listFind(variables.payrexxPSPs, webhookData.pspId)) {
            logWrite(
                "payrexx",
                "warning",
                "Webhook uses a PSP ID that differs from the configured Gateway PSP list; processing continues. [Received PSP ID: #webhookData.pspId#, Configured PSP IDs: #variables.payrexxPSPs#]"
            );
        }

        customerID = 0;
        projectName = "";
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
        cardNumber = "";

        if (structKeyExists(webhookData, "referenceId")) {
            customerID = listFirst(webhookData.referenceId, "@");
            projectName = listLast(webhookData.referenceId, "@");
        }

        if (isNumeric(customerID) and customerID gt 0) {

            if (structKeyExists(webhookData, "id")) {
                internTransID = webhookData.id;
            }
            if (structKeyExists(webhookData, "invoice")) {
                invoiceData = webhookData.invoice;
                if (structKeyExists(invoiceData, "paymentRequestId") and isNumeric(invoiceData.paymentRequestId)) {
                    gatewayID = invoiceData.paymentRequestId;
                } else if (structKeyExists(invoiceData, "paymentLinkId") and isNumeric(invoiceData.paymentLinkId)) {
                    gatewayID = invoiceData.paymentLinkId;
                }
            }
            if (structKeyExists(webhookData, "amount") and isNumeric(webhookData.amount) and webhookData.amount gt 0) {
                paymentAmount = numberFormat(webhookData.amount/100, "_.__");
            }
            if (structKeyExists(webhookData, "time") and isDate(webhookData.time)) {
                objTime = new backend.core.com.time();
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
            if (structKeyExists(webhookData, "payrexxFee") and isNumeric(webhookData.payrexxFee) and webhookData.payrexxFee gte 0) {
                payrexxFee = numberFormat(webhookData.payrexxFee/100, "_.__");
            } else if (structKeyExists(webhookData, "payrexx_fee") and isNumeric(webhookData.payrexx_fee) and webhookData.payrexx_fee gte 0) {
                payrexxFee = numberFormat(webhookData.payrexx_fee/100, "_.__");
            }
            if (structKeyExists(webhookData, "payment")) {
                if (structKeyExists(webhookData.payment, "brand")) {
                    paymentBrand = webhookData.payment.brand;
                    paymentBrand = left(uCase(paymentBrand), 1) & right(paymentBrand, len(paymentBrand) -1);
                }
                if (structKeyExists(webhookData.payment, "cardNumber")) {
                    cardNumber = webhookData.payment.cardNumber;
                }
            }

            // Is there already a default payment method?
            getWebhook = new backend.core.com.payrexx().getWebhook(customerID, 'authorized', 1);
            if (getWebhook.recordCount) {
                default = 0;
            } else {
                default = 1;
            }

            // Insert only if it's the correct webhook
            if (projectName eq variables.applicationname and isNumeric(internTransID) and internTransID gt 0) {

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
                            paymentBrand: {type: "nvarchar", value: paymentBrand},
                            cardNumber: {type: "varchar", value: cardNumber},
                            default: {type: "boolean", value: default}
                        },
                        sql = "
                            INSERT INTO payrexx
                            (
                                intCustomerID,
                                dtmTimeUTC,
                                intGatewayID,
                                intTransactionID,
                                strStatus,
                                strLanguage,
                                strPSP,
                                intPSPID,
                                decAmount,
                                decPayrexxFee,
                                strPaymentBrand,
                                strCardNumber,
                                blnDefault
                            )
                            VALUES (
                                :customerID,
                                :dateTime,
                                :gatewayID,
                                :transID,
                                :status,
                                :language,
                                :serviceProvider,
                                :serviceProviderID,
                                :paymentAmount,
                                :payrexxFee,
                                :paymentBrand,
                                :cardNumber,
                                :default
                            )
                            ON DUPLICATE KEY UPDATE
                                dtmTimeUTC = VALUES(dtmTimeUTC),
                                intGatewayID = VALUES(intGatewayID),
                                strStatus = VALUES(strStatus),
                                strLanguage = VALUES(strLanguage),
                                strPSP = VALUES(strPSP),
                                intPSPID = VALUES(intPSPID),
                                decAmount = VALUES(decAmount),
                                decPayrexxFee = VALUES(decPayrexxFee),
                                strPaymentBrand = VALUES(strPaymentBrand),
                                strCardNumber = VALUES(strCardNumber)

                        "
                    )

                    logWrite("payrexx", "info", "Webhook data successfully saved [CustomerID: #customerID#, TransactionID: #internTransID#, Payment: #paymentAmount#]");


                } catch (any e) {

                    request.payrexxWebhookError = "The Payrexx webhook could not be stored: " & e.message;
                    logWrite("payrexx", "error", "Could not insert the webhook data into the payrexx table. [CustomerID: #customerID#, TransactionID: #internTransID#, Payment: #paymentAmount#, Error: #e.message#]", true);

                }

            } else if (projectName neq variables.applicationname) {

                request.payrexxWebhookError = "The webhook application name does not match this application.";
                logWrite("payrexx", "warning", "Webhook could not be inserted because the application name does not match the project name. [CustomerID: #customerID#, TransactionID: #internTransID#, Payment: #paymentAmount#, projectName: #projectName#, applicationName: #variables.applicationname#]");

            } else {

                request.payrexxWebhookError = "The webhook transaction ID is missing or invalid.";
                logWrite("payrexx", "warning", "Webhook could not be inserted because the transaction ID is missing or invalid. [CustomerID: #customerID#, TransactionID: #internTransID#]");

            }

        } else {

            receivedReferenceID = structKeyExists(webhookData, "referenceId") ? webhookData.referenceId : "missing";
            request.payrexxWebhookError = "The webhook reference ID (#receivedReferenceID#) does not contain a valid customer ID.";
            logWrite("payrexx", "warning", "Webhook reference ID does not contain a valid customer ID. [Reference ID: #receivedReferenceID#]");

        }



    } else {

        receivedPSPID = structKeyExists(webhookData, "pspId") ? webhookData.pspId : "missing";
        request.payrexxWebhookError = "The webhook PSP ID (#receivedPSPID#) is missing or invalid.";
        logWrite("payrexx", "warning", "The webhook PSP ID is missing or invalid. [Received PSP ID: #receivedPSPID#]");

    }

} else {

    request.payrexxWebhookError = "The webhook JSON does not contain a transaction object.";
    logWrite("payrexx", "warning", "Webhook JSON does not contain a transaction object.");

}


</cfscript>
