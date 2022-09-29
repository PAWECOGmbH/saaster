
<cfscript>

// Delete payment method
if (structKeyExists(url, "del")) {

    if (isNumeric(url.del) and url.del gt 0) {

        objPayrexx = new com.payrexx();

        // Get the entries
        getWebhook = objPayrexx.getWebhook(session.customer_id, 'authorized');

        if (getWebhook.recordCount) {

            // Delete reserved transaction on Payrexx
            payload = structNew();
            deleteTransaction = objPayrexx.callPayrexx(payload, 'DEL', 'Transaction', getWebhook.intTransactionID);

            // Delete the entry in the table payrexx
            queryExecute(
                options: {datasource = application.datasource},
                params: {
                    customerID: {type: "numeric", value: session.customer_id},
                    id: {type: "numeric", value: url.del}
                },
                sql = "
                    DELETE FROM payrexx
                    WHERE intCustomerID = :customerID
                    AND intPayrexxID = :id
                "
            )

            // Check for default entry
            local.qCheckDefault = queryExecute(
                options: {datasource = application.datasource},
                params: {
                    customerID: {type: "numeric", value: session.customer_id}
                },
                sql = "
                    SELECT *
                    FROM payrexx
                    WHERE intCustomerID = :customerID
                    AND blnDefault = 1
                "
            )

            // If there is no other default entry, make one
            if (!local.qCheckDefault.recordCount) {
                queryExecute(
                    options: {datasource = application.datasource},
                    params: {
                        customerID: {type: "numeric", value: session.customer_id},
                        id: {type: "numeric", value: url.del}
                    },
                    sql = "
                       UPDATE payrexx
                       SET blnDefault = 1
                       WHERE intCustomerID = :customerID
                       LIMIT 1
                    "
                )
            }


            getAlert('msgPaymentMethodDeleted', 'success');

            location url="#application.mainURL#/account-settings/payment" addtoken="false";

        } else {

            getAlert('msgNeedOnePaymentType', 'info');
            location url="#application.mainURL#/account-settings/payment" addtoken="false";

        }

    }

}


// Add payment method
if (structKeyExists(url, "add")) {

    if (isNumeric(url.add) and url.add eq session.customer_id) {

        objPayrexx = new com.payrexx();
        objPrices = new com.prices();
        objCurrency = new com.currency();

        // Returning from Payrexx
        if (structKeyExists(url, "psp")) {

            // If success, we try to get the webhook data
            if (url.psp eq "success") {

                // If we are in dev mode, call the JSON data from the given server
                if (application.environment eq "dev") {
                    include template="/frontend/payrexx_webhook.cfm";
                }

                // Get the webhook data
                getWebhook = objPayrexx.getWebhook(session.customer_id, 'authorized');

                // If there is no data from the webhook, send the customer back and try again
                if (getWebhook.recordCount) {
                    getAlert('msgPaymentMethodAdded', 'success');
                } else {
                    getAlert('alertErrorOccured', 'warning');
                }

            } else {
                getAlert('alertErrorOccured', 'warning');
            }

            location url="#application.mainURL#/account-settings/payment" addtoken=false;

        } else {

            paymentStruct = structNew();
            paymentStruct['skipResultPage'] = true;
            paymentStruct['referenceId'] = session.customer_id;
            paymentStruct['currency'] = objCurrency.getCurrency().iso;
            paymentStruct['successRedirectUrl'] = "#application.mainURL#/payment-settings?add=#session.customer_id#&psp=success";
            paymentStruct['failedRedirectUrl'] = "#application.mainURL#/payment-settings?add=#session.customer_id#&psp=failed";
            paymentStruct['cancelRedirectUrl'] = "#application.mainURL#/account-settings/payment";
            paymentStruct['lookAndFeelProfile'] = variables.payrexxDesignID; // config.cfm
            paymentStruct['purpose'] = "Validation test";
            paymentStruct['amount'] = 100;
            paymentStruct['preAuthorization'] = true;


            // Call Payrexx and create a gateway
            payrexxRespond = objPayrexx.callPayrexx(paymentStruct, "POST", "Gateway");

            if (isStruct(payrexxRespond) and payrexxRespond.status eq "success") {

                gatewayData = payrexxRespond.data[1];

                try {

                    // Redirect to the payment terminal with the choosen language
                    if (len(trim(variables.payrexxAPIinstance))) {
                        payrexxURL = "https://" & variables.payrexxAPIinstance & ".payrexx.com/" & session.lng & "/?payment=" & gatewayData.hash;
                    } else {
                        payrexxURL = gatewayData.link;
                    }

                    location url=payrexxURL addtoken="false";


                } catch (any e) {

                    // todo: send error mail

                    getAlert(e.message);
                    location url="#application.mainURL#/account-settings/payment" addtoken="false";

                }


            } else {

                getAlert(payrexxRespond.message, 'danger');
                location url="#application.mainURL#/account-settings/payment" addtoken="false";

            }

        }

    }

}


