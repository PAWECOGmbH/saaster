<cfoutput>
<html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <meta http-equiv="X-UA-Compatible" content="ie=edge"/>

    <title>saaster.io</title>
    <meta name="description" content="saaster.io">
    <link type="text/css" href="#application.mainURL#/dist/css/tabler.min.css" rel="stylesheet"/>
    <link type="text/css" href="#application.mainURL#/dist/css/demo.min.css" rel="stylesheet"/>
    <link type="text/css" href="#application.mainURL#/dist/fontawesome/css/all.css" rel="stylesheet" />
    <link type="text/css" href="#application.mainURL#/dist/css/custom.css" rel="stylesheet"/>
    <link type="text/css" href="#application.mainURL#/backend/core/views/color.cfm" rel="stylesheet"/>
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

<script src="#application.mainURL#/dist/js/jquery-3.6.0.min.js"></script>
<script src="#application.mainURL#/dist/js/dropify.min.js"></script>
<script src="#application.mainURL#/dist/js/jquery-ui.min.js"></script>
<script src="#application.mainURL#/dist/js/jquery.toggleinput.js"></script>
<script src="#application.mainURL#/dist/js/custom.js"></script>

</body>
</html>

</cfoutput>