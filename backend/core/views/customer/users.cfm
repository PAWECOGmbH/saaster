
<cfscript>
    qUser = application.objUser.getAllUsers(session.customer_id);
</cfscript>



<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">
        <div class="row mb-3">
            <div class="col-md-12 col-lg-12 mb-3">
                <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                    <h4 class="page-title">#getTrans('titUserOverview')#</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                        <li class="breadcrumb-item active">#getTrans('titUserOverview')#</li>
                    </ol>
                </div>
                <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                    <a href="#application.mainURL#/account-settings/user/new" class="btn btn-primary">
                        <i class="fas fa-plus pe-3"></i> #getTrans('btnNewUser')#
                    </a>
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="row">
            <div class="col-md-12 col-lg-12">
                <div class="card">

                    <div class="table-responsive">
                        <table class="table card-table table-vcenter text-nowrap">
                            <thead >
                                <tr>
                                    <th>#getTrans('titPhoto')#</th>
                                    <th>#getTrans('formFirstName')#</th>
                                    <th>#getTrans('formName')#</th>
                                    <th>#getTrans('formEmailAddress')#</th>
                                    <th class="text-center">#getTrans('titSuperAdmin')#</th>
                                    <th class="text-center">#getTrans('titAdmin')#</th>
                                    <th class="text-center">#getTrans('titActive')#</th>
                                    <th class="w-1"></th>
                                </tr>
                            </thead>
                            <tbody>
                            <cfloop query="qUser">
                                <tr>
                                    <cfif not len(trim(qUser.strPhoto))>
                                        <td><span class="avatar avatar-md brround">#ucase(left(qUser.strFirstName,1))##ucase(left(qUser.strLastName,1))#</span></td>
                                    <cfelse>
                                        <td><img src="#application.mainURL#/userdata/images/users/#qUser.strPhoto#" title="#qUser.strFirstName#" class="avatar avatar-md brround"></td>
                                    </cfif>
                                    <td>#qUser.strFirstName#</td>
                                    <td>#qUser.strLastName#</td>
                                    <td>#qUser.strEmail#</td>
                                    <td class="text-center"><cfif qUser.blnSuperAdmin><i class="fa fa-check text-green"></i><cfelse><i class="fa fa-close text-red"></cfif></td>
                                    <td class="text-center"><cfif qUser.blnAdmin><i class="fa fa-check text-green"></i><cfelse><i class="fa fa-close text-red"></cfif></td>
                                    <td class="text-center"><cfif qUser.blnActive><i class="fa fa-check text-green"></i><cfelse><i class="fa fa-close text-red"></cfif></td>
                                    <td class="text-end">
                                        <cfset canEdit = true>
                                        <cfif session.superadmin>
                                            <cfif qUser.blnSysAdmin>
                                                <cfset canEdit = false>
                                            </cfif>
                                        <cfelseif session.admin>
                                            <cfif qUser.blnSuperAdmin>
                                                <cfset canEdit = false>
                                            </cfif>
                                        </cfif>
                                        <cfif canEdit or session.sysadmin>
                                            <div class="btn-list flex-nowrap">
                                                <button type="button" class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown">
                                                    #getTrans('blnAction')#
                                                </button>
                                                <div class="dropdown-menu dropdown-menu-end">
                                                    <cfif qUser.intUserID neq session.user_id>
                                                        <a class="dropdown-item" href="#application.mainURL#/account-settings/user/edit/#qUser.intUserID#">#getTrans('btnEdit')#</a>
                                                    <cfelse>
                                                        <a class="dropdown-item" href="#application.mainURL#/account-settings/my-profile">#getTrans('btnEdit')#</a>
                                                    </cfif>
                                                    <cfif qUser.intUserID neq session.user_id>
                                                        <a class="dropdown-item cursor-pointer" onclick="sweetAlert('warning', '#application.mainURL#/user?delete=#qUser.intUserID#', '#getTrans("titDeleteUser")#', '#getTrans("txtDeleteUserConfirmText")#', '#getTrans("btnNoCancel")#', '#getTrans("btnYesDelete")#')">#getTrans('btnDelete')#</a>
                                                    </cfif>
                                                    <a class="dropdown-item" href="#application.mainURL#/user?invit=#qUser.intUserID#">#getTrans('btnSendActivLink')#</a>
                                                </div>
                                            </div>
                                        </cfif>
                                    </td>
                                </tr>
                            </cfloop>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    

</div>
</cfoutput>