
component displayname="settings" output="false" {


    // Initialising the system setting variables in order to save it into the application scope
    public struct function initSystemSettings() {

        local.settingStruct = structNew();

        local.qSettings = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT strSettingVariable, strDefaultValue
                FROM system_settings
            "
        )

        loop query="local.qSettings" {
            local.settingStruct[local.qSettings.strSettingVariable] = local.qSettings.strDefaultValue;
        }

        return local.settingStruct;

    }


    // Get the value of a system setting as well as of a plan setting using a variable (and planID if desired)
    public string function getSetting(required string settingVariable, numeric planID, string language) {

        if (structKeyExists(arguments, "language")) {
            local.lngID = application.objLanguage.getAnyLanguage(arguments.language).lngID;
        } else {
            local.lngID = application.objLanguage.getDefaultLanguage().lngID;
        }

        if (structKeyExists(arguments, "planID") and isNumeric(arguments.planID)) {

            local.qPlanValue = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    planID: {type: "numeric", value: arguments.planID},
                    variable_name: {type: "string", value: arguments.settingVariable},
                    lngID: {type: "numeric", value: local.lngID}
                },
                sql = "
                    SELECT plans_plan_features.blnCheckmark,
                    IF(
                        LENGTH(
                            (
                                SELECT strValue
                                FROM plans_plan_features_trans
                                WHERE intPlansPlanFeatID = plans_plan_features.intPlansPlanFeatID
                                AND intLanguageID = :lngID
                            )
                        ),
                        (
                            SELECT strValue
                            FROM plans_plan_features_trans
                            WHERE intPlansPlanFeatID = plans_plan_features.intPlansPlanFeatID
                            AND intLanguageID = :lngID
                        ),
                        plans_plan_features.strValue
                    ) as strValue
                    FROM plan_features
                    INNER JOIN plans_plan_features
                    ON plan_features.intPlanFeatureID = plans_plan_features.intPlanFeatureID
                    WHERE plans_plan_features.intPlanID = :planID
                    AND plan_features.strVariable = :variable_name
                "
            )

            if (local.qPlanValue.recordcount) {

                if (len(trim(local.qPlanValue.strValue))) {
                    local.valueString = local.qPlanValue.strValue;
                } else {
                    local.valueString = trueFalseFormat(local.qPlanValue.blnCheckmark);
                }

            } else {

                local.valueString = "";

            }


        } else {

            if (structKeyExists(application.systemSettingStruct, arguments.settingVariable)) {
                local.valueString = structFindKey(application.systemSettingStruct, arguments.settingVariable, "one");
            } else {
                local.valueString = "";
            }

        }

        if (isArray(local.valueString) and arrayLen(local.valueString) gte 1) {
            local.valueString = local.valueString[1].value;
        }

        return local.valueString;

    }


    // This code generates an SQL script that formats all entries from the given table
    public string function generateSqlCode(required string sqlTable, required string primKey) {

        // Check if the table exists
        local.checkSqlTable = queryExecute(
            options = {datasource = application.datasource},
            params = {
                table_name: {type: "string", value: arguments.sqlTable}
            },
            sql = "
                SELECT COUNT(*) as cnt
                FROM information_schema.tables
                WHERE table_name = :table_name
            "
        )

        if (local.checkSqlTable.cnt gt 0) {

            local.getEntries = queryExecute(
                options = {datasource = application.datasource},
                sql = "
                    SELECT *
                    FROM #arguments.sqlTable#
                "
            )

            if (local.getEntries.recordCount) {

                // Get column list and remove the first entry
                local.columns = local.getEntries.columnList;
                local.columnsArray = listToArray(local.columns, ",");
                arrayDeleteAt(local.columnsArray, 1); // Removes the first entry

                // Create the filtered list of columns
                local.filteredColumns = arrayToList(local.columnsArray, ", ");

                // Generate the SQL statement
                local.sqlOutput = "INSERT INTO #arguments.sqlTable# (" & local.filteredColumns & ") VALUES" & chr(10);

                // Collect values
                local.values = [];
                for (local.row in local.getEntries) {
                    local.valueRow = [];
                    for (local.column in local.columnsArray) {
                        local.value = "'" & replace(local.row[local.column], "'", "''", "all") & "'"; // Escaping
                        arrayAppend(local.valueRow, local.value);
                    }
                    arrayAppend(local.values, "(" & arrayToList(local.valueRow, ", ") & ")");
                }
                local.sqlOutput &= arrayToList(local.values, "," & chr(10)) & chr(10);

                // ON DUPLICATE KEY UPDATE Logic
                local.updateClauses = [];
                for (local.column in local.columnsArray) {
                    if (local.column NEQ arguments.primKey) { // Exclude primary key
                        arrayAppend(local.updateClauses, local.column & " = VALUES(" & local.column & ")");
                    }
                }
                local.sqlOutput &= "ON DUPLICATE KEY UPDATE " & chr(10) & arrayToList(local.updateClauses, "," & chr(10)) & ";";

                // Return with textarea
                return '
                    <textarea style="width: 100%; height: 800px;" readonly>' &
                    local.sqlOutput &
                    '</textarea>';

            } else {

                return "No entries in table " & arguments.sqlTable;

            }



        } else {

            return "No table found!"

        }




    }

}