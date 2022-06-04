<cfscript>

    objPlan = new com.plans(language=session.lng);
    moduleArray = new com.modules().getAllModules();

</cfscript>

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

            <div class="col-lg-4 mb-3">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">#getTrans('txtMyProfile')#</h3>
                    </div>
                    <div class="card-body">
                        <div class="list-group">
                            <a href="#application.mainURL#/account-settings/my-profile" class="list-group-item list-group-item-action flex-column align-items-start">
                                <div class="d-flex justify-content-between">
                                    <h4 class="mb-1"><b>#getTrans('txtEditProfile')#</b></h4>
                                </div>
                                <p class="mb-1 ">#getTrans('txtEditYourProfile')#</p>
                            </a>
                            <a href="#application.mainURL#/account-settings/reset-password" class="list-group-item list-group-item-action flex-column align-items-start">
                                <div class="d-flex justify-content-between">
                                    <h4 class="mb-1"><b>#getTrans('titResetPassword')#</b></h4>
                                </div>
                                <p class="mb-1 ">#getTrans('txtResetOwnPassword')#</p>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <cfif session.admin>
                <div class="col-lg-4 mb-3">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">#getTrans('titGeneralSettings')#</h3>
                        </div>
                        <div class="card-body">
                            <div class="list-group">
                                <a href="#application.mainURL#/account-settings/company" class="list-group-item list-group-item-action flex-column align-items-start">
                                    <div class="d-flex justify-content-between">
                                        <h4 class="mb-1"><b>#getTrans('titMyCompany')#</b></h4>
                                    </div>
                                    <p class="mb-1 ">#getTrans('txtMyCompanyDescription')#</p>
                                </a>
                                <a href="#application.mainURL#/account-settings/users" class="list-group-item list-group-item-action flex-column align-items-start">
                                    <div class="d-flex justify-content-between">
                                        <h4 class="mb-1"><b>#getTrans('titUser')#</b></h4>
                                    </div>
                                    <p class="mb-1 ">#getTrans('txtAddOrEditUser')#</p>
                                </a>
                                <cfif getCustomerData.intCustParentID eq 0 and session.superadmin>
                                    <a href="#application.mainURL#/account-settings/tenants" class="list-group-item list-group-item-action flex-column align-items-start">
                                        <div class="d-flex justify-content-between">
                                            <h4 class="mb-1"><b>#getTrans('titMandanten')#</b></h4>
                                        </div>
                                        <p class="mb-1 ">#getTrans('txtAddOrEditTenants')#</p>
                                    </a>
                                </cfif>
                                <a href="#application.mainURL#/account-settings/invoices" class="list-group-item list-group-item-action flex-column align-items-start">
                                    <div class="d-flex justify-content-between">
                                        <h4 class="mb-1"><b>#getTrans('titInvoices')#</b></h4>
                                    </div>
                                    <p class="mb-1 ">#getTrans('txtViewInvoices')#</p>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 mb-3">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">#getTrans('titPlansAndModules')#</h3>
                        </div>
                        <div class="card-body">

                            <cfif session.currentPlan.planID gt 0>

                                <cfset getStatus = objPlan.getPlanStatusAsText(session.currentPlan)>

                                <dl class="row">

                                    <dt class="col-5">#getTrans('titYourPlan')#:</dt>
                                    <dd class="col-7">#session.currentPlan.planName#</dd>

                                    <dt class="col-5">#getTrans('txtPlanStatus')#:</dt>
                                    <dd class="col-7 text-#getStatus.fontColor#">#getStatus.statusTitle#</dd>

                                    <dt class="col-5">#getTrans('txtBookedOn')#:</dt>
                                    <dd class="col-7">#lsDateFormat(session.currentPlan.startDate, "Full")#</dd>

                                    <cfif session.currentPlan.status eq "active">

                                        <dt class="col-5">#getTrans('txtRenewPlanOn')#:</dt>
                                        <dd class="col-7">#lsDateFormat(session.currentPlan.endDate, "Full")#</dd>

                                    <cfelseif session.currentPlan.status eq "canceled">

                                        <dt class="col-5">#getTrans('txtExpiryDate')#:</dt>
                                        <dd class="col-7">#lsDateFormat(session.currentPlan.endDate, "Full")#</dd>
                                        <dt class="col-5">#getTrans('txtInformation')#:</dt>
                                        <dd class="col-7">#getStatus.statusText#</dd>

                                    <cfelseif session.currentPlan.status eq "test">

                                        <dt class="col-5">#getTrans('txtExpiryDate')#:</dt>
                                        <dd class="col-7">#lsDateFormat(session.currentPlan.endTestDate, "Full")#</dd>
                                        <dt class="col-5">#getTrans('txtInformation')#:</dt>
                                        <dd class="col-7">#getStatus.statusText#</dd>

                                    </cfif>

                                </dl>

                                <cfif session.superAdmin>

                                    <cfif session.currentPlan.status eq "active" or session.currentPlan.status eq "test">
                                        <div class="row mt-4">
                                            <div class="button-group">
                                                <a href="#application.mainURL#/plans" class="btn btn-outline-success me-3">#getTrans('txtChangePlan')#</a>
                                                <a class="btn btn-outline-danger" onclick="sweetAlert('warning', '#application.mainURL#/cancel?plan=#session.currentPlan.planID#', '#getTrans('txtCancelPlan')#', '#getTrans('msgCancelPlanWarningText')#', '#getTrans('btnDontCancel')#', '#getTrans('btnYesCancel')#')">#getTrans('txtCancelPlan')#</a>
                                            </div>
                                        </div>
                                    <cfelseif session.currentPlan.status eq "canceled">
                                        <div class="row mt-4">
                                            <div class="button-group">
                                                <a href="#application.mainURL#/cancel?plan=#session.currentPlan.planID#&revoke" class="btn btn-outline-info me-3">#getTrans('btnRevokeCancellation')#</a>
                                            </div>
                                        </div>
                                    <cfelseif session.currentPlan.status eq "free">
                                        <div class="row mt-4">
                                            <div class="button-group">
                                                <a href="#application.mainURL#/plans" class="btn btn-outline-success me-3">#getTrans('txtUpgradePlanNow')#</a>
                                            </div>
                                        </div>
                                    <cfelseif session.currentPlan.status eq "expired">
                                        <div class="row mt-4">
                                            <div class="button-group">
                                                <a href="#application.mainURL#/plans" class="btn btn-outline-success me-3">#getTrans('txtBookNow')#</a>
                                            </div>
                                        </div>
                                    </cfif>

                                </cfif>

                            <cfelse>
                                <p>#getTrans('msgNoPlanBooked')# - <a href="#application.mainURL#/plans">#getTrans('txtBookNow')#</a></p>
                            </cfif>

                            <cfif arrayLen(moduleArray)>

                                <div class="list-group mt-4">
                                    <a href="#application.mainURL#/account-settings/modules" class="list-group-item list-group-item-action flex-column align-items-start">
                                        <div class="d-flex justify-content-between">
                                            <h4 class="mb-1"><b>#getTrans('titModules')#</b></h4>
                                        </div>
                                        <p class="mb-1">#getTrans('txtAddOrEditModules')#</p>
                                    </a>
                                </div>

                            </cfif>



                        </div>
                    </div>
                </div>
            </cfif>

        </div>
        </cfoutput>
    </div>
</div>
<cfinclude template="/includes/footer.cfm">