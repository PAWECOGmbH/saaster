
<cfscript>
    
    getModal = new backend.core.com.translate();
    objSysadmin = new backend.core.com.sysadmin();
    qPlanFeatures = objSysadmin.getPlanFeatures();

</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">
            <div class="row">
                <div class="col-lg-6 mb-3">
                    <div class="#getLayout.layoutPageHeader#">
                        <h4 class="page-title">Plan features</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/sysadmin/plans">Plans</a></li>
                            <li class="breadcrumb-item active">Plan features</li>
                        </ol>
                    </div>
                </div>
                <div class="#getLayout.layoutPageHeader# col-lg-6 mb-3 text-end">
                    <div class="button-group">
                        <a href="#application.mainURL#/sysadmin/plans" class="btn btn-primary">
                            <i class="fas fa-angle-double-left pe-3"></i> Back to plans
                        </a>
                        <a href="##" data-bs-toggle="modal" data-bs-target="##feature_new" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> Add feature
                        </a>
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
                        <div class="card-header">
                            <h3 class="card-title">Plan features</h3>
                        </div>
                        <div class="card-body">
                            <p>
                                Manage your plan features here.
                            </p>
                            <div class="table-responsive">
                                <cfif qPlanFeatures.recordCount>
                                    <table class="table card-table table-vcenter text-nowrap">
                                        <thead>
                                            <tr>
                                                <th width="5%"></th>
                                                <th width="35%">Plan feature / Category name</th>
                                                <th width="50%">Description</th>
                                                <th width="5%"></th>
                                                <th width="5%"></th>
                                            </tr>
                                        </thead>
                                        <tbody <cfif qPlanFeatures.recordCount gt 1>id="dragndrop_body"</cfif>>
                                            <cfloop query="qPlanFeatures">
                                                <tr <cfif qPlanFeatures.recordCount gt 1>id="sort_#qPlanFeatures.intPlanFeatureID#"</cfif>>
                                                    <td class="move text-center"><cfif qPlanFeatures.recordCount gt 1><i class="fas fa-bars hand" style="cursor: grab;"></i></cfif></td>
                                                    <td><cfif qPlanFeatures.blnCategory eq 1><span class="h3">#qPlanFeatures.strFeatureName#</span><cfelse>#qPlanFeatures.strFeatureName#</cfif>  <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##featurename_#qPlanFeatures.intPlanFeatureID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate feature"></i></a></td>
                                                    <td><cfif len(qPlanFeatures.strDescription) gt 80>#left(qPlanFeatures.strDescription, 76)# ...<cfelse>#qPlanFeatures.strDescription#</cfif> <cfif len(qPlanFeatures.strDescription)><a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##featuredesc_#qPlanFeatures.intPlanFeatureID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate description"></i></a></cfif></td>
                                                    <td><a href="##" class="btn" data-bs-toggle="modal" data-bs-target="##feature_#qPlanFeatures.intPlanFeatureID#">Edit</a></td>
                                                    <td><a href="##" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/plans?delete_feature=#qPlanFeatures.intPlanFeatureID#', 'Delete feature', 'Do you really want to delete this feature irrevocably?', 'No, cancel!', 'Yes, delete!')">Delete</a></td>
                                                </tr>
                                                <div id="feature_#qPlanFeatures.intPlanFeatureID#" class='modal fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                                    <div class="modal-dialog modal-sm modal-dialog-centered" role="document">
                                                        <form action="#application.mainURL#/sysadm/plans" method="post">
                                                        <input type="hidden" name="edit_feature" value="#qPlanFeatures.intPlanFeatureID#">
                                                            <div class="modal-content">
                                                                <div class="modal-header">
                                                                    <h5 class="modal-title">Edit feature</h5>
                                                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                                </div>
                                                                <div class="modal-body">
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Feature name</label>
                                                                        <input type="text" name="feature_name" class="form-control" autocomplete="off" value="#HTMLEditFormat(qPlanFeatures.strFeatureName)#" maxlength="100" required>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Description</label>
                                                                        <textarea class="form-control" name="description" rows="3">#qPlanFeatures.strDescription#</textarea>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Category</label>
                                                                        <label class="form-check form-switch">
                                                                            <input class="form-check-input" type="checkbox" name="category" <cfif qPlanFeatures.blnCategory eq 1>checked</cfif>>
                                                                            <span class="form-check-label">It's a category</span>
                                                                        </label>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Variable
                                                                            <i class="fas fa-info-circle" data-bs-toggle="tooltip" data-bs-placement="top" title="In order to get the value of the feature via function"></i>
                                                                        </label>
                                                                        <input type="text" name="feature_variable" class="form-control" autocomplete="off" value="#HTMLEditFormat(qPlanFeatures.strVariable)#" maxlength="100">
                                                                    </div>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                                    <button type="submit" class="btn btn-primary ms-auto">Save changes</button>
                                                                </div>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                                #getModal.args('plan_features', 'strFeatureName', qPlanFeatures.intPlanFeatureID, 100).openModal('featurename', cgi.path_info, 'Translate feature')#
                                                #getModal.args('plan_features', 'strDescription', qPlanFeatures.intPlanFeatureID).openModal('featuredesc', cgi.path_info, 'Translate description')#
                                                <cfif qPlanFeatures.recordCount gt 1>
                                                    <script>
                                                        // Save new prio
                                                        function fnSaveSort(){
                                                            var jsonTmp = "[";
                                                                $('##dragndrop_body > tr').each(function (i, row) {
                                                                    var divbox = $(this).attr('id');
                                                                    var aTR = divbox.split('_');
                                                                    var newslist = 0;
                                                                    jsonTmp += "{\"prio\" :" + (i+1) + ',';
                                                                    if(newslist != 0){
                                                                        var setlist = JSON.stringify(newslist);
                                                                        jsonTmp += "\"strBoxList\" :" + setlist + ',';
                                                                    }
                                                                    jsonTmp += "\"intPlanFeatureID\" :" + aTR[1] + '},';
                                                                }
                                                            );
                                                            jsonTmp += jsonTmp.slice(0,-1);
                                                            jsonTmp += "]]";
                                                            var ajaxResponse = $.ajax({
                                                                type: "post",
                                                                url: "#application.mainURL#/backend/core/handler/ajax_sort.cfm?planfeatures",
                                                                contentType: "application/json",
                                                                data: JSON.stringify( jsonTmp )
                                                            })
                                                            // Response
                                                            ajaxResponse.then(
                                                                function( apiResponse ){
                                                                    if(apiResponse.trim() == 'ok'){
                                                                        location.href = '#application.mainURL#/sysadmin/planfeatures';
                                                                    }
                                                                }
                                                            );
                                                        }
                                                    </script>
                                                </cfif>
                                            </cfloop>
                                        </tbody>
                                    </table>
                                </cfif>

                                <!--- Modal for new group --->
                                <form action="#application.mainURL#/sysadm/plans" method="post">
                                <div id="feature_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                    <div class="modal-dialog modal-sm modal-dialog-centered" role="document">
                                        <input type="hidden" name="new_feature">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title">Add feature</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <div class="modal-body">
                                                <div class="mb-3">
                                                    <label class="form-label">Feature name</label>
                                                    <input type="text" name="feature_name" class="form-control" autocomplete="off" maxlength="100" required>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label">Description</label>
                                                    <textarea class="form-control" name="description" rows="3"></textarea>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label">Category</label>
                                                    <label class="form-check form-switch">
                                                        <input class="form-check-input" type="checkbox" name="category">
                                                        <span class="form-check-label">It's a category</span>
                                                    </label>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label">Variable
                                                        <i class="fas fa-info-circle" data-bs-toggle="tooltip" data-bs-placement="top" title="In order to get the value of the feature via function"></i>
                                                    </label>
                                                    <input type="text" name="feature_variable" class="form-control" autocomplete="off" maxlength="100">
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                <button type="submit" class="btn btn-primary ms-auto">
                                                    Save feature
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                </form>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    

</div>