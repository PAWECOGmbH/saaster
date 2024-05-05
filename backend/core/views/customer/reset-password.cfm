  

<cfoutput>
<div class="page-wrapper" >
    <div class="#getLayout.layoutPage#">    
        <div class="#getLayout.layoutPageHeader# mb-3">
            <h4 class="page-title">#getTrans('titResetPassword')#</h4>                        
            <ol class="breadcrumb breadcrumb-dots">
                <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                <li class="breadcrumb-item active">#getTrans('titResetPassword')#</li>
            </ol> 
        </div>
        <div class="row mb-3">
            <div class="col-lg-12">
                <form id="submit_form" class="card" method="post" action="#application.mainURL#/user">
                    <input type="hidden" name="change_pw_btn">
                    <div class="card-header">
                        <h3 class="card-title">#getTrans('titChoosePassword')#</h3>
                    </div>
                    <div class="card-body">
                        <cfif structKeyExists(session, "alert")>
                            #session.alert#
                        <cfelse>
                            <div class="alert alert-info" role="alert">
                                #getTrans('alertChoosePassword')#
                            </div>
                        </cfif>
                        <div class="row"> 
                            <div class="col-md-6 mb-3">
                                <div class="form-group">
                                    <label class="form-label">#getTrans('formPassword')#</label>
                                    <input type="password" name="password" class="form-control" required maxlenght="100" minlength="8">
                                </div>
                            </div> 
                            <div class="col-md-6 mb-3">
                                <div class="form-group">
                                    <label class="form-label">#getTrans('formPassword2')#</label>
                                    <input type="password" name="password2" class="form-control" required="true" maxlenght="100" minlength="8">
                                </div>
                            </div> 
                        </div>
                    </div>                                
                    <div class="card-footer text-center">
                        <button id="submit_button" type="submit" class="btn btn-primary">#getTrans('formReset')#</button>
                    </div>
                </form>
            </div>
        </div>        
    </div>
    

</div>
</cfoutput>     