<cfscript>

    objPlans = new backend.core.com.plans(language=session.lng);
    moduleArray = new backend.core.com.modules().getAllModules();

    // Check whether there are plans defined or not
    planGroup = objPlans.prepareForGroupID(session.customer_id).groupID;
    getPlansAsArray = objPlans.getPlans(planGroup);
    hasPlans = arrayLen(getPlansAsArray) ? true : false;

</cfscript>



<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">


        <div class="#getLayout.layoutPageHeader# mb-3">
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
                        <h3 class="card-title">#getTrans('titCompanyUser')#</h3>
                    </div>
                    <div class="card-body">
                        <div class="list-group">
                            <cfif session.admin>
                                <a href="#application.mainURL#/account-settings/company" class="list-group-item list-group-item-action flex-column align-items-start">
                                    <div class="d-flex justify-content-between">
                                        <h4 class="mb-1"><b>#getTrans('titMyCompany')#</b></h4>
                                    </div>
                                    <p class="mb-1 ">#getTrans('txtMyCompanyDescription')#</p>
                                </a>
                            </cfif>
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
                                <a href="#application.mainURL#/account-settings/users" class="list-group-item list-group-item-action flex-column align-items-start">
                                    <div class="d-flex justify-content-between">
                                        <h4 class="mb-1"><b>#getTrans('titUser')#</b></h4>
                                    </div>
                                    <p class="mb-1 ">#getTrans('txtAddOrEditUser')#</p>
                                </a>
                                <cfif getCustomerData.custParentID eq 0 and session.superadmin>
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
                                <cfif session.superadmin>
                                    <a href="#application.mainURL#/account-settings/payment" class="list-group-item list-group-item-action flex-column align-items-start">
                                        <div class="d-flex justify-content-between">
                                            <h4 class="mb-1"><b>#getTrans('titPaymentSettings')#</b></h4>
                                        </div>
                                        <p class="mb-1 ">#getTrans('txtPaymentSettings')#</p>
                                    </a>
                                </cfif>
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

                            <div class="list-group">

                                <cfif session.currentPlan.planID gt 0>

                                    <!--- Display the current plan --->
                                    <cfinclude template="/backend/core/views/plan_view.cfm">

                                    <cfif session.superAdmin>

                                        <cfif session.currentPlan.status eq "canceled">

                                            <p><a href="#application.mainURL#/cancel?plan=#session.currentPlan.planID#&revoke" class="btn btn-outline-info">#getTrans('btnRevokeCancellation')#</a></p>

                                        <cfelse>

                                            <cfif session.currentPlan.status neq "payment">

                                                <a href="#application.mainURL#/account-settings/plans" class="list-group-item list-group-item-action flex-column align-items-start">
                                                    <div class="d-flex justify-content-between">
                                                        <h4 class="mb-1"><b>#getTrans('titPlans')#</b></h4>
                                                    </div>
                                                    <p class="mb-1">#getTrans('txtUpdatePlan')#</p>
                                                </a>

                                            </cfif>

                                        </cfif>

                                    </cfif>

                                <cfelse>

                                    <cfif session.superAdmin>

                                        <cfif hasPlans>

                                            <p>#getTrans('msgNoPlanBooked')#</p>
                                            <p class="mb-4"><a class="btn btn-success" href="#application.mainURL#/account-settings/plans">#getTrans('txtBookNow')#</a></p>

                                        </cfif>

                                    </cfif>

                                </cfif>

                                <cfif arrayLen(moduleArray)>

                                    <a href="#application.mainURL#/account-settings/modules" class="list-group-item list-group-item-action flex-column align-items-start">
                                        <div class="d-flex justify-content-between">
                                            <h4 class="mb-1"><b>#getTrans('titModules')#</b></h4>
                                        </div>
                                        <p class="mb-1">#getTrans('txtAddOrEditModules')#</p>
                                    </a>

                                </cfif>

                            </div>

                        </div>
                    </div>
                </div>
            </cfif>

        </div>
    </div>


</div>
</cfoutput>

