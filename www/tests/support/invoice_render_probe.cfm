<cfsetting showdebugoutput="false">
<cfscript>
/*
    Renders the invoice view (backend/core/views/invoices/invoice.cfm) or the print
    (print.cfm) inside the test application, as a given user with a given interface
    language. Used by specs/integration/invoice_rendering_spec.cfc.

    The real application provides the page variables in Application.cfc::onRequest
    (getTrans, getLayout, getTime, ...); they are set here the same way.

    url.view: "invoice" or "print", url.invoiceID, url.userID, url.lng (interface language)
    Answer: { html } for the view, the PDF itself for the print.

    It only lives inside the test application, which refuses to start outside of
    development.
*/
param name="url.view" default="invoice";
param name="url.invoiceID" default=0;
param name="url.userID" default=0;
param name="url.lng" default="en";

user = application.objCustomer.getUserDataByID(val(url.userID));

session.user_id = val(url.userID);
session.customer_id = user.intCustomerID;
session.lng = url.lng;
session.sysadmin = false;
session.admin = true;
session.superadmin = true;
session.user_name = user.strFirstName & " " & user.strLastName;
session.user_email = user.strEmail;

// The page variables of Application.cfc::onRequest
getTrans = application.objLanguage.getTrans;
getAlert = application.objGlobal.getAlert;
logWrite = application.objLog.logWrite;
csrfToken = application.objGlobal.csrfToken;
csrfField = application.objGlobal.csrfField;
csrfParam = application.objGlobal.csrfParam;
getLayout = application.layoutStruct;
getTime = new backend.core.com.time(session.customer_id);
thiscontent = { thisID: val(url.invoiceID) };

html = "";
if (url.view eq "print") {
    // print.cfm answers with the PDF itself; the spec reads its text
    include template="/backend/core/views/invoices/print.cfm";
    abort;
} else {
    savecontent variable="html" {
        include template="/backend/core/views/invoices/invoice.cfm";
    }
}

content type="application/json" reset="true";
writeOutput(serializeJSON({ "html": html }));
</cfscript>
