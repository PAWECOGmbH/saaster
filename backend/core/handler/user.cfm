<cfscript>

// User edit
if (structKeyExists(form, "edit_profile_btn")) {

    param name="form.salutation" default="";
    param name="form.first_name" default="";
    param name="form.last_name" default="";
    param name="form.email" default="";
    param name="form.language" default="";
    param name="form.phone" default="";
    param name="form.mobile" default="";
    param name="form.tenantID" default="";
    param name="form.admin" default="0";
    param name="form.superadmin" default="0";
    param name="form.active" default="0";
    param name="form.tenantID" default="";
    param name="form.mfa" default="0";
    param name="thisUserID" default="#session.user_id#";
    param name="thisCustomerID" default="#session.customer_id#";
    param name="thisReferer" default="my-profile";

    if (structKeyExists(form, "userID")) {
        thisUserID = form.userID;
        thisReferer = "user/edit/#thisUserID#";
    }
    if (structKeyExists(form, "customerID")) {
        thisCustomerID = form.customerID;
    }
    if (form.admin eq 1 or form.admin eq "on") {
        form.admin = 1;
    } else {
        form.admin = 0;
    }
    if (form.superadmin eq 1 or form.superadmin eq "on") {
        form.superadmin = 1;
        form.admin = 1;
    } else {
        form.superadmin = 0;
    }
    if (form.active eq 1 or form.active eq "on") {
        form.active = 1;
    } else {
        form.active = 0;
    }

    if (form.mfa eq 1 or form.mfa eq "on") {
        form.mfa = 1;
    } else {
        form.mfa = 0;
    }

    // Check whether the email is valid
    checkEmail = application.objGlobal.checkEmail(form.email);

    if (!checkEmail) {
        getAlert('alertEnterEmail', 'warning');
        logWrite("user", "warning", "User edit: wrong email format. [CustomerID: #session.customer_id#, UserID: #session.user_id#, E-Mail: #form.email#]");
        location url="#application.mainURL#/account-settings/#thisReferer#" addtoken="false";
    }

    // Check for already registered email
    qCheckDouble = queryExecute(
        options = {datasource = application.datasource},
        params = {
            strEmail: {type: "nvarchar", value: form.email},
            intCustomerID: {type: "numeric", value: thisCustomerID},
            intUserID: {type: "numeric", value: thisUserID}
        },
        sql = "
            SELECT intUserID
            FROM users
            WHERE strEmail = :strEmail
            AND intCustomerID = :intCustomerID
            AND intUserID <> :intUserID
        "
    )

    if (qCheckDouble.recordCount) {
        getAlert('alertEmailAlreadyUsed', 'warning');
        structDelete(session, "email");
        logWrite("user", "warning", "User edit: E-Mail is already in use. [CustomerID: #session.customer_id#, UserID: #session.user_id#, E-Mail: #form.email#]");
        location url="#application.mainURL#/account-settings/#thisReferer#" addtoken="false";
    }

    // Check if the email is changed
    if (thisReferer eq 'my-profile') {
        mailconfirm = application.objUser.mailChangeConfirm(form.email, thisUserID);
    } else {
        mailconfirm = false
    }

    // Save the user using a function
    objUserEdit = application.objUser.updateUser(form, thisUserID, mailconfirm);

    if (objUserEdit.success) {
        getAlert('msgChangesSaved', 'success');
        logWrite("user", "info", "User changes saved. [CustomerID: #session.customer_id#, UserID: #session.user_id#]");
        if (thisReferer eq "my-profile"){
            session.user_name = form.first_name & " " & form.last_name;
        }
    } else {
        getAlert(objUserEdit.message, 'danger');
        logWrite("system", "error", "User could not be saved. [CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: #objUserEdit.message#]");
    }

    if (thisReferer eq "my-profile") {
        location url="#application.mainURL#/account-settings/#thisReferer#?l=#form.language#" addtoken="false";
    } else {
        location url="#application.mainURL#/account-settings/#thisReferer#" addtoken="false";
    }

}



