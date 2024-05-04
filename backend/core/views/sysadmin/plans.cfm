
<cfscript>

    objSysadmin = new backend.core.com.sysadmin();
    qPlanGroups = objSysadmin.getAllPlanGroups();
    qPlans = objSysadmin.getAllPlans();
    qCountries = objSysadmin.getAllCountries();

</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">
            <div class="row">
                <div class="col-lg-6 mb-3">
                    <div class="#getLayout.layoutPageHeader#">
                        <h4 class="page-title">Plans</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Plans</li>
                        </ol>
                    </div>
                </div>
                <div class="#getLayout.layoutPageHeader# col-lg-6 mb-3 text-end align-text-top">
                    <div class="button-group">
                        <cfif qPlanGroups.recordCount>
                            <button href="##" data-bs-toggle="modal" data-bs-target="##plan_new" class="btn btn-primary">
                                <i class="fas fa-plus pe-3"></i> Add plan
                            </button>
                        </cfif>
                        <button class="btn dropdown-toggle btn-primary" data-bs-toggle="dropdown">
                            Settings
                        </button>
                        <div class="dropdown-menu dropdown-menu-end">
                            <a class="dropdown-item" href="#application.mainURL#/sysadmin/plangroups">Plan groups</a>
                            <a class="dropdown-item" href="#application.mainURL#/sysadmin/planfeatures">Plan features</a>
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
                                    <h3>Plans</h3>
                                </div>
                                <cfif qPlanGroups.recordCount>
                                    <div class="col-lg-6 text-end pe-3">
                                        <a href="#application.mainURL#/plans" target="_blank"><i class="fas fa-search h2" data-bs-toggle="tooltip" data-bs-placement="top" title="Preview plans"></i></a>
                                    </div>
                                </cfif>
                            </div>
                        </div>
                        <div class="card-body">
                            <p>
                                <cfif qPlanGroups.recordCount>
                                    Here you can configure your plans and prices. The <b>default plan</b> indicates that it will be activated immediately when a new registration is made.
                                <cfelse>
                                    <span class="text-red">You need at least one plan group before you can create plans. <a href="#application.mainURL#/sysadmin/plangroups"><i class="fas fa-long-arrow-alt-right"></i> Manage plan groups</a></span>
                                </cfif>
                            </p>
                            <div class="table-responsive">
                                <cfif qPlanGroups.recordCount and qPlans.recordCount>
                                    <table class="table card-table table-vcenter text-nowrap">
                                        <thead>
                                            <tr>
                                                <th width="5%"></th>
                                                <th width="5%" class="text-center">Prio</th>
                                                <th width="30%">Plan name</th>
                                                <th width="30%">Group name</th>
                                                <th width="10%" class="text-center">Recommended</th>
                                                <th width="10%">Default plan</th>
                                                <th width="5%"></th>
                                                <th width="5%"></th>
                                            </tr>
                                        </thead>
                                        <tbody <cfif qPlans.recordCount gt 1>id="dragndrop_body"</cfif>>
                                            <cfloop query="qPlans">
                                                <form action="#application.mainURL#/sysadm/plans?default" method="post">
                                                    <input type="hidden" name="planID" value="#qPlans.intPlanID#">
                                                    <input type="hidden" name="groupID" value="#qPlans.intPlanGroupID#">
                                                    <tr <cfif qPlans.recordCount gt 1>id="sort_#qPlans.intPlanID#" data-id="#qPlans.intPlanID#" data-group="#qPlans.intPlanGroupID#" data-extend="#urlencodedformat('AND intPlanGroupID=' & qPlans.intPlanGroupID)#"</cfif>>
                                                        <td class="move text-center"><cfif qPlans.recordCount gt 1><i class="fas fa-bars hand" style="cursor: grab;"></i></cfif></td>
                                                        <td class="text-center">#qPlans.intPrio#</td>
                                                        <td>#qPlans.strPlanName#</td>
                                                        <td>#qPlans.strGroupName#</td>
                                                        <td class="text-center">#yesNoFormat(qPlans.blnRecommended)#</td>
                                                        <td class="text-center">
                                                            <cfif qPlans.blnFree eq 1 or qPlans.intNumTestDays gt 0>
                                                                <label class="form-check form-switch">
                                                                    <input onclick="this.form.submit()" class="form-check-input" type="checkbox" name="default" <cfif qPlans.blnDefaultPlan eq 1>checked</cfif>>
                                                                </label>
                                                            </cfif>
                                                        </td>
                                                        <td><a href="#application.mainURL#/sysadmin/plan/edit/#qPlans.intPlanID#" class="btn">Edit</a></td>
                                                        <td><a href="##" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/plans?delete_plan=#qPlans.intPlanID#', 'Delete plan', 'Do you really want to delete this plan irrevocably?', 'No, cancel!', 'Yes, delete!')">Delete</a></td>
                                                    </tr>
                                                </form>
                                            </cfloop>
                                        </tbody>
                                    </table>
                                </cfif>

                                <!--- Modal for new plan --->
                                <form action="#application.mainURL#/sysadm/plans" method="post">
                                <div id="plan_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                    <div class="modal-dialog modal-sm modal-dialog-centered" role="document">
                                        <input type="hidden" name="new_plan">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title">Add plan</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <div class="modal-body">
                                                <div class="mb-3">
                                                    <label class="form-label">Plan group</label>
                                                    <select name="groupID" class="form-select">
                                                        <cfloop query="qPlanGroups">
                                                            <option value="#qPlanGroups.intPlanGroupID#">#qPlanGroups.strGroupName#</option>
                                                        </cfloop>
                                                    </select>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label">Plan name</label>
                                                    <input type="text" name="plan_name" class="form-control" autocomplete="off" maxlength="100" required>
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                <button type="submit" class="btn btn-primary ms-auto">
                                                    Save plan
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



<cfif qPlans.recordCount gt 1>
    <cfoutput>
    <script>
        // Save new prio
        function fnSaveSort(){

            var jsonTmp = "[";
                $('##dragndrop_body > tr').each(function (i, row) {
                    var divbox = $(this).attr('id');
                    var aTR = divbox.split('_');
                    var newslist = 0;
                    jsonTmp += "{\"prio\" :" + (i+1) + ',';
                    jsonTmp += "\"group\" :" + $(this).data('group') + ',';
                    if(newslist != 0){
                        var setlist = JSON.stringify(newslist);
                        jsonTmp += "\"strBoxList\" :" + setlist + ',';
                    }
                    jsonTmp += "\"intPlanID\" :" + aTR[1] + '},';
                }
            );
            jsonTmp += jsonTmp.slice(0,-1);
            jsonTmp += "]]";

            var ajaxResponse = $.ajax({
                type: "post",
                url: "#application.mainURL#/backend/core/handler/ajax_sort.cfm?plans",
                contentType: "application/json",
                data: JSON.stringify( jsonTmp )
            })

            // Response
            ajaxResponse.then(
                function( apiResponse ){
                    if(apiResponse.trim() == 'ok'){
                        location.href = '#application.mainURL#/sysadmin/plans';
                    }
                }
            );
        }
    </script>
    </cfoutput>
</cfif>