// Update default payment method
if (structKeyExists(url, "default")) {

    if (isNumeric(url.default) and url.default gt 0) {

        queryExecute(
            options: {datasource = application.datasource},
            params: {
                customerID: {type: "numeric", value: session.customer_id},
                id: {type: "numeric", value: url.default}
            },
            sql = "

                UPDATE payrexx
                SET blnDefault = 0
                WHERE intCustomerID = :customerID;

                UPDATE payrexx
                SET blnDefault = 1
                WHERE intCustomerID = :customerID
                AND intPayrexxID = :id

            "
        )

        location url="#application.mainURL#/account-settings/payment" addtoken="false";

    }

}


// Pay open invoice
if (structKeyExists(url, "pay")) {

    if (isNumeric(url.pay) and url.pay gt 0) {

        if (structKeyExists(url, "other")) {

            // Coming from PSP
            if (structKeyExists(url, "psp_response")) {

                // If we are in dev mode, call the JSON data from the given server
                if (application.environment eq "dev") {
                    include template="/frontend/payrexx_webhook.cfm";
                }

                // Get the webhook data
                objPayrexx = new com.payrexx();
                getWebhook = objPayrexx.getWebhook(session.customer_id, 'confirmed');

                // If there is no data from the webhook, send the customer back and try again
                if (getWebhook.recordCount) {

                    // Insert payment
                    payment = structNew();
                    payment['invoiceID'] = url.pay;
                    payment['customerID'] = session.customer_id;
                    payment['date'] = now();
                    payment['amount'] = getWebhook.decAmount;
                    payment['payrexxID'] = getWebhook.intPayrexxID;
                    payment['type'] = getWebhook.strPaymentBrand;

                    objInvoice = new com.invoices();
                    insPayment = objInvoice.insertPayment(payment);
                    anyLanguage = application.objLanguage.getAnyLanguage(session.lng).iso;

                    <!--- Set plans and modules as well as the custom settings into a session --->
                    application.objCustomer.setProductSessions(session.customer_id, anyLanguage);

                    getAlert('msgInvoicePaid', 'success');

                } else {

                    getAlert('alertErrorOccured', 'warning');

                }

            } else {

                // Get the invoice number
                objInvoices = new com.invoices();
                incoiceData = objInvoices.getInvoiceData(url.pay);

                successLink = "#application.mainURL#/payment-settings?pay=#url.pay#&other&psp_response=success";
                cancelLink = "#application.mainURL#/account-settings/invoice/#url.pay#?psp_response=failed";
                failLink = "#application.mainURL#/account-settings/invoice/#url.pay#?psp_response=failed";
                purpose = getTrans('titInvoiceNumber') & " " & incoiceData.number;
                amountToPay = incoiceData.amountOpen;
                currency = incoiceData.currency;

                include template="/includes/payment.cfm";

            }

        } else {

            // Get webhook data
            objPayrexx = new com.payrexx();
            getWebhook = objPayrexx.getWebhook(session.customer_id, 'authorized');
            anyLanguage = application.objLanguage.getAnyLanguage(session.lng).iso;

            if (!getWebhook.recordCount) {
                location url="#application.mainURL#/account-settings/payment" addtoken="false";
            }

            // Charge the amount now (Payrexx)
            chargeNow = new com.invoices().payInvoice(url.pay);
            if (chargeNow.success) {

                <!--- Set plans and modules as well as the custom settings into a session --->
                application.objCustomer.setProductSessions(session.customer_id, anyLanguage);

                getAlert('msgInvoicePaid');


            } else {

                getAlert('txtChargingNotPossible', 'warning');

            }

        }

        location url="#application.mainURL#/account-settings/invoice/#url.pay#" addtoken="false";

    }

}



location url="#application.mainURL#/dashboard" addtoken="false";

</cfscript>