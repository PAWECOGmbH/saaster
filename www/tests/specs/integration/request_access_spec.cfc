component extends="tests.support.integration_spec" {
    function run() {
        describe("Shared request access decisions", () => {
            beforeEach(() => {
                logout();
                variables.access = application.objRequestAccess;
                variables.organization = variables.fixtures.createCustomer();
                variables.owner = variables.fixtures.createUser(customerID=variables.organization, superAdmin=true);
                variables.reader = variables.fixtures.createUser(customerID=variables.organization);
                variables.content = {thisPath:"backend/core/views/main.cfm", access:true, onlyAdmin:false, onlySuperAdmin:false, onlySysAdmin:false};
            });

            it("preserves anonymous login, registration and invoice-print entry points", () => {
                expect(variables.access.checkPage(variables.content, "GET").redirect).toBe("/login");
                expect(variables.access.checkPage(variables.content, "GET", {plan:12}).redirect).toBe("/register?redirect=book?plan=12");
                expect(variables.access.checkPage(variables.content, "GET", {pdf:"token"}).redirect).toBe("/backend/core/views/invoices/print.cfm?pdf=token");
                expect(variables.access.canAccess(variables.content)).toBeFalse();
                variables.content.thisPath = "frontend/default_theme/templates/login.cfm";
                expect(variables.access.canAccess(variables.content)).toBeTrue();
                variables.content.access = false;
                expect(variables.access.checkPage(variables.content, "GET").redirect).toBe("");
            });

            it("preserves independent legacy admin, superadmin and platform mapping flags", () => {
                loginAs(variables.reader);
                loop array=["admin", "superadmin", "sysadmin"] item="local.role" {
                    local.key = "only" & local.role;
                    variables.content[local.key] = true;
                    expect(variables.access.canAccess(variables.content)).toBeFalse();
                    session[local.role] = true;
                    expect(variables.access.canAccess(variables.content)).toBeTrue();
                    session[local.role] = false;
                    variables.content[local.key] = false;
                }
                variables.content.onlyAdmin = true;
                session.superadmin = true;
                expect(variables.access.canAccess(variables.content)).toBeFalse();
            });

            it("keeps product denial ahead of legacy flags without generating duplicate alerts", () => {
                loginAs(variables.reader);
                variables.content.access = false;
                variables.content.onlyAdmin = true;
                local.decision = variables.access.checkPage(variables.content, "GET");
                expect(local.decision.reason).toBe("mapping");
                expect(local.decision.redirect).toBe("/dashboard");
                expect(structKeyExists(local.decision, "alertKey")).toBeFalse();
                session.sysadmin = true;
                expect(variables.access.canAccess(variables.content)).toBeFalse();
            });

            it("uses current membership permissions for UI actions without requiring CSRF tokens", () => {
                activateReader();
                session.alert = "unchanged";
                expect(variables.access.canAccess(variables.content)).toBeTrue();
                variables.content.thisPath = "backend/core/handler/customer.cfm";
                expect(variables.access.canAccess(variables.content, "POST", {edit_company_btn:1})).toBeFalse();
                application.objMembership.setTenantMember(variables.owner.userID, variables.organization, variables.reader.userID, "tenant.admin");
                application.objMembershipAccess.refreshSession();
                expect(variables.access.canAccess(variables.content, "POST", {edit_company_btn:1})).toBeTrue();
                expect(session.alert).toBe("unchanged");
            });

            it("preserves the separate platform boundary during support access", () => {
                activateReader();
                session.supportLogin = true;
                variables.content.thisPath = "backend/core/views/sysadmin/customers.cfm";
                variables.content.onlySysAdmin = true;
                expect(variables.access.checkContext(variables.content, "GET").statusCode).toBe(403);
                expect(variables.access.canAccess(variables.content)).toBeFalse();
            });

            it("rejects stale mutations but accepts the original context token from fields or headers", () => {
                activateReader();
                variables.content.thisPath = "backend/core/handler/user.cfm";
                local.submitted = {userID:variables.reader.userID};
                expect(variables.access.checkContext(variables.content, "POST", local.submitted).statusCode).toBe(409);
                local.token = application.objGlobal.contextToken();
                expect(variables.access.checkContext(variables.content, "POST", local.submitted, {}, {"X-Saaster-Context":local.token}).access).toBeTrue();
                local.submitted.context_token = local.token;
                expect(variables.access.checkContext(variables.content, "POST", local.submitted).access).toBeTrue();
                local.submitted.context_token = "invalid";
                expect(variables.access.checkContext(variables.content, "POST", local.submitted, {}, {"X-Saaster-Context":local.token}).statusCode).toBe(409);
            });

            it("does not introduce context requirements for ordinary reads or legacy sessions", () => {
                loginAs(variables.reader);
                variables.content.thisPath = "backend/core/handler/user.cfm";
                expect(variables.access.checkContext(variables.content, "POST").access).toBeTrue();
                activateReader();
                variables.content.thisPath = "backend/core/views/main.cfm";
                expect(variables.access.checkContext(variables.content, "GET").access).toBeTrue();
            });

            it("preserves inclusive booking dates and access until a canceled booking ends", () => {
                local.today = createDate(2026, 11, 8);
                expect(variables.access.bookingAccess({}, local.today)).toBeFalse();
                expect(variables.access.bookingAccess({status:"active"}, local.today)).toBeFalse();
                expect(variables.access.bookingAccess({status:"free"}, local.today)).toBeTrue();
                loop array=["test", "active", "canceled", "payment"] item="local.status" {
                    expect(variables.access.bookingAccess({status:local.status, startDate:local.today, endDate:local.today}, local.today)).toBeTrue();
                }
                expect(variables.access.bookingAccess({status:"active", startDate:dateAdd("d", 1, local.today), endDate:dateAdd("d", 2, local.today)}, local.today)).toBeFalse();
                expect(variables.access.bookingAccess({status:"canceled", startDate:dateAdd("d", -2, local.today), endDate:dateAdd("d", -1, local.today)}, local.today)).toBeFalse();
                expect(variables.access.bookingAccess({status:"active", startDate:"invalid", endDate:local.today}, local.today)).toBeFalse();
            });

            it("keeps direct module entitlement independent of roles", () => {
                loginAs(variables.owner);
                local.module = variables.fixtures.createModule();
                expect(variables.access.moduleAccess(local.module)).toBeFalse();
                variables.fixtures.createBooking(customerID=variables.organization, moduleID=local.module, status="active",
                    startDate=dateFormat(now(), "yyyy-mm-dd"), endDate=dateFormat(dateAdd("d", 1, now()), "yyyy-mm-dd"));
                expect(variables.access.moduleAccess(local.module)).toBeTrue();
                local.other = variables.fixtures.createModule();
                expect(variables.access.moduleAccess(local.other)).toBeFalse();
                session.sysadmin = true;
                expect(variables.access.moduleAccess(local.other)).toBeTrue();
                session.sysadmin = false;
                session.supportLogin = true;
                expect(variables.access.moduleAccess(local.other)).toBeFalse();
            });
        });
    }

    private void function activateReader() {
        application.objMembershipMigration.activate(variables.owner.userID, variables.organization, variables.owner.userID, true);
        application.objMembership.setTenantMember(variables.owner.userID, variables.organization, variables.reader.userID, "tenant.viewer");
        loginAs(variables.reader);
        application.objMembershipAccess.refreshSession();
    }
}
