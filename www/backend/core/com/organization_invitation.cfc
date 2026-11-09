component output="false" hint="Invitation consent, identity binding and atomic membership creation." {
    public numeric function invite(required numeric actorUserID, required numeric organizationID, required string email,
        string role = "organization.member", array tenants = [], string language = "en") {
        local.email = lCase(trim(arguments.email));
        if (not isValid("email", local.email) or len(local.email) gt 100) { reject(); }
        transaction isolation="read_committed" {
            validateProposal(arguments.actorUserID, arguments.organizationID, arguments.role, arguments.tenants);
            local.users = usersByEmail(local.email);
            if (local.users.recordCount gt 1 or (local.users.recordCount and (local.users.blnSysAdmin or not local.users.blnActive))) { reject(); }
            if (local.users.recordCount and membershipExists(local.users.intUserID, arguments.organizationID)) { reject(); }
            local.params = {org: integer(arguments.organizationID), email: stringParam(local.email)};
            queryExecute(options = {datasource: application.datasource}, params = local.params,
                sql = "UPDATE organization_invitations SET strStatus = 'expired' WHERE intOrganizationID = :org AND strEmail = :email
                    AND strStatus = 'pending' AND dtmExpiresAt <= UTC_TIMESTAMP()");
            local.pending = queryExecute(options = {datasource: application.datasource}, params = local.params,
                sql = "SELECT intInvitationID FROM organization_invitations WHERE intOrganizationID = :org AND strEmail = :email AND strStatus = 'pending'");
            if (local.pending.recordCount) { reject(); }
            local.token = newToken();
            structAppend(local.params, {actor: integer(arguments.actorUserID), target: {type: "integer", value: val(local.users.intUserID), null: not local.users.recordCount},
                role: stringParam(arguments.role), assignments: stringParam(serializeJSON(arguments.tenants)), token: stringParam(hash(local.token, "SHA-256")),
                language: stringParam(arguments.language)});
            // Language validation uses the existing language catalog rather than input in a mail template path.
            local.params.language.value = structKeyExists(application.langStruct, arguments.language) ? arguments.language : application.objLanguage.getDefaultLanguage().iso;
            queryExecute(options = {datasource: application.datasource, result: "local.inserted"}, params = local.params,
                sql = "INSERT INTO organization_invitations (intOrganizationID, intInvitedBy, intTargetUserID, strEmail, strRoleKey, strAssignments, strLanguage, strTokenHash, dtmExpiresAt)
                    VALUES (:org, :actor, :target, :email, :role, :assignments, :language, :token, UTC_TIMESTAMP() + INTERVAL 7 DAY)");
            local.id = local.inserted.generatedKey;
            new backend.core.com.invitation_mail().send(local.email, arguments.organizationID, local.token, local.params.language.value);
        }
        return local.id;
    }

    public query function listForOrganization(required numeric actorUserID, required numeric organizationID) {
        if (not application.objAuthorization.canInOrganization(arguments.actorUserID, arguments.organizationID, "organization.members.manage")) { reject(); }
        return queryExecute(options = {datasource: application.datasource}, params = {org: integer(arguments.organizationID)},
            sql = "SELECT intInvitationID, strEmail, strRoleKey, dtmExpiresAt,
                    CASE WHEN strStatus = 'pending' AND dtmExpiresAt <= UTC_TIMESTAMP() THEN 'expired' ELSE strStatus END AS status
                FROM organization_invitations WHERE intOrganizationID = :org ORDER BY intInvitationID DESC");
    }

    public void function resend(required numeric actorUserID, required numeric organizationID, required numeric invitationID) {
        transaction isolation="read_committed" {
            lockOrganization(arguments.organizationID);
            local.invitation = byID(arguments.invitationID, arguments.organizationID);
            if (not local.invitation.recordCount or not listFind("pending,expired", local.invitation.strStatus)) { reject(); }
            validateProposal(arguments.actorUserID, arguments.organizationID, local.invitation.strRoleKey, deserializeJSON(local.invitation.strAssignments));
            local.otherPending = queryExecute(options = {datasource: application.datasource},
                params = {org: integer(arguments.organizationID), id: integer(arguments.invitationID), email: stringParam(local.invitation.strEmail)},
                sql = "SELECT intInvitationID FROM organization_invitations WHERE intOrganizationID = :org AND strEmail = :email
                    AND intInvitationID <> :id AND strStatus = 'pending' AND dtmExpiresAt > UTC_TIMESTAMP()");
            if (local.otherPending.recordCount) { reject(); }
            local.token = newToken();
            queryExecute(options = {datasource: application.datasource}, params = {id: integer(arguments.invitationID), token: stringParam(hash(local.token, "SHA-256")), actor: integer(arguments.actorUserID)},
                sql = "UPDATE organization_invitations SET strTokenHash = :token, strStatus = 'pending', intInvitedBy = :actor,
                    dtmExpiresAt = UTC_TIMESTAMP() + INTERVAL 7 DAY WHERE intInvitationID = :id");
            new backend.core.com.invitation_mail().send(local.invitation.strEmail, arguments.organizationID, local.token, local.invitation.strLanguage);
        }
    }

    public void function revoke(required numeric actorUserID, required numeric organizationID, required numeric invitationID) {
        transaction isolation="read_committed" {
            lockOrganization(arguments.organizationID);
            local.invitation = byID(arguments.invitationID, arguments.organizationID);
            if (not local.invitation.recordCount or not listFind("pending,expired", local.invitation.strStatus)) { reject(); }
            validateManager(arguments.actorUserID, arguments.organizationID, local.invitation.strRoleKey);
            queryExecute(options = {datasource: application.datasource}, params = {id: integer(arguments.invitationID)},
                sql = "UPDATE organization_invitations SET strStatus = 'revoked' WHERE intInvitationID = :id");
        }
    }

    public struct function inspect(required string token) {
        local.invitation = byToken(arguments.token);
        if (not local.invitation.recordCount) { return {valid: false}; }
        local.organization = application.objMembershipAccess.organizationForCustomer(local.invitation.intOrganizationID);
        if (not local.organization.enabled or not local.organization.active) { return {valid: false}; }
        local.users = usersByEmail(local.invitation.strEmail);
        if (local.users.recordCount gt 1) { return {valid: false}; }
        return {valid: true, organizationID: local.organization.id, organizationName: local.organization.name, email: local.invitation.strEmail,
            role: local.invitation.strRoleKey, tenants: deserializeJSON(local.invitation.strAssignments),
            needsLogin: local.users.recordCount and len(local.users.strPasswordHash & local.users.strPasswordSalt) gt 0};
    }

    // Used only after password verification (and again after the existing MFA flow).
    public boolean function permitsIdentityLogin(required numeric userID, required string token) {
        local.invitation = byToken(arguments.token);
        if (not local.invitation.recordCount) { return false; }
        local.users = usersByEmail(local.invitation.strEmail);
        return local.users.recordCount eq 1 and local.users.intUserID eq arguments.userID and local.users.blnActive
            and (not val(local.invitation.intTargetUserID) or local.invitation.intTargetUserID eq arguments.userID);
    }

    public numeric function accept(required string token, numeric authenticatedUserID = 0, string password = "", string name = "") {
        local.preview = byToken(arguments.token);
        if (not local.preview.recordCount) { reject(); }
        transaction isolation="read_committed" {
            lockOrganization(local.preview.intOrganizationID);
            local.invitation = byID(local.preview.intInvitationID, local.preview.intOrganizationID);
            // Compare again under the lock: a concurrent resend/revoke invalidates the preview.
            if (local.invitation.strStatus neq "pending" or local.invitation.strTokenHash neq hash(arguments.token, "SHA-256")
                or dateCompare(local.invitation.dtmExpiresAt, now()) lte 0) { reject(); }
            local.tenants = deserializeJSON(local.invitation.strAssignments);
            validateProposal(val(local.invitation.intInvitedBy), local.invitation.intOrganizationID, local.invitation.strRoleKey, local.tenants);
            local.params = {email: stringParam(local.invitation.strEmail)};
            new backend.core.com.identity().lockEmail(local.invitation.strEmail);
            local.users = usersByEmail(local.invitation.strEmail, true);
            if (local.users.recordCount gt 1 or (local.users.recordCount and (not local.users.blnActive or local.users.blnSysAdmin))) { reject(); }
            if (val(local.invitation.intTargetUserID) and (not local.users.recordCount or local.users.intUserID neq local.invitation.intTargetUserID)) { reject(); }
            if (arguments.authenticatedUserID gt 0 and (not local.users.recordCount or local.users.intUserID neq arguments.authenticatedUserID)) { reject(); }
            if (local.users.recordCount and len(local.users.strPasswordHash & local.users.strPasswordSalt)) {
                if (arguments.authenticatedUserID neq local.users.intUserID) { reject(); }
                local.userID = local.users.intUserID;
            } else {
                if (not application.objGlobal.isValidPassword(arguments.password)) { reject(); }
                local.passwordHash = application.objGlobal.hashPassword(arguments.password);
                if (local.users.recordCount) {
                    local.userID = local.users.intUserID;
                    queryExecute(options = {datasource: application.datasource}, params = {id: integer(local.userID), password: stringParam(local.passwordHash)},
                        sql = "UPDATE users SET strPasswordHash = :password, strPasswordSalt = '', strUUID = '' WHERE intUserID = :id");
                } else {
                    structAppend(local.params, {password: stringParam(local.passwordHash), name: stringParam(left(trim(arguments.name), 100)), language: stringParam(local.invitation.strLanguage)});
                    queryExecute(options = {datasource: application.datasource, result: "local.inserted"}, params = local.params,
                        sql = "INSERT INTO users (intCustomerID, dtmInsertDate, dtmMutDate, strFirstName, strLastName, strEmail,
                            strPasswordHash, strPasswordSalt, strLanguage, blnActive, blnAdmin, blnSuperAdmin, blnSysAdmin)
                            VALUES (NULL, UTC_TIMESTAMP(), UTC_TIMESTAMP(), :name, '', :email, :password, '', :language, 1, 0, 0, 0)");
                    local.userID = local.inserted.generatedKey;
                }
            }
            // Never silently change or reactivate an existing membership on acceptance.
            if (membershipExists(local.userID, local.invitation.intOrganizationID)) { reject(); }
            local.previousTenants = application.objMembershipAccess.tenants(local.userID);
            local.params = {userID: integer(local.userID), org: integer(local.invitation.intOrganizationID), role: stringParam(local.invitation.strRoleKey)};
            queryExecute(options = {datasource: application.datasource}, params = local.params,
                sql = "INSERT IGNORE INTO membership_identities (intUserID) VALUES (:userID)");
            queryExecute(options = {datasource: application.datasource, result: "local.membership"}, params = local.params,
                sql = "INSERT INTO organization_memberships (intUserID, intOrganizationID, strRoleKey) VALUES (:userID, :org, :role)");
            loop array=local.tenants item="local.tenant" {
                queryExecute(options = {datasource: application.datasource}, params = {membership: integer(local.membership.generatedKey), tenant: integer(local.tenant.customerID), role: stringParam(local.tenant.role)},
                    sql = "INSERT INTO tenant_memberships (intOrgMembershipID, intCustomerID, strRoleKey) VALUES (:membership, :tenant, :role)");
            }
            local.defaultTenant = local.previousTenants.recordCount ? local.previousTenants.intCustomerID[1]
                : (arrayLen(local.tenants) ? local.tenants[1].customerID : local.invitation.intOrganizationID);
            queryExecute(options = {datasource: application.datasource}, params = {userID: integer(local.userID), tenant: integer(local.defaultTenant)},
                sql = "INSERT IGNORE INTO membership_preferences (intUserID, intDefaultCustomerID) VALUES (:userID, :tenant)");
            queryExecute(options = {datasource: application.datasource}, params = {id: integer(local.invitation.intInvitationID), userID: integer(local.userID)},
                sql = "UPDATE organization_invitations SET strStatus = 'accepted', intAcceptedBy = :userID, dtmAcceptedAt = UTC_TIMESTAMP() WHERE intInvitationID = :id");
        }
        return local.userID;
    }

    private void function validateProposal(required numeric actorUserID, required numeric organizationID, required string role, required array tenants) {
        lockOrganization(arguments.organizationID);
        validateManager(arguments.actorUserID, arguments.organizationID, arguments.role);
        if (not listFind("organization.owner,organization.admin,organization.member", arguments.role)
            or (arguments.role eq "organization.member" and not arrayLen(arguments.tenants))
            or (arguments.role neq "organization.member" and arrayLen(arguments.tenants))) { reject(); }
        local.seen = {};
        loop array=arguments.tenants item="local.tenant" {
            if (not isStruct(local.tenant) or not isValid("integer", local.tenant.customerID ?: "")
                or not listFind("tenant.admin,tenant.editor,tenant.viewer", local.tenant.role ?: "")
                or structKeyExists(local.seen, toString(local.tenant.customerID))) { reject(); }
            local.organization = application.objMembershipAccess.organizationForCustomer(local.tenant.customerID);
            if (local.organization.id neq arguments.organizationID
                or not application.objAuthorization.canInTenant(arguments.actorUserID, local.tenant.customerID, "tenant.members.manage")) { reject(); }
            local.seen[toString(local.tenant.customerID)] = true;
            local.plan = new backend.core.com.plans(language = "en").getCurrentPlan(local.tenant.customerID);
            local.limit = val(local.plan.maxUsers ?: 0);
            if (structKeyExists(local.plan, "nextplan") and structKeyExists(local.plan.nextplan, "maxUsers")) { local.limit = val(local.plan.nextplan.maxUsers); }
            if (local.limit gt 0 and application.objUser.getAllUsers(local.tenant.customerID).recordCount gte local.limit) { reject(); }
        }
    }

    private void function validateManager(required numeric actorUserID, required numeric organizationID, required string role) {
        if (not application.objAuthorization.canInOrganization(arguments.actorUserID, arguments.organizationID, "organization.members.manage")
            or (arguments.role neq "organization.member" and not application.objAuthorization.canInOrganization(arguments.actorUserID, arguments.organizationID, "organization.ownership.transfer"))) { reject(); }
    }
    private void function lockOrganization(required numeric organizationID) {
        local.organization = queryExecute(options = {datasource: application.datasource}, params = {org: integer(arguments.organizationID)},
            sql = "SELECT customer.intCustomerID FROM customers customer INNER JOIN organization_access activated ON activated.intOrganizationID = customer.intCustomerID
                WHERE customer.intCustomerID = :org AND customer.intCustParentID = 0 AND customer.blnActive = 1 FOR UPDATE");
        if (not local.organization.recordCount) { reject(); }
    }
    private query function usersByEmail(required string email, boolean locked = false) {
        return queryExecute(options = {datasource: application.datasource}, params = {email: stringParam(arguments.email)},
            sql = "SELECT intUserID, blnActive, blnSysAdmin, strPasswordHash, strPasswordSalt FROM users WHERE strEmail = :email" & (arguments.locked ? " FOR UPDATE" : ""));
    }
    private boolean function membershipExists(required numeric userID, required numeric organizationID) {
        return queryExecute(options = {datasource: application.datasource}, params = {id: integer(arguments.userID), org: integer(arguments.organizationID)},
            sql = "SELECT intOrgMembershipID FROM organization_memberships WHERE intUserID = :id AND intOrganizationID = :org").recordCount gt 0;
    }
    private query function byToken(required string token) {
        return queryExecute(options = {datasource: application.datasource}, params = {token: stringParam(hash(arguments.token, "SHA-256"))},
            sql = "SELECT * FROM organization_invitations WHERE strTokenHash = :token AND strStatus = 'pending' AND dtmExpiresAt > UTC_TIMESTAMP()");
    }
    private query function byID(required numeric invitationID, required numeric organizationID) {
        return queryExecute(options = {datasource: application.datasource}, params = {id: integer(arguments.invitationID), org: integer(arguments.organizationID)},
            sql = "SELECT * FROM organization_invitations WHERE intInvitationID = :id AND intOrganizationID = :org FOR UPDATE");
    }
    private string function newToken() { return lCase(hash(generateSecretKey("AES", 256) & createUUID(), "SHA-256")); }
    private struct function integer(required numeric value) { return {type: "integer", value: arguments.value}; }
    private struct function stringParam(required string value) { return {type: "varchar", value: arguments.value}; }
    private void function reject() { throw(type = "Saaster.Invitation.Invalid", message = "The invitation or requested membership is not allowed."); }
}
