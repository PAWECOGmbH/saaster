<cfscript>

    // you can use this ID to enforce a specific plan. If 0, we will get the group id using the browser setting (locale)

    variables.planGroupID = 1;

    // the language coming from application but you can overwrite the language using the url variable l -> l=en or by hardcoding
    variables.planLanguage = session.lng;

    // you can use this ID to enforce a specific country. Set 0 if you want to use the country of the plan group
    variables.planCountryID = 0;

    // you can use this ID to enforce a specific currency. Set 0 if you want to use the currency of the plan group (country)
    variables.planCurrencyID = 0;


    // Get the data of the plan group if needed
    if (variables.planCountryID eq 0 or variables.planCurrencyID eq 0) {

        getPlanGroupData = objPlans.getGroupData(variables.planGroupID);



    dump(getPlanGroupData);
    abort;

        if (getPlanGroupData.countryID gt 0) {
            variables.planCountryID = getPlanGroupData.countryID;
        }
        if (getPlanGroupData.currencyID gt 0) {
            variables.planCurrencyID = getPlanGroupData.currencyID;
        }

    }

    // Get the plans object
    objPlans = new com.plans(language=variables.planLanguage, currencyID=variables.planCurrencyID);

</cfscript>
<cfoutput>
<div class="border-top-wide border-primary d-flex flex-column">
    <div class="page page-center">
        <div class="container py-4">
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
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