
component extends="taffy.core.resource" taffy_uri="/getcurrentPlan/{customerID}" {

    function get(required numeric customerID, numeric lngID, string language, numeric currencyID) {

        arguments.language = request._taffyrequest.headers.language ?: ""
        arguments.lngID = request._taffyrequest.headers.lngID ?: 0
        arguments.currencyID = request._taffyrequest.headers.currencyID ?: 0

        local.qGetPlan = new com.plans(
            arguments.lngID,
            arguments.language,
            arguments.currencyID).getCurrentPlan(arguments.customerID);

        return rep(local.qGetPlan);

    }

}