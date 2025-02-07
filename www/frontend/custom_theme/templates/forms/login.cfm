<cfoutput>
<div class="container-fluid">
    <div class="py-4 mx-auto px-3 col-12 col-sm-8 col-md-5 col-lg-4 col-xl-4">

        <div class="card wd-50">

            <div class="card-header">
                #getTrans('formSignIn')#
            </div>

            <form id="submit_form" method="post" action="#application.mainURL#/logincheck">
                <input type="hidden" name="login_btn">
                <div class="card-body">
                    <cfif structKeyExists(session, "alert")>
                        #session.alert#
                    </cfif>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formEmailAddress')#</label>
                        <input type="email" name="email" class="form-control" value="#session.email#" required <cfif not len(trim(session.email))>autofocus</cfif>>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formPassword')#</label>
                        <div class="input-group input-group-flat">
                            <input type="password" name="password" class="form-control" required <cfif len(trim(session.email))>autofocus</cfif>>
                        </div>
                    </div>
                    <div class="form-footer">
                        <button type="submit" id="sumbit_button" class="btn btn-primary w-100">#getTrans('formSignIn')#</button>
                    </div>
                </div>
                <div class="text-center mt-2">
                    #getTrans('formRegisterText')# <a href="#application.mainURL#/register">#getTrans('formSignUp')#</a>
                </div>
                <div class="text-center mt-1 mb-4">
                    #getTrans('formForgotPassword')# <a href="#application.mainURL#/password">#getTrans('formReset')#</a>
                </div>
            </form>

        </div>

    </div>
</div>
</cfoutput>