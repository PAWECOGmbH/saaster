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
    
        session.company = form.company;
        session.contact = form.contact;
        session.address = form.address;
        session.address2 = form.address2;
        session.zip = form.zip;
        session.city = form.city;
        session.countryID = form.countryID;
        session.email = form.email;
        session.phone = form.phone;
        session.website = form.website;
        session.billing_name = form.billing_name;
        session.billing_email = form.billing_email;
        session.billing_address = form.billing_address;
        session.billing_info = form.billing_info;  
    
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
    
        <!--- Clear sessions --->
        structDelete(session, "company");
        structDelete(session, "contact");
        structDelete(session, "address");
        structDelete(session, "address2");
        structDelete(session, "zip");
        structDelete(session, "countryID");
        structDelete(session, "email");
        structDelete(session, "phone");
        structDelete(session, "website");
        structDelete(session, "billing_name");
        structDelete(session, "billing_email");
        structDelete(session, "billing_address");
        structDelete(session, "billing_info");
    
        location url="#application.mainURL#/sysadmin/customers/edit/#form.redirect#" addtoken="false";   
    
    }
</cfscript>