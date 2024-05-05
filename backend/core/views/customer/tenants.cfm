
<cfscript>
    // Only main companies have access to this resource
    if (getCustomerData.custParentID gt 0) {
        getAlert('msgNoAccess', 'danger');
        location url="#application.mainURL#/account-settings" addtoken="false";
    }
</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">#getTrans('titTenantOverview')#</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                            <li class="breadcrumb-item active">#getTrans('titTenantOverview')#</li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <cfif session.superadmin>
                            <a href="#application.mainURL#/account-settings/tenant/new" class="btn btn-primary">
                                <i class="fas fa-plus pe-3"></i> #getTrans('btnNewTenant')#
                            </a>
                        </cfif>
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

                        <div class="table-responsive">
                            <table class="table card-table table-vcenter text-nowrap">
                                <thead >
                                    <tr>
                                        <th>#getTrans('titLogo')#</th>
                                        <th>#getTrans('formCompanyName')#</th>
                                        <th>#getTrans('formContactName')#</th>
                                        <th class="text-center">#getTrans('formStandard')#</th>
                                        <th class="text-center">#getTrans('titActive')#</th>
                                        <th class="w-1"></th>
                                    </tr>
                                </thead>
                                <tbody>
                                <!--- ## qTenants is in /backend/core/views/tenant_changer.cfm (header.cfm) --->
                                <cfloop query="qTenants">
                                    <tr>
                                        <td>
                                            <cfif not len(trim(qTenants.strLogo))>
                                                <cfif len(trim(qTenants.strCompanyName))>
                                                    <div style="margin-right:20px" class="avatar avatar-md brround">#left(qTenants.strCompanyName,2)#</div>
                                                <cfelse>
                                                    <div style="margin-right:20px" class="avatar avatar-md brround">#left(qTenants.strContactPerson,2)#</div>
                                                </cfif>
                                            <cfelse>
                                                <img src="#application.mainURL#/userdata/images/logos/#qTenants.strLogo#" style="margin-right:20px" class="avatar avatar-md brround" alt="Companylogo">
                                            </cfif>
                                        </td>
                                        <td>
                                            <cfif len(trim(qTenants.strCompanyName))>
                                                #qTenants.strCompanyName#
                                            <cfelse>
                                                #qTenants.strContactPerson# (#getTrans('formContactName')#)
                                            </cfif>
                                            <!--- #qTenants.strCompanyName# --->
                                        </td>
                                        <td>#qTenants.strContactPerson#</td>
                                        <td class="text-center"><cfif qTenants.blnStandard><i class="fa fa-check text-green"></i><cfelse><i class="fa fa-close text-red"></cfif></td>
                                        <td class="text-center"><cfif qTenants.blnActive><i class="fa fa-check text-green"></i><cfelse><i class="fa fa-close text-red"></cfif></td>
                                        <td class="text-end">
                                            <div class="btn-list flex-nowrap">
                                                <cfif qTenants.intCustParentID gt 0>
                                                    <button type="button" class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown">
                                                        #getTrans('blnAction')#
                                                    </button>
                                                    <div class="dropdown-menu dropdown-menu-end">
                                                        <cfif qTenants.blnActive eq 1>
                                                            <a class="dropdown-item" href="#application.mainURL#/global?switch=#qTenants.intCustomerID#">#getTrans('btnSwitchToThisCompany')#</a>
                                                        </cfif>
                                                            <a class="dropdown-item" href="#application.mainURL#/customer?change_tenant=#qTenants.intCustomerID#"><cfif qTenants.blnActive eq 1>#getTrans('btnDeactivate')#<cfelse>#getTrans('btnActivate')#</cfif></a>
                                                        <cfif qTenants.intCustomerID neq session.customer_id>
                                                            <a class="dropdown-item cursor-pointer" onclick="sweetAlert('warning', '#application.mainURL#/customer?delete=#qTenants.intCustomerID#', '#getTrans("titDeleteTenant")#', '#getTrans("txtDeleteTenantConfirmText")#', '#getTrans("btnNoCancel")#', '#getTrans("btnYesDelete")#')">#getTrans('btnDelete')#</a>
                                                        </cfif>
                                                    </div>
                                                </cfif>
                                            </div>
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
    </cfoutput>
    

