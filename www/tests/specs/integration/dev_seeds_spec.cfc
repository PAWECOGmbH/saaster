component extends="tests.support.integration_spec" {

    /*
        The demo data seeds in config/db/dev - imported into the test database, checked and
        removed again.

        The seeds are data only: the tables come from the migrations. A migration that
        renames or adds a required column breaks a seed - this spec turns red then, instead
        of a developer finding out on import. Before, the seeds recreated the tables
        themselves and silently undid migrations (e.g. V24 on plans_trans).

        Reads the files from /var/saaster/db (read-only mount of config/db in compose-dev.yml);
        skipped without the mount.
    */

    variables.seedFolder = "/var/saaster/db/dev/";
    variables.seedOrder = ["create-plans", "create-modules", "create-widgets", "create-customers", "create-notifications"];
    variables.demoPassword = "Saaster-Demo-2026!";

    function run() {

        describe(title = "Demo data seeds (config/db/dev)", skip = !directoryExists(variables.seedFolder), body = () => {

            beforeEach(() => {
                // Once, before the first import: a failing import in beforeEach skips afterEach
                if (!structKeyExists(variables, "activeCurrencies")) variables.activeCurrencies = valueList(queryExecute("SELECT strCurrencyISO FROM currencies WHERE blnActive = 1", {}, { datasource: application.datasource }).strCurrencyISO);
                importSeeds();
            });

            afterEach(() => {
                removeSeeds();
            });

            it("import into a database built by the migrations", () => {
                expect(count("plans WHERE intPlanID BETWEEN 1 AND 4")).toBe(4);
                expect(count("plans_plan_features WHERE intPlanID BETWEEN 1 AND 4")).toBe(40);
                expect(count("plan_prices WHERE intPlanID BETWEEN 1 AND 4")).toBe(12);
                expect(count("modules WHERE intModuleID BETWEEN 1 AND 3")).toBe(3);
                expect(count("widgets WHERE intWidgetID BETWEEN 1 AND 5")).toBe(5);
                expect(count("customers WHERE intCustomerID BETWEEN 1001 AND 1099")).toBe(12);
                expect(count("users WHERE intUserID BETWEEN 1001 AND 1099")).toBe(16);
                expect(count("bookings WHERE intBookingID BETWEEN 1001 AND 1099")).toBe(15);
                expect(count("invoices WHERE intInvoiceID BETWEEN 1001 AND 1099")).toBe(11);
            });

            it("can be imported again without duplicates", () => {
                importSeeds();

                expect(count("plans_plan_features_trans WHERE intPlansPlanFeatID BETWEEN 1 AND 40")).toBe(7);
                expect(count("plans_trans WHERE intPlanID BETWEEN 1 AND 4")).toBe(4);
                expect(count("modules_prices WHERE intModuleID BETWEEN 1 AND 3")).toBe(3 * count("currencies WHERE blnActive = 1"));
                expect(count("customer_user WHERE intUserID BETWEEN 1001 AND 1099")).toBe(19);
                expect(count("notifications WHERE intCustomerID BETWEEN 1001 AND 1099")).toBe(6);
            });

            it("leave no assignment without its plan, feature, module or customer", () => {
                expect(count("plans_plan_features ppf LEFT JOIN plans p ON p.intPlanID = ppf.intPlanID LEFT JOIN plan_features f ON f.intPlanFeatureID = ppf.intPlanFeatureID WHERE p.intPlanID IS NULL OR f.intPlanFeatureID IS NULL")).toBe(0);
                expect(count("plans_plan_features_trans t LEFT JOIN plans_plan_features ppf ON ppf.intPlansPlanFeatID = t.intPlansPlanFeatID WHERE ppf.intPlansPlanFeatID IS NULL")).toBe(0);
                expect(count("bookings b LEFT JOIN plans p ON p.intPlanID = b.intPlanID LEFT JOIN modules m ON m.intModuleID = b.intModuleID WHERE b.intBookingID BETWEEN 1001 AND 1099 AND ((b.intPlanID IS NOT NULL AND p.intPlanID IS NULL) OR (b.intModuleID IS NOT NULL AND m.intModuleID IS NULL))")).toBe(0);
            });

            it("give every invoice consistent amounts: positions, VAT and payments", () => {
                var invoices = queryExecute("
                    SELECT i.intInvoiceNumber, i.blnIsNet, i.intVatType, i.decSubTotalPrice, i.decTotalPrice, i.intPaymentStatusID,
                           (SELECT SUM(decTotalPrice) FROM invoice_positions WHERE intInvoiceID = i.intInvoiceID) AS positions,
                           (SELECT IFNULL(SUM(decVatAmount), 0) FROM invoice_vat WHERE intInvoiceID = i.intInvoiceID) AS vat,
                           (SELECT IFNULL(SUM(decAmount), 0) FROM payments WHERE intInvoiceID = i.intInvoiceID) AS paid
                    FROM invoices i WHERE i.intInvoiceID BETWEEN 1001 AND 1099
                ", {}, { datasource: application.datasource });

                loop query=invoices {
                    var label = "INV-" & invoices.intInvoiceNumber;
                    expect(invoices.positions).toBe(invoices.decSubTotalPrice, label & ": positions");
                    var expectedTotal = (invoices.intVatType eq 1 and invoices.blnIsNet) ? invoices.decSubTotalPrice + invoices.vat : invoices.decSubTotalPrice;
                    expect(invoices.decTotalPrice).toBe(expectedTotal, label & ": total");
                    if (invoices.intPaymentStatusID eq 3) {
                        expect(invoices.paid).toBe(invoices.decTotalPrice, label & ": paid in full");
                    } else if (invoices.intPaymentStatusID eq 4) {
                        expect(invoices.paid).toBeGT(0, label & ": partly paid");
                        expect(invoices.paid).toBeLT(invoices.decTotalPrice, label & ": partly paid");
                    } else {
                        expect(invoices.paid).toBe(0, label & ": nothing paid");
                    }
                }
            });

            it("let the active demo users log in with the documented password, and refuse the inactive ones", () => {
                var users = queryExecute("
                    SELECT users.strEmail, users.blnActive AND customers.blnActive AS canLogin
                    FROM users INNER JOIN customers ON customers.intCustomerID = users.intCustomerID
                    WHERE users.intUserID BETWEEN 1001 AND 1099
                ", {}, { datasource: application.datasource });

                var refused = [];
                loop query=users {
                    var result = new frontend.core.com.login().checkLogin(email = users.strEmail, password = variables.demoPassword);
                    if (users.canLogin) {
                        expect(result.loginCorrect).toBeTrue(users.strEmail);
                    } else {
                        expect(result.loginCorrect ?: false).toBeFalse(users.strEmail & " is inactive");
                        arrayAppend(refused, users.strEmail);
                    }
                }
                // Clara Hoffmann (inactive user) and Grace Miller (inactive customer)
                expect(arrayLen(refused)).toBe(2);
            });

            it("deletes an own tenant with all shipped demo modules registered for owners and Sysadmins", () => {
                recordLogs();
                local.lifecycle = new backend.core.com.account_lifecycle();
                local.password = "Seed-deletion-test-123!";
                loop array=[false, true] item="local.sysadmin" {
                    local.parent = variables.fixtures.createCustomer();
                    local.tenant = variables.fixtures.createCustomer(parentID=local.parent);
                    local.actor = variables.fixtures.createUser(customerID=local.parent, superAdmin=true, sysAdmin=local.sysadmin,
                        passwordHash=application.objGlobal.hashPassword(local.password));
                    variables.fixtures.grantTenant(local.actor.userID, local.tenant);
                    variables.fixtures.createBooking(customerID=local.tenant, moduleID=3, status="active");
                    loginAs(local.actor);
                    local.operation = local.lifecycle.beginOperation(local.parent, "request");
                    request.accountOperation = local.operation;
                    try {
                        local.result = local.lifecycle.submitDeletion(local.actor.userID, local.tenant, local.password);
                        expect(local.result.success).toBeTrue(serializeJSON(variables.logRecorder.getCalls()));
                        expect(local.lifecycle.deletionState(local.tenant).status).toBe("completed");
                        local.remaining = queryExecute(options={datasource:application.datasource},
                            params={tenant:{type:"integer",value:local.tenant},parent:{type:"integer",value:local.parent}},
                            sql="SELECT (SELECT COUNT(*) FROM customers WHERE intCustomerID = :tenant) AS tenants,
                                (SELECT COUNT(*) FROM bookings WHERE intCustomerID = :tenant) AS bookings,
                                (SELECT blnActive FROM customers WHERE intCustomerID = :parent) AS parentActive");
                        expect(local.remaining.tenants).toBe(0);
                        expect(local.remaining.bookings).toBe(0);
                        expect(local.remaining.parentActive).toBe(1);
                        expect(local.lifecycle.hasOperations(local.parent)).toBeTrue();
                        expect(count("modules WHERE intModuleID BETWEEN 1 AND 3")).toBe(3);
                    } finally {
                        local.lifecycle.finishOperation(local.operation);
                        structDelete(request, "accountOperation");
                        logout();
                    }
                }
            });

            it("give every active demo customer a super admin", () => {
                expect(count("customers c WHERE c.intCustomerID BETWEEN 1001 AND 1099 AND c.blnActive = 1 AND c.intCustParentID = 0 AND NOT EXISTS (SELECT 1 FROM users u WHERE u.intCustomerID = c.intCustomerID AND u.blnSuperAdmin = 1)")).toBe(0);
            });

        });

    }

    // Imports every seed file in its order, the way the mysql client does (allowMultiQueries)
    private void function importSeeds() {
        for (var name in variables.seedOrder) {
            // Comment lines out: the mysql client drops them, but through JDBC a "-- comment" inside a
            // multi-line INSERT would swallow the rest of the statement
            var sql = arrayToList(
                listToArray(replace(fileRead(variables.seedFolder & name & ".sql", "utf-8"), chr(13), "", "all"), chr(10), true)
                    .filter((line) => !reFind("^\s*--", line)),
                chr(10)
            );
            try {
                queryExecute(sql, {}, { datasource: application.datasource });
            } catch (any e) {
                fail("config/db/dev/" & name & ".sql does not import: " & e.message & " " & (e.detail ?: ""));
            }
        }
    }

    // Removes the demo data again and restores the active currencies
    private void function removeSeeds() {
        var statements = [
            "DELETE d FROM invoice_documents d INNER JOIN invoices i ON i.intInvoiceID = d.intInvoiceID WHERE i.intCustomerID BETWEEN 1001 AND 1099 OR d.intOriginalCustomerID BETWEEN 1001 AND 1099",
            "DELETE FROM invoices WHERE intCustomerID BETWEEN 1001 AND 1099",
            "DELETE FROM customers WHERE intCustomerID BETWEEN 1001 AND 1099 AND intCustParentID > 0",
            "DELETE FROM customers WHERE intCustomerID BETWEEN 1001 AND 1099",
            "DELETE FROM widgets WHERE intWidgetID BETWEEN 1 AND 5",
            "DELETE FROM modules WHERE intModuleID BETWEEN 1 AND 3",
            "DELETE FROM plans_plan_features_trans WHERE intPlansPlanFeatID BETWEEN 1 AND 40",
            "DELETE FROM plans WHERE intPlanID BETWEEN 1 AND 4",
            "DELETE FROM plan_groups WHERE intPlanGroupID = 1",
            "DELETE FROM plan_features WHERE intPlanFeatureID BETWEEN 1 AND 13"
        ];
        for (var statement in statements) {
            queryExecute(statement, {}, { datasource: application.datasource });
        }
        queryExecute(
            "UPDATE currencies SET blnActive = IF(FIND_IN_SET(strCurrencyISO, :active) > 0, 1, 0)",
            { active: { type: "varchar", value: variables.activeCurrencies } },
            { datasource: application.datasource }
        );
    }

    private numeric function count(required string fromWhere) {
        return queryExecute("SELECT COUNT(*) AS cnt FROM " & arguments.fromWhere, {}, { datasource: application.datasource }).cnt;
    }

}
