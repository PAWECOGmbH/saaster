<cfsetting showdebugoutput="false">
<cfscript>
    // Exercise production dispatch in the isolated test application, using fixture identities only.
    if (cgi.request_method eq "GET" and structKeyExists(url, "userID")) {
        fixtureUser = queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:val(url.userID)}},
            sql="SELECT intUserID, intCustomerID, blnAdmin, blnSuperAdmin, blnSysAdmin FROM users WHERE intUserID = :id AND strEmail LIKE '%@saaster.invalid'");
        if (not fixtureUser.recordCount) { header statuscode=404; abort; }
        structClear(session);
        session.user_id = fixtureUser.intUserID;
        session.customer_id = val(url.customerID ?: fixtureUser.intCustomerID);
        session.admin = fixtureUser.blnAdmin;
        session.superadmin = fixtureUser.blnSuperAdmin;
        session.sysadmin = fixtureUser.blnSysAdmin;
        session.lng = url.language ?: "en";
        application.objCustomer.setProductSessions(session.customer_id, session.lng);
    }
    flowRoutes = "account-settings/memberships,memberships,global,organization-invitation,accept-organization-invitation,login,logincheck,dashboard";
    if (not listFind(flowRoutes, url.route ?: "")) { header statuscode=404; abort; }
    if (listFind("default_theme,custom_theme", url.theme ?: "")) {
        application.activeTheme = url.theme;
        application.assetFiles = application.objCoreUtil.getAssets(url.theme);
    }
    application action="update" cgiReadonly=false;
    cgi.path_info = structKeyExists(url, "direct") ? "" : "/" & url.route;
    new webroot.Application().onRequest(structKeyExists(url, "direct") ? "/backend/myapp/__saaster_access_test.cfm" : "/index.cfm");
</cfscript>
