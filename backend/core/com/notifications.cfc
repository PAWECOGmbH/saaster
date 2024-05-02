
component displayname="notifications" output="false" {

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


    // Get all notifications
    public struct function getNotifications(required numeric customerID, numeric start, numeric count, boolean read) {

        local.queryLimit;
        local.queryWhere;

        if (structKeyExists(arguments, "count")) {
            local.queryLimit = "LIMIT #arguments.count#";
        }

        if (structKeyExists(arguments, "read")) {
            local.queryWhere = "AND dtmRead IS NULL";
        }

        if (structKeyExists(arguments, "start") and structKeyExists(arguments, "count")) {
            local.queryLimit = "LIMIT #arguments.start#, #arguments.count#";
        }

        local.qTotalCount = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT COUNT(intCustomerID) as totalCount
                FROM notifications
                WHERE intCustomerID = :customerID
            "
        )

        local.notificationStruct = structNew();
        local.notificationStruct['totalCount'] = qTotalCount.totalCount;
        local.notificationStruct['arrayNoti'] = "";

        local.qNotifications = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT *
                FROM notifications
                WHERE intCustomerID = :customerID
                #local.queryWhere#
                ORDER BY dtmCreated DESC
                #local.queryLimit#
            "
        )

        local.arrayNoti = arrayNew(1);

        cfloop(query="local.qNotifications") {

            local.notiStruct = structNew();

            local.notiStruct['notiID'] = local.qNotifications.intNotificationID;
            local.notiStruct['customerID'] = local.qNotifications.intCustomerID;
            local.notiStruct['userID'] = local.qNotifications.intUserID;
            local.notiStruct['created'] = local.qNotifications.dtmCreated;
            local.notiStruct['title_var'] = local.qNotifications.strTitleVar;
            local.notiStruct['desc_var'] = local.qNotifications.strDescrVar;
            local.notiStruct['link'] = local.qNotifications.strLink;
            local.notiStruct['link_text_var'] = local.qNotifications.strLinkTextVar;
            local.notiStruct['read'] = local.qNotifications.dtmRead;

            arrayAppend(local.arrayNoti, local.notiStruct);

        }

        local.notificationStruct['arrayNoti'] = local.arrayNoti;

        return local.notificationStruct;

    }


    // Get notification detail
    public struct function getNotificationDetail(required numeric notiID, required numeric customerID) {

        local.notiStruct = structNew();

        local.qNotification = queryExecute(
            options = {datasource = application.datasource},
            params = {
                notiID: {type: "numeric", value: arguments.notiID},
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT *
                FROM notifications
                WHERE intNotificationID = :notiID
                AND intCustomerID = :customerID

            "
        )

        if (local.qNotification.recordCount) {

            local.notiStruct['notiID'] = local.qNotification.intNotificationID;
            local.notiStruct['customerID'] = local.qNotification.intCustomerID;
            local.notiStruct['userID'] = local.qNotification.intUserID;
            local.notiStruct['created'] = local.qNotification.dtmCreated;
            local.notiStruct['title_var'] = local.qNotification.strTitleVar;
            local.notiStruct['desc_var'] = local.qNotification.strDescrVar;
            local.notiStruct['link'] = local.qNotification.strLink;
            local.notiStruct['link_text_var'] = local.qNotification.strLinkTextVar;
            local.notiStruct['read'] = local.qNotification.dtmRead;

        }

        return local.notiStruct;

    }


    // Get notification detail
    public void function setRead(required numeric notiID, required numeric customerID) {

        local.qNotification = queryExecute(
            options = {datasource = application.datasource, result="test"},
            params = {
                notiID: {type: "numeric", value: arguments.notiID},
                customerID: {type: "numeric", value: arguments.customerID},
                dateNow: {type: "datetime", value: now()}
            },
            sql = "
                UPDATE notifications
                SET dtmRead = :dateNow
                WHERE intNotificationID = :notiID
                AND intCustomerID = :customerID

            "
        )

    }


    // Delete notification
    public void function delNoti(required numeric notiID, required numeric customerID) {

        local.qNotification = queryExecute(
            options = {datasource = application.datasource},
            params = {
                notiID: {type: "numeric", value: arguments.notiID},
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                DELETE FROM notifications
                WHERE intNotificationID = :notiID
                AND intCustomerID = :customerID

            "
        )

    }



}