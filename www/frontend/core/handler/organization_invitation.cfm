<cfscript>
    if (cgi.request_method neq "POST" or not structKeyExists(form, "accept_invitation") or not application.objGlobal.csrfVerify()) {
        header statuscode=403 statustext="Forbidden";
        abort;
    }
    if (structKeyExists(form, "accept_invitation")) {
        try {
            if ((form.invitation_token ?: "") neq (session.pendingOrganizationInvitation ?: "")) {
                throw(type="Saaster.Invitation.Invalid");
            }
            acceptedUserID = application.objOrganizationInvitation.accept(form.invitation_token,
                val(session.user_id ?: (session.invitation_authenticated_user ?: 0)), form.password ?: "", form.name ?: "");
            structDelete(session, "pendingOrganizationInvitation");
            structDelete(session, "invitation_authenticated_user");
            getAlert("msgInvitationAccepted", "success");
            location url=application.objGlobal.getLink("templates/login.cfm") addtoken=false;
        } catch (Saaster.Invitation error) {
            getAlert("msgInvitationInvalid", "warning");
            location url="#application.mainURL#/organization-invitation" addtoken=false;
        }
    }
</cfscript>
