component displayname="widget" output="false" {

    public query function getAllWidgets(required string moduleList, required numeric planID){

        local.qWidgets = queryExecute(
            options = {datasource = application.datasource},
            params = {
                planID: {type: "numeric", value: arguments.planID},
                moduleList: {type: "varchar", value: listLen(arguments.moduleList) ? arguments.moduleList : 0}
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

    public query function deleteMultipleWidget(required string allWidgets, required numeric userID){

        local.qRemoveWidgets = queryExecute(
            options = {datasource = application.datasource},
            params = {
                user_id: {type: "numeric", value: arguments.userID},
                allWidgets: {type: "varchar", value: arguments.allWidgets, list: true, separator: ","}
            },
            sql = "
                DELETE FROM user_widgets
                WHERE intUserID = :user_id
                AND intWidgetID NOT IN(:allWidgets)
            "
        );

        return local.qRemoveWidgets;
    }

    public query function deleteWidget(required numeric userID){

        local.qRemoveWidgets = queryExecute(
            options = {datasource = application.datasource},
            params = {
                user_id: {type: "numeric", value: arguments.userID}
            },
            sql = "
                DELETE FROM user_widgets
                WHERE intUserID = :user_id
            "
        );

        return local.qRemoveWidgets;
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

    public query function getUserWidgets(required numeric userID){

        local.qUserWidgets = queryExecute(
            options = {datasource = application.datasource},
            params = {
                user_id: {type: "numeric", value: arguments.userID}
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
                ORDER BY user_widgets.intPrio

            "
        );

        return local.qUserWidgets;
    }

}