component displayname="notifications" output="false" {

    param name="notiStruct" required="false" type="any";
    param name="customerID" required="false" type="any";
    param name="userID" required="false" type="any";

    // Create a notification entry
    public struct function insertNotification(required struct notiStruct) {

        // Default variables
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        local.userID = 0;
        local.title_var = "";
        local.descr_var = "";
        local.link = "";
        local.linktext_var = "";

        if (structKeyExists(arguments.notiStruct, "customerID") and isNumeric(arguments.notiStruct.customerID)) {
            local.customerID = arguments.notiStruct.customerID;
        } else {
            local.argsReturnValue['message'] = "No customerID found!";
            return local.argsReturnValue;
        }
        if (structKeyExists(arguments.notiStruct, "userID") and isNumeric(arguments.notiStruct.userID)) {
            local.userID = arguments.notiStruct.userID;
        }
        if (structKeyExists(arguments.notiStruct, "title_var") and (len(trim(arguments.notiStruct.title_var)))) {
            local.title_var = left((trim(arguments.notiStruct.title_var)), 50);
        }
        if (structKeyExists(arguments.notiStruct, "descr_var") and (len(trim(arguments.notiStruct.descr_var)))) {
            local.descr_var = left((trim(arguments.notiStruct.descr_var)), 50);
        }
        if (structKeyExists(arguments.notiStruct, "link") and (len(trim(arguments.notiStruct.link)))) {
            local.link = left(trim(arguments.notiStruct.link), 255);
        }
        if (structKeyExists(arguments.notiStruct, "linktext_var") and (len(trim(arguments.notiStruct.linktext_var)))) {
            local.linktext_var = left((trim(arguments.notiStruct.linktext_var)), 50);
        }

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

    /* Get Notification Position for nav notifications and pagination */

    public any function getNotificationPos(notificationID){
        local.qNotificationTillPos = queryExecute(
                options = {datasource=application.datasource},
                params = {
                    notificationID: {type: "numeric", value: arguments.notificationID}                    
                },

                sql ="
                SELECT COUNT(intNotificationID) as intNotificationPos
                FROM notifications
                WHERE intNotificationID >= :notificationID;
            "  
        )

        local.notification_page = ceiling(local.qNotificationTillPos.intNotificationPos/10);
        return local.notification_page;
    }


    /* get notifications from DB entrys  */

    public any function getNotifications(required numeric customerID, numeric userID){

        if(structKeyExists(arguments, "userID") and structKeyExists(arguments, "customerID")){
            local.customer_ID = arguments.customerID;
            local.user_ID = arguments.userID;

            local.qGetNotificationsByDte = queryExecute(
                options = {datasource=application.datasource, returntype="array"},
                params = {
                    customerID: {type: "numeric", value: local.customer_ID},
                    userID: {type: "numeric", value: local.user_ID}
                },
                sql ="
                    SELECT * 
                    FROM notifications
                    WHERE
                    (dtmRead IS NULL) AND
                    (intUserID = :userID
                    AND intCustomerID = :customerID)
                    ORDER BY dtmCreated DESC;
                "  
            )

        }else if(structKeyExists(arguments, "customerID")){
            local.customer_ID = arguments.customerID;

            local.qGetNotificationsByDte = queryExecute(
                options = {datasource=application.datasource, returntype="array"},
                params = {
                    customerID: {type: "numeric", value: local.customer_ID},
                    userID: {type: "numeric", value: local.user_ID}
                },
                sql ="
                    SELECT * 
                    FROM notifications
                    WHERE (dtmRead IS NULL) AND
                    (intCustomerID = :customerID)
                    ORDER BY dtmCreated DESC;
                "
            )
        }
       getNotifications = local.qGetNotificationsByDte;
       return getNotifications;
    }

    /* get ALL Notifications */
    public any function getAllNotifications(required numeric customerID, numeric userID){

        if(structKeyExists(arguments, "userID") and structKeyExists(arguments, "customerID")){
            local.customer_ID = arguments.customerID;
            local.user_ID = arguments.userID;

            local.qGetNotificationsByDte = queryExecute(
                options = {datasource=application.datasource, returntype="array"},
                params = {
                    customerID: {type: "numeric", value: local.customer_ID},
                    userID: {type: "numeric", value: local.user_ID}
                },
                sql ="
                    SELECT * 
                    FROM notifications
                    WHERE
                    (intUserID = :userID
                    AND intCustomerID = :customerID)
                    ORDER BY dtmCreated DESC;
                "
            )

        }else if(structKeyExists(arguments, "customerID")){
            local.customer_ID = arguments.customerID;

            local.qGetNotificationsByDte = queryExecute(
                options = {datasource=application.datasource, returntype="array"},
                params = {
                    customerID: {type: "numeric", value: local.customer_ID},
                    userID: {type: "numeric", value: local.user_ID}
                },
                sql ="
                    SELECT * 
                    FROM notifications
                    (intCustomerID = :customerID)
                    ORDER BY dtmCreated DESC;
                "
            )
        }
       getNotifications = local.qGetNotificationsByDte;
       return getNotifications;
    }
    /* Update Notifications Read */
    public any function updateReadNotifications(required numeric notificationID){

        if(structKeyExists(arguments, "notificationID")){
            local.notificationID = arguments.notificationID;
            local.qUpdateNotificationRead = queryExecute(
                options = {datasource=application.datasource, returntype="array"},
                params = {
                    qnotificationID: {type: "numeric", value: local.notificationID},
                    dateTime: {type: "datetime", value: now()}
                },
                sql ="
                    UPDATE notifications
                    SET dtmRead = :dateTime
                    WHERE intNotificationID = :qnotificationID;
                "
            )
        }
    }
    /* Delete Notifications Read */
    public void function deleteNotifications(required numeric notificationID){

        if(structKeyExists(arguments, "notificationID")){
            local.notificationID = arguments.notificationID;
            local.qDeleteNotification = queryExecute(
                options = {datasource=application.datasource},
                params = {
                    qnotificationID: {type: "numeric", value: local.notificationID}
                },
                sql ="
                    DELETE FROM notifications 
                    WHERE intNotificationID = :qnotificationID;
                "
            )
        }
    }
    /* Delete Multiple Notifications */
    public any function deleteMultipleNotifications(required string singleNotificationIDs){
        local.strCheckBoxID = arguments.singleNotificationIDs;
        local.qDeleteMultipleNotifications = queryExecute(
            options = {datasource=application.datasource},
            params = {
                qnotificationIDs: {type: "string",list="yes", value: local.strCheckBoxID}
            },
            sql ="
                DELETE FROM notifications 
                WHERE intNotificationID IN (:qnotificationIDs);
            "
        )
       return;
    }
}