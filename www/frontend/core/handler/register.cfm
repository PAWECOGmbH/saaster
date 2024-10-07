
<cfscript>

objRegister = new frontend.core.com.register();

// Check login
if (structKeyExists(form, 'login_btn')) {

    param name="form.email" default="";
    param name="form.password" default="";

    objUserLogin = new frontend.core.com.login().checkLogin(argumentCollection = form);

    if (isStruct(objUserLogin)) {

        if (objUserLogin.loginCorrect) {

            session.user_id = objUserLogin.user_id;
            session.customer_id = objUserLogin.customer_id;
            session.user_name = objUserLogin.user_name;
            session.user_email = objUserLogin.user_email;
			session.last_login = objUserLogin.last_login;
            session.lng = objUserLogin.language;
			session.admin = trueFalseFormat(objUserLogin.admin);
            session.superadmin = trueFalseFormat(objUserLogin.superadmin);
            session.sysadmin = trueFalseFormat(objUserLogin.sysadmin);

            // Inheritance
            if (session.sysadmin) {
                session.admin = true;
                session.superadmin = true;
            } else if (session.superadmin) {
                session.admin = true;
            }

            // Set plans and modules as well as the custom settings into a session
            application.objCustomer.setProductSessions(session.customer_id, session.lng);

            // Is the needed data of the cutomer already filled out?
            dataFilledIn = objRegister.checkFilledData(session.customer_id);
            if (!dataFilledIn) {
                session.filledData = false;
            }

            objUserMfa = application.objCustomer.getUserDataByID(session.user_id);
            blnresend = false;
            mfaUUID = application.objGlobal.getUUID();

            if (objUserMfa.blnMfa){
                structDelete(session, 'user_id');
                session.mfaCheckCount = 0;
                objSendMfa = application.objUser.sendMfaCode(mfaUUID, blnresend, session.user_email, session.user_name);
                logWrite("user", "info", "User got MFA by e-mail after login. [E-Mail: #session.user_email#]");
                location url="#objSendMfa.redirect#" addtoken="false";
            }

            // Let's check whether there is a file we have to include coming from modules
            filesToInlude = application.objGlobal.getLoginIncludes(session.customer_id);
            if (!arrayIsEmpty(filesToInlude)) {
                loop array=filesToInlude item="path" {
                    include template=path;
                }
            }

            structDelete(session, "alert");
            logWrite("user", "info", "Login successfull [CustomerID: #session.customer_id#, UserID: #session.user_id#, E-Mail: #session.user_email#]");
            location url="#objUserLogin.redirect#" addtoken="false";



        } else {

            // Is the user active?
            if (structKeyExists(objUserLogin, "active") and !objUserLogin.active) {
                getAlert('msgAccountDisabledByAdmin', 'warning');
                logWrite("user", "warning", "User tried to login but account is not active [E-mail: #form.email#]");
                location url="#application.mainURL#/login" addtoken="false";
            } else {
                getAlert('alertWrongLogin', 'warning');
                logWrite("user", "warning", "Unsuccessful login try [E-mail: #form.email#]");
                location url="#application.mainURL#/login" addtoken="false";
            }

        }



    } else {

        getAlert('alertErrorOccured', 'danger');
        logWrite("system", "error", "Error on login try!", true);
        location url="#application.mainURL#/login" addtoken="false";

    }

}

