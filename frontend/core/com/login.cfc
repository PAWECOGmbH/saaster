component displayname="login" output="false" {

    // Login
    public struct function checkLogin() {

        param name="arguments.email" default="" type="string";
        param name="arguments.password" default="" type="string";

        local.returnStruct = structNew();
        local.returnStruct['loginCorrect'] = false;
        local.returnStruct['step'] = 1;

        local.qCheckLogin = queryExecute(

            options = {datasource = application.datasource},
            params = {
                thisEmail: {type: "nvarchar", value: arguments.email}
                },
            sql = "
                SELECT intUserID,strFirstName,strLastName,dtmLastLogin,blnAdmin,strEmail,blnActive,blnSuperAdmin,blnSysAdmin,strPasswordHash,strPasswordSalt,strLanguage,
                    (   SELECT intCustomerID
                        FROM customer_user
                        WHERE intUserID = users.intUserID AND blnStandard = 1
                        LIMIT 1
                    ) AS intCustomerID,
                    (   SELECT customers.blnActive
                        FROM customer_user INNER JOIN customers ON customer_user.intCustomerID = customers.intCustomerID
                        WHERE blnStandard = 1 AND intUserID = users.intUserID
                        LIMIT 1
                    ) AS tenant_active
                FROM users
                WHERE strEmail = :thisEmail
            "

        )


        if (local.qCheckLogin.recordCount) {

            if (local.qCheckLogin.strPasswordHash eq hash(arguments.password & local.qCheckLogin.strPasswordSalt, 'SHA-512')) {

                if (local.qCheckLogin.blnActive and local.qCheckLogin.tenant_active) {

                    local.returnStruct['active'] = true;
                    local.returnStruct['user_id'] = local.qCheckLogin.intUserID;
                    local.returnStruct['customer_id'] = local.qCheckLogin.intCustomerID;
                    local.returnStruct['user_name'] = local.qCheckLogin.strFirstName & " " & local.qCheckLogin.strLastName;
                    local.returnStruct['user_email'] = local.qCheckLogin.strEmail;
                    local.returnStruct['last_login'] = local.qCheckLogin.dtmLastLogin;
                    local.returnStruct['language'] = local.qCheckLogin.strLanguage;
                    local.returnStruct['admin'] = trueFalseFormat(local.qCheckLogin.blnAdmin);
                    local.returnStruct['superadmin'] = trueFalseFormat(local.qCheckLogin.blnSuperAdmin);
                    local.returnStruct['sysadmin'] = trueFalseFormat(local.qCheckLogin.blnSysAdmin);

                    queryExecute(

                        options = {datasource = application.datasource},
                        params = {
                            thisUserID: {type: "nvarchar", value: local.returnStruct.user_id},
                            dateNow: {type: "datetime", value: now()}
                        },
                        sql = "
                            UPDATE users
                            SET dtmLastLogin = :dateNow,
                                strUUID = ''
                            WHERE intUserID = :thisUserID
                        "

                    )

                    local.returnStruct['loginCorrect'] = true;

                    // If a redirect exists
                    local.insertDefaultPlan = true;
                    if (structKeyExists(session, "redirect") and len(trim(session.redirect))) {
                        local.returnStruct['redirect'] = session.redirect;
                        if (findNoCase("plan=", session.redirect)) {
                            local.insertDefaultPlan = false;
                        }
                    } else {
                        local.returnStruct['redirect'] = "#application.mainURL#/dashboard";
                    }

                    // Set the default plan only if the user hasn't choosed a plan via frontend
                    if (local.insertDefaultPlan) {

                        local.objPlans = new backend.core.com.plans();
                        local.planGroup = local.objPlans.prepareForGroupID(local.qCheckLogin.intCustomerID, session.usersIP);
                        local.objPlans.setDefaultPlan(local.qCheckLogin.intCustomerID, local.planGroup.groupID, local.qCheckLogin.blnSysAdmin);

                    }


                } else {

                    local.returnStruct['active'] = false;
                    local.returnStruct['loginCorrect'] = false;

                }

            }

        }else {

            local.returnStruct['redirect'] = "#application.mainURL#/login";

        }

        return local.returnStruct;

    }

}