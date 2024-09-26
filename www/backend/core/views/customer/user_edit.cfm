<cfscript>
    // Exception handling for sef and user id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisUserID = thiscontent.thisID;

    if(not isNumeric(thisUserID) or thisUserID lte 0) {
        location url="#application.mainURL#/account-settings/users" addtoken="false";
    }

    // Get the users data
    qCustomer = application.objCustomer.getUserDataByID(thisUserID)
    if(not qCustomer.recordCount){
        location url="#application.mainURL#/account-settings/users" addtoken="false";
    }

    // Write the data into variables
    // Set default values
    userSalutation = qCustomer.strSalutation;
    userFirstName = qCustomer.strFirstName;
    userLastName = qCustomer.strLastName;
    userEmail = qCustomer.strEmail;
    userPhone = qCustomer.strPhone;
    userMobile = qCustomer.strMobile;

    if(structKeyExists(session, "salutation") and len(trim(session.salutation))){
        userSalutation = session.salutation;
    }

    if(structKeyExists(session, "first_name") and len(trim(session.first_name))){
        userFirstName = session.first_name;
    }

    if(structKeyExists(session, "last_name") and len(trim(session.last_name))){
        userLastName = session.last_name;
    }

    if(structKeyExists(session, "email") and len(trim(session.email))){
        userEmail = session.email;
    }

    if(structKeyExists(session, "phone") and len(trim(session.phone))){
        userPhone = session.phone;
    }

    if(structKeyExists(session, "mobile") and len(trim(session.mobile))){
        userMobile = session.mobile;
    }

</cfscript>



