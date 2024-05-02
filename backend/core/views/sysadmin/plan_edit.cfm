
<cfscript>

    objSysadmin = new backend.core.com.sysadmin();

    // Exception handling for sef and user id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisPlanID = thiscontent.thisID;

    if(not isNumeric(thisPlanID) or thisPlanID lte 0) {
        location url="#application.mainURL#/sysadmin/plans" addtoken="false";
    }

    qPlanGroups = objSysadmin.getPlanGroups();
    qPlan = objSysadmin.getPlan(thisPlanID);

    if(!qPlan.recordCount){
        location url="#application.mainURL#/sysadmin/plans" addtoken="false";
    }

    param name="url.tab" default="details";
    details = "";
    prices = "";
    features = "";
    modules = "";
    switch (url.tab) {
        case "details":
            details = "show active";
            break;
        case "prices":
            prices = "show active";
            break;
        case "features":
            features = "show active";
            break;
        case "modules":
            modules = "show active";
            break;
    }

    getModal = new backend.core.com.translate();

</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Plans</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/sysadmin/plans">Plans</a></li>
                            <li class="breadcrumb-item active">#qPlan.strPlanName#</li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 text-end">
                        <div class="button-group">
                            <a href="#application.mainURL#/sysadmin/plans" class="btn btn-primary">
                                <i class="fas fa-angle-double-left pe-3"></i> Back to plans
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="#getLayout.layoutPage#">
            <div class="row">
                <div class="col-lg-12">
                    <div class="card">
                        <div class="card-header" style="display: block;">
                            <div class="row mt-2">
                                <div class="col-lg-6">
                                    <h3 >Configure plan "#qPlan.strPlanName#" in group "#qPlan.strGroupName#"</h3>
                                </div>
                                <cfif qPlanGroups.recordCount>
                                    <div class="col-lg-6 text-end pe-3">
                                        <a href="#application.mainURL#/plans" target="_blank"><i class="fas fa-search h2" data-bs-toggle="tooltip" data-bs-placement="top" title="Preview plans"></i></a>
                                    </div>
                                </cfif>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row row-cards">
                                <div class="col-md-12">
                                    <div class="card">
                                        <ul class="nav nav-tabs nav-fill mb-4" data-bs-toggle="tabs">
                                            <li class="nav-item">
                                                <a href="##details" class="nav-link #details#" data-bs-toggle="tab">
                                                    <i class="fas fa-info-circle pe-3"></i>
                                                    Details
                                                </a>
                                            </li>
                                            <li class="nav-item">
                                                <cfif qPlan.blnFree>
                                                    <a class="nav-link" style="cursor: not-allowed;" data-bs-toggle="tooltip" data-bs-placement="top" title="Its a free plan">
                                                        <i class="fas fa-coins pe-3"></i>
                                                        Prices
                                                    </a>
                                                <cfelse>
                                                    <a href="##prices" class="nav-link #prices#" data-bs-toggle="tab">
                                                        <i class="fas fa-coins pe-3"></i>
                                                        Prices
                                                    </a>
                                                </cfif>
                                            </li>
                                            <li class="nav-item">
                                                <a href="##features" class="nav-link #features#" data-bs-toggle="tab">
                                                    <i class="fas fa-list-ul pe-3"></i>
                                                    Features
                                                </a>
                                            </li>
                                            <li class="nav-item">
                                                <a href="##modules" class="nav-link #modules#" data-bs-toggle="tab">
                                                    <i class="fas fa-th-list pe-3"></i>
                                                    Modules
                                                </a>
                                            </li>
                                        </ul>
                                        <div class="card-body">
                                            <div class="tab-content">
                                                <div class="tab-pane #details#" id="details">
                                                    <cfinclude template="plan_details.cfm">
                                                </div>
                                                <div class="tab-pane #prices#" id="prices">
                                                    <cfinclude template="plan_prices.cfm">
                                                </div>
                                                <div class="tab-pane #features#" id="features">
                                                    <cfinclude template="plan_feat.cfm">
                                                </div>
                                                <div class="tab-pane #modules#" id="modules">
                                                    <cfinclude template="plan_modules.cfm">
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
    

</div>