
<cfscript>

qCountries = queryExecute(
    options = {datasource = application.datasource},
    sql = "
        SELECT intCountryID, strCountryName
        FROM countries
        ORDER BY strCountryName
    "
)

qSetup = queryExecute(
    options = {datasource = application.datasource},
    sql = "
        SELECT intDefaultCountryID
        FROM setup_saaster
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

    <h2 class="card-title text-center mb-4">Your main country</h2>
    <p>
        Please select the country you want to define as the default country.
        You can add more countries later.
    </p>

    <form action="step2.cfm" method="post">
        <div class="mb-3">
            <select name="countryID" class="form-select" id="select_box" required>
                <option value="">Select Country</option>
                <cfoutput query="qCountries">
                    <option value="#qCountries.intCountryID#" <cfif qCountries.intCountryID eq qSetup.intDefaultCountryID>selected</cfif>>#qCountries.strCountryName#</option>
                </cfoutput>
            </select>
        </div>
        <div class="mb-3 text-center">
            <button type="submit" class="btn btn-primary w-100">Save and next</button>
        </div>
    </form>

</div>

<cfinclude template="bottom.cfm">