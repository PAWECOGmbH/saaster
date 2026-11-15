component extends="tests.support.integration_spec" {
    function run() {
        describe("Module block management over HTTP", () => {
            beforeEach(() => {
                variables.customer = variables.fixtures.createCustomer(companyName="Customer <script>unsafe</script>");
                variables.admin = variables.fixtures.createUser(customerID=variables.customer, sysAdmin=true);
                variables.reader = variables.fixtures.createUser(customerID=variables.customer);
                variables.module = variables.fixtures.createModule(name="Module <script>unsafe</script>");
                queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:variables.module}},
                    sql="INSERT INTO modules_prices (intModuleID, intCurrencyID) SELECT :id, intCurrencyID FROM currencies WHERE blnActive = 1");
                variables.plan = variables.fixtures.createPlan([variables.module]);
                variables.fixtures.createBooking(customerID=variables.customer,planID=variables.plan,status="free");
            });

            it("keeps Sysadmin module actions English in a German session and confirms block/unblock", () => {
                local.page = renderTab(variables.admin.userID);
                expect(local.page.statusCode).toInclude("200");
                expect(local.page.fileContent).toInclude('name="module_access_action" value="block"');
                expect(arrayLen(reMatch('data-bs-target="##module-access-' & variables.module & '"',local.page.fileContent))).toBe(1);
                expect(local.page.fileContent).toInclude("Billing and the subscription period continue");
                expect(local.page.fileContent).toInclude("Block module");
                expect(local.page.fileContent).toInclude('aria-label="Close"');
                expect(local.page.fileContent).notToInclude("Modul sperren");
                expect(local.page.fileContent).toInclude("Customer &lt;script&gt;unsafe&lt;/script&gt;");
                expect(local.page.fileContent).notToInclude("##csrfField");
                expect(local.page.fileContent).notToInclude("##application.mainURL");
                local.auth = sessionFields(local.page);
                local.response = submit(local.auth,"block");
                expect(local.response.statusCode).toInclude("302");
                expect(local.response.responseHeader.Location).toInclude("?del_redirect##modules");
                expect(application.objModuleBlocks.isBlocked(variables.customer,variables.module)).toBeTrue();
                local.page = renderTab(variables.admin.userID);
                expect(local.page.fileContent).toInclude("Access blocked");
                expect(local.page.fileContent).toInclude("Unblock module");
                expect(local.page.fileContent).notToInclude("Zugriff gesperrt");
                expect(local.page.fileContent).notToInclude("Modul freigeben");
                expect(local.page.fileContent).toInclude('name="module_access_action" value="unblock"');
                local.response = submit(sessionFields(local.page),"unblock");
                expect(local.response.statusCode).toInclude("302");
                expect(application.objModuleBlocks.isBlocked(variables.customer,variables.module)).toBeFalse();
                local.booking = queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:variables.customer}},sql="SELECT strStatus FROM bookings WHERE intCustomerID = :id");
                expect(local.booking.strStatus).toBe("free");
            });

            it("renders one action for a directly booked module too", () => {
                queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:variables.plan}},
                    sql="DELETE FROM plans_modules WHERE intPlanID = :id");
                variables.fixtures.createBooking(customerID=variables.customer,moduleID=variables.module,status="free");
                local.page = renderTab(variables.admin.userID);
                expect(local.page.statusCode).toInclude("200");
                expect(arrayLen(reMatch('data-bs-target="##module-access-' & variables.module & '"',local.page.fileContent))).toBe(1);
            });

            it("warns about permanent module data deletion when the project hook enables it", () => {
                queryExecute(
                    options={datasource:application.datasource},
                    params={id:{type:"integer",value:variables.plan}},
                    sql="DELETE FROM plans_modules WHERE intPlanID = :id"
                );
                variables.fixtures.createBooking(customerID=variables.customer,moduleID=variables.module,status="free");
                local.hadHook = structKeyExists(application, "objSubscriptionHooks");
                local.oldHook = local.hadHook ? application.objSubscriptionHooks : "";
                local.hook = new tests.support.subscription_hook_recorder();
                local.hook.setWarnModule(variables.module);
                application.objSubscriptionHooks = local.hook;

                try {
                    local.page = renderTab(variables.admin.userID);
                    expect(local.page.statusCode).toInclude("200");
                    expect(local.page.fileContent).toInclude("All customer data stored by this module will be permanently deleted.");
                    expect(local.page.fileContent).toInclude("OK, withdraw!");
                } finally {
                    if (local.hadHook) {
                        application.objSubscriptionHooks = local.oldHook;
                    } else {
                        structDelete(application, "objSubscriptionHooks");
                    }
                }
            });

            it("rejects missing CSRF tokens, invalid actions and users without platform rights", () => {
                local.auth = sessionFields(renderTab(variables.admin.userID));
                local.valid = local.auth.csrf_token;
                local.auth.csrf_token = "invalid";
                expect(submit(local.auth,"block").statusCode).toInclude("403");
                expect(application.objModuleBlocks.isBlocked(variables.customer,variables.module)).toBeFalse();
                local.auth.csrf_token = local.valid;
                expect(submit(local.auth,"invalid").statusCode).toInclude("400");
                local.denied = renderTab(variables.reader.userID);
                expect(local.denied.statusCode).toInclude("403");
                local.auth.cookies = cookies(local.denied);
                local.response = submit(local.auth,"block");
                expect(local.response.statusCode).notToInclude("200");
                expect(application.objModuleBlocks.isBlocked(variables.customer,variables.module)).toBeFalse();
            });
        });
    }

    private struct function renderTab(required numeric userID) {
        cfhttp(url="http://127.0.0.1/tests/support/customer_tab_probe.cfm?tab=modules&customerID=" & variables.customer & "&language=de&userID=" & arguments.userID,
            method="get",redirect=false,timeout=30,result="local.response");
        return local.response;
    }

    private string function cookies(required struct response) {
        local.headers = arguments.response.responseHeader["Set-Cookie"] ?: [];
        if (not isArray(local.headers)) { local.headers = [local.headers]; }
        local.cookies = [];
        loop array=local.headers item="local.cookie" { arrayAppend(local.cookies,listFirst(local.cookie,";")); }
        return arrayToList(local.cookies,"; ");
    }

    private struct function sessionFields(required struct response) {
        local.fields = {cookies:cookies(arguments.response)};
        loop array=["csrf_token","context_token"] item="local.name" {
            local.match = reFind('name="' & local.name & '" value="([^"]*)"',arguments.response.fileContent,1,true);
            local.fields[local.name] = mid(arguments.response.fileContent,local.match.pos[2],local.match.len[2]);
        }
        return local.fields;
    }

    private struct function submit(required struct auth, required string action) {
        cfhttp(url="http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=sysadm/modules",method="post",redirect=false,timeout=30,result="local.response") {
            cfhttpparam(type="header",name="Cookie",value=arguments.auth.cookies);
            cfhttpparam(type="header",name="X-Requested-With",value="XMLHttpRequest");
            cfhttpparam(type="formfield",name="csrf_token",value=arguments.auth.csrf_token);
            cfhttpparam(type="formfield",name="context_token",value=arguments.auth.context_token);
            cfhttpparam(type="formfield",name="module_access_action",value=arguments.action);
            cfhttpparam(type="formfield",name="customer_id",value=variables.customer);
            cfhttpparam(type="formfield",name="module_id",value=variables.module);
        }
        return local.response;
    }
}
