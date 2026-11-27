<cfoutput>

<!doctype html>
<html lang="#session.lng#"<cfif getLayout.layoutString eq "combined"> data-bs-navbar-position="combined"</cfif>#application.themeStruct.htmlAttributes ?: ""#>

<cfinclude template="/backend/core/views/head.cfm">

<body #getLayout.layoutBody#>
</cfoutput>
    <div class="page">
        <cfinclude template="/backend/core/views/header.cfm">
        <div class="page-wrapper">
            <cfinclude template="/backend/core/views/status_banners.cfm">
            <cfif fileExists(thiscontent.thisPath) or fileExists("/" & thiscontent.thisPath)>
                <cfinclude template="/#thiscontent.thisPath#">
            <cfelse>
                <cfinclude template="/backend/core/views/dashboard.cfm">
            </cfif>
            <cfinclude template="/backend/core/views/footer.cfm">
        </div>
    </div>
	<div id="dynModal" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
		<div class="modal-dialog modal-dialog-centered modal-dialog-scrollable" role="document">
			<div class="modal-content" id="dyn_modal-content">
				<!--- dynamic content from ajax request --->
			</div>
		</div>
	</div>
	<cfinclude template="/backend/core/views/js.cfm">
</body>
</html>
<cfset structDelete(session, "alert") />


