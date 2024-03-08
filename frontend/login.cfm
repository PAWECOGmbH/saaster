
<cfscript>
    if (structKeyExists(url, "logout")) {
        getAlert('alertLoggedOut', 'info');
    } else if (structKeyExists(session, "user_id") and session.user_id gt 0) {
        structDelete(session, "alert");
        location url="#application.mainURL#/dashboard" addtoken="false";
    }
    param name="session.email" default="";

    getSysadminData = application.objSysadmin.getSysAdminData();
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

            <form id="submit_form" class="card card-md" method="post" action="#application.mainURL#/registration">
                <input type="hidden" name="login_btn">
                <div class="card-body">
                    <h2 class="card-title text-center mb-4">#getTrans('formSignIn')#</h2>
                    <cfif structKeyExists(session, "alert")>
                        #session.alert#
                    </cfif>
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formEmailAddress')#</label>
                        <input type="email" name="email" class="form-control" value="#session.email#" required autofocus>
                    </div>
                    <div class="mb-2">
                        <label class="form-label">#getTrans('formPassword')#</label>
                        <div class="input-group input-group-flat">
                            <input type="password" name="password" class="form-control" required>
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
<cfset structDelete(session, "alert") />