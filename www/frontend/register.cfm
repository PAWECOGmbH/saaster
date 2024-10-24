<cfscript>

    if (structKeyExists(session, "user_id") and session.user_id gt 0) {
        if (!structKeyExists(session, "step")) {
            location url="#application.mainURL#/dashboard" addtoken="false";
        }
    }

    param name="session.step" default="1";
    param name="session.first_name" default="";
    param name="session.name" default="";
    param name="session.company" default="";
    param name="session.email" default="";
    getSysadminData = application.objSysadmin.getSysAdminData();

    if (session.step eq 3) {
        qCountries = application.objGlobal.getCountry(language=session.lng);
        timeZones = new backend.core.com.time().getTimezones();
    }

</cfscript>

<cfoutput>
<cfif len(trim(variables.reCAPTCHA_site_key))>
     <script src="https://www.google.com/recaptcha/api.js"></script>
     <script>
        function onSubmit(token) {
            document.getElementById("submit_form").submit();
        }
    </script>
</cfif>
<div class="page page-center">
    <div class="container-tight py-4">
        <div class="text-center mb-4">
            <cfif len(trim(getSysadminData.logo))>
                <a href="./" class="navbar-brand navbar-brand-autodark"><img src="/userdata/images/logos/#getSysadminData.logo#" height="80" alt="Logo"></a>
            <cfelse>
                <a href="./" class="navbar-brand navbar-brand-autodark"><img src="/assets/img/logo.svg" height="80" alt="Logo"></a>
            </cfif>
        </div>
        <cfif session.step eq 1>
            <form class="card card-md" id="submit_form" method="post" action="#application.mainURL#/logincheck?reinit=3">
                <input type="hidden" name="register_btn">
                <div class="card-body">
                    <h2 class="card-title text-center mb-4">#getTrans('formSignUp')#</h2>
                    <cfif structKeyExists(session, "alert")>
                        #session.alert#
                    </cfif>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formFirstName')# *</label>
                        <input type="text" name="first_name" class="form-control" value="#session.first_name#" minlength="3" maxlenght="100" required autofocus>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formName')# *</label>
                        <input type="text" name="name" class="form-control" value="#session.name#"  minlength="3" maxlenght="100" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formCompanyName')#</label>
                        <input type="text" name="company" class="form-control" value="#session.company#" minlength="5" maxlenght="100">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formEmailAddress')# *</label>
                        <input type="email" name="email" class="form-control" value="#session.email#" minlength="5" maxlenght="100" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formLanguage')#</label>
                        <select name="language" class="form-select">
                            <cfloop list="#application.allLanguages#" index="i">
                                <cfset lngIso = listfirst(i,"|")>
                                <cfset lngName = listlast(i,"|")>
                                <option value="#lngIso#" <cfif lngIso eq session.lng>selected</cfif>>#lngName#</option>
                            </cfloop>
                        </select>
                    </div>
                    <div class="mb-4">
                        <label class="form-check">
                            <input type="checkbox" class="form-check-input" required>
                            <span class="form-check-label"><a href="##" data-bs-toggle="modal" data-bs-target="##privacy_policy">#getTrans('txtAgreePolicy')#</a></span>
                        </label>
                    </div>
                    <div class="mb-4">
                        <div class="g-recaptcha" data-sitekey="#variables.reCAPTCHA_site_key#"></div>
                    </div>
                    <div class="form-footer">
                        <button id="submit_button" type="submit" class="btn btn-primary w-100">#getTrans('titCreateNewAccount')#</button>
                    </div>
                    <div class="text-center text-muted mt-4">
                        #getTrans('formAlreadyHaveAccount')# <a href="#application.mainURL#/login">#getTrans('formSignIn')#</a>
                    </div>
                </div>
            </form>
        <cfelseif session.step eq 2>

            <form class="card card-md" id="submit_form" method="post" action="#application.mainURL#/logincheck">
                <input type="hidden" name="create_account">
                <div class="card-body">
                    <h2 class="card-title text-center mb-4">#getTrans('titChoosePassword')#</h2>
                    <cfif structKeyExists(session, "alert")>
                        #session.alert#
                    </cfif>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formPassword')#</label>
                        <input type="password" name="password" class="form-control" placeholder="#getTrans('formPassword')#" required message="#getTrans('alertEnterPassword1')#" maxlenght="100" minlength="8"  autofocus>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formPassword2')#</label>
                        <input type="password" name="password2" class="form-control" placeholder="#getTrans('formPassword2')#" required message="#getTrans('alertEnterPassword2')#" maxlenght="100" minlength="8">
                    </div>
                    <div class="form-footer">
                        <button type="submit" class="btn btn-primary w-100">#getTrans('titCreateNewAccount')#</button>
                    </div>
                </div>
            </form>
        <cfelseif session.step eq 3>
            <form class="card card-md" id="submit_form" method="post" action="#application.mainURL#/logincheck">
                <input type="hidden" name="fill_remaining_data">
                <div class="card-body">
                    <h2 class="card-title text-center mb-4">#getTrans('txtUpdateInformation')#</h2>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formCompanyName')#</label>
                        <input type="text" name="company" class="form-control" value="#HTMLEditFormat(session.company)#" minlength="3" maxlength="100" >
                    </div>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formContactName')# *</label>
                        <input type="text" name="contact" class="form-control" value="#HTMLEditFormat(session.first_name)# #HTMLEditFormat(session.name)#" minlength="3" maxlength="100" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formAddress')# *</label>
                        <input type="text" name="address" class="form-control" value="" minlength="3" maxlength="100" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formAddress2')#</label>
                        <input type="text" name="address2" class="form-control" value="" maxlength="100">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formZIP')# *</label>
                        <input type="text" name="zip" class="form-control" value="" minlength="4" maxlength="10" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formCity')# *</label>
                        <input type="text" name="city" class="form-control" value="" minlength="3" maxlength="100" required>
                    </div>
                    <cfif qCountries.recordCount>
                        <div class="mb-3">
                            <label class="form-label">#getTrans('formCountry')# *</label>
                            <select name="countryID" class="form-select" required>
                                <option value=""></option>
                                <cfloop query="qCountries">
                                    <option value="#qCountries.intCountryID#">#qCountries.strCountryName#</option>
                                </cfloop>
                            </select>
                        </div>
                    <cfelse>
                        <div class="mb-3">
                            <label class="form-label">#getTrans('titTimezone')# *</label>
                            <select name="timezoneID" class="form-select" required>
                                <option value=""></option>
                                <cfloop array="#timeZones#" index="i">
                                    <option value="#i.id#">#i.timezone# - #i.city# (#i.utc#)</option>
                                </cfloop>
                            </select>
                        </div>
                    </cfif>
                    <div>
                        <button type="submit" id="submit_button" class="btn btn-primary">#getTrans('btnSave')#</button>
                    </div>
                </div>
            </form>
        </cfif>
    </div>
</div>
<div id="privacy_policy" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
    <form action="step3.cfm" method="post">
        <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">#getTrans('titlePrivacyPolicy')#</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    #getTrans('txtPrivacyPolicy')#
                </div>
            </div>
        </div>
    </form>
</div>
</cfoutput>
<cfset structDelete(session, "alert") />