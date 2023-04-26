component displayname="ticket" output="false" {


    /* Initialise language object with getTrans function */
    local.objLanguage = new com.language();
    local.getTrans = local.objLanguage.getTrans;


    /* Function to create ticket */
    public struct function createTicket(required struct formStruct){

        /* Initialise return struct */
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        /* Reset session variables */
        structDelete(session, "reference");
        structDelete(session, "description");
        structDelete(session, "email");

        local.worker = false;

        /* Check internal usage */
        if(structKeyExists(arguments.formStruct, "create_worker")){
            local.worker = true;
        }

        /* Validate form values */
        if(structKeyExists(arguments.formStruct, "reference") and len(trim(arguments.formStruct.reference))){
            session.reference = trim(left(arguments.formStruct.reference, 255));
        } else {
            local.argsReturnValue.message = local.worker ? "Enter a reference!" : "#local.getTrans('txtReferenceError')#";
        }

        if(structKeyExists(arguments.formStruct, "description") and len(trim(arguments.formStruct.description))){
            session.description = trim(left(arguments.formStruct.description, 2000));
        } else {

            if(len(trim(local.argsReturnValue.message))){
                local.argsReturnValue.message = local.worker ? "Enter a description and reference!" : "#local.getTrans('txtDescriptionReferenceError')#";
            } else {
                local.argsReturnValue.message = local.worker ? "Enter a description!" : "#local.getTrans('txtDescriptionError')#";
            }

        }

        /* Search for user by email */
        if(structKeyExists(arguments.formStruct, "create_worker")){
            if(structKeyExists(arguments.formStruct, "email") and len(trim(arguments.formStruct.email))){
                
                /* Get user query */
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
                    local.argsReturnValue.message = "Could not execute query to find user!";
                    return local.argsReturnValue;
                }

                /* Check if user was found */
                if(local.qUser.recordCount eq 1){
                    session.email = arguments.formStruct.email;
                    local.user = local.qUser.intUserID;
                } else {
                    local.argsReturnValue.message = "E-mail doesn't exists!";
                    return local.argsReturnValue;
                }

            } else {
                local.argsReturnValue.message = "Enter a E-Mail!";
                return local.argsReturnValue;
            }
        }

        /* Get ID from user */
        if(structKeyExists(arguments.formStruct, "create_user")){
            local.user = session.user_id;
        }

        /* check cancellation */
        if(not structKeyExists(session, "reference") or not structKeyExists(session, "description")){
            return local.argsReturnValue;
        }

        /* Define needed variables */
        local.status = 1;
        local.date = now();
        local.uuid = listLast(createUUID(), "-");

        local.check = checkUUID(local.uuid);
        
        /* Check if uuid already exists */
        while(local.check.recordCount neq 0){
            local.uuid = listLast(createUUID(), "-");
            local.check = checkUUID(local.uuid);
        }

        /* Create ticket query */
        try {
            local.qCreateTicket = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    reference: {type: "varchar", value: session.reference},
                    description: {type: "varchar", value: session.description},
                    userID: {type: "integer", value: local.user},
                    statusID: {type: "integer", value: local.status},
                    UUID: {type: "varchar", value: local.uuid},
                    datetime: {type: "timestamp", value: local.date}
                },
                sql = "
                    INSERT INTO ticket (intUserID, intStatusID, strReference, strDescription, dtmOpen, strUUID)
                    VALUES (:userID, :statusID, :reference, :description, :datetime, :UUID)
                "
            )
        } catch (any e) {
            local.argsReturnValue.message = local.worker ? "Could not execute query to create ticket!" : "#local.getTrans('txtCreateTicketError')#";
            return local.argsReturnValue;
        }

        /* Reset session variables */
        structDelete(session, "reference");
        structDelete(session, "description");
        structDelete(session, "email");
        
        /* configure return struct */
        local.argsReturnValue['uuid'] = local.uuid;
        local.argsReturnValue['message'] = "Ok";
        local.argsReturnValue['success'] = true;
        return local.argsReturnValue;
    }


    /* Function to get all tickets */
    public query function getTickets(struct formStruct){

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
                ORDER BY ticket.dtmOpen DESC
            "
        )

        return local.qTickets;
    }


    /* Function to get all workers */
    public query function getWorker(){

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


    /* Function to get all status */
    public query function getStatus(){

        local.qStatus = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT intStatusID, strName
                FROM ticket_status
            "
        )

        return local.qStatus;
    }


    /* Function to check if UUID already exists */
    private query function checkUUID(required string ticketUUID){
        
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


    /* Function to get a ticket from a user */
    public query function getTicketUser(required string ticketUUID, required numeric userID){
        
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


    /* Function to get a ticket from a worker */
    public query function getTicketWorker(required string ticketUUID){
        
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


    /* Function to get all answers */
    public query function getAnswers(required numeric ticketID){

        local.qAnswer = queryExecute(
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

        return local.qAnswer;
    }


    /* Function to assign a worker */
    public struct function updateWorker(required struct formStruct, required string ticketUUID){

        /* Initialise return struct */
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;
        
        local.statusID = 2;
        
        /* Update ticket query */
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
            local.argsReturnValue.message = "Could not assign worker!";
            return local.argsReturnValue;
        }

        /* configure return struct */
        local.argsReturnValue.message = "Ok";
        local.argsReturnValue.success = true;
        return local.argsReturnValue;
    }

    
    /* Function to close a ticket */
    public struct function closeTicket(required struct formStruct, required string ticketUUID){

        /* Initialise return struct */
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;
        
        local.statusID = 3;

        /* Update ticket query */
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
            local.argsReturnValue.message = "Could not close ticket!";
            return local.argsReturnValue;
        }

        /* configure return struct */
        local.argsReturnValue.message = "Ok";
        local.argsReturnValue.success = true;
        return local.argsReturnValue;
    }


    /* Function to create a answer */
    public struct function createAnswer(required struct formStruct, required string ticketUUID, required numeric userID){

        /* Initialise return struct */
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        /* Reset session variables */
        structDelete(session, "answer");

        local.worker = false;

        /* Check internal usage */
        if(structKeyExists(arguments.formStruct, "answer_worker")){
            local.worker = true;
        }

        /* Validate form values */
        if(structKeyExists(arguments.formStruct, "answer") and len(trim(arguments.formStruct.answer))){
            session.answer = trim(left(arguments.formStruct.answer, 1000));
        } else {
            local.argsReturnValue.message = local.worker ? "Enter a answer!" : "#getTrans('txtAnswer')#";
            return local.argsReturnValue;
        }

        /* Get ticket by UUID */
        local.ticket = getTicketWorker(arguments.ticketUUID);
        
        /* Check if belongs to worker or user */
        if(local.ticket.intUserID eq arguments.userID or local.ticket.intWorkerID eq arguments.userID){
            local.ticketID = local.ticket.intTicketID;
        } else {
            local.argsReturnValue.message = local.worker ? "Enter a reply to your ticket!" : "#getTrans('txtTicketError')#";
            return local.argsReturnValue;
        }

        /* Define needed variables */
        local.date = now();

        /* Create answer query */
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
            local.argsReturnValue.message = local.worker ? "Could not execute query to create answer!" : "#getTrans('txtCreateAnswerError')#";
            return local.argsReturnValue;
        }

        /* Reset session variables */
        structDelete(session, "answer");

        /* configure return struct */
        local.argsReturnValue.message = "Ok";
        local.argsReturnValue.success = true;
        return local.argsReturnValue;
    }

}