// User new
if (structKeyExists(form, "user_new_btn")) {

    param name="form.salutation" default="";
    param name="form.first_name" default="";
    param name="form.last_name" default="";
    param name="form.email" default="";
    param name="form.phone" default="";
    param name="form.mobile" default="";
    param name="form.admin" default="0";
    param name="form.superadmin" default="0";
    param name="form.sysadmin" default="0";
    param name="form.active" default="0";
    param name="form.language" default=session.lng;

    if (form.admin eq 1 or form.admin eq "on") {
        form.admin = 1;
    } else {
        form.admin = 0;
    }
    if (form.superadmin eq 1 or form.superadmin eq "on") {
        form.superadmin = 1;
    } else {
        form.superadmin = 0;
    }
    if (form.active eq 1 or form.active eq "on") {
        form.active = 1;
    } else {
        form.active = 0;
    }
    if (form.sysadmin eq 1 or form.sysadmin eq "on") {
        form.sysadmin = 1;
    } else {
        form.sysadmin = 0;
    }

    session.salutation = form.salutation;
    session.first_name = form.first_name;
    session.last_name = form.last_name;
    session.email = form.email;
    session.phone = form.phone;
    session.mobile = form.mobile;

    // Check whether the email is valid
    checkEmail = application.objGlobal.checkEmail(form.email);

    if (!checkEmail) {
        getAlert('alertEnterEmail', 'warning');
        logWrite("user", "warning", "User new: wrong email format. [CustomerID: #session.customer_id#, UserID: #session.user_id#, E-Mail: #form.email#]");
        location url="#application.mainURL#/account-settings/user/new" addtoken="false";
    }

    // Email address already used?
    qCheckEmail = queryExecute(
        options = {datasource = application.datasource},
        params = {
            customerID: {type: "numeric", value: session.customer_id},
            thisEmail: {type: "nvarchar", value: form.email}
        },
        sql="
            SELECT intUserID
            FROM users
            WHERE strEmail = :thisEmail
        "
    )
    if (qCheckEmail.recordCount) {
        getAlert('alertEmailAlreadyUsed', 'warning');
        logWrite("user", "warning", "User new: E-Mail is already in use. [CustomerID: #session.customer_id#, UserID: #session.user_id#, E-Mail: #form.email#]");
        location url="#application.mainURL#/account-settings/user/new" addtoken="false";
    }

    // Save the user using a function
    objUserInsert = application.objUser.insertUser(form, session.customer_id);

    if (objUserInsert.success) {

        // Send the invitation link using a function
        objInvitation = application.objUser.sendInvitation(objUserInsert.newUserID, session.user_id);

        // Clear sessions
        structDelete(session, "salutation");
        structDelete(session, "first_name");
        structDelete(session, "last_name");
        structDelete(session, "email");
        structDelete(session, "phone");
        structDelete(session, "mobile");

        getAlert('alertNewUserCreated', 'success');
        logWrite("user", "info", "User added with ID #objUserInsert.newUserID# [CustomerID: #session.customer_id#, UserID: #session.user_id#]");

    } else {

        getAlert(objUserInsert.message, 'danger');
        logWrite("system", "error", "User could not be saved [CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: #objUserInsert.message#]");

    }

    location url="#application.mainURL#/account-settings/users" addtoken="false";

}


// Photo upload
if (structKeyExists(form, "photo_upload_btn")) {

    fileStruct = structNew();
    fileStruct.filePath = expandPath('/userdata/images/users'); //absolute path
    fileStruct.maxSize = "500"; // empty or kb
    fileStruct.maxWidth = "500"; // empty or pixels
    fileStruct.maxHeight = ""; // empty or pixels
    fileStruct.makeUnique = true; // true or false (default true)
    fileStruct.fileName = lcase(replace(createUUID(),"-", "", "all")); // empty or any name; ex. uuid (without extension)

    if (structKeyExists(form, "photo") and len(trim(form.photo))) {

        fileStruct.fileNameOrig = form.photo;

        // Check if file is a valid image
        try {
            ImageRead(ExpandPath("#fileStruct.fileNameOrig#"));
        }
        catch("java.io.IOException" e){
            getAlert( "msgFileUploadError", 'danger');
            logWrite("system", "error", "Photo could not be uploaded [CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: msgFileUploadError]");
            location url="#application.mainURL#/account-settings/my-profile" addtoken="false";
        }
        catch(any e){
            getAlert( e.message, 'danger');
            logWrite("system", "error", "Photo could not be uploaded [CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: #e.message#]");
            location url="#application.mainURL#/account-settings/my-profile" addtoken="false";
        }

        // Sending the data into a function
        fileUpload = application.objGlobal.uploadFile(fileStruct, variables.imageFileTypes);

        if (fileUpload.success) {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    userID: {type: "numeric", value: session.user_id},
                    thisPhoto: {type: "nvarchar", value: fileUpload.fileName}
                },
                sql = "
                    UPDATE users
                    SET strPhoto = :thisPhoto
                    WHERE intUserID = :userID
                "
            )

            getAlert('msgFileUploadedSuccessfully', 'success');
            logWrite("user", "info", "Photo uploaded [CustomerID: #session.customer_id#, UserID: #session.user_id#, Filename: #fileUpload.fileName#]");

        } else {

            getAlert(fileUpload.message, 'danger');
            logWrite("system", "error", "Photo could not be uploaded [CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: #fileUpload.message#]");

        }

    } else {

        getAlert('msgPleaseChooseFile', 'warning');
        logWrite("user", "warning", "User did not choose a file for photo upload [CustomerID: #session.customer_id#, UserID: #session.user_id#]");

    }

    location url="#application.mainURL#/account-settings/my-profile" addtoken="false";

}


