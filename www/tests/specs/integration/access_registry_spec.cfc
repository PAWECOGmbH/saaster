component extends="tests.support.integration_spec" {
    function run() {
        describe("Extension permission manifests", () => {
            beforeEach(() => {
                variables.previousRegistry = application.objAccessRegistry;
                variables.organization = variables.fixtures.createCustomer();
                variables.user = variables.fixtures.createUser(customerID = variables.organization);
                queryExecute(options = {datasource: application.datasource}, params = {
                    userID: {type: "integer", value: variables.user.userID}, organizationID: {type: "integer", value: variables.organization}
                }, sql = "INSERT INTO organization_memberships (intUserID, intOrganizationID) VALUES (:userID, :organizationID)");
                queryExecute(options = {datasource: application.datasource}, params = {
                    userID: {type: "integer", value: variables.user.userID}, organizationID: {type: "integer", value: variables.organization}
                }, sql = "INSERT INTO tenant_memberships (intOrgMembershipID, intCustomerID, strRoleKey)
                    SELECT intOrgMembershipID, :organizationID, 'tenant.viewer' FROM organization_memberships WHERE intUserID = :userID");
                queryExecute(options = {datasource: application.datasource}, params = {
                    id: {type: "integer", value: variables.organization}
                }, sql = "INSERT INTO organization_access (intOrganizationID) VALUES (:id)");
                variables.manifest = {
                    namespace: "example", basePath: "backend/myapp/", permissions: [
                        {key: "example.read", scope: "tenant", label: "txtExampleRead", roles: ["tenant.viewer", "tenant.editor"]},
                        {key: "example.edit", scope: "tenant", label: "txtExampleEdit", roles: ["tenant.editor"]}
                    ], routes: [
                        {path: "views/example.cfm", methods: ["GET"], permissions: ["example.read"]},
                        {path: "handler/example.cfm", methods: ["POST"], permissions: ["example.edit"]}
                    ]
                };
                application.objAccessRegistry = new backend.core.com.access_registry([variables.manifest]);
            });
            afterEach(() => { application.objAccessRegistry = variables.previousRegistry; });

            it("allows an explicitly registered read page but not mutations or other HTTP methods", () => {
                expect(allowed("views/example.cfm", "GET")).toBeTrue();
                expect(allowed("views/example.cfm", "POST")).toBeFalse();
                expect(allowed("handler/example.cfm", "POST")).toBeFalse();
                expect(allowed("handler/example.cfm", "GET")).toBeFalse();
                expect(allowed("views/unregistered.cfm", "GET")).toBeFalse();
                expect(application.objAuthorization.canInTenant(variables.user.userID, variables.organization, "example.unknown")).toBeFalse();
            });
            it("requires explicit grants even for organization owners", () => {
                queryExecute(options = {datasource: application.datasource}, params = {
                    id: {type: "integer", value: variables.user.userID}
                }, sql = "UPDATE organization_memberships SET strRoleKey = 'organization.owner' WHERE intUserID = :id");
                expect(application.objAuthorization.canInTenant(variables.user.userID, variables.organization, "example.edit")).toBeFalse();
            });
            it("rechecks suspension and never grants access to another organization", () => {
                local.other = variables.fixtures.createCustomer();
                expect(application.objAuthorization.canInTenant(variables.user.userID, local.other, "example.read")).toBeFalse();
                queryExecute(options = {datasource: application.datasource}, params = {
                    id: {type: "integer", value: variables.user.userID}
                }, sql = "UPDATE organization_memberships SET strStatus = 'suspended' WHERE intUserID = :id");
                expect(allowed("views/example.cfm", "GET")).toBeFalse();
            });
            it("rejects unknown route permissions, wildcards, traversal and duplicate declarations", () => {
                variables.invalidManifest = duplicate(variables.manifest);
                variables.invalidManifest.routes[1].permissions = ["example.unknown"];
                expect(() => new backend.core.com.access_registry([variables.invalidManifest])).toThrow("Saaster.Access.InvalidManifest");
                variables.invalidManifest = duplicate(variables.manifest);
                variables.invalidManifest.permissions[1].roles = ["*"];
                expect(() => new backend.core.com.access_registry([variables.invalidManifest])).toThrow("Saaster.Access.InvalidManifest");
                variables.invalidManifest = duplicate(variables.manifest);
                variables.invalidManifest.routes[1].path = "../core/handler/user.cfm";
                expect(() => new backend.core.com.access_registry([variables.invalidManifest])).toThrow("Saaster.Access.InvalidManifest");
                expect(() => new backend.core.com.access_registry([variables.manifest, variables.manifest])).toThrow("Saaster.Access.InvalidManifest");
            });
            it("exposes translation keys without permitting callers to change registered grants", () => {
                local.definition = application.objAccessRegistry.permission("example.read");
                expect(local.definition.label).toBe("txtExampleRead");
                arrayAppend(local.definition.roles, "organization.owner");
                expect(arrayLen(application.objAccessRegistry.permission("example.read").roles)).toBe(2);
            });
        });
    }
    private boolean function allowed(required string path, required string method) {
        return application.objMembershipAccess.allowRequest(variables.user.userID, variables.organization, "backend/myapp/" & arguments.path, arguments.method);
    }
}
