component displayname="widget" output="false" {

    /*
        Prepares the dashboard widgets of a user and returns the ones to display.

        Widgets of a plan or module the customer does not have right now (not booked,
        expired, payment pending, deactivated by the sysadmin) are only hidden - the
        user's entry with its position and on/off setting stays and is shown again as
        soon as the widget is available again. New widgets are added at the end.
        Deleted widgets disappear by themselves (ON DELETE CASCADE).
    */
    public query function prepareUserWidgets(required numeric userID, required string moduleList, required numeric planID){

        local.qWidgets = getAllWidgets(arguments.moduleList, arguments.planID);
        local.availableIDs = valueList(local.qWidgets.intWidgetID);

        local.qOldUserWidgets = getOldUserWidgets(arguments.userID);
        local.oldUserWidgetIDs = valueList(local.qOldUserWidgets.intWidgetID);
        local.lastUserWidgetPrio = local.qOldUserWidgets.recordCount;

        for (local.row in local.qWidgets) {
            if (not listFind(local.oldUserWidgetIDs, local.row.intWidgetID)) {
                local.lastUserWidgetPrio++;
                insertWidget(local.row.intWidgetID, local.lastUserWidgetPrio, arguments.userID);
                local.oldUserWidgetIDs = listAppend(local.oldUserWidgetIDs, local.row.intWidgetID);
            }
        }

        return getUserWidgets(arguments.userID, local.availableIDs);
    }

    public query function getAllWidgets(required string moduleList, required numeric planID){

        // Bound as a real list: a plain string "3,5,7" would be read as 3 by MySQL
        local.moduleIDs = listToArray(arguments.moduleList).filter((id) => isValid("integer", trim(id))).map((id) => int(trim(id)));
        if (arrayIsEmpty(local.moduleIDs)) {
            local.moduleIDs = [0];
        }

        local.qWidgets = queryExecute(
            options = {datasource = application.datasource},
            params = {
                planID: {type: "numeric", value: arguments.planID},
                moduleList: {type: "numeric", value: arrayToList(local.moduleIDs), list: true}
            },
            sql = "
                SELECT widgets.*, widget_ratio.strDescription, widget_ratio.intSizeRatio

                FROM widgets_plans
                RIGHT JOIN widgets ON 1=1
                AND widgets_plans.intWidgetID = widgets.intWidgetID

                RIGHT JOIN widget_ratio ON 1=1
                AND widgets.intRatioID = widget_ratio.intRatioID

                WHERE (widgets_plans.intPlanID = :planID OR widgets.blnPermDisplay = 1)

                AND widgets.blnActive = 1

                UNION

                SELECT widgets.*, widget_ratio.strDescription, widget_ratio.intSizeRatio

                FROM widgets_modules
                RIGHT JOIN widgets ON 1=1
                AND widgets_modules.intWidgetID = widgets.intWidgetID

                RIGHT JOIN widget_ratio ON 1=1
                AND widgets.intRatioID = widget_ratio.intRatioID

                WHERE (widgets_modules.intModuleID IN (:moduleList) OR widgets.blnPermDisplay = 1)

                AND widgets.blnActive = 1

            "
        );

        return local.qWidgets;
    }

    public query function getOldUserWidgets(required numeric userID){

        local.qOldUserWidgets = queryExecute(
            options = {datasource = application.datasource},
            params = {
                user_id: {type: "numeric", value: arguments.userID}
            },
            sql = "
                SELECT intWidgetID
                FROM user_widgets
                WHERE intUserID = :user_id
            "
        );

        return local.qOldUserWidgets;
    }

    public query function insertWidget(required numeric widgetID, required numeric prio, required numeric userID){

        local.qInsertWidgets = queryExecute(
            options = {datasource = application.datasource},
            params = {
                widget_id: {type: "numeric", value: arguments.widgetID},
                user_id: {type: "numeric", value: arguments.userID},
                sortorder: {type: "numeric", value: arguments.prio}
            },
            sql = "
                INSERT INTO user_widgets (intWidgetID, intUserID, intPrio, blnActive)
                VALUES (:widget_id, :user_id, :sortorder, 1)
            "
        );

        return local.qInsertWidgets;
    }

    // widgetIDs: only these widgets (the ones available right now); all of the user's widgets if not passed
    public query function getUserWidgets(required numeric userID, string widgetIDs){

        local.widgetFilter = "";
        if (structKeyExists(arguments, "widgetIDs")) {
            // An empty list means nothing is available - 0 never matches a widget
            local.widgetFilter = "AND user_widgets.intWidgetID IN (:widgetIDs)";
        }

        local.qUserWidgets = queryExecute(
            options = {datasource = application.datasource},
            params = {
                user_id: {type: "numeric", value: arguments.userID},
                widgetIDs: {type: "numeric", value: (structKeyExists(arguments, "widgetIDs") and listLen(arguments.widgetIDs)) ? arguments.widgetIDs : 0, list: true}
            },
            sql = "
                SELECT
                    user_widgets.intPrio,
                    user_widgets.blnActive,
                    widgets.intWidgetID,
                    widgets.strWidgetName,
                    widgets.strFilePath,
                    widget_ratio.intSizeRatio

                FROM widgets
                INNER JOIN user_widgets ON 1=1
                AND widgets.intWidgetID = user_widgets.intWidgetID

                INNER JOIN widget_ratio ON 1=1
                AND widgets.intRatioID = widget_ratio.intRatioID

                WHERE user_widgets.intUserID = :user_id
                #local.widgetFilter#
                ORDER BY user_widgets.intPrio

            "
        );

        return local.qUserWidgets;
    }

}