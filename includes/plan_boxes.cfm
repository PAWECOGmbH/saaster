
<cfscript>
    param name="variables.planLanguage" default="en";
    param name="variables.planCurrencyID" default="0";
    param name="variables.planCountryID" default="0";
    param name="variables.planGroupID" default="0";
    planArgList = "";
    if (len(trim(variables.planLanguage))) {
        planLanguage = variables.planLanguage;
    }
    if (len(trim(variables.planGroupID)) and isNumeric(variables.planGroupID)) {
        planGroupID = variables.planGroupID;
    }
    if (len(trim(variables.planCurrencyID)) and isNumeric(variables.planCurrencyID)) {
        planCurrencyID = variables.planCurrencyID;
    }
    objPlans = new com.plans();
    planObj = objPlans.getPlans(language=planLanguage, groupID=planGroupID, currencyID=planCurrencyID);
    //dump(planObj);
</cfscript>

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
    <cfloop array="#planObj#" index="i">
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
                    <div style="min-height: 50px;" class="monthly price_box">
                        <div class="fw-bold my-2 plan_price">
                            <cfif i.onRequest>
                                #getTrans('txtOnRequest')#
                            <cfelse>
                                <cfif i.priceMonthly eq 0>
                                    #getTrans('txtFree')#
                                <cfelse>
                                    <span class="currency">#i.currencySign#</span> #lsnumberFormat(i.priceMonthly, '__,___.__')#
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
                                <cfif i.priceMonthly eq 0>
                                    #getTrans('txtFree')#
                                <cfelse>
                                    <span class="currency">#i.currencySign#</span> #lsnumberFormat(i.priceYearly, '__,___.__')#
                                </cfif>
                            </cfif>
                        </div>
                        <!--- Price addition --->
                        <div style="min-height: 50px;">
                            <cfif !i.onRequest and i.priceMonthly gt 0>
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

                        <!--- Button monthly --->
                        <div class="text-center my-4 monthly <cfif i.recommended>btn-green</cfif>">
                            <a href="#i.bookingLinkM#" rel="nofollow" class="btn w-100">#getTrans('btnActivate')#</a>
                        </div>

                        <!--- Button yearly --->
                        <div class="text-center my-4 yearly <cfif i.recommended>btn-green</cfif>" style="display: none;">
                            <a href="#i.bookingLinkY#" rel="nofollow" class="btn w-100">#getTrans('btnActivate')#</a>
                        </div>

                    <!--- otherwise send to registration form --->
                    <cfelse>

                        <div class="text-center my-4 <cfif i.recommended>btn-green</cfif>">
                            <a href="#application.mainURL#/register" class="btn w-100"><cfif len(trim(i.buttonName))>#i.buttonName#<cfelse>#getTrans('btnActivate')#</cfif></a>
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
</div>
</cfoutput>