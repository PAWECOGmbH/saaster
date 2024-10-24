
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta17/dist/css/tabler.min.css" />
<link rel="stylesheet" type="text/css" href="/backend/dist/fontawesome/css/all.css" />

<cfif fileExists("/frontend/dist/css/frontend-min.css")>
    <link rel="stylesheet" type="text/css" href="/frontend/dist/css/frontend-min.css?v=1.0.0" />
<cfelse>
    <link rel="stylesheet" type="text/css" href="/frontend/dist/css/frontend.css" />
</cfif>
