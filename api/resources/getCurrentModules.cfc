component extends="taffy.core.resource" taffy_uri="/getcurrentModules/{customerID}" {

    function get(required numeric customerID) {

        arguments.language = request._taffyrequest.headers.language ?: ""
        arguments.lngID = request._taffyrequest.headers.lngID ?: 0
        arguments.currencyID = request._taffyrequest.headers.currencyID ?: 0

        local.qGetModules = new com.modules(
            arguments.lngID,
            arguments.language,
            arguments.currencyID).getBookedModules(arguments.customerID);

        return rep(local.qGetModules);

    }

}