
component displayname="settings" output="false" {

    // Init for the requested language
    public any function init(string language) {

        variables.language = application.objLanguage.getDefaultLanguage().iso;
        if (structKeyExists(arguments, "language")) {
            variables.language = arguments.language;
        }

        variables.lngID = application.objLanguage.getAnyLanguage(variables.language).lngID;

        return this;

    }


    // Initialising the system setting variables
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


    // Get all the custom setting variables
    public array function getCustomSettings() {

        local.settingArray = arrayNew(1);
        local.settingStruct = structNew();

        local.qSettings = queryExecute(
            options = {datasource = application.datasource},
            params = {
                lngID: {type: "numeric", value: variables.lngID}
            },
            sql = "
                SELECT strSettingVariable,
                IF(
                    LENGTH(
                        (
                            SELECT strDefaultValue
                            FROM custom_settings_trans
                            WHERE intCustomSettingID = custom_settings.intCustomSettingID
                            AND intLanguageID = :lngID
                        )
                    ),
                    (
                        SELECT strDefaultValue
                        FROM custom_settings_trans
                        WHERE intCustomSettingID = custom_settings.intCustomSettingID
                        AND intLanguageID = :lngID
                    ),
                    custom_settings.strDefaultValue
                ) as strDefaultValue,
                IF(
                    LENGTH(
                        (
                            SELECT strDescription
                            FROM custom_settings_trans
                            WHERE intCustomSettingID = custom_settings.intCustomSettingID
                            AND intLanguageID = :lngID
                        )
                    ),
                    (
                        SELECT strDescription
                        FROM custom_settings_trans
                        WHERE intCustomSettingID = custom_settings.intCustomSettingID
                        AND intLanguageID = :lngID
                    ),
                    custom_settings.strDescription
                ) as strDescription
                FROM custom_settings

            "
        )

        loop query="local.qSettings" {

            local.settingStruct['variable'] = local.qSettings.strSettingVariable;
            local.settingStruct['defaultValue'] = local.qSettings.strDefaultValue;
            local.settingStruct['description'] = local.qSettings.strDescription;
            arrayAppend(local.settingArray, local.settingStruct);

        }

        return local.settingArray;

    }


    // Get the value of a system setting as well as of a plan setting using a variable (and planID if desired)
    public string function getSetting(required string settingVariable, numeric planID) {

        if (structKeyExists(arguments, "planID") and isNumeric(arguments.planID)) {

            local.qPlanValue = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    planID: {type: "numeric", value: arguments.planID},
                    variable_name: {type: "string", value: arguments.settingVariable},
                    lngID: {type: "numeric", value: variables.lngID}
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


    // Get the setting of a customer using a variable
    public string function getCustomerSetting(required string settingVariable, required numeric customerID) {

        local.custSetting;

        local.qSettings = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                variable_name: {type: "string", value: arguments.settingVariable}
            },
            sql = "
                SELECT
                IF(
                    LENGTH(
                        (
                            SELECT strSettingValue
                            FROM customer_custom_settings
                            WHERE intCustomSettingID = custom_settings.intCustomSettingID
                            AND intCustomerID = :customerID
                        )
                    ),
                    (
                        SELECT strSettingValue
                        FROM customer_custom_settings
                        WHERE intCustomSettingID = custom_settings.intCustomSettingID
                        AND intCustomerID = :customerID
                    ),
                    custom_settings.strDefaultValue
                ) as strSettingValue
                FROM custom_settings
                WHERE strSettingVariable = :variable_name
            "
        )

        if (local.qSettings.recordCount) {
            local.custSetting = local.qSettings.strSettingValue;
        }

        return local.custSetting;

    }




}