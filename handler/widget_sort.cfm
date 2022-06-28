<cfscript>
widget_order = 1;

loop list=form.sortorder delimiters="&" index="widget" {

    widget_id = listLast(widget, "=");

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            widget_id: {type: "numeric", value: widget_id},
            widget_order: {type: "numeric", value: widget_order}
        },
        sql = "
            UPDATE widgets
            SET intPrio=:widget_order
            WHERE intWidgetID=:widget_id
        "
    );

    widget_order++;

}
</cfscript>