<cfsetting showdebugoutput="false">
<cfscript>
// The test application refuses non-development environments and only uses its test DB.
param name="url.userID" default=0;
param name="url.customerID" default=0;
param name="url.view" default="tab";
user = queryExecute(
    options={datasource=application.datasource},
    params={id:{type:"integer",value:val(url.userID)}},
    sql="SELECT strFirstName, strLastName, intCustomerID, blnSysAdmin, blnAdmin, blnSuperAdmin FROM users WHERE intUserID = :id"
);
session.user_id = val(url.userID);
session.user_name = user.strFirstName & " " & user.strLastName;
session.customer_id = user.intCustomerID;
session.lng = listFind("en,de",url.language ?: "") ? url.language : "en";
session.sysadmin = user.blnSysAdmin;
session.admin = user.blnAdmin;
session.superadmin = user.blnSuperAdmin;
application.objCustomer.setProductSessions(session.customer_id, session.lng);
getTrans = application.objLanguage.getTrans;
getAlert = application.objGlobal.getAlert;
csrfField = application.objGlobal.csrfField;
csrfParam = application.objGlobal.csrfParam;
getLayout = application.layoutStruct;
thiscontent = {thisID:val(url.customerID)};
if (url.view eq "page") {
    include template="/backend/core/views/sysadmin/customers_details.cfm";
} else {
    include template="/backend/core/views/sysadmin/ajax_customer_tab.cfm";
}
</cfscript>
