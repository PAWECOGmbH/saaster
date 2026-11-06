<cfsetting showdebugoutput="false">
<cfscript>
    // Test-only HTTP harness: tests/Application.cfc enforces the isolated test DB.
    param name="url.view" default="memberships";
    if (cgi.request_method eq "GET" and structKeyExists(url, "userID")) {
        probeUser = queryExecute(
            options = {datasource: application.datasource}, params = {id: {type: "integer", value: val(url.userID)}},
            sql = "SELECT * FROM users WHERE intUserID = :id AND strEmail LIKE '%@saaster.invalid'"
        );
        if (not probeUser.recordCount) { header statuscode=404; abort; }
        structClear(session);
        session.user_id = probeUser.intUserID;
        session.customer_id = val(url.customerID ?: probeUser.intCustomerID);
        session.admin = probeUser.blnAdmin;
        session.superadmin = probeUser.blnSuperAdmin;
        session.sysadmin = probeUser.blnSysAdmin;
        session.lng = url.language ?: "en";
    }
    if (not structKeyExists(session, "user_id") or not application.objMembershipAccess.refreshSession()) {
        header statuscode=403; abort;
    }
    probeViews = {memberships:"memberships", account:"account-settings", newuser:"user_new", users:"users", tenants:"tenants"};
    probePath = url.view eq "handler" ? "backend/core/handler/memberships.cfm" : "backend/core/views/customer/" & (probeViews[url.view] ?: "memberships") & ".cfm";
    if (not application.objMembershipAccess.allowRequest(session.user_id, session.customer_id, probePath, cgi.request_method, form, url)) {
        header statuscode=403; abort;
    }
    getTrans = application.objLanguage.getTrans;
    getAlert = application.objGlobal.getAlert;
    csrfField = application.objGlobal.csrfField;
    csrfParam = application.objGlobal.csrfParam;
    getLayout = application.layoutStruct;
    if (url.view eq "handler") {
        include template="/backend/core/handler/memberships.cfm";
    } else {
        writeOutput('<!doctype html><html><head><meta name="viewport" content="width=device-width, initial-scale=1">');
        include template="/backend/core/views/css.cfm";
        writeOutput('</head><body>');
        application.objCustomer.setProductSessions(session.customer_id, session.lng);
        getCustomerData = application.objCustomer.getCustomerData(session.customer_id);
        qTenants = application.objCustomer.getAllTenants(session.user_id);
        include template="/#probePath#";
        writeOutput('<script src="https://cdn.jsdelivr.net/npm/@tabler/core@1.6.1/dist/js/tabler.min.js"></script></body></html>');
    }
</cfscript>
