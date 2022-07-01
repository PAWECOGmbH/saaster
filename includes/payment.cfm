
<cfscript>

    // Here we process the payment via Payrexx

    // Let's make an entry in the payrexx control table
    newUUID = replace(lcase(createUUID()), "-", "", "all");
    queryExecute(
        options = {datasource = application.datasource},
        params = {
            uuID: {type: "varchar", value: newUUID},
            customerID: {type: "numeric", value: session.customer_id},
            dateTime: {type: "datetime", value: now()}
        },
        sql = "
            INSERT INTO payrexx (strUUID, intCustomerID, dtmTimeUTC)
            VALUES (:uuID, :customerID, :dateTime)
        "
    )


    objPayrexx = new com.payrexx();
    paymentStruct = structNew();

    if (structKeyExists(url, "module")) {
        recurring = moduleStruct.recurring;
        thisStruct = moduleDetails;
        redirectString = "#application.mainURL#/book?module=#url.module#&psp_response=";
        failLink = "#application.mainURL#/account-settings/modules";
        paymentStruct['purpose'] = thisStruct.name;
    } else {
        recurring = planStruct.recurring;
        thisStruct = planDetails;
        redirectString = "#application.mainURL#/book?plan=#url.plan#&psp_response=";
        failLink = "#application.mainURL#/plans";
        paymentStruct['purpose'] = thisStruct.planName;
    }
    if (structKeyExists(thisStruct, "priceOneTimeAfterVAT") and thisStruct.priceOneTimeAfterVAT gt 0) {
        thisAmount = thisStruct.priceOneTimeAfterVAT * 100;
        paymentStruct['amount'] = numberFormat(thisAmount, "__.__");
        paymentStruct['preAuthorization'] = false;
    } else {
        if (recurring eq "y") {
            thisAmount = thisStruct.priceYearlyAfterVAT * 100;
            paymentStruct['amount'] = numberFormat(thisAmount, "__.__");
            paymentStruct['preAuthorization'] = true;
            paymentStruct['chargeOnAuthorization'] = true;
        } else {
            thisAmount = thisStruct.priceMonthlyAfterVAT * 100;
            paymentStruct['amount'] = numberFormat(thisAmount, "__.__");
            paymentStruct['preAuthorization'] = true;
            paymentStruct['chargeOnAuthorization'] = true;
        }
    }

    paymentStruct['skipResultPage'] = true;
    paymentStruct['referenceId'] = session.customer_id;
    paymentStruct['currency'] = thisStruct.currency;
    paymentStruct['successRedirectUrl'] = redirectString & "success" & "&uuid=" & newUUID;
    paymentStruct['failedRedirectUrl'] = redirectString & "failed" & "&uuid=" & newUUID;
    paymentStruct['cancelRedirectUrl'] = redirectString & "cancel" & "&uuid=" & newUUID;
    paymentStruct['lookAndFeelProfile'] = variables.payrexxDesignID; // config.cfm


    // Call Payrexx and create a gateway
    payrexxRespond = objPayrexx.callPayrexx(paymentStruct, "POST", "Gateway");

    if (isStruct(payrexxRespond) and payrexxRespond.status eq "success") {

        gatewayData = payrexxRespond.data[1];

        try {

            queryExecute(

                options = {datasource = application.datasource},
                params = {
                    uuID: {type: "varchar", value: newUUID},
                    gatewayID: {type: "numeric", value: gatewayData.id},
                    preAuthorization: {type: "boolean", value: gatewayData.preAuthorization},
                    status: {type: "varchar", value: gatewayData.status},
                    customerID: {type: "numeric", value: session.customer_id}
                },
                sql = "
                    UPDATE payrexx
                    SET intGatewayID = :gatewayID,
                        blnPreAuthorization = :preAuthorization,
                        strStatus = :status
                    WHERE strUUID = :uuID
                    AND intCustomerID = :customerID
                "
            )

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
            location url=failLink addtoken="false";

        }


    } else {

        getAlert(payrexxRespond.message, 'danger');
        location url=failLink addtoken="false";

    }



</cfscript>
