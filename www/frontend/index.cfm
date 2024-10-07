
<html>
    <cfinclude template="/frontend/includes/head.cfm">
    <cfinclude template="/frontend/includes/header.cfm">
    <cfinclude template="/frontend/includes/css.cfm">
<body>


    <cfif fileExists(thiscontent.thisPath) or fileExists("/" & thiscontent.thisPath)>
        <cfinclude template="/#thiscontent.thisPath#">
    <cfelse>
        <cfinclude template="/frontend/start.cfm">
    </cfif>


<cfinclude template="/frontend/includes/footer.cfm">
<cfinclude template="/frontend/includes/js.cfm">

</body>
</html>