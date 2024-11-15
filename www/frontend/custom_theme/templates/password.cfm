<cfparam name="session.step" default="1">

<!--- Enter the email --->
<cfif session.step eq 1>

    <cfinclude template="forms/password_1.cfm">

<!--- Enter the new password --->
<cfelseif session.step eq 2>

    <cfinclude template="forms/password_2.cfm">

</cfif>
