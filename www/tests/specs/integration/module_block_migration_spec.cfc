component extends="tests.support.integration_spec" {
    variables.migrationFile = "/var/saaster/db/core/V31__customer-module-blocks.sql";

    function run() {
        describe("Repeatable customer module block migration", () => {
            beforeEach(() => {
                variables.original = translation();
                variables.oldDE = "Das Modul ist für diesen Kunden gesperrt. Abrechnung und Laufzeit laufen weiter.";
                variables.oldEN = "The module is blocked for this customer. Billing and the subscription period continue.";
                variables.newDE = "Ihr Zugriff auf dieses Modul wurde gesperrt. Ihr Abonnement bleibt bestehen; Abrechnung und Laufzeit laufen weiter.";
                variables.newEN = "Your access to this module has been blocked. Your subscription remains in place; billing and the subscription period continue.";
            });

            afterEach(() => {
                setTranslation(variables.original.strStringDE, variables.original.strStringEN);
            });

            it("corrects old defaults on repeated runs while preserving existing blocks", () => {
                local.customer = variables.fixtures.createCustomer();
                local.actor = variables.fixtures.createUser(customerID=local.customer, sysAdmin=true);
                local.module = variables.fixtures.createModule();
                local.params = {
                    customer: {type: "integer", value: local.customer},
                    module: {type: "integer", value: local.module},
                    actor: {type: "integer", value: local.actor.userID}
                };
                queryExecute(options={datasource:application.datasource}, params=local.params,
                    sql="INSERT INTO customer_module_blocks (intCustomerID, intModuleID, intActorUserID, dtmBlockedAt)
                        VALUES (:customer, :module, :actor, '2026-01-02 03:04:05')");
                setTranslation(variables.oldDE, variables.oldEN);

                runMigration();
                runMigration();

                local.text = translation();
                expect(local.text.strStringDE).toBe(variables.newDE);
                expect(local.text.strStringEN).toBe(variables.newEN);
                local.block = queryExecute(options={datasource:application.datasource},
                    params={customer:{type:"integer",value:local.customer}},
                    sql="SELECT * FROM customer_module_blocks WHERE intCustomerID = :customer");
                expect(local.block.recordCount).toBe(1);
                expect(local.block.intModuleID).toBe(local.module);
                expect(local.block.intActorUserID).toBe(local.actor.userID);
                expect(local.block.dtmBlockedAt).toBe(createDateTime(2026, 1, 2, 3, 4, 5));
            });

            it("preserves customized wording separately for each language", () => {
                setTranslation("Individuelle Sperrmeldung", variables.oldEN);
                runMigration();
                runMigration();
                local.text = translation();
                expect(local.text.strStringDE).toBe("Individuelle Sperrmeldung");
                expect(local.text.strStringEN).toBe(variables.newEN);

                setTranslation(variables.oldDE, "Custom block message");
                runMigration();
                runMigration();
                local.text = translation();
                expect(local.text.strStringDE).toBe(variables.newDE);
                expect(local.text.strStringEN).toBe("Custom block message");
            });
        });
    }

    private query function translation() {
        return queryExecute(options={datasource:application.datasource}, params={},
            sql="SELECT strStringDE, strStringEN FROM system_translations WHERE strVariable = 'msgModuleBlocked'");
    }

    private void function setTranslation(required string german, required string english) {
        queryExecute(options={datasource:application.datasource},
            params={german:{type:"string",value:arguments.german}, english:{type:"string",value:arguments.english}},
            sql="UPDATE system_translations SET strStringDE = :german, strStringEN = :english WHERE strVariable = 'msgModuleBlocked'");
    }

    private void function runMigration() {
        // This migration ends statements at line boundaries; text contains inline semicolons.
        local.statement = "";
        local.count = 0;
        loop array=listToArray(replace(fileRead(variables.migrationFile, "utf-8"), chr(13), "", "all"), chr(10)) item="local.line" {
            if (reFind("^\s*--", local.line)) { continue; }
            local.statement &= local.line & chr(10);
            if (right(trim(local.line), 1) eq ";") {
                queryExecute(options={datasource:application.datasource}, params={}, sql=local.statement);
                local.statement = "";
                local.count++;
            }
        }
        expect(trim(local.statement)).toBe("");
        expect(local.count).toBe(5);
    }
}
