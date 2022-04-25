<cfscript>
    qWidgets = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT widgets.*, widget_ratio.strDescription, widget_ratio.intSizeRatio
            FROM widgets INNER JOIN widget_ratio ON widgets.intRatioID = widget_ratio.intRatioID
            WHERE widgets.blnActive = 1
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

                <div class="row row-deck row-cards">

                    <cfloop query="qWidgets">

                        <div class="col-lg-#qWidgets.intSizeRatio#">
                            <div class="card">
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


