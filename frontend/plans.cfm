<cfscript>
    variables.planLanguage = session.lng;
    variables.planCurrencyID = 3;
    variables.planCountryID = 164;
    variables.planGroupID = 0;
</cfscript>
<cfoutput>
<div class="border-top-wide border-primary d-flex flex-column">
    <div class="page page-center">
        <div class="container py-4">
            <div class="text-center mb-4">
                <cfinclude template="/includes/plan_boxes.cfm">
            </div>
            <div class="text-center mb-4">
                <!--- <cfinclude template="/includes/plan_features.cfm"> --->
            </div>
        </div>
    </div>
</div>
</cfoutput>