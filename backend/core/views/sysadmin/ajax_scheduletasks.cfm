<cfscript>
    setting showdebugoutput = false;
    param name="url.taskID" default=0 type="numeric";
    param name="url.moduleID" default=0 type="numeric";
    if(not isNumeric(url.taskID) or not isNumeric(url.moduleID)){
        abort;
    }
    qSchdule = application.objSysadmin.getScheduleTask(url.taskID);
    startDateTime = new backend.core.com.time(session.customer_id);
</cfscript>

<cfif qSchdule.recordCount>

    <cfoutput>
    <form action="#application.mainURL#/sysadm/modules?moduleID=#url.moduleID#" method="post">
    <input type="hidden" name="edit_scheduletask" value="#url.taskID#">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Edit scheduletask</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label">Name</label>
                    <input type="text" name="schedule_name" class="form-control" autocomplete="off" maxlength="250" value="#qSchdule.strName#" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Path</label>
                    <input type="text" name="path" class="form-control" autocomplete="off" maxlength="250" value="#qSchdule.strPath#" required>
                </div>
                <div class="row">
                    <div class="col-lg-4">
                        <div class="mb-2">
                            <label class="form-label">Start date</label>
                            <input type="date" name="start_date" class="form-control" value="#dateFormat(startDateTime.utc2local(utcDate=qSchdule.dtmStartTime), 'yyyy-mm-dd')#" required>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="mb-2">
                            <label class="form-label">Time</label>
                            <input type="time" name="start_time" class="form-control" value="#timeFormat(startDateTime.utc2local(utcDate=qSchdule.dtmStartTime), 'HH:MM')#" required>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="mb-2">
                            <label class="form-label">Iteration in minutes</label>
                            <input type="text" name="iteration" class="form-control" pattern="([2-9]|[1-9][0-9]+)" value="#qSchdule.intIterationMinutes#" title="Iteration must be at minimum 2 minutes!" required>
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
    </cfoutput>

<cfelse>

    No Scheduletask found!

</cfif>