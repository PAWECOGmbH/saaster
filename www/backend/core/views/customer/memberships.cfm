<cfscript>
    membershipData = application.objMembershipAccess.managementData(session.user_id, session.customer_id);
    roleLabels = application.objMembershipAccess;
    if (not membershipData.organization.enabled) {
        membershipPreview = application.objMembershipMigration.preview(membershipData.organization.id);
        previewOwner = val(session.membershipPreviewOwner ?: membershipPreview.suggestedOwnerUserID);
        if (not arrayFind(membershipPreview.ownerCandidates, previewOwner)) {
            previewOwner = membershipPreview.suggestedOwnerUserID;
        }
        membershipPreview = application.objMembershipMigration.preview(membershipData.organization.id, previewOwner);
        blockingIssues = membershipPreview.issues.filter((issue) => not listFind("scoped_superadmin,owner_access_expansion", issue.issueCode));
    }
</cfscript>
<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">
        <div class="row mb-3">
            <div class="col-md-12 col-lg-12 mb-3">
                <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-12 float-start">
                    <h4 class="page-title">#getTrans('titMemberships')#</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                        <li class="breadcrumb-item active">#getTrans('titMemberships')#</li>
                    </ol>
                </div>
                <cfif membershipData.organization.enabled and membershipData.manageOrganization>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-12 align-items-sm-end float-start">
                        <a href="#application.mainURL#/account-settings/user/new" class="btn btn-primary">
                            <i class="ti ti-plus pe-3" aria-hidden="true"></i> #getTrans('btnNewUser')#
                        </a>
                    </div>
                </cfif>
            </div>
            <cfif structKeyExists(session, "alert")>#session.alert#</cfif>
        </div>
        <div class="row">
            <div class="col-md-12 col-lg-12">
                <cfif not membershipData.organization.enabled>
                    <div class="card mb-3">
                        <div class="card-header gap-3">
                            <h3 class="card-title">#getTrans('txtMembershipSetup')#</h3>
                            <button type="button" class="btn btn-icon btn-ghost-secondary ms-auto flex-shrink-0" data-bs-toggle="modal" data-bs-target="##membership-role-help" aria-controls="membership-role-help" aria-label="#encodeForHTMLAttribute(getTrans('titMembershipRoleHelp'))#" title="#encodeForHTMLAttribute(getTrans('titMembershipRoleHelp'))#">
                                <i class="ti ti-help-circle" aria-hidden="true"></i>
                            </button>
                        </div>
                        <div class="card-body">
                            <p>#getTrans('txtMembershipSetupInfo')#</p>
                            <p class="text-secondary">#getTrans('txtMembershipReview')#</p>
                            <form method="post" action="#application.mainURL#/memberships" class="row g-2 align-items-end mb-3">#csrfField()#
                                <input type="hidden" name="member_action" value="preview">
                                <div class="col-md-8">
                                    <label class="form-label" for="setup-owner">#getTrans('txtMembershipOwner')#</label>
                                    <select id="setup-owner" name="ownerID" class="form-select" required>
                                        <option value="">—</option>
                                        <cfloop query="membershipData.members">
                                            <cfif arrayFind(membershipPreview.ownerCandidates, membershipData.members.intUserID)>
                                                <option value="#membershipData.members.intUserID#"<cfif previewOwner eq membershipData.members.intUserID> selected</cfif>>#encodeForHTML(membershipData.members.strFirstName & ' ' & membershipData.members.strLastName & ' · ' & membershipData.members.strEmail)#</option>
                                            </cfif>
                                        </cfloop>
                                    </select>
                                </div>
                                <div class="col-md-4"><button type="submit" class="btn btn-outline-primary">#getTrans('txtMembershipPreview')#</button></div>
                            </form>
                            <div class="table-responsive">
                                <table class="table table-vcenter">
                                    <thead><tr><th>#getTrans('titUser')#</th><th>#getTrans('txtMembershipOrganizationRole')#</th><th>#getTrans('txtMembershipTenantAccess')#</th></tr></thead>
                                    <tbody>
                                    <cfloop array="#membershipPreview.members#" item="proposedMember">
                                        <cfset previewUser = membershipData.members.filter((member) => member.intUserID eq proposedMember.userID)>
                                        <tr>
                                            <td>#encodeForHTML(previewUser.strFirstName & ' ' & previewUser.strLastName)#<div class="text-secondary">#encodeForHTML(previewUser.strEmail)#</div></td>
                                            <td>#getTrans(roleLabels.roleLabel(proposedMember.role))#<cfif proposedMember.status eq 'suspended'><div class="text-warning">#getTrans('txtMembershipSuspended')#</div></cfif></td>
                                            <td>
                                                <cfif proposedMember.role neq 'organization.member'>#getTrans('txtMembershipInherited')#<cfelse>
                                                    <cfloop array="#membershipPreview.assignments#" item="proposedAssignment">
                                                        <cfif proposedAssignment.userID eq proposedMember.userID>
                                                            <cfset previewTenant = membershipData.tenants.filter((tenant) => tenant.intCustomerID eq proposedAssignment.customerID)>
                                                            <div>#encodeForHTML(previewTenant.strCompanyName)# · #getTrans(roleLabels.roleLabel(proposedAssignment.role))#</div>
                                                        </cfif>
                                                    </cfloop>
                                                </cfif>
                                            </td>
                                        </tr>
                                    </cfloop>
                                    </tbody>
                                </table>
                            </div>
                            <cfif arrayLen(blockingIssues)>
                                <div class="alert alert-warning">#getTrans('txtMembershipIssues')#
                                    <ul class="mb-0"><cfloop array="#blockingIssues#" item="membershipIssue"><li>#getTrans('txtMembershipIssue_' & membershipIssue.issueCode)# · #getTrans('titUser')# #membershipIssue.userID# · #getTrans('titMandanten')# #membershipIssue.customerID#</li></cfloop></ul>
                                </div>
                            <cfelse>
                                <form method="post" action="#application.mainURL#/memberships">#csrfField()#
                                    <input type="hidden" name="member_action" value="activate">
                                    <input type="hidden" name="ownerID" value="#previewOwner#">
                                    <label class="form-check mb-3"><input type="checkbox" class="form-check-input" name="reviewed" value="1" required><span class="form-check-label">#getTrans('txtMembershipApprove')#</span></label>
                                    <button type="submit" class="btn btn-primary">#getTrans('txtMembershipActivate')#</button>
                                </form>
                            </cfif>
                        </div>
                    </div>
                <cfelse>
                    <div class="card">
                        <div class="card-header gap-3">
                            <h3 class="card-title">#getTrans('txtMembershipsDescription')#</h3>
                            <button type="button" class="btn btn-icon btn-ghost-secondary ms-auto flex-shrink-0" data-bs-toggle="modal" data-bs-target="##membership-role-help" aria-controls="membership-role-help" aria-label="#encodeForHTMLAttribute(getTrans('titMembershipRoleHelp'))#" title="#encodeForHTMLAttribute(getTrans('titMembershipRoleHelp'))#">
                                <i class="ti ti-help-circle" aria-hidden="true"></i>
                            </button>
                        </div>
                        <div class="table-responsive">
                            <table class="table card-table table-vcenter text-nowrap">
                                <thead>
                                    <tr>
                                        <th>#getTrans('titUser')#</th>
                                        <th>#getTrans('txtMembershipOrganizationRole')#</th>
                                        <th>#getTrans('txtMembershipTenantAccess')#</th>
                                        <th>#getTrans('titStatus')#</th>
                                        <th class="w-1"></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfloop query="membershipData.members">
                                        <cfset memberID = membershipData.members.intUserID>
                                        <cfset memberEditable = membershipData.manageOrganization and not membershipData.members.blnSysAdmin and (membershipData.owner or not len(membershipData.members.role) or membershipData.members.role eq 'organization.member')>
                                        <cfset tenantEditable = not membershipData.members.blnSysAdmin and membershipData.members.role eq 'organization.member'>
                                        <cfset memberActive = membershipData.members.blnActive and membershipData.members.status eq 'active'>
                                        <tr data-member-id="#memberID#">
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <span class="avatar avatar-md brround me-3" aria-hidden="true">#encodeForHTML(ucase(left(membershipData.members.strFirstName, 1) & left(membershipData.members.strLastName, 1)))#</span>
                                                    <div>
                                                        <div>#encodeForHTML(membershipData.members.strFirstName & ' ' & membershipData.members.strLastName)#</div>
                                                        <div class="text-muted">#encodeForHTML(membershipData.members.strEmail)#</div>
                                                        <cfif membershipData.members.blnSysAdmin><span class="badge bg-secondary-lt mt-1">#getTrans('txtMembershipPlatform')#</span></cfif>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>#getTrans(len(membershipData.members.role) ? roleLabels.roleLabel(membershipData.members.role) : 'txtMembershipRemoved')#</td>
                                            <td>
                                                <cfif len(membershipData.members.role) and membershipData.members.role neq 'organization.member'>
                                                    <span class="text-muted">#getTrans('txtMembershipInherited')#</span>
                                                <cfelse>
                                                    <cfset memberAssignments = membershipData.assignments.filter((assignment) => assignment.intUserID eq memberID)>
                                                    <cfif memberAssignments.recordCount>
                                                        <cfloop query="memberAssignments">
                                                            <cfset assignedTenant = membershipData.tenants.filter((tenant) => tenant.intCustomerID eq memberAssignments.intCustomerID)>
                                                            <div>
                                                                #encodeForHTML(assignedTenant.strCompanyName)# · #getTrans(roleLabels.roleLabel(memberAssignments.strRoleKey))#
                                                                <cfif memberAssignments.strStatus eq 'suspended' or not assignedTenant.blnActive>
                                                                    <span class="text-muted">(#getTrans('txtMembershipSuspended')#)</span>
                                                                </cfif>
                                                            </div>
                                                        </cfloop>
                                                    <cfelse>
                                                        <span class="text-muted">#getTrans('txtMembershipNoAccess')#</span>
                                                    </cfif>
                                                </cfif>
                                            </td>
                                            <td>
                                                <i class="ti #memberActive ? 'ti-check text-green' : 'ti-x text-red'# me-1" aria-hidden="true"></i>
                                                <cfif not len(membershipData.members.role)>
                                                    #getTrans('txtMembershipRemoved')#
                                                <cfelseif not membershipData.members.blnActive>
                                                    #getTrans('txtMembershipInactiveAccount')#
                                                <cfelse>
                                                    #getTrans(memberActive ? 'txtMembershipActive' : 'txtMembershipSuspended')#
                                                </cfif>
                                            </td>
                                            <td class="text-end">
                                                <cfif memberEditable or tenantEditable>
                                                    <div class="btn-list flex-nowrap justify-content-end">
                                                        <button type="button" class="btn" data-bs-toggle="modal" data-bs-target="##membership-#memberID#">#getTrans('btnEdit')#</button>
                                                        <cfif memberEditable and len(membershipData.members.role)>
                                                            <button type="button" class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown" aria-expanded="false">#getTrans('blnAction')#</button>
                                                            <div class="dropdown-menu dropdown-menu-end">
                                                                <cfif memberActive and membershipData.members.activationPending and memberID neq session.user_id>
                                                                    <form method="post" action="#application.mainURL#/memberships" class="m-0">#csrfField()#
                                                                        <input type="hidden" name="member_action" value="resend_invitation"><input type="hidden" name="userID" value="#memberID#">
                                                                        <button type="submit" class="dropdown-item">#getTrans('btnSendActivLink')#</button>
                                                                    </form>
                                                                </cfif>
                                                                <cfif membershipData.owner and memberID neq session.user_id and membershipData.members.status eq 'active' and membershipData.members.blnActive>
                                                                    <button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="##membership-transfer-#memberID#">#getTrans('txtMembershipTransferOrganization')#</button>
                                                                </cfif>
                                                                <button type="button" class="dropdown-item text-danger" data-bs-toggle="modal" data-bs-target="##membership-remove-#memberID#">#getTrans('txtMembershipRemoveOrganization')#</button>
                                                            </div>
                                                        </cfif>
                                                    </div>
                                                </cfif>
                                            </td>
                                        </tr>
                                    </cfloop>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </cfif>
            </div>
        </div>
    </div>
</div>

<!--- Keep dialogs outside the table and page container so their markup and scrolling stay independent. --->
<div id="membership-role-help" class="modal modal-blur fade" tabindex="-1" aria-labelledby="membership-role-help-title" aria-describedby="membership-role-help-intro" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="membership-role-help-title">#getTrans('titMembershipRoleHelp')#</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="#encodeForHTMLAttribute(getTrans('btnClose'))#"></button>
            </div>
            <div class="modal-body">
                <p id="membership-role-help-intro">#getTrans('txtMembershipRoleHelpIntro')#</p>
                <div class="table-responsive">
                    <table class="table table-vcenter text-wrap mb-0 membership-role-help-table" aria-labelledby="membership-role-help-title">
                        <thead>
                            <tr>
                                <th scope="col" class="w-25">#getTrans('txtMembershipRoleHelpRole')#</th>
                                <th scope="col">#getTrans('txtMembershipRoleHelpPermissions')#</th>
                            </tr>
                        </thead>
                        <cfloop list="organization,tenant" item="roleHelpScope">
                            <tbody>
                                <tr class="bg-light"><th colspan="2" scope="rowgroup" class="text-wrap">#getTrans('txtMembershipRoleHelp_' & roleHelpScope)#</th></tr>
                                <cfloop list="#roleHelpScope eq 'organization' ? 'organization.owner,organization.admin,organization.member' : 'tenant.admin,tenant.editor,tenant.viewer'#" item="roleHelpKey">
                                    <tr>
                                        <th scope="row" class="text-wrap text-break align-top">#getTrans(roleLabels.roleLabel(roleHelpKey))#</th>
                                        <td>#getTrans('txtMembershipRoleHelp_' & replace(roleHelpKey, '.', '_', 'all'))#</td>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </cfloop>
                    </table>
                </div>
                <div class="text-secondary small mt-3">
                    <p>#getTrans('txtMembershipRoleHelpInherited')#</p>
                    <p class="mb-0">#getTrans('txtMembershipRoleHelpPlatform')#</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn" data-bs-dismiss="modal">#getTrans('btnClose')#</button>
            </div>
        </div>
    </div>
</div>


<cfif membershipData.organization.enabled>
    <cfloop query="membershipData.members">
        <cfset memberID = membershipData.members.intUserID>
        <cfset memberName = trim(membershipData.members.strFirstName & ' ' & membershipData.members.strLastName)>
        <cfset memberEditable = membershipData.manageOrganization and not membershipData.members.blnSysAdmin and (membershipData.owner or not len(membershipData.members.role) or membershipData.members.role eq 'organization.member')>
        <cfset tenantEditable = not membershipData.members.blnSysAdmin and membershipData.members.role eq 'organization.member'>
        <cfset inheritedAccess = listFind('organization.owner,organization.admin', membershipData.members.role) gt 0>
        <cfset canRemoveMember = memberEditable and len(membershipData.members.role)>
        <cfset canTransferOwnership = canRemoveMember and membershipData.owner and memberID neq session.user_id and membershipData.members.status eq 'active' and membershipData.members.blnActive>
        <cfif memberEditable or tenantEditable>
            <div id="membership-#memberID#" class="modal modal-blur fade" tabindex="-1" aria-labelledby="membership-title-#memberID#" aria-hidden="true">
                <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
                    <form method="post" action="#application.mainURL#/memberships" class="modal-content" data-membership-form>#csrfField()#
                        <input type="hidden" name="member_action" value="save_member"><input type="hidden" name="userID" value="#memberID#">
                        <div class="modal-header">
                            <div class="me-2">
                                <h5 class="modal-title" id="membership-title-#memberID#">#encodeForHTML(memberName)#</h5>
                                <div class="text-muted text-break">#encodeForHTML(membershipData.members.strEmail)#</div>
                            </div>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="#encodeForHTMLAttribute(getTrans('btnClose'))#"></button>
                        </div>
                        <div class="modal-body">
                            <p class="text-secondary">#getTrans('txtMembershipOrganization')#: <strong>#encodeForHTML(membershipData.organization.name)#</strong></p>
                            <cfif memberEditable>
                                <div class="row g-3">
                                    <div class="col-md-7"><label class="form-label" for="org-role-#memberID#">#getTrans('txtMembershipOrganizationRole')#</label>
                                        <select id="org-role-#memberID#" class="form-select" name="organization_role" data-organization-role>
                                            <cfloop list="organization.member,organization.admin,organization.owner" item="availableRole">
                                                <cfif membershipData.owner or availableRole eq 'organization.member'><option value="#availableRole#"<cfif membershipData.members.role eq availableRole> selected</cfif>>#getTrans(roleLabels.roleLabel(availableRole))#</option></cfif>
                                            </cfloop>
                                        </select>
                                    </div>
                                    <div class="col-md-5"><label class="form-label" for="org-status-#memberID#">#getTrans('titStatus')#</label>
                                        <select id="org-status-#memberID#" class="form-select" name="organization_status"><option value="active">#getTrans('txtMembershipActive')#</option><option value="suspended"<cfif membershipData.members.status eq 'suspended'> selected</cfif>>#getTrans('txtMembershipSuspended')#</option></select>
                                    </div>
                                </div>
                            <cfelse>
                                <p>#getTrans('txtMembershipOrganizationRole')#: <strong>#getTrans(roleLabels.roleLabel(membershipData.members.role))#</strong> · #getTrans(membershipData.members.status eq 'active' ? 'txtMembershipActive' : 'txtMembershipSuspended')#</p>
                            </cfif>
                            <hr><h4>#getTrans('txtMembershipTenantAccess')#</h4>
                            <p class="text-secondary mb-0" data-membership-inherited<cfif not inheritedAccess> hidden</cfif>>#getTrans('txtMembershipInherited')#</p>
                            <fieldset class="m-0 p-0 border-0" data-membership-tenants<cfif inheritedAccess> disabled hidden</cfif>>
                                <cfloop query="membershipData.tenants">
                                    <cfset tenantAssignment = membershipData.assignments.filter((assignment) => assignment.intUserID eq memberID and assignment.intCustomerID eq membershipData.tenants.intCustomerID)>
                                    <div class="row g-3 mb-3" data-membership-tenant>
                                        <div class="col-md-7"><label class="form-label" for="tenant-#memberID#-#membershipData.tenants.intCustomerID#">#encodeForHTML(membershipData.tenants.strCompanyName)#</label>
                                            <select id="tenant-#memberID#-#membershipData.tenants.intCustomerID#" class="form-select" name="tenant_role_#membershipData.tenants.intCustomerID#" data-tenant-role<cfif not membershipData.tenants.blnActive> disabled</cfif>>
                                                <option value="">#getTrans('txtMembershipNoAccess')#</option>
                                                <cfloop list="tenant.viewer,tenant.editor,tenant.admin" item="availableRole"><option value="#availableRole#"<cfif tenantAssignment.strRoleKey eq availableRole> selected</cfif>>#getTrans(roleLabels.roleLabel(availableRole))#</option></cfloop>
                                            </select>
                                        </div>
                                        <div class="col-md-5"><label class="form-label" for="tenant-status-#memberID#-#membershipData.tenants.intCustomerID#">#getTrans('titStatus')#</label>
                                            <select id="tenant-status-#memberID#-#membershipData.tenants.intCustomerID#" name="tenant_status_#membershipData.tenants.intCustomerID#" class="form-select" data-tenant-status<cfif not membershipData.tenants.blnActive or not len(tenantAssignment.strRoleKey)> disabled</cfif>><option value="active">#getTrans('txtMembershipActive')#</option><option value="suspended"<cfif tenantAssignment.strStatus eq 'suspended'> selected</cfif>>#getTrans('txtMembershipSuspended')#</option></select>
                                        </div>
                                    </div>
                                </cfloop>
                            </fieldset>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn" data-bs-dismiss="modal">#getTrans('btnClose')#</button>
                            <button type="submit" class="btn btn-primary">#getTrans('txtMembershipSaveAll')#</button>
                        </div>
                    </form>
                </div>
            </div>
            <cfif canRemoveMember>
                <div id="membership-remove-#memberID#" class="modal modal-blur fade" tabindex="-1" aria-labelledby="membership-remove-title-#memberID#" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" role="document">
                        <form method="post" action="#application.mainURL#/memberships" class="modal-content">#csrfField()#
                            <input type="hidden" name="member_action" value="remove_org"><input type="hidden" name="userID" value="#memberID#">
                            <div class="modal-header">
                                <h5 class="modal-title" id="membership-remove-title-#memberID#">#getTrans('txtMembershipRemoveOrganization')#</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="#encodeForHTMLAttribute(getTrans('btnClose'))#"></button>
                            </div>
                            <div class="modal-body">
                                <p>#encodeForHTML(replace(replace(getTrans('txtMembershipRemoveDetails'), '{organization}', membershipData.organization.name, 'all'), '{member}', memberName, 'all'))#</p>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn" data-bs-dismiss="modal">#getTrans('txtMembershipCancel')#</button>
                                <button type="submit" class="btn btn-danger">#getTrans('txtMembershipRemoveOrganization')#</button>
                            </div>
                        </form>
                    </div>
                </div>
            </cfif>
            <cfif canTransferOwnership>
                <div id="membership-transfer-#memberID#" class="modal modal-blur fade" tabindex="-1" aria-labelledby="membership-transfer-title-#memberID#" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" role="document">
                        <form method="post" action="#application.mainURL#/memberships" class="modal-content">#csrfField()#
                            <input type="hidden" name="member_action" value="transfer"><input type="hidden" name="userID" value="#memberID#">
                            <div class="modal-header">
                                <h5 class="modal-title" id="membership-transfer-title-#memberID#">#getTrans('txtMembershipTransferOrganization')#</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="#encodeForHTMLAttribute(getTrans('btnClose'))#"></button>
                            </div>
                            <div class="modal-body">
                                <p>#encodeForHTML(replace(replace(getTrans('txtMembershipTransferDetails'), '{organization}', membershipData.organization.name, 'all'), '{member}', memberName, 'all'))#</p>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn" data-bs-dismiss="modal">#getTrans('txtMembershipCancel')#</button>
                                <button type="submit" class="btn btn-primary">#getTrans('txtMembershipTransfer')#</button>
                            </div>
                        </form>
                    </div>
                </div>
            </cfif>
        </cfif>
    </cfloop>
</cfif>
</cfoutput>
<script>
    document.querySelectorAll('[data-membership-form]').forEach(function (form) {
        function updateAccessFields() {
            const role = form.querySelector('[data-organization-role]');
            const inherited = role && role.value !== 'organization.member';
            const tenants = form.querySelector('[data-membership-tenants]');
            tenants.hidden = inherited;
            tenants.disabled = inherited;
            form.querySelector('[data-membership-inherited]').hidden = !inherited;
            form.querySelectorAll('[data-membership-tenant]').forEach(function (row) {
                const tenantRole = row.querySelector('[data-tenant-role]');
                row.querySelector('[data-tenant-status]').disabled = tenantRole.disabled || !tenantRole.value;
            });
        }
        form.addEventListener('change', updateAccessFields);
        updateAccessFields();
    });
</script>
