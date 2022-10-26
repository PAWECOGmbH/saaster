<cfscript>
    notificationObj = new com.notifications();
    notificationEntrys = notificationObj.getNotifications(session.customer_id, session.user_id);           
</cfscript>
<div class="nav-item dropdown d-none d-md-flex me-3" id="readMsges">
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
              
                        <a href="#application.mainURL#/notifications?Nid=#notificationitem.intNotificationID#" class="dropdown-item">    
                          #getTrans(notificationitem.strTitleVar)#
                          #DateFormat( notificationitem.dtmCreated, "yyyy-mm-dd")#
                          
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
<!--- dump all variables --->
<!--- <div>  
  <cfdump var="#form#">
  <cfdump var="#session#">
  <cfdump var="#url#">
</div> --->

  <!--- im searching variables!!!! --->


  <!--- All Functions Globally --->
  <!--- <cfdump var="#application.objGlobal#"> --->

  <!--- Translated textmessages output --->
 <!---  <cfdump var="#application.objGlobal.getTrans#">
  <cfset yolo1 = "#application.objGlobal.getTrans("alertEnterCity")#">
  <cfdump var="#yolo1#">
 --->

  <!--- dump function and data inside --->
  <!--- <cfdump var = "#application.objGlobal.getDefaultLanguage#">
        <cfset yolo = "#application.objGlobal.getDefaultLanguage()#">
        <cfdump var = "#yolo#"> --->