// Delete photo
if (structKeyExists(url, "del_photo")) {

    qPhoto = queryExecute(
        options = {datasource = application.datasource},
        params = {
            userID: {type: "numeric", value: session.user_id}
        },
        sql="
            SELECT strPhoto
            FROM users
            WHERE intUserID = :userID
        "
    )

    if (qPhoto.recordCount and len(trim(qPhoto.strPhoto))) {

        // Delete photo using a function
        application.objGlobal.deleteFile(expandPath("/userdata/images/users/#qPhoto.strPhoto#"));

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                intUserID: {type: "numeric", value: session.user_id}
            },
            sql="
                UPDATE users
                SET strPhoto = ''
                WHERE intUserID = :intUserID
            "
        )

        logWrite("user", "info", "Photo deleted [CustomerID: #session.customer_id#, UserID: #session.user_id#, Filename: #qPhoto.strPhoto#]");

        location url="#application.mainURL#/account-settings/my-profile" addtoken="false";

    }

}

// Change password
if (structKeyExists(form, "change_pw_btn")) {

    param name="form.password" default="";
    param name="form.password2" default="";

    // Check passwords first
    if (len(trim(form.password)) and len(trim(form.password2))) {
        if (not trim(form.password) eq trim(form.password2)) {
            getAlert('alertPasswordsNotSame', 'warning');
            logWrite("user", "warning", "User tried to change passwords. Passwords are not the same. [CustomerID: #session.customer_id#, UserID: #session.user_id#]");
            location url="#application.mainURL#/account-settings/reset-password" addtoken="false";
        }
    } else {
        getAlert('alertChoosePassword', 'warning');
        logWrite("user", "warning", "User tried to change passwords. Password field empty. [CustomerID: #session.customer_id#, UserID: #session.user_id#]");
        location url="#application.mainURL#/account-settings/reset-password" addtoken="false";
    }

    newUUID = application.objGlobal.getUUID();

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            intUserID: {type: "numeric", value: session.user_id},
            strUUID: {type: "nvarchar", value: newUUID}
        },
        sql = "
            UPDATE users
            SET strUUID = :strUUID
            WHERE intUserID = :intUserID
        "
    )

    // Change it now
    changePW = application.objUser.changePassword(form.password, newUUID);
    if (changePW.success) {
        getAlert('alertPasswordResetSuccessfully', 'success');
        logWrite("user", "info", "User changed passwords. [CustomerID: #session.customer_id#, UserID: #session.user_id#]");
    } else {
        getAlert(changePW.message, 'danger');
        logWrite("system", "error", "Could not change password. [CustomerID: #session.customer_id#, UserID: #session.user_id#, Error: #changePW.message#]");
    }

    location url="#application.mainURL#/account-settings/reset-password" addtoken="false";

}