// Register new user step 1
if (structKeyExists(form, 'register_btn')) {

    // Google ReCaptcha
    if (len(trim(variables.reCAPTCHA_site_key))) {

        captchaSuccess = false;

        if (StructKeyExists(form, "g-recaptcha-response")) {

            isValid = objRegister.verifyGoogleToken(form["g-recaptcha-response"], variables.reCAPTCHA_secret);

            if (isValid) {

                captchaSuccess = true;

            }

        }

        if (!captchaSuccess) {

            getAlert('msgCaptchaFailed', 'warning');
            logWrite("user", "warning", "Captcha verification failed [E-Mail: #form.email#]");
            location url="#application.mainURL#/register" addtoken="false";

        }

    }

    param name="form.first_name" default="";
    param name="form.name" default="";
    param name="form.company" default="";
    param name="form.email" default="";
    param name="form.language" default="";

    session.first_name = form.first_name;
    session.name = form.name;
    session.company = form.company;
    session.email = form.email;
    session.lng = form.language;

    checkEmail = application.objGlobal.checkEmail(form.email);

    if (checkEmail) {

        // Check for already registered email
        qCheckDouble = queryExecute(
            options = {datasource = application.datasource},
            params = {
                strEmail = {type: "nvarchar", value: form.email}
            },
            sql = "
                SELECT intUserID
                FROM users
                WHERE strEmail = :strEmail
            "
        );

        if (qCheckDouble.recordCount) {
            getAlert('alertHasAccountAlready', 'warning');
            logWrite("user", "warning", "Register new user step 1: E-Mail already registered [E-Mail: #form.email#]");
            location url="#application.mainURL#/login" addtoken="false";
        }

        newUUID = application.objGlobal.getUUID();

        optinValues = structNew();
        optinValues.first_name = form.first_name;
        optinValues.name = form.name;
        optinValues.company = form.company;
        optinValues.email = form.email;
        optinValues.language = form.language;
        optinValues.newUUID = newUUID;

        // Save the customer into the temporary table optin
        objUserRegister1 = objRegister.insertOptin(optinValues);

        if (objUserRegister1.success) {

            mailTitle = "#getTrans('subjectConfirmEmail')#";
            mailType = "html";

            cfsavecontent (variable = "mailContent") {

                echo("
                    #getTrans('titHello')# #form.first_name# #form.name#<br><br>
                    #getTrans('txtPleaseConfirmEmail')#<br><br>
                    <a href='#application.mainURL#/logincheck?u=#newUUID#' style='border-bottom: 10px solid ##337ab7; border-top: 10px solid ##337ab7; border-left: 20px solid ##337ab7; border-right: 20px solid ##337ab7; background-color: ##337ab7; color: ##ffffff; text-decoration: none;' target='_blank'>#getTrans('btnActivate')#</a>
                    <br><br>
                    #getTrans('txtRegards')#<br>
                    #getTrans('txtYourTeam')#<br>
                    #application.appOwner#
                ");
            }

            // Send double opt-in mail
            mail to="#form.email#" from="#application.fromEmail#" subject="#getTrans('subjectConfirmEmail')#" type="html" {
                include template="/frontend/core/mail_design.cfm";
            }

            structDelete(session, "first_name");
            structDelete(session, "name");
            structDelete(session, "company");
            structDelete(session, "email");

            getAlert('alertOptinSent', 'info');
            logWrite("user", "info", "Register new user step 1: Opt-in e-mail sent [E-Mail: #form.email#]");
            location url="#application.mainURL#/login" addtoken="false";

        } else {

            getAlert(objUserRegister1.message, 'danger');
            logWrite("system", "error", "Register new user step 1: Registration failed [E-Mail: #form.email#, Error: #objUserRegister1.message#]");
            location url="#application.mainURL#/register" addtoken="false";

        }

    } else {

        getAlert('alertEnterEmail', 'warning');
        logWrite("user", "warning", "Register new user step 1: Could not register, wrong email format. [E-Mail: #form.email#]");
        location url="#application.mainURL#/register" addtoken="false";

    }

}

// Coming from double opt-in mail (also for new users added by the admin)
if (structKeyExists(url, 'u') and len(trim(url.u)) eq 64) {

    qCheckOptin = queryExecute(

        options = {datasource = application.datasource},
        params = {
           strUUID: {type: "nvarchar", value: url.u}
        },
        sql = "
            SELECT strUUID, strLanguage
            FROM optin
            WHERE strUUID = :strUUID
        "
    )

    if (qCheckOptin.recordCount) {

        session.step = 2;
        session.uuid = qCheckOptin.strUUID;
        session.lng = qCheckOptin.strLanguage;
        getAlert('alertChoosePassword', 'info');
        logWrite("user", "info", "Register new user step 2: A user has confirmed the opt-in e-mail. [UUID: #url.u#]");

    } else {

        // Check whether its added by admin
        qCheckUser = queryExecute(

            options = {datasource = application.datasource},
            params = {
                strUUID: {type: "nvarchar", value: url.u}
            },
            sql = "
                SELECT strUUID, strLanguage
                FROM users
                WHERE strUUID = :strUUID
            "
        )

        if (qCheckUser.recordCount) {

            session.step = 2;
            session.uuid = qCheckUser.strUUID;
            session.lng = qCheckUser.strLanguage;
            getAlert('alertChoosePassword', 'info');
            logWrite("user", "info", "Register new user step 2: A user invited by the administrator has confirmed the opt-in email. [UUID: #url.u#]");

        } else {

            session.step = 1;
            getAlert('alertNotValidAnymore', 'warning');
            logWrite("user", "warning", "Register new user step 2: Opt-in e-mail not valid anymore. [UUID: #url.u#]");

        }

    }

    location url="#application.mainURL#/register" addtoken="false";

}

// Register new user step 3 (create account)
if (structKeyExists(form, 'create_account')) {

    param name="form.password" default="";
    param name="form.password2" default="";

    // Check passwords first
    if (len(trim(form.password)) and len(trim(form.password2))) {
        if (not trim(form.password) eq trim(form.password2)) {
            session.step = 2;
            getAlert('alertPasswordsNotSame', 'warning');
            logWrite("user", "warning", "Register new user step 3: The passwords don't match");
            location url="#application.mainURL#/register" addtoken="false";
        }
    } else {
        session.step = 2;
        getAlert('alertChoosePassword', 'warning');
        logWrite("user", "warning", "Register new user step 3: The password fields are empty");
        location url="#application.mainURL#/register" addtoken="false";
    }

    // Is there a valid uuid?
    if (structKeyExists(session, "uuid")) {

        // Is there a valid registration?
        qCheckOptin = queryExecute(

            options = {datasource = application.datasource},
            params = {
                strUUID: {type: "nvarchar", value: session.uuid}
            },
            sql = "
                SELECT *
                FROM optin
                WHERE strUUID = :strUUID
            "
        )

        if (qCheckOptin.recordCount) {

            customerStruct = QueryRowData(qCheckOptin, 1);

            // Hash and salt the password
            hashedStruct = application.objGlobal.generateHash(form.password);
            StructInsert(customerStruct, "hash", hashedStruct.thisHash);
            StructInsert(customerStruct, "salt", hashedStruct.thisSalt);

            // Save the customer into the db
            insertCustomer = objRegister.insertCustomer(customerStruct);

            if (insertCustomer.success) {

                structDelete(session, "step");
                structDelete(session, "first_name");
                structDelete(session, "name");
                structDelete(session, "company");
                structDelete(session, "uuid");

                getAlert('alertAccountCreatedLogin', 'success');
                logWrite("user", "info", "Register new user step 3: Account created [E-Mail: #qCheckOptin.strEmail#]");
                location url="#application.mainURL#/login" addtoken="false";

            } else {

                session.step = 1;
                getAlert(insertCustomer.message, 'danger');
                logWrite("system", "error", "Register new user step 3: Could not create account [E-Mail: #qCheckOptin.strEmail#, Error: #insertCustomer.message#]");
                location url="#application.mainURL#/register" addtoken="false";

            }

        } else {


            // Check whether its added by admin
            qCheckUser = queryExecute(

                options = {datasource = application.datasource},
                params = {
                    strUUID: {type: "nvarchar", value: session.uuid}
                },
                sql = "
                    SELECT strUUID
                    FROM users
                    WHERE strUUID = :strUUID
                "
            )

            if (qCheckUser.recordCount) {

                // Update password and send to login
                setNewPassword = application.objUser.changePassword(form.password, qCheckUser.strUUID);

                if (setNewPassword.success) {

                    getAlert('alertAccountCreatedLogin', 'success');
                    logWrite("user", "info", "Register new user step 3: A user invited by the administrator has set the password. [UUID: #qCheckUser.strUUID#]");
                    location url="#application.mainURL#/login" addtoken="false";

                } else {

                    session.step = 1;
                    getAlert('alertNotValidAnymore', 'warning');
                    logWrite("user", "warning", "Register new user step 3: A user invited by the administrator couldn't set the password, because the opt-in e-mail wasn't valid anymore. [UUID: #qCheckUser.strUUID#]");
                    location url="#application.mainURL#/register" addtoken="false";

                }


            }

            session.step = 1;
            getAlert('alertNotValidAnymore', 'warning');
            logWrite("user", "warning", "Register new user step 3: A user couldn't set the password, because the opt-in e-mail wasn't valid anymore. [UUID: #session.uuid#]");
            location url="#application.mainURL#/register" addtoken="false";

        }

    } else {

        session.step = 1;
        getAlert('alertNotValidAnymore', 'warning');
        logWrite("user", "warning", "Register new user step 3: A user couldn't set the password, because the opt-in e-mail wasn't valid anymore. [UUID: none]");
        location url="#application.mainURL#/register" addtoken="false";

    }

}

// Reset the password step 1
if (structKeyExists(form, "reset_pw_btn_1")) {

    param name="form.email" default="";

    qCheckUser = queryExecute(
        options = {datasource = application.datasource},
        params = {
            email: {type: "nvarchar", value: form.email}
        },
        sql="
            SELECT intUserID, strFirstName, strLastName, strEmail
            FROM users
            WHERE strEmail = :email AND blnActive = 1
        "
    );

    if (qCheckUser.recordCount) {

        newUUID = application.objGlobal.getUUID();

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                strUUID: {type: "nvarchar", value: newUUID},
                intUserID: {type: "numeric", value: qCheckUser.intUserID}
            },
            sql="
                UPDATE users
                SET strUUID = :strUUID
                WHERE intUserID = :intUserID
            "
        );


        variables.mailTitle = getTrans('titResetPassword');
        variables.mailType = "html";

        cfsavecontent (variable = "variables.mailContent") {

            echo("
                #getTrans('titHello')# #qCheckUser.strFirstName# #qCheckUser.strLastName#<br><br>
                #getTrans('txtResetPassword')#
                <br><br>
                <a href='#application.mainURL#/logincheck?p=#newUUID#'style='border-bottom: 10px solid ##337ab7; border-top: 10px solid ##337ab7; border-left: 20px solid ##337ab7; border-right: 20px solid ##337ab7; background-color: ##337ab7; color: ##ffffff; text-decoration: none;' target='_blank'>#getTrans('titResetPassword')#</a>

                <br><br>
                #getTrans('txtRegards')#<br>
                #getTrans('txtYourTeam')#<br>
                #application.appOwner#
            ");
        }

        // Send email to reset the password
        mail from="#application.fromEmail#" to="#form.email#" subject="#getTrans('titResetPassword')#" type="html" {
            include template="/frontend/core/mail_design.cfm";
        }

        logWrite("user", "info", "Reset password: E-mail sent in order to reset the password. [E-Mail: #form.email#]");

    } else {

        logWrite("user", "warning", "Reset password: No account found with this e-mail address. [E-Mail: #form.email#]");

    }

    getAlert('alertIfAccountFoundEmail', 'info');
    location url="#application.mainURL#/login" addtoken="false";

}

