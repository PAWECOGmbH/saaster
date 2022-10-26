<cfinclude template="/includes/header.cfm">

<cfinclude template="/includes/navigation.cfm">

<cfscript>
    param name="session.notification_page" default=1 type="numeric";
    notificationObj = new com.notifications();
    notificationEntrys = notificationObj.getAllNotifications(session.CUSTOMER_ID, session.USER_ID);    
    
    if((not structKeyExists(url, 'page')) and structKeyExists(url, 'Nid')){
        notificationPos = notificationObj.getNotificationPos(url.Nid);
        location url="#application.mainURL#/notifications?page=#notificationPos#&Nid=#url.Nid#" addtoken="false";   
    }

    totalEntrys = ArrayLen(notificationEntrys);
    getEntries = 10;
    invoice_start = 0;
    pages = ceiling(totalEntrys / getEntries);
/*     if(pages GTE url.pages){

        newvalue = session.notification_page -1
    } */

    
    // Check if url "page" exists and if it matches the requirments
    if (structKeyExists(url, "page") and isNumeric(url.page) and not url.page lte 0 and not url.page gt pages) {
        
        session.notification_page = url.page;
    }
    
    if (session.notification_page gt 1){
        tPage = session.notification_page - 1;
        valueToAdd = getEntries * tPage;
        invoice_start = invoice_start + valueToAdd;
    }
    queryLimit = "LIMIT #invoice_start#, #getEntries#";

    if(structKeyExists(session, "CUSTOMER_ID") and structKeyExists(session, "USER_ID")){
        qTotalCount = queryExecute(
            options = {datasource = application.datasource, returntype="array"},
            params = {
                customerID: {type: "numeric", value: session.customer_ID},
                userID: {type: "numeric", value: session.user_ID}
            },
            sql = "
                SELECT *
                FROM notifications
                WHERE intCustomerID = :customerID
                AND intUserID = :userID
                ORDER BY dtmCreated DESC
                #queryLimit#
            "
        )
    }else if(structKeyExists(session, "costumer_ID")){
        qTotalCount = queryExecute(
            options = {datasource = application.datasource, returntype="array"},
            params = {
                customerID: {type: "numeric", value: session.customer_ID},
                
            },
            sql = "
                SELECT *
                FROM notifications
                WHERE intCustomerID = :customerID
                ORDER BY dtmCreated DESC
                #queryLimit#  
            "
        )
    }
    cfsavecontent( variable="inlinestyling" ){
		echo('style="border-bottom: none!important;border-bottom-color: none!important;border-bottom-style: none!important;border-bottom-width: none!important;"')
	}
	/* echo(inlinestyling); */

