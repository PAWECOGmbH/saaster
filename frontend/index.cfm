<cfoutput>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <meta http-equiv="X-UA-Compatible" content="ie=edge"/>

    <title>saaster.io</title>
    <meta name="description" content="saaster.io">
    <link type="text/css" href="#application.mainURL#/dist/css/tabler.min.css" rel="stylesheet"/>
</head>
<body>

<div class="page">
    <cfif fileExists(thiscontent.thisPath)>
        <cfinclude template="/#thiscontent.thisPath#">
    <cfelse>
        <h1>SAASTER</h1>
        <p><a href="./plans">Plans</a></p>
        <p><a href="./login">Login page</a></p>
        <p><a href="./register">Registration page</a></p>
    </cfif>
</div>

</body>
</html>

</cfoutput>