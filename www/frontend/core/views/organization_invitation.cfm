<cfscript>
    if (structKeyExists(url, "token") and reFind("^[a-fA-F0-9]{64}$", url.token)) {
        session.pendingOrganizationInvitation = url.token;
    }
    invitationInfo = application.objOrganizationInvitation.inspect(session.pendingOrganizationInvitation ?: "");
    invitationIdentity = val(session.user_id ?: (session.invitation_authenticated_user ?: 0));
    invitationSignedIn = invitationIdentity gt 0 and application.objOrganizationInvitation.permitsIdentityLogin(invitationIdentity, session.pendingOrganizationInvitation ?: "");
    header name="Referrer-Policy" value="no-referrer";
</cfscript>
<cfoutput>
<div class="container py-5">
    <div class="row justify-content-center"><div class="col-lg-7">
        <div class="card"><div class="card-body">
            <h1 class="h3">#getTrans('btnAcceptInvitation')#</h1>
            <cfif structKeyExists(session, 'alert')>#session.alert#</cfif>
            <cfif not invitationInfo.valid>
                <p>#getTrans('msgInvitationInvalid')#</p>
            <cfelse>
                <p>#encodeForHTML(replace(getTrans('txtInvitationIntro'), '{organization}', invitationInfo.organizationName, 'all'))#</p>
                <p class="text-break"><strong>#encodeForHTML(invitationInfo.email)#</strong></p>
                <p>#getTrans('txtMembershipOrganizationRole')#: #getTrans(application.objMembershipAccess.roleLabel(invitationInfo.role))#</p>
                <cfif invitationInfo.role neq 'organization.member'><p>#getTrans('txtMembershipInherited')#</p></cfif>
                <ul>
                    <cfloop array="#invitationInfo.tenants#" item="invitationTenant">
                        <cfset invitationCustomer = application.objCustomer.getCustomerData(invitationTenant.customerID)>
                        <li>#encodeForHTML(invitationCustomer.companyName)# · #getTrans(application.objMembershipAccess.roleLabel(invitationTenant.role))#</li>
                    </cfloop>
                </ul>
                <cfif invitationInfo.needsLogin and not invitationSignedIn>
                    <p>#getTrans('txtInvitationLogin')#</p>
                    <a href="#application.objGlobal.getLink('templates/login.cfm')#" class="btn btn-primary">#getTrans('formSignIn')#</a>
                <cfelse>
                    <form method="post" action="#application.mainURL#/accept-organization-invitation">#csrfField()#
                        <input type="hidden" name="accept_invitation" value="1">
                        <input type="hidden" name="invitation_token" value="#encodeForHTMLAttribute(session.pendingOrganizationInvitation)#">
                        <cfif not invitationInfo.needsLogin>
                            <div class="mb-3"><label class="form-label" for="invitation-name">#getTrans('txtInvitationName')#</label><input id="invitation-name" class="form-control" name="name" maxlength="100" autocomplete="name" required></div>
                            <div class="mb-3"><label class="form-label" for="invitation-password">#getTrans('txtInvitationPassword')#</label><input id="invitation-password" class="form-control" name="password" type="password" minlength="#application.objGlobal.passwordMinLength()#" maxlength="1024" autocomplete="new-password" required></div>
                        </cfif>
                        <button class="btn btn-primary" type="submit">#getTrans('btnAcceptInvitation')#</button>
                    </form>
                </cfif>
            </cfif>
        </div></div>
    </div></div>
</div>
</cfoutput>
