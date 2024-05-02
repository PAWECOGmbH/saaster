
<cfscript>

// Delete a logfile
if (structKeyExists(url, "logfile")) {

    deleteFile = application.objLog.deleteLogfile(url.logfile);

    if (deleteFile.success) {
        getAlert(deleteFile.message, 'success');
    } else {
        getAlert(deleteFile.message, 'warning');
    }

    location url="#application.mainURL#/sysadmin/logs" addtoken="false";

}


// Bulk action
if (structKeyExists(form, "log_action")) {

    // Bulk delete
    if (form.log_action eq "delete") {

        if (structKeyExists(form, "logfile") and listLen(form.logfile)) {

            hasFailures = false;

            loop list=form.logfile index="file" {

                deleteFile = application.objLog.deleteLogfile(file);

                if (!deleteFile.success) {
                    hasFailures = true;
                }

            }

            if (hasFailures) {
                getAlert('Some files or directories could not be deleted!', 'warning');
            } else {
                getAlert('All files and any directories have been deleted.', 'success');
            }

        }


    }

    location url="#application.mainURL#/sysadmin/logs" addtoken="false";

}

location url="#application.mainURL#/dashboard" addtoken="false";

</cfscript>