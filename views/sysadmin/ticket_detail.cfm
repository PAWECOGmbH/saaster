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
                        <h3 class="card-title">Ticketnumber:</h3>
                    </div>

                    <div class="card-body">
                        <div class="row">

                            <!--- Ticket problem description --->
                            <div class="col-9">
                                <div class="card">
                                    <div class="card-header">
                                        <p class="no-margin">Lorem ipsum dolor sit amet, consetetur sadipscing elitr</p>
                                    </div>
                                    <div class="card-body">
                                        <p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut 
                                        labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo 
                                        dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. 
                                        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore 
                                        et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. 
                                        Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, 
                                        consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, 
                                        sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, 
                                        no sea takimata sanctus est Lorem ipsum dolor sit amet. 
                                        Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, 
                                        vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit 
                                        praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, 
                                        consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. 
                                        Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea 
                                        commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, 
                                        vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent 
                                        luptatum zzril delenit augue duis dolore te feugait nulla facilisi.</p>
                                    </div>
                                </div>
                            </div>

                            <!--- Ticket information box --->
                            <div class="col-3">
                                <form action="#application.mainURL#/ticket" method="post">
                                    <div class="card mb-2">
                                        <div class="card-header">
                                            <h4 class="no-margin">Info</h4>
                                        </div>
                                        <div class="card-body">
                                            <div class="mb-1">
                                                <label class="bold">User:</label>
                                                <span>Hans Meier</span>
                                            </div>
                                            <div class="mb-1">
                                                <label class="bold">Created:</label>
                                                <span>22.04.2023</span>
                                            </div>
                                            <div class="mb-1">
                                                <label class="bold">Status:</label>
                                                <span>open</span>
                                            </div>
                                            <div class="mb-1">
                                                <label class="bold">Worker:</label>
                                                <span>Peter Pan</span>
                                            </div>
                                        </div>
                                    </div>
                                    <button class="btn btn-primary button-max-width" type="submit">Close</button>
                                </form>
                            </div>

                        </div>
                    </div>

                    <div class="card-body">
                        <div class="row mb-2">
                            
                            <!--- Answer output --->
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-body">
                                        <p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et 
                                        dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores.</p>
                                        <div class="d-flex justify-content-between">
                                            <p class="no-margin text-footer">Hans Meier</p>
                                            <p class="no-margin text-footer">22.04.2023</p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </div>

                        <div class="row">
                            
                            <!--- Answer input field --->
                            <div class="col-12">
                                <form action="#application.mainURL#/ticket" method="post">
                                    <textarea class="form-control mb-2" rows="5"></textarea>
                                    <button class="btn btn-primary" type="submit">Send</button>
                                </form>
                            </div>

                        </div>
                    </div>
                    
                </div>

            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">

</div>