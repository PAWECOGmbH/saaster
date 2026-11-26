<!--- Test plan running? --->
<cfif structKeyExists(session, "currentPlan") and session.currentPlan.recurring eq "test" and !findNoCase("frontend", thiscontent.thisPath)>
    <cfoutput>
    <cfif dateformat(now(), 'yyyy-mm-dd') lte dateformat(session.currentPlan.endDate, 'yyyy-mm-dd')>
        <div class="text-center col-lg-12 bg-blue py-2 text-white">#getTrans('txtTestUntil')#: #lsDateFormat(getTime.utc2local(utcDate=session.currentPlan.endDate))#</div>
    <cfelse>
        <div class="text-center col-lg-12 bg-red py-2 text-white">#getTrans('txtTestTimeExpired')#</div>
    </cfif>
    </cfoutput>
</cfif>
