<cfoutput>

<div class="container py-4 px-3 mx-auto w-25">

    <div class="card">

        <div class="card-header">
            #getTrans('titChoosePassword')#
        </div>

        <form id="submit_form" method="post" action="#application.mainURL#/logincheck">
            <input type="hidden" name="create_account">
            <div class="card-body">
                <cfif structKeyExists(session, "alert")>
                    #session.alert#
                </cfif>
                <div class="mb-3">
                    <label class="form-label">#getTrans('formPassword')#</label>
                    <input type="password" name="password" class="form-control" placeholder="#getTrans('formPassword')#" required message="#getTrans('alertEnterPassword1')#" maxlenght="100" minlength="8"  autofocus>
                </div>
                <div class="mb-3">
                    <label class="form-label">#getTrans('formPassword2')#</label>
                    <input type="password" name="password2" class="form-control" placeholder="#getTrans('formPassword2')#" required message="#getTrans('alertEnterPassword2')#" maxlenght="100" minlength="8">
                </div>
                <!--- Privacy policy if invited by admin --->
                <cfif (structKeyExists(url, 'invited') and url.invited eq "true")>
                    <div class="mb-4">
                        <label class="form-check">
                            <input type="checkbox" class="form-check-input" required>
                            <span class="form-check-label"><a href="##" data-bs-toggle="modal" data-bs-target="##privacy_policy">#getTrans('txtAgreePolicy')#</a></span>
                        </label>
                    </div>
                </cfif>
                <div class="form-footer">
                    <button type="submit" class="btn btn-primary w-100">#getTrans('titCreateNewAccount')#</button>
                </div>
            </div>
        </form>

    </div>

</div>

</cfoutput>