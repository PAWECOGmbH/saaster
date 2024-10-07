
<!--- This is a demo file which will be loaded into a widget on the dashboard. --->
<cfoutput>
<div class="card card-active">
    <div class="card-body">
        <h2>Hallo #session.user_name#, willkommen bei Stellensuche.ch!</h2>
        <p>Ihr letztes Login: <cfif len(session.last_login)>#lsDateFormat(getTime.utc2local(utcDate=session.last_login))# - #lsTimeFormat(getTime.utc2local(utcDate=session.last_login))#<cfelse>Das war Ihr erstes Login.</cfif></p>
        <cfif !session.sysadmin>
            <p>Ihr aktueller Plan: <cfif len(session.currentPlan.planName)><b>#session.currentPlan.planName#</b> <a href="account-settings/plans">Plan wechseln</a><cfelse>Sie haben noch keinen Plan gebucht. <a href="/plans">Wählen Sie einen Plan.</a></cfif></p>
        </cfif>
    </div>
</div>
</cfoutput>
