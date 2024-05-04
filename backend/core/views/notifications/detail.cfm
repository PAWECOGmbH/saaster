<cfsetting showdebugoutput="no">
<cfscript>
    param name="url.nID" default="0" type="numeric";
    objNoti = new backend.core.com.notifications();
    notiStruct = objNoti.getNotificationDetail(url.nID, session.customer_id);
    if (structIsEmpty(notiStruct)) {
        location url="dashboard" addtoken="false";
    }
    // Set notification as read
    objNoti.setRead(url.nID, session.customer_id);
</cfscript>

<cfoutput>
<div class="modal-header">
    <h5 class="modal-title">#getTrans(notiStruct.title_var)#</h5>
</div>
<div class="modal-body">
    #replace(getTrans(notiStruct.desc_var), chr(13), '<br />', 'all')#
</div>
<div class="modal-footer">
    <button type="button" class="btn me-auto" data-bs-dismiss="modal" onclick="javascript:window.location.reload()">Close</button>
    <a href="#notiStruct.link#" class="btn btn-primary">#getTrans(notiStruct.link_text_var)#</a>
</div>
</cfoutput>