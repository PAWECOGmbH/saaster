component extends="tests.support.integration_spec" {

    function run() {
        describe("Read-only legacy membership migration preview", () => {
            beforeEach(() => {
                variables.organization = variables.fixtures.createCustomer();
                variables.tenant = variables.fixtures.createCustomer(parentID = variables.organization);
                variables.owner = variables.fixtures.createUser(customerID = variables.organization, superAdmin = true);
                variables.member = variables.fixtures.createUser(customerID = variables.tenant);
                variables.fixtures.grantTenant(variables.owner.userID, variables.tenant);
                variables.migration = application.objMembershipMigration;
            });

            it("suggests a sole eligible owner but never silently chooses one", () => {
                local.preview = variables.migration.preview(variables.organization);
                expect(local.preview.suggestedOwnerUserID).toBe(variables.owner.userID);
                expect(local.preview.ownerUserID).toBe(0);
                expect(local.preview.ready).toBeFalse();
                expect(issueCodes(local.preview)).toInclude("owner_selection_required");
            });

            it("prepares explicit ownership and tenant roles without changing any memberships", () => {
                local.before = executeSQL("SELECT * FROM users WHERE intUserID = :id", idParam(variables.owner.userID));
                local.preview = variables.migration.preview(variables.organization, variables.owner.userID);
                expect(local.preview.ready).toBeTrue();
                expect(local.preview.members).toHaveLength(2);
                expect(local.preview.assignments).toHaveLength(3);
                expect(proposedMember(local.preview, variables.owner.userID).role).toBe("organization.owner");
                expect(proposedMember(local.preview, variables.member.userID).role).toBe("organization.member");
                expect(proposedMember(local.preview, variables.member.userID).defaultCustomerID).toBe(variables.tenant);
                expect(local.preview.assignments.filter((item) => item.userID eq variables.member.userID)[1].role).toBe("tenant.editor");
                expect(executeSQL("SELECT * FROM organization_memberships WHERE intOrganizationID = :id", idParam(variables.organization)).recordCount).toBe(0);
                expect(serializeJSON(executeSQL("SELECT * FROM users WHERE intUserID = :id", idParam(variables.owner.userID)))).toBe(serializeJSON(local.before));
                expect(application.objGlobal.checkTenantRange(variables.owner.userID, variables.tenant)).toBeTrue();
            });

            it("keeps inactive users suspended and platform privileges separate", () => {
                executeSQL("UPDATE users SET blnActive = 0, blnSysAdmin = 1 WHERE intUserID = :id", idParam(variables.member.userID));
                local.preview = variables.migration.preview(variables.organization, variables.owner.userID);
                local.member = proposedMember(local.preview, variables.member.userID);
                expect(local.member.status).toBe("suspended");
                expect(local.member.platformAdmin).toBeTrue();
                expect(local.member.role).toBe("organization.member");
            });

            it("does not treat an arbitrary first user as an owner", () => {
                executeSQL("UPDATE users SET blnSuperAdmin = 0 WHERE intUserID = :id", idParam(variables.owner.userID));
                local.preview = variables.migration.preview(variables.organization, variables.owner.userID);
                expect(local.preview.ownerCandidates).toHaveLength(0);
                expect(local.preview.ready).toBeFalse();
                expect(issueCodes(local.preview)).toInclude("invalid_owner_selection");
            });

            it("reports ambiguous owners instead of choosing the lowest user ID", () => {
                local.second = variables.fixtures.createUser(customerID = variables.organization, superAdmin = true);
                variables.fixtures.grantTenant(local.second.userID, variables.tenant);
                local.preview = variables.migration.preview(variables.organization);
                expect(local.preview.ownerCandidates).toHaveLength(2);
                expect(local.preview.suggestedOwnerUserID).toBe(0);
                expect(local.preview.ready).toBeFalse();
            });

            it("only proposes organization admin for a superadmin already assigned to the whole family", () => {
                local.fullAdmin = variables.fixtures.createUser(customerID = variables.organization, superAdmin = true);
                variables.fixtures.grantTenant(local.fullAdmin.userID, variables.tenant);
                local.scopedAdmin = variables.fixtures.createUser(customerID = variables.tenant, superAdmin = true);
                local.preview = variables.migration.preview(variables.organization, variables.owner.userID);
                expect(proposedMember(local.preview, local.fullAdmin.userID).role).toBe("organization.admin");
                expect(proposedMember(local.preview, local.scopedAdmin.userID).role).toBe("organization.member");
                expect(issueCodes(local.preview)).toInclude("scoped_superadmin");
                expect(local.preview.ready).toBeFalse();
            });

            it("requires review when ownership would add access to an unassigned tenant", () => {
                variables.fixtures.createCustomer(parentID = variables.organization);
                local.preview = variables.migration.preview(variables.organization, variables.owner.userID);
                expect(issueCodes(local.preview)).toInclude("owner_access_expansion");
                expect(local.preview.ready).toBeFalse();
            });

            it("rejects owners from another family, inactive owners and tenant contexts", () => {
                local.other = variables.fixtures.createCustomer();
                local.stranger = variables.fixtures.createUser(customerID = local.other, superAdmin = true);
                expect(issueCodes(variables.migration.preview(variables.organization, local.stranger.userID))).toInclude("invalid_owner_selection");
                executeSQL("UPDATE users SET blnActive = 0 WHERE intUserID = :id", idParam(variables.owner.userID));
                expect(issueCodes(variables.migration.preview(variables.organization, variables.owner.userID))).toInclude("invalid_owner_selection");
                expect(issueCodes(variables.migration.preview(variables.tenant))).toInclude("invalid_organization");
            });

            it("reports duplicate assignments without importing duplicate suggestions", () => {
                variables.fixtures.grantTenant(variables.member.userID, variables.tenant);
                local.preview = variables.migration.preview(variables.organization, variables.owner.userID);
                expect(issueCodes(local.preview)).toInclude("duplicate_assignment");
                expect(local.preview.assignments.filter((item) => item.userID eq variables.member.userID)).toHaveLength(1);
                expect(local.preview.ready).toBeFalse();
            });

            it("reports missing and multiple default tenants", () => {
                executeSQL("UPDATE customer_user SET blnStandard = 0 WHERE intUserID = :id", idParam(variables.member.userID));
                expect(issueCodes(variables.migration.preview(variables.organization))).toInclude("invalid_default_count");
                executeSQL("UPDATE customer_user SET blnStandard = 1 WHERE intUserID = :id", idParam(variables.owner.userID));
                local.audit = variables.migration.audit(variables.organization);
                expect(local.audit.filter((item) => item.issueCode eq "invalid_default_count").recordCount).toBe(2);
            });

            it("reports inbound and outbound assignments across organization boundaries", () => {
                local.other = variables.fixtures.createCustomer();
                local.stranger = variables.fixtures.createUser(customerID = local.other);
                variables.fixtures.grantTenant(variables.member.userID, local.other);
                variables.fixtures.grantTenant(local.stranger.userID, variables.tenant);
                local.audit = variables.migration.audit(variables.organization);
                expect(local.audit.filter((item) => item.issueCode eq "cross_organization_assignment").recordCount).toBe(2);
                local.preview = variables.migration.preview(variables.organization, variables.owner.userID);
                expect(local.preview.members).toHaveLength(2);
                expect(local.preview.assignments).toHaveLength(3);
                expect(local.preview.ready).toBeFalse();
            });

            it("reports grandchildren and broken parent references", () => {
                variables.fixtures.createCustomer(parentID = variables.tenant);
                expect(issueCodes(variables.migration.preview(variables.organization))).toInclude("invalid_parent");
                local.orphanParent = variables.fixtures.createCustomer();
                local.orphan = variables.fixtures.createCustomer(parentID = local.orphanParent);
                executeSQL("DELETE FROM customers WHERE intCustomerID = :id", idParam(local.orphanParent));
                local.audit = variables.migration.audit();
                expect(local.audit.filter((item) => item.issueCode eq "invalid_parent").recordCount).toBeGTE(2);
            });

            it("reports incomplete legacy assignments", () => {
                executeSQL("INSERT INTO customer_user (intCustomerID, intUserID) VALUES (:id, NULL)", idParam(variables.organization));
                executeSQL("INSERT INTO customer_user (intCustomerID, intUserID) VALUES (NULL, :id)", idParam(variables.member.userID));
                expect(issueCodes(variables.migration.preview(variables.organization))).toInclude("incomplete_assignment");
                expect(variables.migration.audit(variables.organization).filter((item) => item.issueCode eq "incomplete_assignment").recordCount).toBe(2);
            });

            it("flags an active user's inactive default tenant for review", () => {
                executeSQL("UPDATE customers SET blnActive = 0 WHERE intCustomerID = :id", idParam(variables.tenant));
                local.preview = variables.migration.preview(variables.organization, variables.owner.userID);
                expect(issueCodes(local.preview)).toInclude("inactive_default_tenant");
                expect(local.preview.ready).toBeFalse();
            });

            it("preserves a disabled organization as a valid state during migration", () => {
                executeSQL("UPDATE customers SET blnActive = 0 WHERE intCustomerID = :id", idParam(variables.organization));
                local.preview = variables.migration.preview(variables.organization, variables.owner.userID);
                expect(local.preview.ready).toBeTrue();
                expect(local.preview.organizationActive).toBeFalse();
                expect(executeSQL("SELECT blnActive FROM customers WHERE intCustomerID = :id", idParam(variables.organization)).blnActive).toBe(0);
            });
        });
    }

    private struct function idParam(required numeric id) {
        return {id: {type: "integer", value: arguments.id}};
    }

    private any function executeSQL(required string sql, struct params = {}) {
        return queryExecute(options = {datasource: application.datasource}, params = arguments.params, sql = arguments.sql);
    }

    private string function issueCodes(required struct preview) {
        return arrayToList(arguments.preview.issues.map((issue) => issue.issueCode));
    }

    private struct function proposedMember(required struct preview, required numeric userID) {
        loop array=arguments.preview.members item="local.member" {
            if (local.member.userID eq arguments.userID) {
                return local.member;
            }
        }
        return {};
    }

}
