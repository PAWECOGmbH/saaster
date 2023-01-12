
component extends="taffy.core.resource" taffy_uri="/getcurrentPlan/{customerID}" {

    function get(required numeric customerID, numeric lngID, string language, numeric currencyID) {

        param name="arguments.lngID" default=0;
        param name="arguments.language" default="";
        param name="arguments.currencyID" default=0;

        local.qGetPlan = new com.plans(
            arguments.lngID,
            arguments.language,
            arguments.currencyID).getCurrentPlan(arguments.customerID);

        return rep(local.qGetPlan);

    }

}