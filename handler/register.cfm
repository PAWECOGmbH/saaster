
<cfscript>

objRegister = new com.register();

<!--- Register new user step 1 --->
if (structKeyExists(form, 'register_btn')) {

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

        <!--- Check for already registered email --->
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

        <!--- Save the customer into the temporary table optin --->
        objUserRegister1 = objRegister.insertOptin(optinValues);

        if (isNumeric(objUserRegister1) and objUserRegister1 gt 0) {

            mailTitle = "#getTrans('subjectConfirmEmail')#";
            mailType = "html";
            mailCustomerID = 1;

            cfsavecontent (variable = "mailContent") {

                echo("
                    #getTrans('titHello')# #form.first_name# #form.name#<br><br>
                    #getTrans('txtPleaseConfirmEmail')#<br><br>
                    <a href='#application.mainURL#/registration?u=#newUUID#' style='border-bottom: 10px solid ##337ab7; border-top: 10px solid ##337ab7; border-left: 20px solid ##337ab7; border-right: 20px solid ##337ab7; background-color: ##337ab7; color: ##ffffff; text-decoration: none;' target='_blank'>#getTrans('btnActivate')#</a>
                    <br><br>
                    #getTrans('txtRegards')#<br>
                    #getTrans('txtYourTeam')#<br>
                    #application.appOwner#
                ");
            }

            <!--- Send double opt-in mail --->
            mail to="#form.email#" from="#application.fromEmail#" subject="#getTrans('subjectConfirmEmail')#" type="html" {
                include "/includes/mail_design.cfm";
            }

            structDelete(session, "first_name");
            structDelete(session, "name");
            structDelete(session, "company");
            structDelete(session, "email");

            getAlert('alertOptinSent', 'info');
            location url="#application.mainURL#/login" addtoken="false";

        } else {

            getAlert('alertErrorOccured', 'danger');
            location url="#application.mainURL#/register" addtoken="false";

        }

    } else {

        getAlert('alertEnterEmail', 'warning');
        location url="#application.mainURL#/register" addtoken="false";

    }

}


<!--- Coming from double opt-in mail (also for new users added by the admin) --->
if (structKeyExists(url, 'u') and len(trim(url.u)) eq 64) {

    qCheckOptin = queryExecute(

        options = {datasource = application.datasource},
        params = {
           strUUID: {type: "nvarchar", value: url.u}
        },
        sql = "
            SELECT strUUID
            FROM optin
            WHERE strUUID = :strUUID
        "
    )

    if (qCheckOptin.recordCount) {

        session.step = 2;
        session.uuid = qCheckOptin.strUUID;
        getAlert('alertChoosePassword', 'info');

    } else {

        <!--- Check whether its added by admin --->
        qCheckUser = queryExecute(

            options = {datasource = application.datasource},
            params = {
                strUUID: {type: "nvarchar", value: url.u}
            },
            sql = "
                SELECT strUUID
                FROM users
                WHERE strUUID = :strUUID
            "
        )

        if (qCheckUser.recordCount) {

            session.step = 2;
            session.uuid = qCheckUser.strUUID;
            getAlert('alertChoosePassword', 'info');

        } else {

            session.step = 1;
            getAlert('alertNotValidAnymore', 'warning');

        }

    }

    location url="#application.mainURL#/register" addtoken="false";

}


<!--- Register new user step 3 (create account) --->
if (structKeyExists(form, 'create_account')) {

    param name="form.password" default="";
    param name="form.password2" default="";

    <!--- Check passwords first --->
    if (len(trim(form.password)) and len(trim(form.password2))) {
        if (not trim(form.password) eq trim(form.password2)) {
            session.step = 2;
            getAlert('alertPasswordsNotSame', 'warning');
            location url="#application.mainURL#/register" addtoken="false";
        }
    } else {
        session.step = 2;
        getAlert('alertChoosePassword', 'warning');
        location url="#application.mainURL#/register" addtoken="false";
    }

    <!--- Is there a valid uuid? --->
    if (structKeyExists(session, "uuid")) {

        <!--- Is there a valid registration? --->
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

            <!--- Hash and salt the password --->
            hashedStruct = application.objGlobal.generateHash(form.password);
            StructInsert(customerStruct, "hash", hashedStruct.thisHash);
            StructInsert(customerStruct, "salt", hashedStruct.thisSalt);

            <!--- Save the customer into the db --->
            insertCustomer = new com.register().insertCustomer(customerStruct);

            if (insertCustomer.success) {

                structDelete(session, "step");
                structDelete(session, "first_name");
                structDelete(session, "name");
                structDelete(session, "company");
                structDelete(session, "uuid");

                getAlert('alertAccountCreatedLogin', 'success');
                location url="#application.mainURL#/login" addtoken="false";

            } else {

                session.step = 1;
                getAlert(insertCustomer.message, 'danger');
                location url="#application.mainURL#/register" addtoken="false";

            }

        } else {


            <!--- Check whether its added by admin --->
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

                <!--- Update password and send to login --->
                setNewPassword = application.objUser.changePassword(form.password, qCheckUser.strUUID);

                if (setNewPassword.success) {

                    getAlert('alertAccountCreatedLogin', 'success');
                    location url="#application.mainURL#/login" addtoken="false";

                } else {

                    session.step = 1;
                    getAlert('alertNotValidAnymore', 'warning');
                    location url="#application.mainURL#/register" addtoken="false";

                }


            }

            session.step = 1;
            getAlert('alertNotValidAnymore', 'warning');
            location url="#application.mainURL#/register" addtoken="false";

        }

    } else {

        session.step = 1;
        getAlert('alertNotValidAnymore', 'warning');
        location url="#application.mainURL#/register" addtoken="false";

    }

}

