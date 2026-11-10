
<cfscript>

// Cancel plan or revoke cancellation
if (structKeyExists(url, "plan")) {

    if (isNumeric(url.plan) and url.plan gt 0) {

        // Revoke cancellation
        if (structKeyExists(url, "revoke")) {

            revokePlan = new backend.core.com.cancel(session.customer_id, url.plan, 'plan').revoke();

            if (!revokePlan.success) {
                getAlert(revokePlan.message, 'danger');

                logWrite("user", "warning", "Plan could not be revoked! [PlanID: #url.plan#, CustomerID: #session.customer_id#, UserID: #session.user_id#]");
                location url="#application.mainURL#/account-settings" addtoken="false";
            }

            logWrite("user", "info", "Plan cancellation revoked [PlanID: #url.plan#, CustomerID: #session.customer_id#, UserID: #session.user_id#]");
            getAlert('msgRevokedSuccessful', 'success');


        } else {

            // Remove waiting plan
            if (structKeyExists(url, "waitingPlan")) {

                cancelWaitingPlan = new backend.core.com.cancel(session.customer_id, url.plan, 'plan').cancelWaitingPlan();

                if (!cancelWaitingPlan.success) {
                    getAlert(cancelWaitingPlan.message, 'danger');
                    logWrite("user", "warning", "Waiting plan could not be deleted! [PlanID: #url.plan#, CustomerID: #session.customer_id#, UserID: #session.user_id#]");
                    location url="#application.mainURL#/account-settings/plans" addtoken="false";
                }

                logWrite("user", "info", "Waiting plan deleted [PlanID: #url.plan#, CustomerID: #session.customer_id#, UserID: #session.user_id#]");


            // Cancel plan
            } else {

                cancelPlan = new backend.core.com.cancel(session.customer_id, url.plan, 'plan').cancel();

                if (!cancelPlan.success) {
                    getAlert(cancelPlan.message, 'danger');
                    logWrite("user", "error", "Plan could not be cancelled! [PlanID: #url.plan#, CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: #cancelPlan.message#]");
                    location url="#application.mainURL#/account-settings" addtoken="false";
                }

                logWrite("user", "info", "Plan cancelled [PlanID: #url.plan#, CustomerID: #session.customer_id#, UserID: #session.user_id#]");
                getAlert('msgCanceledSuccessful', 'info');

            }

        }

        // Set plans and modules as well as the custom settings into a session
        application.objCustomer.setProductSessions(session.customer_id, session.lng);

        location url="#application.mainURL#/account-settings" addtoken="false";

    }

}


// Cancel module or revoke cancellation
if (structKeyExists(url, "module")) {

    if (isNumeric(url.module) and url.module gt 0) {

        // Revoke cancellation
        if (structKeyExists(url, "revoke")) {

            revokeModule = new backend.core.com.cancel(session.customer_id, url.module, 'module').revoke();

            if (!revokeModule.success) {
                getAlert(revokeModule.message, 'danger');
                logWrite("user", "error", "Module could not be revoked! [ModuleID: #url.module#, CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: #revokeModule.message#]");
                location url="#application.mainURL#/account-settings/modules" addtoken="false";
            }

            logWrite("user", "info", "Module cancellation revoked [ModuleID: #url.module#, CustomerID: #session.customer_id#, UserID: #session.user_id#]");
            getAlert('msgRevokedSuccessful', 'success');


        } else {

            cancelModule = new backend.core.com.cancel(session.customer_id, url.module, 'module').cancel();

            if (!cancelModule.success) {
                getAlert(cancelModule.message, 'danger');
                logWrite("user", "error", "Module could not be cancelled! [ModuleID: #url.module#, CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: #cancelModule.message#]");
                location url="#application.mainURL#/account-settings/modules" addtoken="false";
            }

            logWrite("user", "info", "Module cancelled [ModuleID: #url.module#, CustomerID: #session.customer_id#, UserID: #session.user_id#]");
            getAlert('msgCanceledSuccessful', 'success');

        }

        // Set plans and modules as well as the custom settings into a session
        application.objCustomer.setProductSessions(session.customer_id, session.lng);

        location url="#application.mainURL#/account-settings/modules" addtoken="false";

    }

}


// The same lifecycle handles manual account and individual tenant deletion.
if (structKeyExists(form, "delete")) {
    if (cgi.request_method neq "POST") { header statuscode=405 statustext="Method Not Allowed"; abort; }
    if (!isValid("integer", form.delete) or val(form.delete) lte 0 or (form.confirm_delete ?: "") neq "1") {
        header statuscode=400 statustext="Bad Request";
        abort;
    }
    deletionTarget = val(form.delete);
    deletionWasOwnContext = deletionTarget eq session.customer_id;
    deletionResult = new backend.core.com.account_lifecycle().submitDeletion(session.user_id, deletionTarget, form.password ?: "");
    deletionProgressMessage = deletionResult.reason eq "cleanup" ? "msgAccountDeletionFailed" : "msgAccountDeletionStarted";
    deletionAlertType = deletionResult.success ? "success" : (deletionResult.reason eq "cleanup" ? "danger" : "warning");
    if (deletionResult.accepted and deletionWasOwnContext) {
        deletionLanguage = session.lng;
        structClear(session);
        onSessionStart();
        session.lng = deletionLanguage;
        getAlert(deletionResult.success ? "msgAccountDeletionComplete" : deletionProgressMessage, deletionAlertType);
        location url="#application.mainURL#/login" addtoken=false;
    }
    deletionMessage = deletionResult.success ? "msgAccountDeletionComplete"
        : (deletionResult.accepted ? deletionProgressMessage
        : (deletionResult.reason eq "tenants" ? "msgAccountHasTenants"
        : (deletionResult.reason eq "identity" ? "msgAccountDeletionIdentity" : "msgAccountDeletionDenied")));
    getAlert(deletionMessage, deletionAlertType);
    location url=application.mainURL & (deletionWasOwnContext ? "/account-settings/company" : "/account-settings/tenants") addtoken=false;
}

logWrite("user", "warning", "Access attempt to handler/cancel.cfm without method [CustomerID: #session.customer_id#, UserID: #session.user_id#]");
location url="#application.mainURL#/dashboard" addtoken="false";

</cfscript>