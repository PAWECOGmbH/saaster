<cfscript>
    getSysadminData = application.objSysadmin.getSysAdminData();
</cfscript>
<cfparam name="session.step" default="1">

<div class="w-100 login-page">
<div class="container mx-auto w-100 pb-5 pt-3 page page-center d-flex justify-content-start align-items-center">

    <div class="container-tight py-4">
        <cfoutput>
            <div class="text-center mb-4">
               <!-- <cfif len(trim(getSysadminData.logo))>
                    <a href="./" class="navbar-brand navbar-brand-autodark"><img src="#application.mainURL#/userdata/images/logos/#getSysadminData.logo#" height="80" alt="Logo"></a>
                <cfelse>
                    <a href="./" class="navbar-brand navbar-brand-autodark"><img src="#application.mainURL#/dist/img/logo.svg" height="80" alt="Logo"></a>
                </cfif> -->
            </div>

            <cfif session.step eq 1>
                <form class="card" id="submit_form" method="post" action="#application.mainURL#/logincheck">
                    <input type="hidden" name="reset_pw_btn_1">
                    <div class="card-body p-6">
                        <div class="text-left card-title mb-4 login-head pt-3">
                            <h2>
                                #getTrans('titResetPassword')#
                            </h2>
                        </div>
                        <cfif structKeyExists(session, "alert")>
                            #session.alert#
                        </cfif>
                        <div class="form-group mb-3">
                            <label class="form-label pb-2" for="InputEmail1">#getTrans('formEmailAddress')#</label>
                            <input type="email" name="email" placeholder="#getTrans('formEnterEmail')#" class="form-control" id="InputEmail1" required>
                        </div>
                        <div class="form-footer">
                            <button type="submit" id="sumbit_button" class="btn btn-submit login-btn btn-pill fs-2 text-white w-100"  style="height: 55px;">
                                #getTrans('formReset')#
                            </button>
                        </div>
                        <div class="text-center mt-4 fs-3 fg-pass">
                            #getTrans('formAlreadyHaveAccount')# <a href="#application.mainURL#/login">#getTrans('formSignIn')#</a>
                        </div>
                    </div>
                </form>
            <cfelseif session.step eq 2>
                <form class="card" id="submit_form" method="post" action="#application.mainURL#/logincheck">
                    <input type="hidden" name="reset_pw_btn_2">
                    <div class="card-body p-6">
                        <div class="card-title text-center mb-4">#getTrans('titChoosePassword')#</div>
                        <cfif structKeyExists(session, "alert")>
                            #session.alert#
                        </cfif>
                        <div class="form-group mb-2">
                            <label class="form-label">#getTrans('formPassword')#</label>
                            <input type="password" name="password" class="form-control" required maxlenght="100" minlength="8">
                        </div>
                        <div class="form-group">
                            <label class="form-label">#getTrans('formPassword2')#</label>
                            <input type="password" name="password2" class="form-control" required maxlenght="100" minlength="8">
                        </div>
                        <div class="form-footer">
                            <button type="submit" id="submit_button" class="btn btn-primary btn-block w-100">#getTrans('titResetPassword')#</button>
                        </div>
                    </div>
                </form>
            </cfif>
        </cfoutput>
    </div>
    </div>
</div>

<cfset structDelete(session, "alert") />