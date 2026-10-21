component extends="tests.support.integration_spec" {

    /*
        Translation modal (translate.cfc::saveTranslation, handler/sysadmin/languages.cfm) - issue #689.

        Regression: translating e.g. the description of a new plan failed with "Field
        'strPlanName' doesn't have a default value". The row of a language is created with
        only the field being translated, and plans_trans, countries_trans and widgets_trans
        had a name column that was NOT NULL without a default (fixed by migration V24).
        The reading queries fall back to the name of the base table while the translated
        name is empty.
    */

    function run() {

        var translate = new backend.core.com.translate();

        describe("Translation modal", () => {

            describe("Schema of the translation tables", () => {

                it("lets the modal create a row with a single field in every _trans table", () => {
                    // Columns a new row cannot leave empty: NOT NULL, no default, not the key, the language or the ID
                    var blocking = queryExecute("
                        SELECT c.TABLE_NAME, c.COLUMN_NAME
                        FROM information_schema.COLUMNS c
                        WHERE c.TABLE_SCHEMA = DATABASE()
                        AND c.TABLE_NAME LIKE '%\_trans'
                        AND c.IS_NULLABLE = 'NO'
                        AND c.COLUMN_DEFAULT IS NULL
                        AND c.EXTRA NOT LIKE '%auto_increment%'
                        AND c.COLUMN_NAME <> 'intLanguageID'
                        AND c.COLUMN_NAME NOT IN (
                            SELECT k.COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE k
                            WHERE k.TABLE_SCHEMA = c.TABLE_SCHEMA AND k.TABLE_NAME = c.TABLE_NAME AND k.REFERENCED_TABLE_NAME IS NOT NULL
                        )
                    ", {}, { datasource: application.datasource });

                    var columns = [];
                    loop query=blocking {
                        arrayAppend(columns, blocking.TABLE_NAME & "." & blocking.COLUMN_NAME);
                    }
                    expect(columns).toBeEmpty("These columns would make the translation modal fail on a new language row");
                });

            });

            describe("saveTranslation", () => {

                it("translates the description of a plan without a translated name (##689)", () => {
                    var planID = variables.fixtures.createPlan();

                    expect(translate.saveTranslation("plans_trans", "intPlanID", "strDescription", planID, "de", "Beschreibung")).toBeTrue();

                    var row = transRow("plans_trans", "intPlanID", planID);
                    expect(row.recordCount).toBe(1);
                    expect(row.strDescription).toBe("Beschreibung");
                });

                it("keeps showing the base name of the plan while its translated name is empty", () => {
                    var planID = variables.fixtures.createPlan();
                    translate.saveTranslation("plans_trans", "intPlanID", "strDescription", planID, "de", "Beschreibung");

                    var name = queryExecute("
                        SELECT IF(
                            LENGTH((SELECT strPlanName FROM plans_trans WHERE intPlanID = plans.intPlanID AND intLanguageID = (SELECT intLanguageID FROM languages WHERE strLanguageISO = 'de'))),
                            (SELECT strPlanName FROM plans_trans WHERE intPlanID = plans.intPlanID AND intLanguageID = (SELECT intLanguageID FROM languages WHERE strLanguageISO = 'de')),
                            plans.strPlanName
                        ) AS planName
                        FROM plans WHERE intPlanID = :planID
                    ", { planID: { type: "numeric", value: planID } }, { datasource: application.datasource });

                    expect(name.planName).toBe("testbox: Plan");
                });

                it("translates a country and a widget without a translated name", () => {
                    queryExecute("INSERT INTO countries (strCountryName, intPrio) VALUES ('testbox: Country', 999)", {}, { datasource: application.datasource, result: "local.country" });
                    queryExecute("INSERT INTO widgets (strWidgetName, strFilePath) VALUES ('testbox: Widget', '/testbox.cfm')", {}, { datasource: application.datasource, result: "local.widget" });

                    try {
                        // Both tables only have the name column; the modal of another field must still work
                        expect(translate.saveTranslation("countries_trans", "intCountryID", "strCountryName", local.country.generatedKey, "de", "Testland")).toBeTrue();
                        expect(translate.saveTranslation("widgets_trans", "intWidgetID", "strWidgetName", local.widget.generatedKey, "de", "Testwidget")).toBeTrue();
                        expect(transRow("countries_trans", "intCountryID", local.country.generatedKey).strCountryName).toBe("Testland");
                    } finally {
                        queryExecute("DELETE FROM countries WHERE intCountryID = :id", { id: { type: "numeric", value: local.country.generatedKey } }, { datasource: application.datasource });
                        queryExecute("DELETE FROM widgets WHERE intWidgetID = :id", { id: { type: "numeric", value: local.widget.generatedKey } }, { datasource: application.datasource });
                    }
                });

                it("updates the row of a language that exists already", () => {
                    var moduleID = variables.fixtures.createModule("Translation");
                    translate.saveTranslation("modules_trans", "intModuleID", "strModuleName", moduleID, "de", "Erste Fassung");

                    translate.saveTranslation("modules_trans", "intModuleID", "strModuleName", moduleID, "de", "Zweite Fassung");

                    var row = transRow("modules_trans", "intModuleID", moduleID);
                    expect(row.recordCount).toBe(1);
                    expect(row.strModuleName).toBe("Zweite Fassung");
                });

                it("refuses unknown tables, columns and languages", () => {
                    var planID = variables.fixtures.createPlan();

                    expect(translate.saveTranslation("plans_trans", "intPlanID", "strNoSuchField", planID, "de", "x")).toBeFalse();
                    expect(translate.saveTranslation("no_such_trans", "intPlanID", "strDescription", planID, "de", "x")).toBeFalse();
                    expect(translate.saveTranslation("plans_trans", "intPlanID", "strDescription", planID, "zz", "x")).toBeFalse();
                    expect(translate.saveTranslation("plans_trans", "intPlanID", "strDescription = 'x', strPlanName", planID, "de", "x")).toBeFalse();
                    expect(transRow("plans_trans", "intPlanID", planID).recordCount).toBe(0);
                });

            });

            describe("Handler (source)", () => {

                it("reads the submitted texts with form[] and never with evaluate()", () => {
                    var source = new tests.support.security_scanner().branchBody("backend/core/handler/sysadmin/languages.cfm", "form", "modal_lng");
                    expect(source).toInclude("saveTranslation(");
                    expect(source).toInclude("form[i]");
                    expect(source).notToInclude("evaluate(");
                });

            });

        });

    }

    private query function transRow(required string table, required string key, required numeric id) {
        return queryExecute(
            "SELECT * FROM #arguments.table# WHERE #arguments.key# = :id AND intLanguageID = (SELECT intLanguageID FROM languages WHERE strLanguageISO = 'de')",
            { id: { type: "numeric", value: arguments.id } },
            { datasource: application.datasource }
        );
    }

}
