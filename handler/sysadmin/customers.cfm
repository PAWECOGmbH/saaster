<cfscript>
    
    <!--- Company edit --->
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

        <!--- Check whether the email is valid --->
        checkEmail = application.objGlobal.checkEmail(form.email);
        if (!checkEmail) {
            getAlert('alertEnterEmail', 'warning');
            location url="#application.mainURL#/sysadmin/customers/edit/#form.redirect#" addtoken="false";
        }
    
        if (len(trim(form.billing_email))) {
            checkEmail = application.objGlobal.checkEmail(form.billing_email);
            if (!checkEmail) {
                getAlert('alertEnterEmail', 'warning');
                location url="#application.mainURL#/sysadmin/customers/edit/#form.redirect#" addtoken="false";
            }
        }
    
        <!--- Save the customer using a function --->
        objCustomerEdit = application.objCustomer.updateCustomer(form, form.redirect);
    
        if (objCustomerEdit.success) {
            getAlert('msgChangesSaved', 'success');        
        } else {
            getAlert(objCustomerEdit.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/customers/edit/#form.redirect#" addtoken="false";   
    
    }

    if (structKeyExists(form, "edit_user")) {

        <!--- Check whether the email is valid --->
        checkEmail = application.objGlobal.checkEmail(form.email);

        if (!checkEmail) {
            getAlert('alertEnterEmail', 'warning');
            location url="#application.mainURL#/sysadmin/customers/details/#form.customer_id#" addtoken="false";
        }

        <!--- Check for already registered email --->
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

        objupdateUser = application.objUser.updateUser(form, form.user_id);

        if (objupdateUser.success) {
            getAlert('msgChangesSaved', 'success');        
        } else {
            getAlert(objCustomerEdit.message, 'danger');
        }
        
        location url="#application.mainURL#/sysadmin/customers/details/#form.customer_id#" addtoken="false";   
    }
</cfscript>