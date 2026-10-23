component extends="testbox.system.BaseSpec" {

    /*
        user.cfc - the role rules behind creating and editing users
        (canCreateUser, canEditUser, allowedRoles). Pure functions, no database.

        Regression: the handler used to store admin, superadmin and sysadmin
        exactly as the form sent them. Any logged-in user could create a system
        administrator with a crafted POST, and every user could make themselves
        super admin through the hidden fields of the profile form.
    */

    private struct function actor(boolean admin = false, boolean superadmin = false, boolean sysadmin = false) {
        return { userID: 1, admin: arguments.admin, superadmin: arguments.superadmin, sysadmin: arguments.sysadmin };
    }

    private struct function target(boolean inTenantRange = true, boolean mainUser = false, boolean sysadmin = false) {
        return { inTenantRange: arguments.inTenantRange, mainUser: arguments.mainUser, sysadmin: arguments.sysadmin };
    }

    function run() {

        var users = application.objUser;

        describe("canCreateUser", () => {

            it("allows admins, super admins and system administrators", () => {
                expect(users.canCreateUser(actor(admin = true))).toBeTrue();
                expect(users.canCreateUser(actor(superadmin = true))).toBeTrue();
                expect(users.canCreateUser(actor(sysadmin = true))).toBeTrue();
            });

            it("denies a user without admin rights", () => {
                expect(users.canCreateUser(actor())).toBeFalse();
            });

        });

        /*
            Regression: the tenant actions in handler/customer.cfm only checked the
            tenant range. The route is open to admins, so an admin without super admin
            rights could create, delete and deactivate tenants by calling the handler
            directly, although the tenant pages are super admin only.
        */
        describe("canManageTenants", () => {

            it("allows super admins and system administrators", () => {
                expect(users.canManageTenants(actor(admin = true, superadmin = true))).toBeTrue();
                expect(users.canManageTenants(actor(sysadmin = true))).toBeTrue();
            });

            it("denies an admin without super admin rights", () => {
                expect(users.canManageTenants(actor(admin = true))).toBeFalse();
            });

            it("denies a user without admin rights", () => {
                expect(users.canManageTenants(actor())).toBeFalse();
            });

        });

        describe("canEditUser (another user)", () => {

            it("allows a super admin to edit a user of an own tenant", () => {
                expect(users.canEditUser(actor(admin = true, superadmin = true), target())).toBeTrue();
            });

            it("denies an admin without super admin rights", () => {
                expect(users.canEditUser(actor(admin = true), target())).toBeFalse();
            });

            it("denies a user without admin rights", () => {
                expect(users.canEditUser(actor(), target())).toBeFalse();
            });

            it("denies a user outside the own tenants", () => {
                expect(users.canEditUser(actor(admin = true, superadmin = true), target(inTenantRange = false))).toBeFalse();
            });

            it("denies the main user of a customer", () => {
                expect(users.canEditUser(actor(admin = true, superadmin = true), target(mainUser = true))).toBeFalse();
            });

            it("denies a system administrator", () => {
                expect(users.canEditUser(actor(admin = true, superadmin = true), target(sysadmin = true))).toBeFalse();
            });

            it("allows a system administrator everything", () => {
                expect(users.canEditUser(actor(sysadmin = true), target(inTenantRange = false, mainUser = true, sysadmin = true))).toBeTrue();
            });

        });

        describe("allowedRoles when creating a user", () => {

            it("does not let an admin grant super admin or system administrator", () => {
                var roles = users.allowedRoles(actor(admin = true), { admin: "on", superadmin: "on", sysadmin: "on", active: "on" });

                expect(roles.sysadmin).toBeFalse();
                expect(roles.superadmin).toBeFalse();
                expect(roles.admin).toBeTrue();
                expect(roles.active).toBeTrue();
            });

            it("lets a super admin grant super admin, but not system administrator", () => {
                var roles = users.allowedRoles(actor(admin = true, superadmin = true), { superadmin: 1, sysadmin: 1 });

                expect(roles.sysadmin).toBeFalse();
                expect(roles.superadmin).toBeTrue();
                expect(roles.admin).toBeTrue("super admin includes admin");
            });

            it("lets a system administrator grant every role, higher roles including the lower ones", () => {
                var roles = users.allowedRoles(actor(sysadmin = true), { sysadmin: "on" });

                expect(roles.sysadmin).toBeTrue();
                expect(roles.superadmin).toBeTrue();
                expect(roles.admin).toBeTrue();
            });

            it("creates a plain user when no role is requested", () => {
                var roles = users.allowedRoles(actor(admin = true), { active: "on" });

                expect(roles.admin).toBeFalse();
                expect(roles.superadmin).toBeFalse();
                expect(roles.sysadmin).toBeFalse();
            });

        });

        describe("allowedRoles when editing another user", () => {

            it("keeps the super admin role of a user if an admin edits it", () => {
                var roles = users.allowedRoles(actor(admin = true), { admin: 1, superadmin: 0, active: 1 }, { admin: true, superadmin: true });

                expect(roles.superadmin).toBeTrue();
            });

            it("lets a super admin revoke the super admin role", () => {
                var roles = users.allowedRoles(actor(admin = true, superadmin = true), { admin: 1, superadmin: 0, active: 1 }, { admin: true, superadmin: true });

                expect(roles.superadmin).toBeFalse();
                expect(roles.admin).toBeTrue();
            });

            it("never touches the system administrator role unless a system administrator edits", () => {
                var keep = users.allowedRoles(actor(admin = true, superadmin = true), { sysadmin: 0 }, { sysadmin: true, superadmin: true, admin: true });
                var grant = users.allowedRoles(actor(admin = true, superadmin = true), { sysadmin: 1 }, { sysadmin: false });

                expect(keep.sysadmin).toBeTrue();
                expect(grant.sysadmin).toBeFalse();
            });

            it("lets the editor deactivate the user", () => {
                var roles = users.allowedRoles(actor(admin = true, superadmin = true), { active: 0 }, { active: true });

                expect(roles.active).toBeFalse();
            });

        });

        describe("allowedRoles on the own profile", () => {

            it("ignores every requested role and keeps the current ones", () => {
                var roles = users.allowedRoles(actor(), { admin: 1, superadmin: 1, sysadmin: 1, active: 1 }, { admin: false, superadmin: false, sysadmin: false, active: true }, true);

                expect(roles.admin).toBeFalse();
                expect(roles.superadmin).toBeFalse();
                expect(roles.sysadmin).toBeFalse();
            });

            it("does not let users drop their own roles or deactivate themselves", () => {
                var roles = users.allowedRoles(actor(admin = true, superadmin = true), { admin: 0, superadmin: 0, active: 0 }, { admin: true, superadmin: true, active: true }, true);

                expect(roles.admin).toBeTrue();
                expect(roles.superadmin).toBeTrue();
                expect(roles.active).toBeTrue();
            });

        });

    }

}
