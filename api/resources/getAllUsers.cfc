component extends="taffy.core.resource" taffy_uri="/getAllUsers" {

    function get(){
        local.qGetAllUsers = queryExecute(

            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM users
            "

        )

        return rep(queryToArray(local.qGetAllUsers));
    }

}