component extends="tests.support.integration_spec" {

    /*
        frontend/core/com/login.cfc::checkLogin - the password check of the login.

        Existing users still have legacy SHA-512 hashes. They must be able to log in
        as before, and their hash must be replaced by Argon2id at that moment - no
        password reset, no action from the user.
    */

    private query function readPassword(required numeric userID) {
        return queryExecute(
            "SELECT strPasswordHash, strPasswordSalt FROM users WHERE intUserID = :userID",
            { userID: { type: "numeric", value: arguments.userID } },
            { datasource: application.datasource }
        );
    }

    function run() {

        describe("checkLogin", () => {

            beforeEach(() => {
                variables.customerID = variables.fixtures.createCustomer();
                variables.login = new frontend.core.com.login();
            });

            describe("with a legacy SHA-512 hash", () => {

                beforeEach(() => {
                    var salt = hash(createUUID(), "SHA-512");
                    variables.user = variables.fixtures.createUser(
                        customerID   = variables.customerID,
                        passwordHash = hash("Legacy-Pass-1" & salt, "SHA-512"),
                        passwordSalt = salt
                    );
                });

                it("logs the user in with the right password", () => {
                    expect(variables.login.checkLogin(email = variables.user.email, password = "Legacy-Pass-1").loginCorrect).toBeTrue();
                });

                it("replaces the legacy hash with Argon2id on that login", () => {
                    variables.login.checkLogin(email = variables.user.email, password = "Legacy-Pass-1");

                    var stored = readPassword(variables.user.userID);
                    expect(stored.strPasswordHash).toInclude("$argon2id$");
                    expect(stored.strPasswordSalt).toBe("");
                });

                it("still logs the user in after the migration", () => {
                    variables.login.checkLogin(email = variables.user.email, password = "Legacy-Pass-1");

                    expect(variables.login.checkLogin(email = variables.user.email, password = "Legacy-Pass-1").loginCorrect).toBeTrue();
                });

                it("does not touch the hash on a wrong password", () => {
                    var before = readPassword(variables.user.userID).strPasswordHash;

                    expect(variables.login.checkLogin(email = variables.user.email, password = "wrong").loginCorrect).toBeFalse();
                    expect(readPassword(variables.user.userID).strPasswordHash).toBe(before);
                });

            });

            describe("with an Argon2id hash", () => {

                beforeEach(() => {
                    variables.user = variables.fixtures.createUser(
                        customerID   = variables.customerID,
                        passwordHash = application.objGlobal.hashPassword("Argon-Pass-1")
                    );
                });

                it("logs the user in with the right password", () => {
                    expect(variables.login.checkLogin(email = variables.user.email, password = "Argon-Pass-1").loginCorrect).toBeTrue();
                });

                it("refuses a wrong password", () => {
                    expect(variables.login.checkLogin(email = variables.user.email, password = "Argon-Pass-2").loginCorrect).toBeFalse();
                });

            });

            describe("without a usable password", () => {

                it("refuses an unknown address", () => {
                    expect(variables.login.checkLogin(email = variables.fixtures.uniqueEmail("nobody"), password = "x").loginCorrect).toBeFalse();
                });

                it("refuses an invited user who has not set a password yet", () => {
                    var invited = variables.fixtures.createUser(customerID = variables.customerID);

                    expect(variables.login.checkLogin(email = invited.email, password = "").loginCorrect).toBeFalse();
                });

            });

        });

    }

}
