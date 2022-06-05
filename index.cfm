
<!--- If a session exists, we fetch the customer data in this file, because we need the data on almost every page. --->
<cfif structKeyExists(session, "customer_id")>
<cfset getCustomerData = application.objCustomer.getCustomerData(session.customer_id)>
</cfif>

<!doctype html>
<html lang="<cfoutput>#session.lng#</cfoutput>">

<cfinclude template="includes/head.cfm">
<body>
	<div class="page">
		<cfinclude template="#thiscontent.thisPath#">
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

