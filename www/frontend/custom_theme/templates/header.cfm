<cfoutput>
<!DOCTYPE html>
<html lang="#session.lng ?: application.defaultLanguage#">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>#getMeta(cgi.path_info, session.lng).metaTtile#</title>
    <meta name="description" content="#getMeta(cgi.path_info, session.lng).metaDescription#">
    #getMeta(cgi.path_info, session.lng).metaHTML#
    <link rel="icon" type="image/png" href="/frontend/#application.activeTheme#/images/favicon.png">
    <cfinclude template="../css/css-include.cfm">
</head>
</cfoutput>

<body>

<!--- Logo --->
<div class="d-block mx-auto mb-4 mt-4 text-center">
    <a href="./"><img src="/assets/img/logo.svg" alt="Saaster" width="300"></a>
</div>