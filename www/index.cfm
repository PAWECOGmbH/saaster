<cfif findNoCase("backend", thiscontent.thisPath)>
    <cfinclude template="/backend/index.cfm">
<cfelse>
    <cfinclude template="/frontend/index.cfm">
</cfif> 