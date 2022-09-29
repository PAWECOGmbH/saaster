
component displayname="settings" output="false" {


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


    // Get the custom setting variables
    public struct function getCustomSettings(required numeric customerID) {

        local.settingStruct = structNew();

        local.qSettings = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT customer_custom_settings.strSettingValue, custom_settings.strSettingVariable
                FROM customer_custom_settings
                INNER JOIN custom_settings ON customer_custom_settings.intCustomSettingID = custom_settings.intCustomSettingID
                WHERE customer_custom_settings.intCustomerID = :customerID
            "
        )

        loop query="local.qSettings" {
            local.settingStruct[local.qSettings.strSettingVariable] = local.qSettings.strSettingValue;
        }

        return local.settingStruct;

    }


    // Get settings (system settings as well as plan settings)
    public string function getSetting(required string settingVariable, numeric customerID, numeric planID) {

        if (structKeyExists(arguments, "customerID") and isNumeric(arguments.customerID)) {

            if (structKeyExists(session, "customSettings") and structKeyExists(session.customSettings, arguments.settingVariable)) {
                local.valueString = structFindKey(session.customSettings, arguments.settingVariable, "one");
            } else {
                local.valueString = "";
            }

        } else if (structKeyExists(arguments, "planID") and isNumeric(arguments.planID)) {

            local.qPlanValue = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    planID: {type: "numeric", value: arguments.planID},
                    variable_name: {type: "string", value: arguments.settingVariable}
                },
                sql = "
                    SELECT
                        plan_features.strVariable,
                        plans_plan_features.strValue,
                        plans_plan_features.intPlanID,
                        plans_plan_features.blnCheckmark
                    FROM
                        plan_features
                        INNER JOIN
                        plans_plan_features
                        ON
                            plan_features.intPlanFeatureID = plans_plan_features.intPlanFeatureID
                    WHERE
                        plans_plan_features.intPlanID = :planID AND
                        plan_features.strVariable = :variable_name
                "
            );

            if(local.qPlanValue.recordcount){

                if (len(trim(local.qPlanValue.strValue))) {
                    local.valueString = local.qPlanValue.strValue;
                } else {
                    local.valueString = trueFalseFormat(local.qPlanValue.blnCheckmark);
                }

            }else{

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