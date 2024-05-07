<cfscript>

    // Is the customer allowed to create more users?
    if (structKeyExists(session.currentPlan, "maxUsers") and !session.sysadmin) {
        maxUsers = session.currentPlan.maxUsers;
        // Does the client have a plan on the waiting list?
        if (structKeyExists(session.currentPlan, "nextplan")) {
            if (structKeyExists(session.currentPlan.nextplan, "maxUsers")) {
                maxUsers = session.currentPlan.nextplan.maxUsers;
            }
        }
        if (maxUsers gt 0) {
            numUsers = application.objUser.getAllUsers(session.customer_id).recordcount;
            if (numUsers gte maxUsers) {
                getAlert('msgMaxUsersReached', 'warning');
                location url="#application.mainURL#/account-settings/users" addtoken="false";
            }
        }
    }

    // Set default values
    userSalutation = "";
    userFirstName = "";
    userLastName = "";
    userEmail = "";
    userPhone = "";
    userMobile = "";

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
        userEmail = session.email
    }

    if(structKeyExists(session, "phone") and len(trim(session.phone))){
        userPhone = session.phone
    }

    if(structKeyExists(session, "mobile") and len(trim(session.mobile))){
        userMobile = session.mobile
    }
</cfscript>




<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">#getTrans('btnNewUser')#</h4>
                        <ol class="breadcrumb breadcrumb-dots ">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings/users">#getTrans('titUserOverview')#</a></li>
                            <li class="breadcrumb-item active">#getTrans('btnNewUser')#</li>
                        </ol>
                    </div>

                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="#getLayout.layoutPage#">
            <div class="row">
                <div class="col-lg-12">
                    <div class="card">

                        <form id="submit_form" class="card" method="post" action="#application.mainURL#/user">
                        <input type="hidden" name="user_new_btn">
                            <div class="card-header">
                                <h3 class="card-title">#getTrans('titNewUser')#</h3>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <cfif !session.sysadmin>
                                        <div class="col-lg-4 mb-3">
                                            <div class="form-label">#getTrans('titActive')#</div>
                                            <label class="form-check form-switch">
                                                <input class="form-check-input" type="checkbox" name="active" checked>
                                                <span class="form-check-label">#getTrans('txtActivateThisUser')#</span>
                                            </label>
                                        </div>
                                        <div class="col-lg-4 mb-3">
                                            <div class="form-label">#getTrans('titAdmin')#</div>
                                            <label class="form-check form-switch">
                                                <input class="form-check-input" type="checkbox" name="admin">
                                                <span class="form-check-label">#getTrans('txtSetUserAsAdmin')#</span>
                                            </label>
                                        </div>
                                        <cfif session.superadmin>
                                            <div class="col-lg-4 mb-3">
                                                <div class="form-label">#getTrans('titSuperAdmin')#</div>
                                                <label class="form-check form-switch">
                                                    <input class="form-check-input" type="checkbox" name="superadmin">
                                                    <span class="form-check-label">#getTrans('txtSetUserAsSuperAdmin')#</span>
                                                </label>
                                            </div>
                                        </cfif>
                                    </cfif>
                                    <cfif session.sysadmin>
                                        <div class="col-lg-3 mb-3">
                                            <div class="form-label">#getTrans('titActive')#</div>
                                            <label class="form-check form-switch">
                                                <input class="form-check-input" type="checkbox" name="active" checked>
                                                <span class="form-check-label">#getTrans('txtActivateThisUser')#</span>
                                            </label>
                                        </div>
                                        <div class="col-lg-3 mb-3">
                                            <div class="form-label">#getTrans('titAdmin')#</div>
                                            <label class="form-check form-switch">
                                                <input class="form-check-input" type="checkbox" name="admin">
                                                <span class="form-check-label">#getTrans('txtSetUserAsAdmin')#</span>
                                            </label>
                                        </div>
                                        <cfif session.superadmin>
                                            <div class="col-lg-3 mb-3">
                                                <div class="form-label">#getTrans('titSuperAdmin')#</div>
                                                <label class="form-check form-switch">
                                                    <input class="form-check-input" type="checkbox" name="superadmin">
                                                    <span class="form-check-label">#getTrans('txtSetUserAsSuperAdmin')#</span>
                                                </label>
                                            </div>
                                        </cfif>
                                        <div class="col-lg-3 mb-3">
                                            <div class="form-label">#getTrans('titSysAdmin')#</div>
                                            <label class="form-check form-switch">
                                                <input class="form-check-input" type="checkbox" name="sysadmin">
                                                <span class="form-check-label">#getTrans('txtSetUserAsSysAdmin')#</span>
                                            </label>
                                        </div>
                                    </cfif>

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

                                    <div class="col-md-4 mb-3">
                                        <div class="form-group">
                                            <label class="form-label">#getTrans('formEmailAddress')# *</label>
                                            <input type="email" class="form-control" name="email" value="#userEmail#" minlength="3" maxlength="100" required>
                                        </div>
                                    </div>
                                        <div class="col-sm-6 col-md-4 mb-3">
                                        <div class="form-group">
                                            <label class="form-label">#getTrans('formPhone')#</label>
                                            <input type="text" class="form-control" name="phone" value="#HTMLEditFormat(userPhone)#" maxlength="100">
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-md-4 mb-3">
                                        <div class="form-group">
                                            <label class="form-label">#getTrans('formMobile')#</label>
                                            <input type="text" name="mobile" class="form-control" value="#HTMLEditFormat(userMobile)#" maxlength="100">
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="card-footer text-right">
                                <button id="submit_button" type="submit" class="btn btn-primary">#getTrans('btnSave')#</button>
                            </div>
                        </form>

                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    

</div>