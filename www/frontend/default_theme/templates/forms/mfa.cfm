<cfoutput>

<div class="container-sm py-4 px-3 mx-auto w-25">

    <div class="card">

        <div class="card-header">
            #getTrans('titMfa')#
        </div>

        <form id="mfa_form" method="post" action="#application.mainURL#/logincheck?uuid=#uuid#">
            <input type="hidden" name="mfa_btn">
            <div class="card-body">
                <cfif structKeyExists(session, "alert")>
                    #session.alert#
                </cfif>
                <cfif structKeyExists(session, "mfaCheckCount") and session.mfaCheckCount lt 3>
                    <div class="d-flex justify-content-center align-items-center">
                        <div class="p-3 bg-light rounded">
                            <p class="text-center mb-3">#getTrans('txtmfaLead')#</p>
                            <div class="d-flex otp-field justify-content-center">
                                <input type="text" name="mfa_1" maxlength="1" class="form-control text-center mx-1 code-input" style="width: 45px; height: 50px;">
                                <input type="text" name="mfa_2" maxlength="1" class="form-control text-center mx-1 code-input" style="width: 45px; height: 50px;">
                                <input type="text" name="mfa_3" maxlength="1" class="form-control text-center mx-1 code-input" style="width: 45px; height: 50px;">
                                <input type="text" name="mfa_4" maxlength="1" class="form-control text-center mx-1 code-input" style="width: 45px; height: 50px;">
                                <input type="text" name="mfa_5" maxlength="1" class="form-control text-center mx-1 code-input" style="width: 45px; height: 50px;">
                                <input type="text" name="mfa_6" maxlength="1" class="form-control text-center mx-1 code-input" style="width: 45px; height: 50px;">
                            </div>
                        </div>
                    </div>
                </cfif>
            </div>
        </form>

        <div class="form-footer text-center mb-3">
            <a role="button" href="#application.mainURL#/logincheck?resend=1&uuid=#uuid#">#getTrans('txtResendMfa')#</a>
        </div>

    </div>

</div>

</cfoutput>