component displayname="ticket" output="false" {

    public struct function createTicket(required struct formStruct){

        /* Initialise return struct */
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        local.worker = false;

        /* Initialise language object with getTrans function */
        local.objLanguage = new com.language();
        local.getTrans = local.objLanguage.getTrans;

        /* Reset session variables */
        structDelete(session, "reference");
        structDelete(session, "description");
        structDelete(session, "email");

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
                
                try {

                    local.qUser = queryExecute (
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
                    
                    local.argsReturnValue.message = "Could not execute query qUser!";
                    return local.argsReturnValue;
                }

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

        /* Define variables */
        local.status = 1;
        local.uuid = listLast(createUUID(), "-");
        local.date = now();

        /* Check if uuid already exists */
        try {

            local.qUuidCheck = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    uuid: {type: "varchar", value: local.uuid}
                },
                sql = "
                    SELECT intTicketID
                    FROM ticket
                    WHERE strUUID = :uuid
                "
            )
        } catch(any e) {
            
            local.argsReturnValue.message = local.worker ? "Could not execute query qUuidCheck!" : "#local.getTrans('txtCheckUuidError')#";
            return local.argsReturnValue;
        }

        if(local.qUuidCheck.recordCount neq 0){
            local.uuid = listLast(createUUID(), "-");
        }

        /* Create ticket query */
        try {

            local.qCreateTicket = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    reference: {type: "varchar", value: session.reference},
                    description: {type: "varchar", value: session.description},
                    user: {type: "integer", value: local.user},
                    status: {type: "integer", value: local.status},
                    uuid: {type: "varchar", value: local.uuid},
                    datetime: {type: "timestamp", value: local.date}
                },
                sql = "
                    INSERT INTO ticket (intUserID, intStatusID, strReference, strDescription, dtmOpen, strUUID)
                    VALUES (:user, :status, :reference, :description, :datetime, :uuid)
                "
            )
        } catch (any e) {

            local.argsReturnValue.message = local.worker ? "Could not execute query qCreateTicket!" : "#local.getTrans('txtCreateTicketError')#";
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

    public query function getTickets(struct formStruct){

        qTicket = queryExecute (
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

        return qTicket;

    }


}