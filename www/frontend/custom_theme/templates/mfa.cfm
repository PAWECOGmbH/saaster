
<cfscript>
    // Call the utility function to handle UUID and MFA checks
    application.objCoreUtil.handleUUIDandMFA();
</cfscript>

<!--- Include the mfa form --->
<cfinclude template="forms/mfa.cfm">