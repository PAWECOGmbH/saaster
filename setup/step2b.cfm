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
        SELECT strCountryList
        FROM setup_saaster
    "
)

</cfscript>


<cfinclude template="top.cfm">

<div class="card-body">

    <div class="steps steps-counter steps-blue">
        <a href="step1.cfm" class="step-item "></a>
        <span href="#" class="step-item active"></span>
        <span href="#" class="step-item"></span>
        <span href="#" class="step-item"></span>
    </div>

    <h2 class="card-title text-center mb-4">Choose your countries</h2>
    <p>
        Now select all countries in which your offer can be bought:
    </p>

    <cfoutput>
    <form action="step3.cfm" method="post">
        <div class="mb-3 mt-5">
            <div class="mb-3">
                <div class="divide-y">
                    <cfloop query="qCountries">
                        <div>
                            <label class="row">
                                <span class="col">#qCountries.strCountryName#</span>
                                <span class="col-auto">
                                    <label class="form-check form-check-single form-switch">
                                        <input type="checkbox" name="countryID" value="#qCountries.intCountryID#" class="form-check-input" <cfif listFind(qSetup.strCountryList,qCountries.intCountryID)>checked</cfif>>
                                    </label>
                                </span>
                            </label>
                        </div>
                    </cfloop>
                </div>
            </div>
        </div>
        <div class="mb-3 text-center">
            <button type="submit" class="btn btn-primary w-100">Save and next</button>
        </div>
    </form>
    </cfoutput>

</div>

<cfinclude template="bottom.cfm">