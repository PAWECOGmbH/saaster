<cfscript>

if (structKeyExists(form, "world") and form.world eq 0) {

    location url="step1b.cfm" addtoken="false";

} else if (structKeyExists(form, "world") and form.world eq 1) {

    queryExecute(
        options = {datasource = application.datasource},
        sql = "
            UPDATE countries
            SET blnDefault = 0,
                blnActive = 0

        "
    )

}

if (structKeyExists(form, "countryID")) {

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            countryID: {type: "numeric", value: form.countryID}
        },
        sql = "
            UPDATE countries
            SET blnDefault = 1
            WHERE intCountryID = :countryID

        "
    )

}


qLanguages = queryExecute(
    options = {datasource = application.datasource},
    sql = "
        SELECT intLanguageID, strLanguageEN, strLanguageISO
        FROM languages
        ORDER BY intPrio
    "
)

</cfscript>

<cfinclude template="top.cfm">

<div class="card-body">

    <div class="steps steps-counter steps-blue">
        <a href="step1.cfm" class="step-item "></a>
        <span href="#" class="step-item active"></span>
        <span href="#" class="step-item"></span>
    </div>

    <h2 class="card-title text-center mb-4">Choose your default language</h2>
    <p>
        Now select <b>the default language</b> in your project.<br />
        <span class="text-red">Note:</span> You <b>CANNOT</b> change the default language later!
    </p>

    <cfoutput>
    <cfif structKeyExists(session, "alert")>
        #session.alert#
    </cfif>
    <form action="step3.cfm" method="post">
        <div class="mb-3">
            <div class="mt-4">
                <cfloop query="qLanguages">
                    <label class="form-check">
                        <input type="radio" name="langID" value="#qLanguages.intLanguageID#" class="form-check-input" >
                        <span class="form-check-label">#qLanguages.strLanguageEN# (#qLanguages.strLanguageISO#)</span>
                    </label>
                </cfloop>
            </div>
        </div>
        <div class="mb-3">
            <p><a href="##" data-bs-toggle="modal" data-bs-target="##lng_new"><i class="fas fa-plus pe-3"></i> Add language</a></p>
            <p class="small">(Add a new language only if you miss your default language. You can add more languages later.)</p>
        </div>
        <div class="mb-3 text-center">
            <button type="submit" class="btn btn-primary w-100">Save and next</button>
        </div>
    </form>

    <div id="lng_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
        <form action="step3.cfm" method="post">
            <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">New language</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Language (english)</label>
                            <input type="text" name="lng_en" class="form-control" autocomplete="off" maxlength="20" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Language (in its language)</label>
                            <input type="text" name="lng_own" class="form-control" autocomplete="off" maxlength="20" required>
                        </div>
                        <div class="row">
                            <div class="col-lg-2">
                                <div class="mb-3">
                                    <label class="form-label">ISO code</label>
                                    <div class="input-group input-group-flat">
                                        <input type="text" class="form-control" name="iso" autocomplete="off" maxlength="2" required>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                        <button type="submit" name="new_lang" class="btn btn-primary ms-auto">
                            Save language
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
    </cfoutput>

</div>

<cfinclude template="bottom.cfm">