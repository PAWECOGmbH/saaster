
<cfscript>

    objLogs = application.objLog;

    param name="session.log_type" default="";
    param name="session.log_date" default=dateFormat(now(), "yyyy-mm-dd");
    param name="session.log_level" default="";

    if (structKeyExists(form, "log_type")) {
        session.log_type = form.log_type;
    }
    if (structKeyExists(form, "log_date")) {
        session.log_date = dateFormat(form.log_date, "yyyy-mm-dd");
    }
    if (structKeyExists(form, "log_level")) {
        session.log_level = form.log_level;
    }

    qLogfiles = objLogs.getLogs(type=session.log_type, date=session.log_date, level=session.log_level);
    logTypes = objLogs.getLogTypes();

</cfscript>

<style type="text/css">
.openPopup_big:hover {
    font-weight: bold;
}
</style>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Logfiles</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Logfiles</li>
                        </ol>
                    </div>

                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="#getLayout.layoutPage#">
            <div class="row">
                <div class="col-lg-12 mb-3">
                    <div class="card">
                        <form action="#application.mainURL#/sysadmin/logs" method="post">
                            <div class="col-lg-12 p-3">
                                <p class="text-info">Note: The log files will be deleted automatically after 30 days!</p>
                                <div class="row">
                                    <div class="col-lg-2 mb-3">
                                        <div class="form-label">Filter by type:</div>
                                        <select name="log_type" class="form-select">
                                            <option value="" <cfif session.log_type eq "">selected</cfif>>All</option>
                                            <cfloop array="#logTypes#" item="type">
                                                <option value="#type#" <cfif session.log_type eq type>selected</cfif>>#type#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                    <div class="col-lg-2 mb-3">
                                        <div class="form-label">Filter by level:</div>
                                        <select name="log_level" class="form-select">
                                            <option value="" <cfif session.log_level eq "">selected</cfif>>All</option>
                                            <option value="info" <cfif session.log_level eq "info">selected</cfif>>info</option>
                                            <option value="warning" <cfif session.log_level eq "warning">selected</cfif>>warning</option>
                                            <option value="error" <cfif session.log_level eq "error">selected</cfif>>error</option>
                                        </select>
                                    </div>
                                    <div class="col-lg-2 mb-3">
                                        <div class="form-label">Filter by date:</div>
                                        <input type="date" class="form-control" name="log_date" value="#session.log_date#">
                                    </div>
                                    <div class="col-lg-1 mb-3">
                                        <div class="form-label">&nbsp;</div>
                                        <input type="submit" class="btn btn-primary" value="Filter">
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
                <div class="col-lg-12">
                    <cfif qLogfiles.recordCount>
                        <div class="card">
                            <div class="table-responsive">
                                <table class="table table-vcenter table-mobile-md card-table">
                                    <thead>
                                        <tr>
                                            <th width="5%"><input type="checkbox" id="checkAll"></th>
                                            <th width="45%">File name</th>
                                            <th width="20%">Log level</th>
                                            <th width="15%">Last modified</th>
                                            <th width="10%" class="text-center">Size</th>
                                            <th width="5%"></th>
                                        </tr>
                                    </thead>
                                    <form action="#application.mainURL#/sysadm/logs" method="post">
                                        <input type="hidden" name="del_logs">
                                        <tbody>
                                            <cfloop query="qLogfiles">
                                                <cfset replacedPath = replace(replace(qLogfiles.directory, "\", "/", "all"), "logs/", "~", "one")>
                                                <cfset dirPath = listLast(replacedPath, "~")>
                                                <tr id="checkAll">
                                                    <td><input type="checkbox" name="logfile" value="#qLogfiles.directory#/#qLogfiles.name#"></td>
                                                    <td style="cursor: pointer;" class="openPopup_big" data-bs-toggle="modal" data-href="#application.mainURL#/backend/core/views/sysadmin/ajax_logfile.cfm?logfile=#qLogfiles.directory#/#qLogfiles.name#">#dirPath#/#qLogfiles.name#</td>
                                                    <td>#ucase(replace(qLogfiles.name, ".log", ""))#</td>
                                                    <td>#lsDateFormat(getTime.utc2local(utcDate=qLogfiles.dateLastModified))# #lsTimeFormat(getTime.utc2local(utcDate=qLogfiles.dateLastModified))#</td>
                                                    <td class="text-center">#round(qLogfiles.size/1000)# kb</td>
                                                    <td><a href="##?" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/logs?logfile=#urlEncodedFormat(qLogfiles.directory)#/#qLogfiles.name#', 'Delete logfile', 'Do you really want to delete this log file?', 'No', 'Yes')">Delete</a></td>
                                                </tr>
                                            </cfloop>
                                        </tbody>
                                        <tr>
                                            <td colspan="3">
                                                <div class="input-group" style="max-width: 300px;">
                                                    <select name="log_action" class="form-select">
                                                        <option value="">---</option>
                                                        <option value="delete">#getTrans('btnDelete')#</option>
                                                    </select>
                                                    <input type="submit" class="btn" value="OK!">
                                                </div>
                                            </td>
                                        </tr>
                                    </form>
                                </table>
                            </div>
                        </div>
                    <cfelse>
                        <div class="alert alert-primary" role="alert">
                            No logs found on this day.
                        </div>
                    </cfif>
                </div>
            </div>
        </div>
    </cfoutput>
    

</div>

<div id="dynModal_big" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
    <div class="modal-dialog modal-full-width modal-dialog-centered modal-dialog-scrollable" role="document">
        <div class="modal-content" id="dyn_modal-content">

        </div>
    </div>
</div>