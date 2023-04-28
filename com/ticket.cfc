component displayname="ticket" output="false" {


    // Initialise language object with getTrans function 
    local.objLanguage = new com.language();
    getTrans = local.objLanguage.getTrans;

    // Initialise log object with logWrite function
    local.objLog = new com.log();
    logWrite = local.objLog.logWrite;


    // Function to create ticket 
    public struct function createTicket(required struct formStruct){

        // Initialise return struct 
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        // Reset session variables 
        structDelete(session, "reference");
        structDelete(session, "description");
        structDelete(session, "email");

        local.worker = false;

        // Check internal usage 
        if(structKeyExists(arguments.formStruct, "create_worker")){
            local.worker = true;
        }

        // Validate form values 
        if(structKeyExists(arguments.formStruct, "reference") and len(trim(arguments.formStruct.reference))){
            session.reference = trim(left(arguments.formStruct.reference, 255));
        } else {
            local.argsReturnValue.message = local.worker ? "Enter a reference!" : "#getTrans('txtReferenceError')#";
        }

        if(structKeyExists(arguments.formStruct, "description") and len(trim(arguments.formStruct.description))){
            session.description = trim(left(arguments.formStruct.description, 2000));
        } else {

            if(len(trim(local.argsReturnValue.message))){
                local.argsReturnValue.message = local.worker ? "Enter a description and reference!" : "#getTrans('txtDescriptionReferenceError')#";
            } else {
                local.argsReturnValue.message = local.worker ? "Enter a description!" : "#getTrans('txtDescriptionError')#";
            }

        }

        // Search for user by email 
        if(structKeyExists(arguments.formStruct, "create_worker")){
            if(structKeyExists(arguments.formStruct, "email") and len(trim(arguments.formStruct.email))){
                
                // Get user query 
                try {
                    local.qUser = queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            email: {type: "varchar", value: arguments.formStruct.email}
                        },
                        sql = "
                            SELECT intUserID
                            FROM users
                            WHERE strEmail = :email
                        "
                    )
                } catch (any e) {
                    logWrite("Ticketsystem", 3, "File: #callStackGet("string", 0 , 1)#, Could not execute query to find user: #e.message#", false);
                    local.argsReturnValue.message = "Could not execute query to find user!";
                    return local.argsReturnValue;
                }

                // Check if user was found 
                if(local.qUser.recordCount eq 1){
                    session.email = arguments.formStruct.email;
                    local.userID = local.qUser.intUserID;
                } else {
                    local.argsReturnValue.message = "E-mail doesn't exists!";
                    return local.argsReturnValue;
                }

            } else {
                local.argsReturnValue.message = "Enter a E-Mail!";
                return local.argsReturnValue;
            }
        }

        // Get ID from user 
        if(structKeyExists(arguments.formStruct, "create_user")){
            local.userID = session.user_id;
        }

        // Check cancellation 
        if(not structKeyExists(session, "reference") or not structKeyExists(session, "description")){
            return local.argsReturnValue;
        }

        // Get ticket from user query
        try {
            local.qTicketUser = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    userID: {type: "integer", value: local.userID}
                },
                sql = "
                    SELECT intTicketID
                    FROM ticket
                    WHERE intUserID = :userID
                    AND intStatusID != 3
                "
            )
        } catch (any e) {
            logWrite("Ticketsystem", 3, "File: #callStackGet("string", 0 , 1)#, Could not execute query to find tickets from user: #e.message#", false);
            local.argsReturnValue.message = local.worker ? "Could not execute query to find tickets from user!" : "#getTrans('txtTicketCheckError')#";
            return local.argsReturnValue;
        }

        // Check if user has more than three tickets
        if(local.qTicketUser.recordCount gt 2){
            local.argsReturnValue.message = local.worker ? "This user already have three tickets that have not been completed!" : "#getTrans('txtTicketAmountError')#";
            return local.argsReturnValue;
        }

        // Define needed variables 
        local.status = 1;
        local.date = now();
        local.ticketUUID = listLast(createUUID(), "-");

        local.check = checkUUID(local.ticketUUID);
        
        // Check if uuid already exists 
        while(local.check.recordCount neq 0){
            local.ticketUUID = listLast(createUUID(), "-");
            local.check = checkUUID(local.ticketUUID);
        }

        // Create ticket query 
        try {
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    reference: {type: "varchar", value: session.reference},
                    description: {type: "varchar", value: session.description},
                    userID: {type: "integer", value: local.userID},
                    statusID: {type: "integer", value: local.status},
                    UUID: {type: "varchar", value: local.ticketUUID},
                    datetime: {type: "timestamp", value: local.date}
                },
                sql = "
                    INSERT INTO ticket (intUserID, intStatusID, strReference, strDescription, dtmOpen, strUUID)
                    VALUES (:userID, :statusID, :reference, :description, :datetime, :UUID)
                "
            )
        } catch (any e) {
            logWrite("Ticketsystem", 3, "File: #callStackGet("string", 0 , 1)#, Could not execute query to create ticket: #e.message#", false);
            local.argsReturnValue.message = local.worker ? "Could not execute query to create ticket!" : "#getTrans('txtCreateTicketError')#";
            return local.argsReturnValue;
        }

        // Reset session variables 
        structDelete(session, "reference");
        structDelete(session, "description");
        structDelete(session, "email");

        // Send E-Mail
        local.email = sendEmail(arguments.formStruct, local.ticketUUID, local.userID, local.worker);

        // Check if email was sent
        if(not local.email.success){
            local.argsReturnValue.message = local.email.message;
            return local.argsReturnValue;
        }
        
        // configure return struct 
        local.argsReturnValue['uuid'] = local.ticketUUID;
        local.argsReturnValue['message'] = "Ok";
        local.argsReturnValue['success'] = true;
        return local.argsReturnValue;
    }


    // Function to get all tickets 
    public query function getTickets(struct formStruct){
        
        // Sort by date
        if(structKeyExists(arguments.formStruct, "date") and isNumeric(arguments.formStruct.date)){
            
            // Assign values ​​from form
            switch(arguments.formStruct.date){
                case 1:
                    local.date = "DESC";
                    break;
                case 2:
                    local.date = "ASC";
                    break;
                default:
                    local.date = "DESC";
                    break;
            }

            // Get tickets query date
            local.qTickets = queryExecute(
                options = {datasource = application.datasource},
                sql = "
                    SELECT ticket.intStatusID, ticket.intUserID, ticket.intWorkerID, ticket.strReference, ticket.dtmOpen, ticket.strUUID, 
                    ticket_status.strName, us.strFirstName userFirstName, us.strLastName userLastName, wo.strFirstName workerFirstName, wo.strLastName workerLastName
                    FROM ticket
                    LEFT JOIN ticket_status
                    ON ticket.intStatusID = ticket_status.intStatusID
                    LEFT JOIN users us
                    ON ticket.intUserID = us.intUserID
                    LEFT JOIN users wo
                    ON ticket.intWorkerID = wo.intUserID
                    WHERE ticket.intStatusID != 3
                    ORDER BY ticket.dtmOpen #local.date#
                "
            )

            return local.qTickets;
        }

        // Sort by status
        if(structKeyExists(arguments.formStruct, "status") and isNumeric(arguments.formStruct.status)){

            // Assign values ​​from form
            switch(arguments.formStruct.status){
                case 1:
                    local.status = 1;
                    break;
                case 2:
                    local.status = 2;
                    break;
                case 3:
                    local.status = 3;
                    break;
                default:
                    local.status = 1;
                    break;
            }

            // Get tickets query status
            local.qTickets = queryExecute(
                options = {datasource = application.datasource},
                sql = "
                    SELECT ticket.intStatusID, ticket.intUserID, ticket.intWorkerID, ticket.strReference, ticket.dtmOpen, ticket.strUUID, 
                    ticket_status.strName, us.strFirstName userFirstName, us.strLastName userLastName, wo.strFirstName workerFirstName, wo.strLastName workerLastName
                    FROM ticket
                    LEFT JOIN ticket_status
                    ON ticket.intStatusID = ticket_status.intStatusID
                    LEFT JOIN users us
                    ON ticket.intUserID = us.intUserID
                    LEFT JOIN users wo
                    ON ticket.intWorkerID = wo.intUserID
                    WHERE ticket.intStatusID = #local.status#
                    ORDER BY ticket.dtmOpen ASC
                "
            )

            return local.qTickets;
        }

        // Sort by worker
        if(structKeyExists(arguments.formStruct, "worker") and isNumeric(arguments.formStruct.worker)){

            local.worker = arguments.formStruct.worker;

            // Get tickets query by worker       
            local.qTickets = queryExecute(
                options = {datasource = application.datasource},
                sql = "
                    SELECT ticket.intStatusID, ticket.intUserID, ticket.intWorkerID, ticket.strReference, ticket.dtmOpen, ticket.strUUID, 
                    ticket_status.strName, us.strFirstName userFirstName, us.strLastName userLastName, wo.strFirstName workerFirstName, wo.strLastName workerLastName
                    FROM ticket
                    LEFT JOIN ticket_status
                    ON ticket.intStatusID = ticket_status.intStatusID
                    LEFT JOIN users us
                    ON ticket.intUserID = us.intUserID
                    LEFT JOIN users wo
                    ON ticket.intWorkerID = wo.intUserID
                    WHERE ticket.intWorkerID = #local.worker#
                "
            )

            return local.qTickets;
        }

        // Search for user name
        if(structKeyExists(arguments.formStruct, "search") and structKeyExists(arguments.formStruct, "text") and len(trim(arguments.formStruct.text))){
            
            // Chech for first and last name
            if(listLen(arguments.formStruct.text, " ") eq 2){

                local.firstName = listFirst(arguments.formStruct.text, " ");
                local.lastName = listLast(arguments.formStruct.text, " ");

                // Get tickets query by first and last name
                local.qTickets = queryExecute(
                    options = {datasource = application.datasource},
                    sql = "
                        SELECT ticket.intStatusID, ticket.intUserID, ticket.intWorkerID, ticket.strReference, ticket.dtmOpen, ticket.strUUID, 
                        ticket_status.strName, us.strFirstName userFirstName, us.strLastName userLastName, wo.strFirstName workerFirstName, wo.strLastName workerLastName
                        FROM ticket
                        LEFT JOIN ticket_status
                        ON ticket.intStatusID = ticket_status.intStatusID
                        LEFT JOIN users us
                        ON ticket.intUserID = us.intUserID
                        LEFT JOIN users wo
                        ON ticket.intWorkerID = wo.intUserID
                        WHERE us.strFirstName = '#local.firstName#'
                        AND us.strLastName = '#local.lastName#'
                        ORDER BY ticket.dtmOpen DESC
                    "
                )

            } else {

                local.name = listFirst(arguments.formStruct.text, " ");

                // Get tickets query by first name 
                local.qTickets = queryExecute(
                    options = {datasource = application.datasource},
                    sql = "
                        SELECT ticket.intStatusID, ticket.intUserID, ticket.intWorkerID, ticket.strReference, ticket.dtmOpen, ticket.strUUID, 
                        ticket_status.strName, us.strFirstName userFirstName, us.strLastName userLastName, wo.strFirstName workerFirstName, wo.strLastName workerLastName
                        FROM ticket
                        LEFT JOIN ticket_status
                        ON ticket.intStatusID = ticket_status.intStatusID
                        LEFT JOIN users us
                        ON ticket.intUserID = us.intUserID
                        LEFT JOIN users wo
                        ON ticket.intWorkerID = wo.intUserID
                        WHERE us.strFirstName = '#local.name#'
                        ORDER BY ticket.dtmOpen DESC
                    "
                )

                // Search for last name if no first name result is found
                if(local.qTickets.recordCount eq 0){

                    local.qTickets = queryExecute(
                        options = {datasource = application.datasource},
                        sql = "
                            SELECT ticket.intStatusID, ticket.intUserID, ticket.intWorkerID, ticket.strReference, ticket.dtmOpen, ticket.strUUID, 
                            ticket_status.strName, us.strFirstName userFirstName, us.strLastName userLastName, wo.strFirstName workerFirstName, wo.strLastName workerLastName
                            FROM ticket
                            LEFT JOIN ticket_status
                            ON ticket.intStatusID = ticket_status.intStatusID
                            LEFT JOIN users us
                            ON ticket.intUserID = us.intUserID
                            LEFT JOIN users wo
                            ON ticket.intWorkerID = wo.intUserID
                            WHERE us.strLastName = '#local.name#'
                            ORDER BY ticket.dtmOpen DESC
                        "
                    )
                }
            }

            return local.qTickets
        }

        // Get tickets query
        local.qTickets = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT ticket.intStatusID, ticket.intUserID, ticket.intWorkerID, ticket.strReference, ticket.dtmOpen, ticket.strUUID, 
                ticket_status.strName, us.strFirstName userFirstName, us.strLastName userLastName, wo.strFirstName workerFirstName, wo.strLastName workerLastName
                FROM ticket
                LEFT JOIN ticket_status
                ON ticket.intStatusID = ticket_status.intStatusID
                LEFT JOIN users us
                ON ticket.intUserID = us.intUserID
                LEFT JOIN users wo
                ON ticket.intWorkerID = wo.intUserID
                WHERE ticket.intStatusID = 1
                ORDER BY ticket.dtmOpen ASC
            "
        )

        return local.qTickets;
    }


    // Function to get all workers 
    public query function getWorker(){

        // Get worker query
        local.qWorker = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT intUserID, strFirstName, strLastName
                FROM users
                WHERE blnSysAdmin = 1
            "
        )

        return local.qWorker;
    }


    // Function to get all status 
    public query function getStatus(){

        // Get status query        
        local.qStatus = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT intStatusID, strName
                FROM ticket_status
            "
        )

        return local.qStatus;
    }


    // Function to check if UUID already exists
    private query function checkUUID(required string ticketUUID){
        
        // Get UUID query
        local.qUuidCheck = queryExecute(
            options = {datasource = application.datasource},
            params = {
                UUID: {type: "varchar", value: arguments.ticketUUID}
            },
            sql = "
                SELECT intTicketID
                FROM ticket
                WHERE strUUID = :UUID
            "
        )

        return local.qUuidCheck;
    }


    // Function to get a ticket for a user
    public query function getTicketUser(required string ticketUUID, required numeric userID){
        
        // Get ticket for user query
        local.qTicket = queryExecute(
            options = {datasource = application.datasource},
            params = {
                UUID: {type: "varchar", value: arguments.ticketUUID},
                userID: {type: "integer", value: arguments.userID}
            },
            sql = "
                SELECT ticket.intTicketID, ticket.intStatusID, ticket.intUserID, ticket.intWorkerID, ticket.strReference, ticket.strDescription, ticket.dtmOpen, ticket.strUUID, 
                ticket_status.strName, us.strFirstName userFirstName, us.strLastName userLastName, wo.strFirstName workerFirstName, wo.strLastName workerLastName
                FROM ticket
                LEFT JOIN ticket_status
                ON ticket.intStatusID = ticket_status.intStatusID
                LEFT JOIN users us
                ON ticket.intUserID = us.intUserID
                LEFT JOIN users wo
                ON ticket.intWorkerID = wo.intUserID
                WHERE ticket.strUUID = :UUID AND ticket.intUserID = :userID
            "
        )

        return local.qTicket;
    }


    // Function to get a ticket for a worker
    public query function getTicketWorker(required string ticketUUID){
        
        // Get ticket for worker query
        local.qTicket = queryExecute(
            options = {datasource = application.datasource},
            params = {
                UUID: {type: "varchar", value: arguments.ticketUUID}
            },
            sql = "
                SELECT ticket.intTicketID, ticket.intStatusID, ticket.intUserID, ticket.intWorkerID, ticket.strReference, ticket.strDescription, ticket.dtmOpen, ticket.strUUID, 
                ticket_status.strName, us.strFirstName userFirstName, us.strLastName userLastName, wo.strFirstName workerFirstName, wo.strLastName workerLastName
                FROM ticket
                LEFT JOIN ticket_status
                ON ticket.intStatusID = ticket_status.intStatusID
                LEFT JOIN users us
                ON ticket.intUserID = us.intUserID
                LEFT JOIN users wo
                ON ticket.intWorkerID = wo.intUserID
                WHERE ticket.strUUID = :UUID
            "
        )

        return local.qTicket;
    }


    // Function to get all answers 
    public query function getAnswers(required numeric ticketID){

        // Get answers query
        local.qAnswers = queryExecute(
            options = {datasource = application.datasource},
            params = {
                ticketID: {type: "integer", value: arguments.ticketID}
            },
            sql = "
                SELECT ticket_answer.intUserID, ticket_answer.strAnswer, ticket_answer.dtmSent, users.strFirstName, users.strLastName
                FROM ticket_answer
                LEFT JOIN users
                ON ticket_answer.intUserID = users.intUserID
                WHERE ticket_answer.intTicketID = :ticketID
            "
        )

        return local.qAnswers;
    }


    // Function to assign a worker
    public struct function updateWorker(required struct formStruct, required string ticketUUID){

        // Initialise return struct 
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;
        
        local.statusID = 2;
        
        // Update ticket query 
        try {
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    ticketUUID: {type: "varchar", value: arguments.ticketUUID},
                    workerID: {type: "integer", value: arguments.formStruct.worker},
                    statusID: {type: "integer", value: local.statusID}
                },
                sql = "
                    UPDATE ticket
                    SET intWorkerID = :workerID, intStatusID = :statusID
                    WHERE strUUID = :ticketUUID
                "
            )
        } catch (any e) {
            logWrite("Ticketsystem", 3, "File: #callStackGet("string", 0 , 1)#, Could not assign worker: #e.message#", false);
            local.argsReturnValue.message = "Could not assign worker!";
            return local.argsReturnValue;
        }

        // configure return struct 
        local.argsReturnValue.message = "Ok";
        local.argsReturnValue.success = true;
        return local.argsReturnValue;
    }

    
    // Function to close a ticket 
    public struct function updateStatus(required struct formStruct, required string ticketUUID){

        // Initialise return struct 
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;
        
        local.statusID = 3;

        // Update ticket query 
        try {
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    ticketUUID: {type: "varchar", value: arguments.ticketUUID},
                    statusID: {type: "integer", value: local.statusID}
                },
                sql = "
                    UPDATE ticket
                    SET intStatusID = :statusID
                    WHERE strUUID = :ticketUUID
                "
            )
        } catch (any e) {
            logWrite("Ticketsystem", 3, "File: #callStackGet("string", 0 , 1)#, Could not close ticket: #e.message#", false);
            local.argsReturnValue.message = "Could not close ticket!";
            return local.argsReturnValue;
        }

        // configure return struct
        local.argsReturnValue.message = "Ok";
        local.argsReturnValue.success = true;
        return local.argsReturnValue;
    }


    // Function to create a answer
    public struct function createAnswer(required struct formStruct, required string ticketUUID, required numeric userID){

        // Initialise return struct
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        // Reset session variables 
        structDelete(session, "answer");

        local.worker = false;

        // Check internal usage 
        if(structKeyExists(arguments.formStruct, "answer_worker")){
            local.worker = true;
        }

        // Validate form values
        if(structKeyExists(arguments.formStruct, "answer") and len(trim(arguments.formStruct.answer))){
            session.answer = trim(left(arguments.formStruct.answer, 1000));
        } else {
            local.argsReturnValue.message = local.worker ? "Enter a answer!" : "#getTrans('txtAnswer')#";
            return local.argsReturnValue;
        }

        // Get ticket by UUID
        local.ticket = getTicketWorker(arguments.ticketUUID);
        
        // Check if belongs to worker or user
        if(local.ticket.intUserID eq arguments.userID or local.ticket.intWorkerID eq arguments.userID){
            local.ticketID = local.ticket.intTicketID;
            local.userID = local.ticket.intUserID;
        } else {
            local.argsReturnValue.message = local.worker ? "Enter a reply to your ticket!" : "#getTrans('txtTicketError')#";
            return local.argsReturnValue;
        }

        // Check ticket status
        if(local.ticket.intStatusID neq 2){
            local.argsReturnValue.message = local.worker ? "The ticket has the wrong status to send a reply!" : "#getTrans('txtAnswerStatusError')#";
            return local.argsReturnValue;
        }

        // Define needed variables 
        local.date = now();

        // Create answer query 
        try {
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    ticketID: {type: "integer", value: local.ticketID},
                    userID: {type: "integer", value: arguments.userID},
                    answer: {type: "varchar", value: session.answer},
                    datetime: {type: "timestamp", value: local.date}
                },
                sql = "
                    INSERT INTO ticket_answer (intTicketID, intUserID, strAnswer, dtmSent)
                    VALUES (:ticketID, :userID, :answer, :datetime)
                "
            )
        } catch (any e){
            logWrite("Ticketsystem", 3, "File: #callStackGet("string", 0 , 1)#, Could not execute query to create answer: #e.message#", false);
            local.argsReturnValue.message = local.worker ? "Could not execute query to create answer!" : "#getTrans('txtCreateAnswerError')#";
            return local.argsReturnValue;
        }

        // Reset session variables 
        structDelete(session, "answer");

        // Send E-Mail
        if(local.worker){

            local.email = sendEmail(arguments.formStruct, arguments.ticketUUID, local.userID, local.worker);

            // Check if email was sent
            if(not local.email.success){
                local.argsReturnValue.message = local.email.message;
                return local.argsReturnValue;
            }
        }
        
        // configure return struct 
        local.argsReturnValue.message = "Ok";
        local.argsReturnValue.success = true;
        return local.argsReturnValue;
    }

    private struct function sendEmail(required struct formStruct, required string ticketUUID, required numeric userID, required boolean worker){
        
        // Initialise return struct
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        // Create link
        local.link = application.mainURL & "/ticket/detail?ticket=" & arguments.ticketUUID;

        // Get user data
        try{
            local.qUser = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    userID: {type: "integer", value: arguments.userID}
                },
                sql = "
                    SELECT strFirstName, strLastName, strEmail, strLanguage
                    FROM users
                    WHERE intUserID = :userID 
                "
            )
        } catch (any e) {
            logWrite("Ticketsystem", 3, "File: #callStackGet("string", 0 , 1)#, Could not execute query to get user data: #e.message#", false);
            local.argsReturnValue.message = arguments.worker ? "Could not execute query to get user data!" : "#getTrans('txtEmailUserError')#";
            return local.argsReturnValue;
        }

        local.language = local.qUser.strLanguage;
        variables.mailTitle = "Ticket: #arguments.ticketUUID#";
        variables.mailType = "html";

        // Choose email content
        if(structKeyExists(arguments.formStruct, "create_user") or structKeyExists(arguments.formStruct, "create_worker")){
            
            cfsavecontent (variable = "variables.mailContent") {
                echo("
                    #getTrans('titHello', local.language)# #local.qUser.strFirstName# #local.qUser.strLastName#<br><br>
                    #getTrans('txtEmailCreateTicketFirst', local.language)#<br>
                    #getTrans('txtEmailCreateTicketSecond', local.language)#<br><br>

                    <a href='#local.link#' style='border-bottom: 10px solid ##337ab7; border-top: 10px solid ##337ab7; border-left: 20px solid ##337ab7; border-right: 20px solid ##337ab7; background-color: ##337ab7; color: ##ffffff; text-decoration: none;' target='_blank'>#local.link#</a><br><br>
                    
                    #getTrans('txtRegards', local.language)#<br>
                    #getTrans('txtYourTeam', local.language)#<br>
                    #application.appOwner#
                ");
            }

        } else {
            
            cfsavecontent (variable = "variables.mailContent") {
                echo("
                    #getTrans('titHello', local.language)# #local.qUser.strFirstName# #local.qUser.strLastName#<br><br>
                    #getTrans('txtEmailAnswerFirst', local.language)#<br>
                    #getTrans('txtEmailAnswerSecond', local.language)#<br><br>

                    <a href='#local.link#' style='border-bottom: 10px solid ##337ab7; border-top: 10px solid ##337ab7; border-left: 20px solid ##337ab7; border-right: 20px solid ##337ab7; background-color: ##337ab7; color: ##ffffff; text-decoration: none;' target='_blank'>#local.link#</a><br><br>
                    
                    #variables.getTrans('txtRegards')#<br>
                    #variables.getTrans('txtYourTeam')#<br>
                    #application.appOwner#
                ");
            }
            
        }
        
        // Send E-Mail
        try{
            mail to="#local.qUser.strEmail#" from="#application.fromEmail#" subject="Ticket: #arguments.ticketUUID#"  type="html" {
                include template="/config.cfm";
                include template="/includes/mail_design.cfm";
            }
        } catch (any e) {
            logWrite("Ticketsystem", 3, "File: #callStackGet("string", 0 , 1)#, Could not send E-Mail: #e.message#", false);
            local.argsReturnValue.message = arguments.worker ? "Could not send E-Mail!" : "#getTrans('txtEmailError')#";
            return local.argsReturnValue;
        }

        // configure return struct 
        local.argsReturnValue.message = "Ok";
        local.argsReturnValue.success = true;
        return local.argsReturnValue;
    }

}