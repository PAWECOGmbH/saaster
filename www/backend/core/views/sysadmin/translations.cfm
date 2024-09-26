<cfscript>
    param name="session.search" default="" type="string";
    param name="url.tr" default="custom" type="string";
    param name="session.visTrans" default="0" type="numeric";
    param name="session.displayLanguage" default="#application.objLanguage.getDefaultLanguage().iso#" type="string";

    objSysadmin = new backend.core.com.sysadmin();

    s_badge_custom = "";
    s_badge_system = "";

    if(structKeyExists(form, "displayLanguage")){
        session.displayLanguage = form.displayLanguage;
    }

    if(structKeyExists(url, "vis")) {
        switch(url.vis) {
            case "show":
                session.search = "";
                session.visTrans = 1;
                break;

            case "hide":
                session.search = "";
                session.visTrans = 0;
                break;

            default:
                session.visTrans = 0;
        }
    }

    if(structKeyExists(form, "search") and len(trim(form.search))) {
        session.search = form.search;
    } else if (structKeyExists(form, "delete")) {
        session.search = "";
    }

    // The language query is used in order to translate entries
    qLanguages = objSysadmin.getLanguages();

    // When entering a search
    if(len(trim(session.search))) {
        session.visTrans = 0

        qCustomResults = objSysadmin.searchCustomTranslations(session.search);

        s_badge_custom = "";

        if(qCustomResults.recordCount){
            s_badge_custom = "<span class='mx-2 badge bg-green'>#qCustomResults.recordCount#</span>";
        }else {
            s_badge_custom = "<span class='mx-2 badge bg-red'>0</span>";
        }

        qSystemResults = objSysadmin.searchSystemTranslations(session.search);

        s_badge_system = "";

        if(qSystemResults.recordCount){
            s_badge_system = "<span class='mx-2 badge bg-green'>#qSystemResults.recordCount#</span>";
        }else {
            s_badge_system = "<span class='mx-2 badge bg-red'>0</span>";
        }

        // Create getModal object
        getModal = new backend.core.com.translate();
    }

    if(session.visTrans) {
        qSystemResults = objSysadmin.getSystemTranslations();
        qCustomResults = objSysadmin.getCustomTranslations();
    }
