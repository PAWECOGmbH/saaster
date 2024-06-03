
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
                    <a href="./" class="navbar-brand navbar-brand-autodark">
                        <img src="#application.mainURL#/userdata/images/logos/#getSysadminData.logo#" height="80" alt="Logo">
                    </a>
                <cfelse>
                    <a href="./" class="navbar-brand navbar-brand-autodark">
                        <img src="#application.mainURL#/dist/img/logo.svg" height="80" alt="Logo">
                    </a>
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
                            <input type="number" inputmode="numeric" pattern="[0-9]*" autocomplete="one-time-code" id="otc-1" name="mfa_1" maxlength="1" class="mfa-input" oninput="validateInput(this)" onkeydown="handleKeyDown(event, this, 0)" required>
                            <input type="number" inputmode="numeric" pattern="[0-9]*" maxlength="1" id="otc-2" name="mfa_2" class="mfa-input" oninput="validateInput(this)" onkeydown="handleKeyDown(event, this, 1)" required>
                            <input type="number" inputmode="numeric" pattern="[0-9]*" maxlength="1" id="otc-3" name="mfa_3" class="mfa-input" oninput="validateInput(this)" onkeydown="handleKeyDown(event, this, 2)" required>
                            <input type="number" inputmode="numeric" pattern="[0-9]*" maxlength="1" id="otc-4" name="mfa_4" class="mfa-input" oninput="validateInput(this)" onkeydown="handleKeyDown(event, this, 3)" required>
                            <input type="number" inputmode="numeric" pattern="[0-9]*" maxlength="1" id="otc-5" name="mfa_5" class="mfa-input" oninput="validateInput(this)" onkeydown="handleKeyDown(event, this, 4)" required>
                            <input type="number" inputmode="numeric" pattern="[0-9]*" maxlength="1" id="otc-6" name="mfa_6" class="mfa-input" oninput="validateInput(this)" onkeydown="handleKeyDown(event, this, 5)" required>
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

<!--- <script>
    document.addEventListener('DOMContentLoaded', function() {
        const mfaInputs = document.querySelectorAll('.mfa-input');
    
        mfaInputs.forEach(function(input, index) {
            input.addEventListener('input', function(e) {
                if (this.value.length > 1) {
                    this.value = this.value.slice(0, 1); // Ensure only one digit
                }
    
                if (this.value.length === 1 && index < mfaInputs.length - 1) {
                    mfaInputs[index + 1].focus(); // Move to the next input
                }
            });
    
            input.addEventListener('keydown', function(e) {
                if (e.key === 'Backspace' && this.value.length === 0 && index > 0) {
                    mfaInputs[index - 1].focus(); // Move to the previous input
                }
            });
    
            input.addEventListener('focus', function(e) {
                // Ensure that focus moves to the first empty input field
                for (let i = 0; i < mfaInputs.length; i++) {
                    if (mfaInputs[i].value === '') {
                        mfaInputs[i].focus();
                        break;
                    }
                }
            });
        });
    
        document.getElementById('mfa_form').addEventListener('paste', function(e) {
            let paste = (e.clipboardData || window.clipboardData).getData('text');
            paste = paste.slice(0, mfaInputs.length);
            mfaInputs.forEach((input, index) => {
                input.value = paste[index] || '';
            });
    
            if (paste.length === mfaInputs.length) {
                e.preventDefault();
                this.submit();
            }
        });
    
        function validateCode() {
            return Array.from(mfaInputs).every(input => input.value.length === 1);
        }
    
        mfaInputs[mfaInputs.length - 1].addEventListener('input', function() {
            if (validateCode()) {
                document.getElementById('mfa_form').submit();
            }
        });
    });
    
    function validateInput(input) {
        input.value = input.value.replace(/\s/g, '');
    
        if (input.value.length > 1) {
            input.value = input.value.slice(0, 1);
        }
    }
    
    function onlyDigits(event) {
        var charCode = (event.which) ? event.which : event.keyCode;
        if (charCode > 31 && (charCode < 48 || charCode > 57)) {
            event.preventDefault();
            return false;
        }
        return true;
    }
    </script> --->
    