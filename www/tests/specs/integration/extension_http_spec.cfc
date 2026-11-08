component extends="tests.support.integration_spec" {
    function run() {
        describe("Direct extension HTTP authorization", () => {
            beforeEach(() => {
                variables.originalRegistry = application.objAccessRegistry;
                variables.path = expandPath("/backend/myapp/__saaster_access_test.cfm");
                if (fileExists(variables.path)) { throw(message="The isolated extension fixture path already exists."); }
                fileWrite(variables.path, '<cfoutput>extension request reached ##application.objGlobal.csrfField()##</cfoutput>', "utf-8");
                variables.organization = variables.fixtures.createCustomer();
                variables.owner = variables.fixtures.createUser(customerID=variables.organization, superAdmin=true);
                variables.reader = variables.fixtures.createUser(customerID=variables.organization);
                application.objMembershipMigration.activate(variables.owner.userID, variables.organization, variables.owner.userID, true);
                application.objMembership.setTenantMember(variables.owner.userID, variables.organization, variables.reader.userID, "tenant.viewer");
                queryExecute(options={datasource:application.datasource}, sql="INSERT INTO custom_mappings (strMapping, strPath, blnOnlyAdmin)
                    VALUES ('saaster-extension-test', 'backend/myapp/__saaster_access_test.cfm', 1)");
                application.objAccessRegistry = new backend.core.com.access_registry([{
                    namespace:"httptest", basePath:"backend/myapp/", permissions:[
                        {key:"httptest.read", scope:"tenant", label:"titUser", roles:["tenant.viewer", "tenant.editor"]},
                        {key:"httptest.edit", scope:"tenant", label:"titUser", roles:["tenant.editor"]}
                    ], routes:[
                        {path:"__saaster_access_test.cfm", methods:["GET"], permissions:["httptest.read"]},
                        {path:"__saaster_access_test.cfm", methods:["POST"], permissions:["httptest.edit"]}
                    ]
                }]);
            });
            afterEach(() => {
                application.objAccessRegistry = variables.originalRegistry;
                if (fileExists(variables.path)) { fileDelete(variables.path); }
                queryExecute(options={datasource:application.datasource}, sql="DELETE FROM custom_mappings WHERE strMapping = 'saaster-extension-test'");
            });
            it("checks the real template path, permissions, methods and CSRF even without path-info", () => {
                local.url = "http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=dashboard&direct=1";
                cfhttp(url=local.url & "&userID=" & variables.reader.userID, method="get", redirect=false, timeout=30, result="local.read");
                expect(local.read.statusCode).toInclude("200");
                expect(local.read.fileContent).toInclude("extension request reached");
                local.cookieHeaders = local.read.responseHeader["Set-Cookie"] ?: [];
                if (not isArray(local.cookieHeaders)) { local.cookieHeaders = [local.cookieHeaders]; }
                local.cookies = [];
                loop array=local.cookieHeaders item="local.cookie" { arrayAppend(local.cookies, listFirst(local.cookie, ";")); }
                local.csrf = reFind('name="csrf_token" value="([^"]+)"', local.read.fileContent, 1, true);
                local.context = reFind('name="context_token" value="([^"]+)"', local.read.fileContent, 1, true);
                local.fields = {
                    csrf_token: mid(local.read.fileContent, local.csrf.pos[2], local.csrf.len[2]),
                    context_token: mid(local.read.fileContent, local.context.pos[2], local.context.len[2])
                };
                cfhttp(url=local.url, method="post", redirect=false, timeout=30, result="local.denied") {
                    cfhttpparam(type="header", name="Cookie", value=arrayToList(local.cookies, "; "));
                    loop collection=local.fields key="local.key" { cfhttpparam(type="formfield", name=local.key, value=local.fields[local.key]); }
                }
                expect(local.denied.statusCode).toInclude("403");
                expect(local.denied.fileContent).notToInclude("extension request reached");
                application.objMembership.setTenantMember(variables.owner.userID, variables.organization, variables.reader.userID, "tenant.editor");
                cfhttp(url=local.url, method="post", redirect=false, timeout=30, result="local.allowed") {
                    cfhttpparam(type="header", name="Cookie", value=arrayToList(local.cookies, "; "));
                    loop collection=local.fields key="local.key" { cfhttpparam(type="formfield", name=local.key, value=local.fields[local.key]); }
                }
                expect(local.allowed.statusCode).toInclude("200");
                expect(local.allowed.fileContent).toInclude("extension request reached");
                cfhttp(url=local.url, method="delete", redirect=false, timeout=30, result="local.unknownMethod") {
                    cfhttpparam(type="header", name="Cookie", value=arrayToList(local.cookies, "; "));
                }
                expect(local.unknownMethod.statusCode).toInclude("403");
            });
        });
    }
}
