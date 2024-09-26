
<cfscript>

    objSysadmin = new backend.core.com.sysadmin();
    qNonDefLng = objSysadmin.getNonDefLng();

</cfscript>


<cfoutput>
<form id="submit_form" method="post" action="#application.mainURL#/sysadm/plans">
<input type="hidden" name="edit_plan" value="#qPlan.intPlanID#">
    <div class="row">
        <div class="col-lg-6 pe-5">
            <div class="mb-3">
                <label class="form-label">Plan group</label>
                <select name="groupID" class="form-select">
                    <cfloop query="qPlanGroups">
                        <option value="#qPlanGroups.intPlanGroupID#" <cfif qPlanGroups.intPlanGroupID eq qPlan.intPlanGroupID>selected</cfif>>#qPlanGroups.strGroupName#</option>
                    </cfloop>
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label">Plan name *</label>
                <div class="input-group input-group-flat">
                    <input type="text" class="form-control" name="plan_name" autocomplete="off" maxlength="100" value="#HTMLEditFormat(qPlan.strPlanName)#" required placeholder="Basic">
                    <span class="input-group-text">
                        <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##plan_name_#qPlan.intPlanID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate plan name"></i></a>
                    </span>
                </div>
            </div>
            <div class="mb-3">
                <label class="form-label">Short description</label>
                <div class="input-group input-group-flat">
                    <textarea class="form-control" name="short_desc" rows="3" maxlength="16000" data-bs-toggle="autosize">#qPlan.strShortDescription#</textarea>
                    <span class="input-group-text">
                        <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##short_desc_#qPlan.intPlanID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate short description"></i></a>
                    </span>
                </div>
            </div>
            <div class="mb-3">
                <label class="form-label">Button name (for not registered users)</label>
                <div class="input-group input-group-flat">
                    <input type="text" class="form-control" name="button_name" autocomplete="off" maxlength="50" value="#HTMLEditFormat(qPlan.strButtonName)#" placeholder="Book now">
                    <span class="input-group-text">
                        <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##button_name_#qPlan.intPlanID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate button name"></i></a>
                    </span>
                </div>
            </div>
            <div class="mb-4">
                <label class="form-label">Booking link</label>
                <div class="input-group">
                    <span class="input-group-text">
                        root/
                    </span>
                    <input type="text" class="form-control" name="booking_link" autocomplete="off" maxlength="255" value="#HTMLEditFormat(qPlan.strBookingLink)#">
                </div>
                <small class="form-hint">
                    Leave empty if you want to use the default setting.
                </small>
            </div>
            <div class="row mb-4">
                <div class="col-lg-12">
                    <label class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" name="free" <cfif qPlan.blnFree>checked</cfif>>
                        <span class="form-check-label">Free plan</span>
                    </label>
                    <small class="form-hint">
                        Activate this plan as "Free". All settings in the "Prices" tab then become ineffective.
                    </small>
                </div>
            </div>
            <div class="row mb-3">
                <div class="col-lg-4">
                    <label class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" name="recommended" <cfif qPlan.blnRecommended>checked</cfif>>
                        <span class="form-check-label">Recommended</span>
                    </label>
                    <small class="form-hint">
                        Mark this plan as "recommendation".
                    </small>
                </div>
                <div class="col-lg-4">
                    <label class="form-label text-end">Number of test days *</label>
                    <cfif qPlan.blnFree>
                        <input type="text" class="form-control text-end" value="#qPlan.intNumTestDays#" disabled style="cursor: not-allowed;" data-bs-toggle="tooltip" data-bs-placement="top" title="Its a free plan">
                    <cfelse>
                        <input type="text" class="form-control text-end" name="test_days" autocomplete="off" maxlength="10" value="#qPlan.intNumTestDays#" placeholder="30" required>
                    </cfif>
                    <small class="form-hint">
                        Enter 0 if you don't want to provide any test days.
                    </small>
                </div>
                <div class="col-lg-4">
                    <label class="form-label text-end">Maximum users *</label>
                    <input type="text" class="form-control text-end" name="max_users" autocomplete="off" maxlength="10" value="#qPlan.intMaxUsers#" placeholder="0" required>
                    <small class="form-hint">
                        Enter 0 if you don't want to use the user limit.
                    </small>
                </div>
            </div>
        </div>
        <div class="col-lg-6">
            <div class="row mb-2">
                <label class="form-label">Description <a href="##?" class="input-group-link ms-2" data-bs-toggle="modal" data-bs-target="##desc_#qPlan.intPlanID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate description"></i></a></label>
            </div>
            <textarea class="form-control editor" name="desc" style="height: 400px;">#qPlan.strDescription#</textarea>
            <small class="form-hint mt-1">
                For <i class="fas fa-check mt-2"></i> checkmarks use the <i class="fas fa-list"></i> unordered list function. The bullet points are automatically replaced.
            </small>
        </div>
    </div>
    <div class="card-footer ps-0 pt-3">
        <button type="submit" id="submit_button" class="btn btn-primary">Save details</button>
    </div>
</form>
#getModal.args('plans', 'strPlanName', qPlan.intPlanID, 100).openModal('plan_name', cgi.path_info, 'Translate plan name')#
#getModal.args('plans', 'strShortDescription', qPlan.intPlanID).openModal('short_desc', cgi.path_info, 'Translate short description')#
#getModal.args('plans', 'strButtonName', qPlan.intPlanID, 50).openModal('button_name', cgi.path_info, 'Translate button name')#
#getModal.args('plans', 'strDescription', qPlan.intPlanID).openModal('desc', cgi.path_info, 'Translate description', 1)#
</cfoutput>