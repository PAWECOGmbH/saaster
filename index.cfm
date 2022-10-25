<cfoutput>
<!doctype html>
<html lang="#session.lng#">

<cfinclude template="includes/head.cfm">
<body #application.layoutStruct.layoutBody#>
</cfoutput>
	<div class="page">
		<cfif fileExists(thiscontent.thisPath)>
			<cfinclude template="#thiscontent.thisPath#">
		<cfelse>
			<cfinclude template="/frontend/start.cfm">
		</cfif>
	</div>
	<cfinclude template="includes/js.cfm">
	<cfif structKeyExists(session, "filledData")>
		<cfinclude template="/includes/fill_data_modal.cfm">
		<script type="text/javascript">
			$(window).on('load', function() {
				$('#fillData').modal('show');
			});
		</script>
	</cfif>
</body>
</html>
<cfset structDelete(session, "alert") />

