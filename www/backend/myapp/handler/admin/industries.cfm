
<cfscript>

objIndustries = new backend.myapp.com.admin.industries();

// New industry
if (structKeyExists(form, "industry_new")) {

    if (len(trim(form.industry_new))) {
        form["industry_new"] = form.industry_new;
    }
    if (structKeyExists(form, "active")) {
        form["active"] = 1;
    } else {
        form["active"] = 0;
    }

    setNewIndustry = objIndustries.newIndustry(form);

    if (setNewIndustry.success) {
       getAlert(setNewIndustry.message);
    } else {
       getAlert(setNewIndustry.message, "danger");
    }


}


// Edit industry
if (structKeyExists(form, "industry_edit") and isNumeric(form.industry_edit)) {

    // Update
    if (structKeyExists(form, "save")) {

        if (len(trim(form.industry))) {
            form["industry"] = form.industry;
        }
        if (structKeyExists(form, "active")) {
            form["active"] = 1;
        } else {
            form["active"] = 0;
        }

        updateIndustry = objIndustries.updateIndustry(form);

        if (updateIndustry.success) {
            getAlert(updateIndustry.message);
        } else {
            getAlert(updateIndustry.message, "danger");
        }


    } else if (structKeyExists(form, "delete")) {

        deleteIndustry = objIndustries.deleteIndustry(form);

        if (deleteIndustry.success) {
            getAlert(deleteIndustry.message);
        } else {
            getAlert(deleteIndustry.message, "danger");
        }

    }


}


// Proposals
if (structKeyExists(form, "proposal") and isNumeric(form.proposal)) {

    editProposal = objIndustries.editProposal(form);

    if (editProposal.success) {
        getAlert(editProposal.message);
    } else {
        getAlert(editProposal.message, "danger");
    }


}

location url="#application.mainURL#/admin/industries" addtoken="false";

</cfscript>