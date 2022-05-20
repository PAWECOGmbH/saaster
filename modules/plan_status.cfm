
<!--- This is a demo file which will be loaded into a widget on the dashboard. --->

<cfsetting showdebugoutput="no">

<cfoutput>
<h2>Your plan</h2>
<a href="#application.mainURL#/account-settings">Account settings</a>
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