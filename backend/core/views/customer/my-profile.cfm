<cfscript>

	qCustomer = application.objCustomer.getUserDataByID(session.user_ID);

    iniUserObj = application.objUser;
    userMail = qCustomer.strEmail;

    if (structKeyExists(url, "c") and len(trim(url.c)) eq 64){
        
        qOptinUser = iniUserObj.getOptinUser(url.c);
        cReferer = "my-profile";

        local.userID = qOptinUser.intUserID
        
        objMailUpdate = iniUserObj.UpdateEmail(url.nMail, local.userID);

        if (objMailUpdate.success) {
            getAlert('txtEmailUpdated', 'success');
        } else {
            getAlert('No user found!', 'danger');
        }

        userMail = url.nMail;
    }

    fileList = application.objGlobal.buildAllowedFileLists(variables.imageFileTypes);
    
    allowedFileTypesList = fileList.allowedFileTypesList;
    acceptFileTypesList = fileList.acceptFileTypesList; 

</cfscript>




<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">
        <div class="row mb-3">
            <div class="col-md-12 col-lg-12">
                <div class="#getLayout.layoutPageHeader# mb-3">
                    <h4 class="page-title">#getTrans('txtMyProfile')#</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                        <li class="breadcrumb-item active">#getTrans('txtMyProfile')#</li>
                    </ol>
                </div>
                <cfif structKeyExists(session, "alert")>
                    #session.alert#
                </cfif>
                <div class="row">
                    <div class="col-lg-4 mb-3">
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title">#getTrans('titMyPhoto')#</h3>
                            </div>
                            <div class="card-body">
                                <form action="#application.mainURL#/user" method="post" enctype="multipart/form-data">
                                    <div class="row mb-3">
                                        <div class="col-auto text-center">
                                            <!--- Object "objUser" initialized in /backend/core/views/header.cfm --->
                                            <img src="#application.objUser.getUserImage(session.user_id).userImage#" alt="#session.user_name#" class="avatar avatar-xl brround"><br />
                                        </div>
                                        <div class="col">
                                            <h3 class="mb-1">#qCustomer.strFirstName# #qCustomer.strLastName#</h3>
                                            <p class="mb-4">
                                                <cfif qCustomer.blnAdmin>
                                                    #getTrans('titAdmin')#
                                                <cfelse>
                                                    #getTrans('titUser')#
                                                </cfif>
                                            </p>
                                        </div>
                                    </div>

                                    <cfif application.objUser.getUserImage(session.user_id).itsLocal>
                                        <div class="d-flex flex-row flex-start">
                                            <a href="#application.mainURL#/user?del_photo" class="btn btn-warning btn-block" >#getTrans('txtDeletePhoto')#</a>
                                        </div>
                                    <cfelse>
                                        <div class="mt-3">
                                            <input name="photo" required type="file" accept="#allowedFileTypesList#" class="dropify" data-height="100" data-allowed-file-extensions='[#acceptFileTypesList#]' data-max-file-size="3M" />
                                        </div>
                                        <div class="mt-3">
                                            <button name="photo_upload_btn" class="btn btn-primary btn-block">#getTrans('btnUpload')#</button>
                                        </div>
                                    </cfif>
                                </form>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-8">
                        <form id="submit_form" class="card" method="post" action="#application.mainURL#/user">
                            <input type="hidden" name="edit_profile_btn">
                            <input type="hidden" name="admin" value="#qCustomer.blnAdmin#">
                            <input type="hidden" name="superadmin" value="#qCustomer.blnSuperAdmin#">
                            <input type="hidden" name="active" value="#qCustomer.blnActive#">
                            <div class="card-header">
                                <h3 class="card-title">#getTrans('txtEditProfile')#</h3>
                            </div>
                            <div class="card-body">
                                <div class="row mb-1">
                                    <div class="col-sm-6 col-md-3 mb-3">
                                        <div class="form-group">
                                            <label class="form-label">#getTrans('formSalutation')#</label>
                                            <input type="text" name="salutation" class="form-control" value="#HTMLEditFormat(qCustomer.strSalutation)#" maxlength="20">
                                        </div>
                                    </div>
                                    <div class="col-md-5 mb-3">
                                        <div class="form-group">
                                            <label class="form-label">#getTrans('formFirstName')# *</label>
                                            <input type="text" name="first_name" class="form-control" value="#HTMLEditFormat(qCustomer.strFirstName)#" minlength="3" maxlength="100" required>
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-md-4 mb-3">
                                        <div class="form-group">
                                            <label class="form-label">#getTrans('formName')# *</label>
                                            <input type="text" name="last_name" class="form-control" value="#HTMLEditFormat(qCustomer.strLastName)#" minlength="3" maxlength="100" required>
                                        </div>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <div class="form-group">
                                            <label class="form-label">#getTrans('formEmailAddress')# *</label>
                                            <input type="email" class="form-control" name="email" value="#userMail#" maxlength="100" minlength="3" required>
                                        </div>
                                    </div>
                                        <div class="col-sm-6 col-md-4 mb-3">
                                        <div class="form-group">
                                            <label class="form-label">#getTrans('formPhone')#</label>
                                            <input type="text" class="form-control" name="phone" value="#HTMLEditFormat(qCustomer.strPhone)#" maxlength="100">
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-md-4 mb-3">
                                        <div class="form-group">
                                            <label class="form-label">#getTrans('formMobile')#</label>
                                            <input type="text" name="mobile" class="form-control" value="#HTMLEditFormat(qCustomer.strMobile)#" maxlength="100">
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-md-4 mb-3">
                                        <div class="form-group">
                                            <label class="form-label">#getTrans('formLanguage')#</label>
                                            <select name="language" class="form-select">
                                                <cfloop list="#application.allLanguages#" index="i">
                                                    <cfset lngIso = listfirst(i,"|")>
                                                    <cfset lngName = listlast(i,"|")>
                                                    <option <cfif qCustomer.strLanguage eq lngIso>selected</cfif> value="#lngIso#">#lngName#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="col-sm-6 col-md-4 mb-3">
                                        <label class="form-label">#getTrans('titMfa')#</label>
                                        <label class="form-check form-switch mt-3">
                                            <input class="form-check-input" type="checkbox" name="mfa" <cfif qCustomer.blnMfa eq 1>checked</cfif>>
                                            <span class="form-check-label small pt-1">#getTrans('btnActivate')#</span>
                                        </label>
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
    </div>
    

</div>
</cfoutput>

