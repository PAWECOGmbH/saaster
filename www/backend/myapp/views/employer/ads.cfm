
<cfscript>

    // Security
    if (planGroupID neq 1) {
        location url="#application.mainURL#/dashboard" addtoken=false;
    }

    objAds = new backend.myapp.com.ads();
    qAds = objAds.getAds(session.customer_id, "AND blnArchived = 0 AND blnAdTypeID = 1");

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
                        <li class="breadcrumb-item active">Inserate</li>
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
                        <h3 class="card-title">Inserate Übersicht</h3>
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
                                                    <td class="text-secondary text-center">
                                                        <cfif len(qAds.dteStart)>
                                                            #dateFormat(getTime.utc2local(qAds.dteStart), "dd.mm.yyyy")#
                                                        <cfelse>
                                                            -
                                                        </cfif>
                                                    </td>
                                                    <td class="text-secondary text-center">
                                                        <cfif len(qAds.dteEnd)>
                                                            #dateFormat(getTime.utc2local(qAds.dteEnd), "dd.mm.yyyy")#
                                                        <cfelse>
                                                            -
                                                        </cfif>
                                                    </td>
                                                    <td class="text-center text-#qAds.class#">#qAds.status#</td>
                                                    <td class="text-secondary text-center">
                                                        <cfif qAds.applications gt 0>
                                                            <a href="#application.mainURL#/employer/applications/#qAds.intAdID#">#qAds.applications#</a>
                                                        <cfelse>
                                                            #qAds.applications#
                                                        </cfif>
                                                    </td>
                                                    <cfif qAds.status eq "Deaktiviert">
                                                        <td colspan="3"><em>Bitte melden Sie sich beim Support!</em></td>
                                                    <cfelse>
                                                        <cfif qAds.status neq "Beendet">
                                                            <td><a href="#application.mainURL#/employer/ads/edit/#qAds.intAdID#">Bearbeiten</a></td>
                                                        </cfif>
                                                        <cfif qAds.blnActive eq 1>
                                                            <cfif qAds.status eq "Beendet">
                                                                <td><a href="#application.mainURL#/handler/ads?copy=#qAds.intAdID#">Kopieren</a></td>
                                                                <td><a href="#application.mainURL#/handler/ads?archive=#qAds.intAdID#">Archivieren</a></td>
                                                            <cfelse>
                                                                <cfif qAds.blnPaused eq 1>
                                                                    <td><a href="##?" onclick="sweetAlert('info', '#application.mainURL#/handler/ads?pauseback=#qAds.intAdID#', 'Inserat reaktivieren', 'Pause vorbei und Inserat reaktivieren?', 'Abbrechen', 'Jetzt reaktivieren')">Reaktivieren</a></td>
                                                                <cfelse>
                                                                    <td><a href="##?" onclick="sweetAlert('warning', '#application.mainURL#/handler/ads?pause=#qAds.intAdID#', 'Inserat pausieren', 'Sie können das Inserat pausieren, um es in der Suche auszublenden. Bitte beachten Sie, dass dies keine Auswirkungen auf die Laufzeit hat und die Zeit weiterläuft!', 'Abbrechen', 'Jetzt pausieren')">Pausieren</a></td>
                                                                </cfif>
                                                                <td><a href="##?" onclick="sweetAlert('warning', '#application.mainURL#/handler/ads?end=#qAds.intAdID#', 'Inserat beenden', 'Wenn Sie das Inserat beenden, geht die übrige Laufzeit verloren! Möchten Sie das Inserat wirklich beenden?', 'Abbrechen', 'Jetzt beenden')">Beenden</a></td>
                                                            </cfif>
                                                        <cfelse>
                                                            <td><a href="##?" onclick="sweetAlert('info', '#application.mainURL#/handler/ads?activate=#qAds.intAdID#', 'Inserat aktivieren', 'Das Inserat kostet CHF #getAdCost#.- und dauert #getAdDuring# Tage. Sie werden nach der Aktivierung zur Rechnung geleitet, welche Sie bitte innert 10 Tagen begleichen mögen.', 'Abbrechen', 'Jetzt aktivieren')">Aktivieren</a></td>
                                                            <td><a href="##?" onclick="sweetAlert('warning', '#application.mainURL#/handler/ads?del=#qAds.intAdID#', 'Inserat löschen', 'Möchten Sie dieses Inserat wirklich unwiederruflich löschen?', '#getTrans('btnNoCancel')#', '#getTrans('btnYesDelete')#')">Löschen</a></td>
                                                        </cfif>
                                                    </cfif>
                                                </tr>
                                            </cfloop>
                                        <cfelse>
                                            <tr><td colspan="100%" class="text-center text-blue">Sie haben noch keine Inserate erfasst.</td></tr>
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

