<cfscript>
    invitations = application.objOrganizationInvitation.listForOrganization(session.user_id, membershipData.organization.id);
</cfscript>
<cfoutput>
<div class="card mt-4">
    <div class="card-header"><h3 class="card-title">#getTrans('titOrganizationInvitations')#</h3></div>
    <div class="table-responsive">
        <table class="table table-vcenter card-table">
            <thead><tr><th>#getTrans('txtInvitationEmail')#</th><th>#getTrans('txtMembershipOrganizationRole')#</th><th>#getTrans('titStatus')#</th><th>#getTrans('txtInvitationExpiry')#</th><th></th></tr></thead>
            <tbody><cfloop query="invitations">
                <tr>
                    <td>#encodeForHTML(invitations.strEmail)#</td>
                    <td>#getTrans(application.objMembershipAccess.roleLabel(invitations.strRoleKey))#</td>
                    <td>#getTrans('txtInvitation_' & invitations.status)#</td>
                    <td>#dateFormat(invitations.dtmExpiresAt, 'dd.mm.yyyy')#</td>
                    <td class="text-end">
                        <cfif listFind('pending,expired', invitations.status) and (membershipData.owner or invitations.strRoleKey eq 'organization.member')>
                            <div class="dropdown">
                                <button class="btn dropdown-toggle" type="button" data-bs-toggle="dropdown">#getTrans('blnAction')#</button>
                                <div class="dropdown-menu dropdown-menu-end">
                                    <form method="post" action="#application.mainURL#/memberships">#csrfField()#
                                        <input type="hidden" name="member_action" value="resend_pending"><input type="hidden" name="invitationID" value="#invitations.intInvitationID#">
                                        <button class="dropdown-item" type="submit">#getTrans('btnResendInvitation')#</button>
                                    </form>
                                    <form method="post" action="#application.mainURL#/memberships">#csrfField()#
                                        <input type="hidden" name="member_action" value="revoke_pending"><input type="hidden" name="invitationID" value="#invitations.intInvitationID#">
                                        <button class="dropdown-item text-danger" type="submit">#getTrans('btnRevokeInvitation')#</button>
                                    </form>
                                </div>
                            </div>
                        </cfif>
                    </td>
                </tr>
            </cfloop></tbody>
        </table>
    </div>
</div>
<div id="membership-invite" class="modal modal-blur fade" tabindex="-1" aria-labelledby="membership-invite-title" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <form method="post" action="#application.mainURL#/memberships" class="modal-content" data-invitation-form>#csrfField()#
            <input type="hidden" name="member_action" value="invite">
            <div class="modal-header">
                <h5 class="modal-title" id="membership-invite-title">#getTrans('btnInviteMember')#</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="#encodeForHTMLAttribute(getTrans('btnClose'))#"></button>
            </div>
            <div class="modal-body">
                <p>#getTrans('txtInvitationCreateInfo')#</p>
                <p class="text-secondary">#getTrans('txtMembershipOrganization')#: <strong>#encodeForHTML(membershipData.organization.name)#</strong></p>
                <div class="mb-3"><label class="form-label" for="invite-email">#getTrans('txtInvitationEmail')#</label><input id="invite-email" type="email" name="email" class="form-control" required maxlength="100"></div>
                <div class="mb-3"><label class="form-label" for="invite-organization-role">#getTrans('txtMembershipOrganizationRole')#</label>
                    <select id="invite-organization-role" name="invite_organization_role" class="form-select">
                        <cfloop list="organization.member,organization.admin" item="inviteRole">
                            <cfif membershipData.owner or inviteRole eq 'organization.member'><option value="#inviteRole#">#getTrans(application.objMembershipAccess.roleLabel(inviteRole))#</option></cfif>
                        </cfloop>
                    </select>
                </div>
                <p class="text-secondary" data-invite-inherited hidden>#getTrans('txtMembershipInherited')#</p>
                <fieldset data-invite-tenants>
                    <legend class="form-label">#getTrans('txtMembershipTenantAccess')#</legend>
                    <cfloop query="membershipData.tenants">
                        <cfif membershipData.tenants.blnActive>
                            <div class="mb-3"><label class="form-label" for="invite-tenant-#membershipData.tenants.intCustomerID#">#encodeForHTML(membershipData.tenants.strCompanyName)#</label>
                                <select id="invite-tenant-#membershipData.tenants.intCustomerID#" name="invite_role_#membershipData.tenants.intCustomerID#" class="form-select">
                                    <option value="">#getTrans('txtMembershipNoAccess')#</option>
                                    <cfloop list="tenant.viewer,tenant.editor,tenant.admin" item="inviteRole"><option value="#inviteRole#"<cfif membershipData.tenants.intCustomerID eq session.customer_id and inviteRole eq 'tenant.viewer'> selected</cfif>>#getTrans(application.objMembershipAccess.roleLabel(inviteRole))#</option></cfloop>
                                </select>
                            </div>
                        </cfif>
                    </cfloop>
                </fieldset>
            </div>
            <div class="modal-footer"><button type="button" class="btn" data-bs-dismiss="modal">#getTrans('btnClose')#</button><button type="submit" class="btn btn-primary">#getTrans('btnInviteMember')#</button></div>
        </form>
    </div>
</div>
</cfoutput>
<script>
    document.querySelectorAll('[data-invitation-form]').forEach(function (form) {
        const role = form.querySelector('[name="invite_organization_role"]');
        role.addEventListener('change', function () {
            const inherited = role.value !== 'organization.member';
            form.querySelector('[data-invite-tenants]').disabled = inherited;
            form.querySelector('[data-invite-tenants]').hidden = inherited;
            form.querySelector('[data-invite-inherited]').hidden = !inherited;
        });
    });
</script>
