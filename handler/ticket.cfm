<cfscript>

// Initialise ticket object 
objTicket = new com.ticket();


if(structKeyExists(form, "create_user")){

    // Execute function to create ticket
    createTicket = objTicket.createTicket(form);

    // Check execution 
    if(createTicket.success){
        logWrite("Ticketsystem", 1, "File: #callStackGet("string", 0 , 1)#, Ticket successfully created", false);
        session.ticket = createTicket.uuid;
        location url="#application.mainURL#/ticket/check" addtoken="false";
    } else {
        logWrite("Ticketsystem", 2, "File: #callStackGet("string", 0 , 1)#, Could not create ticket: #createTicket.message#", false);
        getAlert(createTicket.message, "warning");
        location url="#application.mainURL#/ticket/new" addtoken="false";
    }
    
}

if(structKeyExists(form, "create_worker")){

    // Execute function to create ticket 
    createTicket = objTicket.createTicket(form);
    
    // Check execution 
    if(createTicket.success){
        logWrite("Ticketsystem", 1, "File: #callStackGet("string", 0 , 1)#, Ticket successfully created", false);
        getAlert("Ticket successfully created");
        location url="#application.mainURL#/sysadmin/ticketsystem/new" addtoken="false";
    } else {
        logWrite("Ticketsystem", 2, "File: #callStackGet("string", 0 , 1)#, Could not create ticket: #createTicket.message#", false);
        getAlert(createTicket.message, "warning");
        location url="#application.mainURL#/sysadmin/ticketsystem/new" addtoken="false";
    }

}

if(structKeyExists(form, "answer_user")){
    
    // Execute function to create answer 
    createAnswer = objTicket.createAnswer(form, url.ticket, session.user_id);

    // Check execution 
    if(createAnswer.success){
        logWrite("Ticketsystem", 1, "File: #callStackGet("string", 0 , 1)#, Response sent successfully", false);
        getAlert("#getTrans('txtAnswerCreated')#");
        location url="#application.mainURL#/ticket/detail?ticket=#url.ticket#" addtoken="false";
    } else {
        logWrite("Ticketsystem", 2, "File: #callStackGet("string", 0 , 1)#, Could not send response: #createAnswer.message#", false);
        getAlert(createAnswer.message, "warning");
        location url="#application.mainURL#/ticket/detail?ticket=#url.ticket#" addtoken="false";
    }

}

if(structKeyExists(form, "answer_worker")){
    
    // Execute function to create answer 
    createAnswer = objTicket.createAnswer(form, url.ticket, session.user_id);

    // Check execution 
    if(createAnswer.success){
        logWrite("Ticketsystem", 1, "File: #callStackGet("string", 0 , 1)#, Response sent successfully", false);
        getAlert("Response sent successfully!");
        location url="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#url.ticket#" addtoken="false";
    } else {
        logWrite("Ticketsystem", 2, "File: #callStackGet("string", 0 , 1)#, Could not send response: #createAnswer.message#", false);
        getAlert(createAnswer.message, "warning");
        location url="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#url.ticket#" addtoken="false";
    }

}

if(structKeyExists(form, "worker")){

    // Execute function to assign a worker
    updateWorker = objTicket.updateWorker(form, url.ticket);

    // Check execution
    if(updateWorker.success){
        logWrite("Ticketsystem", 1, "File: #callStackGet("string", 0 , 1)#, Worker successfully assigned", false);
        getAlert("Worker successfully assigned");
        location url="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#url.ticket#" addtoken="false";
    } else {
        logWrite("Ticketsystem", 2, "File: #callStackGet("string", 0 , 1)#, Could not assigne worker: #updateWorker.message#", false);
        getAlert(updateWorker.message, "warning");
        location url="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#url.ticket#" addtoken="false";
    }

}

if(structKeyExists(form, "close")){
    
    // Execute function to close a ticket
    updateStatus = objTicket.updateStatus(form, url.ticket);

    // Check execution
    if(updateStatus.success){
        logWrite("Ticketsystem", 1, "File: #callStackGet("string", 0 , 1)#, Ticket successfully closed", false);
        getAlert("Ticket successfully closed");
        location url="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#url.ticket#" addtoken="false";
    } else {
        logWrite("Ticketsystem", 2, "File: #callStackGet("string", 0 , 1)#, Could not close ticket: #updateStatus.message#", false);
        getAlert(updateStatus.message, "warning");
        location url="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#url.ticket#" addtoken="false";
    }

}

</cfscript>