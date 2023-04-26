<cfscript>

/* Initialise ticket object */
objTicket = new com.ticket();


if(structKeyExists(form, "create_user")){

    /* Execute function to create ticket */
    createTicket = objTicket.createTicket(form);

    /* Check execution */
    if(createTicket.success){
        location url="#application.mainURL#/ticket/check?ticket=#createTicket.uuid#" addtoken="false";
    } else {
        getAlert(createTicket.message, "warning");
        location url="#application.mainURL#/ticket/new" addtoken="false";
    }
    
}

if(structKeyExists(form, "create_worker")){

    /* Execute function to create ticket */
    createTicket = objTicket.createTicket(form);
    
    /* Check execution */
    if(createTicket.success){
        getAlert("Ticket successfully created");
        location url="#application.mainURL#/sysadmin/ticketsystem/new" addtoken="false";
    } else {
        getAlert(local.createTicket.message, "warning");
        location url="#application.mainURL#/sysadmin/ticketsystem/new" addtoken="false";
    }

}

if(structKeyExists(form, "answer_user")){
    
    /* Execute function to create answer */
    createAnswer = objTicket.createAnswer(form, url.ticket, session.user_id);

    /* Check execution */
    if(createAnswer.success){
        getAlert("#getTrans('txtAnswerCreated')#");
        location url="#application.mainURL#/ticket/detail?ticket=#url.ticket#" addtoken="false";
    } else {
        getAlert(local.createAnswer.message, "warning");
        location url="#application.mainURL#/ticket/detail?ticket=#url.ticket#" addtoken="false";
    }

}

if(structKeyExists(form, "answer_worker")){
    
    /* Execute function to create answer */
    createAnswer = objTicket.createAnswer(form, url.ticket, session.user_id);

    /* Check execution */
    if(createAnswer.success){
        getAlert("Response sent successfully!");
        location url="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#url.ticket#" addtoken="false";
    } else {
        getAlert(local.createAnswer.message, "warning");
        location url="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#url.ticket#" addtoken="false";
    }

}

if(structKeyExists(form, "worker")){

    /* Execute function to assign a worker */
    updateWorker = objTicket.updateWorker(form, url.ticket);

    /* Check execution */
    if(updateWorker.success){
        getAlert("Worker successfully assigned");
        location url="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#url.ticket#" addtoken="false";
    } else {
        getAlert(local.updateWorker.message, "warning");
        location url="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#url.ticket#" addtoken="false";
    }

}

if(structKeyExists(form, "close")){
    
    /* Execute function to close a ticket */
    closeTicket = objTicket.closeTicket(form, url.ticket);

    /* Check execution */
    if(closeTicket.success){
        getAlert("Ticket successfully closed");
        location url="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#url.ticket#" addtoken="false";
    } else {
        getAlert(local.closeTicket.message, "warning");
        location url="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#url.ticket#" addtoken="false";
    }

}

</cfscript>