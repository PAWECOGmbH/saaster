component extends="tests.support.integration_spec" {

    function run() {
        describe("Transactional membership administration", () => {
            beforeEach(() => {
                variables.organization = variables.fixtures.createCustomer();
                variables.tenant = variables.fixtures.createCustomer(parentID = variables.organization);
                variables.sibling = variables.fixtures.createCustomer(parentID = variables.organization);
                variables.foreign = variables.fixtures.createCustomer();
                variables.owner = variables.fixtures.createUser(customerID = variables.organization);
                variables.admin = variables.fixtures.createUser(customerID = variables.organization);
                variables.member = variables.fixtures.createUser(customerID = variables.tenant);
                variables.stranger = variables.fixtures.createUser(customerID = variables.foreign, sysAdmin = true);
                seedMember(variables.owner.userID, "organization.owner");
                seedMember(variables.admin.userID, "organization.admin");
                seedMember(variables.member.userID, "organization.member");
                variables.service = application.objMembership;
            });

            it("saves organization status and multiple tenant assignments together", () => {
                variables.service.saveMember(variables.owner.userID, variables.organization, variables.member.userID,
                    {role: "organization.member", status: "suspended"}, [
                        {customerID: variables.tenant, role: "tenant.editor", status: "active"},
                        {customerID: variables.sibling, role: "tenant.viewer", status: "suspended"}
                    ]);
                expect(memberRecord(variables.member.userID).strStatus).toBe("suspended");
                local.saved = assignments(variables.member.userID);
                expect(local.saved.recordCount).toBe(2);
                expect(local.saved.filter((row) => row.intCustomerID eq variables.sibling).strStatus).toBe("suspended");
                expect(local.saved.filter((row) => row.intCustomerID eq variables.tenant).strRoleKey).toBe("tenant.editor");
            });

            it("leaves all roles and statuses unchanged when any tenant edit is invalid", () => {
                variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.viewer");
                local.changes = [
                    {customerID: variables.tenant, role: "tenant.admin", status: "active"},
                    {customerID: variables.sibling, role: "invalid", status: "active"}
                ];
                expect(() => variables.service.saveMember(variables.owner.userID, variables.organization, variables.member.userID,
                    {role: "organization.member", status: "suspended"}, changes)).toThrow(type = "Saaster.Membership.InvalidValue");
                local.changes[2] = {customerID: variables.foreign, role: "tenant.viewer", status: "active"};
                expect(() => variables.service.saveMember(variables.owner.userID, variables.organization, variables.member.userID,
                    {role: "organization.member", status: "suspended"}, changes)).toThrow(type = "Saaster.Membership.InvalidTenant");
                expect(memberRecord(variables.member.userID).strStatus).toBe("active");
                expect(assignments(variables.member.userID).recordCount).toBe(1);
                expect(assignments(variables.member.userID).strRoleKey).toBe("tenant.viewer");
            });

            it("prevents a tenant admin from injecting organization or sibling changes into a combined save", () => {
                local.target = variables.fixtures.createUser(customerID = variables.organization);
                seedMember(local.target.userID, "organization.member");
                variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.admin");
                local.allowed = {customerID: variables.tenant, role: "tenant.viewer", status: "active"};
                expect(() => variables.service.saveMember(variables.member.userID, variables.organization, target.userID,
                    {role: "organization.owner", status: "active"}, [allowed])).toThrow(type = "Saaster.Membership.Forbidden");
                expect(() => variables.service.saveMember(variables.member.userID, variables.organization, target.userID, {},
                    [allowed, {customerID: variables.sibling, role: "tenant.admin", status: "active"}])).toThrow(type = "Saaster.Membership.Forbidden");
                expect(assignments(local.target.userID).recordCount).toBe(0);
                expect(memberRecord(local.target.userID).strRoleKey).toBe("organization.member");
                variables.service.saveMember(variables.member.userID, variables.organization, local.target.userID, {}, [local.allowed]);
                expect(assignments(local.target.userID).strRoleKey).toBe("tenant.viewer");
            });

            it("validates all permissions before an administrator edits their own tenant access", () => {
                variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.admin");
                variables.service.setTenantMember(variables.owner.userID, variables.sibling, variables.member.userID, "tenant.admin");
                variables.service.saveMember(variables.member.userID, variables.organization, variables.member.userID, {}, [
                    {customerID: variables.tenant, role: "", status: "active"},
                    {customerID: variables.sibling, role: "tenant.viewer", status: "active"}
                ]);
                expect(assignments(variables.member.userID).recordCount).toBe(1);
                expect(assignments(variables.member.userID).strRoleKey).toBe("tenant.viewer");
            });

            it("protects the last owner during a combined save and allows a safe owner demotion", () => {
                local.changes = [{customerID: variables.organization, role: "tenant.viewer", status: "active"}];
                expect(() => variables.service.saveMember(variables.owner.userID, variables.organization, variables.owner.userID,
                    {role: "organization.member", status: "active"}, changes)).toThrow(type = "Saaster.Membership.LastOwner");
                expect(assignments(variables.owner.userID).recordCount).toBe(0);
                variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.admin.userID, "organization.owner");
                variables.service.saveMember(variables.owner.userID, variables.organization, variables.owner.userID,
                    {role: "organization.member", status: "active"}, local.changes);
                expect(memberRecord(variables.owner.userID).strRoleKey).toBe("organization.member");
                expect(assignments(variables.owner.userID).strRoleKey).toBe("tenant.viewer");
                expect(memberRecord(variables.admin.userID).strRoleKey).toBe("organization.owner");
            });

            it("restores membership and tenant access in one save", () => {
                variables.service.removeOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID);
                variables.service.saveMember(variables.owner.userID, variables.organization, variables.member.userID,
                    {role: "organization.member", status: "active"}, [{customerID: variables.tenant, role: "tenant.editor", status: "active"}]);
                expect(memberRecord(variables.member.userID).recordCount).toBe(1);
                expect(application.objAuthorization.canInTenant(variables.member.userID, variables.tenant, "tenant.content.write")).toBeTrue();
            });

            it("preserves explicit assignments on promotion and rejects edits to inherited access", () => {
                variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.viewer");
                variables.service.saveMember(variables.owner.userID, variables.organization, variables.member.userID,
                    {role: "organization.admin", status: "active"});
                expect(assignments(variables.member.userID).strRoleKey).toBe("tenant.viewer");
                expect(application.objAuthorization.canInTenant(variables.member.userID, variables.sibling, "tenant.members.manage")).toBeTrue();
                expect(() => variables.service.saveMember(variables.owner.userID, variables.organization, variables.member.userID, {},
                    [{customerID: variables.tenant, role: "", status: "active"}])).toThrow(type = "Saaster.Membership.InheritedAccess");
                expect(assignments(variables.member.userID).recordCount).toBe(1);
            });

            it("adds a same-family account and updates its membership without duplicating it", () => {
                local.user = variables.fixtures.createUser(customerID = variables.sibling);
                local.id = variables.service.setOrganizationMember(variables.admin.userID, variables.organization, local.user.userID);
                expect(local.id).toBeGT(0);
                expect(variables.service.setOrganizationMember(variables.admin.userID, variables.organization, local.user.userID, "organization.member", "suspended")).toBe(local.id);
                expect(memberRecord(local.user.userID).strStatus).toBe("suspended");
                expect(memberRecord(local.user.userID).recordCount).toBe(1);
            });

            it("allows owners to appoint administrators and additional owners", () => {
                variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID, "organization.admin");
                expect(memberRecord(variables.member.userID).strRoleKey).toBe("organization.admin");
                variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID, "organization.owner");
                expect(memberRecord(variables.member.userID).strRoleKey).toBe("organization.owner");
            });

            it("prevents organization admins from elevating themselves or another member", () => {
                expect(() => variables.service.setOrganizationMember(variables.admin.userID, variables.organization, variables.admin.userID, "organization.owner")).toThrow(type = "Saaster.Membership.ProtectedRole");
                expect(() => variables.service.setOrganizationMember(variables.admin.userID, variables.organization, variables.member.userID, "organization.admin")).toThrow(type = "Saaster.Membership.ProtectedRole");
                expect(memberRecord(variables.admin.userID).strRoleKey).toBe("organization.admin");
                expect(memberRecord(variables.member.userID).strRoleKey).toBe("organization.member");
            });

            it("prevents admins from removing or suspending an owner or another admin", () => {
                expect(() => variables.service.removeOrganizationMember(variables.admin.userID, variables.organization, variables.owner.userID)).toThrow(type = "Saaster.Membership.ProtectedRole");
                expect(() => variables.service.setOrganizationMember(variables.admin.userID, variables.organization, variables.owner.userID, "organization.member", "suspended")).toThrow(type = "Saaster.Membership.ProtectedRole");
                expect(() => variables.service.removeOrganizationMember(variables.admin.userID, variables.organization, variables.admin.userID)).toThrow(type = "Saaster.Membership.ProtectedRole");
            });

            it("does not allow a normal member or unrelated platform admin to manage the organization", () => {
                expect(() => variables.service.removeOrganizationMember(variables.member.userID, variables.organization, variables.admin.userID)).toThrow(type = "Saaster.Membership.Forbidden");
                expect(() => variables.service.removeOrganizationMember(variables.stranger.userID, variables.organization, variables.member.userID)).toThrow(type = "Saaster.Membership.Forbidden");
            });

            it("refuses accounts from another family even when the actor owns this organization", () => {
                expect(() => variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.stranger.userID)).toThrow(type = "Saaster.Membership.OutsideOrganization");
                expect(memberRecord(variables.stranger.userID).recordCount).toBe(0);
            });

            it("protects platform administrator memberships from organization management", () => {
                variables.systemUser = variables.fixtures.createUser(customerID = variables.organization, sysAdmin = true);
                seedMember(variables.systemUser.userID, "organization.member");
                expect(() => variables.service.removeOrganizationMember(variables.owner.userID, variables.organization, variables.systemUser.userID)).toThrow(type = "Saaster.Membership.ProtectedSystemUser");
                expect(() => variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.systemUser.userID, "organization.admin")).toThrow(type = "Saaster.Membership.ProtectedSystemUser");
                expect(() => variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.systemUser.userID, "tenant.admin")).toThrow(type = "Saaster.Membership.ProtectedSystemUser");
            });

            it("rejects unknown roles, wrong scopes and invitation states", () => {
                expect(() => variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID, "tenant.admin")).toThrow(type = "Saaster.Membership.InvalidValue");
                expect(() => variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "organization.owner")).toThrow(type = "Saaster.Membership.InvalidValue");
                expect(() => variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID, "organization.member", "invited")).toThrow(type = "Saaster.Membership.InvalidValue");
            });

            it("requires an active root and rejects child organizations", () => {
                expect(() => variables.service.setOrganizationMember(variables.owner.userID, variables.tenant, variables.member.userID)).toThrow(type = "Saaster.Membership.InvalidOrganization");
                executeSQL("UPDATE customers SET blnActive = 0 WHERE intCustomerID = :id", idParam(variables.organization));
                expect(() => variables.service.removeOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID)).toThrow(type = "Saaster.Membership.InvalidOrganization");
            });

            it("does not remove, suspend or demote the last active owner", () => {
                expect(() => variables.service.removeOrganizationMember(variables.owner.userID, variables.organization, variables.owner.userID)).toThrow(type = "Saaster.Membership.LastOwner");
                expect(() => variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.owner.userID, "organization.owner", "suspended")).toThrow(type = "Saaster.Membership.LastOwner");
                expect(() => variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.owner.userID, "organization.admin")).toThrow(type = "Saaster.Membership.LastOwner");
                expect(memberRecord(variables.owner.userID).strRoleKey).toBe("organization.owner");
                expect(memberRecord(variables.owner.userID).strStatus).toBe("active");
            });

            it("does not count a suspended owner or an inactive user as an effective owner", () => {
                variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID, "organization.owner", "suspended");
                expect(() => variables.service.removeOrganizationMember(variables.owner.userID, variables.organization, variables.owner.userID)).toThrow(type = "Saaster.Membership.LastOwner");
                variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID, "organization.owner");
                executeSQL("UPDATE users SET blnActive = 0 WHERE intUserID = :id", idParam(variables.member.userID));
                expect(() => variables.service.removeOrganizationMember(variables.owner.userID, variables.organization, variables.owner.userID)).toThrow(type = "Saaster.Membership.LastOwner");
            });

            it("allows an owner to leave when another active owner remains", () => {
                variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID, "organization.owner");
                variables.service.removeOrganizationMember(variables.owner.userID, variables.organization, variables.owner.userID);
                expect(memberRecord(variables.owner.userID).recordCount).toBe(0);
                expect(memberRecord(variables.member.userID).strRoleKey).toBe("organization.owner");
                expect(executeSQL("SELECT intUserID FROM users WHERE intUserID = :id", idParam(variables.owner.userID)).recordCount).toBe(1);
            });

            it("keeps an owner when two owners try to remove themselves concurrently", () => {
                variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID, "organization.owner");
                local.actors = [variables.owner.userID, variables.member.userID];
                local.outcomes = ["", ""];
                local.organizationID = variables.organization;
                [1, 2].each((index) => {
                    try {
                        new backend.core.com.membership().removeOrganizationMember(actors[index], organizationID, actors[index]);
                        outcomes[index] = "removed";
                    } catch (any e) {
                        outcomes[index] = e.type;
                    }
                }, true, 2);
                expect(arrayToList(local.outcomes)).toInclude("removed");
                expect(arrayToList(local.outcomes)).toInclude("Saaster.Membership.LastOwner");
                expect(executeSQL("SELECT intUserID FROM organization_memberships WHERE intOrganizationID = :id AND strRoleKey = 'organization.owner'", idParam(variables.organization)).recordCount).toBe(1);
            });

            it("transfers ownership atomically and preserves both identities", () => {
                variables.service.transferOwnership(variables.owner.userID, variables.organization, variables.member.userID);
                expect(memberRecord(variables.owner.userID).strRoleKey).toBe("organization.admin");
                expect(memberRecord(variables.member.userID).strRoleKey).toBe("organization.owner");
                expect(application.objAuthorization.canInOrganization(variables.owner.userID, variables.organization, "organization.ownership.transfer")).toBeFalse();
                expect(application.objAuthorization.canInOrganization(variables.member.userID, variables.organization, "organization.ownership.transfer")).toBeTrue();
            });

            it("rejects ownership transfer by an admin, to oneself or across organizations", () => {
                expect(() => variables.service.transferOwnership(variables.admin.userID, variables.organization, variables.member.userID)).toThrow(type = "Saaster.Membership.Forbidden");
                expect(() => variables.service.transferOwnership(variables.owner.userID, variables.organization, variables.owner.userID)).toThrow(type = "Saaster.Membership.Forbidden");
                expect(() => variables.service.transferOwnership(variables.owner.userID, variables.organization, variables.stranger.userID)).toThrow(type = "Saaster.Membership.OutsideOrganization");
                expect(memberRecord(variables.owner.userID).strRoleKey).toBe("organization.owner");
            });

            it("keeps the original owner when the recipient is suspended or inactive", () => {
                variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID, "organization.member", "suspended");
                expect(() => variables.service.transferOwnership(variables.owner.userID, variables.organization, variables.member.userID)).toThrow(type = "Saaster.Membership.InactiveOwner");
                variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID);
                executeSQL("UPDATE users SET blnActive = 0 WHERE intUserID = :id", idParam(variables.member.userID));
                expect(() => variables.service.transferOwnership(variables.owner.userID, variables.organization, variables.member.userID)).toThrow(type = "Saaster.Membership.InactiveOwner");
                expect(() => variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID, "organization.owner")).toThrow(type = "Saaster.Membership.InactiveOwner");
                expect(memberRecord(variables.owner.userID).strRoleKey).toBe("organization.owner");
            });

            it("lets a platform administrator who is the owner transfer their own ownership", () => {
                executeSQL("UPDATE users SET blnSysAdmin = 1 WHERE intUserID = :id", idParam(variables.owner.userID));
                variables.service.transferOwnership(variables.owner.userID, variables.organization, variables.member.userID);
                expect(memberRecord(variables.member.userID).strRoleKey).toBe("organization.owner");
                expect(executeSQL("SELECT blnSysAdmin FROM users WHERE intUserID = :id", idParam(variables.owner.userID)).blnSysAdmin).toBe(1);
            });

            it("adds and updates tenant roles without affecting sibling assignments", () => {
                variables.service.setTenantMember(variables.admin.userID, variables.tenant, variables.member.userID, "tenant.admin");
                variables.service.setTenantMember(variables.admin.userID, variables.sibling, variables.member.userID, "tenant.viewer");
                variables.service.setTenantMember(variables.admin.userID, variables.tenant, variables.member.userID, "tenant.editor");
                expect(application.objAuthorization.canInTenant(variables.member.userID, variables.tenant, "tenant.content.write")).toBeTrue();
                expect(application.objAuthorization.canInTenant(variables.member.userID, variables.tenant, "tenant.members.manage")).toBeFalse();
                expect(application.objAuthorization.canInTenant(variables.member.userID, variables.sibling, "tenant.content.write")).toBeFalse();
                expect(assignments(variables.member.userID).recordCount).toBe(2);
            });

            it("limits a tenant admin to that tenant and to existing organization members", () => {
                variables.targetUser = variables.fixtures.createUser(customerID = variables.organization);
                variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.admin");
                expect(() => variables.service.setTenantMember(variables.member.userID, variables.tenant, variables.targetUser.userID)).toThrow(type = "Saaster.Membership.MissingMembership");
                variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.targetUser.userID);
                variables.service.setTenantMember(variables.member.userID, variables.tenant, variables.targetUser.userID, "tenant.admin");
                expect(() => variables.service.setTenantMember(variables.member.userID, variables.sibling, variables.targetUser.userID)).toThrow(type = "Saaster.Membership.Forbidden");
                expect(() => variables.service.setOrganizationMember(variables.member.userID, variables.organization, variables.targetUser.userID, "organization.admin")).toThrow(type = "Saaster.Membership.Forbidden");
            });

            it("denies tenant member management to viewers, editors and suspended admins", () => {
                variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.viewer");
                expect(() => variables.service.removeTenantMember(variables.member.userID, variables.tenant, variables.member.userID)).toThrow(type = "Saaster.Membership.Forbidden");
                variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.editor");
                expect(() => variables.service.removeTenantMember(variables.member.userID, variables.tenant, variables.member.userID)).toThrow(type = "Saaster.Membership.Forbidden");
                variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.admin", "suspended");
                expect(() => variables.service.removeTenantMember(variables.member.userID, variables.tenant, variables.member.userID)).toThrow(type = "Saaster.Membership.Forbidden");
            });

            it("rejects foreign targets, unrelated tenants and malformed hierarchies", () => {
                expect(() => variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.stranger.userID)).toThrow(type = "Saaster.Membership.OutsideOrganization");
                expect(() => variables.service.setTenantMember(variables.owner.userID, variables.foreign, variables.member.userID)).toThrow(type = "Saaster.Membership.Forbidden");
                variables.grandchild = variables.fixtures.createCustomer(parentID = variables.tenant);
                expect(() => variables.service.setTenantMember(variables.owner.userID, variables.grandchild, variables.member.userID)).toThrow(type = "Saaster.Membership.InvalidOrganization");
            });

            it("rejects tenant edits that would pretend to restrict inherited organization access", () => {
                expect(() => variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.admin.userID, "tenant.viewer")).toThrow(type = "Saaster.Membership.InheritedAccess");
                expect(() => variables.service.removeTenantMember(variables.owner.userID, variables.tenant, variables.owner.userID)).toThrow(type = "Saaster.Membership.InheritedAccess");
            });

            it("removes only the requested tenant access and is safe to repeat", () => {
                variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.admin");
                variables.service.setTenantMember(variables.owner.userID, variables.sibling, variables.member.userID, "tenant.viewer");
                variables.service.removeTenantMember(variables.admin.userID, variables.tenant, variables.member.userID);
                variables.service.removeTenantMember(variables.admin.userID, variables.tenant, variables.member.userID);
                expect(application.objAuthorization.canInTenant(variables.member.userID, variables.tenant, "tenant.view")).toBeFalse();
                expect(application.objAuthorization.canInTenant(variables.member.userID, variables.sibling, "tenant.view")).toBeTrue();
                expect(memberRecord(variables.member.userID).recordCount).toBe(1);
            });

            it("removes memberships without deleting the user or changing legacy access", () => {
                variables.service.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.admin");
                variables.service.removeOrganizationMember(variables.admin.userID, variables.organization, variables.member.userID);
                variables.service.removeOrganizationMember(variables.admin.userID, variables.organization, variables.member.userID);
                expect(memberRecord(variables.member.userID).recordCount).toBe(0);
                expect(assignments(variables.member.userID).recordCount).toBe(0);
                expect(executeSQL("SELECT intUserID FROM users WHERE intUserID = :id", idParam(variables.member.userID)).recordCount).toBe(1);
                expect(application.objGlobal.checkTenantRange(variables.member.userID, variables.tenant)).toBeTrue();
            });

            it("rechecks revoked administrator rights on the next mutation", () => {
                variables.service.setOrganizationMember(variables.owner.userID, variables.organization, variables.admin.userID, "organization.member");
                expect(() => variables.service.removeOrganizationMember(variables.admin.userID, variables.organization, variables.member.userID)).toThrow(type = "Saaster.Membership.Forbidden");
                expect(memberRecord(variables.member.userID).recordCount).toBe(1);
            });
        });
    }

    private struct function idParam(required numeric id) {
        return {id: {type: "integer", value: arguments.id}};
    }

    private any function executeSQL(required string sql, struct params = {}) {
        return queryExecute(options = {datasource: application.datasource}, params = arguments.params, sql = arguments.sql);
    }

    private void function seedMember(required numeric userID, required string role) {
        executeSQL("INSERT INTO organization_memberships (intOrganizationID, intUserID, strRoleKey) VALUES (:organizationID, :userID, :role)", {
            organizationID: {type: "integer", value: variables.organization},
            userID: {type: "integer", value: arguments.userID}, role: {type: "varchar", value: arguments.role}
        });
    }

    private query function memberRecord(required numeric userID) {
        return executeSQL("SELECT * FROM organization_memberships WHERE intUserID = :id", idParam(arguments.userID));
    }

    private query function assignments(required numeric userID) {
        return executeSQL("SELECT assignment.* FROM tenant_memberships assignment INNER JOIN organization_memberships membership
            ON membership.intOrgMembershipID = assignment.intOrgMembershipID WHERE membership.intUserID = :id", idParam(arguments.userID));
    }

}
