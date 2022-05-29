
<cfif structKeyExists(url, "flush")>
    <cfset cacheAction = "flush">
<cfelse>
    <cfset cacheAction = "cache">
</cfif>

<cfcache action="#cacheAction#" timespan="#CreateTimeSpan(0,6,0,0)#">

<cfscript>

    objPlans = new com.plans();

    if (structKeyExists(session, "customer_id")) {
        groupStruct = objPlans.prepareForGroupID(customerID=session.customer_id);
    } else {
        groupStruct = objPlans.prepareForGroupID(ipAddress=application.usersIP);
    }

    hasPlans = true;

    if (groupStruct.groupID gt 0) {

        planArray = objPlans.init(language=session.lng, currencyID=groupStruct.defaultCurrencyID).getPlans(groupStruct.groupID);

        if (!arrayLen(planArray)) {
            hasPlans = false;
        }

    } else {

        hasPlans = false;

    }

    if (!hasPlans) {
        getAlert('Sorry, no plans were found!', 'warning');
    }

    //dump(groupStruct);

</cfscript>


<cfoutput>
<div class="border-top-wide border-primary d-flex flex-column">
    <div class="page page-center">
        <div class="container py-4">
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
            <cfif hasPlans>
                <div class="text-center mb-4">
                    <cfinclude template="/includes/plan_boxes.cfm">
                </div>
                <div class="text-center mb-4">
                    <cfinclude template="/includes/plan_features.cfm">
                </div>
            </cfif>
        </div>
    </div>
</div>
</cfoutput>

</cfcache>