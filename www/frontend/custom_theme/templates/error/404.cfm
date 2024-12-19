<cfheader statuscode="404" statustext="File Not Found">
<cfheader name="Connection" value="Close">

<cfif structKeyExists(session, "customer_id")>
    <cfset takeMeBackURL = "/dashboard">
<cfelse>
    <cfset takeMeBackURL = application.mainURL>
</cfif>

<!DOCTYPE html>
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Page Not Found</title>
    <cfinclude template="../../css/css-include.cfm">
</head>

<body>

<cfoutput>
<div class="px-4 py-5 my-5 text-center">
    <h1 class="display-5 fw-bold text-body-emphasis mb-4">404</h1>
    <div class="col-lg-4 mx-auto">
        <p class="lead mb-4">#getTrans('txt404Text')#</p>
        <div class="d-grid gap-2 d-sm-flex justify-content-sm-center">
            <a href="#takeMeBackURL#" type="button" class="btn btn-secondary btn-lg px-4 gap-3">#getTrans('txtTakeBack')#</a>
        </div>
    </div>
</div>
</cfoutput>

</body>

</body>
</html>


<script>
    if (window.location.pathname !== "/404") {
        history.replaceState({}, "Page Not Found", "/404");
    }
</script>