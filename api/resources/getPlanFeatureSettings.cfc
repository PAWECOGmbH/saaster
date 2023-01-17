
component extends="taffy.core.resource" taffy_uri="/getPlanFeatureSettings/{settingVariable}/{planID}" {

    function get(required string settingVariable, required numeric planID) {
        
        arguments.settingVariable = ""
        arguments.planID = 0
        arguments.language = request._taffyrequest.headers.language ?: ""

        local.qGetPlanFeatureSettings = new com.settings().getSetting(arguments.settingVariable, arguments.planID, arguments.language);

        return rep(local.qGetPlanFeatureSettings);
    }

}