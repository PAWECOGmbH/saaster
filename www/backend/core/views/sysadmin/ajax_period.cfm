<cfsetting showdebugoutput="no">

<cfscript>
    param name="url.c" default="0";
    param name="url.m" default="0";
    param name="url.p" default="0";
    param name="url.b" default="0";
    if (url.m gt 0) {
        status = new backend.core.com.modules().getModuleStatus(url.c, url.m);
        type = "modules";
    } else if (url.p gt 0) {
        status = new backend.core.com.plans().getCurrentPlan(url.c);
        type = "plans";
    }
</cfscript>

<cfoutput>
<form action="#application.mainURL#/sysadm/#type#?booking&b=#url.b#&c=#url.c#&m=#url.m#&p=#url.p#&period" method="post">
    <div class="modal-header">
        <h5 class="modal-title">Module edit</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
    </div>
    <div class="modal-body">
        <div class="row mb-3">
            <div class="col-lg-6">
                <label class="form-label">Start date *</label>
                <div class="input-icon">
                    <span class="input-icon-addon"><i class="far fa-calendar-alt"></i></span>
                    <input class="form-control" placeholder="Select a date" name="start_date" id="date1" value="#dateFormat(status.startDate, 'yyyy-mm-dd')#" required>
                </div>
            </div>
            <div class="col-lg-6">
                <label class="form-label">End date *</label>
                <div class="input-icon">
                    <span class="input-icon-addon"><i class="far fa-calendar-alt"></i></span>
                    <input class="form-control" placeholder="Select a date" name="end_date" id="date2" value="#dateFormat(status.endDate, 'yyyy-mm-dd')#" required>
                </div>
            </div>
        </div>
    </div>
    <div class="modal-footer">
        <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
        <button type="submit" class="btn btn-primary ms-auto">
            Save settings
        </button>
    </div>
</form>
</cfoutput>