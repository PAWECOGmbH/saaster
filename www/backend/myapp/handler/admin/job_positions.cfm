
<cfscript>

objJobPosition = new backend.myapp.com.admin.job_positions();

// New job position
if (structKeyExists(form, "position_new")) {

    if (len(trim(form.position_new))) {
        form["position_new"] = form.position_new;
    }
    if (structKeyExists(form, "active")) {
        form["active"] = 1;
    } else {
        form["active"] = 0;
    }

    newJobPosition = objJobPosition.newJobPosition(form);

    if (newJobPosition.success) {
       getAlert(newJobPosition.message);
    } else {
       getAlert(newJobPosition.message, "danger");
    }


}


// Edit job position
if (structKeyExists(form, "position_edit") and isNumeric(form.position_edit)) {

    // Update
    if (structKeyExists(form, "save")) {

        if (len(trim(form.position))) {
            form["position"] = form.position;
        }
        if (structKeyExists(form, "active")) {
            form["active"] = 1;
        } else {
            form["active"] = 0;
        }

        updateJobPosition = objJobPosition.updateJobPosition(form);

        if (updateJobPosition.success) {
            getAlert(updateJobPosition.message);
        } else {
            getAlert(updateJobPosition.message, "danger");
        }


    } else if (structKeyExists(form, "delete")) {

        deleteJobPosition = objJobPosition.deleteJobPosition(form);

        if (deleteJobPosition.success) {
            getAlert(deleteJobPosition.message);
        } else {
            getAlert(deleteJobPosition.message, "danger");
        }

    }


}


location url="#application.mainURL#/admin/job-positions" addtoken="false";

</cfscript>