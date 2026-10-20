component extends="tests.support.integration_spec" {

    /*
        Values from requests that end up in SQL - with real payloads against the test database.

        sql_registry_spec checks the source; this spec checks the behaviour: an injected
        sort falls back to the default, quotes in search terms stay data, and a forged
        tenant list cannot widen the DELETE in updateUser().
    */

    variables.payloads = [
        "' OR '1'='1",
        "strCompanyName; DROP TABLE customers",
        "(SELECT SLEEP(5))",
        "1 UNION SELECT strPasswordHash FROM users",
        "strCompanyName ASC, (SELECT 1 FROM users)"
    ];

    function run() {

        describe("safeOrderBy", () => {

            var allowed = ["strCompanyName ASC", "strCompanyName DESC"];

            it("returns an allowed value", () => {
                expect(application.objGlobal.safeOrderBy("strCompanyName DESC", allowed, "strCompanyName ASC")).toBe("strCompanyName DESC");
            });

            it("returns the allowed spelling for a value in other case or with spaces around it", () => {
                expect(application.objGlobal.safeOrderBy("  strcompanyname desc ", allowed, "strCompanyName ASC")).toBe("strCompanyName DESC");
            });

            it("returns the default for an empty value", () => {
                expect(application.objGlobal.safeOrderBy("", allowed, "strCompanyName ASC")).toBe("strCompanyName ASC");
            });

            for (var payload in variables.payloads) {
                it(
                    title = "returns the default for: " & payload,
                    data  = { payload: payload, allowed: allowed },
                    body  = (data) => {
                        expect(application.objGlobal.safeOrderBy(data.payload, data.allowed, "strCompanyName ASC")).toBe("strCompanyName ASC");
                    }
                );
            }

        });

        describe("isKnownColumn", () => {

            it("accepts an existing table and column", () => {
                expect(application.objGlobal.isKnownColumn("customers", "strCompanyName")).toBeTrue();
            });

            it("rejects an unknown column", () => {
                expect(application.objGlobal.isKnownColumn("customers", "strNoSuchColumn")).toBeFalse();
            });

            it("rejects an unknown table", () => {
                expect(application.objGlobal.isKnownColumn("no_such_table", "strCompanyName")).toBeFalse();
            });

            it("rejects SQL in the table or column name", () => {
                expect(application.objGlobal.isKnownColumn("customers WHERE 1=1 --", "strCompanyName")).toBeFalse();
                expect(application.objGlobal.isKnownColumn("customers", "strCompanyName, strPasswordHash")).toBeFalse();
                expect(application.objGlobal.isKnownColumn("customers`", "strCompanyName")).toBeFalse();
            });

            it("rejects a table of another schema", () => {
                expect(application.objGlobal.isKnownColumn("information_schema.tables", "table_name")).toBeFalse();
            });

        });

        describe("Sort parameters of the sysadmin and blog lists", () => {

            for (var payload in variables.payloads) {
                it(
                    title = "fall back to the default order for: " & payload,
                    data  = { payload: payload },
                    body  = (data) => {
                        // A sort that reached the SQL would fail to parse or change the result - both make the call throw or differ.
                        expect(application.objSysadmin.getCustomer(0, data.payload).recordCount).toBe(application.objSysadmin.getCustomer(0, "strCompanyName ASC").recordCount);
                        application.objSysadmin.getCustomerSearch("TestBox", 0, data.payload);
                        application.objSysadmin.getAllInvoicesSearch("TestBox", "1", 0, "", data.payload);
                        new backend.core.com.blog().getPosts(0, data.payload);
                        new backend.core.com.blog().getPostsSearch("TestBox", 0, data.payload);
                        expect(new frontend.core.com.blog().getOverviewPosts(sort = data.payload)).toBeArray();
                    }
                );
            }

        });

        describe("Search terms with quotes", () => {

            beforeEach(() => {
                variables.customerID = variables.fixtures.createCustomer(companyName = "TestBox Injection " & createUUID());
            });

            it("finds nothing with a classic always-true payload in the customer lookup", () => {
                var result = application.objSysadmin.getCustomerAjax("' OR '1'='1");
                expect(result.recordCount).toBe(0);
            });

            it("treats quotes and comment signs as part of the search value (LIKE searches)", () => {
                for (var payload in variables.payloads.merge(["'; --", '" OR ""="', "\'"])) {
                    expect(application.objSysadmin.getCustomerAjax(payload).recordCount).toBe(0);
                    application.objSysadmin.searchCustomTranslations(payload);
                    application.objSysadmin.searchSystemTranslations(payload);
                }
            });

            // MATCH ... AGAINST (:search IN BOOLEAN MODE): the value is bound, but MySQL parses it
            // as a boolean search expression. A dangling operator such as "--" is a MySQL syntax
            // error there, not an injection - hence payloads without dangling operators.
            it("treats quotes as part of the search value (full-text searches)", () => {
                for (var payload in variables.payloads.merge(['" OR ""="', "\'"])) {
                    application.objSysadmin.getCustomerSearch(payload, 0, "strCompanyName ASC");
                    application.objSysadmin.getAllInvoicesSearch(payload, payload, 0, "", "invoiceNumber DESC");
                    new backend.core.com.blog().getPostsSearch(payload, 0, "dtmCreated DESC");
                }
            });

            it("still finds a customer by a normal search value", () => {
                var result = application.objSysadmin.getCustomerAjax("TestBox Injection");
                expect(result.recordCount).toBeGTE(1);
            });

        });

        describe("updateUser with a forged tenant list", () => {

            beforeEach(() => {
                variables.customerA = variables.fixtures.createCustomer();
                variables.customerB = variables.fixtures.createCustomer();
                variables.user = variables.fixtures.createUser(customerID = variables.customerA, admin = true);
                variables.fixtures.grantTenant(variables.user.userID, variables.customerB);
                variables.otherUser = variables.fixtures.createUser(customerID = variables.customerB);
            });

            it("keeps whole numbers only and leaves other users' tenant links alone", () => {
                var result = application.objUser.updateUser(
                    {
                        first_name: "TestBox",
                        last_name: "User",
                        email: variables.user.email,
                        language: "en",
                        active: 1,
                        admin: 1,
                        tenantID: variables.customerA & ",0) OR 1=1 OR (1"
                    },
                    variables.user.userID,
                    false
                );

                expect(result.success).toBeTrue(result.message);
                expect(tenantsOf(variables.user.userID)).toBe([variables.customerA]);
                expect(tenantsOf(variables.otherUser.userID)).toBe([variables.customerB], "The forged list reached the DELETE");
            });

            it("ignores a tenant list without any whole number", () => {
                application.objUser.updateUser(
                    { first_name: "TestBox", last_name: "User", email: variables.user.email, language: "en", active: 1, admin: 1, tenantID: "abc, ' OR 1=1, 1;2" },
                    variables.user.userID,
                    false
                );

                expect(tenantsOf(variables.user.userID)).toBe([variables.customerA, variables.customerB]);
            });

        });

    }

    private array function tenantsOf(required numeric userID) {
        var rows = queryExecute(
            "SELECT intCustomerID FROM customer_user WHERE intUserID = :userID ORDER BY intCustomerID",
            { userID: { type: "numeric", value: arguments.userID } },
            { datasource: application.datasource }
        );
        return valueArray(rows, "intCustomerID");
    }

}
