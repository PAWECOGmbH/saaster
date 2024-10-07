<cfscript>
    if (structKeyExists(session, "customer_id") and session.customer_id gt 0 and session.superAdmin) {
        getWebhook = new backend.core.com.payrexx().getWebhook(session.customer_id, 'authorized');
    }
</cfscript>

<cfoutput>
<div class="tab-container">
    <cfif structKeyExists(planArray[1], "planGroupID") and planArray[1].planGroupID gt 0>

        <div class="tab-content active pb-5 gap-btw px-xl-0">
            <div class="container <cfif local.groupID eq 1>arbeitgeber-payment-container</cfif> payment-container d-flex justify-content-between align-items-start mx-auto">
                <cfloop array="#planArray#" index="i">
                    <div class="<cfif local.groupID eq 1>arbeitgeber-payment-card</cfif> payment-card position-relative">
                        <cfif i.recommended>
                            <div class="ribbon ribbon-top ribbon-bookmark bg-green">
                                <i class="fas fa-star" style="font-size: 16px;"></i>
                            </div>
                        </cfif>
                        <div class="inner-flex">
                            <!--- Plan name --->
                            <h1>#i.planName#</h1>

                            <div class="price d-flex justify-content-start align-items-center">
                                <!--- Price monthly --->
                                <div class="pricing monthly-price">
                                    <cfif i.onRequest>
                                        <span class="month" style="margin-top: 0 !important">#getTrans('txtOnRequest')#</span>
                                    <cfelse>
                                        <cfif i.itsFree eq 1>
                                            <span class="month" style="margin-top: 0 !important"><!--- #getTrans('txtFree')# --->Kostenlose Registrierung</span>
                                        <cfelse>
                                            <span class="dollar">#i.currencySign#</span>
                                            <span>#lsCurrencyFormat(i.priceMonthly, "none")#</span>
                                            <p class="month">/#getTrans('TitMonth')#</p>
                                        </cfif>
                                    </cfif>
                                </div>
                                <!--- Price Yearly --->
                                <div class="pricing yearly-price">
                                    <cfif i.onRequest>
                                        <span class="month" style="margin-top: 0 !important">#getTrans('txtOnRequest')#</span>
                                    <cfelse>
                                        <cfif i.itsFree eq 1>
                                           <span class="month" style="margin-top: 0 !important"><!--- #getTrans('txtFree')# --->Kostenlose Registrierung</span>
                                        <cfelse>
                                            <span class="dollar">#i.currencySign#</span>
                                            <span>#lsCurrencyFormat(i.priceYearly, "none")#</span>
                                            <p class="month">/#getTrans('TitYear')#</p>
                                        </cfif>
                                    </cfif>
                                </div>
                            </div>
                            <div class="pay-detail">
                                <h2>#getTrans('txtIncludedInPlan')#:</h2>
                                <ul>
                                    <!--- Split the shortDescription by line breaks and loop through each line --->
                                    <cfset features = listToArray(i.shortDescription, chr(13))>
                                    <cfloop array="#features#" index="feature">
                                        <li>#feature#</li>
                                    </cfloop>
                                </ul>
                                <!-- Process i.description -->
                                <cfset descriptionContent = reReplace(i.description, "<p>(.*?)</p>", "", "one")>
                                <cfset pContent = reMatch("<p>(.*?)</p>", i.description)>

                                <!-- Output the cleaned i.description (without the p tag) -->
                                #descriptionContent#

                                <!-- Output the extracted p tag content -->
                                <cfif arrayLen(pContent) gt 0>
                                    #pContent[1]#
                                </cfif>
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
                        <div style="display: none;">
                        </div>

                        <!--- If there is a user session, send the user to the booking page --->
                        <cfif structKeyExists(session, "customer_id") and session.customer_id gt 0>

                            <cfif session.superAdmin>

                                <!--- If the user already has a plan, send him to the plan edit page --->
                                <cfif structKeyExists(session.currentPlan, "planID") and session.currentPlan.planID gt 0>

                                    <div class="text-center my-4 <cfif i.recommended>btn-green</cfif>">
                                        <a href="#application.mainURL#/account-settings/plans" rel="nofollow" class="btn w-100">#getTrans('btnActivate')#</a>
                                    </div>

                                <cfelse>

                                    <cfif i.itsFree eq 1>

                                        <!--- Button free --->
                                        <div class="text-center my-4 <cfif i.recommended>btn-green</cfif>">
                                            <a href="#i.bookingLinkO#" rel="nofollow" class="btn w-100 plan">#getTrans('btnActivate')#</a>
                                        </div>

                                    <cfelse>

                                        <cfif getWebhook.recordCount or i.testDays gt 0>

                                            <!--- Button monthly --->
                                            <div class="text-center my-4 price_box monthly <cfif i.recommended>btn-green</cfif>">
                                                <a href="#i.bookingLinkM#" rel="nofollow" class="btn w-100 plan">#getTrans('btnActivate')#</a>
                                            </div>

                                            <!--- Button yearly --->
                                            <div style="display: none;" class="text-center price_box my-4 yearly <cfif i.recommended>btn-green</cfif>">
                                                <a href="#i.bookingLinkY#" rel="nofollow" class="btn w-100 plan">#getTrans('btnActivate')#</a>
                                            </div>

                                        <cfelse>

                                            <!--- To the payment page in order to add a payment method  --->
                                            <div class="text-center my-4 <cfif i.recommended>btn-green</cfif>">
                                                <a href="#application.mainURL#/account-settings/payment" rel="nofollow" class="btn w-100">#getTrans('btnActivate')#</a>
                                            </div>

                                        </cfif>

                                    </cfif>

                                </cfif>

                            <cfelse>

                                <div class="text-center my-4 <cfif i.recommended>btn-green</cfif>">
                                    <a href="#application.mainURL#/dashboard" rel="nofollow" class="btn w-100">#getTrans('btnActivate')#</a>
                                </div>

                            </cfif>



                        <!--- otherwise send to the registration form --->
                        <cfelse>

                            <cfif i.itsFree eq 1>
                                <cfset redirectLinkM = urlEncodedFormat(replace(replace(i.bookingLinkO, application.mainURL, "", "one"), "/", "", "one"))>
                                <cfset redirectLinkY = urlEncodedFormat(replace(replace(i.bookingLinkO, application.mainURL, "", "one"), "/", "", "one"))>
                            <cfelse>
                                <cfset redirectLinkM = urlEncodedFormat(replace(replace(i.bookingLinkM, application.mainURL, "", "one"), "/", "", "one"))>
                                <cfset redirectLinkY = urlEncodedFormat(replace(replace(i.bookingLinkY, application.mainURL, "", "one"), "/", "", "one"))>
                            </cfif>

                             <!--- Button monthly --->
                            <a href="#application.mainURL#/register?redirect=#redirectLinkM#" class="w-100 price_box monthly">
                                <button class="btn-pill pay-btn mt-4">
                                    <cfif len(trim(i.buttonName))>#i.buttonName#<cfelse>#getTrans('btnActivate')#</cfif>
                                </button>
                            </a>

                            <!--- Button yearly --->
                            <a style="display: none;" href="#application.mainURL#/register?redirect=#redirectLinkY#" class="price_box yearly w-100">
                                <button class="btn-pill pay-btn mt-4<cfif i.recommended>btn-green</cfif>">

                                    <cfif len(trim(i.buttonName))>#i.buttonName#
                                         <cfelse>#getTrans('btnActivate')#
                                    </cfif>
                                </button>
                            </a>

                        </cfif>

                    </div>
                </cfloop>
            </div>
        </div>
    </cfif>
</div>

</cfoutput>