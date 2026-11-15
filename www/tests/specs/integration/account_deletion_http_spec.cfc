component extends="tests.support.integration_spec" {
    function run() {
        describe("Manual account deletion UI and handlers", () => {
            beforeEach(() => {
                logout(); recordLogs();
                variables.customer = variables.fixtures.createCustomer(companyName="Deletion <script>test</script>");
                variables.password = "Delete-this-test-account-123!";
                variables.owner = variables.fixtures.createUser(customerID=variables.customer, superAdmin=true,
                    passwordHash=application.objGlobal.hashPassword(variables.password));
                variables.admin = variables.fixtures.createUser(customerID=variables.fixtures.createCustomer(), sysAdmin=true, superAdmin=true,
                    passwordHash=application.objGlobal.hashPassword(variables.password));
                variables.lifecycle = new backend.core.com.account_lifecycle();
            });
            afterEach(() => {
                new backend.core.com.loginthrottle().reset(variables.owner.email);
            });
            it("renders the customer warning without the invoice-retention notice and verifies the current password", () => {
                local.page = renderPage("account-settings/company", variables.owner.userID);
                expect(local.page.statusCode).toInclude("200", left(local.page.fileContent,500));
                local.modal = modal(local.page.fileContent, "delete_account");
                expect(local.modal).toInclude("eigenen Passwort");
                expect(local.modal).toInclude("Deletion &lt;script&gt;test&lt;/script&gt;");
                expect(local.modal).notToInclude("Rechnungen");
                expect(local.modal).notToInclude("invoice");
                expect(local.modal).notToInclude("##deletion");
                local.auth = fields(local.page);
                expect(submit(local.auth, "cancel", "delete", variables.customer, "wrong").statusCode).toInclude("302");
                expect(variables.lifecycle.isDeleting(variables.customer)).toBeFalse();
                local.auth.csrf_token = "wrong";
                local.rejected = submit(local.auth, "cancel", "delete", variables.customer, variables.password);
                expect(local.rejected.statusCode).toInclude("302");
                expect(local.rejected.responseHeader.Location).toInclude("/dashboard");
                expect(variables.lifecycle.isDeleting(variables.customer)).toBeFalse();
            });
            it("deletes an activated organization's own account and ends its session", () => {
                application.objMembershipMigration.activate(variables.owner.userID, variables.customer, variables.owner.userID, true);
                local.auth = fields(renderPage("account-settings/company", variables.owner.userID));
                local.response = submit(local.auth, "cancel", "delete", variables.customer, variables.password);
                expect(local.response.statusCode).toInclude("302", left(local.response.fileContent,500));
                expect(local.response.responseHeader.Location).toInclude("/login");
                expect(customerExists()).toBeFalse();
                expect(variables.lifecycle.deletionState(variables.customer).status).toBe("completed");
            });
            it("shows the parent restriction and enforces it for submitted forms", () => {
                variables.fixtures.createCustomer(parentID=variables.customer, active=false);
                local.page = renderPage("account-settings/company", variables.owner.userID);
                local.modal = modal(local.page.fileContent, "delete_account");
                expect(local.modal).toInclude("Mandanten einzeln gelöscht");
                expect(local.modal).notToInclude('type="submit"');
                local.response = submit(fields(local.page), "cancel", "delete", variables.customer, variables.password);
                expect(local.response.statusCode).toInclude("302");
                expect(variables.lifecycle.isDeleting(variables.customer)).toBeFalse();
            });
            it("deletes an individual tenant without deleting or disabling its parent", () => {
                local.tenant = variables.fixtures.createCustomer(parentID=variables.customer);
                variables.fixtures.grantTenant(variables.owner.userID, local.tenant);
                local.page = renderPage("account-settings/tenants", variables.owner.userID);
                expect(local.page.statusCode).toInclude("200");
                expect(local.page.fileContent).toInclude('id="delete-tenant-' & local.tenant & '"');
                local.response = submit(fields(local.page), "cancel", "delete", local.tenant, variables.password);
                expect(local.response.responseHeader.Location).toInclude("/account-settings/tenants");
                expect(customerExists()).toBeTrue();
                expect(variables.lifecycle.isDeleting(variables.customer)).toBeFalse();
                expect(variables.lifecycle.deletionState(local.tenant).status).toBe("completed");
            });
            it("keeps inactive and pending tenants manageable in activated organizations", () => {
                local.tenant = variables.fixtures.createCustomer(parentID=variables.customer, active=false);
                application.objMembershipMigration.activate(variables.owner.userID, variables.customer, variables.owner.userID, true);
                local.work = variables.lifecycle.beginOperation(local.tenant, "job");
                local.page = renderPage("account-settings/tenants", variables.owner.userID);
                expect(local.page.statusCode).toInclude("200", left(local.page.fileContent,500));
                expect(local.page.fileContent).toInclude('id="delete-tenant-' & local.tenant & '"');
                submit(fields(local.page), "cancel", "delete", local.tenant, variables.password);
                expect(variables.lifecycle.deletionState(local.tenant).status).toBe("waiting");
                local.page = renderPage("account-settings/tenants", variables.owner.userID);
                expect(local.page.statusCode).toInclude("200", left(local.page.fileContent,500));
                expect(local.page.fileContent).toInclude("Löschung ausstehend");
                expect(local.page.fileContent).notToInclude("change_tenant=" & local.tenant);
                expect(modal(local.page.fileContent, "delete-tenant-" & local.tenant)).notToInclude("Rechnungen");
                variables.lifecycle.finishOperation(local.work);
                submit(fields(local.page), "cancel", "delete", local.tenant, variables.password);
                expect(variables.lifecycle.deletionState(local.tenant).status).toBe("completed");
            });
            it("logs out a customer when cleanup is pending and keeps its subscription stopped", () => {
                local.work = variables.lifecycle.beginOperation(variables.customer, "job");
                local.auth = fields(renderPage("account-settings/company", variables.owner.userID));
                local.response = submit(local.auth, "cancel", "delete", variables.customer, variables.password);
                expect(local.response.responseHeader.Location).toInclude("/login");
                expect(variables.lifecycle.deletionState(variables.customer).status).toBe("waiting");
                expect(customerExists()).toBeTrue();
                variables.lifecycle.finishOperation(local.work);
            });
            it("shows invoice retention only in the English Sysadmin dialog and retries pending work", () => {
                local.work = variables.lifecycle.beginOperation(variables.customer, "job");
                local.page = renderPage("sysadmin/customers/details/" & variables.customer, variables.admin.userID);
                expect(local.page.statusCode).toInclude("200", left(local.page.fileContent,500));
                local.modal = modal(local.page.fileContent, "delete-customer");
                expect(local.modal).toInclude("Issued invoices, their original PDFs and recorded payments are retained.");
                expect(local.modal).toInclude("Confirm with your own password");
                local.response = submit(fields(local.page), "sysadm/customers", "delete_account", variables.customer, variables.password);
                expect(local.response.statusCode).toInclude("302");
                expect(customerExists()).toBeTrue();
                expect(variables.lifecycle.deletionState(variables.customer).status).toBe("waiting");
                local.page = renderPage("sysadmin/customers/details/" & variables.customer, variables.admin.userID);
                expect(local.page.fileContent).toInclude("Account deletion pending");
                expect(local.page.fileContent).toInclude("Retry deletion");
                variables.lifecycle.finishOperation(local.work);
                local.response = submit(fields(local.page), "sysadm/customers", "delete_account", variables.customer, variables.password);
                expect(local.response.statusCode).toInclude("302");
                expect(customerExists()).toBeFalse();
            });
            it("shows failed tenant cleanup distinctly and resumes the existing request after the cause is fixed", () => {
                local.tenant = variables.fixtures.createCustomer(parentID=variables.customer);
                variables.fixtures.grantTenant(variables.owner.userID, local.tenant);
                local.module = variables.fixtures.createModule();
                local.params = {id:{type:"integer",value:local.module}};
                queryExecute(options={datasource:application.datasource}, params=local.params,
                    sql="UPDATE modules SET strSettingPath = 'backend/modules/missing_http_cleanup/settings' WHERE intModuleID = :id");
                // Reproduce the platform administrator deleting a tenant of their own account.
                queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:variables.owner.userID}},
                    sql="UPDATE users SET blnSysAdmin = 1 WHERE intUserID = :id");
                local.page = renderPage("account-settings/tenants", variables.owner.userID);
                submit(fields(local.page), "cancel", "delete", local.tenant, variables.password);
                expect(variables.lifecycle.deletionState(local.tenant).status).toBe("failed");
                local.page = renderPage("account-settings/tenants", variables.owner.userID);
                expect(local.page.fileContent).toInclude("Löschung fehlgeschlagen");
                expect(local.page.fileContent).notToInclude("Löschung ausstehend");
                expect(local.page.fileContent).toInclude("Löschung fortsetzen");
                expect(modal(local.page.fileContent, "delete-tenant-" & local.tenant)).toInclude("Bereinigung konnte nicht abgeschlossen werden");
                local.requested = queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:local.tenant}},
                    sql="SELECT dtmRequestedAt FROM account_deletions WHERE intCustomerID = :id").dtmRequestedAt;
                // Repair only the test-only module registration before retrying the rendered form.
                queryExecute(options={datasource:application.datasource}, params=local.params,
                    sql="UPDATE modules SET strSettingPath = '' WHERE intModuleID = :id");
                submit(fields(local.page), "cancel", "delete", local.tenant, variables.password);
                expect(variables.lifecycle.deletionState(local.tenant).status).toBe("completed");
                expect(queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:local.tenant}},
                    sql="SELECT dtmRequestedAt FROM account_deletions WHERE intCustomerID = :id").dtmRequestedAt).toBe(local.requested);
                expect(customerExists()).toBeTrue();
            });
            it("rejects unchecked confirmations and attempts against unrelated accounts", () => {
                local.auth = fields(renderPage("account-settings/company", variables.owner.userID));
                expect(submit(local.auth, "cancel", "delete", variables.customer, variables.password, "0").statusCode).toInclude("400");
                local.other = variables.fixtures.createCustomer();
                submit(local.auth, "cancel", "delete", local.other, variables.password);
                expect(variables.lifecycle.isDeleting(local.other)).toBeFalse();
                expect(variables.lifecycle.isDeleting(variables.customer)).toBeFalse();
            });
        });
    }
    private boolean function customerExists() {
        return queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:variables.customer}},
            sql="SELECT intCustomerID FROM customers WHERE intCustomerID = :id").recordCount gt 0;
    }
    private string function modal(required string html, required string id) {
        local.start = find('id="' & arguments.id & '"', arguments.html);
        expect(local.start).toBeGT(0);
        return mid(arguments.html, local.start, find('</form>',arguments.html,local.start)-local.start);
    }
    private struct function renderPage(required string route, required numeric userID) {
        cfhttp(url="http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=" & urlEncodedFormat(arguments.route) & "&language=de&userID=" & arguments.userID,
            result="local.response", redirect=false, timeout=40);
        return local.response;
    }
    private struct function fields(required struct response) {
        local.headers = arguments.response.responseHeader["Set-Cookie"] ?: [];
        if (!isArray(local.headers)) local.headers = [local.headers];
        local.cookies = [];
        loop array=local.headers item="local.cookie" { arrayAppend(local.cookies, listFirst(local.cookie,";")); }
        local.result = {cookies:arrayToList(local.cookies,"; ")};
        loop list="csrf_token,context_token" item="local.name" {
            local.match = reFind('name="' & local.name & '" value="([^"]*)"', arguments.response.fileContent, 1, true);
            expect(local.match.len[1]).toBeGT(0, left(arguments.response.fileContent,500));
            local.result[local.name] = mid(arguments.response.fileContent,local.match.pos[2],local.match.len[2]);
        }
        return local.result;
    }
    private struct function submit(required struct auth, required string route, required string trigger, required numeric target, required string password, string confirmed="1") {
        cfhttp(url="http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=" & arguments.route, method="post",redirect=false,timeout=40,result="local.response") {
            cfhttpparam(type="header",name="Cookie",value=arguments.auth.cookies);
            cfhttpparam(type="formfield",name="csrf_token",value=arguments.auth.csrf_token);
            cfhttpparam(type="formfield",name="context_token",value=arguments.auth.context_token);
            cfhttpparam(type="formfield",name=arguments.trigger,value=arguments.target);
            cfhttpparam(type="formfield",name="confirm_delete",value=arguments.confirmed);
            cfhttpparam(type="formfield",name="password",value=arguments.password);
        }
        return local.response;
    }
}
