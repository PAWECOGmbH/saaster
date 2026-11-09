component extends="tests.support.integration_spec" {
    function run() {
        describe("Independent organization memberships", () => {
            beforeEach(() => {
                logout();
                variables.a = variables.fixtures.createCustomer();
                variables.b = variables.fixtures.createCustomer();
                variables.user = variables.fixtures.createUser(customerID = variables.a);
                variables.owner = variables.fixtures.createUser(customerID = variables.a);
                variables.ownerB = variables.fixtures.createUser(customerID = variables.b);
                seed(variables.user.userID, variables.a, "organization.admin");
                seed(variables.user.userID, variables.b, "organization.member");
                seed(variables.owner.userID, variables.a, "organization.owner");
                seed(variables.ownerB.userID, variables.b, "organization.owner");
                queryExecute(options = {datasource: application.datasource}, params = {
                    userID: {type: "integer", value: variables.user.userID}, organizationID: {type: "integer", value: variables.b}
                }, sql = "INSERT INTO tenant_memberships (intOrgMembershipID, intCustomerID, strRoleKey)
                    SELECT intOrgMembershipID, :organizationID, 'tenant.viewer' FROM organization_memberships
                    WHERE intUserID = :userID AND intOrganizationID = :organizationID");
            });
            afterEach(() => { logout(); });

            it("resolves administrator and viewer rights independently when switching contexts", () => {
                local.a = application.objMembershipAccess.context(variables.user.userID, variables.a, false);
                local.b = application.objMembershipAccess.context(variables.user.userID, variables.b, false);
                expect(local.a.organizationID).toBe(variables.a);
                expect(local.a.admin).toBeTrue();
                expect(local.b.organizationID).toBe(variables.b);
                expect(local.b.role).toBe("organization.member");
                expect(local.b.admin).toBeFalse();
                expect(local.b.superadmin).toBeFalse();
                loginAs(variables.user);
                application.objMembershipAccess.refreshSession();
                session.customer_id = variables.b;
                expect(application.objMembershipAccess.refreshSession()).toBeTrue();
                expect(session.admin).toBeFalse();
                expect(session.organization_id).toBe(variables.b);
            });
            it("limits role updates, suspension and removal to the selected organization", () => {
                application.objMembership.setOrganizationMember(variables.owner.userID, variables.a, variables.user.userID, "organization.member", "suspended");
                expect(application.objMembershipAccess.context(variables.user.userID, variables.a, false).allowed).toBeFalse();
                expect(application.objMembershipAccess.context(variables.user.userID, variables.b, false).allowed).toBeTrue();
                application.objMembership.removeOrganizationMember(variables.owner.userID, variables.a, variables.user.userID);
                expect(application.objMembershipAccess.context(variables.user.userID, variables.b, false).allowed).toBeTrue();
                expect(application.objMembershipAccess.context(variables.user.userID).organizationID).toBe(variables.b);
            });
            it("keeps identities and remaining access when their legacy home row is deleted", () => {
                queryExecute(options = {datasource: application.datasource}, params = {id: {type: "integer", value: variables.a}},
                    sql = "DELETE FROM customers WHERE intCustomerID = :id");
                expect(application.objMembershipAccess.context(variables.user.userID).organizationID).toBe(variables.b);
                expect(application.objAuthorization.canInTenant(variables.user.userID, variables.b, "tenant.view")).toBeTrue();
            });
            it("rejects a form from another context even when the identity can access both", () => {
                loginAs(variables.user);
                application.objMembershipAccess.refreshSession();
                local.token = application.objGlobal.contextToken();
                expect(application.objGlobal.contextVerify(local.token)).toBeTrue();
                session.customer_id = variables.b;
                application.objMembershipAccess.refreshSession();
                expect(application.objGlobal.contextVerify(local.token)).toBeFalse();
                expect(application.objGlobal.contextVerify("")).toBeFalse();
                expect(application.objGlobal.contextVerify(application.objGlobal.contextToken())).toBeTrue();
            });
            it("never transfers ownership or administrator rights into a second organization", () => {
                application.objMembership.setOrganizationMember(variables.owner.userID, variables.a, variables.user.userID, "organization.owner");
                application.objMembership.transferOwnership(variables.user.userID, variables.a, variables.owner.userID);
                expect(application.objMembershipAccess.context(variables.user.userID, variables.b, false).role).toBe("organization.member");
                expect(application.objAuthorization.canInOrganization(variables.user.userID, variables.b, "organization.members.manage")).toBeFalse();
            });
            it("keeps a support session within the organization selected by the platform administrator", () => {
                loginAs(variables.user);
                session.supportLogin = true;
                session.supportOrganizationID = variables.a;
                expect(application.objMembershipAccess.canAccessTenant(variables.user.userID, variables.a)).toBeTrue();
                expect(application.objMembershipAccess.canAccessTenant(variables.user.userID, variables.b)).toBeFalse();
                expect(application.objMembershipAccess.context(variables.user.userID, variables.b, false).allowed).toBeFalse();
            });
            it("preserves unactivated legacy access without activating that organization", () => {
                queryExecute(options = {datasource: application.datasource}, params = {id: {type: "integer", value: variables.a}},
                    sql = "DELETE FROM organization_access WHERE intOrganizationID = :id");
                expect(application.objMembershipAccess.organizationForCustomer(variables.a).enabled).toBeFalse();
                expect(application.objMembershipAccess.context(variables.user.userID, variables.a, false).allowed).toBeTrue();
                expect(application.objMembershipAccess.context(variables.user.userID, variables.b, false).allowed).toBeTrue();
            });
        });
    }
    private void function seed(required numeric userID, required numeric organizationID, required string role) {
        local.params = {userID: {type: "integer", value: arguments.userID}, organizationID: {type: "integer", value: arguments.organizationID}, role: {type: "varchar", value: arguments.role}};
        queryExecute(options = {datasource: application.datasource}, params = local.params,
            sql = "INSERT IGNORE INTO organization_access (intOrganizationID) VALUES (:organizationID)");
        queryExecute(options = {datasource: application.datasource}, params = local.params,
            sql = "INSERT IGNORE INTO membership_identities (intUserID) VALUES (:userID)");
        queryExecute(options = {datasource: application.datasource}, params = local.params,
            sql = "INSERT INTO organization_memberships (intUserID, intOrganizationID, strRoleKey) VALUES (:userID, :organizationID, :role)");
    }
}
