
<cfoutput>
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<cfif fileExists("/frontend/#application.activeTheme#/css/styles-min.css")>
    <link rel="stylesheet" type="text/css" href="/frontend/#application.activeTheme#/css/styles-min.css?v=123456789" />
<cfelse>
    <link rel="stylesheet" type="text/css" href="/frontend/#application.activeTheme#/css/styles.css" />
</cfif>
</cfoutput>
