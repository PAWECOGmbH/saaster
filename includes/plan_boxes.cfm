<cfoutput>



<cfif structKeyExists(session, "alert")>
    #session.alert#
</cfif>

<div class="mb-5">
    <div class="form-label">#getTrans('titPayment')#</div>
    <div class="form-group radio-toggle has-toggle-input toggleradio mt-3">
        <div class="form-check">
            <label class="form-check-label active form-check form-check-inline monthly">
                <input class="form-check-input" id="monthly" type="radio" name="payment_changer" value="monthly" style="visibility:hidden;" checked>
                <span class="form-check-label">#getTrans('txtMonthly')#</span>
            </label>
            <label class="form-check-label form-check form-check-inline yearly">
                <input class="form-check-input" id="yearly" type="radio" name="payment_changer" value="yearly" style="visibility:hidden;">
                <span class="form-check-label">#getTrans('txtYearly')#</span>
            </label>
        </div>
    </div>
</div>
<div class="row row-cards">
    <cfif structKeyExists(planArray[1], "planGroupID") and planArray[1].planGroupID gt 0>
        <cfloop array="#planArray#" index="i">
            <div class="col-sm-6 col-lg-3">
                <div class="card card-md">
                    <cfif i.recommended>
                        <div class="ribbon ribbon-top ribbon-bookmark bg-green">
                            <i class="fas fa-star" style="font-size: 16px;"></i>
                        </div>
                    </cfif>
                    <div class="card-body text-center">

                        <!--- Plan name --->
                        <div class="text-uppercase text-muted h4">#i.planName#</div>

                        <!--- Price monthly --->
                        <div style="min-height: 50px;" class="price_box monthly">
                            <div class="fw-bold my-2 plan_price">
                                <cfif i.onRequest>
                                    #getTrans('txtOnRequest')#
                                <cfelse>
                                    <cfif i.itsFree eq 1>
                                        #getTrans('txtFree')#
                                    <cfelse>
                                        <span class="currency">#i.currencySign#</span> #lsCurrencyFormat(i.priceMonthly, "none")#
                                    </cfif>
                                </cfif>
                            </div>
                            <!--- Price addition --->
                            <div style="min-height: 50px;">
                                <cfif !i.onRequest and i.priceMonthly gt 0>
                                    #getTrans('txtMonthlyPayment')#
                                </cfif>
                            </div>
                        </div>

                        <!--- Price yearly --->
                        <div style="min-height: 50px; display: none;" class="price_box yearly">
                            <div class="fw-bold my-2 plan_price">
                                <cfif i.onRequest>
                                    #getTrans('txtOnRequest')#
                                <cfelse>
                                    <cfif i.itsFree eq 1>
                                        #getTrans('txtFree')#
                                    <cfelse>
                                        <span class="currency">#i.currencySign#</span> #lsCurrencyFormat(i.priceYearly, "none")#
                                    </cfif>
                                </cfif>
                            </div>
                            <!--- Price addition --->
                            <div style="min-height: 50px;">
                                <cfif !i.onRequest and i.priceYearly gt 0>
                                    #getTrans('txtYearlyPayment')#
                                </cfif>
                            </div>
                        </div>

                        <!--- Description short --->
                        <div class="text-center py-3" style="min-height: 120px;">
                            #replace(i.shortDescription, chr(13), "<br />")#
                        </div>

                        <!--- If there is a user session, send the user to the booking page --->
                        <cfif structKeyExists(session, "customer_id") and session.customer_id gt 0>

                            <!--- Check whether the user has already a plan and is doing a down- or upgrade --->
                            <cfset toManyUsers = false>
                            <cfset alertDowngrade = false>
                            <cfset alertUpgrade = false>
                            <cfif len(trim(session.currentPlan.status)) and session.currentPlan.status neq "expired" and !i.onRequest>
                                <cfif i.priceMonthly lt session.currentPlan.priceMonthly>
                                    <!--- Check whether the customer has registered more users than the new plan provides --->
                                    <cfif (i.maxUsers gt 0) and application.objUser.getAllUsers(session.customer_id).recordCount gt i.maxUsers>
                                        <cfset toManyUsers = true>
                                    </cfif>
                                    <!--- Downgrade --->
                                    <cfset alertDowngrade = true>
                                <cfelseif i.priceMonthly gt session.currentPlan.priceMonthly and session.currentPlan.status neq "free">
                                    <cfset alertUpgrade = true>
                                </cfif>
                            </cfif>

                            <cfif toManyUsers>

                                <cfset usersToDelete = application.objUser.getAllUsers(session.customer_id).recordCount - i.maxUsers>

                                <div class="text-center my-4 <cfif i.recommended>btn-green</cfif>">
                                    <a class="btn w-100" onclick="sweetAlert('error', '#application.mainURL#/account-settings/users', '#getTrans('titDowngradeNotPossible')#', '#getTrans('txtDowngradeNotPossibleText')# #usersToDelete#', 'OK', '#getTrans('btnToTheUsers')#')">#getTrans('btnActivate')#</a>
                                </div>

                            <cfelse>

                                <cfif i.itsFree eq 1>

                                    <!--- Button free --->
                                    <div class="text-center my-4 <cfif i.recommended>btn-green</cfif>">

                                        <cfif alertDowngrade>
                                            <a class="btn w-100 plan" onclick="sweetAlert('warning', '#i.bookingLinkF#', '#getTrans('titDowngrade')#', '#getTrans('txtYouAreDowngrading')#', '#getTrans('btnWantWait')#', '#getTrans('btnYesDowngrade')#')">#getTrans('btnActivate')#</a>
                                        <cfelse>
                                            <a href="#i.bookingLinkF#" rel="nofollow" class="btn w-100 plan">#getTrans('btnActivate')#</a>
                                        </cfif>

                                    </div>

                                <cfelse>

                                    <cfif alertDowngrade>

                                        <!--- Button monthly --->
                                        <div class="text-center my-4 price_box monthly <cfif i.recommended>btn-green</cfif>">
                                            <a class="btn w-100 plan" onclick="sweetAlert('warning', '#i.bookingLinkM#', '#getTrans('titDowngrade')#', '#getTrans('txtYouAreDowngrading')#', '#getTrans('btnWantWait')#', '#getTrans('btnYesDowngrade')#')">#getTrans('btnActivate')#</a>
                                        </div>
                                        <!--- Button yearly --->
                                        <div style="display: none;" class="text-center price_box my-4 yearly <cfif i.recommended>btn-green</cfif>">
                                            <a class="btn w-100 plan" onclick="sweetAlert('warning', '#i.bookingLinkY#', '#getTrans('titDowngrade')#', '#getTrans('txtYouAreDowngrading')#', '#getTrans('btnWantWait')#', '#getTrans('btnYesDowngrade')#')">#getTrans('btnActivate')#</a>
                                        </div>

                                    <cfelseif alertUpgrade>

                                        <!--- Calculate the amount the customer has to pay today for this upgrade  --->
                                        <cfset amountToPayM = objPlans.calculateUpgrade(session.customer_id, i.planID, 'monthly').toPayNow>
                                        <cfset amountToPayY = objPlans.calculateUpgrade(session.customer_id, i.planID, 'yearly').toPayNow>

                                        <!--- Set text for sweet alert --->
                                        <cfset textToPayTodayM = getTrans('txtYouAreUpgrading') & " " & getTrans('txtToPayToday') & " " & i.currencySign & " " & lsCurrencyFormat(amountToPayM, "none")>
                                        <cfset textToPayTodayY = getTrans('txtYouAreUpgrading') & " " & getTrans('txtToPayToday') & " " & i.currencySign & " " & lsCurrencyFormat(amountToPayY, "none")>

                                        <!--- The amount mus be greater than 0, we do not refund money --->
                                        <cfif amountToPayM gte 0>
                                            <!--- Button monthly --->
                                            <div class="text-center my-4 price_box monthly <cfif i.recommended>btn-green</cfif>">
                                                <a class="btn w-100 plan" onclick="sweetAlert('info', '#i.bookingLinkM#', '#getTrans('titUpgrade')#', '#textToPayTodayM#', '#getTrans('btnWantWait')#', '#getTrans('btnYesUpgrade')#')">#getTrans('btnActivate')#</a>
                                            </div>
                                        <cfelse>
                                            <!--- Button monthly --->
                                            <div class="text-center my-4 price_box monthly <cfif i.recommended>btn-green</cfif>">
                                                <a class="btn w-100 plan" onclick="sweetAlert('warning', '', '#getTrans('titUpgrade')#', '#getTrans('txtYouCantUpgrade')#', '', '')">#getTrans('btnActivate')#</a>
                                            </div>
                                        </cfif>
                                        <cfif amountToPayY gte 0>
                                            <!--- Button yearly --->
                                            <div style="display: none;" class="text-center price_box my-4 yearly <cfif i.recommended>btn-green</cfif>">
                                                <a class="btn w-100 plan" onclick="sweetAlert('info', '#i.bookingLinkY#', '#getTrans('titUpgrade')#', '#textToPayTodayY#', '#getTrans('btnWantWait')#', '#getTrans('btnYesUpgrade')#')">#getTrans('btnActivate')#</a>
                                            </div>
                                        <cfelse>
                                            <!--- Button yearly --->
                                            <div style="display: none;" class="text-center price_box my-4 yearly <cfif i.recommended>btn-green</cfif>">
                                                <a class="btn w-100 plan" onclick="sweetAlert('warning', '', '#getTrans('titUpgrade')#', '#getTrans('txtYouCantUpgrade')#', '', '')">#getTrans('btnActivate')#</a>
                                            </div>
                                        </cfif>

                                    <cfelse>

                                        <!--- Button monthly --->
                                        <div class="text-center my-4 price_box monthly <cfif i.recommended>btn-green</cfif>">
                                            <a href="#i.bookingLinkM#" rel="nofollow" class="btn w-100 plan">#getTrans('btnActivate')#</a>
                                        </div>
                                        <!--- Button yearly --->
                                        <div style="display: none;" class="text-center price_box my-4 yearly <cfif i.recommended>btn-green</cfif>">
                                            <a href="#i.bookingLinkY#" rel="nofollow" class="btn w-100 plan">#getTrans('btnActivate')#</a>
                                        </div>

                                    </cfif>

                                </cfif>

                            </cfif>

                        <!--- otherwise send to the registration form --->
                        <cfelse>

                            <cfif i.itsFree eq 1>
                                <cfset redirectLink = replace(i.bookingLinkF, application.mainURL, "", "one")>
                            <cfelse>
                                <cfset redirectLink = replace(i.bookingLinkM, application.mainURL, "", "one")>
                            </cfif>

                            <div class="text-center my-4 <cfif i.recommended>btn-green</cfif>">
                                <a href="#application.mainURL#/register?redirect=plans" class="btn w-100 plan"><cfif len(trim(i.buttonName))>#i.buttonName#<cfelse>#getTrans('btnActivate')#</cfif></a>
                            </div>

                        </cfif>

                        <!--- Description --->
                        <div class="card-body plan-cards" style="min-height: 150px;">
                            #i.description#
                        </div>

                    </div>

                </div>

                <cfif !i.itsFree and !i.onRequest>

                    <!--- Price monthly --->
                    <div class="row pt-2 small price_box monthly">
                        <p class="text-muted">#i.vat_text_monthly#</p>
                    </div>

                    <!--- Price yearly --->
                    <div class="row pt-2 small price_box yearly" style="display: none;">
                        <p class="text-muted">#i.vat_text_yearly#</p>
                    </div>

                </cfif>

            </div>

        </cfloop>
    </cfif>
</div>
</cfoutput>