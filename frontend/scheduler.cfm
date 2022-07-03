
<cfscript>

// This file is called by the scheduler


// Security
param name="url.pass" default="";
if (variables.schedulePassword eq url.pass) {

    local.objInvoice = new com.invoices();

    // Charge open invoices
    local.chargeNow = local.objInvoice.payInvoice(1);

    dump(local.chargeNow);





} else {

    location url="#application.mainURL#" addtoken="false";

}


</cfscript>