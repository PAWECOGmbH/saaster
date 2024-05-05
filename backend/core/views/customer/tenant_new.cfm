


<cfscript>
    // Only main companies have access to this resource
    if(getCustomerData.custParentID gt 0){
        getAlert('msgNoAccess', 'danger');
        location url="#application.mainURL#/account-settings" addtoken="false";
    }
</cfscript>

<cfoutput>
<div class="page-wrapper" >
    <div class="#getLayout.layoutPage#">

        <div class="#getLayout.layoutPageHeader# mb-3">
            <h4 class="page-title">#getTrans('btnNewTenant')#</h4>
            <ol class="breadcrumb breadcrumb-dots">
                <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings/tenants">#getTrans('titTenantOverview')#</a></li>
                <li class="breadcrumb-item active">#getTrans('btnNewTenant')#</li>
            </ol>
        </div>
        <cfif structKeyExists(session, "alert")>
            #session.alert#
        </cfif>
        <div class="row">
            <div class="col-lg-12">
                <form id="submit_form" class="card" method="post" action="#application.mainURL#/customer">
                    <input type="hidden" name="new_tenant_btn">
                    <div class="card-header">
                        <h3 class="card-title">#getTrans('txtNewTenant')#</h3>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label class="form-label">#getTrans('formCompanyName')#</label>
                                    <input type="text" name="company_name" class="form-control" minlength="3" maxlenght="100">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label class="form-label">#getTrans('formContactName')# *</label>
                                    <input type="text" name="contact_person" class="form-control" required="true" minlength="3" maxlenght="100">
                                </div>
                            </div>

                        </div>
                    </div>
                    <div class="card-footer text-center">
                        <button id="submit_button" type="submit" class="btn btn-primary">#getTrans('btnNewTenant')#</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    

</div>
</cfoutput>