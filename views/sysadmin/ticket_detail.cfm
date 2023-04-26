<cfscript>

    /* checks if variable exists otherwise it will be created */
    param name="url.ticket" default="";

    /* Initialise ticket object */
    objTicket = new com.ticket();

    /* Execute function */
    qWorker = objTicket.getWorker();
    qTicket = objTicket.getTicketWorker(url.ticket);

    /* Checks if ticket was found */
    if(qTicket.recordCount eq 1){
        qAnswers = objTicket.getAnswers(qTicket.intTicketID);
    } else {
        getAlert("That is not your ticket!", "warning");
    }

</cfscript>

<cfinclude template="/includes/header.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">
                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Ticketsystem</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/sysadmin/ticketsystem">Ticketsystem</a></li>
                            <li class="breadcrumb-item active">Detail</li>
                        </ol>
                    </div>
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>

        </div>
        <div class="#getLayout.layoutPage#">
            <div class="row">

                <div class="card">

                    <div class="card-header">
                        <h3 class="card-title">Ticketnumber: #qTicket.strUUID#</h3>
                    </div>

                    <div class="card-body">
                        <div class="row">

                            <!--- Ticket problem description --->
                            <div class="col-9">
                                <div class="card">
                                    <div class="card-header">
                                        <p class="no-margin">#qTicket.strReference#</p>
                                    </div>
                                    <div class="card-body">
                                        <p>#qTicket.strDescription#</p>
                                    </div>
                                </div>
                            </div>

                            <!--- Ticket information box --->
                            <div class="col-3">
                                <form action="#application.mainURL#/ticket?ticket=#qTicket.strUUID#" method="post">
                                    <div class="card mb-2">
                                        <div class="card-header">
                                            <h4 class="no-margin">Info</h4>
                                        </div>
                                        <div class="card-body">
                                            <div class="mb-1">
                                                <label class="bold">User:</label>
                                                <span>#qTicket.userFirstName# #qTicket.userLastName#</span>
                                            </div>
                                            <div class="mb-1">
                                                <label class="bold">Created:</label>
                                                <span>#dateTimeFormat(qTicket.dtmOpen, "dd.mm.yyyy kk:nn:ss")#</span>
                                            </div>
                                            <div class="mb-1">
                                                <label class="bold">Status:</label>
                                                <span>#qTicket.strName#</span>
                                            </div>
                                            <div class="mb-1">
                                                <cfif isNumeric(qTicket.intWorkerID)>
                                                    <label class="bold">Worker:</label>
                                                    <span>#qTicket.workerFirstName# #qTicket.workerLastName#</span>
                                                <cfelse>
                                                    <select class="form-select" name="worker" onchange="this.form.submit()">
                                                        <option value="">Chose worker</option>
                                                        <cfloop query="#qWorker#">
                                                            <option value="#intUserID#">#strFirstName# #strLastName#</option>
                                                        </cfloop>
                                                    </select>
                                                </cfif>
                                            </div>
                                        </div>
                                    </div>
                                    <cfif qTicket.intWorkerID eq session.user_id and qTicket.intStatusID eq 2>
                                        <button class="btn btn-primary button-max-width" type="submit" name="close">Close</button>
                                    </cfif>
                                </form>
                            </div>

                        </div>
                    </div>

                    <div class="card-body">
                        <div class="row">
                            
                            <!--- Answer output --->
                            <cfif qTicket.recordCount eq 1>
                                <cfloop query="#qAnswers#">
                                    <div class="col-12 mb-2">
                                        <div class="card">
                                            <div class="card-body">
                                                <p>#qAnswers.strAnswer#</p>
                                                <div class="d-flex justify-content-between">
                                                    <p class="no-margin text-footer">#qAnswers.strFirstName# #qAnswers.strLastName#</p>
                                                    <p class="no-margin text-footer">#dateTimeFormat(qAnswers.dtmSent, "dd.mm.yyyy kk:nn:ss")#</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </cfloop>
                            </cfif>
                        </div>

                        <div class="row">
                            
                            <cfif qTicket.intWorkerID eq session.user_id and qTicket.intStatusID eq 2>
                                <!--- Answer input field --->
                                <div class="col-12">
                                    <form action="#application.mainURL#/ticket?ticket=#qTicket.strUUID#" method="post">
                                        <textarea class="form-control mb-2" rows="5" name="answer" maxlenght="1000"><cfif structKeyExists(session, "answer")>#session.answer#</cfif></textarea>
                                        <button class="btn btn-primary" type="submit" name="answer_worker">Send</button>
                                    </form>
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