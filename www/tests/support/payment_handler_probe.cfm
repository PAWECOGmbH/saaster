<cfsetting showdebugoutput="false">
<cfscript>
/*
    Runs the return from Payrexx (backend/core/handler/payment.cfm, url.add + url.psp)
    inside the test application, as a given user. Used by
    specs/integration/booking_after_payment_spec.cfc (issue #521).

    url.customerID, url.userID   the logged-in user
    url.redirect                 booking waiting for the payment method, like ?redirect= on the payment page
    url.gatewayID                the Payrexx gateway the setup was started with
    url.psp                      "success" or "failed"
    url.cancelFirst              open the payment page with ?cancel before (the user canceled a setup)

    The handler answers with a redirect (302); the spec reads its Location header.
    application.objLog is replaced by the log recorder for the run.

    It only lives inside the test application, which refuses to start outside of
    development.
*/
param name="url.customerID" default=0;
param name="url.userID" default=0;
param name="url.redirect" default="";
param name="url.gatewayID" default=0;
param name="url.psp" default="success";

session.customer_id = val(url.customerID);
session.user_id = val(url.userID);
session.lng = "en";
session.sysadmin = false;
session.admin = true;
session.superadmin = true;
structDelete(session, "redirect");
if (len(url.redirect)) {
    // Application.cfc::onRequest does the same for ?redirect=
    session.redirect = application.mainURL & "/" & url.redirect;
}
if (val(url.gatewayID) gt 0) {
    session.payrexxPendingGatewayID = val(url.gatewayID);
}

// The page variables of Application.cfc::onRequest
getTrans = application.objLanguage.getTrans;
getAlert = application.objGlobal.getAlert;
csrfToken = application.objGlobal.csrfToken;
csrfField = application.objGlobal.csrfField;
csrfParam = application.objGlobal.csrfParam;
getLayout = application.layoutStruct;
getTime = new backend.core.com.time(session.customer_id);

originalLog = application.objLog;
recorder = new tests.support.log_recorder();
application.objLog = recorder;
// A closure, not a reference to recorder.logWrite: a detached method loses the recorder's state
logWrite = (type, level, message, sendMail = false) => recorder.logWrite(type, level, message, sendMail);

try {

    if (structKeyExists(url, "cancelFirst")) {
        // The payment page with ?cancel, the way Payrexx sends the user back after canceling
        url.cancel = "";
        savecontent variable="cancelPage" {
            include template="/backend/core/views/customer/payment.cfm";
        }
        structDelete(url, "cancel");
    }

    url.add = session.customer_id;
    include template="/backend/core/handler/payment.cfm";

} finally {
    application.objLog = originalLog;
}

// The handler always redirects - reaching this line means it did not
content type="application/json" reset="true";
writeOutput(serializeJSON({ "noRedirect": true }));
</cfscript>
