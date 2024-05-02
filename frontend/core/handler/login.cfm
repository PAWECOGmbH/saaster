<cfscript>



// Logout and delete all sessions
if (structKeyExists(url, "logout")) {

    logWrite("user", "info", "User has logged out [CustomerID: #session.customer_id#, UserID: #session.user_id#]");

    structClear(SESSION);
    onSessionStart();

    location url="#application.mainURL#/login?logout" addtoken="no";
}


</cfscript>