
<!--- Check if the database and datasource is set up correctly --->
<cfscript>

try {

    qSetup = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT *
            FROM optin
        "
    )


} catch (any e) {

    getAlert(e.message, 'warning');

}

</cfscript>

<cfinclude template="top.cfm">

<div class="card-body">

    <h2 class="card-title text-center mb-4">Setup routine for saaster</h2>

    <cfif structKeyExists(session, "alert")>
        <cfoutput>#session.alert#</cfoutput>
    </cfif>
    <div class="form-footer">
        <a href="step1.cfm?reinit=4" class="btn btn-primary w-100">Start setup</a>
    </div>

</div>

<cfinclude template="bottom.cfm">
