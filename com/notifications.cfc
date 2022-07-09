
component displayname="notifications" output="false" {

    <!--- Create a notification entry --->
    public struct function insertNotification(required struct notiStruct) {

        <!--- Default variables --->
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (structKeyExists(arguments.notiStruct, "customerID") and isNumeric(arguments.notiStruct.customerID)) {
            local.customerID = arguments.notiStruct.customerID;
        } else {
            local.argsReturnValue['message'] = "No customerID found!";
            return local.argsReturnValue;
        }
        if (structKeyExists(arguments.notiStruct, "userID") and isNumeric(arguments.notiStruct.userID)) {
            local.userID = arguments.notiStruct.userID;
        } else {
            local.argsReturnValue['message'] = "No userID found!";
            return local.argsReturnValue;
        }

        if (structKeyExists(arguments.notiStruct, "title") and (len(trim(arguments.notiStruct.title)))) {
            local.title = left((trim(arguments.notiStruct.title)), 100);
        } else {
            local.title = "no title";
        }
        if (structKeyExists(arguments.notiStruct, "description") and (len(trim(arguments.notiStruct.description)))) {
            local.description = trim(arguments.notiStruct.description);
        } else {
            local.description = "no description";
        }
        if (structKeyExists(arguments.notiStruct, "link") and (len(trim(arguments.notiStruct.link)))) {
            local.link = left(trim(arguments.notiStruct.link), 255);
        } else {
            local.link = "";
        }

        try {

            queryExecute(
                options = {datasource=application.datasource, result="local.newID"},
                params = {
                    customerID: {type: "numeric", value: local.customerID},
                    userID: {type: "numeric", value: local.userID},
                    title: {type: "nvarchar", value: local.title},
                    description: {type: "nvarchar", value: local.description},
                    link: {type: "nvarchar", value: local.link},
                    dateNow: {type: "datetime", value: now()}
                },
                sql = "
                    INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitle, strDescription, strLink, dtmRead)
                    VALUES (:customerID, :userID, :dateNow, :title, :description, :link, NULL)
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