<cfscript>
    param name="form.translated" default=0; 

    if (!structKeyExists(form, "langID") or !isNumeric(form.langID)) {
        getAlert('Please choose the default language!', 'warning');
        location url="step3.cfm" addtoken="false";
    }

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            lID: {type: "numeric", value: form.langID}
        },
        sql = "
            UPDATE setup_saaster
            SET intDefaultLanguageID = :lID
        "
    )
    
    // Lets translate content, if its a new language
    if (form.langID neq 1 and form.langID neq 2 and form.translated neq 1) {
        location url="step3b.cfm?newlng=#form.langID#" addtoken="false";
    }

    qCurrencies = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT intCurrencyID, strCurrencyISO, strCurrencyEN
            FROM currencies
            ORDER BY intPrio
        "
    )
</cfscript>


<cfinclude template="top.cfm">

<div class="card-body">

    <div class="steps steps-counter steps-blue">
        <a href="step1.cfm" class="step-item "></a>
        <a href="step2.cfm" class="step-item "></a>
        <a href="step3.cfm" class="step-item "></a>
        <span href="#" class="step-item active"></span>
    </div>

    <h2 class="card-title text-center mb-4">Choose your default currency</h2>
    <p>
        If you miss your default currency, just choose another one. You can add more currencies later.
    </p>

    <cfoutput>
    <form action="end.cfm" method="post">
        <div class="mb-3">
            <div class="divide-y">
                <cfloop query="qCurrencies">
                    <label class="form-check">
                        <input type="radio" name="currencyID" value="#qCurrencies.intCurrencyID#" class="form-check-input">
                        <span class="form-check-label">#qCurrencies.strCurrencyEN# (#qCurrencies.strCurrencyISO#)</span>
                    </label>
                </cfloop>
            </div>
        </div>
        <div class="mb-3 text-center">
            <button type="submit" class="btn btn-primary w-100">Save and finish setup</button>
        </div>
    </form>
    </cfoutput>

</div>

<cfinclude template="bottom.cfm">