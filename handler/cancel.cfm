
<cfscript>

<!--- Cancel plan or revoke cancellation --->
if (structKeyExists(url, "plan")) {

    if (isNumeric(url.plan) and url.plan gt 0) {

        // Revoke cancellation
        if (structKeyExists(url, "revoke")) {

            revokePlan = new com.cancel(session.customer_id, url.plan, 'plan').revoke();

            if (!revokePlan.success) {
                getAlert(revokePlan.message, 'danger');
                location url="#application.mainURL#/account-settings" addtoken="false";
            }

            getAlert('msgRevokedSuccessful', 'success');

        } else {

            cancelPlan = new com.cancel(session.customer_id, url.plan, 'plan').cancel();

            if (!cancelPlan.success) {
                getAlert(cancelPlan.message, 'danger');
                location url="#application.mainURL#/account-settings" addtoken="false";
            }

            getAlert('msgCanceledSuccessful', 'info');


        }

        <!--- Save current plan into a session --->
        session.currentPlan = new com.plans().getCurrentPlan(session.customer_id);

        <!--- Save current module array into a session --->
        session.currentModules = new com.modules().getBookedModules(session.customer_id);

        location url="#application.mainURL#/account-settings" addtoken="false";

    }

}


<!--- Cancel module or revoke cancellation --->
if (structKeyExists(url, "module")) {

    if (isNumeric(url.module) and url.module gt 0) {

        // Revoke cancellation
        if (structKeyExists(url, "revoke")) {

            revokeModule = new com.cancel(session.customer_id, url.module, 'module').revoke();

            if (!revokeModule.success) {
                getAlert(revokeModule.message, 'danger');
                location url="#application.mainURL#/account-settings/modules" addtoken="false";
            }

            getAlert('msgRevokedSuccessful', 'success');


        } else {

            cancelModule = new com.cancel(session.customer_id, url.module, 'module').cancel();

            if (!cancelModule.success) {
                getAlert(cancelModule.message, 'danger');
                location url="#application.mainURL#/account-settings/modules" addtoken="false";
            }

            getAlert('msgCanceledSuccessful', 'success');

        }

        <!--- Save current plan into a session --->
        session.currentPlan = new com.plans().getCurrentPlan(session.customer_id);

        <!--- Save current module array into a session --->
        session.currentModules = new com.modules().getBookedModules(session.customer_id);

        location url="#application.mainURL#/account-settings/modules" addtoken="false";

    }

}

location url="#application.mainURL#/dashboard" addtoken="false";

</cfscript>