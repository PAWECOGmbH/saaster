<cfscript>

    // Security
    if (planGroupID neq 1) {
        location url="#application.mainURL#/dashboard" addtoken=false;
    }

    objAds = new backend.myapp.com.ads();
    qAds = objAds.getAds(session.customer_id, "AND blnArchived = 1 AND blnAdTypeID = 1");

</cfscript>

<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">

        <div class="row mb-3">
            <div class="col-md-12 col-lg-12">

                <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                    <h4 class="page-title">Inserateverwaltung</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="#application.mainURL#/employer/ads">Inserate</a></li>
                        <li class="breadcrumb-item active">Inserate Archiv</li>
                    </ol>
                </div>
                <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                    <a href="#application.mainURL#/employer/ads/new" class="btn btn-primary">
                        <i class="fas fa-plus pe-3"></i> Inserat hinzufügen
                    </a>
                </div>
            </div>
        </div>
        <cfif structKeyExists(session, "alert")>
            #session.alert#
        </cfif>
    </div>
    <div class="#getLayout.layoutPage#">
        <div class="row">
            <div class="col-lg-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Inserate Archiv</h3>
                    </div>
                    <div class="card-body">
                        <div class="card">
                            <div class="table-responsive">
                                <table class="table table-vcenter card-table">
                                    <thead>
                                        <tr>
                                            <th>Titel</th>
                                            <th class="text-center">Start</th>
                                            <th class="text-center">Ende</th>
                                            <th class="text-center">Status</th>
                                            <th class="text-center">Bewerbungen</th>
                                            <th class="w-1"></th>
                                            <th class="w-1"></th>
                                            <th class="w-1"></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfif qAds.recordCount>
                                            <cfloop query="qAds">
                                                <tr>
                                                    <td>#qAds.strJobTitle#</td>
                                                    <td class="text-secondary text-center">#dateFormat(getTime.utc2local(qAds.dteStart), "dd.mm.yyyy")#</td>
                                                    <td class="text-secondary text-center">#dateFormat(getTime.utc2local(qAds.dteEnd), "dd.mm.yyyy")#</td>
                                                    <td class="text-secondary text-center">Archiviert</td>
                                                    <td class="text-secondary text-center">#qAds.applications#</td>
                                                    <td><a href="#application.mainURL#/handler/ads?copy=#qAds.intAdID#">Kopieren</a></td>
                                                    <td><a href="##?" onclick="sweetAlert('warning', '#application.mainURL#/handler/ads?del=#qAds.intAdID#&archive', 'Inserat löschen', 'Es werden alle Daten des Inserates gelöscht, auch allfällige Bewerbungen. Möchten Sie wirklich löschen?', '#getTrans('btnNoCancel')#', '#getTrans('btnYesDelete')#')">Löschen</a></td>
                                                </tr>
                                            </cfloop>
                                        <cfelse>
                                            <tr><td colspan="100%" class="text-center text-blue">Es wurden noch keine Inserate archiviert.</td></tr>
                                        </cfif>
                                    </tbody>
                                </table>
                            </div>
                            </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</cfoutput>