</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">
                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Translations</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Translations</li>
                        </ol>
                    </div>
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
            <div class="alert alert-info" id="loadingAlert" style="display: none;" role="alert">
                <h4 class="alert-title">Translating<span id="loadingPoints" class="animated-dots"></span></h4>
                <div class="text-muted">This can take a couple of minutes.</div>
            </div>
        </div>
        <div class="#getLayout.layoutPage#">
            <div class="row">
                <div class="col-md-12 col-lg-12">
                    <div class="card">
                        <ul class="nav nav-tabs" data-bs-toggle="tabs">
                            <li class="nav-item"><a href="##custom" class="nav-link <cfif url.tr eq "custom">active</cfif>" data-bs-toggle="tab">Custom translations #s_badge_custom#</a></li>
                            <li class="nav-item"><a href="##system" class="nav-link <cfif url.tr eq "system">active</cfif>" data-bs-toggle="tab">System translations #s_badge_system#</a></li>
                            <li class="nav-item"><a href="##bulk" class="nav-link <cfif url.tr eq "bulk">active</cfif>" data-bs-toggle="tab">Bulk translate</a></li>
                        </ul>
                    </div>
                    <div class="tab-content">
                        <div id="custom" class="card tab-pane show <cfif url.tr eq "custom">active</cfif>">
                            <div class="card-body">
                                <div class="card-title">Custom translations</div>
                                <p>Here you can create your own translations (variables). These are used for system texts and are called with the function "getTrans()". These translations are not affected by any system updates.</p>
                                <div class="row">
                                    <div class="col-lg-4">
                                        <form action="#application.mainURL#/sysadmin/translations" method="post">
                                            <label class="form-label">Search for translations:</label>
                                            <div class="input-group mb-2">
                                                <input type="text" name="search" class="form-control" minlength="3" placeholder="Search for…">
                                                <button class="btn bg-green-lt" type="submit">Go!</button>
                                                <cfif len(trim(session.search))>
                                                    <button class="btn bg-red-lt" name="delete" type="submit">Delete search!</button>
                                                </cfif>
                                            </div>
                                        </form>
                                    </div>
                                    <div class="col-lg-2 trans-display-lng">
                                        <form action="#application.mainURL#/sysadmin/translations?tr=custom" method="post">
                                            <label class="form-label">Display language:</label>
                                            <div>
                                                <select onchange="this.form.submit()" name="displayLanguage" class="form-select" required>
                                                    <cfoutput query="qLanguages">
                                                        <option value="#qLanguages.strLanguageISO#" <cfif session.displayLanguage eq qLanguages.strLanguageISO> selected </cfif>>#qLanguages.strLanguageEN#</option>
                                                    </cfoutput>
                                                </select>
                                            </div>
                                        </form>
                                    </div>
                                    <div class="col-lg-3 px-4">
                                        <a  data-bs-toggle="modal" data-bs-target="##lng_trans" class="btn btn-primary trans-btn">
                                            <i class="fas fa-plus pe-3"></i> Add custom translation
                                        </a>
                                    </div>
                                    <div class="col-lg-3 text-end px-4">
                                        <cfif session.visTrans>
                                            <a href="#application.mainURL#/sysadmin/translations?vis=hide&tr=custom" class="btn btn-primary trans-btn">
                                                <i class="fas fa-eye-slash  pe-3"></i>
                                                Hide translations
                                            </a>
                                        <cfelse>
                                            <a href="#application.mainURL#/sysadmin/translations?vis=show&tr=custom" class="btn btn-primary trans-btn">
                                                <i class="fas fa-eye pe-3"></i>
                                                Show all translations
                                            </a>
                                        </cfif>
                                    </a>
                                </div>
                                </div>
                                <div class="row">

                                    <div class="table-responsive">
                                        <table class="table table-vcenter card-table">
                                            <cfif len(trim(session.search)) or session.visTrans>
                                                <thead>
                                                    <tr>
                                                        <th width="30%">Variable</th>
                                                        <th width="65%">Text (#session.displayLanguage#)</th>
                                                        <th width="5%"></th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                <cfif qCustomResults.recordCount>
                                                    <cfloop query="qCustomResults">
                                                        <cfset transTextCustom = HTMLCodeFormat(Left(evaluate("qCustomResults.strString#ucase(session.displayLanguage)#"), 250)) >
                                                        <tr>
                                                            <td>#qCustomResults.strVariable#</td>
                                                            <td>
                                                                <div class="trans-container">
                                                                    <div class="trans-text">
                                                                        #transTextCustom#
                                                                    </div>
                                                                    <div>
                                                                        <a href="##?" class="trans-link input-group-link" data-bs-toggle="modal" data-bs-target="##modal_#qCustomResults.intCustTransID#">
                                                                            <i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate content"></i>
                                                                        </a>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                            <td class="text-left">
                                                                <a href="#application.mainURL#/sysadm/translations?delete_trans=#qCustomResults.intCustTransID#" title="Delete">
                                                                    <i class="fas fa-times text-red" style="font-size: 20px;"></i>
                                                                </a>
                                                            </td>
                                                        </tr>


                                                        <!--- Modal for translations --->
                                                        <div id="modal_#qCustomResults.intCustTransID#" class="modal modal-blur fade" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
                                                            <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                                                <form action="#application.mainURL#/sysadm/translations" method="post">
                                                                <input type="hidden" name="edit_variable" value="#qCustomResults.intCustTransID#">
                                                                    <div class="modal-content">
                                                                        <div class="modal-header">
                                                                            <h5 class="modal-title">Translate content</h5>
                                                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                                        </div>
                                                                        <div class="modal-body">
                                                                            <p></p>
                                                                            <cfloop query="qLanguages">
                                                                                <div class="mb-3">
                                                                                    <div class="hr-text hr-text-left my-2">#qLanguages.strLanguageEN#</div>
                                                                                    <textarea onclick='this.style.height = "";this.style.height = this.scrollHeight + "px"' class="form-control" name="text_#qLanguages.strLanguageISO#" placeholder="Text in #lcase(qLanguages.strLanguageEN)#" required>#evaluate("qCustomResults.strString#ucase(qLanguages.strLanguageISO)#")#</textarea>
                                                                                </div>
                                                                            </cfloop>
                                                                        </div>
                                                                        <div class="modal-footer">
                                                                            <a class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                                            <button type="submit" class="btn btn-primary ms-auto">
                                                                                Save translation
                                                                            </button>
                                                                        </div>
                                                                    </div>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </cfloop>
                                                <cfelse>
                                                    <tr><td colspan="100%">No results found.</td></tr>
                                                </cfif>
                                                </tbody>
                                            </cfif>

                                            <!--- Modal for new translations --->
                                            <div id="lng_trans" class="modal modal-blur fade" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
                                                <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                                    <form action="#application.mainURL#/sysadm/translations" method="post">
                                                    <input type="hidden" name="new_variable">
                                                        <div class="modal-content">
                                                            <div class="modal-header">
                                                                <h5 class="modal-title">New translation</h5>
                                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                            </div>
                                                            <div class="modal-body">
                                                                <div class="mb-3">
                                                                    <label class="form-label">Variable</label>
                                                                    <input type="text" class="form-control" name="variable" placeholder="Add new variable" minlength="3" maxlength="100" required>
                                                                </div>
                                                                <cfloop query="qLanguages">
                                                                    <div class="mb-3">
                                                                        <div class="hr-text hr-text-left my-2">#qLanguages.strLanguageEN#</div>
                                                                        <textarea oninput='this.style.height = "";this.style.height = this.scrollHeight + "px"' class="form-control" name="text_#qLanguages.strLanguageISO#" placeholder="Text in #lcase(qLanguages.strLanguageEN)#" required></textarea>
                                                                    </div>
                                                                </cfloop>
                                                            </div>
                                                            <div class="modal-footer">
                                                                <a  class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                                <button type="submit" class="btn btn-primary ms-auto">
                                                                    Save translation
                                                                </button>
                                                            </div>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </table>
                                    </div>
                                </div>
                            </div>

                        </div>
                        <div id="system" class="card tab-pane show <cfif url.tr eq "system">active</cfif>">
                            <div class="card-body">
                                <div class="card-title">System translations</div>
                                <p class="text-red">The system translations are used by the developers of the saaster.io project. Users of the tool should only perform translations and not change any variables. Co-developers can request changes via Github.</p>
                                <div class="row">
                                    <div class="col-lg-4">
                                        <form action="#application.mainURL#/sysadmin/translations?tr=system" method="post">
                                            <label class="form-label">Search for translations:</label>
                                            <div class="input-group mb-2">
                                                <input type="text" name="search" class="form-control" minlength="3" placeholder="Search for…">
                                                <button class="btn bg-green-lt" type="submit">Go!</button>
                                                <cfif len(trim(session.search))>
                                                    <button class="btn bg-red-lt" name="delete" type="submit">Delete search!</button>
                                                </cfif>
                                            </div>
                                        </form>
                                    </div>
                                    <div class="col-lg-2 trans-display-lng">
                                        <form action="#application.mainURL#/sysadmin/translations?tr=system" method="post">
                                            <label class="form-label">Display language:</label>
                                            <div>
                                                <select onchange="this.form.submit()" name="displayLanguage" class="form-select" required>
                                                    <cfoutput query="qLanguages">
                                                        <option value="#qLanguages.strLanguageISO#" <cfif session.displayLanguage eq qLanguages.strLanguageISO> selected </cfif>>#qLanguages.strLanguageEN#</option>
                                                    </cfoutput>
                                                </select>
                                            </div>
                                        </form>
                                    </div>
                                    <div class="col-lg-6 text-end px-4">
                                            <cfif session.visTrans>
                                                <a href="#application.mainURL#/sysadmin/translations?vis=hide&tr=system" class="btn btn-primary trans-btn">
                                                    <i class="fas fa-eye-slash  pe-3"></i>
                                                    Hide translations
                                                </a>
                                            <cfelse>
                                                <a href="#application.mainURL#/sysadmin/translations?vis=show&tr=system" class="btn btn-primary trans-btn">
                                                    <i class="fas fa-eye pe-3"></i>
                                                    Show all translations
                                                </a>
                                            </cfif>
                                        </a>
                                    </div>
                                </div>
                                <div class="row">
                                    <cfif len(trim(session.search)) or session.visTrans>
                                        <cfif qSystemResults.recordCount>
                                            <div class="table-responsive">
                                                <table class="table table-vcenter card-table">
                                                    <thead>
                                                        <tr>
                                                            <th width="30%">Variable</th>
                                                            <th width="70%">Text (#session.displayLanguage#)</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <cfloop query="qSystemResults">
                                                            <cfset transText = HTMLCodeFormat(Left(evaluate("qSystemResults.strString#session.displayLanguage#"), 250)) >
                                                            <tr>
                                                                <td>#qSystemResults.strVariable#</td>
                                                                <td>
                                                                    <div class="trans-container">
                                                                        <div class="trans-text">
                                                                            #transText#
                                                                        </div>
                                                                        <div>
                                                                            <a href="##?" class="trans-link input-group-link" data-bs-toggle="modal" data-bs-target="##syst_modal_#qSystemResults.intSystTransID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate content"></i></a>
                                                                        </div>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                            <!--- Modal for translations --->
                                                            <div id="syst_modal_#qSystemResults.intSystTransID#" class="modal modal-blur fade" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
                                                                <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                                                    <form action="#application.mainURL#/sysadm/translations" method="post">
                                                                    <input type="hidden" name="edit_syst_variable" value="#qSystemResults.intSystTransID#">
                                                                        <div class="modal-content">
                                                                            <div class="modal-header">
                                                                                <h5 class="modal-title">Translate content</h5>
                                                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                                            </div>
                                                                            <div class="modal-body">
                                                                                <p></p>
                                                                                <cfloop query="qLanguages">
                                                                                    <div class="mb-3">
                                                                                        <div class="hr-text hr-text-left my-2">#qLanguages.strLanguageEN#</div>
                                                                                        <textarea onclick='this.style.height = "";this.style.height = this.scrollHeight + "px"' class="form-control" name="text_#qLanguages.strLanguageISO#" placeholder="Text in #lcase(qLanguages.strLanguageEN)#" required>#evaluate("qSystemResults.strString#ucase(qLanguages.strLanguageISO)#")#</textarea>
                                                                                    </div>
                                                                                </cfloop>
                                                                            </div>
                                                                            <div class="modal-footer">
                                                                                <a  class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                                                <button type="submit" class="btn btn-primary ms-auto">
                                                                                    Save translation
                                                                                </button>
                                                                            </div>
                                                                        </div>
                                                                    </form>
                                                                </div>
                                                            </div>
                                                        </cfloop>
                                                    </tbody>
                                                </table>
                                            </div>
                                        <cfelse>
                                            <p>No results found.</p>
                                        </cfif>
                                    </cfif>
                                </div>
                            </div>

                        </div>

                        <div id="bulk" class="card tab-pane show <cfif url.tr eq "bulk">active</cfif>">
                            <div class="card-body">
                                <div class="card-title">Bulk translate</div>
                                <p>
                                    Here you can translate a complete language via the Deepl API.
                                    A <a href="https://www.deepl.com/pro-api" target="_blank">Deepl API</a> key is required for this. Please check whether the language you want to translate is supported.
                                </p>
                                <form onsubmit="loading()" id="submit_form" class="col-lg-9 row" action="#application.mainURL#/sysadm/translations" method="post">
                                    
                                    <div class="col-lg-5">
                                        <label for="fromLang">From:</label>
                                        <select onchange="checkIfSame()" id="fromLang" name="fromLang" class="form-select" required>
                                            <option value="">Select Language</option>
                                            <cfoutput query="qLanguages">
                                                <option value="#qLanguages.strLanguageISO#">#qLanguages.strLanguageEN#</option>
                                            </cfoutput>
                                        </select>
                                    </div>

                                    <div class="col-lg-2 trans-arrow-box">
                                        <i class="fa fa-long-arrow-right trans-arrow" aria-hidden="true"></i>
                                    </div>

                                    <div class="col-lg-5">
                                        <label for="toLang">To:</label>
                                        <select onchange="checkIfSame()" id="toLang" name="toLang" class="form-select" required>
                                            <option value="">Select Language</option>
                                            <cfoutput query="qLanguages">
                                                <option value="#qLanguages.strLanguageISO#">#qLanguages.strLanguageEN#</option>
                                            </cfoutput>
                                        </select>
                                    </div>
                                    <br>

                                    <label for="apiKey">API Key:</label>
                                    <div class="col-lg-8">
                                        <input type="text" name="apiKey" class="form-control" minlength="10" maxlength="100" placeholder="Please enter a valid API key..." required="">
                                        <input type="hidden" name="bulk_translate">
                                    </div>
                                    <div class="col-lg-2">
                                        <label class="form-selectgroup-item">
                                            <input type="radio" name="apiType" id="apiFree" value="0" class="form-selectgroup-input" checked="">
                                            <span class="form-selectgroup-label">
                                                DeepL API Free
                                            </span>
                                        </label>
                                    </div>
                                    <div class="col-lg-2">
                                        <label class="form-selectgroup-item">
                                            <input type="radio" name="apiType" id"apipro"="" value="1" class="form-selectgroup-input">
                                            <span class="form-selectgroup-label">
                                                DeepL API Pro
                                            </span>
                                        </label>
                                    </div>
                                    <div> 
                                        <br>
                                        <p>Choose what you would like to translate:</p>
                                        <label class="form-check">
                                            <input name="transCus" value="1" class="form-check-input" type="checkbox" checked>
                                            <span class="form-check-label">Custom translations</span>
                                        </label>
                                        <label class="form-check">
                                            <input name="transSys" value="1" class="form-check-input" type="checkbox" checked>
                                            <span class="form-check-label">System translations</span>
                                        </label>
                                    </div>
                                    <div class="mt-2 trans-submit-btn">
                                        <button id="submit_button" class="btn btn-primary btn-block" disabled>
                                            Translate
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <script>
                            function checkIfSame() {
                                const TranslateButton = document.getElementById('submit_button');

                                var fromLang = document.getElementById("fromLang");
                                var toLang = document.getElementById("toLang");

                                var textFromLang = fromLang.options[fromLang.selectedIndex].text;
                                var texttoLang = toLang.options[toLang.selectedIndex].text;

                                if (textFromLang === texttoLang || textFromLang == "Select Language" || texttoLang == "Select Language") {
                                    TranslateButton.setAttribute('disabled', '');
                                }else {
                                    TranslateButton.removeAttribute('disabled', '')
                                }
                            }

                            function loading() {
                                document.getElementById('loadingAlert').style.display='';
                            }
                        </script>

                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    

</div>