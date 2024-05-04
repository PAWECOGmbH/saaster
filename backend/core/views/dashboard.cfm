<cfscript>

    objWidget = new backend.core.com.widget();

    // Get all the booked modules as a list
    moduleList = "";
    if (!arrayIsEmpty(session.currentModules)) {
        loop array=session.currentModules index="i" {
            moduleList = listAppend(moduleList, i.moduleID);
        }
    }

    // Get all widgets which are connected to plans and modules (or displayed permanent)
    qWidgets = objWidget.getAllWidgets(moduleList, session.currentPlan.planID);

    allWidgets = valueList(qWidgets.intWidgetID);

    // Remove user widgets that have been deactivated by admin
    if(listLen(allWidgets)){
        qRemoveWidgets = objWidget.deleteMultipleWidget(allWidgets, session.user_id);
    }else{
        qRemoveWidgets = objWidget.deleteWidget(session.user_id);
    }


    qOldUserWidgets = objWidget.getOldUserWidgets(session.user_id);
    oldUserWidgetIDs = valueList(qOldUserWidgets.intWidgetID);
    lastUserWidgetPrio = qOldUserWidgets.recordCount;

    for(row in qWidgets){

        if(not listFind(oldUserWidgetIDs, row.intWidgetID)){

            lastUserWidgetPrio++;
            qInsertWidgets = objWidget.insertWidget(row.intWidgetID, lastUserWidgetPrio, session.user_id);
        }

    }

    qUserWidgets = objWidget.getUserWidgets(session.user_id);

</cfscript>

<cfoutput>
<div class="page-wrapper">

    <div class="#getLayout.layoutPage#">

        <div class="row mb-3">
            <div class="col-md-12 col-lg-12">

                <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                    <h4 class="page-title">Dashboard</h4>

                </div>


            </div>
        </div>
        <cfif structKeyExists(session, "alert")>
            #session.alert#
        </cfif>
    </div>
    <div class="page-body">
        <div class="#getLayout.layoutPage#">

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
</div>
</cfoutput>


