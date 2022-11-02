<cfscript>

    setting showdebugoutput =false;
    notifications = new com.notifications();

    if(structKeyExists(url, 'delete')){
        notificationDelete = notifications.deleteNotifications(url.notificationID);
    } else if(structKeyExists(url, 'deleteall')){
        notificationDeleteMultiple = notifications.deleteMultipleNotifications(url.arrCheckBoxID); 
    } else {
        notificationUpdate = notifications.updateReadNotifications(url.notificationID);
    };

    notificationEntrys = notifications.getNotifications(session.CUSTOMER_ID, session.USER_ID);
    
</cfscript>

    <a href="#" class="nav-link px-0" data-bs-toggle="dropdown" tabindex="-1" aria-label="Show notifications">
        <i class="far fa-bell"></i>
        <cfif not ArrayIsEmpty(notificationEntrys)>
            <span class="badge bg-red"></span>
        </cfif>
    </a>
    <cfif not ArrayIsEmpty(notificationEntrys)>
        <div class="dropdown-menu dropdown-menu-end dropdown-menu-card">
            <cfoutput>
                <cfloop array="#notificationEntrys#" index="i" item="notificationitem">
                    <cfif i GT 5 >
                        <cfbreak>
                    <cfelse>  
                        <a href="#application.mainURL#/notifications?nid=#notificationitem.intNotificationID#" class="dropdown-item">    
                            #getTrans(notificationitem.strTitleVar)#
                            #DateFormat(notificationitem.dtmCreated, "dd.mm.yyyy")#

                        </a>
                    </cfif>
                </cfloop>
                <a href="#application.mainURL#/notifications" class="dropdown-item">    
                    Alle Nachrichten anzeigen 
                    <cfset msgRows = arrayLen(notificationEntrys)>
                    <cfif msgRows gt 5>
                        <cfset msgUnreadLeft = msgRows - 5>
                        +#msgUnreadLeft#
                    </cfif>
                </a>
            </cfoutput>        
        </div>
    </cfif> 