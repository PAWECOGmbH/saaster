<cfscript>

actionSuccess = false;

//=== Set Dashboard Edit Mode ================

if (structKeyExists(form, "dashboardedit") and (form.dashboardedit eq 1)) {

    session.dashboardedit = 1;

    location url="#application.mainURL#/dashboard" addtoken="false";

}

//=== Finish Dashboard Edit Mode ================

if (structKeyExists(form, "dashboardedit") and (form.dashboardedit eq 0)) {

    session.dashboardedit = 0;

    location url="#application.mainURL#/dashboard" addtoken="false";

}


//=== Disable/Enable Widget ================

if (structKeyExists(form, "action") and (form.action eq "disable")) {

    wIsActive = 1;
    if(form.active neq 1){
        wIsActive = 0;
    }

    qUpdateUserWidget = queryExecute(
        options = {datasource = application.datasource},
        params = {
            widget_id: {type: "numeric", value: form.id},
            user_id: {type: "numeric", value: session.user_id},
            isactive: {type: "numeric", value: wIsActive}
        },
        sql = "
            UPDATE user_widgets
            SET blnActive = :isactive
            WHERE intUserID = :user_id
            AND intWidgetID = :widget_id
        "
    );

    logWrite("user", "info", "Enabled or disabled a widget [CustomerID: #session.customer_id#, UserID: #session.user_id#, WidgetID: #form.id#]");
    actionSuccess = true;

}


//=== Change Widgets Sortorder ================

if (structKeyExists(form, "sortorder") and len(trim(form.sortorder))) {

    widget_order = 1;

    loop list=form.sortorder delimiters="&" index="widget" {

        widget_id = listLast(widget, "=");

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                widget_id: {type: "numeric", value: widget_id},
                user_id: {type: "numeric", value: session.user_id},
                widget_order: {type: "numeric", value: widget_order}
            },
            sql = "
                UPDATE user_widgets
                SET intPrio = :widget_order
                WHERE intWidgetID = :widget_id
                AND intUserID = :user_id
            "
        );

        widget_order++;

    }

    logWrite("user", "info", "User changed a widget sortorder [CustomerID: #session.customer_id#, UserID: #session.user_id#, WidgetID: #widget_id#]");
    actionSuccess = true;

}

//redirect to dashboard page if nothing worked:
if(not actionSuccess){
    location url="#application.mainURL#/dashboard" addtoken="false";
}


</cfscript>