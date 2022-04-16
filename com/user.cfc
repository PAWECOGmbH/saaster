
component displayname="user" output="false" {

    <!--- Login --->
    public struct function checkLogin() {

        param name="form.email" default="" type="string";
        param name="form.password" default="" type="string";

        local.returnStruct = structNew();
        local.returnStruct['loginCorrect'] = false;
        local.returnStruct['step'] = 1;

        qCheckLogin = queryExecute(

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


        if (qCheckLogin.recordCount) {

            if (qCheckLogin.strPasswordHash eq hash(form.password & qCheckLogin.strPasswordSalt, 'SHA-512')) {

                if (qCheckLogin.blnActive and qCheckLogin.tenant_active) {

                    local.returnStruct['active'] = true;
                    local.returnStruct['user_id'] = qCheckLogin.intUserID;
                    local.returnStruct['customer_id'] = qCheckLogin.intCustomerID;
                    local.returnStruct['user_name'] = qCheckLogin.strFirstName & " " & qCheckLogin.strLastName;
                    local.returnStruct['user_email'] = qCheckLogin.strEmail;
                    local.returnStruct['last_login'] = qCheckLogin.dtmLastLogin;
                    local.returnStruct['language'] = qCheckLogin.strLanguage;
                    local.returnStruct['admin'] = trueFalseFormat(qCheckLogin.blnAdmin);
                    local.returnStruct['superadmin'] = trueFalseFormat(qCheckLogin.blnSuperAdmin);
                    local.returnStruct['sysadmin'] = trueFalseFormat(qCheckLogin.blnSysAdmin);

                    queryExecute(

                        options = {datasource = application.datasource},
                        params = {
                            thisUserID: {type: "nvarchar", value: local.returnStruct.user_id}
                        },
                        sql = "
                            UPDATE users
                            SET dtmLastLogin = now(),
                                strUUID = ''
                            WHERE intUserID = :thisUserID
                        "

                    )

                    local.returnStruct['loginCorrect'] = true;

                    if (structKeyExists(session, "redirect") and len(trim(session.redirect))) {
                        local.returnStruct['redirect'] = session.redirect;
                    } else {
                        local.returnStruct['redirect'] = "#application.mainURL#/dashboard";
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


    <!--- Change users password --->
    public struct function changePassword(required string newPassword, required string resetUUID) {

        <!--- Default variables --->
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        <!--- Hash and salt the password --->
        local.hashedStruct = application.objGlobal.generateHash(arguments.newPassword);

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    passwordHash: {type: "nvarchar", value: local.hashedStruct.thisHash},
                    passwordSalt: {type: "nvarchar", value: local.hashedStruct.thisSalt},
                    strUUID: {type: "nvarchar", value: arguments.resetUUID}
                },
                sql = "
                    UPDATE users
                    SET strPasswordHash = :passwordHash,
                        strPasswordSalt = :passwordSalt
                    WHERE strUUID = :strUUID
                "
            )

            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        }
        catch(any) {

            local.argsReturnValue['message'] = cfcatch.message;
        }

        return local.argsReturnValue;

    }


    <!--- Update user --->
    public struct function updateUser(required struct userStruct, required numeric userID) {

        <!--- Default variables --->
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (structKeyExists(arguments.userStruct, "salutation")) {
            local.salutation = application.objGlobal.cleanUpText(arguments.userStruct.salutation, 20);
        } else {
            local.salutation = '';
        }
        if (structKeyExists(arguments.userStruct, "first_name")) {
            local.first_name = application.objGlobal.cleanUpText(arguments.userStruct.first_name, 100);
        } else {
            local.first_name = '';
        }
        if (structKeyExists(arguments.userStruct, "last_name")) {
            local.last_name = application.objGlobal.cleanUpText(arguments.userStruct.last_name, 100);
        } else {
            local.last_name = '';
        }
        if (structKeyExists(arguments.userStruct, "email")) {
            local.email = application.objGlobal.cleanUpText(arguments.userStruct.email, 100);
        } else {
            local.email = '';
        }
        if (structKeyExists(arguments.userStruct, "phone")) {
            local.phone = application.objGlobal.cleanUpText(arguments.userStruct.phone, 100);
        } else {
            local.phone = '';
        }
        if (structKeyExists(arguments.userStruct, "mobile")) {
            local.mobile = application.objGlobal.cleanUpText(arguments.userStruct.mobile, 100);
        } else {
            local.mobile = '';
        }
        if (structKeyExists(arguments.userStruct, "language")) {
            local.language = arguments.userStruct.language;
        } else {
            local.language = '';
        }
        if (structKeyExists(arguments.userStruct, "superadmin")) {
            local.superadmin = arguments.userStruct.superadmin;
        } else {
            local.superadmin = 0;
        }
        if (structKeyExists(arguments.userStruct, "admin")) {
            local.admin = arguments.userStruct.admin;
        } else {
            local.admin = 0;
        }
        if (structKeyExists(arguments.userStruct, "active")) {
            local.active = arguments.userStruct.active;
        } else {
            local.active = 0;
        }
        if (structKeyExists(arguments.userStruct, "tenantID")) {
            local.tenantID = arguments.userStruct.tenantID;
        } else {
            local.tenantID = '';
        }

        try {

            <!--- update the user --->
            queryExecute(

                options = {datasource = application.datasource, result="check"},
                params = {
                    intUserID: {type: "numeric", value: arguments.userID},
                    salutation: {type: "nvarchar", value: local.salutation},
                    first_name: {type: "nvarchar", value: local.first_name},
                    last_name: {type: "nvarchar", value: local.last_name},
                    email: {type: "nvarchar", value: local.email},
                    phone: {type: "nvarchar", value: local.phone},
                    mobile: {type: "nvarchar", value: local.mobile},
                    language: {type: "nvarchar", value: local.language},
                    admin: {type: "numeric", value: local.admin},
                    superadmin: {type: "numeric", value: local.superadmin},
                    active: {type: "numeric", value: local.active}
                },
                sql = "

                    UPDATE users
                    SET strSalutation = :salutation,
                        strFirstName = :first_name,
                        strLastName = :last_name,
                        strEmail = :email,
                        strPhone = :phone,
                        strMobile = :mobile,
                        strLanguage = :language,
                        blnAdmin = :admin,
                        blnSuperAdmin = :superadmin,
                        blnActive = :active
                    WHERE intUserID = :intUserID

                "

            )


            if (listLen(local.tenantID)) {

                <!--- Delete tenants to which the user has no access  --->
                queryExecute(

                    options = {datasource = application.datasource, result="check"},
                    params = {
                        userID: {type: "numeric", value: arguments.userID}
                    },
                    sql = "
                        DELETE FROM customer_user
                        WHERE intUserID = :userID AND NOT intCustomerID IN (#local.tenantID#)
                    "

                )

                <!--- Insert tenants to which the user has access  --->
                cfloop( list = local.tenantID, index = "local.t" ) {

                    queryExecute(

                        options = {datasource = application.datasource},
                        params = {
                            tenantID: {type: "numeric", value: local.t},
                            userID: {type: "numeric", value: arguments.userID}
                        },
                        sql = "
                            INSERT INTO customer_user (intCustomerID, intUserID)
                            SELECT * FROM
                            (
                                SELECT :tenantID as thisTenantID, :userID as thisUserID
                            ) as tmp
                            WHERE NOT EXISTS
                            (
                                SELECT intCustomerID
                                FROM customer_user
                                WHERE intCustomerID = :tenantID AND intUserID = :userID
                            )
                        "

                    )

                }

                <!--- At least one tenant must be defined as standard --->
                qCheckStandard = queryExecute(

                    options = {datasource = application.datasource},
                    params = {
                        userID: {type: "numeric", value: arguments.userID}
                    },
                    sql = "
                        SELECT SUM(blnStandard) as hasStandard
                        FROM customer_user
                        WHERE intUserID = :userID
                    "
                )

                if (qCheckStandard.hasStandard eq 0) {

                    queryExecute(

                        options = {datasource = application.datasource},
                        params = {
                            userID: {type: "numeric", value: arguments.userID}
                        },
                        sql = "
                            UPDATE customer_user
                            SET blnStandard = 1
                            WHERE intUserID = :userID
                            ORDER BY intCustomerID
                            LIMIT 1
                        "
                    )

                }

            }

            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        } catch(any){

            local.argsReturnValue['message'] = cfcatch.message;


        }

        return local.argsReturnValue;

    }


    <!--- Insert user --->
    public struct function insertUser(required struct userStruct, required numeric customerID) {

        <!--- Default variables --->
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;
        local.argsReturnValue['newUUID'] = application.objGlobal.getUUID();

        if (structKeyExists(arguments.userStruct, "salutation")) {
            local.salutation = application.objGlobal.cleanUpText(arguments.userStruct.salutation, 20);
        } else {
            local.salutation = '';
        }
        if (structKeyExists(arguments.userStruct, "first_name")) {
            local.first_name = application.objGlobal.cleanUpText(arguments.userStruct.first_name, 100);
        } else {
            local.first_name = '';
        }
        if (structKeyExists(arguments.userStruct, "last_name")) {
            local.last_name = application.objGlobal.cleanUpText(arguments.userStruct.last_name, 100);
        } else {
            local.last_name = '';
        }
        if (structKeyExists(arguments.userStruct, "email")) {
            local.email = application.objGlobal.cleanUpText(arguments.userStruct.email, 100);
        } else {
            local.email = '';
        }
        if (structKeyExists(arguments.userStruct, "phone")) {
            local.phone = application.objGlobal.cleanUpText(arguments.userStruct.phone, 100);
        } else {
            local.phone = '';
        }
        if (structKeyExists(arguments.userStruct, "mobile")) {
            local.mobile = application.objGlobal.cleanUpText(arguments.userStruct.mobile, 100);
        } else {
            local.mobile = '';
        }
        if (structKeyExists(arguments.userStruct, "admin")) {
            local.admin = arguments.userStruct.admin;
        } else {
            local.admin = 0;
        }
        if (structKeyExists(arguments.userStruct, "superadmin")) {
            local.superadmin = arguments.userStruct.superadmin;
            if (local.superadmin eq 1) {
                local.admin = 1;
            }
        } else {
            local.superadmin = 0;
        }
        if (structKeyExists(arguments.userStruct, "active")) {
            local.active = arguments.userStruct.active;
        } else {
            local.active = 0;
        }


        try {

            queryExecute(

                options = {datasource = application.datasource, result="newUserID"},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID},
                    salutation: {type: "nvarchar", value: local.salutation},
                    first_name: {type: "nvarchar", value: local.first_name},
                    last_name: {type: "nvarchar", value: local.last_name},
                    email: {type: "nvarchar", value: local.email},
                    phone: {type: "nvarchar", value: local.phone},
                    mobile: {type: "nvarchar", value: local.mobile},
                    admin: {type: "boolean", value: local.admin},
                    superadmin: {type: "boolean", value: local.superadmin},
                    active: {type: "boolean", value: local.active},
                    newUUID: {type: "nvarchar", value: local.argsReturnValue.newUUID}
                },
                sql = "
                    INSERT INTO users (intCustomerID, dtmInsertDate, dtmMutDate, strSalutation, strFirstName, strLastName, strEmail, strPhone, strMobile, blnActive, blnAdmin, blnSuperAdmin, strUUID)
                    VALUES (:customerID, now(), now(), :salutation, :first_name, :last_name, :email, :phone, :mobile, :active, :admin, :superadmin, :newUUID)
                "

            )

            local.argsReturnValue['newUserID'] = newUserID.generatedkey;
            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        } catch(any){

            local.argsReturnValue['message'] = cfcatch.message;

        }

        return local.argsReturnValue;

    }


    <!--- Get all users --->
    public query function getAllUsers(required numeric customerID) {

        if (arguments.customerID gt 0) {

            qUsers = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID}
                },
                sql = "
                    SELECT users.*
                    FROM customer_user
                    INNER JOIN users ON customer_user.intUserID = users.intUserID
                    WHERE customer_user.intCustomerID = :customerID
                "
            )

            return qUsers;

        }

    }


    <!--- Send invitation link --->
    public struct function sendInvitation(required numeric toUserID, required numeric fromUserID) {

        <!--- Default variables --->
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (arguments.toUserID gt 0 and arguments.fromUserID gt 0) {

            <!--- Get user --->
            qUser = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    toUserID: {type: "numeric", value: arguments.toUserID},
                    fromUserID: {type: "numeric", value: arguments.fromUserID}
                },
                sql = "
                    SELECT strUUID,
                            (SELECT CONCAT(strFirstName, ' ', strLastName) FROM users WHERE intUserID = :fromUserID) as fromName,
                            (SELECT strEmail FROM users WHERE intUserID = :fromUserID) as fromEmail,
                            (SELECT CONCAT(strFirstName, ' ', strLastName) FROM users WHERE intUserID = :toUserID) as toName,
                            (SELECT strEmail FROM users WHERE intUserID = :toUserID) as toEmail
                    FROM users
                    WHERE intUserID = :toUserID
                "
            )

            local.thisUUID = qUser.strUUID;

            if (qUser.recordCount) {

                <!--- UUID already set? --->
                if (!len(trim(qUser.strUUID))) {

                    local.thisUUID = application.objGlobal.getUUID();

                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            userID: {type: "numeric", value: arguments.toUserID},
                            newUUID: {type: "nvarchar", value: local.thisUUID}
                        },
                        sql = "
                            UPDATE users
                            SET strUUID = :newUUID
                            WHERE intUserID = :userID
                        "
                    )

                }

                getTrans = application.objGlobal.getTrans;

                <!--- Replacing variables --->
                local.invitationMail = replaceNoCase(getTrans('txtInvitationMail'), '@sender_name@', '#qUser.fromName#', 'all');
                local.invitationMail = replaceNoCase(local.invitationMail, '@project_name@', '#application.projectName#', 'all');

                <!--- Send activation link --->
                mail from="#application.fromEmail#" to="#qUser.toEmail#" subject="#getTrans('txtInvitationFrom')# #qUser.fromName#" type="html" {
                    echo (
                        "
                        <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
                        <html xmlns='http://www.w3.org/1999/xhtml'>
                            <head></head>
                            <body style='font-family:Verdana, Geneva, sans-serif; font-size: 14px;'>
                                #getTrans('titHello')# #qUser.toName#<br><br>
                                #local.invitationMail#<br>
                                <a href='#application.mainURL#/registration?u=#local.thisUUID#'>#application.mainURL#/registration?u=#local.thisUUID#</a><br>
                                (#getTrans('txtRegisterLinkNotWorking')#)
                                <br><br>
                                #getTrans('txtRegards')#<br>
                                #getTrans('txtYourTeam')#<br>
                                #application.appOwner#
                            </body>
                        </html>
                        "
                    )
                }

                local.argsReturnValue['message'] = getTrans('msgUserGotInvitation');
                local.argsReturnValue['success'] = true;

            } else {

                local.argsReturnValue['message'] = "No user found!";

            }


        } else {

            local.argsReturnValue['message'] = "Wrong id's";

        }

        return local.argsReturnValue;

    }


    <!--- Get users image --->
    public struct function getUserImage(required numeric userID) {

        local.userData = application.objCustomer.getUserDataByID(arguments.userID);

        local.myImgStruct = structNew();

        if (len(trim(local.userData.strPhoto)) and fileExists(expandpath('/userdata/images/users/#local.userData.strPhoto#'))) {

            local.myImgStruct['userImage'] = "#application.mainURL#/userdata/images/users/#local.userData.strPhoto#";
            local.myImgStruct['itsLocal'] = true;

        } else {

            <!--- Look for a gravatar.com picture or use the default picture (application) --->
            local.encodedPath = urlEncode(application.userTempImg);
            local.myImgStruct['userImage'] = "https://www.gravatar.com/avatar/#lcase(Hash(lcase(local.userData.strEmail)))#?d=#local.encodedPath#&s=300";
            local.myImgStruct['itsLocal'] = false;

        }

        return local.myImgStruct;

    }
}