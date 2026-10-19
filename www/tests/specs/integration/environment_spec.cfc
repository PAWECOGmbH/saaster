component extends="tests.support.integration_spec" {

    /*
        Smoke test for the test environment itself. If this spec is red, every
        other integration spec is meaningless - start looking here.
    */

    function run() {

        describe("Test environment", () => {

            it("is connected to the test database, not to the development database", () => {
                var connected = queryExecute("SELECT DATABASE() AS db", {}, { datasource: application.datasource }).db;

                expect(connected).toBe(request.testSettings.database);
                expect(connected).toInclude("test");
            });

            it("has run the real Saaster application start", () => {
                expect(application).toHaveKey("objGlobal");
                expect(application).toHaveKey("objUser");
                expect(application).toHaveKey("objCustomer");
            });

            it("has loaded the languages from the migrated base data", () => {
                expect(len(application.allLanguages)).toBeGT(0);
            });

            it("has loaded the system settings from the migrated base data", () => {
                expect(application.systemSettingStruct).toBeStruct();
                expect(structCount(application.systemSettingStruct)).toBeGT(0);
            });

        });

    }

}
