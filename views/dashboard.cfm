<cfscript>
    qWidgets = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT widgets.*, widget_ratio.strDescription, widget_ratio.intSizeRatio
            FROM widgets INNER JOIN widget_ratio ON widgets.intRatioID = widget_ratio.intRatioID
            WHERE widgets.blnActive = 1
            ORDER BY intPrio
        "
    )
    objPrices = new com.prices();
</cfscript>

<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<!--- <cfdump  var="#session.currentModules#">
<cfdump  var="#session.currentPlan#"> --->



<!--- <cfdump var="#new com.modules().getBookedModules(session.customer_id)#">

<cfabort> --->

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

                    <cfloop query="qWidgets">

                        <div id="id_#qWidgets.intWidgetID#" class="widget col-lg-#qWidgets.intSizeRatio#">
                            <div class="card">
                                <div class="widget-options">
                                    <i class="fas fa-arrows-up-down-left-right move-widget" style="cursor:grab;"></i>
                                </div>
                                <div class="card-body">
                                    <cfinclude template="/#qWidgets.strFilePath#">
                                </div>
                            </div>
                        </div>

                    </cfloop>

                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>


