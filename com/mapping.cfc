component displayname="mapping" output="false" {

    public query function getCustomMappings(){

        local.qCustomMappings = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM custom_mappings
                ORDER BY intCustomMappingID DESC
            "
        );

        return local.qCustomMappings;
    }

    public query function getSystemMappings(){

        local.qSystemMappings = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM system_mappings
            "
        );

        return local.qSystemMappings;
    }

}