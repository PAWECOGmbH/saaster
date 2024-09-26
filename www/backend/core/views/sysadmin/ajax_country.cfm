<cfsetting showdebugoutput="no">
<cfscript>

    objSysadmin = new backend.core.com.sysadmin();

    setting showdebugoutput = false;
    param name="url.countryID" default=0 type="numeric";

    if(not isNumeric(url.countryID)){
        abort;
    }

    qCountry = objSysadmin.getCountryAjax(url.countryID);

</cfscript>

<cfif qCountry.recordCount>

    <cfset qTotalCountries = objSysadmin.getCountriesAjax()>
    <cfset qLanguages = application.objLanguage.getAllLanguages()>
    <cfset timeZones = new backend.core.com.time(session.customer_id).getTimezones()>

    <cfoutput>
        <form action="#application.mainURL#/sysadm/countries" method="post">
            <input type="hidden" name="edit_country" value="#qCountry.intCountryID#">
            <div class="modal-header">
                <h5 class="modal-title">Edit country</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-lg-6 mb-3">
                        <label class="form-label">Country name *</label>
                        <input type="text" name="country" class="form-control" autocomplete="off" value="#HTMLEditFormat(qCountry.strCountryName)#" maxlength="100" required>
                    </div>
                    <div class="col-lg-6 mb-3">
                        <label class="form-label">Language</label>
                        <select name="languageID" class="form-select">
                            <cfloop query="qLanguages">
                                <option value="#qLanguages.intLanguageID#" <cfif qLanguages.intLanguageID eq qCountry.intLanguageID>selected</cfif>>#qLanguages.strLanguageEN#</option>
                            </cfloop>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-3">
                        <div class="mb-3">
                            <label class="form-label">Locale</label>
                            <div class="input-group input-group-flat">
                                <input type="text" class="form-control" name="locale" autocomplete="off" value="#HTMLEditFormat(qCountry.strLocale)#" maxlength="20">
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-3">
                        <div class="mb-3">
                            <label class="form-label">ISO 1</label>
                            <div class="input-group input-group-flat">
                                <input type="text" class="form-control" name="iso1" autocomplete="off" value="#HTMLEditFormat(qCountry.strISO1)#" maxlength="3">
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-3">
                        <div class="mb-3">
                            <label class="form-label">ISO 2</label>
                            <div class="input-group input-group-flat">
                                <input type="text" class="form-control" name="iso2" autocomplete="off" value="#HTMLEditFormat(qCountry.strISO2)#" maxlength="3">
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-3">
                        <div class="mb-3">
                            <label class="form-label">Currency</label>
                            <div class="input-group input-group-flat">
                                <input type="text" class="form-control" name="currency" autocomplete="off" value="#HTMLEditFormat(qCountry.strCurrency)#" maxlength="20">
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-6 mb-3">
                        <label class="form-label">Region</label>
                        <input type="text" name="region" class="form-control" autocomplete="off" value="#HTMLEditFormat(qCountry.strRegion)#" maxlength="100">
                    </div>
                    <div class="col-lg-6 mb-3">
                        <label class="form-label">Subregion</label>
                        <input type="text" name="subregion" class="form-control" autocomplete="off" value="#HTMLEditFormat(qCountry.strSubRegion)#" maxlength="100">
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-5 mb-3">
                        <label class="form-label">Flag</label>
                        <input type="text" name="flag" class="form-control" autocomplete="off" value="#HTMLEditFormat(qCountry.strFlagSVG)#" maxlength="255">
                    </div>
                    <div class="col-lg-1 mb-3 pt-4">
                        <cfif fileExists(qCountry.strFlagSVG)>
                            <img src="#qCountry.strFlagSVG#" style="max-height: 30px;" alt="Flag of #qCountry.strCountryName#">
                        </cfif>
                    </div>
                    <div class="col-lg-6 mb-3">
                        <label class="form-label">Timezone</label>
                        <select name="timezoneID" class="form-select">
                            <cfloop array="#timeZones#" index="i">
                                <option value="#i.id#" <cfif i.id eq qCountry.intTimezoneID>selected</cfif>>(#i.utc#) #i.city# - #i.timezone#</option>
                            </cfloop>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-2 mb-3">
                        <label class="form-label">Prio</label>
                        <input type="number" name="prio" min="1" max="#qTotalCountries.totalCountries#" class="form-control" autocomplete="off" value="#qCountry.intPrio#" required>
                    </div>
                    <div class="col-lg-4 mb-3"></div>
                    <div class="col-lg-6 mb-3">
                        <label class="form-label">Default</label>
                        <label class="form-check form-switch">
                            <cfif qCountry.blnDefault>
                                <input class="form-check-input" type="checkbox" name="default" checked disabled>
                                <input type="hidden" name="default" value="on">
                            <cfelse>
                                <input class="form-check-input" type="checkbox" name="default">
                            </cfif>
                            <span class="form-check-label">Default country</span>
                        </label>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                <button type="submit" class="btn btn-primary ms-auto">Save changes</button>
            </div>
        </form>
    </cfoutput>

<cfelse>

    No country found!

</cfif>