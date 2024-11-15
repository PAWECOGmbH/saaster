
<cfscript>

// Handle logout logic and display alert if applicable
application.objCoreUtil.handleLogout();

// Redirect user if already logged in
application.objCoreUtil.redirectIfLoggedIn();

// Set default session email if not set
param name="session.email" default="";

</cfscript>

<!--- Include the login form --->
<cfinclude template="forms/login.cfm">


<script>
    var isLogout = <cfif structKeyExists(url, "logout")>true<cfelse>false</cfif>;
</script>