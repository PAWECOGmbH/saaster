
<cfscript>

    // Get the booked plan
    bookedPlan = session.currentPlan;

    // If no plan is booked send to plans in frontend
    if (bookedPlan.planID eq 0) {
        location url="#application.mainURL#/plans" addtoken="false";
    }


    objPlans = new com.plans();
    objInvoices = new com.invoices();
    objPrices = new com.prices();

    // Get plan data using the booked plan
    planDetail = objPlans.getPlanDetail(bookedPlan.planID);

    // Get the currency of the last invoice
    invoices = objInvoices.getInvoices(session.customer_id, 0, 1);
    if (invoices.totalCount gt 0) {
        currency = invoices.arrayInvoices[1].invoiceCurrency;
        currencyID = objPrices.getCurrency(currency).id;
    } else {
        currencyID = objPrices.getCurrency().id;
    }

    // Get all plans of the current plan group
    objPlan = objPlans.init(language=session.lng, currencyID=currencyID);
    planArray = objPlan.getPlans(planDetail.planGroupID);


    dump(bookedPlan);



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
                            <div class="row">

                                <div class="col-lg-4">

                                    <h2 class="mb-4"><span class="badge badge-pill bg-primary ps-2 pe-2 me-2">1</span> #getTrans('titYourPlan')#:</h2>

                                    <div class="form-selectgroup form-selectgroup-boxes d-flex flex-column mb-3">
                                    <cfloop array="#planArray#" index="i">
                                        <cfif !i.onRequest>
                                            <label class="form-selectgroup-item flex-fill">
                                                <input type="radio" name="planID" value="#i.planID#" class="form-selectgroup-input plan_edit" <cfif bookedPlan.planID eq i.planID>checked</cfif>>
                                                <div class="form-selectgroup-label d-flex align-items-top p-3">
                                                    <div class="me-3">
                                                        <span class="form-selectgroup-check"></span>
                                                    </div>
                                                    <div>
                                                        <div class="card-title mb-4">#i.planName#</div>
                                                        <div class="card-subtitle">
                                                            #getTrans('txtMonthlyPayment')#:
                                                            <cfif i.itsFree eq 1>
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
                                                            <cfif i.itsFree eq 1>
                                                                <b>#getTrans('txtFree')#</b>
                                                            <cfelse>
                                                                <b>#i.currencySign# #lsCurrencyFormat(i.priceYearly, "none")#</b> #lcase(getTrans('txtYearly'))#<br />
                                                                <span class="small">
                                                                    #i.vat_text_yearly#
                                                                </span>
                                                            </cfif>

                                                        </div>
                                                        <div>
                                                            <p><a href="#application.mainURL#/plans" target="_blank">#getTrans('txtInformation')#</a></p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </label>
                                        </cfif>
                                    </cfloop>
                                    </div>

                                </div>

                                <div class="col-lg-1"></div>

                                <div class="col-lg-7">

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
                                        <div class="card-body p-4">
                                            <cfinclude  template="/includes/plan_view.cfm">
                                        </div>
                                        <div class="card-footer">
                                            <div class="d-flex">

                                                <div id="change_plan" class="row">

                                                    <cfif session.currentPlan.status eq "active" or session.currentPlan.status eq "test">

                                                        <a href="#application.mainURL#/account-settings/plans" class="btn btn-outline-success me-3">#getTrans('txtChangePlan')#</a>

                                                    <cfelseif session.currentPlan.status eq "canceled">

                                                        <a href="#application.mainURL#/cancel?plan=#session.currentPlan.planID#&revoke" class="btn btn-outline-info me-3">#getTrans('btnRevokeCancellation')#</a>

                                                    <cfelseif session.currentPlan.status eq "free">

                                                        <a href="#application.mainURL#/account-settings/plans" class="btn btn-outline-success me-3">#getTrans('txtUpgradePlanNow')#</a>

                                                    <cfelseif session.currentPlan.status eq "expired">

                                                        <a href="#application.mainURL#/account-settings/plans" class="btn btn-outline-success me-3">#getTrans('txtBookNow')#</a>

                                                    </cfif>

                                                    <a class="btn ms-auto" onclick="sweetAlert('warning', '#application.mainURL#/cancel?plan=#session.currentPlan.planID#', '#getTrans('txtCancelPlan')#', '#getTrans('msgCancelPlanWarningText')#', '#getTrans('btnDontCancel')#', '#getTrans('btnYesCancel')#')">#getTrans('txtCancelPlan')#</a>

                                                </div>
                                            </div>
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
