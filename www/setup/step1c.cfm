<cfscript>

if (structKeyExists(form, "countryID")) {

    loop list=form.countryID index="i" {
        queryExecute(
            options = {datasource = application.datasource},
            params = {
                countryID: {type: "numeric", value: i}
            },
            sql = "
                UPDATE countries
                SET blnActive = 1
                WHERE intCountryID = :countryID

            "
        )
    }

}

qCountries = queryExecute(
    options = {datasource = application.datasource},
    sql = "
        SELECT intCountryID, strCountryName, blnDefault
        FROM countries
        WHERE blnActive = 1
        ORDER BY strCountryName
    "
)

</cfscript>


<cfinclude template="top.cfm">

<div class="card-body">

    <div class="steps steps-counter steps-blue">
        <span href="#" class="step-item active"></span>
        <span href="#" class="step-item"></span>
        <span href="#" class="step-item"></span>
    </div>

    <h2 class="card-title text-center mb-4">Your main country</h2>
    <p>
        Please select the country you want to define as the default country.
    </p>

    <form action="step2.cfm" method="post">
        <div class="mb-3">
            <select name="countryID" class="form-select" id="select_box" required>
                <option value="">Select Country</option>
                <cfoutput query="qCountries">
                    <option value="#qCountries.intCountryID#" <cfif qCountries.blnDefault eq 1>selected</cfif>>#qCountries.strCountryName#</option>
                </cfoutput>
            </select>
        </div>
        <div class="mb-3 text-center">
            <button type="submit" class="btn btn-primary w-100">Save and next</button>
        </div>
    </form>

</div>

<cfinclude template="bottom.cfm">