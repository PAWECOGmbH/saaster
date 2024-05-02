<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <meta http-equiv="X-UA-Compatible" content="ie=edge"/>

    <title>saaster.io</title>
    <meta name="description" content="saaster.io - the saas boilerplate / framework for coldfusion and lucee">
    <cfoutput>
    <link type="text/css" href="#application.mainURL#/dist/css/dropify.min.css" rel="stylesheet"/>
    <link type="text/css" href="#application.mainURL#/dist/css/tabler.min.css" rel="stylesheet"/>
    <link type="text/css" href="#application.mainURL#/dist/css/tabler-flags.min.css" rel="stylesheet"/>
    <link type="text/css" href="#application.mainURL#/dist/css/tabler-payments.min.css" rel="stylesheet"/>
    <link type="text/css" href="#application.mainURL#/dist/css/tabler-vendors.min.css" rel="stylesheet"/>
    <link type="text/css" href="#application.mainURL#/dist/css/demo.min.css" rel="stylesheet"/>
    <link type="text/css" href="#application.mainURL#/dist/fontawesome/css/all.css" rel="stylesheet" />
    <link type="text/css" href="#application.mainURL#/dist/css/sweetalert.css" rel="stylesheet" />
    <link type="text/css" href="#application.mainURL#/dist/css/dropify.min.css" rel="stylesheet" />
    <link type="text/css" href="#application.mainURL#/dist//trumbowyg/ui/trumbowyg.min.css" rel="stylesheet"/>
    <link type="text/css" href="#application.mainURL#/dist/css/custom.css" rel="stylesheet"/>
    <link type="text/css" href="#application.mainURL#/includes/color.cfm" rel="stylesheet"/>
    </cfoutput>

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

