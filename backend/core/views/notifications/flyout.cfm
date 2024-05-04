<cfscript>

    // How many notifications do we have? (used for the notifications overview too)
    qTotalNoties = application.objNotifications.getNotifications(session.customer_id).totalCount;

    // Get the last 5 unread notifications
    qNotiesUnread = application.objNotifications.getNotifications(customerID=session.customer_id, count=5, read=false);

</cfscript>

<cfoutput>
<div class="nav-item dropdown d-none d-md-flex me-3">
    <a href="##" class="nav-link px-0" data-bs-toggle="dropdown" tabindex="-1" aria-label="Show notifications" aria-expanded="false">
        <i class="far fa-bell" style="font-size: 20px;"></i>
        <cfif !arrayIsEmpty(qNotiesUnread.arrayNoti)>
            <span class="badge bg-red"></span>
        </cfif>
    </a>
    <div class="dropdown-menu dropdown-menu-arrow dropdown-menu-end dropdown-menu-card">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">#getTrans('titNotifications')#</h3>
            </div>
            <div class="list-group list-group-flush list-group-hoverable">
                <cfif arrayIsEmpty(qNotiesUnread.arrayNoti)>
                    <div class="list-group-item">
                        <div class="row align-items-center">
                            <div class="col">
                                <div class="d-block text-muted mt-n1">
                                    #getTrans('msgNoNotifications')#
                                </div>
                            </div>
                        </div>
                    </div>
                <cfelse>
                    <cfloop array="#qNotiesUnread.arrayNoti#" index="i">
                        <div class="list-group-item">
                            <div class="row align-items-center">
                                <div class="col-auto"><span class="status-dot d-block bg-red"></span></div>
                                <div class="col text-truncate">
                                    <div class="d-block text-muted mt-n1 small">
                                        #lsDateFormat(getTime.utc2local(utcDate=i.created))# #lsTimeFormat(getTime.utc2local(utcDate=i.created))#
                                    </div>
                                    <a style="cursor: pointer;" class="openPopup text-body d-block" data-bs-toggle="modal" data-href="#application.mainURL#/backend/core/views/notifications/detail.cfm?nID=#i.notiID#">#getTrans(i.title_var)#</a>
                                    <div class="d-block text-muted mt-n1 text-truncate">
                                        #left(getTrans(i.desc_var), 50)#
                                    </div>
                                </div>
                            </div>
                        </div>
                    </cfloop>
                </cfif>
                <div class="list-group-item">
                    <div class="row align-items-center">
                        <div class="col text-truncate">
                            <a href="#application.mainURL#/notifications" class="btn">#getTrans('txtShowAllNotifications')#</a>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>
</cfoutput>