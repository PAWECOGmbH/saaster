
component displayname="notifications" output="false" {

    // Create a notification entry
    public struct function insertNotification(required struct notiStruct) {

        // Default variables
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (structKeyExists(arguments.notiStruct, "customerID") and isNumeric(arguments.notiStruct.customerID)) {
            local.customerID = arguments.notiStruct.customerID;
        } else {
            local.argsReturnValue['message'] = "No customerID found!";
            return local.argsReturnValue;
        }

        local.userID = (structKeyExists(arguments.notiStruct, "userID") and isNumeric(arguments.notiStruct.userID) ? arguments.notiStruct.userID : 0);
        local.title_var = (structKeyExists(arguments.notiStruct, "title_var") and (len(trim(arguments.notiStruct.title_var))) ? left((trim(arguments.notiStruct.title_var)), 50) : "");
        local.descr_var = (structKeyExists(arguments.notiStruct, "descr_var") and (len(trim(arguments.notiStruct.descr_var))) ? left((trim(arguments.notiStruct.descr_var)), 50) : "");
        local.link = (structKeyExists(arguments.notiStruct, "link") and (len(trim(arguments.notiStruct.link))) ? left(trim(arguments.notiStruct.link), 255) : "");
        local.linktext_var = (structKeyExists(arguments.notiStruct, "linktext_var") and (len(trim(arguments.notiStruct.linktext_var))) ? left((trim(arguments.notiStruct.linktext_var)), 50) : "");

        try {

            queryExecute(
                options = {datasource=application.datasource, result="local.newID"},
                params = {
                    customerID: {type: "numeric", value: local.customerID},
                    userID: {type: "numeric", value: local.userID},
                    title_var: {type: "nvarchar", value: local.title_var},
                    descr_var: {type: "nvarchar", value: local.descr_var},
                    link: {type: "nvarchar", value: local.link},
                    linktext_var: {type: "nvarchar", value: local.linktext_var},
                    dateNow: {type: "datetime", value: now()}
                },
                sql = "
                    INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitleVar, strDescrVar, strLink, strLinkTextVar)
                    VALUES (:customerID, :userID, :dateNow, :title_var, :descr_var, :link, :linktext_var)
                "
            )

            local.argsReturnValue['newID'] = local.newID.generatedkey;
            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        } catch (any e) {

            local.argsReturnValue['message'] = e.message;

        }

        return local.argsReturnValue;

    }






}