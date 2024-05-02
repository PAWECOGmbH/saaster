component extends="taffy.core.resource" taffy_uri="/getcurrentModules" {

    function get() {

        // Required
        local.customerID = request._taffyrequest.headers.customerID ?: 0

        // Optional
        local.language = request._taffyrequest.headers.language ?: ""
        local.lngID = request._taffyrequest.headers.lngID ?: 0
        local.currencyID = request._taffyrequest.headers.currencyID ?: 0

        if(local.customerID eq 0){
            return noData().withStatus(400);
        }

        local.qGetModules = new backend.core.com.modules(
            local.lngID,
            local.language,
            local.currencyID).getBookedModules(local.customerID);

        return rep(local.qGetModules);

    }

}