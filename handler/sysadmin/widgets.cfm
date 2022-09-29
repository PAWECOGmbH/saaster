
<cfscript>

if (structKeyExists(form, "new_widget")) {

    param name="form.name" default="";
    param name="form.path" default="";
    param name="form.planList" default="";
    param name="form.moduleList" default="";

    itsActive = structKeyExists(form, "active") ? 1 : 0;
    permanently = structKeyExists(form, "perm") ? 1 : 0;

    queryExecute(
        options = {datasource = application.datasource, result="newWidgetID"},
        params = {
            name: {type: "nvarchar", value: form.name},
            path: {type: "nvarchar", value: form.path},
            active: {type: "boolean", value: itsActive},
            ratioID: {type: "numeric", value: form.ratioID},
            perm: {type: "boolean", value: permanently}
        },
        sql = "
            INSERT INTO widgets (strWidgetName, strFilePath, blnActive, intRatioID, blnPermDisplay)
            VALUES (:name, :path, :active, :ratioID, :perm)
        "
    )

    if (permanently eq 0 and listLen(form.planList)) {

        loop list=form.planList index="planID" {
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    widgetID: {type: "numeric", value: newWidgetID.generated_key},
                    planID: {type: "numeric", value: planID}
                },
                sql = "
                    INSERT INTO widgets_plans (intWidgetID, intPlanID)
                    VALUES (:widgetID, :planID)
                "
            )
        }

    }

    if (permanently eq 0 and listLen(form.moduleList)) {

        loop list=form.moduleList index="moduleID" {
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    widgetID: {type: "numeric", value: newWidgetID.generated_key},
                    moduleID: {type: "numeric", value: moduleID},
                },
                sql = "
                    INSERT INTO widgets_modules (intWidgetID, intModuleID)
                    VALUES (:widgetID, :moduleID)
                "
            )
        }

    }

    getAlert('Widget added');
    location url="#application.mainURL#/sysadmin/widgets" addtoken="false";


}


if (structKeyExists(form, "edit_widget")) {

    if (isNumeric(form.edit_widget)) {

        param name="form.name" default="";
        param name="form.path" default="";
        param name="form.planList" default="";
        param name="form.moduleList" default="";

        itsActive = structKeyExists(form, "active") ? 1 : 0;
        permanently = structKeyExists(form, "perm") ? 1 : 0;

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                name: {type: "nvarchar", value: form.name},
                path: {type: "nvarchar", value: form.path},
                active: {type: "boolean", value: itsActive},
                ratioID: {type: "numeric", value: form.ratioID},
                widgetID: {type: "numeric", value: form.edit_widget},
                perm: {type: "boolean", value: permanently}
            },
            sql = "
                UPDATE widgets
                SET strWidgetName = :name,
                    strFilePath = :path,
                    blnActive = :active,
                    intRatioID = :ratioID,
                    blnPermDisplay = :perm
                WHERE intWidgetID = :widgetID;
                DELETE FROM widgets_modules WHERE intWidgetID = :widgetID;
                DELETE FROM widgets_plans WHERE intWidgetID = :widgetID;
            "
        )

        if (permanently eq 0 and listLen(form.planList)) {

            loop list=form.planList index="planID" {
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        widgetID: {type: "numeric", value: form.edit_widget},
                        planID: {type: "numeric", value: planID},
                    },
                    sql = "
                        INSERT INTO widgets_plans (intWidgetID, intPlanID)
                        VALUES (:widgetID, :planID)
                    "
                )
            }

        }

        if (permanently eq 0 and listLen(form.moduleList)) {

            loop list=form.moduleList index="moduleID" {
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        widgetID: {type: "numeric", value: form.edit_widget},
                        moduleID: {type: "numeric", value: moduleID},
                    },
                    sql = "
                        INSERT INTO widgets_modules (intWidgetID, intModuleID)
                        VALUES (:widgetID, :moduleID)
                    "
                )
            }

        }

        getAlert('Widget saved');
        location url="#application.mainURL#/sysadmin/widgets" addtoken="false";

    }

}


if (structKeyExists(url, "delete_widget")) {

    if (isNumeric(url.delete_widget)) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                widgetID: {type: "numeric", value: url.delete_widget}
            },
            sql = "
                DELETE FROM widgets
                WHERE intWidgetID = :widgetID
            "
        )

    }

    getAlert('Widget deleted');
    location url="#application.mainURL#/sysadmin/widgets" addtoken="false";

}


</cfscript>