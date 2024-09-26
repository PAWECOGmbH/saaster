<cfscript>
    qSchduleTasks = application.objSysadmin.getScheduleTasksOfModule(qModule.intModuleID);
    startDateTime = new backend.core.com.time(session.customer_id);
</cfscript>

<cfoutput>

<div class="col-md-12 col-lg-12 text-end">
    <div class="row mb-3 me-3">
        <div class="align-items-end">
            <a href="##" data-bs-toggle="modal" data-bs-target="##schedule_new" class="btn btn-primary">
                <i class="fas fa-plus pe-3"></i> Add scheduletask
            </a>
        </div>
    </div>
</div>
<div class="card-body">
    <div class="row">
        <div class="table-responsive">
            <p>Note: Scheduletasks entered here are not created as a direct scheduletask in Lucee. Tasks entered here are processed every 2 minutes by the main scheduletask in Lucee.</p>
            <table class="table table-vcenter card-table">
                <thead>
                    <tr>
                        <th width="20%">Name</th>
                        <th width="25%">Path</th>
                        <th width="10%">Start date</th>
                        <th width="10%">Time</th>
                        <th width="10%">Iteration</th>
                        <th width="10%">Active</th>
                        <th width="5%">&nbsp;</th>
                        <th width="5%">&nbsp;</th>
                        <th width="5%">&nbsp;</th>
                    </tr>
                </thead>
                <tbody>
                    <cfloop query="qSchduleTasks">
                        <form action="#application.mainURL#/sysadm/modules?moduleID=#qModule.intModuleID#&overview" method="post">
                            <input type="hidden" name="edit_scheduletask" value="#qSchduleTasks.intScheduletaskID#">
                            <tr>
                                <td>#qSchduleTasks.strName#</td>
                                <td>#qSchduleTasks.strPath#</td>
                                <td>#lsDateFormat(startDateTime.utc2local(utcDate=qSchduleTasks.dtmStartTime))#</td>
                                <td>#lsTimeFormat(startDateTime.utc2local(utcDate=qSchduleTasks.dtmStartTime))#</td>
                                <td>#qSchduleTasks.intIterationMinutes#</td>
                                <td>
                                    <label class="form-check form-switch">
                                        <input onclick="this.form.submit()" class="form-check-input" type="checkbox" name="active" <cfif qSchduleTasks.blnActive eq 1>checked</cfif>>
                                    </label>
                                </td>
                                <td><a href="#application.mainURL#/#qSchduleTasks.strPath#?pass=#variables.schedulePassword#" class="btn" target="_blank">Run</a></td>
                                <td><a href="##" class="btn openPopup" data-bs-toggle="modal" data-href="#application.mainURL#/backend/core/views/sysadmin/ajax_scheduletasks.cfm?taskID=#qSchduleTasks.intScheduletaskID#&moduleID=#qModule.intModuleID#">Edit</a></td>
                                <td><a href="##?" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/modules?delete_scheduletask=#qSchduleTasks.intScheduletaskID#&moduleID=#qModule.intModuleID#', 'Delete scheduletask', 'Are you sure you want to delete this scheduletask?', 'No, cancel!', 'Yes, delete!')">Delete</a></td>
                            </tr>
                        </form>
                    </cfloop>
                </tbody>
                <div id="schedule_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                    <div class="modal-dialog modal-dialog-centered" role="document">
                        <form action="#application.mainURL#/sysadm/modules" method="post">
                        <input type="hidden" name="new_scheduletask" value="#qModule.intModuleID#">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">New scheduletask</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="mb-3">
                                        <label class="form-label">Name</label>
                                        <input type="text" name="schedule_name" class="form-control" autocomplete="off" maxlength="250" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Path</label>
                                        <input type="text" name="path" class="form-control" autocomplete="off" maxlength="250" required>
                                    </div>
                                    <div class="row">
                                        <div class="col-lg-4">
                                            <div class="mb-2">
                                                <label class="form-label">Start date</label>
                                                <input type="date" name="start_date" class="form-control" required>
                                            </div>
                                        </div>
                                        <div class="col-lg-4">
                                            <div class="mb-2">
                                                <label class="form-label">Time</label>
                                                <input type="time" name="start_time" class="form-control" required>
                                            </div>
                                        </div>
                                        <div class="col-lg-4">
                                            <div class="mb-2">
                                                <label class="form-label">Iteration in minutes</label>
                                                <input type="text" name="iteration" class="form-control" pattern="([2-9]|[1-9][0-9]+)" title="Iteration must be at minimum 2 minutes!" required>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-lg-4"></div>
                                        <div class="col-lg-4 small">
                                            Use your own timezone, but make sure you filled in the correct timezone in the account settings.
                                        </div>
                                        <div class="col-lg-4 small">
                                            1 hour = 60<br />
                                            2 hours = 120<br />
                                            1 day = 1440<br />
                                            1 week = 10080
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                    <button type="submit" class="btn btn-primary ms-auto">
                                        Save scheduletask
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

</cfoutput>