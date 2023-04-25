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
                            <li class="breadcrumb-item active">New</li>
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

                <!--- Formular for worker to create new ticket --->
                <form action="#application.mainURL#/ticket" method="post">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Support</h3>
                        </div>
                        <div class="card-body">
                            <div class="mb-2">
                                <label class="form-label">E-Mail*</label>
                                <input class="form-control" type="email" name="email" maxlenght="255" <cfif structKeyExists(session, "email")>value="#session.email#"</cfif> required>
                            </div>
                            <div class="mb-2">
                                <label class="form-label">Reference*</label>
                                <input class="form-control" type="text" name="reference" maxlenght="255" <cfif structKeyExists(session, "reference")> value="#session.reference#"</cfif> required>
                            </div>
                            <div class="mb-2">
                                <label class="form-label">Description*</label>
                                <textarea class="form-control" type="text" rows="5" name="description" maxlenght="2000" required><cfif structKeyExists(session, "description")>#session.description#</cfif></textarea>
                            </div>
                            <button class="btn btn-primary" type="submit" name="create_worker">Send</button>
                        </div>
                    </div>
                </form>   

            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">

</div>