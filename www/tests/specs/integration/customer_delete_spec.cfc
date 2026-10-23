component extends="tests.support.integration_spec" {

    /*
        customer.cfc::deleteAccount - the files of a deleted account.

        Regression: the logo was only deleted if the first user of the customer had a
        photo (the check read strPhoto instead of strLogo). Customers whose users had no
        photo left their logo behind in /userdata/images/logos.

        The files get unique names; whatever a failing test leaves behind is removed in
        afterEach.
    */

    function run() {

        describe("Deleting an account", () => {

            beforeEach(() => {
                variables.createdFiles = [];
                variables.customerID = variables.fixtures.createCustomer();
                variables.user = variables.fixtures.createUser(customerID = variables.customerID);
            });

            afterEach(() => {
                for (var path in variables.createdFiles) {
                    if (fileExists(path)) {
                        fileDelete(path);
                    }
                }
            });

            it("deletes the logo also when the users have no photo", () => {
                var logo = createFile("logos", "png");
                setLogo(logo.name);

                var result = new backend.core.com.customer().deleteAccount(variables.customerID);

                expect(result.success).toBeTrue(result.message);
                expect(fileExists(logo.path)).toBeFalse("The logo was left behind");
            });

            it("deletes the logo and the photos of the users", () => {
                var logo = createFile("logos", "png");
                var photo = createFile("users", "jpg");
                setLogo(logo.name);
                queryExecute(
                    "UPDATE users SET strPhoto = :photo WHERE intUserID = :userID",
                    { photo: { type: "varchar", value: photo.name }, userID: { type: "numeric", value: variables.user.userID } },
                    { datasource: application.datasource }
                );

                new backend.core.com.customer().deleteAccount(variables.customerID);

                expect(fileExists(logo.path)).toBeFalse();
                expect(fileExists(photo.path)).toBeFalse();
            });

            it("deletes an account without logo or photos", () => {
                var result = new backend.core.com.customer().deleteAccount(variables.customerID);

                expect(result.success).toBeTrue(result.message);
                var left = queryExecute(
                    "SELECT COUNT(*) AS cnt FROM customers WHERE intCustomerID = :customerID",
                    { customerID: { type: "numeric", value: variables.customerID } },
                    { datasource: application.datasource }
                );
                expect(left.cnt).toBe(0);
            });

        });

    }

    // A file in /userdata/images/<folder> with a unique name: { name, path }
    private struct function createFile(required string folder, required string extension) {
        var name = "testbox-" & lCase(createUUID()) & "." & arguments.extension;
        var path = expandPath("/userdata/images/" & arguments.folder & "/" & name);
        if (!directoryExists(getDirectoryFromPath(path))) {
            directoryCreate(getDirectoryFromPath(path), true);
        }
        fileWrite(path, "testbox");
        arrayAppend(variables.createdFiles, path);
        return { name: name, path: path };
    }

    private void function setLogo(required string fileName) {
        queryExecute(
            "UPDATE customers SET strLogo = :logo WHERE intCustomerID = :customerID",
            { logo: { type: "varchar", value: arguments.fileName }, customerID: { type: "numeric", value: variables.customerID } },
            { datasource: application.datasource }
        );
    }

}
