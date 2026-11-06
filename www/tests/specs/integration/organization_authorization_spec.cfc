component extends="tests.support.integration_spec" {

    function run() {
        describe("Organization and tenant authorization", () => {
            beforeEach(() => {
                variables.organizationID = variables.fixtures.createCustomer();
                variables.tenantA = variables.fixtures.createCustomer(parentID = variables.organizationID);
                variables.tenantB = variables.fixtures.createCustomer(parentID = variables.organizationID);
                variables.foreignOrganization = variables.fixtures.createCustomer();
                variables.foreignTenant = variables.fixtures.createCustomer(parentID = variables.foreignOrganization);
                variables.user = variables.fixtures.createUser(customerID = variables.organizationID);
                variables.membershipID = addOrganizationMembership(variables.user.userID, variables.organizationID);
                variables.authorization = application.objAuthorization;
            });

            it("gives an organization member organization visibility without implicit tenant access", () => {
                expect(canOrganization("organization.view")).toBeTrue();
                expect(canOrganization("organization.members.manage")).toBeFalse();
                expect(canTenant(variables.organizationID, "tenant.view")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.view")).toBeFalse();
            });

            it("allows different roles in sibling tenants without leaking rights between them", () => {
                addTenantMembership(variables.tenantA, "tenant.admin");
                addTenantMembership(variables.tenantB, "tenant.viewer");

                expect(canTenant(variables.tenantA, "tenant.members.manage")).toBeTrue();
                expect(canTenant(variables.tenantA, "tenant.billing.manage")).toBeTrue();
                expect(canTenant(variables.tenantB, "tenant.content.read")).toBeTrue();
                expect(canTenant(variables.tenantB, "tenant.content.write")).toBeFalse();
                expect(canTenant(variables.tenantB, "tenant.members.manage")).toBeFalse();
                expect(canTenant(variables.tenantB, "tenant.billing.view")).toBeFalse();
            });

            it("lets editors edit content without managing members, settings or billing", () => {
                addTenantMembership(variables.tenantA, "tenant.editor");

                expect(canTenant(variables.tenantA, "tenant.content.read")).toBeTrue();
                expect(canTenant(variables.tenantA, "tenant.content.write")).toBeTrue();
                expect(canTenant(variables.tenantA, "tenant.members.manage")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.settings.manage")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.billing.view")).toBeFalse();
            });

            it("requires an explicit tenant assignment to access business data in the root", () => {
                addTenantMembership(variables.organizationID, "tenant.viewer");

                expect(canTenant(variables.organizationID, "tenant.content.read")).toBeTrue();
                expect(canTenant(variables.organizationID, "tenant.content.write")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.content.read")).toBeFalse();
            });

            it("inherits organization admin rights across the family without ownership powers", () => {
                setOrganizationRole("organization.admin");

                expect(canOrganization("organization.members.manage")).toBeTrue();
                expect(canOrganization("organization.tenants.manage")).toBeTrue();
                expect(canOrganization("organization.settings.manage")).toBeTrue();
                expect(canOrganization("organization.ownership.transfer")).toBeFalse();
                expect(canOrganization("organization.delete")).toBeFalse();
                expect(canTenant(variables.organizationID, "tenant.billing.manage")).toBeTrue();
                expect(canTenant(variables.tenantA, "tenant.members.manage")).toBeTrue();
                expect(canTenant(variables.tenantB, "tenant.content.write")).toBeTrue();
                expect(canTenant(variables.foreignTenant, "tenant.view")).toBeFalse();
            });

            it("gives explicit owners ownership permissions only in their own organization", () => {
                setOrganizationRole("organization.owner");

                expect(canOrganization("organization.ownership.transfer")).toBeTrue();
                expect(canOrganization("organization.delete")).toBeTrue();
                expect(variables.authorization.canInOrganization(variables.user.userID, variables.foreignOrganization, "organization.delete")).toBeFalse();
                expect(canTenant(variables.foreignTenant, "tenant.content.read")).toBeFalse();
            });

            it("does not narrow inherited organization grants through a tenant assignment", () => {
                setOrganizationRole("organization.admin");
                addTenantMembership(variables.tenantA, "tenant.viewer", "suspended");

                expect(canTenant(variables.tenantA, "tenant.content.write")).toBeTrue();
                expect(canTenant(variables.tenantA, "tenant.members.manage")).toBeTrue();
            });

            it("keeps organization and tenant permission contexts separate", () => {
                setOrganizationRole("organization.owner");

                expect(canOrganization("tenant.view")).toBeFalse();
                expect(canTenant(variables.organizationID, "organization.delete")).toBeFalse();
                expect(variables.authorization.canInOrganization(variables.user.userID, variables.tenantA, "organization.view")).toBeFalse();
            });

            it("rejects unknown permissions, wildcards and SQL-shaped input", () => {
                setOrganizationRole("organization.owner");

                expect(canOrganization("*")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.*")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.future.permission")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.view' OR 1=1 --")).toBeFalse();
                expect(canOrganization("")).toBeFalse();
            });

            it("denies missing users and customers", () => {
                expect(variables.authorization.canInOrganization(0, variables.organizationID, "organization.view")).toBeFalse();
                expect(variables.authorization.canInTenant(0, variables.tenantA, "tenant.view")).toBeFalse();
                expect(variables.authorization.canInOrganization(variables.user.userID, 0, "organization.view")).toBeFalse();
                expect(canTenant(0, "tenant.view")).toBeFalse();
            });

            it("rejects imported assignments to an unrelated root or its tenant", () => {
                addTenantMembership(variables.foreignOrganization, "tenant.admin");
                addTenantMembership(variables.foreignTenant, "tenant.admin");

                expect(canTenant(variables.foreignOrganization, "tenant.view")).toBeFalse();
                expect(canTenant(variables.foreignTenant, "tenant.view")).toBeFalse();
                expect(canOrganization("organization.view")).toBeTrue();
            });

            it("rejects grandchildren even for an organization owner", () => {
                local.grandchild = variables.fixtures.createCustomer(parentID = variables.tenantA);
                setOrganizationRole("organization.owner");
                addTenantMembership(local.grandchild, "tenant.admin");

                expect(canTenant(local.grandchild, "tenant.view")).toBeFalse();
            });

            it("rejects a child incorrectly stored as an organization", () => {
                setOrganizationRole("organization.owner");
                executeSQL(
                    "UPDATE organization_memberships SET intOrganizationID = :id WHERE intOrgMembershipID = :membership",
                    {id: {type: "integer", value: variables.tenantA}, membership: membershipParam()}
                );

                expect(variables.authorization.canInOrganization(variables.user.userID, variables.tenantA, "organization.view")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.view")).toBeFalse();
            });

            it("denies a tenant whose parent has disappeared", () => {
                addTenantMembership(variables.tenantA, "tenant.admin");
                executeSQL("DELETE FROM customers WHERE intCustomerID = :id", {id: {type: "integer", value: variables.organizationID}});

                expect(canTenant(variables.tenantA, "tenant.view")).toBeFalse();
            });

            it("rechecks the family when a tenant moves to a different organization", () => {
                addTenantMembership(variables.tenantA, "tenant.admin");
                expect(canTenant(variables.tenantA, "tenant.content.write")).toBeTrue();
                executeSQL(
                    "UPDATE customers SET intCustParentID = :parent WHERE intCustomerID = :id",
                    {parent: {type: "integer", value: variables.foreignOrganization}, id: {type: "integer", value: variables.tenantA}}
                );

                expect(canTenant(variables.tenantA, "tenant.content.write")).toBeFalse();
            });

            it("applies role changes without waiting for a new login", () => {
                addTenantMembership(variables.tenantA, "tenant.admin");
                expect(canTenant(variables.tenantA, "tenant.content.write")).toBeTrue();
                executeSQL(
                    "UPDATE tenant_memberships SET strRoleKey = 'tenant.viewer' WHERE intOrgMembershipID = :membership",
                    {membership: membershipParam()}
                );

                expect(canTenant(variables.tenantA, "tenant.content.write")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.content.read")).toBeTrue();
            });

            it("applies tenant suspension without affecting an active sibling assignment", () => {
                addTenantMembership(variables.tenantA, "tenant.admin");
                addTenantMembership(variables.tenantB, "tenant.viewer");
                expect(canTenant(variables.tenantA, "tenant.view")).toBeTrue();
                executeSQL(
                    "UPDATE tenant_memberships SET strStatus = 'suspended' WHERE intOrgMembershipID = :membership AND intCustomerID = :id",
                    {membership: membershipParam(), id: {type: "integer", value: variables.tenantA}}
                );

                expect(canTenant(variables.tenantA, "tenant.view")).toBeFalse();
                expect(canTenant(variables.tenantB, "tenant.view")).toBeTrue();
            });

            it("revokes all access when the organization membership is suspended", () => {
                setOrganizationRole("organization.owner");
                addTenantMembership(variables.tenantA, "tenant.admin");
                expect(canTenant(variables.tenantA, "tenant.view")).toBeTrue();
                executeSQL(
                    "UPDATE organization_memberships SET strStatus = 'suspended' WHERE intOrgMembershipID = :membership",
                    {membership: membershipParam()}
                );

                expect(canOrganization("organization.view")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.view")).toBeFalse();
            });

            it("removes tenant access without deleting the identity or sibling assignment", () => {
                addTenantMembership(variables.tenantA, "tenant.admin");
                addTenantMembership(variables.tenantB, "tenant.viewer");
                executeSQL(
                    "DELETE FROM tenant_memberships WHERE intOrgMembershipID = :membership AND intCustomerID = :id",
                    {membership: membershipParam(), id: {type: "integer", value: variables.tenantA}}
                );

                expect(canTenant(variables.tenantA, "tenant.view")).toBeFalse();
                expect(canTenant(variables.tenantB, "tenant.view")).toBeTrue();
                expect(canOrganization("organization.view")).toBeTrue();
            });

            it("revokes organization and tenant rights after membership removal", () => {
                addTenantMembership(variables.tenantA, "tenant.admin");
                executeSQL("DELETE FROM organization_memberships WHERE intOrgMembershipID = :membership", {membership: membershipParam()});

                expect(canOrganization("organization.view")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.view")).toBeFalse();
                expect(executeSQL("SELECT intUserID FROM users WHERE intUserID = :id", {id: {type: "integer", value: variables.user.userID}}).recordCount).toBe(1);
                expect(executeSQL("SELECT intTenantMembershipID FROM tenant_memberships WHERE intOrgMembershipID = :membership", {membership: membershipParam()}).recordCount).toBe(0);
            });

            it("denies an inactive user even when the membership is active", () => {
                setOrganizationRole("organization.owner");
                executeSQL("UPDATE users SET blnActive = 0 WHERE intUserID = :id", {id: {type: "integer", value: variables.user.userID}});

                expect(canOrganization("organization.view")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.view")).toBeFalse();
            });

            it("denies all access through an inactive organization", () => {
                setOrganizationRole("organization.owner");
                executeSQL("UPDATE customers SET blnActive = 0 WHERE intCustomerID = :id", {id: {type: "integer", value: variables.organizationID}});

                expect(canOrganization("organization.view")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.view")).toBeFalse();
            });

            it("denies an inactive tenant while keeping its active siblings accessible", () => {
                setOrganizationRole("organization.owner");
                executeSQL("UPDATE customers SET blnActive = 0 WHERE intCustomerID = :id", {id: {type: "integer", value: variables.tenantA}});

                expect(canTenant(variables.tenantA, "tenant.view")).toBeFalse();
                expect(canTenant(variables.tenantB, "tenant.view")).toBeTrue();
                expect(canOrganization("organization.view")).toBeTrue();
            });

            it("does not turn legacy global flags or session flags into membership permissions", () => {
                executeSQL(
                    "UPDATE users SET blnAdmin = 1, blnSuperAdmin = 1, blnSysAdmin = 1 WHERE intUserID = :id",
                    {id: {type: "integer", value: variables.user.userID}}
                );
                loginAs(variables.user);
                session.admin = true;
                session.superadmin = true;
                session.sysadmin = true;

                expect(canOrganization("organization.delete")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.view")).toBeFalse();
                expect(canTenant(variables.foreignTenant, "tenant.view")).toBeFalse();
            });

            it("requires a new membership even when a legacy tenant assignment exists", () => {
                variables.fixtures.grantTenant(variables.user.userID, variables.tenantA);
                executeSQL("DELETE FROM organization_memberships WHERE intOrgMembershipID = :membership", {membership: membershipParam()});

                expect(application.objGlobal.checkTenantRange(variables.user.userID, variables.tenantA)).toBeTrue();
                expect(canOrganization("organization.view")).toBeFalse();
                expect(canTenant(variables.tenantA, "tenant.view")).toBeFalse();
            });

            it("returns distinct effective permissions when both roles grant them", () => {
                setOrganizationRole("organization.admin");
                addTenantMembership(variables.tenantA, "tenant.admin");
                local.permissions = variables.authorization.getTenantPermissions(variables.user.userID, variables.tenantA);

                expect(local.permissions.recordCount).toBe(7);
                expect(listValueCountNoCase(valueList(local.permissions.strPermissionKey), "tenant.view")).toBe(1);
            });

            it("enforces one organization per identity even for suspended memberships", () => {
                executeSQL("UPDATE organization_memberships SET strStatus = 'suspended' WHERE intOrgMembershipID = :membership", {membership: membershipParam()});

                expect(() => addOrganizationMembership(variables.user.userID, variables.foreignOrganization)).toThrow();
            });

            it("rejects duplicate tenant memberships", () => {
                addTenantMembership(variables.tenantA, "tenant.viewer");

                expect(() => addTenantMembership(variables.tenantA, "tenant.admin")).toThrow();
            });

            it("rejects roles from the wrong scope and unknown role names", () => {
                expect(() => setOrganizationRole("tenant.admin")).toThrow();
                expect(() => addTenantMembership(variables.tenantA, "organization.owner")).toThrow();
                expect(() => setOrganizationRole("organization.missing")).toThrow();
                expect(() => addTenantMembership(variables.tenantA, "tenant.missing")).toThrow();
            });

            it("rejects attempts to bypass role scope using the stored scope column", () => {
                expect(() => executeSQL(
                    "UPDATE organization_memberships SET strRoleKey = 'tenant.admin', strRoleScope = 'tenant' WHERE intOrgMembershipID = :membership",
                    {membership: membershipParam()}
                )).toThrow();

                addTenantMembership(variables.tenantA, "tenant.viewer");
                expect(() => executeSQL(
                    "UPDATE tenant_memberships SET strRoleKey = 'organization.owner', strRoleScope = 'organization' WHERE intOrgMembershipID = :membership",
                    {membership: membershipParam()}
                )).toThrow();
            });

            it("rejects unsupported membership states", () => {
                expect(() => executeSQL(
                    "UPDATE organization_memberships SET strStatus = 'invited' WHERE intOrgMembershipID = :membership",
                    {membership: membershipParam()}
                )).toThrow();
                expect(() => addTenantMembership(variables.tenantA, "tenant.viewer", "invited")).toThrow();
            });

            it("can repeat V26 while preserving role choices, suspension and legacy records", () => {
                local.migrationFile = "/var/saaster/db/core/V26__organization-memberships.sql";
                expect(fileExists(local.migrationFile)).toBeTrue("Mount config/db at /var/saaster/db before running migration specs.");
                setOrganizationRole("organization.admin");
                addTenantMembership(variables.tenantA, "tenant.editor", "suspended");
                local.before = executeSQL("SELECT * FROM users WHERE intUserID = :id", {id: {type: "integer", value: variables.user.userID}});
                local.source = fileRead(local.migrationFile, "utf-8");
                local.lines = listToArray(replace(local.source, chr(13), "", "all"), chr(10), true).filter((line) => !reFind("^\s*--", line));
                local.statements = listToArray(arrayToList(local.lines, chr(10)), ";").filter((statement) => len(trim(statement)));

                loop times=2 {
                    loop array=local.statements item="local.statement" {
                        executeSQL(local.statement);
                    }
                }

                local.membership = executeSQL("SELECT * FROM organization_memberships WHERE intOrgMembershipID = :membership", {membership: membershipParam()});
                local.assignment = executeSQL("SELECT * FROM tenant_memberships WHERE intOrgMembershipID = :membership", {membership: membershipParam()});
                local.after = executeSQL("SELECT * FROM users WHERE intUserID = :id", {id: {type: "integer", value: variables.user.userID}});
                expect(local.membership.recordCount).toBe(1);
                expect(local.membership.strRoleKey).toBe("organization.admin");
                expect(local.assignment.recordCount).toBe(1);
                expect(local.assignment.strRoleKey).toBe("tenant.editor");
                expect(local.assignment.strStatus).toBe("suspended");
                expect(serializeJSON(local.after)).toBe(serializeJSON(local.before));
                expect(application.objGlobal.checkTenantRange(variables.user.userID, variables.organizationID)).toBeTrue();
            });
        });
    }

    private boolean function canOrganization(required string permission) {
        return variables.authorization.canInOrganization(variables.user.userID, variables.organizationID, arguments.permission);
    }

    private boolean function canTenant(required numeric customerID, required string permission) {
        return variables.authorization.canInTenant(variables.user.userID, arguments.customerID, arguments.permission);
    }

    private struct function membershipParam() {
        return {type: "integer", value: variables.membershipID};
    }

    private any function executeSQL(required string sql, struct params = {}) {
        return queryExecute(options = {datasource: application.datasource}, params = arguments.params, sql = arguments.sql);
    }

    private numeric function addOrganizationMembership(required numeric userID, required numeric organizationID) {
        queryExecute(
            options = {datasource: application.datasource, result: "local.inserted"},
            params = {
                userID: {type: "integer", value: arguments.userID},
                organizationID: {type: "integer", value: arguments.organizationID}
            },
            sql = "INSERT INTO organization_memberships (intUserID, intOrganizationID) VALUES (:userID, :organizationID)"
        );
        return local.inserted.generatedKey;
    }

    private void function setOrganizationRole(required string role) {
        executeSQL(
            "UPDATE organization_memberships SET strRoleKey = :role WHERE intOrgMembershipID = :membership",
            {role: {type: "varchar", value: arguments.role}, membership: membershipParam()}
        );
    }

    private void function addTenantMembership(required numeric customerID, required string role, string status = "active") {
        executeSQL(
            "INSERT INTO tenant_memberships (intOrgMembershipID, intCustomerID, strRoleKey, strStatus) VALUES (:membership, :customerID, :role, :status)",
            {
                membership: membershipParam(),
                customerID: {type: "integer", value: arguments.customerID},
                role: {type: "varchar", value: arguments.role},
                status: {type: "varchar", value: arguments.status}
            }
        );
    }

}
