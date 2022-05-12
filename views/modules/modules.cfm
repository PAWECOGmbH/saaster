
<cfscript>

    objModules = new com.modules();
    getModules = objModules.getAllModules(lngID=getAnyLanguage(session.lng).lngID);

    moduleArray = "";

    if (structKeyExists(session.currentPlan, "modulesIncluded")) {
        if (isArray(session.currentPlan.modulesIncluded) and arrayLen(session.currentPlan.modulesIncluded)) {
            moduleArray = session.currentPlan.modulesIncluded;
        }
    }


    //dump(getModules);
    dump(session.currentPlan);
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
                                <cfloop array="#getModules#" index="module">
                                    <div class="col-lg-3">
                                        <div class="card">
                                            <div class="card-body p-4 text-center">
                                                <span class="avatar avatar-xl mb-3 avatar-rounded" style="background-image: url(#application.mainURL#/userdata/images/modules/#module.picture#)"></span>
                                                <h3 class="m-0 mb-1">#module.name#</h3>
                                                <div class="text-muted">#module.short_description#</div>
                                                <div class="mt-2">
                                                    <cfif module.price_monthly eq 0 and module.price_onetime eq 0>
                                                        <div class="small">#getTrans('txtFree')#</div>
                                                    <cfelseif module.price_onetime gt 0>
                                                        <div class="small text-muted">#module.currencySign# #lsnumberFormat(module.price_onetime, '_,___.__')# #lcase(getTrans('txtOneTime'))#</div>
                                                    <cfelse>
                                                        <div class="small text-muted">#module.currencySign# #lsnumberFormat(module.price_monthly, '_,___.__')# #lcase(getTrans('txtMonthly'))#</div>
                                                    </cfif>
                                                </div>
                                            </div>
                                            <div class="d-flex">
                                                <a href="##?" class="card-btn w-50" data-bs-toggle="modal" data-bs-target="##modul_#module.moduleID#">
                                                    <i class="fa-solid fa-circle-info pe-2"></i> Info
                                                </a>
                                                <cfif module.price_monthly gt 0>
                                                    <div class="dropdown w-50" style="border-left: 1px solid ##e6e7e9;">
                                                        <a class="card-btn dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                                            <i class="fa-solid fa-lock pe-2"></i> #getTrans('btnActivate')#
                                                        </a>
                                                        <div class="dropdown-menu">
                                                            <a class="dropdown-item" href="##">#getTrans('txtMonthly')# (#module.currencySign# #lsnumberFormat(module.priceMonthlyAfterVAT, '_,___.__')#)</a>
                                                            <a class="dropdown-item" href="##">#getTrans('txtYearly')# (#module.currencySign# #lsnumberFormat(module.priceYearlyAfterVAT, '_,___.__')#)</a>
                                                        </div>
                                                    </div>
                                                <cfelse>
                                                    <a href="##?" class="card-btn w-50">
                                                        <i class="fa-solid fa-lock pe-2"></i> #getTrans('btnActivate')#
                                                    </a>
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
                                                </div>
                                                <div class="modal-footer">
                                                    <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">#getTrans('btnClose')#</a>
                                                </div>
                                            </div>

                                        </div>
                                    </div>
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