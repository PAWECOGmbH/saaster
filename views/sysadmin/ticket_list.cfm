<cfscript>

    // Initialise ticket object 
    objTicket = new com.ticket();

    // Execute function 
    qWorker = objTicket.getWorker();
    qStatus = objTicket.getStatus();
    qTickets = objTicket.getTickets(form);

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
                            <li class="breadcrumb-item active">Ticketsystem</li>
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
                    <div class="card-header justify-content-between">
                        <h3 class="card-title">Overview</h3>
                        <a class="btn btn-primary" href="#application.mainURL#/sysadmin/ticketsystem/new">New Ticket</a>
                    </div>
                    <div class="card-body">
                        
                        <!--- Searchfilter for Tickets --->
                        <form action="#application.mainURL#/sysadmin/ticketsystem" method="post">
                            <div class="row g-2 mb-2">
                                <div class="col-12 col-md-6 col-lg-3">
                                    <select class="form-select" name="date" onchange="this.form.submit()">
                                        <option value="">Created</option>
                                        <option value="1">Latest</option>
                                        <option value="2">Oldest</option>
                                    </select>
                                </div>
                                <div class="col-12 col-md-6 col-lg-3">
                                    <select class="form-select" name="worker" onchange="this.form.submit()">
                                        <option value="">Worker</option>
                                        <cfloop query="#qWorker#">
                                            <option value="#intUserID#">#strFirstName# #strLastName#</option>
                                        </cfloop>
                                    </select>
                                </div>
                                <div class="col-12 col-md-6 col-lg-3">
                                    <select class="form-select" name="status" onchange="this.form.submit()">
                                        <option value="">Status</option>
                                        <cfloop query="#qStatus#">
                                            <option value="#intStatusID#">#strName#</option>
                                        </cfloop>
                                    </select>
                                </div>
                                <div class="col-12 col-md-6 col-lg-3">
                                    <div class="form-selectgroup input-group">
                                        <input class="form-control" type="text" name="text">
                                        <button class="btn" type="submit" name="search">Search</button>
                                    </div>
                                </div>
                            </div>
                        </form>

                        <!--- Ticket tabelle --->
                        <div class="row">
                            <div class="table-responsive">
                                <table class="table table-vcenter table-mobile-md card-table">
                                    <thead>
                                        <tr>
                                            <th width="17%">Number</th>
                                            <th width="25%">Reference</th>
                                            <th width="14%">User</th>
                                            <th width="14%">Created</th>
                                            <th width="14%">Worker</th>
                                            <th width="8%">Status</th>
                                            <th width="8%"></th>
                                        </tr>
                                    </thead>
                                    <tbody class="table-body">
                                        <cfloop query="#qTickets#">
                                            <tr>
                                                <td>#strUUID#</td>
                                                <td>#strReference#</td>
                                                <td>#userFirstName# #userLastName#</td>
                                                <td>#dateTimeFormat(dtmOpen, "dd.mm.yyyy kk:nn:ss")#</td>
                                                <td>#workerFirstName# #workerLastName#</td>
                                                <td>#strName#</td>
                                                <td>
                                                    <a href="#application.mainURL#/sysadmin/ticketsystem/detail?ticket=#strUUID#" class="btn">Open</a>
                                                </td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </div>

                </div>

            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">

</div>