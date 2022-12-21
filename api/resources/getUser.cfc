component extends="taffy.core.resource" taffy_uri="/getUser/{userID}" {

    function get(required numeric userId){
        local.qGetUser = queryExecute(

            options = {datasource = application.datasource},
            params = {
                thisUserID: {type: "numeric", value: arguments.userID}
            },
            sql = "
                SELECT *
                FROM users
                WHERE intUserID = :thisUserID
            "

        )

        return rep(queryToArray(local.qGetUser));
    }

}