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
                    (   SELECT
                            CASE
                                WHEN EXISTS (
                                    SELECT 1
                                    FROM customer_user
                                    INNER JOIN customers ON customer_user.intCustomerID = customers.intCustomerID
                                    WHERE customer_user.blnStandard = 1
                                    AND customer_user.intUserID = users.intUserID
                                    LIMIT 1
                                )
                                THEN 1
                                ELSE 0
                            END
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


                    /* Handling for default plan an redirects */

                    // Defaults
                    local.insertDefaultPlan = false;

                    // Check for a redirect
                    local.redirectTo = structKeyExists(session, "redirect") and len(trim(session.redirect)) ? session.redirect : "";

                    // Check redirect from plans
                    local.redirectFromPlans = structKeyExists(session, "redirect") and findNoCase("plan=", session.redirect) ? true : false;

                    // Check the current plan
                    local.checkPlan = new backend.core.com.plans(language=local.qCheckLogin.strLanguage).getCurrentPlan(local.qCheckLogin.intCustomerID);
                    local.hasPlan = local.checkPlan.planID gt 0 ? true : false;

                    // In case the customer hasn't a plan yet
                    if (!local.hasPlan) {

                        // Activate the default plan only if there is no redirect from plans (frontend)
                        if (!local.redirectFromPlans) {
                            local.insertDefaultPlan = true;
                        }

                    // In case the customer has a plan already
                    } else {

                        // If the customer has clicked a plan in frontend, we need to delete the redirect
                        if (local.redirectFromPlans) {
                             structDelete(session, "redirect");
                             local.redirectTo = "#application.mainURL#/account-settings/plans";
                        }

                    }

                    // Set the redirect
                    if (len(trim(local.redirectTo))) {
                        local.returnStruct['redirect'] = local.redirectTo;
                    } else {
                        local.returnStruct['redirect'] = "#application.mainURL#/dashboard";
                    }

                    // Set the default plan if needed
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