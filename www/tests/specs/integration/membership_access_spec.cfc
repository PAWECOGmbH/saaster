component extends="tests.support.integration_spec" {
    function run() {
        describe("Activated organization access", () => {
            beforeEach(() => {
                logout();
                variables.previousUsersIP = session.usersIP ?: "";
                session.usersIP = "";
                variables.organization = variables.fixtures.createCustomer();
                variables.tenant = variables.fixtures.createCustomer(parentID = variables.organization);
                variables.other = variables.fixtures.createCustomer();
                variables.owner = variables.fixtures.createUser(customerID = variables.organization, superAdmin = true);
                variables.member = variables.fixtures.createUser(customerID = variables.tenant, admin = true);
                variables.fixtures.grantTenant(variables.owner.userID, variables.tenant);
                variables.access = application.objMembershipAccess;
                variables.migration = application.objMembershipMigration;
            });
            afterEach(() => {
                logout();
                session.usersIP = variables.previousUsersIP;
            });

            it("activates atomically, rehomes identities and preserves the previous default", () => {
                activate();
                expect(variables.access.organizationForUser(variables.member.userID).enabled).toBeTrue();
                expect(sql("SELECT intCustomerID FROM users WHERE intUserID = :id", variables.member.userID).intCustomerID).toBe(variables.organization);
                expect(variables.access.context(variables.member.userID).customerID).toBe(variables.tenant);
                expect(variables.access.context(variables.owner.userID).role).toBe("organization.owner");
                expect(variables.access.tenants(variables.member.userID).recordCount).toBe(1);
                expect(application.objGlobal.checkTenantRange(variables.member.userID, variables.organization)).toBeFalse();
            });
            it("requires explicit review and an authorized legacy root administrator", () => {
                expect(() => variables.migration.activate(variables.owner.userID, variables.organization, variables.owner.userID, false)).toThrow(type="Saaster.Membership.ReviewRequired");
                expect(() => variables.migration.activate(variables.member.userID, variables.organization, variables.owner.userID, true)).toThrow(type="Saaster.Membership.Forbidden");
                expect(variables.access.organizationForCustomer(variables.organization).enabled).toBeFalse();
                expect(sql("SELECT * FROM organization_memberships WHERE intOrganizationID = :id", variables.organization).recordCount).toBe(0);
            });
            it("blocks structural errors without a partial import", () => {
                variables.fixtures.grantTenant(variables.member.userID, variables.other);
                expect(() => activate()).toThrow(type="Saaster.Membership.MigrationBlocked");
                expect(sql("SELECT * FROM organization_memberships WHERE intOrganizationID = :id", variables.organization).recordCount).toBe(0);
                expect(sql("SELECT intCustomerID FROM users WHERE intUserID = :id", variables.member.userID).intCustomerID).toBe(variables.tenant);
            });
            it("does not overwrite previously prepared memberships", () => {
                queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:variables.organization}, userID:{type:"integer",value:variables.owner.userID}},
                    sql="INSERT INTO organization_memberships (intOrganizationID, intUserID, strRoleKey) VALUES (:id, :userID, 'organization.owner')");
                expect(() => activate()).toThrow(type="Saaster.Membership.ExistingMemberships");
            });
            it("is idempotent and keeps subsequent role changes", () => {
                activate();
                application.objMembership.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.viewer");
                activate();
                expect(variables.access.context(variables.member.userID).admin).toBeFalse();
                expect(sql("SELECT * FROM organization_memberships WHERE intOrganizationID = :id", variables.organization).recordCount).toBe(2);
            });
            it("invalidates an existing session when its membership is removed, despite legacy admin flags", () => {
                activate(); loginAs(variables.member);
                expect(variables.access.refreshSession()).toBeTrue();
                application.objMembership.removeOrganizationMember(variables.owner.userID, variables.organization, variables.member.userID);
                expect(variables.access.refreshSession()).toBeFalse();
                expect(structKeyExists(session, "user_id")).toBeFalse();
                expect(variables.access.context(variables.member.userID).enabled).toBeTrue();
                expect(variables.access.context(variables.member.userID).allowed).toBeFalse();
                expect(application.objGlobal.checkTenantRange(variables.member.userID, variables.tenant)).toBeFalse();
            });
            it("updates role flags in an existing session immediately", () => {
                activate(); loginAs(variables.member); variables.access.refreshSession();
                expect(session.admin).toBeTrue();
                application.objMembership.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.viewer");
                expect(variables.access.refreshSession()).toBeTrue();
                expect(session.admin).toBeFalse(); expect(session.superadmin).toBeFalse();
            });
            it("does not silently move an in-flight request to another tenant", () => {
                activate(); loginAs(variables.owner); variables.access.refreshSession();
                application.objMembership.transferOwnership(variables.owner.userID, variables.organization, variables.member.userID);
                application.objMembership.setOrganizationMember(variables.member.userID, variables.organization, variables.owner.userID, "organization.member");
                application.objMembership.removeTenantMember(variables.member.userID, variables.organization, variables.owner.userID);
                expect(variables.access.refreshSession()).toBeFalse();
                expect(variables.access.context(variables.owner.userID).customerID).toBe(variables.tenant);
            });
            it("fails closed if an identity disappears after the session was established", () => {
                activate(); loginAs(variables.member); variables.access.refreshSession();
                sql("DELETE FROM users WHERE intUserID = :id", variables.member.userID);
                expect(variables.access.refreshSession()).toBeFalse();
                expect(structKeyExists(session,"user_id")).toBeFalse();
            });
            it("rejects inactive organizations and suspended tenant memberships", () => {
                activate();
                application.objMembership.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.viewer", "suspended");
                expect(variables.access.context(variables.member.userID).allowed).toBeFalse();
                sql("UPDATE customers SET blnActive = 0 WHERE intCustomerID = :id", variables.organization);
                expect(variables.access.context(variables.owner.userID).allowed).toBeFalse();
            });
            it("permits readers to view core pages and edit only their own profile", () => {
                activate();
                application.objMembership.setTenantMember(variables.owner.userID, variables.tenant, variables.member.userID, "tenant.viewer");
                expect(allowed("views/main.cfm")).toBeTrue();
                expect(allowed("handler/user.cfm", "POST", {userID:variables.member.userID})).toBeTrue();
                expect(allowed("handler/user.cfm", "POST", {userID:variables.owner.userID})).toBeFalse();
                expect(allowed("handler/user.cfm", "GET", {}, {delete:variables.owner.userID})).toBeFalse();
                expect(allowed("handler/customer.cfm", "POST", {edit_company_btn:1})).toBeFalse();
                expect(allowed("handler/book.cfm", "POST")).toBeFalse();
                expect(allowed("handler/sort.cfm", "POST")).toBeFalse();
                expect(allowed("views/customer/memberships.cfm")).toBeFalse();
                expect(allowed("handler/global.cfm", "GET", {}, {switch:variables.other})).toBeFalse();
            });
            it("lets tenant admins manage their tenant but not organization-wide members or tenants", () => {
                activate();
                expect(allowed("views/customer/memberships.cfm")).toBeTrue();
                expect(allowed("handler/customer.cfm", "POST", {edit_company_btn:1})).toBeTrue();
                expect(allowed("handler/customer.cfm", "POST", {new_tenant_btn:1})).toBeFalse();
                expect(allowed("handler/user.cfm", "POST", {user_new_btn:1})).toBeFalse();
                expect(variables.access.managementData(variables.member.userID, variables.tenant).tenants.recordCount).toBe(1);
            });
            it("restricts lifecycle deletion requests to an owner POST for its own organization or tenant", () => {
                activate();
                expect(variables.access.allowRequest(variables.owner.userID, variables.organization, "backend/core/handler/cancel.cfm", "POST", {delete:variables.organization})).toBeTrue();
                expect(variables.access.allowRequest(variables.owner.userID, variables.organization, "backend/core/handler/cancel.cfm", "POST", {delete:variables.tenant})).toBeTrue();
                expect(variables.access.allowRequest(variables.owner.userID, variables.organization, "backend/core/handler/cancel.cfm", "GET", {delete:variables.organization})).toBeFalse();
                expect(variables.access.allowRequest(variables.owner.userID, variables.organization, "backend/core/handler/cancel.cfm", "POST", {delete:variables.other})).toBeFalse();
                expect(variables.access.allowRequest(variables.member.userID, variables.tenant, "backend/core/handler/cancel.cfm", "POST", {delete:variables.tenant})).toBeFalse();
            });
            it("keeps platform support sessions separate from the represented account", () => {
                activate(); loginAs(variables.owner);
                sql("UPDATE users SET blnSysAdmin = 1 WHERE intUserID = :id", variables.owner.userID);
                session.supportLogin = true;
                expect(variables.access.refreshSession()).toBeTrue();
                expect(session.sysadmin).toBeFalse();
            });
            it("keeps unrelated legacy organizations on their existing access model", () => {
                activate();
                local.legacy = variables.fixtures.createUser(customerID=variables.other, admin=true);
                loginAs(local.legacy);
                expect(variables.access.refreshSession()).toBeTrue();
                expect(session.admin).toBeTrue();
                expect(structKeyExists(session,"membership_access")).toBeFalse();
            });
            it("prevents profile updates from suspending the last owner or changing legacy tenant assignments", () => {
                activate(); loginAs(variables.owner);
                local.result = application.objUser.updateUser({first_name:"Owner",last_name:"Example",email:variables.owner.email,active:0,admin:0,superadmin:0,tenantID:toString(variables.other)}, variables.owner.userID, false);
                expect(local.result.success).toBeTrue();
                expect(sql("SELECT blnActive FROM users WHERE intUserID = :id",variables.owner.userID).blnActive).toBe(1);
                expect(variables.access.context(variables.owner.userID).allowed).toBeTrue();
                expect(sql("SELECT * FROM customer_user WHERE intUserID = :id",variables.owner.userID).recordCount).toBe(2);
            });
            it("creates a member with scoped access and ignores submitted legacy privilege flags", () => {
                activate(); loginAs(variables.owner);
                local.created = application.objMembership.createUser(variables.owner.userID, variables.tenant,
                    {first_name:"New",last_name:"Member",email:variables.fixtures.uniqueEmail(),admin:1,superadmin:1,sysadmin:1}, "tenant.viewer");
                expect(local.created.success).toBeTrue();
                local.user = sql("SELECT * FROM users WHERE intUserID = :id",local.created.newUserID);
                expect(local.user.blnSysAdmin).toBe(0); expect(local.user.blnSuperAdmin).toBe(0); expect(local.user.blnAdmin).toBe(0);
                expect(local.user.intCustomerID).toBe(variables.organization);
                expect(variables.access.context(local.created.newUserID).customerID).toBe(variables.tenant);
                expect(application.objGlobal.checkTenantRange(local.created.newUserID,variables.organization)).toBeFalse();
            });
            it("enforces the plan user limit on the server without leaving an orphan identity", () => {
                activate(); loginAs(variables.owner);
                local.plan = variables.fixtures.createPlan();
                sql("UPDATE plans SET intMaxUsers = 1 WHERE intPlanID = :id",local.plan);
                variables.fixtures.createBooking(customerID=variables.tenant,planID=local.plan,status="active",startDate=dateFormat(now(),"yyyy-mm-dd"),endDate=dateFormat(dateAdd("m",1,now()),"yyyy-mm-dd"));
                local.before = sql("SELECT * FROM users WHERE intCustomerID = :id",variables.organization).recordCount;
                expect(() => application.objMembership.createUser(variables.owner.userID,variables.tenant,{email:variables.fixtures.uniqueEmail()},"tenant.viewer")).toThrow(type="Saaster.Membership.UserLimit");
                expect(sql("SELECT * FROM users WHERE intCustomerID = :id",variables.organization).recordCount).toBe(local.before);
            });
            it("checks password login against membership permissions and refuses removed members", () => {
                activate();
                queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:variables.member.userID},password:{type:"varchar",value:application.objGlobal.hashPassword("Test password 123!")}},sql="UPDATE users SET strPasswordHash = :password, strPasswordSalt = '' WHERE intUserID = :id");
                application.objMembership.setTenantMember(variables.owner.userID,variables.tenant,variables.member.userID,"tenant.viewer");
                local.login = new frontend.core.com.login().checkLogin(email=variables.member.email,password="Test password 123!");
                expect(local.login.loginCorrect).toBeTrue();
                expect(local.login.admin).toBeFalse(); expect(local.login.superadmin).toBeFalse();
                application.objMembership.removeOrganizationMember(variables.owner.userID,variables.organization,variables.member.userID);
                expect(new frontend.core.com.login().checkLogin(email=variables.member.email,password="Test password 123!").loginCorrect).toBeFalse();
            });
            it("renders a real setup preview and role forms without literal CFML or unescaped identity data", () => {
                sql("UPDATE users SET strFirstName = '<script>alert(1)</script>' WHERE intUserID = :id",variables.member.userID);
                local.page = renderPage();
                expect(local.page.statusCode).toInclude("200");
                expect(local.page.fileContent).toInclude("Apply and activate roles");
                expect(local.page.fileContent).toInclude("&lt;script&gt;");
                expect(local.page.fileContent).notToInclude("<script>alert(1)</script>");
                expect(local.page.fileContent).notToInclude("##getTrans");
                expect(local.page.fileContent).notToInclude("##application.mainURL##");
                activate();
                local.page = renderPage();
                expect(local.page.statusCode).toInclude("200");
                expect(local.page.fileContent).toInclude('value="save_member"');
                expect(local.page.fileContent).toInclude('name="tenant_role_');
                expect(local.page.fileContent).toInclude('value="transfer"');
                expect(local.page.fileContent).toInclude('name="csrf_token"');
            });
            it("renders the account-settings entry and invitation controls", () => {
                local.page = renderPage("account");
                expect(local.page.statusCode).toInclude("200");
                expect(local.page.fileContent).toInclude("/account-settings/memberships");
                expect(local.page.fileContent).toInclude("Members and roles");
                activate();
                local.page = renderPage("memberships");
                expect(local.page.statusCode).toInclude("200");
                expect(local.page.fileContent).toInclude('name="invite_organization_role"');
                expect(local.page.fileContent).notToInclude('name="sysadmin"');
                expect(local.page.fileContent).notToInclude('name="superadmin"');
                expect(local.page.fileContent).notToInclude('name="admin"');
            });
            it("revalidates access between password entry and MFA completion", () => {
                activate();
                queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:variables.member.userID},expires:{type:"timestamp",value:dateAdd("h",3,now())}},sql="UPDATE users SET intMfaCode = 123456, dtmMfaDateTime = :expires WHERE intUserID = :id");
                local.token = sql("SELECT strUUID FROM users WHERE intUserID = :id",variables.member.userID).strUUID;
                local.result = application.objUser.checkMfa(local.token,123456);
                expect(local.result.success).toBeTrue(); expect(local.result.customerID).toBe(variables.tenant);
                application.objMembership.removeOrganizationMember(variables.owner.userID,variables.organization,variables.member.userID);
                expect(application.objUser.checkMfa(local.token,123456).success).toBeFalse();
            });
            it("preserves an account and sibling access when its former home tenant is deleted", () => {
                activate();
                application.objMembership.setTenantMember(variables.owner.userID,variables.organization,variables.member.userID,"tenant.viewer");
                sql("DELETE FROM customers WHERE intCustomerID = :id",variables.tenant);
                expect(variables.access.context(variables.member.userID).customerID).toBe(variables.organization);
            });
        });
    }
    private struct function renderPage(string view="memberships") {
        local.base = "http://127.0.0.1";
        cfhttp(url=local.base & "/tests/support/membership_probe.cfm?userID=" & variables.owner.userID & "&customerID=" & variables.organization & "&view=" & arguments.view,method="get",redirect=false,timeout=30,result="local.response");
        return local.response;
    }
    private void function activate() {
        variables.migration.activate(variables.owner.userID,variables.organization,variables.owner.userID,true);
    }
    private query function sql(required string sql, required numeric id) {
        return queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:arguments.id}},sql=arguments.sql);
    }
    private boolean function allowed(required string path, string method="GET", struct submitted={}, struct queryString={}) {
        return variables.access.allowRequest(variables.member.userID,variables.tenant,"backend/core/" & arguments.path,arguments.method,arguments.submitted,arguments.queryString);
    }
}
