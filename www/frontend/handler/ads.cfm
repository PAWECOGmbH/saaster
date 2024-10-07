<cfscript>


    if (structKeyExists(form, "application") and form.application eq session.user_id) {

        if (structKeyExists(form, "job") and structKeyExists(form, "motivation")) {

            appData = {};
            appData['workerID'] = form.application;
            appData['jobID'] = form.job;
            appData['motivationText'] = application.objGlobal.cleanUpText(form.motivation, 10000);

            sendApplication = application.objAdsFrontend.sendApplication(appData);
            if (sendApplication.success) {
                getAlert(sendApplication.message);

            } else {
                getAlert(sendApplication.message, "danger");
            }

            location url="#application.mainURL#/#form.mapping#" addtoken="false";

        }

    }

    location url="#application.mainURL#" addtoken="false";

</cfscript>