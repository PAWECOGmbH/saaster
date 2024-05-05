<cfscript>

    objSysadmin = new backend.core.com.sysadmin();
    qWidgets = objSysadmin.getWidgets();
    qWidgetRatio = objSysadmin.getWidgetRatio();
    qPlans = objSysadmin.getPlans();
    qModules = objSysadmin.getModulesWidget();

</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Widgets</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Widgets</li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="##" data-bs-toggle="modal" data-bs-target="##widget_new" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> Add widget
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
                            <h3 class="card-title">Widgets</h3>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table card-table table-vcenter text-nowrap">
                                    <thead >
                                        <tr>
                                            <th width="20%">Widget name</th>
                                            <th width="40%">Filepath</th>
                                            <th width="20%" class="text-center">Size ratio</th>
                                            <th width="10%" class="text-center">Active</th>
                                            <th width="5%"></th>
                                            <th width="5%"></th>
                                        </tr>
                                    </thead>
                                    <cfif qWidgets.recordCount>
                                        <tbody id="dragndrop_body">
                                            <cfloop query="qWidgets">
                                                <tr>
                                                    <td>#qWidgets.strWidgetName#</td>
                                                    <td>#qWidgets.strFilePath#</td>
                                                    <td class="text-center">#qWidgets.strDescription#</td>
                                                    <td class="text-center">#yesNoFormat(qWidgets.blnActive)#</td>
                                                    <td><a href="##" class="btn" data-bs-toggle="modal" data-bs-target="##widget_#qWidgets.intWidgetID#">Edit</a></td>
                                                    <td><a href="##?" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/widgets?delete_widget=#qWidgets.intWidgetID#', 'Delete widget', 'If you delete a widget, the widgets activated by clients on their dashboards will also be removed. Do you really want to delete?', 'No, cancel!', 'Yes, delete!')">Delete</a></td>
                                                </tr>
                                                <div id="widget_#qWidgets.intWidgetID#" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                                    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                                        <form action="#application.mainURL#/sysadm/widgets" method="post">
                                                        <input type="hidden" name="edit_widget" value="#qWidgets.intWidgetID#">
                                                            <div class="modal-content">
                                                                <div class="modal-header">
                                                                    <h5 class="modal-title">Edit widget</h5>
                                                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                                </div>
                                                                <div class="modal-body">
                                                                    <div class="row">
                                                                        <div class="col-lg-12 mb-3">
                                                                            <label class="form-check form-switch">
                                                                                <input class="form-check-input" type="checkbox" name="active" <cfif qWidgets.blnActive>checked</cfif>>
                                                                                <span class="form-check-label">Active</span>
                                                                            </label>
                                                                        </div>
                                                                    </div>
                                                                    <div class="row">
                                                                        <div class="col-lg-6 mb-3">
                                                                            <label class="form-label">Widget name</label>
                                                                            <input type="text" name="name" class="form-control" autocomplete="off" value="#HTMLEditFormat(qWidgets.strWidgetName)#" maxlength="100" required>
                                                                        </div>
                                                                        <div class="col-lg-6 mb-3">
                                                                            <label class="form-label">Widget ratio</label>
                                                                            <select name="ratioID" class="form-select">
                                                                                <cfloop query="qWidgetRatio">
                                                                                    <option value="#qWidgetRatio.intRatioID#" <cfif qWidgetRatio.intRatioID eq qWidgets.intRatioID>selected</cfif>>#qWidgetRatio.strDescription#</option>
                                                                                </cfloop>
                                                                            </select>
                                                                        </div>
                                                                    </div>
                                                                    <div class="row mb-3">
                                                                        <label class="form-label">Path to the widget file</label>
                                                                        <div class="input-group">
                                                                            <span class="input-group-text">root/</span>
                                                                            <input type="text" name="path" class="form-control" autocomplete="off" value="#HTMLEditFormat(qWidgets.strFilePath)#" maxlength="255" required>
                                                                        </div>
                                                                    </div>
                                                                    <div class="row">
                                                                        <div class="col-lg-12 mb-3">
                                                                            <label class="form-check form-switch">
                                                                                <input class="form-check-input" type="checkbox" name="perm" <cfif qWidgets.blnPermDisplay>checked</cfif>>
                                                                                <span class="form-check-label">Display widget permanently or...</span>
                                                                            </label>
                                                                        </div>
                                                                    </div>
                                                                    <div class="row">
                                                                        <div class="col-lg-6 mb-3">
                                                                            <label class="form-check-label mb-2">... display only with these <b>plans</b>:</label>
                                                                            <select name="planList" class="form-select" multiple>
                                                                                <cfloop query="qPlans">
                                                                                    <option value="#qPlans.intPlanID#" <cfif listFind(qWidgets.planList, qPlans.intPlanID)>selected</cfif>>#qPlans.strPlanName#</option>
                                                                                </cfloop>
                                                                            </select>
                                                                        </div>
                                                                        <div class="col-lg-6 mb-3">
                                                                            <label class="form-check-label mb-2">... display only with these <b>modules</b>:</label>
                                                                            <select name="moduleList" class="form-select" multiple>
                                                                                <cfloop query="qModules">
                                                                                    <option value="#qModules.intModuleID#" <cfif listFind(qWidgets.moduleList, qModules.intModuleID)>selected</cfif>>#qModules.strModuleName#</option>
                                                                                </cfloop>
                                                                            </select>
                                                                        </div>
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

                                            </cfloop>
                                        </tbody>
                                    <cfelse>
                                        <tbody>
                                            <tr><td colspan="100%" class="text-center text-red">You have not added any widgets yet</td></tr>
                                        </tbody>
                                    </cfif>
                                    <div id="widget_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                        <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                            <form action="#application.mainURL#/sysadm/widgets" method="post">
                                            <input type="hidden" name="new_widget">
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">New widget</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="row">
                                                            <div class="col-lg-2 mb-3">
                                                                <label class="form-check form-switch">
                                                                    <input class="form-check-input" type="checkbox" name="active">
                                                                    <span class="form-check-label">Active</span>
                                                                </label>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col-lg-6 mb-3">
                                                                <label class="form-label">Widget name</label>
                                                                <input type="text" name="name" class="form-control" autocomplete="off" maxlength="100" required>
                                                            </div>
                                                            <div class="col-lg-6 mb-3">
                                                                <label class="form-label">Widget ratio</label>
                                                                <select name="ratioID" class="form-select">
                                                                    <cfloop query="qWidgetRatio">
                                                                        <option value="#qWidgetRatio.intRatioID#">#qWidgetRatio.strDescription#</option>
                                                                    </cfloop>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="mb-4">
                                                            <label class="form-label">Path to the widget file</label>
                                                            <div class="input-group">
                                                                <span class="input-group-text">root/</span>
                                                                <input type="text" name="path" class="form-control" autocomplete="off" maxlength="255" required>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col-lg-12 mb-3">
                                                                <label class="form-check form-switch">
                                                                    <input class="form-check-input" type="checkbox" name="perm" checked>
                                                                    <span class="form-check-label">Display widget permanently or...</span>
                                                                </label>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col-lg-6 mb-3">
                                                                <label class="form-check-label mb-2">... display only with these <b>plans</b>:</label>
                                                                <select name="planList" class="form-select" multiple>
                                                                    <cfloop query="qPlans">
                                                                        <option value="#qPlans.intPlanID#">#qPlans.strPlanName#</option>
                                                                    </cfloop>
                                                                </select>
                                                            </div>
                                                            <div class="col-lg-6 mb-3">
                                                                <label class="form-check-label mb-2">... display only with these <b>modules</b>:</label>
                                                                <select name="moduleList" class="form-select" multiple>
                                                                    <cfloop query="qModules">
                                                                        <option value="#qModules.intModuleID#">#qModules.strModuleName#</option>
                                                                    </cfloop>
                                                                </select>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                        <button type="submit" class="btn btn-primary ms-auto">
                                                            Save widget
                                                        </button>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    

</div>