<cfoutput>

    <!--- Include the header template for the active theme --->
    <cfinclude template="#application.activeTheme#/templates/header.cfm">

    <!--- Check if a specific content file exists (from frontend_mappings in the database) --->
    <cfif fileExists(thiscontent.thisPath)>

        <!--- Include the specific content file if it exists --->
        <cfinclude template="/#thiscontent.thisPath#">

    <!--- If no specific file is found, load the default home page --->
    <cfelse>
        <cfinclude template="#application.activeTheme#/templates/home.cfm">
    </cfif>

    <!--- Include the footer template for the active theme --->
    <cfinclude template="#application.activeTheme#/templates/footer.cfm">

</cfoutput>

<!--- Clear any existing alert messages in the session --->
<cfset structDelete(session, "alert") />