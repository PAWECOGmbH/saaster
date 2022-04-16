<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <div class="container-xl">

        <cfoutput>
        <div class="page-header mb-3">
            <h2 class="page-title">#getTrans('txtAccountSettings')#</h2>

            <ol class="breadcrumb breadcrumb-dots" aria-label="breadcrumbs">
                <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                <li class="breadcrumb-item active" aria-current="page">#getTrans('txtAccountSettings')#</li>
            </ol>

        </div>

        <cfif structKeyExists(session, "alert")>
            #session.alert#
        </cfif>

        <div class="row">

            <cfif session.admin>
                <div class="col-sm-12 col-md-6">
                    <div class="card mb-3">
                        <div class="card-header">
                            <h3 class="card-title">#getTrans('titGeneralSettings')#</h3>
                        </div>
                        <div class="card-body">
                            <div class="list-group">
                                <a href="./account-settings/company" class="list-group-item list-group-item-action flex-column align-items-start">
                                    <div class="d-flex justify-content-between">
                                        <h4 class="mb-1"><b>#getTrans('titMyCompany')#</b></h4>
                                    </div>
                                    <p class="mb-1 ">#getTrans('txtMyCompanyDescription')#</p>
                                </a>
                                <a href="./account-settings/users" class="list-group-item list-group-item-action flex-column align-items-start">
                                    <div class="d-flex justify-content-between">
                                        <h4 class="mb-1"><b>#getTrans('titUser')#</b></h4>
                                    </div>
                                    <p class="mb-1 ">#getTrans('txtAddOrEditUser')#</p>
                                </a>
                                <cfif getCustomerData.intCustParentID eq 0 and session.superadmin>
                                    <a href="./account-settings/tenants" class="list-group-item list-group-item-action flex-column align-items-start">
                                        <div class="d-flex justify-content-between">
                                            <h4 class="mb-1"><b>#getTrans('titMandanten')#</b></h4>
                                        </div>
                                        <p class="mb-1 ">#getTrans('txtAddOrEditTenants')#</p>
                                    </a>
                                </cfif>
                                <a href="./account-settings/invoices" class="list-group-item list-group-item-action flex-column align-items-start">
                                    <div class="d-flex justify-content-between">
                                        <h4 class="mb-1"><b>#getTrans('titInvoices')#</b></h4>
                                    </div>
                                    <p class="mb-1 ">#getTrans('txtViewInvoices')#</p>
                                </a>
                                <a href="./account-settings/modules" class="list-group-item list-group-item-action flex-column align-items-start">
                                    <div class="d-flex justify-content-between">
                                        <h4 class="mb-1"><b>#getTrans('titModules')#</b></h4>
                                    </div>
                                    <p class="mb-1 ">#getTrans('txtAddOrEditModules')#</p>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </cfif>
            <div class="col-sm-12 col-md-6">

                <div class="card mb-0">
                    <div class="card-header">
                        <h3 class="card-title">#getTrans('txtMyProfile')#</h3>
                    </div>
                    <div class="card-body">
                        <div class="list-group">
                            <a href="./account-settings/my-profile" class="list-group-item list-group-item-action flex-column align-items-start">
                                <div class="d-flex justify-content-between">
                                    <h4 class="mb-1"><b>#getTrans('txtEditProfile')#</b></h4>
                                </div>
                                <p class="mb-1 ">#getTrans('txtEditYourProfile')#</p>
                            </a>
                            <a href="./account-settings/reset-password" class="list-group-item list-group-item-action flex-column align-items-start">
                                <div class="d-flex justify-content-between">
                                    <h4 class="mb-1"><b>#getTrans('titResetPassword')#</b></h4>
                                </div>
                                <p class="mb-1 ">#getTrans('txtResetOwnPassword')#</p>
                            </a>
                        </div>
                    </div>
                </div>

            </div>
        </div>
        </cfoutput>
    </div>
</div>
<cfinclude template="/includes/footer.cfm">