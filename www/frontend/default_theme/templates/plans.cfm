<cfscript>

    // Call the utility function to retrieve plans
    planData = application.objCoreUtil.retrievePlans();

    hasPlans = false;

    if (structKeyExists(planData[1], "planGroupID") and planData[1].planGroupID gt 0) {

        hasPlans = true;

        // Call the core function to retrieve features
        objPlans = new backend.core.com.plans(language=session.lng);
        planFeatures = objPlans.getPlanFeatures();

    }

</cfscript>

<!--- Include toggles, plans and feature table --->
<cfif hasPlans>

    <cfinclude template="plans/toggle.cfm">
    <cfinclude template="plans/plan_boxes.cfm">
    <cfinclude template="plans/plan_features.cfm">

</cfif>