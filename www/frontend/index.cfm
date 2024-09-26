<cfoutput>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <meta http-equiv="X-UA-Compatible" content="ie=edge"/>
    <title>#getMeta(cgi.path_info, session.lng).metaTtile#</title>
    <meta name="description" content="#getMeta(cgi.path_info, session.lng).metaDescription#">
    #getMeta(cgi.path_info, session.lng).metaHTML#
    <cfinclude template="/frontend/css-include.cfm">
</head>
<body>

<div class="page">

    <cfif fileExists(thiscontent.thisPath) or fileExists("/" & thiscontent.thisPath)>
        <cfinclude template="/#thiscontent.thisPath#">
    <cfelse>
        <h1>SAASTER</h1>
        <p><a href="./plans">Plans</a></p>
        <p><a href="./login">Login page</a></p>
        <p><a href="./register">Registration page</a></p>
    </cfif>
</div>

<cfinclude template="/frontend/js-include.cfm">

</body>
</html>

</cfoutput>