
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

}