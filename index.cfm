
<!--- If a session exists, we fetch the customer data in this file, because we need the data on almost every page. --->
<cfscript>
	if (structKeyExists(session, "customer_id")) {
		getCustomerData = application.objCustomer.getCustomerData(session.customer_id);
		getTime = application.getTime;
	}
</cfscript>

<!doctype html>
<html lang="<cfoutput>#session.lng#</cfoutput>">

<cfinclude template="includes/head.cfm">
<body>
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

