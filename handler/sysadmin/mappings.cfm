<cfscript>

if (structKeyExists(form, "new_mapping")) {

    param name="form.mapping" default="";
    param name="form.path" default="";
    param name="form.admin" default="";

    admin = 0;
    superadmin = 0;
    sysadmin = 0;

    if (form.admin eq "admin") {
        admin = 1;
    }
    if (form.admin eq "superadmin") {
        superadmin = 1;
    }
    if (form.admin eq "sysadmin") {
        sysadmin = 1;
    }


    queryExecute(
        options = {datasource = application.datasource},
        params = {
            mapping: {type: "varchar", value: form.mapping},
            thispath: {type: "varchar", value: form.path},
            admin: {type: "boolean", value: admin},
            superadmin: {type: "boolean", value: superadmin},
            sysadmin: {type: "boolean", value: sysadmin}
        },
        sql = "
            INSERT INTO custom_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
            VALUES (:mapping, :thispath, :admin, :superadmin, :sysadmin)
        "
    )

    location url="#application.mainURL#/sysadmin/mappings" addtoken="false";

}


if (structKeyExists(form, "edit_mapping")) {

    if (structKeyExists(form, "delete")) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                mappingID: {type: "numeric", value: form.edit_mapping}
            },
            sql = "
                DELETE FROM custom_mappings WHERE intCustomMappingID = :mappingID
            "
        )

    } else {

        param name="form.mapping" default="";
        param name="form.path" default="";
        param name="form.admin" default="";

        admin = 0;
        superadmin = 0;
        sysadmin = 0;

        if (form.admin eq "admin") {
            admin = 1;
        }
        if (form.admin eq "superadmin") {
            superadmin = 1;
        }
        if (form.admin eq "sysadmin") {
            sysadmin = 1;
        }

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                mapping: {type: "varchar", value: form.mapping},
                thispath: {type: "varchar", value: form.path},
                admin: {type: "boolean", value: admin},
                superadmin: {type: "boolean", value: superadmin},
                sysadmin: {type: "boolean", value: sysadmin}
            },
            sql = "
                UPDATE custom_mappings
                SET strMapping = :mapping,
                    strPath = :thispath,
                    blnOnlyAdmin = :admin,
                    blnOnlySuperAdmin = :superadmin,
                    blnOnlySysAdmin = :sysadmin
            "
        )

    }

    location url="#application.mainURL#/sysadmin/mappings" addtoken="false";

}

</cfscript>