</div>










<!--- <div class="page-wrapper">
    <div class="container-xl">
        <cfoutput>
        <div class="row mb-3">
            <div class="col-md-12 col-lg-12">
                <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12" style="float:left;">
                    <h4 class="page-title">#getTrans('titTenantOverview')#</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                        <li class="breadcrumb-item active">#getTrans('titTenantOverview')#</li>
                    </ol>
                </div>
                <div class="page-header col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                    <cfif session.superadmin>
                        <a href="#application.mainURL#/account-settings/tenant/new" class="btn btn-primary" style="white-space: normal; width: 205px;">
                            <i class="fas fa-plus pe-3"></i> #getTrans('btnNewTenant')#
                        </a>
                    </cfif>
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
                                    <th>#getTrans('titLogo')#</th>
                                    <th>#getTrans('formCompanyName')#</th>
                                    <th>#getTrans('formContactName')#</th>
                                    <th class="text-center">#getTrans('formStandard')#</th>
                                    <th class="text-center">#getTrans('titActive')#</th>
                                    <th class="w-1"></th>
                                </tr>
                            </thead>
                            <tbody>
                            <!--- ## qTenants is in /backend/core/views/tenant_changer.cfm (header.cfm) --->
                            <cfloop query="qTenants">
                                <tr>
                                    <td>
                                        <cfif not len(trim(qTenants.strLogo))>
                                            <div style="margin-right:20px" class="avatar avatar-md brround">#left(qTenants.strCompanyName,2)#</div>
                                        <cfelse>
                                            <img src="#application.mainURL#/userdata/images/logos/#qTenants.strLogo#" style="margin-right:20px" class="avatar avatar-md brround" alt="Companylogo">
                                        </cfif>
                                    </td>
                                    <td>#qTenants.strCompanyName#</td>
                                    <td>#qTenants.strContactPerson#</td>
                                    <td class="text-center"><cfif qTenants.blnStandard><i class="fa fa-check text-green"></i><cfelse><i class="fa fa-close text-red"></cfif></td>
                                    <td class="text-center"><cfif qTenants.blnActive><i class="fa fa-check text-green"></i><cfelse><i class="fa fa-close text-red"></cfif></td>
                                    <td class="text-end">
                                        <div class="btn-list flex-nowrap">
                                            <cfif qTenants.intCustParentID gt 0>
                                                <button type="button" class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown">
                                                    #getTrans('blnAction')#
                                                </button>
                                                <div class="dropdown-menu dropdown-menu-end">
                                                    <cfif qTenants.blnActive eq 1>
                                                        <a class="dropdown-item" href="#application.mainURL#/global?switch=#qTenants.intCustomerID#">#getTrans('btnSwitchToThisCompany')#</a>
                                                    </cfif>
                                                        <a class="dropdown-item" href="#application.mainURL#/customer?change_tenant=#qTenants.intCustomerID#"><cfif qTenants.blnActive eq 1>#getTrans('btnDeactivate')#<cfelse>#getTrans('btnActivate')#</cfif></a>
                                                    <cfif qTenants.intCustomerID neq session.customer_id>
                                                        <a class="dropdown-item cursor-pointer" onclick="sweetAlert('warning', '#application.mainURL#/customer?delete=#qTenants.intCustomerID#', '#getTrans("titDeleteTenant")#', '#getTrans("txtDeleteTenantConfirmText")#', '#getTrans("btnNoCancel")#', '#getTrans("btnYesDelete")#')">#getTrans('btnDelete')#</a>
                                                    </cfif>
                                                </div>
                                            </cfif>
                                        </div>
                                    </td>
                                </tr>
                            </cfloop>
                            </tbody>
                        </table>
                    </div>

                </div>
            </div>
        </div>

        </cfoutput>

    </div>
    
</div> --->