<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">
        <div class="row">
            <div class="#getLayout.layoutPageHeader# mb-3">
                <h4 class="page-title">#getTrans('btnEditUser')#</h4>

                <ol class="breadcrumb breadcrumb-dots">
                    <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                    <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings/users">#getTrans('titUserOverview')#</a></li>
                    <li class="breadcrumb-item active">#getTrans('btnEditUser')#</li>
                </ol>
            </div>
        </div>
        <cfif structKeyExists(session, "alert")>
            #session.alert#
        </cfif>
        <div class="row">
            <div class="col-lg-12">
                <form id="submit_form" class="card" method="post" action="#application.mainURL#/user">
                    <input type="hidden" name="edit_profile_btn">
                    <input type="hidden" name="customerID" value="#session.customer_id#">
                    <input type="hidden" name="userID" value="#thisUserID#">
                    <input type="hidden" name="language" value="#qCustomer.strLanguage#">
                    <div class="card-header">
                        <h3 class="card-title">#getTrans('titEditUser')#</h3>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-4 mb-3">
                                <div class="form-label">#getTrans('titActive')#</div>
                                <label class="form-check form-switch">
                                    <cfif thisUserID neq session.user_id>
                                        <input class="form-check-input" type="checkbox" name="active" <cfif qCustomer.blnActive eq 1>checked</cfif>>
                                    <cfelse>
                                        <input class="form-check-input" type="checkbox" name="active" checked disabled>
                                        <input type="hidden" name="active" value="1">
                                    </cfif>
                                    <span class="form-check-label">#getTrans('txtActivateThisUser')#</span>
                                </label>
                            </div>
                            <div class="col-lg-4 mb-3">
                                <cfif session.admin>
                                    <div class="form-label">#getTrans('titAdmin')#</div>
                                    <label class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="admin" <cfif qCustomer.blnAdmin eq 1>checked</cfif>>
                                        <span class="form-check-label">#getTrans('txtSetUserAsAdmin')#</span>
                                    </label>
                                <cfelse>
                                    <input type="hidden" name="admin" value="#qCustomer.blnAdmin#">
                                </cfif>
                            </div>
                            <div class="col-lg-4 mb-3">
                                <cfif session.superadmin>
                                    <div class="form-label">#getTrans('titSuperAdmin')#</div>
                                    <label class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="superadmin" <cfif qCustomer.blnSuperAdmin eq 1>checked</cfif>>
                                        <span class="form-check-label">#getTrans('txtSetUserAsSuperAdmin')#</span>
                                    </label>
                                <cfelse>
                                    <input type="hidden" name="superadmin" value="#qCustomer.blnSuperAdmin#">
                                </cfif>
                            </div>
                            <div class="col-sm-6 col-md-3 mb-3">
                                <div class="form-group">
                                    <label class="form-label">#getTrans('formSalutation')#</label>
                                    <input type="text" name="salutation" class="form-control" value="#HTMLEditFormat(userSalutation)#" maxlength="20">
                                </div>
                            </div>
                            <div class="col-md-5 mb-3">
                                <div class="form-group">
                                    <label class="form-label">#getTrans('formFirstName')# *</label>
                                    <input type="text" name="first_name" class="form-control" value="#HTMLEditFormat(userFirstName)#" minlength="3" maxlength="100" required>
                                </div>
                            </div>
                            <div class="col-sm-6 col-md-4 mb-3">
                                <div class="form-group">
                                    <label class="form-label">#getTrans('formName')# *</label>
                                    <input type="text" name="last_name" class="form-control" value="#HTMLEditFormat(userLastName)#" minlength="3" maxlength="100" required>
                                </div>
                            </div>

                            <div class="col-md-4">
                                <div class="form-group">
                                    <label class="form-label">#getTrans('formEmailAddress')# *</label>
                                    <input type="email" class="form-control" name="email" value="#userEmail#" minlength="5" maxlength="100" required>
                                </div>
                            </div>
                                <div class="col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label class="form-label">#getTrans('formPhone')#</label>
                                    <input type="text" class="form-control" name="phone" value="#HTMLEditFormat(userPhone)#" maxlength="100">
                                </div>
                            </div>
                            <div class="col-sm-6 col-md-4">
                                <div class="form-group">
                                    <label class="form-label">#getTrans('formMobile')#</label>
                                    <input type="text" name="mobile" class="form-control" value="#HTMLEditFormat(userMobile)#" maxlength="100">
                                </div>
                            </div>
                        </div>
                    </div>
                    <cfif qTenants.recordCount gt 1>
                        <div class="card-header">
                            <h3 class="card-title">#getTrans('titMandanten')#</h3>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-12">
                                    <p>#getTrans('txtWhichTenants')#</p>
                                    <div class="">
                                        <div class="form-selectgroup form-selectgroup-boxes d-flex flex-inline-row">
                                            <cfloop query="qTenants">
                                                <cfquery datasource="#application.datasource#" name="qAccessToTenant">
                                                    SELECT intCustomerID
                                                    FROM customer_user
                                                    WHERE intUserID = <cfqueryparam sqltype="numeric" value="#thisUserID#">
                                                    AND intCustomerID = <cfqueryparam sqltype="numeric" value="#qTenants.intCustomerID#">
                                                </cfquery>
                                                <label class="form-selectgroup-item flex-fill">
                                                    <input type="checkbox" name="tenantID" class="form-selectgroup-input" value="#qTenants.intCustomerID#" <cfif qAccessToTenant.recordCount>checked</cfif>>
                                                    <div class="form-selectgroup-label d-flex align-items-center p-3">
                                                        <div class="me-3">
                                                            <span class="form-selectgroup-check"></span>
                                                        </div>
                                                        <div class="form-selectgroup-label-content d-flex align-items-center">
                                                            <cfif len(trim(qTenants.strLogo))>
                                                                <img src="#application.mainURL#/userdata/images/logos/#qTenants.strLogo#" style="margin-right:20px" class="avatar me-3" alt="#qTenants.strCompanyName#">
                                                            <cfelse>
                                                                <cfif len(trim(qTenants.strCompanyName))>
                                                                    <div style="margin-right:20px" class="avatar me-3">#left(qTenants.strCompanyName,2)#</div>
                                                                <cfelse>
                                                                    <div style="margin-right:20px" class="avatar me-3">#left(qTenants.strContactPerson,2)#</div>
                                                                </cfif>
                                                            </cfif>
                                                            <div>
                                                                <cfif len(trim(qTenants.strCompanyName))>
                                                                    <div class="font-weight-medium">#qTenants.strCompanyName#</div>
                                                                <cfelse>
                                                                    <div class="font-weight-medium">#qTenants.strContactPerson# (#getTrans('formContactName')#)</div>
                                                                </cfif>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </label>
                                            </cfloop>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </cfif>
                    <div class="card-footer">
                        <button id="submit_button" type="submit" class="btn btn-primary">#getTrans('btnSave')#</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    

</div>
</cfoutput>