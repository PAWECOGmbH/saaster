
<cfscript>

    objModules = new com.modules(language=session.lng, currencyID=getCustomerData.currencyStruct.id);
    objPlan = new com.plans(language=session.lng, currencyID=getCustomerData.currencyStruct.id);

    getBookedModules = session.currentModules;
    getBookedModulesAsList = "";
    if (arrayLen(getBookedModules)) {
        loop array=getBookedModules index="i" {
            getBookedModulesAsList = listAppend(getBookedModulesAsList, i.moduleID);
        }
    }

    getAllModules = objModules.getAllModules(getBookedModulesAsList);

    getWebhook = new com.payrexx().getWebhook(session.customer_id, 'authorized');

</cfscript>


<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">#getTrans('titModules')#</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                            <li class="breadcrumb-item active">#getTrans('titModules')#</li>
                        </ol>
                    </div>

                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="container-xl">
            <cfif arrayLen(getBookedModules)>
                <div class="row mb-5">
                    <div class="col-lg-12">
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title">#getTrans('titBookedModules')#</h3>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <cfloop array="#getBookedModules#" index="module">
                                        <cfif structKeyExists(module, "moduleData") and !structIsEmpty(module.moduleData)>
                                            <div class="col-lg-3 mb-4">
                                                <div class="card" style="min-height: 450px;">
                                                    <div class="card-status-top text-#module.moduleStatus.fontColor#"></div>
                                                    <div class="card-body p-4 text-center">
                                                        <span class="avatar avatar-xl mb-3 avatar-rounded" style="background-image: url(#application.mainURL#/userdata/images/modules/#module.moduleData.picture#)"></span>
                                                        <h3 class="m-0 mb-1">#module.moduleData.name#</h3>
                                                        <table class="table text-start mt-4" style="width: 90%;">
                                                            <tr>
                                                                <td width="60%">#getTrans('txtPlanStatus')#:</td>
                                                                <td width="40%" class="text-#module.moduleStatus.fontColor#">#module.moduleStatus.statusTitle#</td>
                                                            </tr>
                                                            <tr>
                                                                <td>#getTrans('txtBookedOn')#:</td>
                                                                <td>#lsDateFormat(getTime.utc2local(utcDate=module.moduleStatus.startDate))#</td>
                                                            </tr>
                                                            <cfif module.moduleStatus.status eq "free">
                                                                </tr>
                                                                    <td colspan="2" align="center">#module.moduleStatus.statusText#</td>
                                                                </tr>
                                                            <cfelseif module.moduleStatus.status eq "canceled" or module.moduleStatus.status eq "expired">
                                                                <cfif isDate(module.moduleStatus.endDate)>
                                                                    <tr>
                                                                        <td>#getTrans('txtExpiryDate')#:</td>
                                                                        <td>#lsDateFormat(getTime.utc2local(utcDate=module.moduleStatus.endDate))#</td>
                                                                    </tr>
                                                                </cfif>
                                                                </tr>
                                                                    <td colspan="2" align="center">#module.moduleStatus.statusText#</td>
                                                                </tr>
                                                            <cfelseif module.moduleStatus.status eq "test">
                                                                <tr>
                                                                    <td>#getTrans('txtExpiryDate')#:</td>
                                                                    <td>#lsDateFormat(getTime.utc2local(utcDate=module.moduleStatus.endDate))#</td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2" align="center">#module.moduleStatus.statusText#</td>
                                                                </tr>
                                                            <cfelseif module.moduleStatus.status eq "active">
                                                                <cfif module.moduleStatus.recurring eq "onetime">
                                                                    <tr>
                                                                        <td colspan="2" align="center">#getTrans('txtOneTimePayment')#</td>
                                                                    </tr>
                                                                <cfelse>
                                                                    <tr>
                                                                        <td>#getTrans('txtRenewPlanOn')#:</td>
                                                                        <td>#lsDateFormat(getTime.utc2local(utcDate=module.moduleStatus.endDate))#</td>
                                                                    </tr>
                                                                </cfif>
                                                            </cfif>
                                                        </table>
                                                    </div>
                                                    <div class="d-flex">
                                                        <cfif module.includedInCurrentPlan>
                                                            <cfif len(trim(module.moduleData.settingPath))>
                                                                <a href="#application.mainURL#/#module.moduleData.settingPath#" class="card-btn">
                                                                    <i class="fas fa-cog pe-2"></i> #getTrans('txtSettings')#
                                                                </a>
                                                            </cfif>
                                                        <cfelse>
                                                            <cfif (module.moduleData.priceMonthly gt 0 or module.moduleData.priceOnetime gt 0 or module.moduleData.priceYearly gt 0) and module.moduleStatus.recurring neq "onetime" and session.superAdmin>
                                                                <cfif module.moduleStatus.status eq "canceled">
                                                                    <a href="#application.mainURL#/cancel?module=#module.moduleData.moduleID#&revoke" class="card-btn text-blue">
                                                                        <i class="fas fa-undo pe-2 text-blue"></i> #getTrans('btnRevokeCancellation')#
                                                                    </a>
                                                                <cfelse>
                                                                    <cfif len(trim(module.moduleData.settingPath))>
                                                                        <a <cfif module.moduleStatus.status neq "expired">href="#application.mainURL#/#module.moduleData.settingPath#"</cfif> class="card-btn">
                                                                            <i class="fas fa-cog pe-2"></i> #getTrans('txtSettings')#
                                                                        </a>
                                                                    </cfif>
                                                                    <cfif module.moduleStatus.recurring eq "test">
                                                                        <cfif getWebhook.recordCount>
                                                                            <cfset linkM = module.moduleData.bookingLinkM>
                                                                            <cfset linkY = module.moduleData.bookingLinkY>
                                                                            <cfset linkO = module.moduleData.bookingLinkO>
                                                                        <cfelse>
                                                                            <cfset linkM = application.mainURL & "/account-settings/payment">
                                                                            <cfset linkY = application.mainURL & "/account-settings/payment">
                                                                            <cfset linkO = application.mainURL & "/account-settings/payment">
                                                                        </cfif>
                                                                        <div class="dropdown w-50" style="border-left: 1px solid ##e6e7e9;">
                                                                            <a class="card-btn dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                                                                <i class="fa-solid fa-lock activate-lock pe-2"></i> #getTrans('btnActivate')#
                                                                            </a>
                                                                            <div class="dropdown-menu">
                                                                                <cfif module.moduleData.priceMonthly gt 0>
                                                                                    <a class="dropdown-item activate-module" href="#linkM#">#getTrans('txtMonthly')# (#module.moduleData.currencySign# #lsCurrencyFormat(module.moduleData.priceMonthly, "none")#)</a>
                                                                                    <a class="dropdown-item activate-module" href="#linkY#">#getTrans('txtYearly')# (#module.moduleData.currencySign# #lsCurrencyFormat(module.moduleData.priceYearly, "none")#)</a>
                                                                                <cfelse>
                                                                                    <a class="dropdown-item activate-module" href="#linkO#">#module.moduleData.currencySign# #lsCurrencyFormat(module.moduleData.priceOneTime, "none")#</a>
                                                                                </cfif>
                                                                                <cfif module.moduleStatus.status eq "expired">
                                                                                    <a style="cursor: pointer;" class="dropdown-item" onclick="sweetAlert('warning', '#application.mainURL#/cancel?module=#module.moduleData.moduleID#', '#getTrans('txtCancel')#', '#getTrans('msgCancelModuleWarningText')#', '#getTrans('btnDontCancel')#', '#getTrans('btnYesCancel')#')"><i class="far fa-trash-alt pe-2 text-red"></i> #getTrans('txtCancel')#</a>
                                                                                </cfif>
                                                                            </div>
                                                                        </div>
                                                                    <cfelse>
                                                                        <a style="cursor: pointer;" class="card-btn text-red" onclick="sweetAlert('warning', '#application.mainURL#/cancel?module=#module.moduleData.moduleID#', '#getTrans('txtCancel')#', '#getTrans('msgCancelModuleWarningText')#', '#getTrans('btnDontCancel')#', '#getTrans('btnYesCancel')#')">
                                                                            <i class="far fa-trash-alt pe-2 text-red"></i> #getTrans('txtCancel')#
                                                                        </a>
                                                                    </cfif>
                                                                </cfif>
                                                            <cfelse>
                                                                <cfif len(trim(module.moduleData.settingPath))>
                                                                    <a href="#application.mainURL#/#module.moduleData.settingPath#" class="card-btn">
                                                                        <i class="fas fa-cog pe-2"></i> #getTrans('txtSettings')#
                                                                    </a>
                                                                </cfif>
                                                            </cfif>
                                                        </cfif>

                                                    </div>
                                                </div>
                                            </div>
                                        </cfif>
                                    </cfloop>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </cfif>

            <cfif arrayLen(getAllModules)>
                <div class="row">
                    <div class="col-lg-12">
                        <div class="card">
                            <div class="card-header">
                                <h3 class="card-title">#getTrans('titAvailableModules')#</h3>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <cfloop array="#getAllModules#" index="module">
                                        <cfif module.bookable or arrayLen(module.includedInPlans)>
                                            <div class="col-lg-3 mb-4">
                                                <div class="card" style="min-height: 400px;">
                                                    <div class="card-body p-4 text-center">
                                                        <span class="avatar avatar-xl mb-3 avatar-rounded" style="background-image: url(#application.mainURL#/userdata/images/modules/#module.picture#)"></span>
                                                        <h3 class="m-0 mb-3">#module.name#</h3>
                                                        <div class="text-muted">#module.shortdescription#</div>
                                                        <div class="mt-3">
                                                            <cfif module.priceMonthly eq 0 and module.priceOnetime eq 0 and module.priceOnetime eq 0>
                                                                <cfif arrayLen(module.includedInPlans)>
                                                                    <div class="small">#getTrans('txtIncludedInPlan')#</div>
                                                                <cfelse>
                                                                    <div class="small">#getTrans('txtFree')#</div>
                                                                </cfif>
                                                            <cfelseif module.priceOnetime gt 0>
                                                                <div class="text-muted">#module.currencySign# #lsCurrencyFormat(module.priceOnetime, "none")# #lcase(getTrans('txtOneTime'))#</div>
                                                            <cfelseif module.priceMonthly gt 0>
                                                                <div class="text-muted">#module.currencySign# #lsCurrencyFormat(module.priceMonthly, "none")# #lcase(getTrans('txtMonthly'))#</div>
                                                            </cfif>
                                                        </div>
                                                    </div>
                                                    <div class="d-flex">
                                                        <a href="##?" class="card-btn w-50" data-bs-toggle="modal" data-bs-target="##modul_#module.moduleID#">
                                                            <i class="fa-solid fa-circle-info pe-2"></i> Info
                                                        </a>
                                                        <cfif session.superAdmin>
                                                            <cfif module.priceMonthly gt 0 or module.priceOnetime gt 0>
                                                                <cfset directBook = 0>
                                                                <cfif module.testDays gt 0>
                                                                    <cfset directBook = 1>
                                                                <cfelse>
                                                                    <cfif getWebhook.recordCount>
                                                                        <cfset directBook = 1>
                                                                    </cfif>
                                                                </cfif>
                                                                <cfif directBook>
                                                                    <cfset linkM = module.bookingLinkM>
                                                                    <cfset linkY = module.bookingLinkY>
                                                                    <cfset linkO = module.bookingLinkO>
                                                                <cfelse>
                                                                    <cfset linkM = application.mainURL & "/account-settings/payment">
                                                                    <cfset linkY = application.mainURL & "/account-settings/payment">
                                                                    <cfset linkO = application.mainURL & "/account-settings/payment">
                                                                </cfif>
                                                                <cfif module.priceMonthly gt 0>
                                                                    <div class="dropdown w-50" style="border-left: 1px solid ##e6e7e9;">
                                                                        <a class="card-btn dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                                                            <i class="fa-solid fa-lock activate-lock pe-2"></i> #getTrans('btnActivate')#
                                                                        </a>
                                                                        <div class="dropdown-menu">
                                                                            <a class="dropdown-item activate-module" href="#linkM#">#getTrans('txtMonthly')# (#module.currencySign# #lsCurrencyFormat(module.priceMonthly, "none")#)</a>
                                                                            <a class="dropdown-item activate-module" href="#linkY#">#getTrans('txtYearly')# (#module.currencySign# #lsCurrencyFormat(module.priceYearly, "none")#)</a>
                                                                        </div>
                                                                    </div>
                                                                <cfelseif module.priceOnetime gt 0>
                                                                    <a href="#linkO#" class="card-btn w-50 activate-module">
                                                                        <i class="fa-solid fa-lock activate-lock pe-2"></i> #getTrans('btnActivate')#
                                                                    </a>
                                                                </cfif>
                                                            <cfelse>
                                                                <cfif not arrayLen(module.includedInPlans)>
                                                                    <a href="#module.bookingLinkO#" class="card-btn w-50 activate-module">
                                                                        <i class="fa-solid fa-lock activate-lock pe-2"></i> #getTrans('btnActivate')#
                                                                    </a>
                                                                </cfif>
                                                            </cfif>
                                                        </cfif>
                                                    </div>
                                                </div>
                                            </div>
                                            <div id="modul_#module.moduleID#" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                                <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable" role="document">

                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">#module.name#</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <div class="mb-3">
                                                                #module.description#
                                                            </div>
                                                            <div class="mb-3">

                                                                <cfif module.priceMonthly eq 0 and module.priceOnetime eq 0>
                                                                    <div class="display-6 fw-bold my-3">#getTrans('txtFree')#</div>
                                                                <cfelseif module.priceOnetime gt 0>
                                                                    <div class="display-6 fw-bold mt-3 mb-1"><span class="currency">#module.currencySign#</span> #lsCurrencyFormat(module.priceOnetime, "none")#</div>
                                                                    <div class="text-muted mb-1">#getTrans('txtOneTime')#</div>
                                                                    <div class="text-muted small">#module.vat_text_onetime#</div>
                                                                <cfelse>
                                                                    <div class="row my-3 col-md-12">
                                                                        <div class="col-md-6">
                                                                            <div class="fw-bold my-3">#getTrans('txtMonthly')#</div>
                                                                            <div class="display-6 fw-bold mb-1"><span class="currency">#module.currencySign#</span> #lsCurrencyFormat(module.priceMonthly, "none")#</div>
                                                                            <div class="text-muted mb-1">#getTrans('txtMonthlyPayment')#</div>
                                                                            <div class="text-muted small">#module.vat_text_monthly#</div>
                                                                        </div>
                                                                        <div class="col-md-6">
                                                                            <div class="fw-bold my-3">#getTrans('txtYearly')#</div>
                                                                            <div class="display-6 fw-bold mb-1"><span class="currency">#module.currencySign#</span> #lsCurrencyFormat(module.priceYearly, "none")#</div>
                                                                            <div class="text-muted mb-1">#getTrans('txtYearlyPayment')#</div>
                                                                            <div class="text-muted small">#module.vat_text_yearly#</div>
                                                                        </div>
                                                                    </div>
                                                                </cfif>

                                                            </div>
                                                            <div class="row p-2 mt-4">
                                                                <cfif arrayLen(module.includedInPlans)>
                                                                    <div class="fw-bold">#getTrans('txtIncludedInPlans')#:</div>
                                                                    <div class="mt-3">
                                                                        <cfloop array="#module.includedInPlans#" index="i">
                                                                            <ul class="my-0">
                                                                                <li class="my-0 py-0">#i.name#</li>
                                                                            </ul>
                                                                        </cfloop>
                                                                        <p class="mt-3 ps-3"><a href="#application.mainURL#/plans">#getTrans('txtBookNow')#</a></p>
                                                                    </div>
                                                                </cfif>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">#getTrans('btnClose')#</a>
                                                        </div>
                                                    </div>

                                                </div>
                                            </div>
                                        </cfif>
                                    </cfloop>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </cfif>

        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>