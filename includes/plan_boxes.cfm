<cfoutput>

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

                        <!--- If there is a user session, send the user to the booking or to the dashboard --->
                        <cfif structKeyExists(session, "customer_id") and session.customer_id gt 0>

                            <cfif i.itsFree eq 1>

                                <!--- Button free --->
                                <div class="text-center my-4 <cfif i.recommended>btn-green</cfif>">
                                    <a href="#i.bookingLinkF#" rel="nofollow" class="btn w-100">#getTrans('btnActivate')#</a>
                                </div>

                            <cfelse>

                                <!--- Button monthly --->
                                <div class="text-center my-4 monthly <cfif i.recommended>btn-green</cfif>">
                                    <a href="#i.bookingLinkM#" rel="nofollow" class="btn w-100">#getTrans('btnActivate')#</a>
                                </div>

                                <!--- Button yearly --->
                                <div class="text-center my-4 yearly <cfif i.recommended>btn-green</cfif>" style="display: none;">
                                    <a href="#i.bookingLinkY#" rel="nofollow" class="btn w-100">#getTrans('btnActivate')#</a>
                                </div>

                            </cfif>

                        <!--- otherwise send to registration form --->
                        <cfelse>

                            <cfif i.itsFree eq 1>
                                <cfset redirectLink = replace(i.bookingLinkF, application.mainURL, "", "one")>
                            <cfelse>
                                <cfset redirectLink = replace(i.bookingLinkM, application.mainURL, "", "one")>
                            </cfif>

                            <div class="text-center my-4 <cfif i.recommended>btn-green</cfif>">
                                <a href="#application.mainURL#/register?redirect=#URLEncodedFormat(redirectLink)#" class="btn w-100"><cfif len(trim(i.buttonName))>#i.buttonName#<cfelse>#getTrans('btnActivate')#</cfif></a>
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
                    <div class="row pt-2 small monthly">
                        <p class="text-muted">#i.vat_text_monthly#</p>
                    </div>

                    <!--- Price yearly --->
                    <div class="row pt-2 small yearly" style="display: none;">
                        <p class="text-muted">#i.vat_text_yearly#</p>
                    </div>

                </cfif>

            </div>

        </cfloop>
    </cfif>
</div>
</cfoutput>