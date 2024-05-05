

<cfscript>

    param name="session.noti_c_page" default=1 type="numeric";
    getEntries = 10;
    noti_start = 0;

    pages = ceiling(qTotalNoties / getEntries);

    // Check if url "page" exists and if it matches the requirments
    if (structKeyExists(url, "page") and isNumeric(url.page) and not url.page lte 0 and not url.page gt pages) {
        session.noti_c_page = url.page;
    } else {
        if (qTotalNoties gt 0) {
            location url="#application.mainurl#/notifications?page=1" addtoken="false";
        }
    }

    if (session.noti_c_page gt 1){
        tPage = session.noti_c_page - 1;
        valueToAdd = getEntries * tPage;
        noti_start = noti_start + valueToAdd;
    }

    qNotiOverview = application.objNotifications.getNotifications(customerID=session.customer_id, start=noti_start, count=getEntries);

</cfscript>

<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">
        <div class="row">
            <div class="#getLayout.layoutPageHeader# mb-3">
                <h4 class="page-title">#getTrans('titNotifications')#</h4>
                <ol class="breadcrumb breadcrumb-dots">
                    <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                    <li class="breadcrumb-item active">#getTrans('titNotifications')# (#qTotalNoties#)</li>
                </ol>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>

        <cfif !ArrayIsEmpty(qNotiOverview.arrayNoti)>
            <div class="row">
                <div class="col-md-12 col-lg-12">
                    <div class="card">
                        <div class="table-responsive">
                            <table class="table table-vcenter table-mobile-md card-table">
                                <thead>
                                    <tr>
                                        <th width="5%"><input type="checkbox" id="checkAll"></th>
                                        <th width="15%">#getTrans('titDateTime')#</th>
                                        <th width="65%">#getTrans('titNotification')#</th>
                                        <th width="10%" class="text-center">#getTrans('titStatus')#</th>
                                        <th width="5%"></th>
                                    </tr>
                                </thead>
                                <form action="#application.mainURL#/global?page=#url.page#" method="post">
                                    <tbody>
                                        <cfloop array="#qNotiOverview.arrayNoti#" index="i">
                                            <tr id="checkAll">
                                                <td><input type="checkbox" name="notiID" value="#i.notiID#"></td>
                                                <td>#lsDateFormat(getTime.utc2local(utcDate=i.created))# #lsTimeFormat(getTime.utc2local(utcDate=i.created))#</td>
                                                <td style="cursor: pointer;" class="openPopup" data-bs-toggle="modal" data-href="#application.mainURL#/backend/core/views/notifications/detail.cfm?nID=#i.notiID#">
                                                    <cfif isDate(i.read)>
                                                        #getTrans(i.title_var)#
                                                    <cfelse>
                                                        <b>#getTrans(i.title_var)#</b>
                                                    </cfif>
                                                </td>
                                                <td class="text-center">
                                                    <cfif isDate(i.read)>
                                                        <div class="badge bg-green"></div>
                                                    <cfelse>
                                                        <div class="badge bg-red"></div>
                                                    </cfif>
                                                </td>
                                                <td><a href="##?" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/global?page=#url.page#&noti_del=#i.notiID#', '#getTrans("titDeleteNotification")#', '#getTrans("txtNotificationDelete")#', '#getTrans("btnNoCancel")#', '#getTrans("btnYesDelete")#')">#getTrans('btnDelete')#</a></td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                    <tr>
                                        <td colspan="3">
                                            <div class="input-group" style="max-width: 300px;">
                                                <select name="noti_action" class="form-select">
                                                    <option value="">---</option>
                                                    <option value="read">#getTrans('txtMarkAsRead')#</option>
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
                </div>
            </div>
            <cfif pages neq 1>
                <div class="card-body">
                    <ul class="pagination justify-content-center" id="pagination">

                        <!--- First page --->
                        <li class="page-item <cfif session.noti_c_page eq 1>disabled</cfif>">
                            <a class="page-link" href="#application.mainURL#/notifications?page=1" tabindex="-1" aria-disabled="true">
                                <i class="fas fa-angle-double-left"></i>
                            </a>
                        </li>

                        <!--- Prev arrow --->
                        <li class="page-item <cfif session.noti_c_page eq 1>disabled</cfif>">
                            <a class="page-link" href="#application.mainURL#/notifications?page=#session.noti_c_page-1#" tabindex="-1" aria-disabled="true">
                                <i class="fas fa-angle-left"></i>
                            </a>
                        </li>

                        <!--- Pages --->
                        <cfif session.noti_c_page + 4 gt pages>
                            <cfset blockPage = pages>
                        <cfelse>
                            <cfset blockPage = session.noti_c_page + 4>
                        </cfif>

                        <cfif blockPage neq pages>
                            <cfloop index="j" from="#session.noti_c_page#" to="#blockPage#">
                                <cfif not blockPage gt pages>
                                    <li class="page-item <cfif session.noti_c_page eq j>active</cfif>">
                                        <a class="page-link" href="#application.mainURL#/notifications?page=#j#">#j#</a>
                                    </li>
                                </cfif>
                            </cfloop>
                        <cfelseif blockPage lt 5>
                            <cfloop index="j" from="1" to="#pages#">
                                <li class="page-item <cfif session.noti_c_page eq j>active</cfif>">
                                    <a class="page-link" href="#application.mainURL#/notifications?page=#j#">#j#</a>
                                </li>
                            </cfloop>
                        <cfelse>
                            <cfloop index="j" from="#pages - 4#" to="#pages#">
                                    <li class="page-item <cfif session.noti_c_page eq j>active</cfif>">
                                        <a class="page-link" href="#application.mainURL#/notifications?page=#j#">#j#</a>
                                    </li>
                            </cfloop>
                        </cfif>

                        <!--- Next arrow --->
                        <li class="page-item <cfif session.noti_c_page gte pages>disabled</cfif>">
                            <a class="page-link" href="#application.mainURL#/notifications?page=#session.noti_c_page+1#">
                                <i class="fas fa-angle-right"></i>
                            </a>
                        </li>

                        <!--- Last page --->
                        <li class="page-item <cfif session.noti_c_page gte pages>disabled</cfif>">
                            <a class="page-link" href="#application.mainURL#/notifications?page=#pages#">
                                <i class="fas fa-angle-double-right"></i>
                            </a>
                        </li>

                    </ul>
                </div>
            </cfif>
        <cfelse>
            <div class="alert alert-primary" role="alert">
                #getTrans('msgNoNotifications')#
            </div>
        </cfif>
    </div>

    

</div>

</cfoutput>
