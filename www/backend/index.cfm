<cfoutput>

<!doctype html>
<html lang="#session.lng#">

<cfinclude template="/backend/core/views/head.cfm">
<cfinclude template="/backend/core/views/header.cfm">

<body #getLayout.layoutBody#>
</cfoutput>
	<div class="page">
		<cfif fileExists(thiscontent.thisPath) or fileExists("/" & thiscontent.thisPath)>
			<cfinclude template="/#thiscontent.thisPath#">
		<cfelse>
			<cfinclude template="/backend/core/views/dashboard.cfm">
		</cfif>
	</div>
	<cfinclude template="/backend/core/views/footer.cfm">
	<cfinclude template="/backend/core/views/js.cfm">
	<cfif structKeyExists(session, "filledData") and not structKeyExists(session, "redirect")>
		<cfinclude template="/backend/core/views/fill_data_modal.cfm">
		<script type="text/javascript">
			$(window).on('load', function() {
				$('#fillData').modal('show');
			});
		</script>
	</cfif>
	<div id="dynModal" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
		<div class="modal-dialog modal-dialog-centered modal-dialog-scrollable" role="document">
			<div class="modal-content" id="dyn_modal-content">
				<!--- dynamic content from ajax request --->
			</div>
		</div>
	</div>
</body>
</html>
<cfset structDelete(session, "alert") />