<!--- Check login --->
if (structKeyExists(form, 'login_btn')) {

    param name="form.email" default="";
    param name="form.password" default="";

    objUserLogin = application.objUser.checkLogin(argumentCollection = form);

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

            <!--- Inheritance --->
            if (session.sysadmin) {
                session.admin = true;
                session.superadmin = true;
            } else if (session.superadmin) {
                session.admin = true;
            }

            <!--- Save current plan into a session --->
            checkPlan = new com.plans(language=session.lng).getCurrentPlan(session.customer_id);
            session.currentPlan = checkPlan;

            <!--- Save current modules into a session --->
            checkModules = new com.modules(language=session.lng).getBookedModules(session.customer_id);
            session.currentModules = checkModules;

            <!--- Save custom settings struct into a session --->
            session.customSettings = application.objGlobal.getCustomSettings(session.customer_id);

            <!--- Is the needed data of the cutomer already filled out? --->
            dataFilledIn = objRegister.checkFilledData(session.customer_id);

            if (!dataFilledIn) {
                session.filledData = false;
            }

            location url="#objUserLogin.redirect#" addtoken="false";


        } else {

            <!--- Is the user active? --->
            if (structKeyExists(objUserLogin, "active") and !objUserLogin.active) {
                getAlert('msgAccountDisabledByAdmin', 'warning');
                location url="#application.mainURL#/login" addtoken="false";
            } else {
                getAlert('alertWrongLogin', 'warning');
                location url="#application.mainURL#/login" addtoken="false";
            }

        }

    } else {

        getAlert('alertErrorOccured', 'danger');
        location url="#application.mainURL#/login" addtoken="false";

    }

}




<!--- Reset the password step 1 --->
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
        variables.mailCustomerID = application.objCustomer.getUserDataByID(qCheckUser.intUserID).intCustomerID;

        cfsavecontent (variable = "variables.mailContent") {

            echo("
                #getTrans('titHello')# #qCheckUser.strFirstName# #qCheckUser.strLastName#<br><br>
                #getTrans('txtResetPassword')#
                <br><br>
                <a href='#application.mainURL#/registration?p=#newUUID#'style='border-bottom: 10px solid ##337ab7; border-top: 10px solid ##337ab7; border-left: 20px solid ##337ab7; border-right: 20px solid ##337ab7; background-color: ##337ab7; color: ##ffffff; text-decoration: none;' target='_blank'>#getTrans('formPassword2')#</a>

                <br><br>
                #getTrans('txtRegards')#<br>
                #getTrans('txtYourTeam')#<br>
                #application.appOwner#
            ");
        }

        <!--- Send email to reset the password --->
        mail from="#application.fromEmail#" to="#form.email#" subject="#getTrans('titResetPassword')#" type="html" {
            include "/includes/mail_design.cfm";
        }

    }

    getAlert('alertIfAccountFoundEmail', 'info');
    location url="#application.mainURL#/login" addtoken="false";

}


<!--- Confirm the password reset --->
if (structKeyExists(url, "p")) {

    <!--- Is the link valid? --->
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
        session.step = 2;
        session.uuid = url.p;
        location url="#application.mainURL#/password" addtoken="false";

    } else {

        getAlert('alertNotValidAnymore', 'warning');
        location url="#application.mainURL#/password" addtoken="false";

    }

}


<!--- Reset password now --->
if (structKeyExists(form, "reset_pw_btn_2")) {

    param name="form.password" default="";
    param name="form.password2" default="";
    param name="thisResetUUID" default="0";


    <!--- Check the uuid session --->
    if (structKeyExists(session, "uuid") and len(trim(session.uuid))) {
        thisResetUUID = session.uuid;
    } else {
        getAlert('alertNotValidAnymore', 'warning');
        location url="#application.mainURL#/password" addtoken="false";
    }

    <!--- Check passwords first --->
    if (len(trim(form.password)) and len(trim(form.password2))) {

        if (not form.password eq form.password2) {
            getAlert('alertPasswordsNotSame', 'warning');
            location url="#application.mainURL#/password" addtoken="false";
        }

    } else {

        getAlert('alertChoosePassword', 'warning');
        location url="#application.mainURL#/password" addtoken="false";

    }


    <!--- save password using a function --->
    changePassword = application.objUser.changePassword(form.password, thisResetUUID);

    if (changePassword.success) {

        structDelete(session, "step");

        <!--- delete the uuid of the user --->
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
        location url="#application.mainURL#/login" addtoken="false";

    } else {
        getAlert(changePassword.message, 'danger');
        location url="#application.mainURL#/password" addtoken="false";
    }

}



</cfscript>