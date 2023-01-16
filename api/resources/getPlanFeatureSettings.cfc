
component extends="taffy.core.resource" taffy_uri="/getPlanFeatureSettings/{settingVariable}/{planID}/{language}" {

    function get(required string settingVariable, required numeric planID, string language) {

        param name="arguments.settingVariable" default="";
        param name="arguments.planID" default=0;
        param name="arguments.language" default=0;

        local.qGetPlanFeatureSettings = new com.settings().getSetting(arguments.settingVariable, arguments.planID, arguments.language);

        return rep(local.qGetPlanFeatureSettings);

    }

}