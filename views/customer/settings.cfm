
<cfscript>

    if (!session.admin) {
        location url="#application.mainURL#/account-settings" addtoken="false";
    }

</cfscript>

<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">#getTrans('titSystemSettings')#</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                            <li class="breadcrumb-item active">#getTrans('titSystemSettings')#</li>
                        </ol>
                    </div>
                    <!--- <div class="page-header col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="##" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> Button
                        </a>
                    </div> --->
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="container-xl">
            <div class="row">
                <div class="col-lg-12">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">#getTrans('titGeneralSettings')#</h3>
                        </div>
                        <div class="card-body">
                            Settings goes here
                        </div>
                        <cfif session.superadmin>
                            <div class="card-footer text-center">
                                <a href="##" data-bs-toggle="modal" data-bs-target="##delete_account" class="btn btn-outline-danger">#getTrans('titDeleteAccount')#</a>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>


<!--- Modal for cancelation --->
<cfoutput>
<form action="#application.mainURL#/cancel" method="post">
<input type="hidden" name="delete" value="#session.customer_id#">
<div id="delete_account" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
    <div class="modal-dialog modal-md modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="ps-3 pe-3">
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                <div class="modal-status bg-danger"></div>
                <div class="modal-body text-center">
                    <i class="fas fa-exclamation-triangle display-1 text-danger"></i>
                    <h3 class="mt-3">#getTrans('titDeleteAccount')#</h3>
                    <p>#getTrans('txtDeleteAccount')#</p>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">#getTrans('formEmailAddress')#</label>
                        <input type="email" name="email" class="form-control" autocomplete="off" required>
                    </div>
                    <div class="mb-2">
                        <label class="form-label">#getTrans('formPassword')#</label>
                        <div class="input-group input-group-flat">
                            <input type="password" name="password" class="form-control" required>
                        </div>
                    </div>
                </div>
                <div class="modal-footer ps-3 pe-3">
                    <a href="##" class="btn bg-green" data-bs-dismiss="modal">#getTrans('txtCancel')#</a>
                    <button type="submit" class="btn bg-danger ms-auto">
                        #getTrans('btnDeleteDefinitely')#
                    </button>
                    <!--- <a onclick="sweetAlert('warning', '#application.mainURL#/cancel?delete', '#getTrans('titDeleteAccount')#?', '', '#getTrans('btnNoCancel')#', '#getTrans('btnYesDelete')#')" type="submit" class="btn bg-danger ms-auto">
                        #getTrans('btnDeleteDefinitely')#
                    </a> --->
                </div>
            </div>
        </div>
    </div>
</div>
</form>
</cfoutput>
