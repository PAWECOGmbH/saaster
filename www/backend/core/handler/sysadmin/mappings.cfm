<cfscript>

objMapping = new backend.core.com.mappings();

if (structKeyExists(form, "new_mapping")) {

    newCustomMapping = objMapping.newCustomMapping(form);

    if (structIsEmpty(newCustomMapping)) {
        getAltert('Something went wrong!', 'danger');
    }

    location url="#application.mainURL#/sysadmin/mappings?mapping=custom" addtoken="false";

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

    location url="#application.mainURL#/sysadmin/mappings?mapping=custom" addtoken="false";

}


if (structKeyExists(form, "new_mapping_frontend")) {

    newFrontendMapping = objMapping.newFrontendMapping(form);

    if (structIsEmpty(newFrontendMapping)) {
        getAltert('Something went wrong!', 'danger');
    }

    location url="#application.mainURL#/sysadmin/mappings?mapping=frontend" addtoken="false";

}


if(structKeyExists(form, "edit_mapping_frontend")) {

    if (structKeyExists(form, "delete")) {

        deleteFrontendMapping = objMapping.deleteFrontendMapping(form.edit_mapping_frontend);

        if (!deleteFrontendMapping) {
            getAlert("Could not delete the mapping!", "danger");
        }

        location url="#application.mainURL#/sysadmin/mappings?mapping=frontend" addtoken="false";

    } else {

        // Decode the 'htmlcodes' field from base64 and convert it to UTF-8 string format.
        if (structKeyExists(form, "htmlcodes")) {
            form.htmlcodes = toString(binaryDecode( form.htmlcodes, "base64" ), "utf-8");
        }

        editFrontendMapping = objMapping.editFrontendMapping(form, form.edit_mapping_frontend);

        getAlert('Frontend mapping updated successfully!', 'success');
        location url="#application.mainURL#/sysadmin/mapping/edit?mappingID=#form.edit_mapping_frontend#" addtoken="false";

    }

}

</cfscript>

