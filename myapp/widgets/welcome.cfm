
<!--- This is a demo file which will be loaded into a widget on the dashboard. --->
<cfoutput>
<div class="card card-active">
    <div class="card-body">
        <h2>Hi #session.user_name#, welcome to SaaSTER!</h2>
        <p>Your last login: <cfif len(session.last_login)>#lsDateFormat(getTime.utc2local(utcDate=session.last_login))# - #lsTimeFormat(getTime.utc2local(utcDate=session.last_login))#<cfelse>It's your first login</cfif></p>
        <p>Your current date: #lsDateFormat(getTime.utc2local(utcDate=now()))# - #lsTimeFormat(getTime.utc2local(utcDate=now()))#</p>
        <p>Your current timezone: #getTime.getTimezoneByID(getCustomerData.timezoneID).timezone#</p>
    </div>
</div>
</cfoutput>