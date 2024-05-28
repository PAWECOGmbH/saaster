
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

            cancelPlan = new backend.core.com.cancel(session.customer_id, url.plan, 'plan').cancel();

            if (!cancelPlan.success) {
                getAlert(cancelPlan.message, 'danger');
                logWrite("user", "error", "Plan could not be cancelled! [PlanID: #url.plan#, CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: #cancelPlan.message#]");
                location url="#application.mainURL#/account-settings" addtoken="false";
            }

            logWrite("user", "info", "Plan cancelled [PlanID: #url.plan#, CustomerID: #session.customer_id#, UserID: #session.user_id#]");
            getAlert('msgCanceledSuccessful', 'info');

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


// Delete the account right now
if (structKeyExists(form, "delete")) {

    if (form.delete eq session.customer_id) {

        param name="form.email" default="";
        param name="form.password" default="";

        objUserLogin = new frontend.core.com.login().checkLogin(argumentCollection = form);

        if (objUserLogin.loginCorrect and objUserLogin.active and objUserLogin.superadmin) {

            user_email = objUserLogin.user_email;
            user_name = objUserLogin.user_name;
            user_id = objUserLogin.user_id;

            deleteAccount = application.objCustomer.deleteAccount(session.customer_id);

            if (deleteAccount.success) {

                logWrite("user", "info", "Account deleted [CustomerID: #session.customer_id#, UserID: #user_id#, E-Mail: #user_email#, Name: #user_name#]");

                structClear(SESSION);
                onSessionStart();
                location url="#application.mainURL#?logout" addtoken="false";

            } else {

                logWrite("user", "warning", "Could not delete account [CustomerID: #session.customer_id#, UserID: #user_id#, E-Mail: #user_email#, Name: #user_name#, Message: #deleteAccount.message#]");
                getAlert(deleteAccount.message, 'warning');
                location url="#application.mainURL#/account-settings/company" addtoken="false";

            }

        } else {

            getAlert('alertWrongLogin', 'danger');
            logWrite("user", "warning", "Couldn't delete the account, because of wrong login or user status [CustomerID: #session.customer_id#, UserID: #user_id#, is active: #objUserLogin.active#, is superAdmin: #objUserLogin.superadmin#]");
            location url="#application.mainURL#/account-settings/company" addtoken="false";

        }

    }

}

logWrite("user", "warning", "Access attempt to handler/cancel.cfm without method [CustomerID: #session.customer_id#, UserID: #session.user_id#]");
location url="#application.mainURL#/dashboard" addtoken="false";

</cfscript>