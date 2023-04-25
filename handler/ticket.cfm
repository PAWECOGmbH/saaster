<cfscript>

/* Initialise ticket object */
objTicket = new com.ticket();


if(structKeyExists(form, "create_user")){

    /* Execute function */
    local.createTicket = objTicket.createTicket(form);

    /* Check execution */
    if(local.createTicket.success){
        location url="#application.mainURL#/ticket/check?a=#local.createTicket.uuid#" addtoken="false";
    } else {
        getAlert(local.createTicket.message, "warning");
        location url="#application.mainURL#/ticket/new" addtoken="false";
    }
    
}

if(structKeyExists(form, "create_worker")){

    /* Execute function */
    local.createTicket = objTicket.createTicket(form);
    
    /* Check execution */
    if(local.createTicket.success){
        getAlert("Ticket successfully created");
        location url="#application.mainURL#/sysadmin/ticketsystem/new" addtoken="false";
    } else {
        getAlert(local.createTicket.message, "warning");
        location url="#application.mainURL#/sysadmin/ticketsystem/new" addtoken="false";
    }

}

if(structKeyExists(form, "answer_user")){
    

}

if(structKeyExists(form, "answer_worker")){
    

}

if(structKeyExists(form, "worker")){


}

if(structKeyExists(form, "close")){
    

}

</cfscript>