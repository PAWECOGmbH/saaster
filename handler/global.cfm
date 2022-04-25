<cfscript>

<!--- Logout and delete all sessions--->
if (structKeyExists(url, "logout")) {

    structClear(SESSION);
    onSessionStart();

    location url="#application.mainURL#/login?logout" addtoken="no";
}


<!--- Switch the company/tenant --->
if (structKeyExists(url, "switch")) {

    if (isNumeric(url.switch)) {

        qTenant = queryExecute(

            options = {datasource = application.datasource},
            params = {
                intCustomerID: {type: "numeric", value = url.switch},
                intUserID: {type: "numeric", value = session.user_id}
            },
            sql = "
                SELECT customers.intCustomerID
                FROM customers INNER JOIN customer_user ON customers.intCustomerID = customer_user.intCustomerID
                WHERE customers.intCustomerID = :intCustomerID AND customer_user.intUserID = :intUserID
            "
        )

        if (qTenant.recordCount) {

            session.customer_id = qTenant.intCustomerID;

            <!--- Save current plan into a session --->
            checkPlan = new com.plans().getCurrentPlan(session.customer_id, session.lng);
            session.currentPlan = checkPlan;

            location url="#application.mainURL#/dashboard" addtoken="no";

        } else {

            location url="#application.mainURL#/global?logout" addtoken="no";

        }

    }


}


</cfscript>