
<cfscript>

// This file is called up by Payrexx as soon as a payment (preAuthorization) has been made.
// The webhook contains a JSON with information about the customer's payment.

// For local purpose: We get the JSON file via cfhttp
if (application.environment eq "dev") {

    cfhttp( url=variables.payrexxWebhookDev, result="httpRes", method="GET" ) {}

    if (isJSON(httpRes.filecontent)) {
        jsonData = deSerializeJSON(httpRes.filecontent);
    } else {
        logWrite("payrexx", "warning", "DEV: No content found or JSON failure!");
        abort;
    }


// Called by Payrexx (Webhook)
} else {

    // Only execute if the url variable was passed in
    if (structKeyExists(url, "pass") and url.pass eq variables.payrexxWebhookPassword) {

        if (!structKeyExists(getHttpRequestData(), "content")) {
            logWrite("payrexx", "warning", "No content found or JSON failure!");
            abort;
        }

    } else {
        logWrite("payrexx", "warning", "Webhook password was not passed in or wrong password!");
        abort;
    }

    jsonData = getHttpRequestData().content;
    jsonData = deSerializeJSON(jsonData);

}


if (structKeyExists(jsonData, "transaction")) {

    webhookData = jsonData.transaction;

    // Security: Only defined psp's in config.cfm can send data
    if (structKeyExists(webhookData, "pspId") and listFind(variables.payrexxPSPs, webhookData.pspId)) {

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
        if (structKeyExists(webhookData, "payrexxFee") and isNumeric(webhookData.pspId) and webhookData.pspId gt 0) {
            payrexxFee = numberFormat(webhookData.payrexxFee/100, "__.__");
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
        if (projectName eq variables.applicationname) {

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

                    "
                )

                logWrite("payrexx", "info", "Webhook data successfully saved [CustomerID: #customerID#, TransactionID: #internTransID#, Payment: #paymentAmount#]");


            } catch (any e) {

                logWrite("payrexx", "error", "Could not insert the webhook data into the payrexx table. [CustomerID: #customerID#, TransactionID: #internTransID#, Payment: #paymentAmount#, Error: #e.message#]", true);

            }

        } else {

            logWrite("payrexx", "warning", "Webhook could not be inserted because the application name does not match the project name. [CustomerID: #customerID#, TransactionID: #internTransID#, Payment: #paymentAmount#, projectName: #projectName#, applicationName: #variables.applicationname#]");

        }

    } else {

        logWrite("payrexx", "warning", "The PSP IDs from the configuration (config.cfm) do not match the webhook.");

    }

}


</cfscript>

