component displayname="api" output="false" {

    public query function getApi(){

        local.qApiUser = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT intApiID, strApiName, dtmValidUntil
                FROM api_management
            "
        )

        return local.qApiUser;
    }

}