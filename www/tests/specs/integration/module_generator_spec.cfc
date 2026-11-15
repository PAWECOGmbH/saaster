component extends="tests.support.integration_spec" {
    function run() {
        describe("Module deletion scaffolding through Sysadmin", () => {
            beforeEach(() => {
                variables.customer = variables.fixtures.createCustomer();
                variables.admin = variables.fixtures.createUser(customerID=variables.customer, sysAdmin=true);
                variables.moduleID = variables.fixtures.createModule();
                variables.prefix = "testhook_" & left(replace(createUUID(),"-","","all"),11);
                variables.folder = expandPath("/backend/modules/" & variables.prefix);
                variables.auth = authenticate();
            });
            afterEach(() => {
                if (directoryExists(variables.folder)) directoryDelete(variables.folder,true);
            });
            it("creates a compilable unfinished hook and preserves implemented cleanup on subsequent saves", () => {
                local.response = saveModule(variables.prefix);
                expect(local.response.statusCode).toInclude("302",left(local.response.fileContent,400));
                expect(fileExists(variables.folder & "/navigation.cfm")).toBeTrue();
                expect(fileExists(variables.folder & "/login_include.cfm")).toBeTrue();
                expect(fileExists(variables.folder & "/deletion.cfc")).toBeTrue();
                expect(fileRead(variables.folder & "/deletion.cfc","utf-8")).toInclude("docs/module-account-deletion.md");
                variables.generated = createObject("component","backend.modules." & variables.prefix & ".deletion");
                expect(() => variables.generated.deleteCustomer(variables.customer)).toThrow("AccountDeletion.NotImplemented");
                local.custom = 'component output="false" { public struct function deleteCustomer(required numeric customerID) { return {success:true}; } }';
                fileWrite(variables.folder & "/deletion.cfc",local.custom,"utf-8");
                expect(saveModule(variables.prefix).statusCode).toInclude("302");
                expect(fileRead(variables.folder & "/deletion.cfc","utf-8")).toBe(local.custom);
            });
            it("adds the missing hook to an existing folder without replacing existing starter files", () => {
                directoryCreate(variables.folder);
                fileWrite(variables.folder & "/navigation.cfm","<!--- Custom navigation --->","utf-8");
                fileWrite(variables.folder & "/login_include.cfm","<!--- Custom login --->","utf-8");
                expect(saveModule(variables.prefix).statusCode).toInclude("302");
                expect(fileExists(variables.folder & "/deletion.cfc")).toBeTrue();
                expect(fileRead(variables.folder & "/navigation.cfm")).toBe("<!--- Custom navigation --->");
                expect(fileRead(variables.folder & "/login_include.cfm")).toBe("<!--- Custom login --->");
            });
            it("rejects a prefix that cannot identify a module component before creating files or updating the module", () => {
                expect(saveModule(variables.prefix & "/child").statusCode).toInclude("302");
                expect(directoryExists(variables.folder)).toBeFalse();
                local.module = queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:variables.moduleID}},
                    sql="SELECT strTabPrefix FROM modules WHERE intModuleID=:id");
                expect(local.module.strTabPrefix).notToBe(variables.prefix & "/child");
            });
        });
    }
    private struct function authenticate() {
        cfhttp(url="http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=sysadmin/invoices&userID=" & variables.admin.userID,
            result="local.response",redirect=false,timeout=40);
        expect(local.response.statusCode).toInclude("200",left(local.response.fileContent,400));
        local.cookies = local.response.responseHeader["Set-Cookie"] ?: [];
        if (!isArray(local.cookies)) local.cookies=[local.cookies];
        local.parts=[];
        loop array=local.cookies item="local.cookie" { arrayAppend(local.parts,listFirst(local.cookie,";")); }
        local.auth={cookies:arrayToList(local.parts,"; ")};
        loop list="csrf_token,context_token" item="local.key" {
            local.match=reFind('name="' & local.key & '" value="([^"]*)"',local.response.fileContent,1,true);
            expect(local.match.len[1]).toBeGT(0);
            local.auth[local.key]=mid(local.response.fileContent,local.match.pos[2],local.match.len[2]);
        }
        return local.auth;
    }
    private struct function saveModule(required string prefix) {
        cfhttp(url="http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=sysadm/modules",method="POST",
            result="local.response",redirect=false,timeout=40) {
            cfhttpparam(type="header",name="Cookie",value=variables.auth.cookies);
            cfhttpparam(type="formfield",name="csrf_token",value=variables.auth.csrf_token);
            cfhttpparam(type="formfield",name="context_token",value=variables.auth.context_token);
            cfhttpparam(type="formfield",name="edit_module",value=variables.moduleID);
            cfhttpparam(type="formfield",name="module_name",value="testbox: Generated module");
            cfhttpparam(type="formfield",name="prefix",value=arguments.prefix);
        }
        return local.response;
    }
}
