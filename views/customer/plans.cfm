
<cfscript>

    // Check whether the customer already has registered a valid payment method
    objPayrexx = new com.payrexx();
    getWebhook = objPayrexx.getWebhook(session.customer_id, 'authorized');

    // Get the booked plan
    bookedPlan = session.currentPlan;

    // If no plan is booked send to plans in frontend
    if (bookedPlan.planID eq 0) {
        location url="#application.mainURL#/plans" addtoken="false";
    }

    // If the plan is canceled, send to account
    if (bookedPlan.status eq "canceled") {
        location url="#application.mainURL#/account-settings" addtoken="false";
    }

    // Get the currency of the last invoice
    currency = application.objCustomer.getCustomerData(session.customer_id).strCurrency;

    // Init prices
    objPrices = new com.prices(language=session.lng, currency=currency);

    // Get the currency id of the last invoice
    currencyID = objPrices.getCurrency(currency).id;
    if (currencyID eq 0) {
        currencyID = objPrices.getCurrency().id;
    }

    // Init plans
    objPlans = new com.plans(language=session.lng, currencyID=currencyID);

    // Get plan data using the booked plan
    planDetail = objPlans.getPlanDetail(bookedPlan.planID);
    planArray = objPlans.getPlans(planDetail.planGroupID);


</cfscript>



<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">#getTrans('titPlans')#</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                            <li class="breadcrumb-item active">#getTrans('titPlans')#</li>
                        </ol>
                    </div>

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
                            <h3 class="card-title">#getTrans('titEditPlan')#</h3>
                        </div>
                        <div class="card-body">
                            <div class="row ps-4 pe-4">

                                <div class="col-lg-5">

                                    <h2 class="mb-4"><span class="badge badge-pill bg-primary ps-2 pe-2 me-2">1</span> #getTrans('titYourPlan')#:</h2>

                                    <div class="form-selectgroup form-selectgroup-boxes d-flex flex-column mb-3">
                                    <cfloop array="#planArray#" index="i">
                                        <label class="form-selectgroup-item flex-fill">
                                            <input type="radio" name="planID" value="#i.planID#" class="form-selectgroup-input plan_edit" <cfif i.onRequest>disabled="true"</cfif> <cfif bookedPlan.planID eq i.planID>checked</cfif>>
                                            <div class="form-selectgroup-label d-flex align-items-top p-3">
                                                <div class="me-3">
                                                    <span class="form-selectgroup-check"></span>
                                                </div>
                                                <div>
                                                    <div class="card-title mb-4">#i.planName#</div>
                                                    <div class="card-subtitle">
                                                        #getTrans('txtMonthlyPayment')#:
                                                        <cfif i.onRequest>
                                                            <b>#getTrans('txtOnRequest')#</b>
                                                        <cfelseif i.itsFree eq 1>
                                                            <b>#getTrans('txtFree')#</b>
                                                        <cfelse>
                                                            <b>#i.currencySign# #lsCurrencyFormat(i.priceMonthly, "none")#</b> #lcase(getTrans('txtMonthly'))#<br />
                                                            <span class="small">
                                                                #i.vat_text_monthly#
                                                            </span>
                                                        </cfif>
                                                    </div>
                                                    <div class="card-subtitle">
                                                        #getTrans('txtYearlyPayment')#:
                                                        <cfif i.onRequest>
                                                            <b>#getTrans('txtOnRequest')#</b>
                                                        <cfelseif i.itsFree eq 1>
                                                            <b>#getTrans('txtFree')#</b>
                                                        <cfelse>
                                                            <b>#i.currencySign# #lsCurrencyFormat(i.priceYearly, "none")#</b> #lcase(getTrans('txtYearly'))#<br />
                                                            <span class="small">
                                                                #i.vat_text_yearly#
                                                            </span>
                                                        </cfif>
                                                    </div>
                                                    <div>
                                                        <cfif i.onRequest>
                                                            <p><a href="#i.bookingLinkM#" target="_blank">#i.buttonName#</a></p>
                                                        <cfelse>
                                                            <p><a href="#application.mainURL#/plans" target="_blank">#getTrans('txtInformation')#</a></p>
                                                        </cfif>
                                                    </div>
                                                </div>
                                            </div>
                                        </label>
                                    </cfloop>
                                    </div>

                                </div>

                                <div class="col-lg-1"></div>

                                <div class="col-lg-6">

                                    <h2 class="mb-4"><span class="badge badge-pill bg-primary ps-2 pe-2 me-2">2</span> #getTrans('titBillingCycle')#:</h2>

                                    <div class="form-selectgroup form-selectgroup-boxes d-flex flex-column mb-3">

                                        <div class="row">
                                            <div class="col-lg-6">
                                                <label class="form-selectgroup-item flex-fill">
                                                    <input type="radio" name="recurring" value="monthly" class="form-selectgroup-input plan_recurring" <cfif bookedPlan.recurring eq "monthly">checked</cfif>>
                                                    <div class="form-selectgroup-label d-flex align-items-top p-3">
                                                        <div class="me-3">
                                                            <span class="form-selectgroup-check"></span>
                                                        </div>
                                                        <div>
                                                            <div class="card-title">#getTrans('txtMonthly')#</div>
                                                        </div>
                                                    </div>
                                                </label>
                                            </div>
                                            <div class="col-lg-6">
                                                <label class="form-selectgroup-item flex-fill">
                                                    <input type="radio" name="recurring" value="yearly" class="form-selectgroup-input plan_recurring" <cfif bookedPlan.recurring eq "yearly">checked</cfif>>
                                                    <div class="form-selectgroup-label d-flex align-items-top">
                                                        <div class="me-3">
                                                            <span class="form-selectgroup-check"></span>
                                                        </div>
                                                        <div>
                                                            <div class="card-title">#getTrans('txtYearly')#</div>
                                                        </div>
                                                    </div>
                                                </label>
                                            </div>
                                        </div>

                                    </div>

                                    <h2 class="mb-4 mt-4"><span class="badge badge-pill bg-primary ps-2 pe-2 me-2">3</span> #getTrans('titOrderSummary')#:</h2>

                                    <div class="card">

                                        <div class="card-body" id="change_plan">

                                            <!--- Display the current plan --->
                                            <cfinclude template="/includes/plan_view.cfm">

                                            <cfif bookedPlan.status eq "expired">
                                                <cfif getWebhook.recordCount>
                                                    <cfif bookedPlan.recurring eq "monthly">
                                                        <p class="mt-4"><a href="#planDetail.bookingLinkM#" class="btn btn-success w-100 plan">#getTrans('txtRenewNow')#</a></p>
                                                    <cfelse>
                                                        <p class="mt-4"><a href="#planDetail.bookingLinkY#" class="btn btn-success w-100 plan">#getTrans('txtRenewNow')#</a></p>
                                                    </cfif>
                                                <cfelse>
                                                    <p class="mt-4"><a href="#application.mainURL#/account-settings/payment" class="btn btn-success w-100 plan">#getTrans('txtRenewNow')#</a></p>
                                                </cfif>
                                            <cfelse>
                                                <cfif not structKeyExists(url, "recurring")>
                                                    <p><a class="btn plan" onclick="sweetAlert('warning', '#application.mainURL#/cancel?plan=#bookedPlan.planID#', '#getTrans('txtCancelPlan')#', '#getTrans('msgCancelPlanWarningText')#', '#getTrans('btnDontCancel')#', '#getTrans('btnYesCancel')#')">#getTrans('txtCancelPlan')#</a></p>
                                                </cfif>
                                            </cfif>

                                        </div>

                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>
