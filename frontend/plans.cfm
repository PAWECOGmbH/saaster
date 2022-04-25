<cfscript>
    variables.planLanguage = session.lng;
    variables.planCurrencyID = 0;
    variables.planCountryID = 0;
    variables.planGroupID = 0;
</cfscript>
<cfoutput>
<cfif structKeyExists(session, "alert")>
    #session.alert#
</cfif>
<div class="border-top-wide border-primary d-flex flex-column">
    <div class="page page-center">
        <div class="container py-4">
            <div class="text-center mb-4">
                <cfinclude template="/includes/plan_boxes.cfm">
            </div>
            <div class="text-center mb-4">
                <cfinclude template="/includes/plan_features.cfm">
            </div>
        </div>
    </div>
</div>
</cfoutput>