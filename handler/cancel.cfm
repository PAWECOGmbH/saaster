
<cfscript>

<!--- Cancel plan or revoke cancellation --->
if (structKeyExists(url, "plan")) {

    if (isNumeric(url.plan) and url.plan gt 0) {

        // Revoke cancellation
        if (structKeyExists(url, "revoke")) {

            revokePlan = new com.cancel(session.customer_id, url.plan, 'plan', session.lng).revoke();

            if (!revokePlan.success) {
                getAlert(revokePlan.message, 'danger');
                location url="#application.mainURL#/account-settings" addtoken="false";
            }

            getAlert('msgRevokedSuccessful', 'success');

        } else {

            cancelPlan = new com.cancel(session.customer_id, url.plan, 'plan', session.lng).cancel();

            if (!cancelPlan.success) {
                getAlert(cancelPlan.message, 'danger');
                location url="#application.mainURL#/account-settings" addtoken="false";
            }

            getAlert('msgCanceledSuccessful', 'success');


        }

        location url="#application.mainURL#/account-settings" addtoken="false";

    }

}


<!--- Cancel module or revoke cancellation --->
if (structKeyExists(url, "module")) {

    if (isNumeric(url.module) and url.module gt 0) {

        // Revoke cancellation
        if (structKeyExists(url, "revoke")) {

            revokeModule = new com.cancel(session.customer_id, url.module, 'module', session.lng).revoke();

            if (!revokeModule.success) {
                getAlert(revokeModule.message, 'danger');
                location url="#application.mainURL#/account-settings/modules" addtoken="false";
            }

            getAlert('msgRevokedSuccessful', 'success');


        } else {

            cancelModule = new com.cancel(session.customer_id, url.module, 'module', session.lng).cancel();

            if (!cancelModule.success) {
                getAlert(cancelModule.message, 'danger');
                location url="#application.mainURL#/account-settings/modules" addtoken="false";
            }

            getAlert('msgCanceledSuccessful', 'success');

        }


        location url="#application.mainURL#/account-settings/modules" addtoken="false";

    }

}

location url="#application.mainURL#/dashboard" addtoken="false";

</cfscript>