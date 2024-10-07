

<cfscript>

    // Security
    if (planGroupID neq 1) {
        location url="#application.mainURL#/dashboard" addtoken=false;
    }

    // Exception handling for sef and user id
    param name="thiscontent.thisID" default=0 type="numeric";
    adID = thiscontent.thisID;

    objAds = new backend.myapp.com.ads();
    qAd = objAds.getAdDetails(adID, 1);

    if (!qAd.recordCount) {
        location url="#application.mainURL#/employer/ads" addtoken=false;
    }

    qApplications = objAds.getApplications(adID, session.customer_id);

</cfscript>

<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">
        <div class="row mb-3">
            <div class="col-md-12 col-lg-12">

                <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                    <h4 class="page-title">Bewerbungen einsehen</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="#application.mainURL#/employer/ads">Inserate</a></li>
                        <li class="breadcrumb-item active">Bewerbungen</li>
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
            <div class="col-lg-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Bewerbungen zur Stelle "#qAd.strJobTitle#"</h3>
                    </div>
                    <div class="card-body">
                        <div class="card">
                            <div class="table-responsive">
                                <table class="table table-vcenter card-table">
                                    <thead>
                                        <tr>
                                            <th class="text-center">Status</th>
                                            <th>Bewerbungsdatum</th>
                                            <th>Name</th>
                                            <th>Adresse</th>
                                            <th class="text-center"></th>
                                            <th class="text-center"></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop query="qApplications">
                                            <tr>
                                                <td class="text-center">
                                                    <cfif qApplications.blnDone eq 0>
                                                        <i class="fas fa-circle text-info" title="offen"></i>
                                                    <cfelse>
                                                        <i class="fas fa-check-circle text-success" title="erledigt"></i>
                                                    </cfif>
                                                </td>
                                                <td>#dateFormat(getTime.utc2local(qApplications.dtmApplieted), "dd.mm.yyyy")# #timeFormat(getTime.utc2local(qApplications.dtmApplieted), "HH:MM")#</td>
                                                <td>#qApplications.strFirstName# #qApplications.strLastName#</td>
                                                <td>#qApplications.strAddress#, #qApplications.strZIP# #qApplications.strCity#</td>
                                                <td class="text-center"><a href="#application.mainURL#/employer/app-detail/#qApplications.intApplicationID#">Bewerbung ansehen</a></td>
                                                <td class="text-center"><a href="##?" onclick="sweetAlert('warning', '#application.mainURL#/handler/ads?del_app=#qApplications.intApplicationID#&job=#adID#', 'Bewerbung löschen', 'Möchten Sie diese Bewerbung wirklich unwiederruflich löschen?', '#getTrans('btnNoCancel')#', '#getTrans('btnYesDelete')#')">Löschen</a></td>
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
    </div>
</div>
</cfoutput>

