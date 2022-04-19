<cfscript>
    param name="session.step" default="";
    param name="session.first_name" default="";
    param name="session.name" default="";
    param name="session.company" default="";
    param name="session.email" default="";
</cfscript>

<cfoutput>
<body  class=" border-top-wide border-primary d-flex flex-column">
    <div class="page page-center">
        <div class="container-tight py-4">
            <cfif session.step eq 1>
                <div class="text-center mb-4">
                    <a href="./" class="navbar-brand navbar-brand-autodark"><img src="#application.mainURL#/dist/img/logo.svg" height="80" alt="Logo"></a>
                </div>
                <form class="card card-md" id="submit_form" method="post" action="./handler/register.cfm">
                    <input type="hidden" name="register_btn">
                    <div class="card-body">
                        <h2 class="card-title text-center mb-4">#getTrans('formSignUp')#</h2>
                        <cfif structKeyExists(session, "alert")>
                            #session.alert#
                        </cfif>

                        <div class="mb-3">
                            <label class="form-label">#getTrans('formFirstName')# *</label>
                            <input type="text" name="first_name" class="form-control" value="#session.first_name#" minlength="3" maxlenght="100" required>
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
                            <label class="form-check">
                                <input type="checkbox" class="form-check-input" required>
                                <span class="form-check-label">Agree the <a href="./" target="_blank">terms and policy</a></span>
                            </label>
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
                <div class="text-center mb-4">
                    <a href="./" class="navbar-brand navbar-brand-autodark"><img src="#application.mainURL#/dist/img/logo.svg" height="36" alt="Logo"></a>
                </div>
                <form class="card card-md" id="submit_form" method="post" action="./handler/register.cfm">
                    <input type="hidden" name="create_account">
                    <div class="card-body">
                        <h2 class="card-title text-center mb-4">#getTrans('titChoosePassword')#</h2>
                        <cfif structKeyExists(session, "alert")>
                            #session.alert#
                        </cfif>
                        <div class="mb-3">
                            <label class="form-label">#getTrans('formPassword')#</label>
                            <input type="password" name="password" class="form-control" placeholder="#getTrans('formPassword')#" required message="#getTrans('alertEnterPassword1')#" maxlenght="100" minlength="8">
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
            </cfif>
        </div>
    </div>
</body>
</cfoutput>


