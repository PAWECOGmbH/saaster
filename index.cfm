<cfoutput>
<!doctype html>
<html lang="#session.lng#">

<cfinclude template="includes/head.cfm">
<body #getLayout.layoutBody# class="d-flex flex-column">
	
</cfoutput>
	
	<cfif fileExists(thiscontent.thisPath)>
		<cfinclude template="#thiscontent.thisPath#">
	<cfelse>
		<cfinclude template="/frontend/start.cfm">
	</cfif>
	
	<cfinclude template="includes/js.cfm">
	<cfif structKeyExists(session, "filledData")>
		<cfinclude template="/includes/fill_data_modal.cfm">
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


