component displayname="modules" output="false" {

    <!--- Pause or reactivate module --->
    public boolean function pauseModule(required numeric customerID, required numeric moduleID, required boolean active) {        

        queryExecute(
            options = {datasource=application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                moduleID: {type: "numeric", value: arguments.moduleID},
                active = {type: "boolean", value: arguments.active}
            },
            sql = "
                UPDATE customer_modules
                SET blnPaused = :active
                WHERE intCustomerID = :customerID
                AND intModuleID = :moduleID
            "
        )

        return arguments.active;

    }


    <!--- Get data of a module --->
    public struct function getModuleDataByID(required numeric moduleID) {

        qModule = queryExecute(
            options = {datasource = application.datasource},
            params = {
                moduleID: {type: "numeric", value: arguments.moduleID}
            },        
            sql = "
                SELECT *
                FROM modules
                WHERE intModulID = :moduleID
            "
        )

        local.moduleStruct = structNew();
        if (qModule.recordCount) {
            local.moduleStruct['name'] = qModule.strModuleName;
            local.moduleStruct['description'] = qModule.strDescription;
            local.moduleStruct['table_prefix'] = qModule.strTabPrefix;
            local.moduleStruct['picture'] = qModule.strPicture;
            local.moduleStruct['bookable'] = qModule.blnBookable;
        }

        return local.moduleStruct;

    }

}