
<cfscript>
    getSysadminData = application.objSysadmin.getSysAdminData();
    if(structKeyExists(url, 'uid')){
        uid = url.uid;
    } else {
        uid = 0;
    };
</cfscript>

<cfoutput>
<div class="border-top-wide border-primary d-flex flex-column">

    <div class="page page-center">

        <div class="container-tight py-4">
            <div class="text-center mb-4">
                <cfif len(trim(getSysadminData.logo))>
                    <a href="./" class="navbar-brand navbar-brand-autodark"><img src="#application.mainURL#/userdata/images/logos/#getSysadminData.logo#" height="80" alt="Logo"></a>
                <cfelse>
                    <a href="./" class="navbar-brand navbar-brand-autodark"><img src="#application.mainURL#/dist/img/logo.svg" height="80" alt="Logo"></a>
                </cfif>
            </div>
            
            <form id="mfa_form" class="card card-md otc" method="post" action="#application.mainURL#/registration?uid=#uid#">
                <input type="hidden" name="mfa_btn">
                <div class="card-body">

                    <h2 class="card-title text-center mb-4">#getTrans('titMfa')#</h2>

                    <cfif structKeyExists(session, "alert")>
                        #session.alert#
                    </cfif>
                    <cfif session.mfaCheckCount lt 3>
                        <div class="mb-3">

                            <label class="form-label">#getTrans('txtMfaLable')#</label>
                            <!--- <input type="text" name="email" class="form-control" value="#session.email#" required> --->
                            <input type="number" pattern="[0-9]*"  value="" inputtype="numeric" autocomplete="one-time-code" id="otc-1" name="mfa_1" required>
                            <!-- Autocomplete not to put on other input -->
                            <input type="number" pattern="[0-9]*" min="0" max="9" maxlength="1"  value="" inputtype="numeric" id="otc-2" name="mfa_2" required>
                            <input type="number" pattern="[0-9]*" min="0" max="9" maxlength="1"  value="" inputtype="numeric" id="otc-3" name="mfa_3" required>
                            <input type="number" pattern="[0-9]*" min="0" max="9" maxlength="1"  value="" inputtype="numeric" id="otc-4" name="mfa_4" required>
                            <input type="number" pattern="[0-9]*" min="0" max="9" maxlength="1"  value="" inputtype="numeric" id="otc-5" name="mfa_5" required>
                            <input type="number" pattern="[0-9]*" min="0" max="9" maxlength="1"  value="" inputtype="numeric" id="otc-6" name="mfa_6" required>

                        </div>
                    </cfif>
                    

                </div>
                <!--- <div class="text-center mt-2">
                    #getTrans('formRegisterText')# <a href="#application.mainURL#/register">#getTrans('formSignUp')#</a>
                </div>
                <div class="text-center mt-1 mb-4">
                    #getTrans('formForgotPassword')# <a href="#application.mainURL#/password">#getTrans('formReset')#</a>
                </div> --->
            </form>
            
            
            <div class="form-footer text-center">
                <a role="button" href="#application.mainURL#/registration?resend=1&uid=#uid#">#getTrans('txtResendMfa')#</a>
                <!--- <button type="button" id="resend_button" class="btn btn-primary w-100">#getTrans('txtResendMfa')#</button> --->
            </div>

        </div>
    </div>
</div>
</cfoutput>
