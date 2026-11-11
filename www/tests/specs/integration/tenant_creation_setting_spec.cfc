component extends="tests.support.integration_spec" {
    function run() {
        describe("Global tenant creation setting", () => {
            beforeEach(() => {
                logout();
                variables.customerID = variables.fixtures.createCustomer();
                variables.owner = variables.fixtures.createUser(customerID=variables.customerID, superAdmin=true);
                loginAs(variables.owner);
                variables.previousSetting = application.systemSettingStruct.settingTenantsEnabled;
                variables.previousIP = session.usersIP ?: "";
                session.usersIP = "";
            });
            afterEach(() => {
                application.systemSettingStruct.settingTenantsEnabled = variables.previousSetting;
                session.usersIP = variables.previousIP;
                if (structKeyExists(variables, "createdTenantID")) {
                    application.objCustomer.deleteAccount(variables.createdTenantID);
                    structDelete(variables, "createdTenantID");
                }
            });
            it("renders the global setting and hides creation controls when disabled", () => {
                variables.sysadmin = variables.fixtures.createUser(
                    customerID=variables.fixtures.createCustomer(), sysAdmin=true, superAdmin=true
                );
                local.settings = renderPage("sysadmin/system-settings", variables.sysadmin.userID);
                expect(local.settings.statusCode).toInclude("200", left(local.settings.fileContent, 500));
                expect(local.settings.fileContent).toInclude('name="settingTenantsEnabled"');
                local.enabledPage = renderPage("account-settings/tenants", variables.owner.userID);
                expect(local.enabledPage.statusCode).toInclude("200", left(local.enabledPage.fileContent, 500));
                expect(local.enabledPage.fileContent).toInclude("/account-settings/tenant/new");

                application.systemSettingStruct.settingTenantsEnabled = "0";
                local.settings = renderPage("sysadmin/system-settings", variables.sysadmin.userID);
                expect(local.settings.fileContent).toInclude('value="0" selected');
                local.account = renderPage("account-settings", variables.owner.userID);
                expect(local.account.statusCode).toInclude("200", left(local.account.fileContent, 500));
                expect(local.account.fileContent).notToInclude("/account-settings/tenants");
                local.tenants = renderPage("account-settings/tenants", variables.owner.userID);
                expect(local.tenants.statusCode).toInclude("200", left(local.tenants.fileContent, 500));
                expect(local.tenants.fileContent).notToInclude("/account-settings/tenant/new");
                local.newTenant = renderPage("account-settings/tenant/new", variables.owner.userID);
                expect(local.newTenant.statusCode).toInclude("302");
                expect(local.newTenant.responseHeader.Location).toInclude("/account-settings/tenants");

                variables.fixtures.createCustomer(parentID=variables.customerID);
                local.account = renderPage("account-settings", variables.owner.userID);
                expect(local.account.fileContent).toInclude("/account-settings/tenants");
            });
            it("blocks new tenants when disabled while keeping existing tenants accessible", () => {
                local.existingID = variables.fixtures.createCustomer(parentID=variables.customerID);
                application.systemSettingStruct.settingTenantsEnabled = "0";
                expect(application.objCustomer.tenantCreationEnabled()).toBeFalse();
                expect(application.objCustomer.hasChildTenants(variables.customerID)).toBeTrue();
                expect(application.objCustomer.getManagedTenants(variables.owner.userID, variables.customerID).recordCount).toBe(2);
                local.result = application.objCustomer.insertTenant({
                    customerID:variables.customerID, userID:variables.owner.userID,
                    company_name:"Disabled tenant", contact_person:"Test Contact"
                });
                expect(local.result.success).toBeFalse();
                expect(queryExecute(
                    options = {datasource:application.datasource},
                    params = {parentID:{type:"integer",value:variables.customerID}},
                    sql = "SELECT intCustomerID FROM customers WHERE intCustParentID = :parentID"
                ).recordCount).toBe(1);

                application.systemSettingStruct.settingTenantsEnabled = "1";
                local.result = application.objCustomer.insertTenant({
                    customerID:variables.customerID, userID:variables.owner.userID,
                    company_name:"Enabled tenant", contact_person:"Test Contact"
                });
                expect(local.result.success).toBeTrue(local.result.message);
                local.children = queryExecute(
                    options = {datasource:application.datasource},
                    params = {parentID:{type:"integer",value:variables.customerID}, name:{type:"string",value:"Enabled tenant"}},
                    sql = "SELECT intCustomerID FROM customers WHERE intCustParentID = :parentID AND strCompanyName = :name"
                );
                expect(local.children.recordCount).toBe(1);
                if (local.children.recordCount) variables.createdTenantID = local.children.intCustomerID;
            });
        });
    }
    private struct function renderPage(required string route, required numeric userID) {
        cfhttp(
            url = "http://127.0.0.1/tests/support/organization_flow_probe.cfm?route="
                & urlEncodedFormat(arguments.route) & "&language=en&userID=" & arguments.userID,
            result = "local.response", redirect = false, timeout = 40
        );
        return local.response;
    }
}