// Confirm the password reset
if (structKeyExists(url, "p")) {

    // Is the link valid?
    qCheckUUID = queryExecute(
        options = {datasource = application.datasource},
        params = {
            strUUID: {type: "nvarchar", value: url.p}
        },
        sql="
            SELECT intUserID
            FROM users
            WHERE strUUID = :strUUID
        "
    );

    if (qCheckUUID.recordCount) {

        getAlert('alertChoosePassword', 'info');
        logWrite("user", "info", "The user has clicked the link to reset the password. The link was valid. [UserID: #qCheckUUID.intUserID#, UUID: #url.p#]");
        session.step = 2;
        session.uuid = url.p;
        location url="#application.mainURL#/password" addtoken="false";

    } else {

        getAlert('alertNotValidAnymore', 'warning');
        logWrite("user", "warning", "The user has clicked the link to reset the password. The link was not valid anymore. [UserID: #qCheckUUID.intUserID#, UUID: #url.p#]");
        location url="#application.mainURL#/password" addtoken="false";

    }

}

// Reset password now
if (structKeyExists(form, "reset_pw_btn_2")) {

    param name="form.password" default="";
    param name="form.password2" default="";
    param name="thisResetUUID" default="0";


    // Check the uuid session
    if (structKeyExists(session, "uuid") and len(trim(session.uuid))) {
        thisResetUUID = session.uuid;
    } else {
        getAlert('alertNotValidAnymore', 'warning');
        logWrite("user", "warning", "Reset password: The user tried to reset the password, but the session has expired.");
        location url="#application.mainURL#/password" addtoken="false";
    }

    // Check passwords first
    if (len(trim(form.password)) and len(trim(form.password2))) {

        if (not form.password eq form.password2) {
            getAlert('alertPasswordsNotSame', 'warning');
            logWrite("user", "warning", "Reset password: The user tried to reset the password, but the passwords don't match. [UUID: #thisResetUUID#]");
            location url="#application.mainURL#/password" addtoken="false";
        }

    } else {

        getAlert('alertChoosePassword', 'warning');
        logWrite("user", "warning", "Reset password: The user tried to reset the password, but the password fields are empty. [UUID: #thisResetUUID#]");
        location url="#application.mainURL#/password" addtoken="false";

    }


    // save password using a function
    changePassword = application.objUser.changePassword(form.password, thisResetUUID);

    if (changePassword.success) {

        structDelete(session, "step");

        // delete the uuid of the user
        queryExecute(
            options = {datasource = application.datasource},
            params = {
                strUUID: {type: "nvarchar", value: thisResetUUID}
            },
            sql="
                UPDATE users
                SET strUUID = ''
                WHERE strUUID = :strUUID
            "
        );

        getAlert('alertPasswordResetSuccess', 'success');
        logWrite("user", "info", "Reset password: The user has successfully reset the password [UUID: #thisResetUUID#]");
        location url="#application.mainURL#/login" addtoken="false";

    } else {

        getAlert(changePassword.message, 'danger');
        logWrite("system", "error", "Reset password: Could not reset the password [UUID: #thisResetUUID#, Error: #changePassword.message#]");
        location url="#application.mainURL#/password" addtoken="false";

    }

}