</cfscript>

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">#getTrans('titNotifications')#</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                            <li class="breadcrumb-item active">#getTrans('titNotifications')#</li>
                        </ol>
                    </div>
                    <!--- <div class="page-header col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="##" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> Button
                        </a>
                    </div> --->
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="container-xl">
            <div class="row">
                <div class="col-lg-12">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">#getTrans('titNotifications')#</h3>
                        </div>
                        <div class="card-body">
                            <cfif not ArrayIsEmpty(notificationEntrys)>
                                <div class="table-responsive">
                                    <table class="table card-table table-vcenter text-nowrap datatable">
                                        <thead>
                                            <tr>
                                                <th class="w-5"><input class="form-check-input m-0 align-middle allCheck" type="checkbox" aria-label="Select all Notifications"></th>
                                                
                                                <th class="w-20">#getTrans('txtNotificationTitle')#</th>
                                                
                                                
                                                <th class="w-20">#getTrans('txtNotificationCreated')#</th>
                                                <th class="w-20 text-center">#getTrans('txtNotificationStatus')#</th>
                                                
                                                <th class="w-20">#getTrans('btnDelete')#</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfset countEntrys = 1>
                                            <!--- <cfdump  var="#qTotalCount#">
                                            <cfabort> --->
                                            <!--- <cfdump  var="#form#"> --->
                                            <cfoutput>
                                            <!--- <form action="#application.mainURL#/notifications" method="post"> --->
                                                </cfoutput>
                                                <cfloop array="#qTotalCount#" index="i" item="notificationitem">
                                                    <cfset countEntrys = countEntrys + 1>
                                                    <cfoutput>
                                                        <tr #inlinestyling#>
                                                            
                                                            <td #inlinestyling#><input role='button' name="" id="#notificationitem.intNotificationID#" class="form-check-input m-0 align-right notificationCheckBox" type="checkbox" aria-label="Select invoice"></td>
                                                            
                                                            <td #inlinestyling#><a role='button' class="text-reset notificationText" data-location="#application.mainURL#/handler/ajax_notificationhandler.cfm?notificationID=#notificationitem.intNotificationID#" id="#notificationitem.intNotificationID#" tabindex="-1">#getTrans(notificationitem.strTitleVar)#</a></td>
                                                            
                                                            <td #inlinestyling#>
                                                                #lsDateFormat(notificationitem.dtmCreated)#
                                                                <!--- <cfswitch expression = #session.lng#>
                                                                <cfcase value="en">
                                                                    #DateFormat( notificationitem.dtmCreated, "yyyy-mm-dd")#
                                                                </cfcase>
                                                                <cfcase value="de">
                                                                    #DateFormat( notificationitem.dtmCreated, "dd-mm-yyyy")#
                                                                </cfcase>
                                                                <cfdefaultcase>
                                                                    #DateFormat( notificationitem.dtmCreated, "yyyy-mm-dd")#
                                                                </cfdefaultcase>
                                                                </cfswitch> --->
                                                            </td>
                                                            <td class="text-center"#inlinestyling# id="msgReadIcon#notificationitem.intNotificationID#">
                                                                <cfif len(trim(notificationitem.dtmRead))>
                                                                    <i class="fas fa-check"></i>
                                                                <cfelse>
                                                                    <span class="badge bg-danger me-1"></span> 
                                                                </cfif>
                                                            </td>
                                                            
                                                            <td #inlinestyling#>
                                                                <button role='button' id="deleteNotification" data-location="#application.mainURL#/handler/ajax_notificationhandler.cfm?notificationID=#notificationitem.intNotificationID#&delete"  class="btn align-text-top" >#getTrans('btnDelete')#
                                                                </button>
                                                                <div hidden id="sweetAlertTransSingle" data-btnone="#getTrans('btnNoCancel')#" data-btntwo="#getTrans('btnYesDelete')#" data-txtone="#getTrans('titDeleteNotification')#" data-txttwo="#getTrans('txtNotificationDelete')#"></div>
                                                            </td>
                                                        </tr>
                                                        
                                                        <tr class="border-t-0 text-break custom-w w-break" id="#notificationitem.intNotificationID#-" <!--- class="d-none" ---> >
                                                            
                                                            <td class="border-t-0 p-0" ></td>
                                                            <td class="border-t-0 p-0 custom-w w-break"  colspan="4" ><div class="notificationiAnimation custom-w w-break" style="display:none;padding:8px;"><!--- #getTrans(notificationitem.strDescrVar)# --->testlongtxttestlongtxttestlongtxttestlongtxttestlong txttestlongtxttestlongtxttestlongtxttestlongtxttestlongtxt testlongtxttestlongtxttestlongtxttestlongtxttestlongtxttestlongtxttestlongtxttestlongtxttestlongtxt</div></td>
                                                            
                                                        </tr>
                                                    </cfoutput>
                                                </cfloop> 
                                                <!--- <button type="submit">Delete</button>  ---> 
                                            <!--- </form>  --->   
                                            <!--- <cfoutput>
                                                #countEntrys#
                                            </cfoutput> --->
                                        </tbody>
                                    </table>
                                    
                                        <!---  --->
                                        <cfoutput>
                                        
                                            <div class="card-body d-flex">
                                                <ul class="mb-0 ps-0">
                                                    <i role='button' id="deleteAllSelected" style="display:none;" data-location="#application.mainURL#/handler/ajax_notificationhandler.cfm?deleteall" class="fas fa-trash-can">
                                                    </i>
                                                    <div hidden id="sweetAlertTrans" data-btnone="#getTrans('btnNoCancel')#" data-btntwo="#getTrans('btnYesDelete')#" data-txtone="#getTrans('titMultipleNotificationDelete')#" data-txttwo="#getTrans('txtMultipleNotificationDelete')#"></div>
                                                </ul>
                                                <ul class="w-50 mb-0"></ul>
                                                <cfif pages neq 1 and arrayLen(notificationEntrys)>
                                                    <ul class="pagination mb-0" id="pagination">
                                                        
                                                        <!--- First page --->
                                                        <li class="page-item <cfif session.notification_page eq 1>disabled</cfif>">
                                                            <a class="page-link" href="#application.mainURL#/notifications?page=1" tabindex="-1" aria-disabled="true">
                                                                <i class="fas fa-angle-double-left"></i>
                                                            </a>
                                                        </li>
                    
                                                        <!--- Prev arrow --->
                                                        <li class="page-item <cfif session.notification_page eq 1>disabled</cfif>">
                                                            <a class="page-link" href="#application.mainURL#/notifications?page=#session.notification_page-1#" tabindex="-1" aria-disabled="true">
                                                                <i class="fas fa-angle-left"></i>
                                                            </a>
                                                        </li>
                    
                                                        <!--- Pages --->
                                                        <cfif session.notification_page + 4 gt pages>
                                                            <cfset blockPage = pages>
                                                        <cfelse>
                                                            <cfset blockPage = session.notification_page + 4>
                                                        </cfif>
                    
                                                        <cfif blockPage neq pages>
                                                            <cfloop index="j" from="#session.notification_page#" to="#blockPage#">
                                                                <cfif not blockPage gt pages>
                                                                    <li class="page-item <cfif session.notification_page eq j>active</cfif>">
                                                                        <a class="page-link" href="#application.mainURL#/notifications?page=#j#">#j#</a>
                                                                    </li>
                                                                </cfif>
                                                            </cfloop>
                                                        <cfelseif blockPage lt 5>
                                                            <cfloop index="j" from="1" to="#pages#">
                                                                <li class="page-item <cfif session.notification_page eq j>active</cfif>">
                                                                    <a class="page-link" href="#application.mainURL#/notifications?page=#j#">#j#</a>
                                                                </li>
                                                            </cfloop>
                                                        <cfelse>
                                                            <cfloop index="j" from="#pages - 4#" to="#pages#">
                                                                    <li class="page-item <cfif session.notification_page eq j>active</cfif>">
                                                                        <a class="page-link" href="#application.mainURL#/notifications?page=#j#">#j#</a>
                                                                    </li>
                                                            </cfloop>
                                                        </cfif>
                    
                                                        <!--- Next arrow --->
                                                        <li class="page-item <cfif session.notification_page gte pages>disabled</cfif>">
                                                            <a class="page-link" href="#application.mainURL#/notifications?page=#session.notification_page+1#">
                                                                <i class="fas fa-angle-right"></i>
                                                            </a>
                                                        </li>
                    
                                                        <!--- Last page --->
                                                        <li class="page-item <cfif session.notification_page gte pages>disabled</cfif>">
                                                            <a class="page-link" href="#application.mainURL#/notifications?page=#pages#">
                                                                <i class="fas fa-angle-double-right"></i>
                                                            </a>
                                                        </li>
                                                    </ul>
                                                </cfif>
                                            <ul class="w-50 mb-0"></ul>
                                        </div>
                                    </cfoutput>
            
                                        <!---  --->
                                        <!--- <div class="card-footer d-flex align-items-center">
                                            <!--- <p class="m-0 text-muted">Showing <span>1</span> to <span>8</span> of <span>16</span> entries</p> --->
                                            <ul class="pagination m-0 ms-auto">
                                            <li class="page-item disabled">
                                                <a class="page-link" href="#" tabindex="-1" aria-disabled="true">
                                                <!-- Download SVG icon from http://tabler-icons.io/i/chevron-left -->
                                                <svg xmlns="http://www.w3.org/2000/svg" class="icon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><polyline points="15 6 9 12 15 18" /></svg>
                                                prev
                                                </a>
                                            </li>
                                            <li class="page-item"><a class="page-link" href="#">1</a></li>
                                            <li class="page-item active"><a class="page-link" href="#">2</a></li>
                                            <li class="page-item"><a class="page-link" href="#">3</a></li>
                                            <li class="page-item"><a class="page-link" href="#">4</a></li>
                                            <li class="page-item"><a class="page-link" href="#">5</a></li>
                                            <li class="page-item">
                                                <a class="page-link" href="#">
                                                next <!-- Download SVG icon from http://tabler-icons.io/i/chevron-right -->
                                                <svg xmlns="http://www.w3.org/2000/svg" class="icon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><polyline points="9 6 15 12 9 18" /></svg>
                                                </a>
                                            </li>
                                            </ul>
                                        </div> --->
                                        
                                </div>
                            </cfif>    
                        </div>
                        
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>


