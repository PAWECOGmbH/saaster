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
                            <li class="breadcrumb-item active">#getTrans('txtCheck')#</li>
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

                <!--- Success message with ticketnumber --->
                <div class="card">
                    <div class="card-body">
                        <div class="d-flex align-items-center">
                            <div class="col-2">
                                <img class="text-img" src="../../dist/img/check.svg" alt="check">
                            </div>
                            <div class="col-10 d-none d-lg-block">
                                <p class="text-check-large">#getTrans('txtCheckFirst')#123#getTrans('txtCheckSecond')#<br>#getTrans('txtCheckThird')#</p>
                            </div>
                            <div class="col-10 d-lg-none">
                                <p class="text-check-small">#getTrans('txtCheckFirst')#123#getTrans('txtCheckSecond')#<br>#getTrans('txtCheckThird')#</p>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">

</div>