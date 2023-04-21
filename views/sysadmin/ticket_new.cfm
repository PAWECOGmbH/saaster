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


            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">

</div>