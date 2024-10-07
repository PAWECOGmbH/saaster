
<cfscript>
    if (structKeyExists(url, "logout")) {
        getAlert('alertLoggedOut', 'info');
    } else if (structKeyExists(session, "user_id") and session.user_id gt 0) {
        structDelete(session, "alert");
        location url="#application.mainURL#/dashboard" addtoken="false";
    }
    param name="session.email" default="";

    getSysadminData = new backend.core.com.sysadmin().getSysAdminData();
</cfscript>

<cfoutput>


<div class="row page-center login-page py-4">

    <div class="container-tight py-4 px-3">

        <form id="submit_form" class="card card-md" method="post" action="#application.mainURL#/logincheck">
            <input type="hidden" name="login_btn">
            <div class="card-body login-head">
                <h2 class="mb-2">Stellensuche Login</h2>
                <cfif structKeyExists(session, "alert")>
                    <div class="mb-3">#session.alert#</div>
                </cfif>
                <div class="mt-4 mb-4">
                    <label class="form-label pb-2 fs-3">#getTrans('formEmailAddress')#</label>
                    <input type="email" name="email" placeholder="#getTrans('formEnterEmail')#" class="form-control" value="#session.email#" required autofocus>
                </div>
                <div class="mb-4">
                    <label class="form-label pb-2 fs-3">#getTrans('formPassword')#</label>
                    <div class="input-group input-group-flat">
                        <input type="password" name="password" placeholder="#getTrans('formPassword2')#" class="form-control" required>
                    </div>

                    <div class="text-left mt-3 mb-4 fg-pass">
                         #getTrans('formForgotPassword')# <a href="#application.mainURL#/password">#getTrans('formReset')#</a>
                    </div>
                </div>
                <div class="form-footer">
                    <button type="submit" id="sumbit_button" class="btn btn-submit login-btn btn-pill fs-2 text-white w-100">#getTrans('formSignIn')#</button>
                </div>
            </div>
            <div class="hr-text px-3 mb-3">#getTrans('txtOr')#</div>
            <div class="text-center mt-2 mb-4 fs-3 fg-pass">
                #getTrans('formRegisterText')#<br />
                <a href="/plans?g=1">Registrierung für Arbeitgeber</a><br />
                <a href="/plans?g=2">Registrierung für Fachkräfte</a>
            </div>

        </form>

    </div>

</div>

</cfoutput>
<cfset structDelete(session, "alert") />


<!--- Disable Browser-back after logout --->
<cfif structKeyExists(url, "logout")>
<script>
    (function (global) {
        if(typeof (global) === "undefined") {
            throw new Error("window is undefined");
        }
        var _hash = "!";
        var noBackPlease = function () {
            global.location.href += "#";

            global.setTimeout(function () {
                global.location.href += "!";
            }, 50);
        };
        global.onhashchange = function () {
            if (global.location.hash !== _hash) {
                global.location.hash = _hash;
            }
        };
        global.onload = function () {
            noBackPlease();
            document.body.onkeydown = function (e) {
                var elm = e.target.nodeName.toLowerCase();
                if (e.which === 8 && (elm !== 'input' && elm  !== 'textarea')) {
                    e.preventDefault();
                }
                e.stopPropagation();
            };
        }
    })(window);
</script>
</cfif>