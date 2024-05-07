
<cfscript>

    objSysadmin = new backend.core.com.sysadmin();
    qModules = objSysadmin.getPlanModules(thisPlanID);
    
</cfscript>

<cfoutput>
<form id="submit_form" method="post" action="#application.mainURL#/sysadm/plans">
<input type="hidden" name="plan_modules" value="#qPlan.intPlanID#">
    <cfif qModules.recordCount>
        <div class="row">
            <div class="col-lg-12">
                <p>Select the modules that are included in this plan without having to pay additional fees.</p>
            </div>
            <div class="mb-3">
                <div class="row">
                    <cfloop query="qModules">
                        <div class="col-lg-6 mb-3">
                            <div class="form-selectgroup form-selectgroup-boxes d-flex flex-column">
                                <label class="form-selectgroup-item flex-fill">
                                    <input type="checkbox" class="form-selectgroup-input" name="moduleID" value="#qModules.intModuleID#" <cfif isNumeric(qModules.currModule)>checked</cfif>>
                                    <div class="form-selectgroup-label d-flex align-items-center p-3">
                                        <div class="me-3">
                                            <span class="form-selectgroup-check"></span>
                                        </div>
                                        <div class="form-selectgroup-label-content d-flex align-items-center">
                                            <span class="avatar me-3" style="background-image: url(#application.mainURL#/userdata/images/modules/#qModules.strPicture#)"></span>
                                            <div>
                                                <div class="font-weight-medium">#qModules.strModuleName#</div>
                                                <div class="text-muted">#qModules.strShortDescription#</div>
                                            </div>
                                        </div>
                                    </div>
                                </label>
                            </div>
                        </div>
                    </cfloop>
                </div>
            </div>
        </div>
        <div class="card-footer ps-0 pt-3">
            <button type="submit" id="submit_button" class="btn btn-primary">Save modules</button>
        </div>
    <cfelse>
        <p class="text-red">No modules found.</p>
    </cfif>
</form>
</cfoutput>