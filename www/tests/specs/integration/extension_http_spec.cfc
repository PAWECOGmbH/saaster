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
            it("tracks admitted web work and releases it after rendering, redirect and failure", () => {
                fileWrite(variables.path, '<cfquery name="operations" datasource="##application.datasource##">SELECT COUNT(*) AS cnt FROM account_operations WHERE strKind = ''request'' AND intCustomerID = <cfqueryparam value="##session.customer_id##" cfsqltype="cf_sql_integer"></cfquery><cfoutput>active requests: ##operations.cnt##</cfoutput>', "utf-8");
                cfhttp(url="http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=saaster-extension-test&direct=1&userID=#variables.reader.userID#", result="local.response", redirect=false);
                expect(local.response.fileContent).toInclude("active requests: 1");
                expect(requestOperations()).toBe(0);
                fileWrite(variables.path, '<cflocation url="/tests/healthcheck.cfm" addtoken="false">', "utf-8");
                cfhttp(url="http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=saaster-extension-test&direct=1&userID=#variables.reader.userID#", result="local.response", redirect=false);
                expect(local.response.statusCode).toInclude("302");
                expect(requestOperations()).toBe(0);
                fileWrite(variables.path, '<cfthrow message="Expected lifecycle test error">', "utf-8");
                cfhttp(url="http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=saaster-extension-test&direct=1&userID=#variables.reader.userID#", result="local.response", redirect=false);
                expect(local.response.statusCode).toInclude("500");
                expect(requestOperations()).toBe(0);
            });
            it("checks permissions, methods and tokens for a plan-included module even without path-info", () => {
                bookIncludedModule();
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
                cfhttp(url=local.url, method="post", redirect=false, timeout=30, result="local.invalidCsrf") {
                    cfhttpparam(type="header", name="Cookie", value=arrayToList(local.cookies, "; "));
                    cfhttpparam(type="header", name="X-Requested-With", value="XMLHttpRequest");
                    cfhttpparam(type="formfield", name="csrf_token", value="invalid");
                    cfhttpparam(type="formfield", name="context_token", value=local.fields.context_token);
                }
                expect(local.invalidCsrf.statusCode).toInclude("403");
                expect(local.invalidCsrf.fileContent).toInclude("Invalid CSRF token");
                cfhttp(url=local.url, method="post", redirect=false, timeout=30, result="local.staleContext") {
                    cfhttpparam(type="header", name="Cookie", value=arrayToList(local.cookies, "; "));
                    cfhttpparam(type="formfield", name="csrf_token", value=local.fields.csrf_token);
                    cfhttpparam(type="formfield", name="context_token", value="invalid");
                }
                expect(local.staleContext.statusCode).toInclude("409");
                expect(local.staleContext.fileContent).notToInclude("extension request reached");
                cfhttp(url=local.url, method="delete", redirect=false, timeout=30, result="local.unknownMethod") {
                    cfhttpparam(type="header", name="Cookie", value=arrayToList(local.cookies, "; "));
                }
                expect(local.unknownMethod.statusCode).toInclude("403");
            });

            it("enforces product entitlement on canonical and direct extension requests", () => {
                local.module = variables.fixtures.createModule();
                queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:local.module}},
                    sql="UPDATE custom_mappings SET intModuleID = :id WHERE strMapping = 'saaster-extension-test'");
                loop array=[false, true] item="local.direct" {
                    local.response = fetchExtension(local.direct);
                    expect(local.response.statusCode).toInclude("302");
                    expect(local.response.responseHeader.Location).toInclude("/dashboard");
                    expect(local.response.fileContent).notToInclude("extension request reached");
                }
                variables.fixtures.createBooking(customerID=variables.organization, moduleID=local.module, status="canceled",
                    startDate=dateFormat(now(), "yyyy-mm-dd"), endDate=dateFormat(dateAdd("d", 1, now()), "yyyy-mm-dd"));
                loop array=[false, true] item="local.direct" {
                    local.response = fetchExtension(local.direct);
                    expect(local.response.statusCode).toInclude("200");
                    expect(local.response.fileContent).toInclude("extension request reached");
                }
            });

            it("blocks canonical and direct module access without changing role grants", () => {
                bookIncludedModule();
                local.mapping = queryExecute(options={datasource:application.datasource},sql="SELECT intModuleID FROM custom_mappings WHERE strMapping = 'saaster-extension-test'");
                local.admin = variables.fixtures.createUser(customerID=variables.organization,sysAdmin=true);
                loginAs(local.admin);
                application.objModuleBlocks.setBlocked(local.admin.userID,variables.organization,local.mapping.intModuleID,true);
                loop array=[false,true] item="local.direct" {
                    local.response = fetchExtension(local.direct);
                    expect(local.response.statusCode).toInclude("403");
                    expect(local.response.fileContent).notToInclude("extension request reached");
                }
                application.objModuleBlocks.setBlocked(local.admin.userID,variables.organization,local.mapping.intModuleID,false);
                expect(fetchExtension(true).statusCode).toInclude("200");
                expect(fetchExtension(false).statusCode).toInclude("200");
            });

            it("does not let an explicit extension grant bypass platform-only mapping flags", () => {
                bookIncludedModule();
                queryExecute(options={datasource:application.datasource},
                    sql="UPDATE custom_mappings SET blnOnlySysAdmin = 1 WHERE strMapping = 'saaster-extension-test'");
                loop array=[false, true] item="local.direct" {
                    local.response = fetchExtension(local.direct);
                    expect(local.response.statusCode).toInclude("302");
                    expect(local.response.fileContent).notToInclude("extension request reached");
                }
            });

            it("checks plan dates on canonical and direct routes and rechecks changes in an existing session", () => {
                local.booking = bookIncludedModule();
                loop array=[false, true] item="local.direct" {
                    local.response = fetchExtension(local.direct);
                    expect(local.response.statusCode).toInclude("200");
                    expect(local.response.fileContent).toInclude("extension request reached");
                    local.headers = local.response.responseHeader["Set-Cookie"] ?: [];
                    if (not isArray(local.headers)) { local.headers = [local.headers]; }
                    local.cookies = [];
                    loop array=local.headers item="local.cookie" { arrayAppend(local.cookies, listFirst(local.cookie, ";")); }
                    local.url = "http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=saaster-extension-test" & (local.direct ? "&direct=1" : "");
                    loop array=[{status:"waiting", start:1, end:2, code:"302"},
                        {status:"canceled", start:-1, end:0, code:"200"},
                        {status:"canceled", start:-2, end:-1, code:"302"}] item="local.state" {
                        queryExecute(options={datasource:application.datasource}, params={
                            id:{type:"integer",value:local.booking}, status:{type:"varchar",value:local.state.status},
                            start:{type:"date",value:dateAdd("d",local.state.start,now())}, end:{type:"date",value:dateAdd("d",local.state.end,now())}},
                            sql="UPDATE bookings SET strStatus = :status, dteStartDate = :start, dteEndDate = :end WHERE intBookingID = :id");
                        cfhttp(url=local.url, method="get", redirect=false, timeout=30, result="local.changed") {
                            cfhttpparam(type="header", name="Cookie", value=arrayToList(local.cookies, "; "));
                        }
                        expect(local.changed.statusCode).toInclude(local.state.code);
                        if (local.state.code eq "302") {
                            expect(local.changed.fileContent).notToInclude("extension request reached");
                        } else {
                            expect(local.changed.fileContent).toInclude("extension request reached");
                        }
                    }
                    queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:local.booking}},
                        sql="UPDATE bookings SET strStatus = 'free', dteStartDate = NULL, dteEndDate = NULL WHERE intBookingID = :id");
                }
            });

            it("refuses ambiguous, absent and unregistered direct mappings", () => {
                queryExecute(options={datasource:application.datasource}, sql="INSERT INTO custom_mappings (strMapping, strPath)
                    VALUES ('saaster-extension-test-alias', 'backend/myapp/__saaster_access_test.cfm')");
                try {
                    expect(fetchExtension(true).statusCode).toInclude("403");
                } finally {
                    queryExecute(options={datasource:application.datasource}, sql="DELETE FROM custom_mappings WHERE strMapping = 'saaster-extension-test-alias'");
                }
                application.objAccessRegistry = new backend.core.com.access_registry([]);
                expect(fetchExtension(true).statusCode).toInclude("403");
                queryExecute(options={datasource:application.datasource}, sql="DELETE FROM custom_mappings WHERE strMapping = 'saaster-extension-test'");
                application.objAccessRegistry = new backend.core.com.access_registry([{
                    namespace:"httptest", basePath:"backend/myapp/", permissions:[
                        {key:"httptest.read", scope:"tenant", label:"titUser", roles:["tenant.viewer"]}
                    ], routes:[{path:"__saaster_access_test.cfm", methods:["GET"], permissions:["httptest.read"]}]
                }]);
                expect(fetchExtension(true).statusCode).toInclude("403");
            });
        });
    }

    private struct function fetchExtension(boolean direct = false) {
        local.url = "http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=saaster-extension-test&userID=" & variables.reader.userID;
        if (arguments.direct) { local.url &= "&direct=1"; }
        cfhttp(url=local.url, method="get", redirect=false, timeout=30, result="local.response");
        return local.response;
    }

    private numeric function bookIncludedModule() {
        local.module = variables.fixtures.createModule();
        local.plan = variables.fixtures.createPlan([local.module]);
        queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:local.module}},
            sql="UPDATE custom_mappings SET intModuleID = :id WHERE strMapping = 'saaster-extension-test'");
        return variables.fixtures.createBooking(customerID=variables.organization, planID=local.plan, status="active",
            startDate=dateFormat(now(), "yyyy-mm-dd"), endDate=dateFormat(dateAdd("d", 1, now()), "yyyy-mm-dd"));
    }
    private numeric function requestOperations() {
        return queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:variables.organization}},
            sql="SELECT COUNT(*) AS cnt FROM account_operations WHERE intCustomerID = :id AND strKind = 'request'").cnt;
    }
}
