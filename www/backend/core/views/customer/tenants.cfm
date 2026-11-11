
<cfscript>
    // Only main companies have access to this resource
    if (getCustomerData.custParentID gt 0) {
        getAlert('msgNoAccess', 'danger');
        location url="#application.mainURL#/account-settings" addtoken="false";
    }
    qManagedTenants = application.objCustomer.getManagedTenants(session.user_id, session.customer_id);
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
                        <cfif session.superadmin and application.objCustomer.tenantCreationEnabled()>
                            <a href="#application.mainURL#/account-settings/tenant/new" class="btn btn-primary">
                                <i class="ti ti-plus pe-3"></i> #getTrans('btnNewTenant')#
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
                                <!--- Include inactive and pending tenants in management. --->
                                <cfloop query="qManagedTenants">
                                    <tr>
                                        <td>
                                            <cfif not len(trim(qManagedTenants.strLogo))>
                                                <cfif len(trim(qManagedTenants.strCompanyName))>
                                                    <div style="margin-right:20px" class="avatar avatar-md brround">#encodeForHTML(left(qManagedTenants.strCompanyName,2))#</div>
                                                <cfelse>
                                                    <div style="margin-right:20px" class="avatar avatar-md brround">#encodeForHTML(left(qManagedTenants.strContactPerson,2))#</div>
                                                </cfif>
                                            <cfelse>
                                                <img src="#application.mainURL#/userdata/images/logos/#encodeForHTML(qManagedTenants.strLogo)#" style="margin-right:20px" class="avatar avatar-md brround" alt="Companylogo">
                                            </cfif>
                                        </td>
                                        <td>
                                            <cfif len(trim(qManagedTenants.strCompanyName))>
                                                #encodeForHTML(qManagedTenants.strCompanyName)#
                                            <cfelse>
                                                #encodeForHTML(qManagedTenants.strContactPerson)# (#getTrans('formContactName')#)
                                            </cfif>
                                            <!--- #encodeForHTML(qManagedTenants.strCompanyName)# --->
                                        </td>
                                        <td>#encodeForHTML(qManagedTenants.strContactPerson)#</td>
                                        <td class="text-center"><cfif qManagedTenants.blnStandard><i class="ti ti-check text-green"></i><cfelse><i class="ti ti-x text-red"></cfif></td>
                                        <td class="text-center"><cfif qManagedTenants.deletionStatus eq 'failed'><span class="badge bg-danger-lt">#getTrans('txtAccountDeletionFailed')#</span><cfelseif qManagedTenants.deletionPending><span class="badge bg-warning-lt">#getTrans('txtAccountDeletionPending')#</span><cfelseif qManagedTenants.blnActive><i class="ti ti-check text-green"></i><cfelse><i class="ti ti-x text-red"></i></cfif></td>
                                        <td class="text-end">
                                            <div class="btn-list flex-nowrap">
                                                <cfif qManagedTenants.intCustParentID gt 0>
                                                    <button type="button" class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown">
                                                        #getTrans('blnAction')#
                                                    </button>
                                                    <div class="dropdown-menu dropdown-menu-end">
                                                        <cfif qManagedTenants.blnActive eq 1>
                                                            <a class="dropdown-item" href="#application.mainURL#/global?switch=#qManagedTenants.intCustomerID#&#csrfParam()#">#getTrans('btnSwitchToThisCompany')#</a>
                                                        </cfif>
                                                        <cfif not qManagedTenants.deletionPending>
                                                            <a class="dropdown-item" href="#application.mainURL#/customer?change_tenant=#qManagedTenants.intCustomerID#"><cfif qManagedTenants.blnActive eq 1>#getTrans('btnDeactivate')#<cfelse>#getTrans('btnActivate')#</cfif></a>
                                                        </cfif>
                                                        <cfif qManagedTenants.intCustomerID neq session.customer_id>
                                                            <cfif new backend.core.com.account_lifecycle().canDelete(session.user_id, qManagedTenants.intCustomerID)>
                                                                <button type="button" class="dropdown-item text-danger" data-bs-toggle="modal" data-bs-target="##delete-tenant-#qManagedTenants.intCustomerID#">#getTrans(qManagedTenants.deletionPending ? 'btnAccountDeletionRetry' : 'btnDelete')#</button>
                                                            </cfif>
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














<cfloop query="qManagedTenants">
    <cfif qManagedTenants.intCustParentID gt 0 and new backend.core.com.account_lifecycle().canDelete(session.user_id, qManagedTenants.intCustomerID)>
        <cfset deletionCustomerID = qManagedTenants.intCustomerID>
        <cfset deletionCustomerName = len(trim(qManagedTenants.strCompanyName)) ? qManagedTenants.strCompanyName : qManagedTenants.strContactPerson>
        <cfset deletionModalID = "delete-tenant-" & qManagedTenants.intCustomerID>
        <cfinclude template="account_delete_modal.cfm">
    </cfif>
</cfloop>
