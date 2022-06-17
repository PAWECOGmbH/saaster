
<cfscript>

    // Here we process the payment via Payrexx

    objPayrexx = new com.payrexx();
    paymentStruct = structNew();

    if (structKeyExists(url, "module")) {
        thisStruct = moduleDetails;
        redirectString = "#application.mainURL#/book?module=#url.module#&psp_response=";
    } else {
        thisStruct = planDetails;
        redirectString = "#application.mainURL#/book?plan=#url.plan#&psp_response=";
    }
    if (thisStruct.priceYearlyAfterVAT gt 0) {
        paymentStruct['amount'] = thisStruct.priceYearlyAfterVAT;
    } else if (thisStruct.priceMonthlyAfterVAT gt 0) {
        paymentStruct['amount'] = thisStruct.priceMonthlyAfterVAT;
    } else if (thisStruct.priceOneTimeAfterVAT gt 0) {
        paymentStruct['amount'] = thisStruct.priceOneTimeAfterVAT;
    }

    paymentStruct['referenceId'] = session.customer_id;
    paymentStruct['purpose'] = thisStruct.name;
    paymentStruct['currency'] = thisStruct.currency;
    paymentStruct['successRedirectUrl'] = redirectString & "success";
    paymentStruct['failedRedirectUrl'] = redirectString & "failed";
    paymentStruct['cancelRedirectUrl'] = redirectString & "cancel";
    paymentStruct['lookAndFeelProfile'] = variables.lookAndFeelProfile; // config.cfm
    paymentStruct['skipResultPage'] = true;


    dump(paymentStruct);
    abort;


    getPaymentLink = objPayrexx.createGateway(paymentStruct);

    /* if (isStruct(getPaymentLink) and getPaymentLink.status eq "success") {
        location url=getPaymentLink.data[1].link;
    } */


    <!---

    The variable of the amount to be sent to the PSP is:
    -> priceAfterVAT

    --->



</cfscript>
