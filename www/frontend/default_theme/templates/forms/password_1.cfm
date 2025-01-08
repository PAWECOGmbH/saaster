<cfoutput>

<div class="container py-4 px-3 mx-auto my-5" style="max-width: 500px;">

    <div class="card">

        <div class="card-header">
            #getTrans('titResetPassword')#
        </div>

        <form id="submit_form" method="post" action="#application.mainURL#/logincheck">
            <input type="hidden" name="reset_pw_btn_1">
            <div class="card-body">
                <cfif structKeyExists(session, "alert")>
                    #session.alert#
                </cfif>
                <div class="form-group mb-3">
                    <label class="form-label" for="InputEmail1">#getTrans('formEmailAddress')#</label>
                    <input type="email" name="email" class="form-control" id="InputEmail1" required>
                </div>
                <div class="form-footer mb-4">
                    <button type="submit" id="submit_button" class="btn btn-primary btn-block w-100">#getTrans('formReset')#</button>
                </div>
                <div class="text-center text-muted">
                    #getTrans('formAlreadyHaveAccount')# <a href="#application.mainURL#/login">#getTrans('formSignIn')#</a>
                </div>
            </div>
        </form>

    </div>

</div>

</cfoutput>