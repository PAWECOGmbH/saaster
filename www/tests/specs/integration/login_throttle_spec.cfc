component extends="tests.support.integration_spec" {

    /*
        loginthrottle.cfc - blocking password guessing on the login.

        Every spec uses its own random address and IP, so the counters of different
        specs (and of real logins in the test database) never mix. The limits are
        lowered via init() to keep the specs short; the logic is the same.
    */

    private string function randomIP() {
        return "10." & randRange(0, 255) & "." & randRange(0, 255) & "." & randRange(1, 254);
    }

    private void function cleanupKeys() {
        queryExecute(
            "DELETE FROM login_throttle WHERE strThrottleKey IN (:keys)",
            { keys: { type: "varchar", value: arrayToList([variables.throttle.emailKey(variables.email), variables.throttle.ipKey(variables.ip)]), list: true } },
            { datasource: application.datasource }
        );
    }

    function run() {

        describe("Login throttle", () => {

            beforeEach(() => {
                variables.throttle = new backend.core.com.loginthrottle(settings = { maxFailuresPerEmail: 3, maxFailuresPerIP: 5 });
                variables.email = variables.fixtures.uniqueEmail("throttle");
                variables.ip = randomIP();
            });

            afterEach(() => cleanupKeys());

            it("does not block without failures", () => {
                expect(variables.throttle.isBlocked(variables.email, variables.ip)).toBeFalse();
            });

            it("does not block below the limit", () => {
                variables.throttle.registerFailure(variables.email, variables.ip);
                variables.throttle.registerFailure(variables.email, variables.ip);

                expect(variables.throttle.isBlocked(variables.email, variables.ip)).toBeFalse();
            });

            it("blocks an address once its limit is reached - from any IP", () => {
                for (var i = 1; i lte 3; i++) {
                    variables.throttle.registerFailure(variables.email, randomIP());
                }

                expect(variables.throttle.isBlocked(variables.email, randomIP())).toBeTrue();
            });

            it("treats the address case-insensitively", () => {
                for (var i = 1; i lte 3; i++) {
                    variables.throttle.registerFailure(uCase(variables.email), randomIP());
                }

                expect(variables.throttle.isBlocked(variables.email, randomIP())).toBeTrue();
            });

            it("blocks an IP that tries many different addresses", () => {
                for (var i = 1; i lte 5; i++) {
                    variables.throttle.registerFailure(variables.fixtures.uniqueEmail("spray"), variables.ip);
                }

                expect(variables.throttle.isBlocked(variables.fixtures.uniqueEmail("other"), variables.ip)).toBeTrue();
            });

            it("lets a successful login reset the counter of the address", () => {
                variables.throttle.registerFailure(variables.email, randomIP());
                variables.throttle.registerFailure(variables.email, randomIP());
                variables.throttle.reset(variables.email);
                variables.throttle.registerFailure(variables.email, randomIP());
                variables.throttle.registerFailure(variables.email, randomIP());

                expect(variables.throttle.isBlocked(variables.email, randomIP())).toBeFalse();
            });

            it("starts counting anew after the time window", () => {
                variables.throttle.registerFailure(variables.email, randomIP());
                variables.throttle.registerFailure(variables.email, randomIP());

                // Move the first failure out of the window
                queryExecute(
                    "UPDATE login_throttle SET dtmFirstFailure = UTC_TIMESTAMP() - INTERVAL 20 MINUTE WHERE strThrottleKey = :key",
                    { key: { type: "varchar", value: variables.throttle.emailKey(variables.email) } },
                    { datasource: application.datasource }
                );

                variables.throttle.registerFailure(variables.email, randomIP());

                expect(variables.throttle.isBlocked(variables.email, randomIP())).toBeFalse();
            });

            it("lifts the block when it has expired", () => {
                for (var i = 1; i lte 3; i++) {
                    variables.throttle.registerFailure(variables.email, randomIP());
                }
                queryExecute(
                    "UPDATE login_throttle SET dtmBlockedUntil = UTC_TIMESTAMP() - INTERVAL 1 MINUTE WHERE strThrottleKey = :key",
                    { key: { type: "varchar", value: variables.throttle.emailKey(variables.email) } },
                    { datasource: application.datasource }
                );

                expect(variables.throttle.isBlocked(variables.email, randomIP())).toBeFalse();
            });

            it("never stores the plain e-mail address", () => {
                variables.throttle.registerFailure(variables.email, variables.ip);

                var stored = queryExecute(
                    "SELECT COUNT(*) AS cnt FROM login_throttle WHERE strThrottleKey LIKE :address",
                    { address: { type: "varchar", value: "%" & variables.email & "%" } },
                    { datasource: application.datasource }
                );

                expect(stored.cnt).toBe(0);
            });

        });

    }

}
