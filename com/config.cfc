
component displayname="config" output="false" {

    // Get config data for the application
    public struct function getConfigData(string datasource) {

        local.qCheck = queryExecute(
            options = {datasource = arguments.datasource},
            sql = "
                SELECT strVariable, strValue
                FROM config
            "
        )

        local.systemStruct = structNew();

        loop query=local.qCheck {
            local.systemStruct[local.qCheck.strVariable] = local.qCheck.strValue;
        }

        return local.systemStruct;

    }



}
