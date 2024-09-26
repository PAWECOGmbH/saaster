
<cfscript>
    
    objSysadmin = new backend.core.com.sysadmin();
    qPlanGroups = objSysadmin.getPlanGroupsCountry();
    qCountries = objSysadmin.getPlanGroupsCountries();

    getModal = new backend.core.com.translate();

</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">
            <div class="row">
                <div class="col-lg-6 mb-3">
                    <div class="#getLayout.layoutPageHeader#">
                        <h4 class="page-title">Plan groups</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/sysadmin/plans">Plans</a></li>
                            <li class="breadcrumb-item active">Plan groups</li>
                        </ol>
                    </div>
                </div>
                <div class="#getLayout.layoutPageHeader# col-lg-6 mb-3 text-end">
                    <div class="button-group">
                        <a href="#application.mainURL#/sysadmin/plans" class="btn btn-primary">
                            <i class="fas fa-angle-double-left pe-3"></i> Back to plans
                        </a>
                        <a href="##" data-bs-toggle="modal" data-bs-target="##plangroup_new" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> Add plan group
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
                            <h3 class="card-title">Plan groups</h3>
                        </div>
                        <div class="card-body">
                            <p>
                                With a plan group you can combine plans.
                                Example: You want to create different plans for America and Germany. Then make a plan group for America and another for Germany.
                            </p>
                            <div class="table-responsive">
                                <cfif qPlanGroups.recordCount>
                                    <table class="table card-table table-vcenter text-nowrap">
                                        <thead>
                                            <tr>
                                                <th width="5%"></th>
                                                <th width="5%" class="text-center">Prio</th>
                                                <th width="35%">Plan group</th>
                                                <th width="35%">Country</th>
                                                <th width="5%"></th>
                                                <th width="5%"></th>
                                            </tr>
                                        </thead>
                                        <tbody <cfif qPlanGroups.recordCount gt 1>id="dragndrop_body"</cfif>>
                                            <cfloop query="qPlanGroups">
                                                <tr <cfif qPlanGroups.recordCount gt 1>id="sort_#qPlanGroups.intPlanGroupID#"</cfif>>
                                                    <td class="move text-center"><cfif qPlanGroups.recordCount gt 1><i class="fas fa-bars hand" style="cursor: grab;"></i></cfif></td>
                                                    <td class="text-center">#qPlanGroups.intPrio#</td>
                                                    <td>#qPlanGroups.strGroupName# <a href="##?" data-bs-toggle="modal" data-bs-target="##trans_plangroup_#qPlanGroups.intPlanGroupID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate plan group"></i></a></td>
                                                    <td>#qPlanGroups.strCountryName#</td>
                                                    <td><a href="##" class="btn" data-bs-toggle="modal" data-bs-target="##plangroup_#qPlanGroups.intPlanGroupID#">Edit</a></td>
                                                    <td><a href="##" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/plans?delete_group=#qPlanGroups.intPlanGroupID#', 'Delete plan group', 'Caution: If you delete a plan group, all the associated plans will also be deleted. Do you really want to delete this group irrevocably?', 'No, cancel!', 'Yes, delete!')">Delete</a></td>
                                                </tr>
                                                <div id="plangroup_#qPlanGroups.intPlanGroupID#" class='modal fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                                    <div class="modal-dialog modal-sm modal-dialog-centered" role="document">
                                                        <form action="#application.mainURL#/sysadm/plans" method="post">
                                                        <input type="hidden" name="edit_plangroup" value="#qPlanGroups.intPlanGroupID#">
                                                            <div class="modal-content">
                                                                <div class="modal-header">
                                                                    <h5 class="modal-title">Edit plan group</h5>
                                                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                                </div>
                                                                <div class="modal-body">
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Group name</label>
                                                                        <input type="text" name="group_name" class="form-control" autocomplete="off" value="#HTMLEditFormat(qPlanGroups.strGroupName)#" maxlength="100" required>
                                                                    </div>
                                                                    <cfif qCountries.recordCount>
                                                                        <div class="mb-3">
                                                                            <label class="form-label">Country</label>
                                                                            <select name="countryID" class="form-select">
                                                                                <option value=""></option>
                                                                                <cfloop query="qCountries">
                                                                                    <option value="#qCountries.intCountryID#" <cfif qCountries.intCountryID eq qPlanGroups.intCountryID>selected</cfif>>#qCountries.strCountryName#</option>
                                                                                </cfloop>
                                                                            </select>
                                                                        </div>
                                                                    </cfif>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                                    <button type="submit" class="btn btn-primary ms-auto">Save changes</button>
                                                                </div>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                                #getModal.args('plan_groups', 'strGroupName', qPlanGroups.intPlanGroupID, 100).openModal('trans_plangroup', cgi.path_info, 'Translate plan group')#
                                                <cfif qPlanGroups.recordCount gt 1>
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
                                                                    jsonTmp += "\"intPlanGroupID\" :" + aTR[1] + '},';
                                                                }
                                                            );
                                                            jsonTmp += jsonTmp.slice(0,-1);
                                                            jsonTmp += "]]";
                                                            var ajaxResponse = $.ajax({
                                                                type: "post",
                                                                url: "#application.mainURL#/backend/core/handler/ajax_sort.cfm?plangroups",
                                                                contentType: "application/json",
                                                                data: JSON.stringify( jsonTmp )
                                                            })
                                                            // Response
                                                            ajaxResponse.then(
                                                                function( apiResponse ){
                                                                    if(apiResponse.trim() == 'ok'){
                                                                        location.href = '#application.mainURL#/sysadmin/plangroups';
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
                                <div id="plangroup_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                    <div class="modal-dialog modal-sm modal-dialog-centered" role="document">
                                        <input type="hidden" name="new_group">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title">Add plan group</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <div class="modal-body">
                                                <div class="mb-3">
                                                    <label class="form-label">Group name</label>
                                                    <input type="text" name="group_name" class="form-control" autocomplete="off" maxlength="100" required>
                                                </div>
                                                <cfif qCountries.recordCount>
                                                    <div class="mb-3">
                                                        <label class="form-label">Country</label>
                                                        <select name="countryID" class="form-select">
                                                            <option value=""></option>
                                                            <cfloop query="qCountries">
                                                                <option value="#qCountries.intCountryID#">#qCountries.strCountryName#</option>
                                                            </cfloop>
                                                        </select>
                                                    </div>
                                                </cfif>
                                            </div>
                                            <div class="modal-footer">
                                                <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                <button type="submit" class="btn btn-primary ms-auto">
                                                    Save group
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