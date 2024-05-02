

<cfscript>

    objSysadmin = new backend.core.com.sysadmin();
    qFeatures = objSysadmin.getFeatures(thisPlanID);

</cfscript>

<cfif qFeatures.recordCount>

    <cfoutput>
    <form id="submit_form" method="post" action="#application.mainURL#/sysadm/plans">
    <input type="hidden" name="edit_features" value="#thisPlanID#">
        <div class="row mb-5">
            <div class="col-lg-10">
                <cfloop query="qFeatures">
                    <div class="row pt-3" style="border-bottom: 1px solid ##eee;">
                        <div class="col-lg-4 pt-2">
                            <cfif qFeatures.blnCategory eq 1>
                                <h3>#qFeatures.strFeatureName#</h3>
                            <cfelse>
                                <p>#qFeatures.strFeatureName#</p>
                            </cfif>
                        </div>
                        <div class="col-lg-3 pt-2">
                            <cfif !qFeatures.blnCategory>
                                <div class="mb-3">
                                    <label class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" name="checkmark_#qFeatures.currID#" <cfif qFeatures.blnCheckmark eq 1>checked</cfif>>
                                        <span class="form-check-label">Checkmark</span>
                                    </label>
                                </div>
                            </cfif>
                        </div>
                        <div class="col-lg-5 pb-3 pe-4">
                            <cfif !qFeatures.blnCategory>
                                <div class="input-group input-group-flat">
                                    <input type="text" name="text_#qFeatures.currID#" class="form-control" autocomplete="off" value="#trim(qFeatures.strValue)#" maxlength="100">
                                    <cfif len(trim(qFeatures.strValue))>
                                        <span class="input-group-text">
                                            <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##value_#qFeatures.intPlansPlanFeatID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate value"></i></a>
                                        </span>
                                    </cfif>
                                </div>
                            </cfif>
                        </div>
                    </div>
                </cfloop>
            </div>
        </div>
        <div class="card-footer ps-0 pt-3">
            <button type="submit" id="submit_button" class="btn btn-primary">Save features</button>
        </div>
    </form>
    </cfoutput>
    <cfoutput query="qFeatures">
    <cfif len(trim(qFeatures.strValue))>
    #getModal.args('plans_plan_features', 'strValue', qFeatures.intPlansPlanFeatID, 100).openModal('value', cgi.path_info & '?tab=features', 'Translate value')#
    </cfif>
    </cfoutput>

<cfelse>

    <cfoutput>
    <p class="text-red">You must create some features first. <a href="#application.mainURL#/sysadmin/planfeatures"><i class="fas fa-long-arrow-alt-right"></i> Manage features</a></p>
    </cfoutput>

</cfif>