<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <meta http-equiv="X-UA-Compatible" content="ie=edge"/>

    <cfoutput>
    <title>#getMeta(cgi.path_info, session.lng).metaTtile#</title>
    <meta name="description" content="#getMeta(cgi.path_info, session.lng).metaDescription#">
    #getMeta(cgi.path_info, session.lng).metaHTML#
    </cfoutput>

    <meta name="robots" content="noindex, nofollow">

</head>