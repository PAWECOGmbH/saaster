component extends="taffy.core.resource" taffy_uri="/getAllUsers" {

    function get(){
        local.getAllUsers = queryExecute(

            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM users
            "

        )

        local.allUsers = {};
        
        loop query=local.getAllUsers {
            
            local.user = { 
                "user#intUserID#": {
                    "intUserID": intUserID,
                    "intCustomerID": intCustomerID,
                    "dtmInsertDate": dtmInsertDate,
                    "dtmMutDate": dtmMutDate,
                    "strSalutation": strSalutation,
                    "strFirstName": strFirstName,
                    "strLastName": strLastName,
                    "strEmail": strEmail,
                    "strPhone": strPhone,
                    "strMobile": strMobile,
                    "strPhoto": strPhoto,
                    "strLanguage": strLanguage,
                    "blnActive": blnActive,
                    "dtmLastLogin": dtmLastLogin,
                    "blnAdmin": blnAdmin,
                    "blnSuperAdmin": blnSuperAdmin,
                    "blnSysAdmin": blnSysAdmin,
                }   
            }

            local.allUsers.append(local.user)
        }

        return rep(local.allUsers);
    }

}