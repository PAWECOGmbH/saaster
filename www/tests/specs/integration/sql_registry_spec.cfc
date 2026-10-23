component extends="tests.support.integration_spec" {

    /*
        Every value written into SQL directly - checked against support/sql_registry.cfc.

        A new interpolation without a reviewed entry turns the run red, and so does
        an entry that no longer exists. The runner lists every place with the reason
        why it is safe.
    */

    function run() {

        var registry = new tests.support.sql_registry();

        describe("SQL interpolation registry", () => {

            beforeEach(() => {
                if (not structKeyExists(variables, "found")) {
                    variables.found = new tests.support.security_scanner().sqlInterpolations();
                }
            });

            it("lists every value interpolated into SQL in the core", () => {
                var listed = {};
                for (var entry in registry.entries()) {
                    listed[entry.file & "|" & entry.expression] = true;
                }

                var unlisted = variables.found
                    .filter((item) => not structKeyExists(listed, item.file & "|" & item.expression))
                    .map((item) => item.file & ":  ##" & item.expression & "##");

                if (arrayLen(unlisted)) {
                    fail("Values interpolated into SQL without a reviewed entry in sql_registry.cfc - bind them as parameters or add them with a reason:" & chr(10) & arrayToList(unlisted, chr(10)));
                }
            });

            describe("Reviewed interpolations", () => {

                for (var entry in registry.entries()) {
                    it(
                        title = entry.reason & "  [" & entry.file & ": " & entry.expression & "]",
                        data  = { entry: entry },
                        body  = (data) => {
                            var stillThere = variables.found.filter((item) => item.file eq data.entry.file and item.expression eq data.entry.expression);
                            expect(arrayLen(stillThere)).toBeGT(0, "No longer found - remove the entry from sql_registry.cfc");
                        }
                    );
                }

            });

        });

    }

}
