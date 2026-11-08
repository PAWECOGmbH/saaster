component extends="tests.support.integration_spec" {
    function run() {
        describe("Organization invitation consent", () => {
            beforeEach(() => {
                logout();
                variables.org = variables.fixtures.createCustomer();
                variables.other = variables.fixtures.createCustomer();
                variables.owner = variables.fixtures.createUser(customerID = variables.org);
                variables.existing = variables.fixtures.createUser(customerID = variables.other, passwordHash = application.objGlobal.hashPassword("Existing-account-123!"));
                variables.email = "invite-" & lCase(replace(createUUID(), "-", "", "all")) & "@saaster.invalid";
                variables.service = application.objOrganizationInvitation;
                queryExecute(options = {datasource: application.datasource}, params = {org: id(variables.org), owner: id(variables.owner.userID)},
                    sql = "INSERT INTO organization_access (intOrganizationID) VALUES (:org)");
                queryExecute(options = {datasource: application.datasource}, params = {org: id(variables.org), owner: id(variables.owner.userID)},
                    sql = "INSERT INTO organization_memberships (intOrganizationID, intUserID, strRoleKey) VALUES (:org, :owner, 'organization.owner')");
            });
            afterEach(() => {
                cfhttp(url = request.testSettings.mailCatcherUrl & "/api/v1/mailbox/" & listFirst(variables.email, "@"), method = "delete", timeout = 10);
                cfhttp(url = request.testSettings.mailCatcherUrl & "/api/v1/mailbox/" & listFirst(variables.existing.email, "@"), method = "delete", timeout = 10);
                logout();
                structDelete(session, "pendingOrganizationInvitation");
                structDelete(session, "invitation_mfa_user");
            });

            it("sends an invitation without creating an account or granting access, then creates one identity on acceptance", () => {
                variables.invitation = send(variables.email);
                expect(users(variables.email).recordCount).toBe(0);
                expect(variables.service.inspect(variables.invitation.token).valid).toBeTrue();
                local.accepted = variables.service.accept(variables.invitation.token, 0, "New-account-123!", "New member");
                expect(users(variables.email).recordCount).toBe(1);
                expect(application.objAuthorization.canInTenant(local.accepted, variables.org, "tenant.view")).toBeTrue();
                expect(application.objAuthorization.canInTenant(local.accepted, variables.org, "tenant.content.write")).toBeFalse();
                expect(variables.service.inspect(variables.invitation.token).valid).toBeFalse();
                expect(() => variables.service.accept(variables.invitation.token, 0, "New-account-123!")).toThrow("Saaster.Invitation.Invalid");
                expect(variables.service.listForOrganization(variables.owner.userID, variables.org).status).toBe("accepted");
            });
            it("requires the existing authenticated identity and preserves its original organization access", () => {
                variables.invitation = send(variables.existing.email);
                expect(() => variables.service.accept(variables.invitation.token, 0, "A-new-password-123!")).toThrow("Saaster.Invitation.Invalid");
                expect(() => variables.service.accept(variables.invitation.token, variables.owner.userID)).toThrow("Saaster.Invitation.Invalid");
                expect(variables.service.accept(variables.invitation.token, variables.existing.userID)).toBe(variables.existing.userID);
                expect(users(variables.existing.email).recordCount).toBe(1);
                expect(application.objMembershipAccess.canAccessTenant(variables.existing.userID, variables.other)).toBeTrue();
                expect(application.objMembershipAccess.canAccessTenant(variables.existing.userID, variables.org)).toBeTrue();
            });
            it("rejects expired and revoked invitations and renews the token on resend", () => {
                variables.invitation = send(variables.email);
                queryExecute(options = {datasource: application.datasource}, params = {id: id(variables.invitation.id)},
                    sql = "UPDATE organization_invitations SET dtmExpiresAt = UTC_TIMESTAMP() - INTERVAL 1 SECOND WHERE intInvitationID = :id");
                expect(() => variables.service.accept(variables.invitation.token, 0, "New-account-123!")).toThrow("Saaster.Invitation.Invalid");
                expect(variables.service.listForOrganization(variables.owner.userID, variables.org).status).toBe("expired");
                variables.service.resend(variables.owner.userID, variables.org, variables.invitation.id);
                variables.renewed = receive(variables.email, variables.invitation.token);
                expect(variables.service.inspect(variables.invitation.token).valid).toBeFalse();
                expect(variables.service.inspect(variables.renewed).valid).toBeTrue();
                variables.service.revoke(variables.owner.userID, variables.org, variables.invitation.id);
                expect(() => variables.service.accept(variables.renewed, 0, "New-account-123!")).toThrow("Saaster.Invitation.Invalid");
            });
            it("does not revive an expired invitation beside a newer pending invitation", () => {
                variables.invitation = send(variables.email);
                queryExecute(options = {datasource: application.datasource}, params = {id: id(variables.invitation.id)},
                    sql = "UPDATE organization_invitations SET dtmExpiresAt = UTC_TIMESTAMP() - INTERVAL 1 SECOND WHERE intInvitationID = :id");
                variables.service.invite(variables.owner.userID, variables.org, variables.email, "organization.member", [{customerID:variables.org, role:"tenant.editor"}]);
                expect(() => variables.service.resend(variables.owner.userID, variables.org, variables.invitation.id)).toThrow("Saaster.Invitation.Invalid");
                expect(variables.service.listForOrganization(variables.owner.userID, variables.org).filter((invitation) => invitation.status eq "pending").recordCount).toBe(1);
            });
            it("rechecks the inviter's current authority and active organization at acceptance", () => {
                variables.invitation = send(variables.email);
                queryExecute(options = {datasource: application.datasource}, params = {id: id(variables.owner.userID)},
                    sql = "UPDATE organization_memberships SET strStatus = 'suspended' WHERE intUserID = :id");
                expect(() => variables.service.accept(variables.invitation.token, 0, "New-account-123!")).toThrow("Saaster.Invitation.Invalid");
                expect(users(variables.email).recordCount).toBe(0);
            });
            it("serializes parallel acceptance and never duplicates memberships or identities", () => {
                variables.invitation = send(variables.existing.email);
                local.token = variables.invitation.token;
                local.userID = variables.existing.userID;
                local.outcomes = ["", ""];
                [1, 2].each((index) => {
                    try { new backend.core.com.organization_invitation().accept(token, userID); outcomes[index] = "accepted"; }
                    catch (Saaster.Invitation error) { outcomes[index] = "rejected"; }
                }, true, 2);
                expect(arrayToList(local.outcomes)).toInclude("accepted");
                expect(arrayToList(local.outcomes)).toInclude("rejected");
                expect(users(variables.existing.email).recordCount).toBe(1);
            });
            it("keeps the normal MFA check when authenticating an identity without an organization", () => {
                variables.invitation = send(variables.existing.email);
                session.pendingOrganizationInvitation = variables.invitation.token;
                session.invitation_mfa_user = variables.existing.userID;
                queryExecute(options={datasource:application.datasource}, params={id:id(variables.existing.userID), token:{type:"varchar",value:"invitation-mfa-test"}},
                    sql="UPDATE users SET blnMfa = 1, intMfaCode = 123456, dtmMfaDateTime = UTC_TIMESTAMP() + INTERVAL 3 HOUR, strUUID = :token WHERE intUserID = :id");
                expect(application.objUser.checkMfa("invitation-mfa-test", 111111).success).toBeFalse();
                expect(application.objUser.checkMfa("invitation-mfa-test", 123456).success).toBeTrue();
                variables.service.revoke(variables.owner.userID, variables.org, variables.invitation.id);
                expect(variables.service.permitsIdentityLogin(variables.existing.userID, variables.invitation.token)).toBeFalse();
            });
            it("rejects changed recipient identities and preserves existing membership state", () => {
                variables.invitation = send(variables.existing.email);
                queryExecute(options={datasource:application.datasource}, params={id:id(variables.existing.userID)},
                    sql="UPDATE users SET strEmail = CONCAT('changed-', strEmail) WHERE intUserID = :id");
                expect(() => variables.service.accept(variables.invitation.token, variables.existing.userID)).toThrow("Saaster.Invitation.Invalid");
            });
            it("serializes acceptance of a new identity as well as an existing one", () => {
                variables.invitation = send(variables.email);
                local.token = variables.invitation.token;
                local.outcomes = ["", ""];
                [1, 2].each((index) => {
                    try { new backend.core.com.organization_invitation().accept(token, 0, "Concurrent-new-account-123!"); outcomes[index] = "accepted"; }
                    catch (Saaster.Invitation error) { outcomes[index] = "rejected"; }
                }, true, 2);
                expect(arrayToList(local.outcomes)).toInclude("accepted");
                expect(arrayToList(local.outcomes)).toInclude("rejected");
                expect(users(variables.email).recordCount).toBe(1);
            });
            it("does not permit another organization, a duplicate pending invite or unauthorized roles", () => {
                variables.invitation = send(variables.email);
                expect(() => variables.service.invite(variables.owner.userID, variables.org, variables.email, "organization.member", [{customerID:variables.org, role:"tenant.viewer"}])).toThrow("Saaster.Invitation.Invalid");
                expect(() => variables.service.revoke(variables.owner.userID, variables.other, variables.invitation.id)).toThrow("Saaster.Invitation.Invalid");
                expect(() => variables.service.invite(variables.owner.userID, variables.org, variables.existing.email, "organization.member", [{customerID:variables.other, role:"tenant.viewer"}])).toThrow("Saaster.Invitation.Invalid");
            });
            it("authenticates an invited identity without granting a session before acceptance, including the MFA recheck", () => {
                variables.invitation = send(variables.existing.email);
                session.pendingOrganizationInvitation = variables.invitation.token;
                local.login = new frontend.core.com.login().checkLogin(email=variables.existing.email, password="Existing-account-123!");
                expect(local.login.loginCorrect).toBeTrue();
                expect(local.login.invitationOnly).toBeTrue();
                expect(application.objAuthorization.canInTenant(variables.existing.userID, variables.org, "tenant.view")).toBeFalse();
                expect(variables.service.permitsIdentityLogin(variables.owner.userID, variables.invitation.token)).toBeFalse();
            });
        });
    }
    private struct function send(required string email) {
        local.invitationID = variables.service.invite(variables.owner.userID, variables.org, arguments.email, "organization.member",
            [{customerID:variables.org, role:"tenant.viewer"}], "de");
        return {id:local.invitationID, token:receive(arguments.email)};
    }
    private string function receive(required string email, string previousToken = "") {
        local.url = request.testSettings.mailCatcherUrl & "/api/v1/mailbox/" & listFirst(arguments.email, "@");
        loop from=1 to=40 index="local.attempt" {
            cfhttp(url=local.url, method="get", timeout=10, result="local.response");
            if (isJSON(local.response.fileContent)) {
                loop array=deserializeJSON(local.response.fileContent) item="local.message" {
                    cfhttp(url=local.url & "/" & local.message.id, method="get", timeout=10, result="local.body");
                    local.matches = reMatch("organization-invitation\?token=[a-f0-9]{64}", deserializeJSON(local.body.fileContent).body.html ?: "");
                    if (arrayLen(local.matches)) {
                        local.token = listLast(local.matches[1], "=");
                        if (local.token neq arguments.previousToken) { return local.token; }
                    }
                }
            }
            sleep(200);
        }
        fail("No invitation arrived in the local mail catcher.");
    }
    private query function users(required string email) {
        return queryExecute(options={datasource:application.datasource}, params={email:{type:"varchar",value:arguments.email}}, sql="SELECT intUserID FROM users WHERE strEmail = :email");
    }
    private struct function id(required numeric value) { return {type:"integer",value:arguments.value}; }
}
