<cfscript>

    // Company edit
    if (structKeyExists(form, "edit_company_btn")) {
        param name="form.company" default="";
        param name="form.contact" default="";
        param name="form.address" default="";
        param name="form.address2" default="";
        param name="form.zip" default="";
        param name="form.city" default="";
        param name="form.countryID" default="1";
        param name="form.email" default="";
        param name="form.phone" default="";
        param name="form.website" default="";
        param name="form.billing_name" default="";
        param name="form.billing_email" default="";
        param name="form.billing_address" default="";
        param name="form.billing_info" default="";

        // Check whether the email is valid
        checkEmail = application.objGlobal.checkEmail(form.email);
        if (!checkEmail) {
            getAlert('alertEnterEmail', 'warning');
            location url="#application.mainURL#/sysadmin/customers/edit/#form.edit_company_btn#" addtoken="false";
        }

        if (len(trim(form.billing_email))) {
            checkEmail = application.objGlobal.checkEmail(form.billing_email);
            if (!checkEmail) {
                getAlert('alertEnterEmail', 'warning');
                location url="#application.mainURL#/sysadmin/customers/edit/#form.edit_company_btn#" addtoken="false";
            }
        }

        // Save the customer using a function
        objCustomerEdit = application.objCustomer.updateCustomer(form, form.edit_company_btn);

        if (objCustomerEdit.success) {
            getAlert('msgChangesSaved', 'success');
        } else {
            getAlert(objCustomerEdit.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/customers/edit/#form.edit_company_btn#" addtoken="false";

    }

    // Delete user
    if (structKeyExists(form, "delete_user")) {
        param name="form.customer_id" default="0";
        param name="form.user_id" default="0";

        if (
            !isNumeric(form.customer_id)
            or form.customer_id lte 0
            or !isNumeric(form.user_id)
            or form.user_id lte 0
        ) {
            getAlert('No user found!', 'danger');
            logWrite("system", "warning", "Sysadmin user deletion received invalid IDs [Sysadmin UserID: #session.user_id#, CustomerID: #form.customer_id#, UserID to delete: #form.user_id#]");
            location url="#application.mainURL#/sysadmin/customers" addtoken="false";
        }

        userToDelete = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: form.customer_id},
                userID: {type: "numeric", value: form.user_id}
            },
            sql = "
                SELECT DISTINCT users.intUserID, users.strPhoto
                FROM users
                INNER JOIN customer_user ON customer_user.intUserID = users.intUserID
                WHERE customer_user.intCustomerID = :customerID
                AND users.intUserID = :userID
            "
        );

        customerUserCount = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: form.customer_id}
            },
            sql = "
                SELECT COUNT(DISTINCT intUserID) AS userCount
                FROM customer_user
                WHERE intCustomerID = :customerID
            "
        );

        if (
            !userToDelete.recordCount
            or userToDelete.intUserID eq session.user_id
            or customerUserCount.userCount lte 1
        ) {
            getAlert('This user cannot be deleted.', 'danger');
            logWrite("user", "warning", "Sysadmin was not allowed to delete user [Sysadmin UserID: #session.user_id#, CustomerID: #form.customer_id#, UserID to delete: #form.user_id#, Customer user count: #customerUserCount.userCount#]");
            location url="#application.mainURL#/sysadmin/customers/details/#form.customer_id###users" addtoken="false";
        }

        queryExecute(
            options = {datasource = application.datasource, result = "deleteUserResult"},
            params = {
                userID: {type: "numeric", value: userToDelete.intUserID}
            },
            sql = "
                DELETE FROM users
                WHERE intUserID = :userID
            "
        );

        if (deleteUserResult.recordCount) {
            if (len(trim(userToDelete.strPhoto))) {
                application.objGlobal.deleteFile(expandPath("/userdata/images/users/#userToDelete.strPhoto#"));
            }
            getAlert('msgUserDeleted', 'success');
            logWrite("user", "info", "Sysadmin deleted user [Sysadmin UserID: #session.user_id#, CustomerID: #form.customer_id#, UserID deleted: #form.user_id#]");
        } else {
            getAlert('No user found!', 'danger');
            logWrite("system", "warning", "Sysadmin user deletion did not match a database row [Sysadmin UserID: #session.user_id#, CustomerID: #form.customer_id#, UserID to delete: #form.user_id#]");
        }

        location url="#application.mainURL#/sysadmin/customers/details/#form.customer_id###users" addtoken="false";
    }

    // Edit user
    if (structKeyExists(form, "edit_user")) {
        param name="form.customer_id" default="";
        param name="form.user_id" default="";
        param name="form.email" default="";

        // Check whether the email is valid
        checkEmail = application.objGlobal.checkEmail(form.email);

        if (!checkEmail) {
            getAlert('alertEnterEmail', 'warning');
            location url="#application.mainURL#/sysadmin/customers/details/#form.customer_id#" addtoken="false";
        }

        // Check for already registered email
        qCheckDouble = queryExecute(
            options = {datasource = application.datasource},
            params = {
                strEmail: {type: "nvarchar", value: form.email},
                intCustomerID: {type: "numeric", value: form.customer_id},
                intUserID: {type: "numeric", value: form.user_id}
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
            location url="#application.mainURL#/sysadmin/customers/details/#form.customer_id#" addtoken="false";
        }

        // Get data that is missing from form
        qGetData = queryExecute(
            options = {datasource = application.datasource},
            params = {
                intUserID: {type: "numeric", value: form.user_id}
            },
            sql = "
                SELECT strPhone, strMobile, strLanguage, blnSuperAdmin, blnAdmin, blnActive
                FROM users
                WHERE intUserID = :intUserID
            "
        )

        allData = {}
        allData.phone = qGetData.strPhone
        allData.mobile = qGetData.strMobile
        allData.language = qGetData.strLanguage
        allData.admin = qGetData.blnAdmin
        allData.superadmin = qGetData.blnSuperAdmin
        allData.active = qGetData.blnActive
        allData.email = form.email
        allData.first_name = form.first_name
        allData.last_name = form.last_name
        allData.salutation = form.salutation

        objupdateUser = application.objUser.updateUser(allData, form.user_id, false);

        if (objupdateUser.success) {
            getAlert('msgChangesSaved', 'success');
        } else {
            getAlert(objupdateUser.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/customers/details/#form.customer_id#" addtoken="false";
    }

    // Add new customer
    if (structKeyExists(form, "add_customer")) {

        customerStruct = {};
        customerStruct['strCompanyName'] = form.company;
        customerStruct['strFirstName'] = form.first_name;
        customerStruct['strLastName'] = form.last_name;
        customerStruct['strEmail'] = form.email;
        customerStruct['strLanguage'] = form.language;
        customerStruct['password'] = form.password;

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
                getAlert('This e-mail address is already in use!', 'warning');
                location url="#application.mainURL#/sysadmin/customers" addtoken="false";
            }

            // Hash and salt the password
            hashedStruct = application.objGlobal.generateHash(form.password);
            customerStruct['hash'] = hashedStruct.thisHash;
            customerStruct['salt'] = hashedStruct.thisSalt;

            // Save the customer into the db
            objRegister = new frontend.core.com.register();
            insertCustomer = objRegister.insertCustomer(customerStruct);
            if (insertCustomer.success) {

                qNewUser = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        strEmail = {type: "nvarchar", value: form.email}
                    },
                    sql = "
                        SELECT intCustomerID
                        FROM users
                        WHERE strEmail = :strEmail
                    "
                );

                newCustomerID = qNewUser.intCustomerID;

                // Update country or timezone
                if (structKeyExists(form, "countryID") and isNumeric(form.countryID)) {

                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            intCustomerID: {type: "numeric", value: newCustomerID},
                            intCountryID: {type: "numeric", value: form.countryID}
                        },
                        sql = "
                            UPDATE customers
                            SET intCountryID = :intCountryID
                            WHERE intCustomerID = :intCustomerID
                        "
                    )

                } else {

                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            intCustomerID: {type: "numeric", value: newCustomerID},
                            intTimeZoneID: {type: "numeric", value: form.timezoneID}
                        },
                        sql = "
                            UPDATE customers
                            SET intTimeZoneID = :intTimeZoneID
                            WHERE intCustomerID = :intCustomerID
                        "
                    )

                }

                getAlert('The new customer has been added.', 'success');


            } else {

                getAlert(insertCustomer.message, 'danger');

            }

            location url="#application.mainURL#/sysadmin/customers" addtoken="false";



        }

    }


    // Login as a customer
    if (structKeyExists(url, "logincustomer") and isNumeric(url.logincustomer)) {

        if (session.sysadmin) {

            // Get customer data
            qCustomer = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    intCustomerID: {type: "numeric", value: url.logincustomer}
                },
                sql = "
                    SELECT *
                    FROM users
                    WHERE intCustomerID = :intCustomerID
                    AND blnSuperAdmin = 1
                    LIMIT 1
                "
            );

            if (qCustomer.recordCount) {

                // Overwrite session data
                session.user_id = qCustomer.intUserID;
                session.customer_id = qCustomer.intCustomerID;
                session.user_name = qCustomer.strFirstName & " " & qCustomer.strLastName;
                session.user_email = qCustomer.strEmail;
                session.last_login = qCustomer.dtmLastLogin;
                session.admin = 1;
                session.superadmin = 1;
                session.sysadmin = 0;
                session.supportLogin = 1;

                // Set plans and modules as well as the custom settings into a session
                application.objCustomer.setProductSessions(session.customer_id, session.lng);

                // Go to dashboard
                location url="#application.mainURL#/dashboard" addtoken="false";

            }

        }

        location url="#application.mainURL#/sysadmin/customers" addtoken="false";

    }



</cfscript>
