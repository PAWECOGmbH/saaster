<cfsetting showdebugoutput="no">
<cfscript>
    param name="url.logfile" default="" type="string";
    logFileDetails = application.objLog.getLogDetail(url.logfile);
</cfscript>
<cfoutput>
<div class="modal-header">
    <h5 class="modal-title">Logfile details: #url.logfile#</h5>
</div>
<div class="modal-body">
    <pre style="white-space: pre-wrap; word-wrap: break-word;">#encodeForHTML(arrayToList(logFileDetails, chr(10)))#</pre>
</div>
<div class="modal-footer">
    <button type="button" class="btn me-auto" data-bs-dismiss="modal">Close</button>
</div>
</cfoutput>