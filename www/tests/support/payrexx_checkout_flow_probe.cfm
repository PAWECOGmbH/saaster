<cfscript>
if (!structKeyExists(application,"checkoutMock")) { header statuscode=404; abort; }
fixture = queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:val(url.userID ?: 0)}},
    sql="SELECT intCustomerID FROM users WHERE intUserID=:id AND strEmail LIKE '%@saaster.invalid'");
if (!fixture.recordCount) { header statuscode=404; abort; }
session.user_id=val(url.userID); session.customer_id=fixture.intCustomerID;
session.lng="en"; session.admin=true; session.superadmin=true; session.sysadmin=false;
variables.applicationname=getApplicationMetadata().name;
variables.payrexxDesignID=""; variables.payrexxPSPs=""; variables.payrexxAPIinstance="";
getTrans=application.objLanguage.getTrans; getAlert=application.objGlobal.getAlert;
logWrite=(type,level,message,sendMail=false)=>application.objLog.logWrite(type,level,message,sendMail);
if ((url.mode ?: "") eq "authorization-start") {
    url.add=session.customer_id;
} else {
    url.pay=val(url.invoiceID); url.other="";
    if (url.mode eq "invoice-return") {
        url.psp_response="success";
        session.payrexxInvoiceGateways={};
        session.payrexxInvoiceGateways[toString(url.pay)]=val(url.gatewayID ?: 0);
        request.payrexxWebhookPayload={transaction:application.checkoutMock.events[1]};
    }
}
include template="/backend/core/handler/payment.cfm";
</cfscript>
