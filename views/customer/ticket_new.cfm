<cfinclude template="/includes/header.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">
                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">#getTrans('txtTicket')#</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">#getTrans('txtTicket')#</li>
                            <li class="breadcrumb-item active">#getTrans('txtNew')#</li>
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

                <!--- Formular for user to create new ticket --->
                <form action="#application.mainURL#/ticket" method="post">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">#getTrans('titSupport')#</h3>
                        </div>
                        <div class="card-body">
                            <div class="mb-2">
                                <label class="form-label">#getTrans('txtReference')#*</label>
                                <input class="form-control" type="text">
                            </div>
                            <div class="mb-2">
                                <label class="form-label">#getTrans('txtDescription')#*</label>
                                <textarea class="form-control" type="text" rows="5"></textarea>
                            </div>
                            <button class="btn btn-primary" type="submit">#getTrans('txtSend')#</button>
                        </div>
                    </div>
                </form>    

            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">

</div>