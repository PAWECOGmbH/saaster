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
            path: {type: "varchar", value: form.path},
            admin: {type: "boolean", value: admin},
            superadmin: {type: "boolean", value: superadmin},
            sysadmin: {type: "boolean", value: sysadmin}
        },
        sql = "
            INSERT INTO custom_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
            VALUES (:mapping, :path, :admin, :superadmin, :sysadmin)
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
                mappingID: {type: "numeric", value: form.edit_mapping},
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
                WHERE intCustomMappingID = :mappingID
            "
        )

    }

    location url="#application.mainURL#/sysadmin/mappings" addtoken="false";

}


if (structKeyExists(form, "new_mapping_frontend")) {

    param name="form.mapping" default="";
    param name="form.path" default="";
    param name="form.metatitle" default="";
    param name="form.metadescription" default="";
    param name="form.htmlcodes" default="";

    local.form.mapping = left(form.mapping, 3000);
    local.form.path = left(form.path, 3000);
    local.form.metatitle = left(form.metatitle, 3000);
    local.form.metadescription = left(form.metadescription, 3000);
    local.form.htmlcodes = left(form.htmlcodes, 3000);

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            mapping: {type: "nvarchar", value: local.form.mapping},
            path: {type: "nvarchar", value: local.form.path},
            metatitle: {type: "nvarchar", value: local.form.metatitle},
            metadescription: {type: "nvarchar", value: local.form.metadescription},
            htmlcodes: {type: "nvarchar", value: local.form.htmlcodes}
        },
        sql = "
            INSERT INTO frontend_mappings (strMapping, strPath, strMetatitle, strMetadescription, strhtmlcodes)
            VALUES (:mapping, :path, :metatitle, :metadescription, :htmlcodes)
        "
    )

    location url="#application.mainURL#/sysadmin/mappings##frontend" addtoken="false";

}


if(structKeyExists(form, "edit_mapping_frontend")) {
    if (structKeyExists(form, "delete")) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                mappingID: {type: "numeric", value: form.edit_mapping_frontend}
            },
            sql = "
                DELETE FROM frontend_mappings WHERE intFrontendMappingsID = :mappingID
            "
        )
        queryExecute(
            options = {datasource = application.datasource},
            params = {
                mappingID: {type: "numeric", value: form.edit_mapping_frontend}
            },
            sql = "
                DELETE FROM frontend_mappings_trans WHERE intFrontendMappingsID = :mappingID
            "
        )

    } else {

        param name="form.edit_mapping_frontend" default="";
        param name="form.mapping" default="";
        param name="form.path" default="";
        param name="form.metatitle" default="";
        param name="form.metadescription" default="";
        param name="form.htmlcodes" default="";

        local.form.mapping = left(form.mapping, 3000);
        local.form.path = left(form.path, 3000);
        local.form.metatitle = left(form.metatitle, 3000);
        local.form.metadescription = left(form.metadescription, 3000);
        local.form.htmlcodes = left(form.htmlcodes, 3000);

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                mappingID: {type: "numeric", value: form.edit_mapping_frontend},
                mapping: {type: "nvarchar", value: local.form.mapping},
                path: {type: "nvarchar", value: local.form.path},
                metatitle: {type: "nvarchar", value: local.form.metatitle},
                metadescription: {type: "nvarchar", value: local.form.metadescription},
                htmlcodes: {type: "nvarchar", value: local.form.htmlcodes}
            },
            sql = "
                UPDATE frontend_mappings
                SET strMapping = :mapping,
                    strPath = :path,
                    strMetatitle = :metatitle,
                    strMetadescription = :metadescription,
                    strhtmlcodes = :htmlcodes
                WHERE intFrontendMappingsID = :mappingID
            "
        )

    }

    location url="#application.mainURL#/sysadmin/mappings##frontend" addtoken="false";
}

</cfscript>