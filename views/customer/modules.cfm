
<cfscript>

    custCountryID = getCustomerData.intCountryID;
    custCountry = application.objGlobal.getCurrencyOfCountry(custCountryID);
    if (custCountry.currencyID gt 0) {
        currencyID = custCountry.currencyID;
    } else {
        currencyID = application.objGlobal.getDefaultCurrency().currencyID;
    }

    objModules = new com.modules(language=session.lng, currencyID=currencyID);

    getAllModules = objModules.getAllModules();

    getBookedModules = objModules.getBookedModules(session.customer_id);

    // Get included modules in booked plans as list
    includedModuleList = "";
    if (structKeyExists(session.currentPlan, "modulesIncludedAsList")) {
        includedModuleList = session.currentPlan.modulesIncludedAsList;
    }

    // Get separately booked modules as list
    bookedModuleList = "";
    if (arrayLen(getBookedModules)) {
        cfloop(array=getBookedModules, index="i") {
            bookedModuleList = listAppend(bookedModuleList, i.moduleID);
        }
    }

    totalModuleList = "";
    totalModuleList = listAppend(totalModuleList, includedModuleList);
    totalModuleList = listAppend(totalModuleList, bookedModuleList);
    totalModuleList = listRemoveDuplicates(totalModuleList);

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
            <div class="row">
                <div class="col-lg-12">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">#getTrans('titModules')#</h3>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <cfloop array="#getAllModules#" index="module">
                                    <cfif module.active>
                                        <cfset moduleStatus = objModules.getModuleStatus(session.customer_id, module.moduleID)>
                                        <cfif listFind(includedModuleList, module.moduleID)>
                                            <cfset bgColor = "bg-green">
                                            <cfset fontColor = "text-green">
                                            <cfset objPlans = new com.plans(language=session.lng)>
                                        <cfelseif structKeyExists(moduleStatus, "fontColor")>
                                            <cfset bgColor = "bg-" & moduleStatus.fontColor>
                                            <cfset fontColor = "text-" & moduleStatus.fontColor>
                                        <cfelse>
                                            <cfset bgColor = "">
                                            <cfset fontColor = "">
                                        </cfif>
                                        <div class="col-lg-3">
                                            <div class="card" style="min-height: 450px;">
                                                <div class="card-status-top #bgColor#"></div>
                                                <div class="card-body p-4 text-center">
                                                    <span class="avatar avatar-xl mb-3 avatar-rounded" style="background-image: url(#application.mainURL#/userdata/images/modules/#module.picture#)"></span>
                                                    <h3 class="m-0 mb-1">#module.name#</h3>
                                                    <cfif listFind(bookedModuleList, module.moduleID)>
                                                        <table class="table text-start mt-4" style="width: 90%;">
                                                            <tr>
                                                                <td width="60%">#getTrans('txtPlanStatus')#:</td>
                                                                <td width="40%" class="#fontColor#">#moduleStatus.statusTitle#</td>
                                                            </tr>
                                                            <tr>
                                                                <td>#getTrans('txtBookedOn')#:</td>
                                                                <td>#lsDateFormat(moduleStatus.startDate)#</td>
                                                            </tr>
                                                            <cfif moduleStatus.recurring eq "onetime">
                                                                <tr>
                                                                    <td colspan="2" align="center">#moduleStatus.statusText#</td>
                                                                </tr>
                                                            <cfelseif moduleStatus.status eq "canceled">
                                                                <cfif isDate(moduleStatus.endDate)>
                                                                    <tr>
                                                                        <td>#getTrans('txtExpiryDate')#:</td>
                                                                        <td>#lsDateFormat(moduleStatus.endDate)#</td>
                                                                    </tr>
                                                                <cfelse>
                                                                    <tr>
                                                                        <td>#getTrans('txtExpiryDate')#:</td>
                                                                        <td>#lsDateFormat(moduleStatus.endTestDate)#</td>
                                                                    </tr>
                                                                </cfif>
                                                                </tr>
                                                                    <td colspan="2" align="center">#moduleStatus.statusText#</td>
                                                                </tr>
                                                            <cfelseif moduleStatus.status eq "test">
                                                                <tr>
                                                                    <td>#getTrans('txtExpiryDate')#:</td>
                                                                    <td>#lsDateFormat(moduleStatus.endTestDate)#</td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2" align="center">#moduleStatus.statusText#</td>
                                                                </tr>

                                                            <cfelseif moduleStatus.status eq "active">
                                                                <tr>
                                                                    <td>#getTrans('txtRenewPlanOn')#:</td>
                                                                    <td>#lsDateFormat(moduleStatus.endDate)#</td>
                                                                </tr>
                                                            </cfif>
                                                        </table>
                                                    <cfelse>
                                                        <div class="text-muted">#module.short_description#</div>
                                                        <cfif listFind(includedModuleList, module.moduleID)>
                                                            <div class="text-green mt-3">#getTrans('txtIncludedInPlan')#</div>
                                                            <cfif session.currentPlan.status eq "canceled">
                                                                <div class="small text-red">#getTrans('txtCanceled')#</div>
                                                            </cfif>
                                                        <cfelse>
                                                            <div class="mt-2">
                                                                <cfif module.price_monthly eq 0 and module.price_onetime eq 0>
                                                                    <div class="small">#getTrans('txtFree')#</div>
                                                                <cfelseif module.price_onetime gt 0>
                                                                    <div class="small text-muted">#module.currencySign# #lsnumberFormat(module.price_onetime, '_,___.__')# #lcase(getTrans('txtOneTime'))#</div>
                                                                <cfelse>
                                                                    <div class="small text-muted">#module.currencySign# #lsnumberFormat(module.price_monthly, '_,___.__')# #lcase(getTrans('txtMonthly'))#</div>
                                                                </cfif>
                                                            </div>
                                                        </cfif>
                                                    </cfif>
                                                </div>
                                                <div class="d-flex">
                                                    <!--- <cfdump var="#moduleStatus.status#"> --->
                                                    <cfif listFind(totalModuleList, module.moduleID)>
                                                        <cfif len(trim(module.settingPath))>
                                                            <cfset settingLink = "#application.mainURL#/#module.settingPath#">
                                                        <cfelse>
                                                            <cfset settingLink = "##?">
                                                        </cfif>
                                                        <cfif listFind(includedModuleList, module.moduleID)>
                                                            <a href="#settingLink#" class="card-btn">
                                                                <i class="fas fa-cog pe-2"></i> #getTrans('txtSettings')#
                                                            </a>
                                                        <cfelse>
                                                            <cfif (module.price_monthly gt 0 or module.price_onetime gt 0 or module.price_yearly gt 0) and moduleStatus.recurring neq "onetime" and session.superAdmin>
                                                                <cfif moduleStatus.status eq "canceled">
                                                                    <a href="#application.mainURL#/cancel?module=#module.moduleID#&revoke" class="card-btn text-blue">
                                                                        <i class="fas fa-undo pe-2 text-blue"></i> #getTrans('btnRevokeCancellation')#
                                                                    </a>
                                                                <cfelse>
                                                                    <a href="#settingLink#" class="card-btn">
                                                                        <i class="fas fa-cog pe-2"></i> #getTrans('txtSettings')#
                                                                    </a>
                                                                    <a href="##?" class="card-btn text-red" onclick="sweetAlert('warning', '#application.mainURL#/cancel?module=#module.moduleID#', '#getTrans('txtCancel')#', '#getTrans('msgCancelModuleWarningText')#', '#getTrans('btnDontCancel')#', '#getTrans('btnYesCancel')#')">
                                                                        <i class="far fa-trash-alt pe-2 text-red"></i> #getTrans('txtCancel')#
                                                                    </a>
                                                                </cfif>
                                                            <cfelse>
                                                                <a href="#settingLink#" class="card-btn">
                                                                    <i class="fas fa-cog pe-2"></i> #getTrans('txtSettings')#
                                                                </a>
                                                            </cfif>
                                                        </cfif>
                                                    <cfelse>
                                                        <a href="##?" class="card-btn w-50" data-bs-toggle="modal" data-bs-target="##modul_#module.moduleID#">
                                                            <i class="fa-solid fa-circle-info pe-2"></i> Info
                                                        </a>
                                                        <cfif session.superAdmin>
                                                            <cfif module.price_monthly gt 0>
                                                                <div class="dropdown w-50" style="border-left: 1px solid ##e6e7e9;">
                                                                    <a class="card-btn dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                                                        <i class="fa-solid fa-lock pe-2"></i> #getTrans('btnActivate')#
                                                                    </a>
                                                                    <div class="dropdown-menu">
                                                                        <a class="dropdown-item" href="#module.bookingLinkM#">#getTrans('txtMonthly')# (#module.currencySign# #lsnumberFormat(module.price_monthly, '_,___.__')#)</a>
                                                                        <a class="dropdown-item" href="#module.bookingLinkY#">#getTrans('txtYearly')# (#module.currencySign# #lsnumberFormat(module.price_yearly, '_,___.__')#)</a>
                                                                    </div>
                                                                </div>
                                                            <cfelseif module.price_onetime gt 0>
                                                                <a href="#module.bookingLinkO#" class="card-btn w-50">
                                                                    <i class="fa-solid fa-lock pe-2"></i> #getTrans('btnActivate')#
                                                                </a>
                                                            <cfelse>
                                                                <a href="#module.bookingLinkF#" class="card-btn w-50">
                                                                    <i class="fa-solid fa-lock pe-2"></i> #getTrans('btnActivate')#
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

                                                            <cfif module.price_monthly eq 0 and module.price_onetime eq 0>
                                                                <div class="display-6 fw-bold my-3">#getTrans('txtFree')#</div>
                                                            <cfelseif module.price_onetime gt 0>
                                                                <div class="display-6 fw-bold mt-3 mb-1"><span class="currency">#module.currencySign#</span> #lsnumberFormat(module.price_onetime, '_,___.__')#</div>
                                                                <div class="text-muted mb-1">#getTrans('txtOneTime')#</div>
                                                                <div class="text-muted small">#module.vat_text_onetime#</div>
                                                            <cfelse>
                                                                <div class="row my-3 col-md-12">
                                                                    <div class="col-md-6">
                                                                        <div class="fw-bold my-3">#getTrans('txtMonthly')#</div>
                                                                        <div class="display-6 fw-bold mb-1"><span class="currency">#module.currencySign#</span> #lsnumberFormat(module.price_monthly, '_,___.__')#</div>
                                                                        <div class="text-muted mb-1">#getTrans('txtMonthlyPayment')#</div>
                                                                        <div class="text-muted small">#module.vat_text_monthly#</div>
                                                                    </div>
                                                                    <div class="col-md-6">
                                                                        <div class="fw-bold my-3">#getTrans('txtYearly')#</div>
                                                                        <div class="display-6 fw-bold mb-1"><span class="currency">#module.currencySign#</span> #lsnumberFormat(module.price_yearly, '_,___.__')#</div>
                                                                        <div class="text-muted mb-1">#getTrans('txtYearlyPayment')#</div>
                                                                        <div class="text-muted small">#module.vat_text_yearly#</div>
                                                                    </div>
                                                                </div>
                                                            </cfif>

                                                        </div>
                                                        <div class="row p-2 mt-4">
                                                            <cfif listLen(module.includedPlans)>
                                                                <div class="fw-bold">#getTrans('txtIncludedInPlans')#:</div>
                                                                <div class="mt-3">
                                                                    <cfloop list="#module.includedPlans#" index="i">
                                                                        <ul class="my-0">
                                                                            <li class="my-0 py-0">#objPlans.getPlanDetail(i).planName#</li>
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
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>