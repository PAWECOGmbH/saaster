
<cfscript>

if (structKeyExists(form, "new_widget")) {

    param name="form.name" default="";
    param name="form.path" default="";

    if (structKeyExists(form, "active")) {
        itsActive = 1;
    } else {
        itsActive = 0;
    }

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            name: {type: "nvarchar", value: form.name},
            path: {type: "nvarchar", value: form.path},
            active: {type: "boolean", value: itsActive},
            ratioID: {type: "numeric", value: form.ratioID}
        },
        sql = "
            INSERT INTO widgets (strWidgetName, strFilePath, blnActive, intRatioID)
            VALUES (:name, :path, :active, :ratioID)
        "
    )

    getAlert('Widget added');
    location url="#application.mainURL#/sysadmin/widgets" addtoken="false";


}


if (structKeyExists(form, "edit_widget")) {

    if (isNumeric(form.edit_widget)) {

        param name="form.name" default="";
        param name="form.path" default="";

        if (structKeyExists(form, "active")) {
            itsActive = 1;
        } else {
            itsActive = 0;
        }

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                name: {type: "nvarchar", value: form.name},
                path: {type: "nvarchar", value: form.path},
                active: {type: "boolean", value: itsActive},
                ratioID: {type: "numeric", value: form.ratioID},
                widgetID: {type: "numeric", value: form.edit_widget}
            },
            sql = "
                UPDATE widgets
                SET strWidgetName = :name,
                    strFilePath = :path,
                    blnActive = :active,
                    intRatioID = :ratioID
                WHERE intWidgetID = :widgetID
            "
        )

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