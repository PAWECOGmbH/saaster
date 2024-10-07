component displayname="init" output="false" {

    // Default variables
    variables.argsReturnValue = structNew();
    variables.argsReturnValue['message'] = "";
    variables.argsReturnValue['success'] = false;

    function cleanUpTrumbowyg(required string input) {

        local.desc = arguments.input;
        local.deniedChars = ["&lt;script", "&lt;cf", "&lt;iframe", "&lt;a"];
        local.cleanedDesc = local.desc;

        for (local.deniedChar in local.deniedChars) {
            local.cleanedDesc = replaceNoCase(local.cleanedDesc, local.deniedChar, "<invalidTag", "all");
        }

        return local.cleanedDesc;

    }


    private void function addHistory(
        required numeric adID,
        required string description,
        required numeric customerID,
        required numeric userID) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                userID: {type: "numeric", value: arguments.userID},
                adID: {type: "numeric", value: arguments.adID},
                description: {type: "nvarchar", value: application.objGlobal.cleanUpText(arguments.description, 250)},
                dateNow: {type: "datetime", value=now()}
            },
            sql = "
                INSERT INTO ss_ads_history (intAdID, intCustomerID, intUserID, dtmProcessDate, strDescription)
                VALUES (:adID, :customerID, :userID, :dateNow, :description)
            "
        );

    }

}