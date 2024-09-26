
<cfscript>
    getSysadminData = application.objSysadmin.getSysAdminData();
    if(structKeyExists(url, 'uuid')){
        uuid = url.uuid;
        if (structKeyExists(session, "mfaCheckCount") and session.mfaCheckCount gte 3) {
            getAlert(getTrans('txtThreeTimeTry'), 'warning');
        }
    };
</cfscript>

<cfoutput>

<div class="page page-center">

    <div class="container-tight py-4">
        <div class="text-center mb-4">
            <cfif len(trim(getSysadminData.logo))>
                <a href="./" class="navbar-brand navbar-brand-autodark"><img src="#application.mainURL#/userdata/images/logos/#getSysadminData.logo#" height="80" alt="Logo"></a>
            <cfelse>
                <a href="./" class="navbar-brand navbar-brand-autodark"><img src="#application.mainURL#/dist/img/logo.svg" height="80" alt="Logo"></a>
            </cfif>
        </div>

        <form id="mfa_form" class="card card-md otc" method="post" action="#application.mainURL#/logincheck?uuid=#uuid#">
            <input type="hidden" name="mfa_btn">
            <div class="card-body">

                <h2 class="card-title text-center mb-4">#getTrans('titMfa')#</h2>
                <cfif structKeyExists(session, "alert")>
                    #session.alert#
                </cfif>
                <cfif structKeyExists(session, "mfaCheckCount") and session.mfaCheckCount lt 3>
                    <p class="text-center">#getTrans('txtmfaLead')#</p>
                    <div class="mb-3 text-center">
                        <label class="form-label">#getTrans('txtMfaLable')#</label>
                        <input type="number" pattern="[0-9]*" value="" inputtype="numeric" autocomplete="one-time-code" id="otc-1" name="mfa_1" maxlength="1" oninput="validateInput(this)" onkeypress="return onlyDigits(event)" required>
                        <input type="number" pattern="[0-9]*" min="0" max="9" maxlength="1"  value="" inputtype="numeric" id="otc-2" name="mfa_2" oninput="validateInput(this)" onkeypress="return onlyDigits(event)" required>
                        <input type="number" pattern="[0-9]*" min="0" max="9" maxlength="1"  value="" inputtype="numeric" id="otc-3" name="mfa_3" oninput="validateInput(this)" onkeypress="return onlyDigits(event)" required>
                        <input type="number" pattern="[0-9]*" min="0" max="9" maxlength="1"  value="" inputtype="numeric" id="otc-4" name="mfa_4" oninput="validateInput(this)" onkeypress="return onlyDigits(event)" required>
                        <input type="number" pattern="[0-9]*" min="0" max="9" maxlength="1"  value="" inputtype="numeric" id="otc-5" name="mfa_5" oninput="validateInput(this)" onkeypress="return onlyDigits(event)" required>
                        <input type="number" pattern="[0-9]*" min="0" max="9" maxlength="1"  value="" inputtype="numeric" id="otc-6" name="mfa_6" oninput="validateInput(this)" onkeypress="return onlyDigits(event)" required>

                    </div>
                </cfif>
            </div>
        </form>

        <div class="form-footer text-center">
            <a role="button" href="#application.mainURL#/logincheck?resend=1&uuid=#uuid#">#getTrans('txtResendMfa')#</a>
        </div>

    </div>
</div>

</cfoutput>
