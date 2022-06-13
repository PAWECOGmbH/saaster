<cfscript>
    if (structKeyExists(url, "newlng") or isNumeric(url.newlng)){
        try {

            qGetLngIso = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    lngID: {type: "numeric", value: url.newlng}
                },
                sql = "
                    SELECT strLanguageISO, strLanguageEN
                    FROM languages
                    WHERE intLanguageID = :lngID
                "
            )

            qGetLanguage = queryExecute(
                options = {datasource = application.datasource},
                sql = "
                    SELECT strString#qGetLngIso.strLanguageISO#, strStringEN, strVariable
                    FROM system_translations
                "
            )

        } catch(any e){
            throw(e.message);
            abort;
        }

    } else {
        getAlert('No language found!', 'warning');
        location url="step3.cfm" addtoken=false;
    }
</cfscript>

<cfinclude template="top.cfm">
    <div class="card-body">
        <div class="steps steps-counter steps-blue">
            <a href="step1.cfm" class="step-item "></a>
            <a href="step2.cfm" class="step-item "></a>
            <span href="#" class="step-item active"></span>
            <span href="#" class="step-item"></span>
        </div>
        <h2 class="card-title text-center mb-4">Translate new language</h2>
        <p>
            Please translate all of the following texts.
            You can also have them translated automatically using the DeepL API. </br>
            Create a free account <a href="https://www.deepl.com/de/pro#developer" target="_blank">here!</a>
        </p>
        <cfoutput>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>

            <div class="alert alert-info" id="loadingAlert" style="display: none;" role="alert">
                <h4 class="alert-title">Translating<span id="loadingPoints" class="animated-dots"></span></h4>
                <div class="text-muted">This can take a couple minutes.</div>
            </div>

            <form onsubmit="loading()" action="translate.cfm?do=trans" method="post">
                <label for="apiKey">API Key</label>
                <input type="text" name="apiKey" class="form-control" minlength="10" maxlength="100" placeholder="Please enter a valid API key..." required>
                <input type="hidden" name="lng" value="#qGetLngIso.strLanguageISO#">
                <input type="hidden" name="lngID" value="#url.newlng#">
                <div class="form-selectgroup pt-1">
                    <label class="form-selectgroup-item ">
                        <input type="radio" name="apiType" id="apiFree" value="0" class="form-selectgroup-input" checked>
                        <span class="form-selectgroup-label">
                            DeepL API Free
                        </span>
                    </label>
                    <label class="form-selectgroup-item">
                        <input type="radio" name="apiType" id"apiPro" value="1" class="form-selectgroup-input">
                        <span class="form-selectgroup-label">
                            DeepL API Pro
                        </span>
                    </label>
                </div>
                <div class="mt-2">
                    <button id="transButton" class="btn btn-primary btn-block">
                        Translate
                    </button>
                </div>
            </form>
        </cfoutput>
    </div>
</div>

<cfoutput>
    <div class="container-xl">
        <div class="row">
            <div class="col-md-12 col-lg-12">
                <div class="card">
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table card-table table-vcenter text-wrap">
                                <thead>
                                    <tr>
                                        <th width="50%">English</th>
                                        <th width="50%">#qGetLngIso.strLanguageEN#</th>
                                        <th>action</th>
                                    </tr>
                                </thead>
                                <cfset counter = 1>
                                <cfloop query="qGetLanguage">
                                    <form action="translate.cfm?do=save" method="post">
                                        <tr>
                                        <cfset counter++>
                                            <td>
                                                <a name="anchor_#counter#">#strStringEN#</a>
                                                <input type="hidden" name="anchor" value="anchor_#counter#">
                                                <input type="hidden" name="lng" value="#qGetLngIso.strLanguageISO#">
                                                <input type="hidden" name="fieldToEdit" value="#strVariable#">
                                                <input type="hidden" name="lngID" value="#url.newlng#">
                                            </td>
                                            <td>
                                                <textarea class="form-control" name="text">#evaluate("strString#ucase(qGetLngIso.strLanguageISO)#")#</textarea>
                                            </td>
                                            <td>
                                                <button class="btn btn-primary btn-block float-end">
                                                    Save
                                                </button>
                                            </td>
                                        </tr>
                                    </form>
                                </cfloop>
                            </table>
                        </div>
                        </br>
                        <form action="step4.cfm" method="post">
                            <input type="hidden" name="langID" value="#url.newlng#">
                            <input type="hidden" name="translated" value="1">
                            <button class="btn btn-primary btn-block float-end mx-3">
                                Continue
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</cfoutput>

<script>
    function loading() {
        document.getElementById('loadingAlert').style.display='';
    }
</script>

<cfinclude template="bottom.cfm">
