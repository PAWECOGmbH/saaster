<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <meta http-equiv="X-UA-Compatible" content="ie=edge"/>

    <cfoutput>
    <title>#variables.metaTitle#</title>
    <meta name="description" content="#variables.metaDescription#">
    </cfoutput>

    <cfinclude template="css.cfm">

</head>

<!--- Display for sysAdmin --->
<cfif structKeyExists(session, "sysadmin") and session.sysadmin and !findNoCase("frontend", thiscontent.thisPath)>
    <div class="text-center col-lg-12 bg-red py-2"><b>SysAdmin</b> (the sysadmin part is only available in english)</div>
</cfif>

<!--- Test plan running? --->
<cfif structKeyExists(session, "currentPlan") and session.currentPlan.recurring eq "test" and !findNoCase("frontend", thiscontent.thisPath)>
    <cfoutput>
    <cfif dateformat(now(), 'yyyy-mm-dd') lte dateformat(session.currentPlan.endDate, 'yyyy-mm-dd')>
        <div class="text-center col-lg-12 bg-blue py-2">#getTrans('txtTestUntil')#: #lsDateFormat(getTime.utc2local(utcDate=session.currentPlan.endDate))#</div>
    <cfelse>
        <div class="text-center col-lg-12 bg-red py-2">#getTrans('txtTestTimeExpired')#</div>
    </cfif>
    </cfoutput>
</cfif>

