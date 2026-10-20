component extends="tests.support.integration_spec" {

    /*
        Links sent by e-mail expire (user.cfc::getUserByValidToken, getOptinUser,
        register.cfc::getValidOptin). Before, a reset or invitation link stayed
        valid until it was used or the user logged in - possibly for months.

        Lifetimes: password reset 2 hours, e-mail change 24 hours, invitation and
        registration opt-in 7 days.
    */

    // Gives the user a token issued the given number of hours ago.
    private string function issueToken(required numeric userID, required numeric hoursAgo) {
        var token = lCase(replace(createUUID(), "-", "", "all")) & lCase(replace(createUUID(), "-", "", "all"));

        queryExecute(
            "UPDATE users SET strUUID = :token, dtmUUIDCreated = UTC_TIMESTAMP() - INTERVAL :hours HOUR WHERE intUserID = :userID",
            {
                token: { type: "varchar", value: token },
                hours: { type: "numeric", value: arguments.hoursAgo },
                userID: { type: "numeric", value: arguments.userID }
            },
            { datasource: application.datasource }
        );

        return token;
    }

    private string function createOptin(required numeric hoursAgo) {
        var token = lCase(replace(createUUID(), "-", "", "all")) & lCase(replace(createUUID(), "-", "", "all"));

        queryExecute(
            "INSERT INTO optin (strFirstName, strLastName, strEmail, strLanguage, strUUID, dtmCreated)
             VALUES ('TestBox', 'Optin', :email, 'en', :token, UTC_TIMESTAMP() - INTERVAL :hours HOUR)",
            {
                email: { type: "varchar", value: variables.fixtures.uniqueEmail("optin") },
                token: { type: "varchar", value: token },
                hours: { type: "numeric", value: arguments.hoursAgo }
            },
            { datasource: application.datasource }
        );

        return token;
    }

    function run() {

        describe("Expiring e-mail links", () => {

            beforeEach(() => {
                variables.customerID = variables.fixtures.createCustomer();
                variables.user = variables.fixtures.createUser(customerID = variables.customerID);
                variables.users = application.objUser;
            });

            afterEach(() => {
                queryExecute(
                    "DELETE FROM optin WHERE strEmail LIKE :marker",
                    { marker: { type: "varchar", value: "%" & variables.fixtures.marker() } },
                    { datasource: application.datasource }
                );
            });

            describe("password reset (2 hours)", () => {

                it("accepts a fresh link", () => {
                    var token = issueToken(variables.user.userID, 1);

                    expect(variables.users.getUserByValidToken(token, "reset").intUserID).toBe(variables.user.userID);
                });

                it("rejects a link older than 2 hours", () => {
                    var token = issueToken(variables.user.userID, 3);

                    expect(variables.users.getUserByValidToken(token, "reset").recordCount).toBe(0);
                });

            });

            describe("invitation (7 days)", () => {

                it("accepts a link of 6 days", () => {
                    var token = issueToken(variables.user.userID, 6 * 24);

                    expect(variables.users.getUserByValidToken(token, "invitation").recordCount).toBe(1);
                });

                it("rejects a link of 8 days", () => {
                    var token = issueToken(variables.user.userID, 8 * 24);

                    expect(variables.users.getUserByValidToken(token, "invitation").recordCount).toBe(0);
                });

                it("starts the lifetime when insertUser creates the user", () => {
                    var created = variables.users.insertUser(
                        { first_name: "Invited", last_name: "User", email: variables.fixtures.uniqueEmail("invited"), language: "en", active: 1 },
                        variables.customerID
                    );

                    expect(variables.users.getUserByValidToken(created.newUUID, "invitation").recordCount).toBe(1);
                });

            });

            describe("e-mail change confirmation (24 hours)", () => {

                it("accepts a fresh link", () => {
                    var token = issueToken(variables.user.userID, 2);

                    expect(variables.users.getOptinUser(token).recordCount).toBe(1);
                });

                it("rejects a link older than 24 hours", () => {
                    var token = issueToken(variables.user.userID, 25);

                    expect(variables.users.getOptinUser(token).recordCount).toBe(0);
                });

            });

            describe("tokens without a creation time", () => {

                // Tokens are only valid if they carry their issue time. A token
                // written without it (old code path, manual change) never works.
                it("rejects a token without dtmUUIDCreated", () => {
                    var token = issueToken(variables.user.userID, 0);
                    queryExecute(
                        "UPDATE users SET dtmUUIDCreated = NULL WHERE intUserID = :userID",
                        { userID: { type: "numeric", value: variables.user.userID } },
                        { datasource: application.datasource }
                    );

                    expect(variables.users.getUserByValidToken(token, "invitation").recordCount).toBe(0);
                });

                it("rejects an empty token", () => {
                    expect(variables.users.getUserByValidToken("", "reset").recordCount).toBe(0);
                });

                it("refuses an unknown purpose", () => {
                    expect(() => variables.users.getUserByValidToken("x", "forever")).toThrow(type = "Saaster.UnknownTokenPurpose");
                });

            });

            describe("registration opt-in (7 days)", () => {

                it("accepts a fresh opt-in", () => {
                    expect(new frontend.core.com.register().getValidOptin(createOptin(1)).recordCount).toBe(1);
                });

                it("rejects an opt-in of 8 days", () => {
                    expect(new frontend.core.com.register().getValidOptin(createOptin(8 * 24)).recordCount).toBe(0);
                });

            });

        });

    }

}
