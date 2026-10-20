component extends="tests.support.integration_spec" {

    /*
        user.cfc::getRoleFacts - the facts the role rules decide on, read from
        the database. If these are wrong, the rules in user_roles_spec are right
        and still protect nothing.
    */

    function run() {

        describe("getRoleFacts", () => {

            beforeEach(() => {
                variables.customerID = variables.fixtures.createCustomer();
                variables.mainUser = variables.fixtures.createUser(customerID = variables.customerID, superAdmin = true);
                variables.secondUser = variables.fixtures.createUser(customerID = variables.customerID, admin = true);
            });

            it("recognises the first user of a customer as main user", () => {
                expect(application.objUser.getRoleFacts(variables.mainUser.userID).mainUser).toBeTrue();
            });

            it("does not treat later users as main user", () => {
                expect(application.objUser.getRoleFacts(variables.secondUser.userID).mainUser).toBeFalse();
            });

            it("reads the roles and the customer of the user", () => {
                var facts = application.objUser.getRoleFacts(variables.secondUser.userID);

                expect(facts.exists).toBeTrue();
                expect(facts.customerID).toBe(variables.customerID);
                expect(facts.admin).toBeTrue();
                expect(facts.superadmin).toBeFalse();
                expect(facts.sysadmin).toBeFalse();
                expect(facts.active).toBeTrue();
            });

            it("reads the user's own active flag, not the customer's", () => {
                queryExecute(
                    "UPDATE users SET blnActive = 0 WHERE intUserID = :userID",
                    { userID: { type: "numeric", value: variables.secondUser.userID } },
                    { datasource: application.datasource }
                );

                expect(application.objUser.getRoleFacts(variables.secondUser.userID).active).toBeFalse();
            });

            it("reports a user that does not exist", () => {
                expect(application.objUser.getRoleFacts(999999999).exists).toBeFalse();
            });

        });

    }

}
