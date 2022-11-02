<cfscript>

    notificationObj = new com.notifications();
    notificationEntrys = notificationObj.getNotifications(session.customer_id, session.user_id); 

</cfscript>

<div class="nav-item dropdown d-flex me-2" id="readMsges">
    <a href="#" class="nav-link px-0" data-bs-toggle="dropdown" tabindex="-1" aria-label="Show notifications">
        <i class="far fa-bell"></i>
        <cfif not ArrayIsEmpty(notificationEntrys)>
            <span class="badge bg-red"></span>
        </cfif>
    </a>
    <div class="dropdown-menu dropdown-menu-end dropdown-menu-card">
        <cfoutput>
            <cfif not ArrayIsEmpty(notificationEntrys)>
                <cfloop array="#notificationEntrys#" index="i" item="notificationitem">
                    <cfif i gt 5 >
                        <cfbreak>
                    <cfelse>  
                        <a href="#application.mainURL#/notifications?nid=#notificationitem.intNotificationID#" class="dropdown-item">    
                          #getTrans(notificationitem.strTitleVar)#
                          #DateFormat(notificationitem.dtmCreated, "dd.mm.yyyy")#
                        </a>
                    </cfif>
                </cfloop>
            </cfif>  
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
</div>