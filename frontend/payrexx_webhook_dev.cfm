
<!--- This file is only used for development purposes and must not be uploaded to production environments. --->

<cfif isDefined("form")>
<cfset data = GetHttpRequestData()>
<cffile action="write" file="#expandPath("test.json")#" output="#data.content#" charset="utf-8">
</cfif>

