
<cfscript>

objContractTypes = new backend.myapp.com.admin.contract_types();

// New contract type
if (structKeyExists(form, "contract_new")) {

    if (len(trim(form.contract_new))) {
        form["contract_new"] = form.contract_new;
    }
    if (structKeyExists(form, "active")) {
        form["active"] = 1;
    } else {
        form["active"] = 0;
    }

    newContractType = objContractTypes.newContractType(form);

    if (newContractType.success) {
       getAlert(newContractType.message);
    } else {
       getAlert(newContractType.message, "danger");
    }


}


// Edit contract type
if (structKeyExists(form, "contract_edit") and isNumeric(form.contract_edit)) {

    // Update
    if (structKeyExists(form, "save")) {

        if (len(trim(form.contract))) {
            form["contract"] = form.contract;
        }
        if (structKeyExists(form, "active")) {
            form["active"] = 1;
        } else {
            form["active"] = 0;
        }

        updateContractType = objContractTypes.updateContractType(form);

        if (updateContractType.success) {
            getAlert(updateContractType.message);
        } else {
            getAlert(updateContractType.message, "danger");
        }


    } else if (structKeyExists(form, "delete")) {

        deleteContractType = objContractTypes.deleteContractType(form);

        if (deleteContractType.success) {
            getAlert(deleteContractType.message);
        } else {
            getAlert(deleteContractType.message, "danger");
        }

    }


}


location url="#application.mainURL#/admin/contract-types" addtoken="false";

</cfscript>