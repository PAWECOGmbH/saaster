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

    local.mapping = application.objGlobal.cleanUpText(form.mapping, 255);
    local.path = application.objGlobal.cleanUpText(form.path, 255);
    local.metatitle = application.objGlobal.cleanUpText(form.metatitle, 255);
    local.metadescription = application.objGlobal.cleanUpText(form.metadescription, 3000);
    local.htmlcodes = left(replace(form.htmlcodes, "invalidTag", "meta", "all"), 3000);

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            mapping: {type: "varchar", value: local.mapping},
            path: {type: "varchar", value: local.path},
            metatitle: {type: "nvarchar", value: local.metatitle},
            metadescription: {type: "nvarchar", value: local.metadescription},
            htmlcodes: {type: "nvarchar", value: local.htmlcodes}
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

        local.mapping = application.objGlobal.cleanUpText(form.mapping, 255);
        local.path = application.objGlobal.cleanUpText(form.path, 255);
        local.metatitle = application.objGlobal.cleanUpText(form.metatitle, 255);
        local.metadescription = application.objGlobal.cleanUpText(form.metadescription, 3000);
        local.htmlcodes = left(replace(form.htmlcodes, "invalidTag", "meta", "all"), 3000);

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                mappingID: {type: "numeric", value: form.edit_mapping_frontend},
                mapping: {type: "varchar", value: local.mapping},
                path: {type: "varchar", value: local.path},
                metatitle: {type: "nvarchar", value: local.metatitle},
                metadescription: {type: "nvarchar", value: local.metadescription},
                htmlcodes: {type: "nvarchar", value: local.htmlcodes}
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