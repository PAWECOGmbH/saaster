<cfscript>

// Retrieve prepared session data for registration
sessionData = application.objCoreUtil.getRegisterSessionData();

// Retrieve additional data (countries, time zones) if step 3 is active
additionalData = application.objCoreUtil.getAdditionalRegisterData();

// Load the reCAPTCHA script if the Site Key is set
recaptchaScript = application.objCoreUtil.getRecaptchaScript(variables.reCAPTCHA_site_key);

</cfscript>

<cfoutput>

<!--- Google reCAPTCHA --->
#recaptchaScript#

<!--- Enter first name, surname, e-mail address and language --->
<cfif sessionData.step eq 1>

    <cfinclude template="forms/register_1.cfm">

<!--- Set password --->
<cfelseif sessionData.step eq 2>

    <cfinclude template="forms/register_2.cfm">

<!--- Enter remaining address data and country or time zone --->
<cfelseif sessionData.step eq 3>

    <cfinclude template="forms/register_3.cfm">

</cfif>

</cfoutput>

<!--- Include the modal for privacy text --->
<cfinclude template="modals/privacy.cfm">