if (structKeyExists(form, 'mfa_btn')) {

    param name="form.mfa_1" default=0;
    param name="form.mfa_2" default=0;
    param name="form.mfa_3" default=0;
    param name="form.mfa_4" default=0;
    param name="form.mfa_5" default=0;
    param name="form.mfa_6" default=0;

    mfa_1 = isNumeric(form.mfa_1) ? toString(form.mfa_1) : 0;
    mfa_2 = isNumeric(form.mfa_2) ? toString(form.mfa_2) : 0;
    mfa_3 = isNumeric(form.mfa_3) ? toString(form.mfa_3) : 0;
    mfa_4 = isNumeric(form.mfa_4) ? toString(form.mfa_4) : 0;
    mfa_5 = isNumeric(form.mfa_5) ? toString(form.mfa_5) : 0;
    mfa_6 = isNumeric(form.mfa_6) ? toString(form.mfa_6) : 0;

    mfaCodes = toNumeric(mfa_1 & mfa_2 & mfa_3 & mfa_4 & mfa_5 & mfa_6);
    checkMfa = application.objUser.checkMfa(url.uuid, mfaCodes);

    if (checkMfa.success eq true) {

        session.user_id = checkMfa.userid;
        logWrite("user", "info", "Login via MFA: User successfully logged in with multi-factor-authentication. [UserID: #checkMfa.userid#]");

        // Is the needed data of the cutomer already filled out?
        dataFilledIn = objRegister.checkFilledData(session.customer_id);
        if (!dataFilledIn) {
            session.filledData = false;
        }

        // Let's check whether there is a file we have to include coming from modules
        filesToInlude = application.objGlobal.getLoginIncludes(session.customer_id);
        if (!arrayIsEmpty(filesToInlude)) {
            loop array=filesToInlude item="path" {
                include template=path;
            }
        }

        location url="#application.mainURL#/dashboard" addtoken="false";

    } else {

        if (structKeyExists(session, "mfaCheckCount") and session.mfaCheckCount eq 3) {
            getAlert(getTrans('txtThreeTimeTry'), 'warning');
            logWrite("user", "warning", "Login via MFA: The user tried 3 times without success. [UUID: #url.uuid#]");
        } else {
            getAlert(checkMfa.message, 'warning');
            param name="session.mfaCheckCount" default="0";
            setLogCount = session.mfaCheckCount+1;
            logWrite("user", "warning", "Login via MFA: #setLogCount#. try to authenticate with the code [UUID: #url.uuid#]");
            session.mfaCheckCount++;
        }

        location url="#application.mainURL#/mfa?uuid=#checkMfa.uuid#" addtoken="false";

    }

}

if (structKeyExists(url, 'resend')) {

    structDelete(session, 'user_id');
    objUserMfa = application.objUser.sendMfaCode(url.uuid, url.resend, session.user_email, session.user_name);

    if (objUserMfa.success eq true) {

        getAlert(objUserMfa.message, 'success');
        logWrite("user", "warning", "Login via MFA: New MFA code send to the user [E-Mail: #session.user_email#, UUID: #url.uuid#]");
        session.mfaCheckCount = 0;
        location url="#application.mainURL#/mfa?uuid=#url.uuid#" addtoken="false";

    }
}

// Logout and delete all sessions
if (structKeyExists(url, "logout")) {

    logWrite("user", "info", "User has logged out [CustomerID: #session.customer_id#, UserID: #session.user_id#]");

    structClear(SESSION);
    onSessionStart();

    location url="#application.mainURL#/login?logout" addtoken="no";
}

logWrite("user", "warning", "Access attempt to frontend/core/handler/register.cfm without method");
location url="#application.mainURL#/dashboard" addtoken="false";

</cfscript>