<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <meta http-equiv="X-UA-Compatible" content="ie=edge"/>

    <cfoutput>
    <title>#variables.metaTitle#</title>
    <meta name="description" content="#variables.metaDescription#">
    <meta name="csrf-token" content="#csrfToken()#">
    <meta name="saaster-context" content="#application.objGlobal.contextToken()#">
    </cfoutput>

    <cfinclude template="css.cfm">

</head>
