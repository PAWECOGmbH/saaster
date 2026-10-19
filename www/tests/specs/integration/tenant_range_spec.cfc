component extends="tests.support.integration_spec" {

    /*
        global.cfc::checkTenantRange - the check whether a user may act on a
        tenant. Deleting users and tenants, and printing invoices rely on it,
        so a false "true" here means data of one customer reachable by another.
    */

    function run() {

        describe("checkTenantRange", () => {

            beforeEach(() => {
                variables.ownCustomer = variables.fixtures.createCustomer(companyName = "Own Company");
                variables.otherCustomer = variables.fixtures.createCustomer(companyName = "Other Company");
                variables.user = variables.fixtures.createUser(customerID = variables.ownCustomer, admin = true);
            });

            it("allows the user's own tenant", () => {
                expect(application.objGlobal.checkTenantRange(variables.user.userID, variables.ownCustomer)).toBeTrue();
            });

            it("denies a tenant of another customer", () => {
                expect(application.objGlobal.checkTenantRange(variables.user.userID, variables.otherCustomer)).toBeFalse();
            });

            it("allows another tenant once access has been granted", () => {
                variables.fixtures.grantTenant(variables.user.userID, variables.otherCustomer);

                expect(application.objGlobal.checkTenantRange(variables.user.userID, variables.otherCustomer)).toBeTrue();
            });

            it("denies a tenant that does not exist", () => {
                expect(application.objGlobal.checkTenantRange(variables.user.userID, 0)).toBeFalse();
            });

        });

    }

}
