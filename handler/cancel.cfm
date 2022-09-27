
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

        objUserLogin = application.objUser.checkLogin(argumentCollection = form);

        if (isStruct(objUserLogin)) {

            if (objUserLogin.loginCorrect and objUserLogin.active and objUserLogin.superadmin) {

                deleteAccount = application.objCustomer.deleteAccount(session.customer_id);
                if (deleteAccount) {
                    structClear(SESSION);
                    onSessionStart();
                    location url="#application.mainURL#?logout" addtoken="false";
                }

            }

        }

        location url="#application.mainURL#/account-settings/settings" addtoken="false";

    }

}





location url="#application.mainURL#/dashboard" addtoken="false";

</cfscript>