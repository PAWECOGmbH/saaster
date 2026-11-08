component output="false" hint="Request-local invitation mail using the existing translation and mail layout." {
    public void function send(required string email, required numeric organizationID, required string token, required string language) {
        local.mailLanguage = arguments.language;
        variables.getTrans = (key) => application.objLanguage.getTrans(key, mailLanguage);
        local.organization = application.objMembershipAccess.organizationForCustomer(arguments.organizationID);
        variables.mailTitle = replace(application.objLanguage.getTrans("txtInvitationMailSubject", arguments.language), "{organization}", local.organization.name, "all");
        variables.mailType = "html";
        variables.mailContent = '<p>' & encodeForHTML(replace(application.objLanguage.getTrans("txtInvitationIntro", arguments.language), "{organization}", local.organization.name, "all")) & '</p>'
            & '<p><a class="mail-btn" href="' & encodeForHTMLAttribute(application.mainURL & '/organization-invitation?token=' & arguments.token) & '">'
            & encodeForHTML(application.objLanguage.getTrans("btnAcceptInvitation", arguments.language)) & '</a></p>';
        mail to=arguments.email from=application.fromEmail subject=variables.mailTitle type="html" {
            include template="/config.cfm";
            include template="/frontend/core/mail_design.cfm";
        }
    }
}
