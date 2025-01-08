<!--- Set the css class for recommended plan, if there is one --->
<cfset recommClass1 = "">
<cfset recommClass2 = "">
<cfif i.recommended eq 1>
    <cfset recommClass1 = "border-primary">
    <cfset recommClass2 = "text-bg-primary border-primary">
</cfif>

<cfoutput>
<div class="col d-flex align-items-stretch">

    <div class="card mb-4 rounded-3 shadow-sm #recommClass1# d-flex flex-column">

        <div class="card-header py-3 #recommClass2#">
            <h4 class="my-0 fw-normal">#i.planName#</h4>
        </div>

        <div class="card-body d-flex flex-column">

            <div class="row align-items-center mb-3 flex-grow-1">

                <!--- Price on request --->
                <cfif i.onRequest>

                    <div class="display-5 text-center">#getTrans('txtOnRequest')#</div>

                <!--- Defined price --->
                <cfelse>

                    <!--- Its a free plan --->
                    <cfif i.itsFree eq 1>

                        <!--- Text output for free plans --->
                        <div class="display-5 text-center">#getTrans('txtFree')#</div>

                    <cfelse>

                        <!--- Price output for paid plans --->
                        <div class="display-5 text-center p-0">
                            <span class="d-inline-flex align-items-center">#i.currencySign# #i.dynPrice# <sub><span class="fs-6"> #i.dynBillingCycleTextA#</span></sub></span>
                        </div>

                        <!--- VAT text if defined --->
                        <div class="small text-secondary text-center mt-2">
                            #i.dynVAT#
                        </div>

                    </cfif>

                </cfif>

                <!--- Short description --->
                <div class="row p-4 fs-6 text-start text-secondary">
                    #i.shortDescription#
                </div>

            </div>

            <!--- Longer description with optional check signs --->
            <div class="planDescription text-start mb-4 flex-grow-1">
                #i.description#
            </div>

            <!--- Button | please keep the class 'bookingButton' --->
            <a type="button"
                data-monthly="#i.bookingLinkM#"
                data-yearly="#i.bookingLinkY#"
                class="bookingButton w-100 btn btn-lg btn-outline-primary mt-auto mb-3">
                #i.dynBookingButtonText#
            </a>

        </div>

    </div>

</div>
</cfoutput>


