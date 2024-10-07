<cfscript>

objMapping = new backend.core.com.mappings();

if (structKeyExists(form, "new_mapping")) {

    newCustomMapping = objMapping.newCustomMapping(form);

    if (structIsEmpty(newCustomMapping)) {
        getAltert('Something went wrong!', 'danger');
    }

    location url="#application.mainURL#/sysadmin/mappings" addtoken="false";

}


if (structKeyExists(form, "edit_mapping")) {

    if (structKeyExists(form, "delete")) {

        deleteCustomMapping = objMapping.deleteCustomMapping(form.edit_mapping);

        if (!deleteCustomMapping) {
            getAlert("Could not delete the mapping!", "danger");
        }

    } else {

        editCustomMapping = objMapping.editCustomMapping(form, form.edit_mapping);

        if (structIsEmpty(editCustomMapping)) {
            getAltert('Something went wrong!', 'danger');
        }

    }

    location url="#application.mainURL#/sysadmin/mappings" addtoken="false";

}


if (structKeyExists(form, "new_mapping_frontend")) {

    newFrontendMapping = objMapping.newFrontendMapping(form);

    if (structIsEmpty(newFrontendMapping)) {
        getAltert('Something went wrong!', 'danger');
    }

    location url="#application.mainURL#/sysadmin/mappings##frontend" addtoken="false";

}


if(structKeyExists(form, "edit_mapping_frontend")) {

    if (structKeyExists(form, "delete")) {

        deleteFrontendMapping = objMapping.deleteFrontendMapping(form.edit_mapping_frontend);

        if (!deleteFrontendMapping) {
            getAlert("Could not delete the mapping!", "danger");
        }

    } else {

        editFrontendMapping = objMapping.editFrontendMapping(form, form.edit_mapping_frontend);

        if (structIsEmpty(editFrontendMapping)) {
            getAltert('Something went wrong!', 'danger');
        }

    }

    location url="#application.mainURL#/sysadmin/mappings##frontend" addtoken="false";
}

</cfscript>