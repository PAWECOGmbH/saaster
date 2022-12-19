component extends="taffy.core.resource" taffy_uri="/getUser/{userID}" {

    function get(required numeric userId){
        local.getUser = queryExecute(

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

        local.user = { 
            "user": {
                "intUserID": local.getUser.intUserID,
                "intCustomerID": local.getUser.intCustomerID,
                "dtmInsertDate": local.getUser.dtmInsertDate,
                "dtmMutDate": local.getUser.dtmMutDate,
                "strSalutation": local.getUser.strSalutation,
                "strFirstName": local.getUser.strFirstName,
                "strLastName": local.getUser.strLastName,
                "strEmail": local.getUser.strEmail,
                "strPhone": local.getUser.strPhone,
                "strMobile": local.getUser.strMobile,
                "strPhoto": local.getUser.strPhoto,
                "strLanguage": local.getUser.strLanguage,
                "blnActive": local.getUser.blnActive,
                "dtmLastLogin": local.getUser.dtmLastLogin,
                "blnAdmin": local.getUser.blnAdmin,
                "blnSuperAdmin": local.getUser.blnSuperAdmin,
                "blnSysAdmin": local.getUser.blnSysAdmin,
            }   
        }

        return rep( [local.user] );
    }

}