// Delete user
if (structKeyExists(url, "delete")) {

    param name="url.delete" default="0";

    if (!isNumeric(url.delete) or url.delete lte 0) {
        getAlert('No user found!', 'danger');
        logWrite("system", "warning", "Delete user: url.delete is not numeric or 0. [CustomerID: #session.customer_id#, UserID: #session.user_id#, url.delete: #url.delete#]");
        location url="#application.mainURL#/account-settings/users" addtoken="false";
    }

    // User data of the user to be deleted
    getUserData = application.objCustomer.getUserDataByID(url.delete);

    if (!isQuery(getUserData) or !getUserData.recordCount) {
        getAlert('No user found!', 'danger');
        logWrite("system", "warning", "Delete user: No user found. [CustomerID: #session.customer_id#, UserID: #session.user_id#, UserID to delete: #url.delete#]");
        location url="#application.mainURL#/account-settings/users" addtoken="false";
    }

    // Check whether the user is allowed to delete
    checkTenantRange = application.objGlobal.checkTenantRange(session.user_id, getUserData.intCustomerID);

    if (!checkTenantRange) {
        getAlert('You are not allowed to delete this user!', 'danger');
        logWrite("user", "warning", "Tried to delete a user from another tenant [CustomerID: #session.customer_id#, UserID: #session.user_id#, UserID to delete: #url.delete#]");
        location url="#application.mainURL#/account-settings/users" addtoken="false";
    }

    // Delete users photo
    if (len(trim(getUserData.strPhoto))) {

        photoPath = expandPath('../userdata/images/users/#getUserData.strPhoto#');
        objUserFileDelete = application.objGlobal.deleteFile(photoPath);
        if (objUserFileDelete.success) {
            logWrite("system", "info", "Users Photo has been deleted [CustomerID: #session.customer_id#, UserID: #session.user_id#, UserID to delete: #url.delete#, Filename: #getUserData.strPhoto#]");
        } else {
            logWrite("system", "warning", "Users Photo could not be deleted [CustomerID: #session.customer_id#, UserID: #session.user_id#, UserID to delete: #url.delete#, Filename: #getUserData.strPhoto#]");
        }

    }

    // Delete user
    queryExecute(
        options = {datasource = application.datasource, result="getAnswer"},
        params = {
            intUserID: {type: "numeric", value: getUserData.intUserID},
            myUserID: {type: "numeric", value: session.user_id}
        },
        sql = "
            DELETE FROM users WHERE intUserID = :intUserID AND intUserID != :myUserID
        "
    )

    if (getAnswer.recordCount) {
        getAlert('msgUserDeleted', 'success');
        logWrite("user", "info", "User has been deleted. [CustomerID: #session.customer_id#, UserID: #session.user_id#, UserID deleted: #url.delete#]");
    } else {
        getAlert('No user found!', 'danger');
        logWrite("system", "warning", "No matching user in database [CustomerID: #session.customer_id#, UserID: #session.user_id#, UserID to delete: #url.delete#]");
    }

    location url="#application.mainURL#/account-settings/users" addtoken="false";

}


// Send invitation link
if (structKeyExists(url, "invit")) {

    // User data of the user to be edited
    getUserData = application.objCustomer.getUserDataByID(url.invit);

    if (!isQuery(getUserData) or !getUserData.recordCount) {
        getAlert('No user found!', 'danger');
        logWrite("system", "warning", "Send invitation link: No user found. [CustomerID: #session.customer_id#, UserID: #session.user_id#, UserID to send invitation: #url.invit#]");
        location url="#application.mainURL#/account-settings/users" addtoken="false";
    }

    // Check whether the user is allowed to edit
    checkTenantRange = application.objGlobal.checkTenantRange(session.user_id, getUserData.intCustomerID);
    if (!checkTenantRange) {
        getAlert('You are not allowed to edit this user!', 'danger');
        logWrite("user", "warning", "Tried to send invitation link to a user from another tenant [CustomerID: #session.customer_id#, UserID: #session.user_id#, UserID to send invitation: #url.invit#]");
        location url="#application.mainURL#/account-settings/users" addtoken="false";
    }

    if (isNumeric(url.invit) and url.invit gt 0) {
        sendInvit = application.objUser.sendInvitation(url.invit, session.user_id);
        if (sendInvit.success) {
            getAlert(sendInvit.message, 'success');
            logWrite("user", "info", "Invitation has been sent [CustomerID: #session.customer_id#, UserID: #session.user_id#, UserID to send invitation: #url.invit#]");
        } else {
            getAlert(sendInvit.message, 'danger');
            logWrite("system", "error", "Invitation could not be sent [CustomerID: #session.customer_id#, UserID: #session.user_id#, UserID to send invitation: #url.invit#, Error: #sendInvit.message#]");
        }
    } else {
        getAlert(sendInvit.message, 'danger');
        logWrite("user", "warning", "Send invitation: url.invit is not numeric or is 0 [CustomerID: #session.customer_id#, UserID: #session.user_id#, url.invit: #url.invit#]");
    }

    location url="#application.mainURL#/account-settings/users" addtoken="false";

}

logWrite("user", "warning", "Access attempt to handler/user.cfm without method [CustomerID: #session.customer_id#, UserID: #session.user_id#]");
location url="#application.mainURL#/dashboard" addtoken="false";

</cfscript>