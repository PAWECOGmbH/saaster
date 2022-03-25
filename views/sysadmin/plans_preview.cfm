<cfset planObj = new com.plans().getPlans()>
<cfoutput>
<div class="modal modal-blur fade" id="plans_preview" tabindex="-1" style="display: none;" aria-hidden="true">
    <div class="modal-dialog modal-full-width modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><cfif arrayLen(planObj)>#planObj[1].groupName#</cfif></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
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
                                    <div class="text-uppercase text-muted font-weight-medium">#i.planName#</div>
                                    <cfif i.onRequest>
                                        <div class="display-6 fw-bold my-3">#getTrans('txtOnRequest')#</div>
                                    <cfelse>
                                        <cfif i.priceMonthly eq 0>
                                            <div class="display-5 fw-bold my-3">#getTrans('txtFree')#</div>
                                        <cfelse>
                                            <div class="display-5 fw-bold mb-1">#i.currency# #numberFormat(i.priceMonthly, '__.__')#</div>
                                            <div class="small text-muted">#getTrans('txtMonthly')#</div>
                                            <div class="small text-muted">(#i.currency# #numberFormat(i.priceYearly, '__.__')# #getTrans('txtYearly')#)</div>
                                        </cfif>
                                    </cfif>
                                    <div class="text-center px-3">
                                        #replace(i.shortDescription, chr(13), "<br />")#
                                    </div>
                                    <div class="text-center mt-4 <cfif i.recommended>btn-green</cfif>">
                                        <a href="##" class="btn w-100"><cfif len(trim(i.buttonName))>#i.buttonName#<cfelse>#getTrans('btnActivate')#</cfif></a>
                                    </div>
                                </div>
                                <div class="card-body plan-cards">
                                    #i.description#
                                </div>
                            </div>
                        </div>
                    </cfloop>
                </div>
                <div class="row pt-2 small">
                    <cfif planObj[1].isNet eq 1>
                        <cfswitch expression="#planObj[1].vatType#">
                            <cfcase value="1">
                                <p class="text-muted">#getTrans('txtPlusVat')# #numberFormat(planObj[1].vat, '__.__')#%</p>
                            </cfcase>
                            <cfcase value="2">
                                <p class="text-muted">#getTrans('txtTotalExcl')#</p>
                            </cfcase>
                            <cfdefaultcase>
                            </cfdefaultcase>
                        </cfswitch>
                    <cfelse>
                        <cfswitch expression="#planObj[1].vatType#">
                            <cfcase value="1">
                                <p class="text-muted">#getTrans('txtVatIncluded')# #numberFormat(planObj[1].vat, '__.__')#%</p>
                            </cfcase>
                            <cfcase value="2">
                                <p class="text-muted">#getTrans('txtTotalExcl')#</p>
                            </cfcase>
                            <cfdefaultcase>
                            </cfdefaultcase>
                        </cfswitch>
                    </cfif>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn me-auto" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
</cfoutput>
