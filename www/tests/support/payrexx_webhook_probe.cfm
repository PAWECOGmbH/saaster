<cfscript>
// Exercise the production webhook handler, including authentication, in the dedicated test app.
if (!structKeyExists(application,"checkoutMock")) { header statuscode=404; abort; }
originalEnvironment = application.environment;
application.environment = "test-webhook";
variables.applicationname = getApplicationMetadata().name;
variables.payrexxWebhookPassword = "fixture-webhook-secret";
variables.payrexxPSPs = "";
logWrite = (type,level,message,sendMail=false) => application.objLog.logWrite(type,level,message,sendMail);
try {
    include template="/frontend/core/handler/payrexx_webhook.cfm";
} finally {
    application.environment = originalEnvironment;
}
</cfscript>
