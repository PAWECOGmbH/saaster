
<cfif isDefined("form")>
<cfset data = GetHttpRequestData()>
<cffile action="write" file="#expandPath("../payrexx/test.json")#" output="#data.content#" charset="utf-8">
</cfif>

