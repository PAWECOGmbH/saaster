component output="false" hint="Transactional organization and tenant membership administration." {

    public struct function createUser(required numeric actorUserID, required numeric customerID, required struct profile, string role = "tenant.viewer", string status = "active") {
        validateChoice(arguments.role, "tenant.admin,tenant.editor,tenant.viewer");
        validateChoice(arguments.status, "active,suspended");
        local.org = application.objMembershipAccess.organizationForCustomer(arguments.customerID);
        transaction isolation="read_committed" {
            lockOrganization(local.org.id);
            requireOrganizationManager(arguments.actorUserID, local.org.id);
            if (not local.org.enabled or not application.objAuthorization.canInTenant(arguments.actorUserID, arguments.customerID, "tenant.members.manage")) {
                reject("Forbidden", "New members require an activated organization and tenant management access.");
            }
            local.plan = new backend.core.com.plans(language = session.lng ?: "en").getCurrentPlan(arguments.customerID);
            local.limit = val(local.plan.maxUsers ?: 0);
            if (structKeyExists(local.plan, "nextplan") and structKeyExists(local.plan.nextplan, "maxUsers")) {
                local.limit = val(local.plan.nextplan.maxUsers);
            }
            if (local.limit gt 0 and application.objUser.getAllUsers(arguments.customerID).recordCount gte local.limit) {
                reject("UserLimit", "The tenant user limit has been reached.");
            }
            local.profile = duplicate(arguments.profile);
            local.profile.admin = 0;
            local.profile.superadmin = 0;
            local.profile.sysadmin = 0;
            local.profile.active = 1;
            local.created = application.objUser.insertUser(local.profile, local.org.id);
            if (not local.created.success) {
                reject("CreateFailed", "The user could not be created.");
            }
            setOrganizationMember(arguments.actorUserID, local.org.id, local.created.newUserID, "organization.member", arguments.status);
            setTenantMember(arguments.actorUserID, arguments.customerID, local.created.newUserID, arguments.role);
            queryExecute(
                options = {datasource: application.datasource},
                params = {userID: {type: "integer", value: local.created.newUserID}, customerID: {type: "integer", value: arguments.customerID}},
                sql = "INSERT INTO membership_preferences (intUserID, intDefaultCustomerID) VALUES (:userID, :customerID)"
            );
        }
        return local.created;
    }

    public struct function resendInvitation(required numeric actorUserID, required numeric organizationID, required numeric userID) {
        transaction isolation="read_committed" {
            lockOrganization(arguments.organizationID);
            local.actor = requireOrganizationManager(arguments.actorUserID, arguments.organizationID);
            local.target = lockTarget(arguments.userID, arguments.organizationID);
            protectOrganizationRole(local.actor, local.target, local.target.role);
            if (arguments.actorUserID eq arguments.userID or not local.target.exists or not local.target.active
                or local.target.status neq "active" or not local.target.activationPending) {
                reject("InvalidInvitation", "Only an active member who has not set a password can receive an activation link.");
            }
            // Use a request-local mailer: its template variables must not be shared
            // with concurrent invitations. Refresh expired links on every resend.
            local.mailer = new backend.core.com.user();
            local.result = local.mailer.sendInvitation(arguments.userID, arguments.actorUserID, true);
        }
        return local.result;
    }

    // Callers must take actorUserID from the authenticated session. These methods
    // are not remote endpoints. Legacy flags never authorize a membership change.
    public numeric function setOrganizationMember(required numeric actorUserID, required numeric organizationID, required numeric userID, string role = "organization.member", string status = "active") {
        validateChoice(arguments.role, "organization.owner,organization.admin,organization.member");
        validateChoice(arguments.status, "active,suspended");

        transaction isolation="read_committed" {
            lockOrganization(arguments.organizationID);
            local.actor = requireOrganizationManager(arguments.actorUserID, arguments.organizationID);
            local.target = lockTarget(arguments.userID, arguments.organizationID);
            protectOrganizationRole(local.actor, local.target, arguments.role);
            protectLastOwner(local.target, arguments.organizationID, arguments.role, arguments.status);

            if (arguments.role eq "organization.owner" and arguments.status eq "active" and not local.target.active) {
                reject("InactiveOwner", "An active owner must have an active user account.");
            }

            local.params = {
                userID: {type: "integer", value: arguments.userID},
                role: {type: "varchar", value: arguments.role},
                status: {type: "varchar", value: arguments.status}
            };
            if (local.target.exists) {
                queryExecute(
                    options = {datasource: application.datasource},
                    params = local.params,
                    sql = "UPDATE organization_memberships SET strRoleKey = :role, strStatus = :status WHERE intUserID = :userID"
                );
                local.membershipID = local.target.membershipID;
            } else {
                local.params.organizationID = {type: "integer", value: arguments.organizationID};
                queryExecute(
                    options = {datasource: application.datasource, result: "local.inserted"},
                    params = local.params,
                    sql = "INSERT INTO organization_memberships (intOrganizationID, intUserID, strRoleKey, strStatus)
                        VALUES (:organizationID, :userID, :role, :status)"
                );
                local.membershipID = local.inserted.generatedKey;
            }
        }
        return local.membershipID;
    }

    // Validate the complete edit under the shared organization lock before writing.
    // This also permits a manager to change their own role without a partial save.
    public void function saveMember(required numeric actorUserID, required numeric organizationID, required numeric userID, struct organization = {}, array tenants = []) {
        transaction isolation="read_committed" {
            lockOrganization(arguments.organizationID);
            lockActor(arguments.actorUserID, arguments.organizationID);
            local.target = lockTarget(arguments.userID, arguments.organizationID);
            local.role = local.target.role;
            if (not structIsEmpty(arguments.organization)) {
                local.role = arguments.organization.role ?: "";
                validateChoice(local.role, "organization.owner,organization.admin,organization.member");
                validateChoice(arguments.organization.status ?: "", "active,suspended");
                local.actor = requireOrganizationManager(arguments.actorUserID, arguments.organizationID);
                protectOrganizationRole(local.actor, local.target, local.role);
                protectLastOwner(local.target, arguments.organizationID, local.role, arguments.organization.status);
                if (local.role eq "organization.owner" and arguments.organization.status eq "active" and not local.target.active) {
                    reject("InactiveOwner", "An active owner must have an active user account.");
                }
            } else if (not local.target.exists) {
                reject("MissingMembership", "Tenant access requires an organization membership.");
            }

            loop array=arguments.tenants item="local.assignment" {
                if (not isStruct(local.assignment) or not isValid("integer", local.assignment.customerID ?: "")) {
                    reject("InvalidTenant", "A valid tenant is required.");
                }
                if (len(local.assignment.role ?: "")) {
                    validateChoice(local.assignment.role, "tenant.admin,tenant.editor,tenant.viewer");
                }
                validateChoice(local.assignment.status ?: "", "active,suspended");
                local.tenant = queryExecute(
                    options = {datasource: application.datasource},
                    params = {
                        customerID: {type: "integer", value: local.assignment.customerID},
                        organizationID: {type: "integer", value: arguments.organizationID}
                    },
                    sql = "SELECT intCustomerID FROM customers WHERE intCustomerID = :customerID AND blnActive = 1
                        AND ((intCustomerID = :organizationID AND intCustParentID = 0) OR intCustParentID = :organizationID) FOR UPDATE"
                );
                if (not local.tenant.recordCount) {
                    reject("InvalidTenant", "The tenant must be active and belong directly to the organization.");
                }
                if (not application.objAuthorization.canInTenant(arguments.actorUserID, local.assignment.customerID, "tenant.members.manage")) {
                    reject("Forbidden", "Tenant member management is not allowed.");
                }
                if (local.role neq "organization.member") {
                    reject("InheritedAccess", "Inherited tenant access cannot be edited separately.");
                }
            }

            local.membershipID = local.target.membershipID;
            if (not structIsEmpty(arguments.organization)) {
                local.membershipID = setOrganizationMember(arguments.actorUserID, arguments.organizationID, arguments.userID,
                    local.role, arguments.organization.status);
            }
            loop array=arguments.tenants item="local.assignment" {
                writeTenantMember(local.membershipID, local.assignment.customerID, local.assignment.role ?: "", local.assignment.status);
            }
        }
    }

    public void function removeOrganizationMember(required numeric actorUserID, required numeric organizationID, required numeric userID) {
        transaction isolation="read_committed" {
            lockOrganization(arguments.organizationID);
            local.actor = requireOrganizationManager(arguments.actorUserID, arguments.organizationID);
            local.target = lockTarget(arguments.userID, arguments.organizationID);
            protectOrganizationRole(local.actor, local.target, "organization.member");
            protectLastOwner(local.target, arguments.organizationID, "", "");

            queryExecute(
                options = {datasource: application.datasource},
                params = {userID: {type: "integer", value: arguments.userID}},
                sql = "DELETE FROM organization_memberships WHERE intUserID = :userID"
            );
        }
    }

    // Promotion and demotion share a transaction and the organization row lock.
    // The former owner remains an administrator; the identity itself is unchanged.
    public void function transferOwnership(required numeric actorUserID, required numeric organizationID, required numeric userID) {
        transaction isolation="read_committed" {
            lockOrganization(arguments.organizationID);
            local.actor = requireOrganizationManager(arguments.actorUserID, arguments.organizationID);
            if (local.actor.role neq "organization.owner"
                or not application.objAuthorization.canInOrganization(arguments.actorUserID, arguments.organizationID, "organization.ownership.transfer")
                or arguments.actorUserID eq arguments.userID) {
                reject("Forbidden", "Only an active owner may transfer ownership to another member.");
            }

            local.target = lockTarget(arguments.userID, arguments.organizationID);
            if (not local.target.exists or not local.target.active or local.target.status neq "active") {
                reject("InactiveOwner", "The new owner must be an active organization member.");
            }

            queryExecute(
                options = {datasource: application.datasource},
                params = {userID: {type: "integer", value: arguments.userID}},
                sql = "UPDATE organization_memberships SET strRoleKey = 'organization.owner' WHERE intUserID = :userID"
            );
            queryExecute(
                options = {datasource: application.datasource},
                params = {userID: {type: "integer", value: arguments.actorUserID}},
                sql = "UPDATE organization_memberships SET strRoleKey = 'organization.admin' WHERE intUserID = :userID"
            );
        }
    }

    public void function setTenantMember(required numeric actorUserID, required numeric customerID, required numeric userID, string role = "tenant.viewer", string status = "active") {
        validateChoice(arguments.role, "tenant.admin,tenant.editor,tenant.viewer");
        validateChoice(arguments.status, "active,suspended");
        changeTenantMember(arguments.actorUserID, arguments.customerID, arguments.userID, arguments.role, arguments.status);
    }

    public void function removeTenantMember(required numeric actorUserID, required numeric customerID, required numeric userID) {
        changeTenantMember(arguments.actorUserID, arguments.customerID, arguments.userID, "", "");
    }

    private void function changeTenantMember(required numeric actorUserID, required numeric customerID, required numeric userID, required string role, required string status) {
        local.context = queryExecute(
            options = {datasource: application.datasource},
            params = {customerID: {type: "integer", value: arguments.customerID}},
            sql = "SELECT CASE WHEN intCustParentID = 0 THEN intCustomerID ELSE intCustParentID END AS organizationID
                FROM customers WHERE intCustomerID = :customerID"
        );
        if (not local.context.recordCount) {
            reject("InvalidTenant", "The tenant does not exist.");
        }

        transaction isolation="read_committed" {
            lockOrganization(local.context.organizationID);
            local.tenant = queryExecute(
                options = {datasource: application.datasource},
                params = {
                    customerID: {type: "integer", value: arguments.customerID},
                    organizationID: {type: "integer", value: local.context.organizationID}
                },
                sql = "SELECT intCustomerID FROM customers WHERE intCustomerID = :customerID AND blnActive = 1
                    AND ((intCustomerID = :organizationID AND intCustParentID = 0) OR intCustParentID = :organizationID) FOR UPDATE"
            );
            if (not local.tenant.recordCount) {
                reject("InvalidTenant", "The tenant must be active and belong directly to the organization.");
            }

            lockActor(arguments.actorUserID, local.context.organizationID);
            if (not application.objAuthorization.canInTenant(arguments.actorUserID, arguments.customerID, "tenant.members.manage")) {
                reject("Forbidden", "Tenant member management is not allowed.");
            }
            local.target = lockTarget(arguments.userID, local.context.organizationID);
            if (not local.target.exists) {
                reject("MissingMembership", "Tenant access requires an organization membership.");
            }
            if (local.target.role neq "organization.member") {
                reject("InheritedAccess", "Change the organization role to limit inherited tenant access.");
            }

            writeTenantMember(local.target.membershipID, arguments.customerID, arguments.role, arguments.status);
        }
    }

    // Only call after authorization and scope checks while holding the organization lock.
    private void function writeTenantMember(required numeric membershipID, required numeric customerID, required string role, required string status) {
        local.params = {
            membershipID: {type: "integer", value: arguments.membershipID},
            customerID: {type: "integer", value: arguments.customerID}
        };
        if (not len(arguments.role)) {
            queryExecute(
                options = {datasource: application.datasource},
                params = local.params,
                sql = "DELETE FROM tenant_memberships WHERE intOrgMembershipID = :membershipID AND intCustomerID = :customerID"
            );
        } else {
            local.params.role = {type: "varchar", value: arguments.role};
            local.params.status = {type: "varchar", value: arguments.status};
            queryExecute(
                options = {datasource: application.datasource},
                params = local.params,
                sql = "INSERT INTO tenant_memberships (intOrgMembershipID, intCustomerID, strRoleKey, strStatus)
                    VALUES (:membershipID, :customerID, :role, :status)
                    ON DUPLICATE KEY UPDATE strRoleKey = :role, strStatus = :status"
            );
        }
    }

    // All membership writers lock the same root first. Re-check permissions after
    // acquiring it so a waiting request cannot use rights revoked by its predecessor.
    private void function lockOrganization(required numeric organizationID) {
        local.organization = queryExecute(
            options = {datasource: application.datasource},
            params = {organizationID: {type: "integer", value: arguments.organizationID}},
            sql = "SELECT intCustomerID FROM customers
                WHERE intCustomerID = :organizationID AND intCustParentID = 0 AND blnActive = 1 FOR UPDATE"
        );
        if (not local.organization.recordCount) {
            reject("InvalidOrganization", "An active root organization is required.");
        }
    }

    private struct function lockActor(required numeric userID, required numeric organizationID) {
        local.actor = queryExecute(
            options = {datasource: application.datasource},
            params = {
                userID: {type: "integer", value: arguments.userID},
                organizationID: {type: "integer", value: arguments.organizationID}
            },
            sql = "SELECT membership.strRoleKey FROM organization_memberships membership
                INNER JOIN users ON users.intUserID = membership.intUserID
                WHERE membership.intUserID = :userID AND membership.intOrganizationID = :organizationID
                    AND membership.strStatus = 'active' AND users.blnActive = 1 FOR UPDATE"
        );
        if (not local.actor.recordCount) {
            reject("Forbidden", "An active membership in this organization is required.");
        }
        return {role: local.actor.strRoleKey};
    }

    private struct function requireOrganizationManager(required numeric userID, required numeric organizationID) {
        local.actor = lockActor(arguments.userID, arguments.organizationID);
        if (not listFindNoCase("organization.owner,organization.admin", local.actor.role)
            or not application.objAuthorization.canInOrganization(arguments.userID, arguments.organizationID, "organization.members.manage")) {
            reject("Forbidden", "Organization member management is not allowed.");
        }
        return local.actor;
    }

    private struct function lockTarget(required numeric userID, required numeric organizationID) {
        // The legacy home customer remains a boundary until identity migration.
        // Never attach an existing account from an unrelated organization.
        local.target = queryExecute(
            options = {datasource: application.datasource},
            params = {
                userID: {type: "integer", value: arguments.userID},
                organizationID: {type: "integer", value: arguments.organizationID}
            },
            sql = "SELECT users.blnActive, users.blnSysAdmin, membership.intOrgMembershipID,
                    CASE WHEN COALESCE(users.strPasswordHash, '') = '' AND COALESCE(users.strPasswordSalt, '') = '' THEN 1 ELSE 0 END AS activationPending,
                    membership.intOrganizationID, membership.strRoleKey, membership.strStatus
                FROM users INNER JOIN customers home ON home.intCustomerID = users.intCustomerID
                LEFT JOIN organization_memberships membership ON membership.intUserID = users.intUserID
                WHERE users.intUserID = :userID
                    AND ((home.intCustomerID = :organizationID AND home.intCustParentID = 0) OR home.intCustParentID = :organizationID)
                FOR UPDATE"
        );
        if (not local.target.recordCount
            or (val(local.target.intOrganizationID) gt 0 and local.target.intOrganizationID neq arguments.organizationID)) {
            reject("OutsideOrganization", "The user must belong to this organization.");
        }
        if (local.target.blnSysAdmin) {
            reject("ProtectedSystemUser", "Organization management cannot change platform administrator memberships.");
        }
        return {
            exists: val(local.target.intOrgMembershipID) gt 0,
            membershipID: val(local.target.intOrgMembershipID),
            userID: arguments.userID,
            active: local.target.blnActive eq 1,
            activationPending: local.target.activationPending eq 1,
            role: local.target.strRoleKey ?: "",
            status: local.target.strStatus ?: ""
        };
    }

    private void function protectOrganizationRole(required struct actor, required struct target, required string requestedRole) {
        if (arguments.actor.role neq "organization.owner"
            and (arguments.requestedRole neq "organization.member"
                or (arguments.target.exists and arguments.target.role neq "organization.member"))) {
            reject("ProtectedRole", "Only owners may manage organization administrators and owners.");
        }
    }

    private void function protectLastOwner(required struct target, required numeric organizationID, required string role, required string status) {
        if (arguments.target.role neq "organization.owner" or arguments.target.status neq "active" or not arguments.target.active
            or (arguments.role eq "organization.owner" and arguments.status eq "active")) {
            return;
        }
        local.owners = queryExecute(
            options = {datasource: application.datasource},
            params = {
                organizationID: {type: "integer", value: arguments.organizationID},
                userID: {type: "integer", value: arguments.target.userID}
            },
            sql = "SELECT membership.intUserID FROM organization_memberships membership
                INNER JOIN users ON users.intUserID = membership.intUserID
                WHERE membership.intOrganizationID = :organizationID AND membership.intUserID <> :userID
                    AND membership.strRoleKey = 'organization.owner' AND membership.strStatus = 'active'
                    AND users.blnActive = 1 FOR UPDATE"
        );
        if (not local.owners.recordCount) {
            reject("LastOwner", "The last active owner cannot be removed, suspended or demoted.");
        }
    }

    private void function validateChoice(required string value, required string allowed) {
        if (not listFind(arguments.allowed, arguments.value)) {
            reject("InvalidValue", "The requested role or membership status is not supported.");
        }
    }

    private void function reject(required string code, required string message) {
        throw(type = "Saaster.Membership." & arguments.code, message = arguments.message);
    }

}
