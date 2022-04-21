
<!--- This is a demo file which will be loaded into a widget on the dashboard. --->

<cfsetting showdebugoutput="no">
<!--- <cfdump  var="#session.currentPlan#"> --->

<cfoutput>
<h2>Your plan</h2>
<p class="mb-1">
    Your current plan:
    <cfif session.currentPlan.planID gt 0>
        #session.currentPlan.planName#
    <cfelse>
        You don't have a plan yet - <a href="#application.mainURL#/plans">book now!</a>
    </cfif>
</p>
<cfif session.currentPlan.planID gt 0>
    <p class="mb-1">
        Plan status:
        <cfif session.currentPlan.status eq "active"><span class="text-green">ACTIVE</span> - <a href="#application.mainURL#/plans">Change plan now!</a></cfif>
        <cfif session.currentPlan.status eq "test"><span class="text-blue">TEST</span></cfif>
        <cfif session.currentPlan.status eq "expired"><span class="text-red">EXPIRED</span></cfif>
        <cfif session.currentPlan.status eq "free"><span class="text-green">FREE</span> - <a href="#application.mainURL#/plans">Upgrade plan now!</a></cfif>
    </p>
    <cfif session.currentPlan.status eq "test">
        <p class="mb-1">You can test until: #lsDateFormat(session.currentPlan.endTestDate, "Full")#</p>
    </cfif>
    <cfif session.currentPlan.status eq "active">
        <p class="mb-1">Your plan is valid until: #lsDateFormat(session.currentPlan.endDate, "Full")#</p>
    </cfif>
</cfif>

</cfoutput>