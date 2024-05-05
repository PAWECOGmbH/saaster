
<cfscript>

    // Here we process the payment via Payrexx
    // It's used for onetime paid modules or for invoices
    // Hint: For recurring payments we charge the amount directly via transaction id

    objPayrexx = new backend.core.com.payrexx();
    paymentStruct = structNew();

    // For modules
    if (structKeyExists(url, "module")) {

        successLink = "#application.mainURL#/book?module=#url.module#";
        cancelLink = "#application.mainURL#/account-settings/modules?psp_response=cancel";
        failLink = "#application.mainURL#/account-settings/modules?psp_response=failed";
        thisStruct = moduleDetails;
        recurring = thisStruct.recurring;
        paymentStruct['purpose'] = thisStruct.name;


    // For plans
    } else if (structKeyExists(url, "plan")) {

        successLink = "#application.mainURL#/book?plan=#url.plan#";
        cancelLink = "#application.mainURL#/plans?psp_response=cancel";
        failLink = "#application.mainURL#/plans?psp_response=failed";
        thisStruct = planDetails;
        recurring = thisStruct.recurring;
        paymentStruct['purpose'] = thisStruct.planName;


    // For other payments (eg. invoices)
    } else {

        param name="successLink" default="";
        param name="cancelLink" default="";
        param name="failLink" default="";
        param name="purpose" default="";
        param name="amountToPay" default="0";
        param name="currency" default="USD";

        recurring = "onetime";
        paymentStruct['purpose'] = purpose;
        thisStruct.priceOneTimeAfterVAT = amountToPay;
        thisStruct.currency = currency;

    }

    // Charge the amount immediately
    if (structKeyExists(thisStruct, "priceOneTimeAfterVAT") and thisStruct.priceOneTimeAfterVAT gt 0) {

        thisAmount = thisStruct.priceOneTimeAfterVAT * 100;
        paymentStruct['amount'] = numberFormat(thisAmount, "__.__");
        paymentStruct['preAuthorization'] = false;

    } else {

        // If it's a recurring plan or module, only make a preAuthorization
        if (recurring eq "yearly") {
            thisAmount = thisStruct.priceYearlyAfterVAT * 100;
            paymentStruct['amount'] = numberFormat(thisAmount, "__.__");
            paymentStruct['preAuthorization'] = true;
        } else {
            thisAmount = thisStruct.priceMonthlyAfterVAT * 100;
            paymentStruct['amount'] = numberFormat(thisAmount, "__.__");
            paymentStruct['preAuthorization'] = true;
        }

    }

    paymentStruct['skipResultPage'] = true;
    paymentStruct['referenceId'] = session.customer_id & "@" & application.applicationname; // In order to recive the correct webhook, we need to pass the project name
    paymentStruct['currency'] = thisStruct.currency;
    paymentStruct['successRedirectUrl'] = successLink;
    paymentStruct['failedRedirectUrl'] = failLink;
    paymentStruct['cancelRedirectUrl'] = cancelLink;
    paymentStruct['lookAndFeelProfile'] = variables.payrexxDesignID; // config.cfm

    // Are there any specific PSPs defined?
    if (len(trim(variables.payrexxPSPs))) {
        paymentStruct['psp'] = variables.payrexxPSPs; // config.cfm
    }


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

            getAlert(e.message, 'danger');
            logWrite("payrexx", "error", "Could not create gateway [Error: #e.message#]", true);
            location url=failLink addtoken="false";

        }


    } else {

        getAlert(payrexxRespond.message, 'danger');
        logWrite("payrexx", "error", "Could not create gateway [Error: #payrexxRespond.message#]", true);
        location url=failLink addtoken="false";

    }



</cfscript>
