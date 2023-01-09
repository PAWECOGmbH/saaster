component extends="taffy.core.resource" taffy_uri="/getUser/{userID}" {

    function get(required numeric userId){

        local.qGetUser = application.objCustomer.getUserDataByID(arguments.userID);
        
        return rep(queryToStruct(local.qGetUser));
    }

}