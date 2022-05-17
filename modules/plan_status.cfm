
<!--- This is a demo file which will be loaded into a widget on the dashboard. --->

<cfsetting showdebugoutput="no">
<!--- <cfdump var="#session.currentPlan#"> --->

<cfoutput>
<h2>Your plan</h2>
<p class="mb-1">
    Your current plan:
    <cfif session.currentPlan.planID gt 0>
        <b>#session.currentPlan.planName#</b>
    <cfelse>
        You don't have a plan yet - <a href="#application.mainURL#/plans">book now!</a>
    </cfif>
</p>
<p class="mb-1">

<cfif session.currentPlan.planID gt 0>

Plan status:

    <!--- Test time --->
    <cfif isDate(session.currentPlan.endTestDate)>

        <cfif session.currentPlan.status eq "expired">
            <span class="text-red">Your test time has EXPIRED</span> - <a href="#application.mainURL#/plans">Renew plan now!</a>
        <cfelseif session.currentPlan.status eq "test">
            <span class="text-blue">TEST</span>  - <a href="#application.mainURL#/plans">Change plan now!</a><br>
            You can test until: #lsDateFormat(session.currentPlan.endTestDate, "Full")#
        </cfif>

    <!--- Normal time --->
    <cfelseif isDate(session.currentPlan.endDate)>

        <cfif session.currentPlan.status eq "active">
            <span class="text-green">ACTIVE</span>
            <cfif isArray(session.currentPlan.modulesIncluded)>
                <p class="mb-1">Included modules:</p>
                <ul>
                    <cfloop array="#session.currentPlan.modulesIncluded#" index="m">
                        <li>#m.name# (#m.moduleID#)</li>
                    </cfloop>
                </ul>
            </cfif>
            <p class="mb-1">Your plan will be renewed on: #lsDateFormat(session.currentPlan.endDate, "Full")#</p>
        <cfelseif session.currentPlan.status eq "expired">
            <span class="text-red">EXPIRED</span> - <a href="#application.mainURL#/plans">Renew plan now!</a>
        </cfif>

    <!--- Free account --->
    <cfelse>

        <span class="text-green">FREE</span> - <a href="#application.mainURL#/plans">Upgrade plan now!</a>

    </cfif>

</cfif>

</p>

<p><hr></p>
<br>

<h2>Your modules</h2>

<cfif arrayLen(session.currentModules)>

    <cfloop array="#session.currentModules#" index="i">
        <h3>#i.moduleData.name#</h3>
        <p>#i.moduleData.short_description#</p>
        <p>
            Status:
            <!--- Test time --->
            <cfif isDate(i.moduleStatus.endTestDate)>

                <cfif i.moduleStatus.status eq "expired">
                    <span class="text-red">Your test time has EXPIRED</span> - <a href="#application.mainURL#/account-settings/modules">Renew module now!</a>
                <cfelseif i.moduleStatus.status eq "test">
                    <span class="text-blue">TEST</span> <br>
                    You can test until: #lsDateFormat(i.moduleStatus.endTestDate, "Full")#
                </cfif>

            <!--- Normal time --->
            <cfelseif isDate(i.moduleStatus.endDate)>

                <cfif i.moduleStatus.status eq "active">
                    <span class="text-green">ACTIVE</span>
                    <cfif i.moduleStatus.status neq "onetime">
                        <p class="mb-1">Your module will be renewed on: #lsDateFormat(i.moduleStatus.endDate, "Full")#</p>
                    </cfif>
                <cfelseif i.moduleStatus.status eq "expired">
                    <span class="text-red">EXPIRED</span> - <a href="#application.mainURL#/account-settings/modules">Renew module now!</a>
                </cfif>

            <!--- Free module --->
            <cfelse>

                <span class="text-green">ACTIVE (FREE)</span>

            </cfif>
        </p>
        <p><hr></p>
    </cfloop>

<cfelse>

    No modules activated - <a href="#application.mainURL#/account-settings/modules">book now!</a>

</cfif>



</cfoutput>