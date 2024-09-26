<cfscript>

    if (structKeyExists(form, "new_lang")) {

        param name="form.lng_en" default="";
        param name="form.lng_own" default="";
        param name="form.iso" default="";

        try {

            qNewPrio = queryExecute(
                options = {datasource = application.datasource},
                sql = "
                    SELECT MAX(intPrio)+1 as newPrio
                    FROM languages
                "
            )

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    lng_en: {type: "varchar", value: left(form.lng_en, 20)},
                    lng_own: {type: "varchar", value: left(form.lng_own, 20)},
                    iso: {type: "varchar", value: left(form.iso, 2)},
                    newPrio: {type: "numeric", value: qNewPrio.newPrio}
                },
                sql = "
                    ALTER TABLE system_translations ADD COLUMN strString#ucase(form.iso)# longtext;
                    ALTER TABLE custom_translations ADD COLUMN strString#ucase(form.iso)# longtext;
                    INSERT INTO languages (strLanguageISO, strLanguageEN, strLanguage, intPrio, blnDefault, blnChooseable)
                    VALUES (:iso, :lng_en, :lng_own, :newPrio, 0, 1)
                "
            )

            getAlert('Language added!');
            location url="step2.cfm" addtoken="false";

        } catch (any e) {

            throw(e.message);
            abort;

        }

    }

    param name="form.translated" default=0;

    if (!structKeyExists(form, "langID") or !isNumeric(form.langID)) {
        getAlert('Please choose the default language!', 'warning');
        location url="step2.cfm" addtoken="false";
    }

    // Lets translate content, if its a new language
    if (form.langID neq 1 and form.langID neq 2 and form.translated neq 1) {
        location url="step2b.cfm?newlng=#form.langID#" addtoken="false";
    }


    if (structKeyExists(form, "langID")) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                lngID: {type: "numeric", value: form.langID}
            },
            sql = "
                UPDATE languages SET blnDefault = 0;
                UPDATE languages
                SET blnDefault = 1
                WHERE intLanguageID = :lngID
            "
        )

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