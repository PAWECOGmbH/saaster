<cfscript>

    // Is there coming a redirect from the PSP?
    if (structKeyExists(url, "psp_response")) {
        if (url.psp_response eq "failed") {
            getAlert('alertErrorOccured', 'warning');
        }
    }

    objPlans = new backend.core.com.plans();

    if (structKeyExists(session, "customer_id")) {
        groupStruct = objPlans.prepareForGroupID(customerID=session.customer_id);
    } else {
        groupStruct = objPlans.prepareForGroupID(ipAddress=session.usersIP);
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

</cfscript>


<cfoutput>
<div class="page page-center">
    <div class="container py-4">
        <cfif structKeyExists(session, "alert")>
            #session.alert#
        </cfif>
        <cfif hasPlans>
            <div class="text-center mb-4">
                <cfinclude template="plan_boxes.cfm">
            </div>
            <div class="text-center mb-4">
                <cfinclude template="plan_features.cfm">
            </div>
        </cfif>
    </div>
</div>
</cfoutput>
<cfset structDelete(session, "alert") />