component extends="taffy.core.resource" taffy_uri="/getPlanFeatureSetting" {

    function get() {

        // Required
        local.settingVariable = request._taffyrequest.headers.settingVariable ?: "";
        local.planID = request._taffyrequest.headers.planID ?: 0;
        
        // Optional
        local.language = request._taffyrequest.headers.language ?: "";
        
        if(local.planID eq 0 or local.settingVariable eq ""){
            return noData().withStatus(400);
        }

        local.qGetPlanFeatureSettings = new backend.core.com.settings().getSetting(local.settingVariable, local.planID, local.language);

        return rep(local.qGetPlanFeatureSettings);
    }

}