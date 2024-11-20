<cfoutput>

<div class="container py-4 px-3 mx-auto w-25">

    <div class="card">

        <div class="card-header">
            #getTrans('titChoosePassword')#
        </div>

        <form id="submit_form" method="post" action="#application.mainURL#/logincheck">
            <input type="hidden" name="reset_pw_btn_2">
            <div class="card-body">
                <cfif structKeyExists(session, "alert")>
                    #session.alert#
                </cfif>
                <div class="form-group mb-3">
                    <label class="form-label">#getTrans('formPassword')#</label>
                    <input type="password" name="password" class="form-control" required maxlenght="100" minlength="8">
                </div>
                <div class="form-group mb-3">
                    <label class="form-label">#getTrans('formPassword2')#</label>
                    <input type="password" name="password2" class="form-control" required maxlenght="100" minlength="8">
                </div>
                <div class="form-footer">
                    <button type="submit" id="submit_button" class="btn btn-primary btn-block w-100">#getTrans('titResetPassword')#</button>
                </div>
            </div>
        </form>

    </div>

</div>

</cfoutput>