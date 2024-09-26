component extends="taffy.core.resource" taffy_uri="/getCurrentPlan" {

    function get() {

        // Required
        local.customerID = request._taffyrequest.headers.CustomerID ?: 0

        // Optional
        local.language = request._taffyrequest.headers.language ?: ""
        local.lngID = request._taffyrequest.headers.lngID ?: 0
        local.currencyID = request._taffyrequest.headers.currencyID ?: 0

        if(local.customerID eq 0){
            return noData().withStatus(400);
        }

        local.qGetPlan = new backend.core.com.plans(
            local.lngID,
            local.language,
            local.currencyID).getCurrentPlan(local.customerID);

        return rep(local.qGetPlan);

    }

}