<cfscript>
    if (structKeyExists(session, "user_id") and session.user_id gt 0) {
        location url="#application.mainURL#/dashboard" addtoken="false";
    }
    param name="session.step" default="1";
    param name="session.first_name" default="";
    param name="session.name" default="";
    param name="session.company" default="";
    param name="session.email" default="";
    getSysadminData = application.objSysadmin.getSysAdminData();
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
<div class="row page-center login-page">
    <div class="container-tight py-4">
        <cfif session.step eq 1>
            <form class="card card-md" id="submit_form" method="post" action="#application.mainURL#/logincheck?reinit=3">
                <input type="hidden" name="register_btn">
                <div class="card-body login-head">
                    <h2 class="card-head text-left mb-4">Stellensuche Registrierung</h2>
                    <cfif structKeyExists(session, "alert")>
                        <div class="mb-3">#session.alert#</div>
                    </cfif>
                    <div class="mb-4">
                         <label class="form-label pb-2 fs-3">#getTrans('formFirstName')# <span style="color: red;">*</span></label>
                        <input type="text" name="first_name" placeholder="#getTrans('formEnterFirstName')#" class="form-control" value="#session.first_name#" minlength="3" maxlenght="100" required autofocus>
                    </div>
                    <div class="mb-4">
                         <label class="form-label pb-2 fs-3">#getTrans('formName')# <span style="color: red;">*</span></label>
                        <input type="text" name="name" placeholder="#getTrans('formEnterName')#" class="form-control" value="#session.name#"  minlength="3" maxlenght="100" required>
                    </div>
                    <div class="mb-4">
                         <label class="form-label pb-2 fs-3">#getTrans('formEmailAddress')# <span style="color: red;">*</span></label>
                        <input type="email" name="email" placeholder="#getTrans('formEnterEmail')#" class="form-control" value="#session.email#" minlength="5" maxlenght="100" required>
                    </div>
                    <div class="mb-4">
                        <label class="form-label pb-2 fs-3">#getTrans('formCompanyName')# <span class="text-muted">(für Arbeitgeber zwingend)</span></label>
                        <input type="text" name="company" placeholder="#getTrans('formEnterCompanyName')#" class="form-control" value="#session.company#" minlength="5" maxlenght="100">
                    </div>
                    <div class="mb-4">
                        <label class="form-label pb-2 fs-3">#getTrans('formLanguage')#</label>
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
                            <span class="form-check-label"><a href="##" data-bs-toggle="modal" data-bs-target="##privacy_policy" style='padding-left: 8px;'> #getTrans('txtAgreePolicy')#</a></span>
                        </label>
                    </div>
                    <div class="mb-4">
                        <div class="g-recaptcha" data-sitekey="#variables.reCAPTCHA_site_key#"></div>
                    </div>
                    <div class="form-footer text-center mt-4">
                        <button id="submit_button" type="submit" class="btn btn-submit btn-pill text-white w-full"  style="font-size: 18px;">#getTrans('titCreateNewAccount')#</button>
                    </div>
                    <div class="text-center mt-4 fg-pass fs-3">
                        #getTrans('formAlreadyHaveAccount')# <a href="#application.mainURL#/login">#getTrans('formSignIn')#</a>
                    </div>
                </div>
            </form>
        <cfelseif session.step eq 2>
            <div class="text-center mb-4">
                <a href="./" class="navbar-brand navbar-brand-autodark"><img src="#application.mainURL#/dist/img/logo.svg" height="36" alt="Logo"></a>
            </div>
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
                        <button type="submit" class="btn btn-submit fs-3 btn-pill text-white">#getTrans('titCreateNewAccount')#</button>
                    </div>

                </div>
            </form>
        </cfif>
    </div>
</div>

<div id="privacy_policy" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
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
</div>
</cfoutput>
<cfset structDelete(session, "alert") />