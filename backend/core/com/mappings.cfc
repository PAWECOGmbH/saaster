component displayname="mappings" output="false" {


    // #### FRONTEND MAPPINGS

    public struct function newFrontendMapping(required struct mappingData) {

        local.mappingData = evalDataFrontendMapping(arguments.mappingData);
        local.frontendMapping = {};

        // Check for existing mapping
        local.mappingData.mapping = checkFrontendMapping(local.mappingData.mapping);

        queryExecute(
            options = {datasource = application.datasource, result="local.newMapping"},
            params = {
                mapping: {type: "varchar", value: local.mappingData.mapping},
                path: {type: "varchar", value: local.mappingData.path},
                metaTitle: {type: "nvarchar", value: local.mappingData.metaTitle},
                metaDescription: {type: "nvarchar", value: local.mappingData.metaDescription},
                metaHTML: {type: "nvarchar", value: local.mappingData.metaHTML},
                createdByApp: {type: "boolean", value: local.mappingData.createdByApp}
            },
            sql = "
                INSERT INTO frontend_mappings (strMapping, strPath, strMetatitle, strMetadescription, strhtmlcodes, blnCreatedByApp)
                VALUES (:mapping, :path, :metaTitle, :metaDescription, :metaHTML, :createdByApp)
            "
        )

        if (local.newMapping.recordCount) {

            local.frontendMapping['id'] = local.newMapping.generated_key;
            local.frontendMapping['mapping'] = local.mappingData.mapping;
            local.frontendMapping['path'] = local.mappingData.path;
            local.frontendMapping['metaTitle'] = local.mappingData.metaTitle;
            local.frontendMapping['metaDescription'] = local.mappingData.metaDescription;
            local.frontendMapping['metaHTML'] = local.mappingData.metaHTML;
            local.frontendMapping['createdByApp'] = local.mappingData.createdByApp;

        }

        return local.frontendMapping;



    }

    public struct function editFrontendMapping(required struct mappingData, required numeric mappingID) {

        local.mappingData = evalDataFrontendMapping(arguments.mappingData);

        // Check for existing mapping
        local.mappingData.mapping = checkFrontendMapping(local.mappingData.mapping, arguments.mappingID);

        local.frontendMapping = {};

        queryExecute(
            options = {datasource = application.datasource, result="local.editMapping"},
            params = {
                mappingID = {type: "numeric", value: arguments.mappingID},
                mapping: {type: "varchar", value: local.mappingData.mapping},
                path: {type: "varchar", value: local.mappingData.path},
                metaTitle: {type: "nvarchar", value: local.mappingData.metaTitle},
                metaDescription: {type: "nvarchar", value: local.mappingData.metaDescription},
                metaHTML: {type: "nvarchar", value: local.mappingData.metaHTML},
                createdByApp: {type: "boolean", value: local.mappingData.createdByApp}
            },
            sql = "
                UPDATE frontend_mappings
                SET strMapping = :mapping,
                    strPath = :path,
                    strMetatitle = :metaTitle,
                    strMetadescription = :metaDescription,
                    strhtmlcodes = :metaHTML,
                    blnCreatedByApp = :createdByApp
                WHERE intFrontendMappingsID = :mappingID
            "
        )

        if (local.editMapping.recordCount) {

            local.frontendMapping['id'] = arguments.mappingID;
            local.frontendMapping['mapping'] = local.mappingData.mapping;
            local.frontendMapping['path'] = local.mappingData.path;
            local.frontendMapping['metaTitle'] = local.mappingData.metaTitle;
            local.frontendMapping['metaDescription'] = local.mappingData.metaDescription;
            local.frontendMapping['metaHTML'] = local.mappingData.metaHTML;
            local.frontendMapping['createdByApp'] = local.mappingData.createdByApp;

        }

        return local.frontendMapping;


    }

    private struct function evalDataFrontendMapping(required struct mappingData) {

        local.mapping;
        local.stringForUrlSlug;
        local.path;
        local.metaTitle;
        local.metaDescription;
        local.metaHTML;
        local.createdByApp = false;

        if (structKeyExists(arguments.mappingData, "mapping") and len(trim(arguments.mappingData.mapping))) {
            local.mapping = application.objGlobal.cleanUpText(arguments.mappingData.mapping, 255);
        }
        if (structKeyExists(arguments.mappingData, "path") and len(trim(arguments.mappingData.path))) {
            local.path = application.objGlobal.cleanUpText(arguments.mappingData.path, 255);
        }
        if (structKeyExists(arguments.mappingData, "metaTitle") and len(trim(arguments.mappingData.metaTitle))) {
            local.metaTitle = application.objGlobal.cleanUpText(arguments.mappingData.metaTitle, 255);
        }
        if (structKeyExists(arguments.mappingData, "metaDescription") and len(trim(arguments.mappingData.metaDescription))) {
            local.metaDescription = application.objGlobal.cleanUpText(arguments.mappingData.metaDescription, 3000);
        }
        if (structKeyExists(arguments.mappingData, "metaHTML") and len(trim(arguments.mappingData.metaHTML))) {
            local.metaHTML = application.objGlobal.cleanUpText(arguments.mappingData.metaHTML, 3000);
        }

        // If stringForUrlSlug is specified, we generate the URL slug from it
        if (structKeyExists(arguments.mappingData, "stringForUrlSlug") and len(trim(arguments.mappingData.stringForUrlSlug))) {
            local.slash = len(trim(arguments.mappingData.mapping)) ? "/" : "";
            local.mapping = local.mapping & local.slash & application.objGlobal.beautifyString(arguments.mappingData.stringForUrlSlug);
        }
        if (structKeyExists(arguments.mappingData, "createdByApp") and isBoolean(arguments.mappingData.createdByApp)) {
            local.createdByApp = arguments.mappingData.createdByApp;
        }

        return local;

    }

    private string function checkFrontendMapping(required string mapping, numeric mappingID) {

        local.mapping = arguments.mapping;
        local.whereStatement;

        if (structKeyExists(arguments, "mappingID")) {
            local.whereStatement = "AND intFrontendMappingsID <> " & arguments.mappingID;
        }

        local.qCheckMapping = queryExecute(
            options = {datasource = application.datasource},
            params = {
                mapping: {type: "varchar", value: local.mapping}
            },
            sql = "
                SELECT intFrontendMappingsID
                FROM frontend_mappings
                WHERE strMapping = :mapping
                #local.whereStatement#
            "
        )

        // Set an appendix to the mapping
        if (local.qCheckMapping.recordCount) {
            local.mapping = local.mapping & "-" & left(application.objGlobal.getUUID(), 6);
        }

        return local.mapping;

    }

    public boolean function deleteFrontendMapping(required numeric mappingID) {

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    mappingID: {type: "numeric", value: arguments.mappingID}
                },
                sql = "
                    DELETE FROM frontend_mappings
                    WHERE intFrontendMappingsID = :mappingID
                "
            )

            return true;

        } catch (any) {

            return false;

        }

    }


    // #### CUSTOM MAPPINGS

    public struct function newCustomMapping(required struct mappingData) {

        local.mappingData = evalDataCustomMapping(arguments.mappingData);
        local.customMapping = {};

        // Check for existing mapping
        local.mappingData.mapping = checkCustomMapping(local.mappingData.mapping);

        queryExecute(
            options = {datasource = application.datasource, result="local.newMapping"},
            params = {
                mapping: {type: "varchar", value: local.mappingData.mapping},
                path: {type: "varchar", value: local.mappingData.path},
                admin: {type: "boolean", value: local.mappingData.admin},
                superadmin: {type: "boolean", value: local.mappingData.superadmin},
                sysadmin: {type: "boolean", value: local.mappingData.sysadmin}
            },
            sql = "
                INSERT INTO custom_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
                VALUES (:mapping, :path, :admin, :superadmin, :sysadmin)
            "
        )

        if (local.newMapping.recordCount) {

            local.customMapping['id'] = local.newMapping.generated_key;
            local.customMapping['mapping'] = local.mappingData.mapping;
            local.customMapping['path'] = local.mappingData.path;

        }

        return local.customMapping;


    }

    public struct function editCustomMapping(required struct mappingData, required numeric mappingID) {

        local.mappingData = evalDataCustomMapping(arguments.mappingData);

        // Check for existing mapping
        local.mappingData.mapping = checkCustomMapping(local.mappingData.mapping, arguments.mappingID);

        local.customMapping = {};

        queryExecute(
            options = {datasource = application.datasource, result="local.editMapping"},
            params = {
                mappingID: {type: "numeric", value: arguments.mappingID},
                mapping: {type: "varchar", value: local.mappingData.mapping},
                thispath: {type: "varchar", value: local.mappingData.path},
                admin: {type: "boolean", value: local.mappingData.admin},
                superadmin: {type: "boolean", value: local.mappingData.superadmin},
                sysadmin: {type: "boolean", value: local.mappingData.sysadmin}
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

        if (local.editMapping.recordCount) {

            local.customMapping['id'] = arguments.mappingID;
            local.customMapping['mapping'] = local.mappingData.mapping;
            local.customMapping['path'] = local.mappingData.path;

        }

        return local.customMapping;


    }


    private struct function evalDataCustomMapping(required struct mappingData) {

        local.mapping;
        local.path;

        if (structKeyExists(arguments.mappingData, "mapping") and len(trim(arguments.mappingData.mapping))) {
            local.mapping = application.objGlobal.cleanUpText(arguments.mappingData.mapping, 255);
        }
        if (structKeyExists(arguments.mappingData, "path") and len(trim(arguments.mappingData.path))) {
            local.path = application.objGlobal.cleanUpText(arguments.mappingData.path, 255);
        }

        local.admin = arguments.mappingData.admin eq "admin" ? 1 : 0;
        local.superadmin = arguments.mappingData.admin eq "superadmin" ? 1 : 0;
        local.sysadmin = arguments.mappingData.admin eq "sysadmin" ? 1 : 0;

        return local;

    }

    private string function checkCustomMapping(required string mapping, numeric mappingID) {

        local.mapping = arguments.mapping;
        local.whereStatement;

        if (structKeyExists(arguments, "mappingID")) {
            local.whereStatement = "AND intCustomMappingID <> " & arguments.mappingID;
        }

        local.qCheckMapping = queryExecute(
            options = {datasource = application.datasource},
            params = {
                mapping: {type: "varchar", value: local.mapping}
            },
            sql = "
                SELECT intCustomMappingID
                FROM custom_mappings
                WHERE strMapping = :mapping
                #local.whereStatement#
            "
        )

        // Set an appendix to the mapping
        if (local.qCheckMapping.recordCount) {
            local.mapping = local.mapping & "-" & left(application.objGlobal.getUUID(), 6);
        }

        return local.mapping;

    }

    public boolean function deleteCustomMapping(required numeric mappingID) {

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    mappingID: {type: "numeric", value: arguments.mappingID}
                },
                sql = "
                    DELETE FROM custom_mappings
                    WHERE intCustomMappingID = :mappingID
                "
            )

            return true;

        } catch (any) {

            return false;

        }

    }

}