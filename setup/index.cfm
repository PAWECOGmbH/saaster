
<!--- Check if the database and datasource is set up correctly --->
<cfscript>

try {

    qSetup = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT *
            FROM setup_saaster
        "
    )

    //Check if there is already an entry in the table
    if (!qSetup.recordCount) {
        queryExecute(
            options = {datasource = application.datasource},
            sql = "
                INSERT INTO setup_saaster (intDefaultCountryID)
                VALUES (0)
            "
        )
    }

} catch (any e) {

    getAlert(e.message, 'warning');

}

</cfscript>

<cfinclude template="top.cfm">

<div class="card-body">

    <h2 class="card-title text-center mb-4">Setup saaster</h2>

    <cfif structKeyExists(session, "alert")>
        <cfoutput>#session.alert#</cfoutput>
    </cfif>
    <div class="form-footer">
        <a href="step1.cfm" class="btn btn-primary w-100">Start</a>
    </div>

</div>

<cfinclude template="bottom.cfm">
