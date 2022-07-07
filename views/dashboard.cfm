<cfscript>

    qWidgets = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT widgets.*, widget_ratio.strDescription, widget_ratio.intSizeRatio
            FROM widgets INNER JOIN widget_ratio ON widgets.intRatioID = widget_ratio.intRatioID
            WHERE widgets.blnActive = 1
        "
    );

    allWidgets = valueList(qWidgets.intWidgetID);

    // Remove user widgets that have been deactivated by admin
    if(listLen(allWidgets)){

        qRemoveWidgets = queryExecute(
            options = {datasource = application.datasource},
            params = {
                user_id: {type: "numeric", value: session.user_id},
                allWidgets: {type: "varchar", value: allWidgets, list: true, separator: ","}
            },
            sql = "
                DELETE FROM user_widgets
                WHERE intUserID = :user_id
                AND intWidgetID NOT IN(:allWidgets)
            "
        );

    }else{

        qRemoveWidgets = queryExecute(
            options = {datasource = application.datasource},
            params = {
                user_id: {type: "numeric", value: session.user_id}
            },
            sql = "
                DELETE FROM user_widgets
                WHERE intUserID = :user_id
            "
        );

    }


    qOldUserWidgets = queryExecute(
        options = {datasource = application.datasource},
        params = {
            user_id: {type: "numeric", value: session.user_id}
        },
        sql = "
            SELECT intWidgetID
            FROM user_widgets
            WHERE intUserID = :user_id
        "
    );

    oldUserWidgetIDs = valueList(qOldUserWidgets.intWidgetID);
    lastUserWidgetPrio = qOldUserWidgets.recordCount;

    for(row in qWidgets){

        if(not listFind(oldUserWidgetIDs, row.intWidgetID)){

            lastUserWidgetPrio++;

            qInsertWidgets = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    widget_id: {type: "numeric", value: row.intWidgetID},
                    user_id: {type: "numeric", value: session.user_id},
                    sortorder: {type: "numeric", value: lastUserWidgetPrio}
                },
                sql = "
                    INSERT INTO user_widgets (intWidgetID, intUserID, intPrio, blnActive)
                    VALUES (:widget_id, :user_id, :sortorder, 1)
                "
            )

        }

    }

    qUserWidgets = queryExecute(
        options = {datasource = application.datasource},
        params = {
            user_id: {type: "numeric", value: session.user_id}
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



</cfscript>

<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Dashboard by #getCustomerData.strCompanyName#</h4>

                    </div>


                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="page-body">
            <div class="container-xl">

                <div class="row row-deck row-cards dashboard">

                    <cfparam name="session.dashboardedit" default="0" />

                    <cfloop query="qUserWidgets">

                        <cfif session.dashboardedit eq 1>

                            <!---============== dashboard edit mode ==============--->

                            <div id="id_#qUserWidgets.intWidgetID#" class="widget col-lg-#qUserWidgets.intSizeRatio#">
                                <div class="card">

                                    <cfif session.dashboardedit eq 1>
                                        <div class="card-header d-flex">
                                            <div style="margin-right:15px">
                                                <i class="fas fa-bars move-widget" style="cursor:grab;"></i>
                                            </div>
                                            <div class="flex-grow-1">
                                                <span class="isvisible" style="<cfif qUserWidgets.blnActive eq 1>display:block<cfelse>display:none</cfif>">#getTrans('txtWidgetVisible')#</span>
                                                <span class="isinvisible" style="<cfif qUserWidgets.blnActive eq 0>display:block<cfelse>display:none</cfif>">#getTrans('txtWidgetHidden')#</span>
                                            </div>
                                            <div style="margin-left:15px">
                                                <label class="form-check form-switch">
                                                    <input class="form-check-input disable-widget" type="checkbox" name="active" value="#qUserWidgets.intWidgetID#" <cfif qUserWidgets.blnActive>checked</cfif>>
                                                </label>
                                            </div>
                                        </div>
                                    </cfif>

                                    <div class="card-body<cfif qUserWidgets.blnActive neq 1> widget-disabled</cfif>">
                                        <!--- check if file exists --->
                                        <cfif fileExists(expandPath("/#qUserWidgets.strFilePath#"))>
                                            <cfinclude template="/#qUserWidgets.strFilePath#">
                                        <cfelse>
                                            #getTrans('txtCheckWidgetPath')#
                                        </cfif>
                                    </div>
                                </div>
                            </div>

                        <cfelseif qUserWidgets.blnActive eq 1>

                            <!---============== dashboard default ==============--->

                            <div class="col-lg-#qUserWidgets.intSizeRatio#">
                                <div class="card">
                                    <div class="card-body">
                                        <!--- check if file exists --->
                                        <cfif fileExists(expandPath("/#qUserWidgets.strFilePath#"))>
                                            <cfinclude template="/#qUserWidgets.strFilePath#">
                                        <cfelse>
                                            #getTrans('txtCheckWidgetPath')#
                                        </cfif>
                                    </div>
                                </div>
                            </div>

                        </cfif>

                    </cfloop>

                </div>

                <cfif qUserWidgets.recordcount>

                    <div class="row mt-4">
                        <div class="col text-center">
                            <form action="#application.mainURL#/dashboard-settings" method="post">
                                <cfif session.dashboardedit eq 0>
                                    <input type="hidden" name="dashboardedit" value="1">
                                    <button type="submit" class="btn btn-outline-dark"><i class="fas fa-th-large pe-3"></i>#getTrans('bnEditDashboard')#</button>
                                <cfelse>
                                    <input type="hidden" name="dashboardedit" value="0">
                                    <button type="submit" class="btn btn-outline-dark"><i class="fas fa-th-large pe-3"></i>#getTrans('bnEndEditDashboard')#</button>
                                </cfif>
                            </form>
                        </div>
                    </div>

                </cfif>

            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>


