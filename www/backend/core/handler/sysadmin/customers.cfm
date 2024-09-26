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

    if (structKeyExists(form, "edit_user")) {
        param name="form.customer_id" default="";
        param name="form.user_id " default="";
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
</cfscript>