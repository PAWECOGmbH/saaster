<cfoutput>

<div class="container py-4 px-3 mx-auto my-5" style="max-width: 500px;">

    <div class="card">

        <div class="card-header">
            #getTrans('formSignUp')#
        </div>

        <form id="submit_form" method="post" action="#application.mainURL#/logincheck">
            <input type="hidden" name="register_btn">
            <div class="card-body">
                <cfif structKeyExists(session, "alert")>
                    #session.alert#
                </cfif>
                <div class="mb-3">
                    <label class="form-label">#getTrans('formFirstName')# *</label>
                    <input type="text" name="first_name" class="form-control" value="#sessionData.first_name#" minlength="3" maxlenght="100" required autofocus>
                </div>
                <div class="mb-3">
                    <label class="form-label">#getTrans('formName')# *</label>
                    <input type="text" name="name" class="form-control" value="#sessionData.name#"  minlength="3" maxlenght="100" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">#getTrans('formCompanyName')#</label>
                    <input type="text" name="company" class="form-control" value="#sessionData.company#" minlength="5" maxlenght="100">
                </div>
                <div class="mb-3">
                    <label class="form-label">#getTrans('formEmailAddress')# *</label>
                    <input type="email" name="email" class="form-control" value="#sessionData.email#" minlength="5" maxlenght="100" required>
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

    </div>

</div>

</cfoutput>