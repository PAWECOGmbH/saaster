
<cfscript>

qConfig = queryExecute(
    options = {datasource = application.datasource},
    sql = "
        SELECT *
        FROM config
    "
)

</cfscript>

<cfinclude template="top.cfm">

<div class="card-body">

    <div class="steps steps-counter steps-blue">
        <a href="#" class="step-item active"></a>
        <span href="#" class="step-item"></span>
        <span href="#" class="step-item"></span>
        <span href="#" class="step-item"></span>
    </div>

    <h2 class="card-title text-center mb-4">Application settings</h2>
    <p>
        First, let's configure your application.cfc. Overwrite the fields according to your needs.
    </p>

    <form action="step2.cfm" method="post">
        <input type="hidden" name="step1">
        <cfoutput query="qConfig">
            <div class="mb-3">
                <label class="form-label">#qConfig.strVariable#</label>
                <input type="text" name="#qConfig.strVariable#" class="form-control" value="#HTMLEditFormat(qConfig.strValue)#" maxlength="100" required>
                <small class="form-hint mt-0">
                    #qConfig.strDescription#
                </small>
            </div>
        </cfoutput>
        <div class="mb-3 text-center">
            <button type="submit" class="btn btn-primary w-100">Save and next</button>
        </div>
    </form>

</div>

<cfinclude template="bottom.cfm">