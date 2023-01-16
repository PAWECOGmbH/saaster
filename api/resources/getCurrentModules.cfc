
component extends="taffy.core.resource" taffy_uri="/getcurrentModules/{customerID}" {

    function get(required numeric customerID, numeric lngID, string language, numeric currencyID) {

        param name="arguments.lngID" default=0;
        param name="arguments.language" default="";
        param name="arguments.currencyID" default=0;

        local.qGetModules = new com.modules(
            arguments.lngID,
            arguments.language,
            arguments.currencyID).getBookedModules(arguments.customerID);

        return rep(local.qGetModules);

    }

}