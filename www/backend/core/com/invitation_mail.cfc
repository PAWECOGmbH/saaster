component output="false" hint="Request-local invitation mail using the existing translation and mail layout." {
    public void function send(required string email, required numeric organizationID, required string token, required string language) {
        local.mailLanguage = arguments.language;
        variables.mailLanguage = arguments.language;
        variables.getTrans = (key) => application.objLanguage.getTrans(key, mailLanguage);
        local.organization = application.objMembershipAccess.organizationForCustomer(arguments.organizationID);
        variables.mailTitle = replace(application.objLanguage.getTrans("txtInvitationMailSubject", arguments.language), "{organization}", local.organization.name, "all");
        variables.mailType = "html";
        local.recipient = queryExecute(
            options = {datasource:application.datasource},
            params = {email:{type:"varchar",value:arguments.email}},
            sql = "SELECT strFirstName,strLastName FROM users WHERE strEmail=:email AND blnActive=1 LIMIT 2"
        );
        local.greeting = application.objLanguage.getTrans("titHello",arguments.language);
        if (local.recipient.recordCount eq 1) {
            local.name = trim((local.recipient.strFirstName ?: "") & " " & (local.recipient.strLastName ?: ""));
            if (len(local.name)) local.greeting &= " " & local.name;
        }
        variables.mailContent = '<p>' & encodeForHTML(local.greeting) & '</p>'
            & '<p>' & encodeForHTML(replace(application.objLanguage.getTrans("txtInvitationIntro", arguments.language), "{organization}", local.organization.name, "all")) & '</p>'
            & '<p><a class="mail-btn" href="' & encodeForHTMLAttribute(application.mainURL & '/organization-invitation?token=' & arguments.token) & '">'
            & encodeForHTML(application.objLanguage.getTrans("btnAcceptInvitation", arguments.language)) & '</a></p>';
        mail to=arguments.email from=application.fromEmail subject=variables.mailTitle type="html" {
            include template="/config.cfm";
            include template="/frontend/core/mail_design.cfm";
        }
    }
}
