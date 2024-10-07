
<cfscript>

    objWorkerProfiles = new backend.myapp.com.admin.worker();

    if (structKeyExists(form, "delete")) {
        structDelete(session, "worker_search_admin");
    }

    param name="session.worker_search_admin" default="";
    param name="session.worker_order_admin" default="";
    param name="url.sort" default="start";
    param name="url.dest" default="up";

    if (structKeyExists(form, "search") and len(trim(form.search))) {
        session.worker_search_admin = form.search;
    }

    switch(url.sort) {
        case "title":
            if (url.dest eq "up") {
                session.worker_order_admin = "ss_ads.strJobTitle";
                dest = "down";
            } else {
                session.worker_order_admin = "ss_ads.strJobTitle DESC";
                dest = "up";
            }
            break;

        case "start":
            if (url.dest eq "up") {
                session.worker_order_admin = "ss_ads.dteStart";
                dest = "down";
            } else {
                session.worker_order_admin = "ss_ads.dteStart DESC";
                dest = "up";
            }
            break;

        case "end":
            if (url.dest eq "up") {
                session.worker_order_admin = "ss_ads.dteEnd";
                dest = "down";
            } else {
                session.worker_order_admin = "ss_ads.dteEnd DESC";
                dest = "up";
            }
            break;

        case "status":
            if (url.dest eq "up") {
                session.worker_order_admin = "status";
                dest = "down";
            } else {
                session.worker_order_admin = "status DESC";
                dest = "up";
            }
            break;

        case "customer":
            if (url.dest eq "up") {
                session.worker_order_admin = "customerName";
                dest = "down";
            } else {
                session.worker_order_admin = "customerName DESC";
                dest = "up";
            }
            break;

        default:

    }

    qWorkerProfiles = objWorkerProfiles.getProfiles(session.worker_order_admin, session.worker_search_admin);
    profilesTotal = objWorkerProfiles.getProfilesTotal();

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
                        <li class="breadcrumb-item active">Jobprofile Fachkräfte</li>
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
                        <h3 class="card-title">Profile Übersicht (#profilesTotal#)</h3>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <form action="" method="post">
                                <label class="form-label">Es werden max. 20 Einträge angezeigt. Bitte die Suche benutzen:</label>
                                <div class="row">
                                    <div class="col-lg-5">
                                        <div class="input-group">
                                            <input type="text" class="form-control me-1" name="search" placeholder="Inseratetitel oder Kunde">
                                            <button class="btn btn-icon me-2" aria-label="Button">
                                                <svg xmlns="http://www.w3.org/2000/svg" class="icon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"></path><path d="M10 10m-7 0a7 7 0 1 0 14 0a7 7 0 1 0 -14 0"></path><path d="M21 21l-6 -6"></path></svg>
                                            </button>
                                            <cfif len(trim(session.worker_search_admin))>
                                                <button class="btn bg-red-lt" name="delete">
                                                    <i class="fas fa-times me-2"></i>
                                                    Suche löschen
                                                </button>
                                            </cfif>
                                        </div>
                                    </div>
                                </div>
                            </form>
                        </div>
                        <div class="card">
                            <div class="table-responsive">
                                <table class="table table-vcenter card-table">
                                    <thead>
                                        <tr>
                                            <th><a href="?sort=title&dest=#dest#">Titel <i class="fas fa-sort"></i></a></th>
                                            <th class="text-center"><a href="?sort=start&dest=#dest#">Start <i class="fas fa-sort"></i></a></th>
                                            <th class="text-center"><a href="?sort=end&dest=#dest#">Ende <i class="fas fa-sort"></i></a></th>
                                            <th><a href="?sort=customer&dest=#dest#">Kunde <i class="fas fa-sort"></i></a></th>
                                            <th class="w-1"></th>
                                            <th class="w-1"></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfif qWorkerProfiles.recordCount>
                                            <cfloop query="qWorkerProfiles">
                                                <tr>
                                                    <td>#qWorkerProfiles.strJobTitle#</td>
                                                    <td class="text-secondary text-center">#dateFormat(getTime.utc2local(qWorkerProfiles.dteStart), "dd.mm.yyyy")#</td>
                                                    <td class="text-secondary text-center">#dateFormat(getTime.utc2local(qWorkerProfiles.dteEnd), "dd.mm.yyyy")#</td>
                                                    <td class="text-secondary"><a href="#application.mainURL#/sysadmin/customers/details/#qWorkerProfiles.intCustomerID#">#qWorkerProfiles.customerName#</a></td>
                                                    <td>
                                                        <cfif len(qWorkerProfiles.mapping) and qWorkerProfiles.blnPublic eq 1>
                                                            <a href="#application.mainURL#/#qWorkerProfiles.mapping#">Ansehen</a>
                                                        <cfelse>
                                                            <a href="##?">Ansehen</a>
                                                        </cfif>
                                                    </td>
                                                    <td>
                                                        <cfif isNumeric(qWorkerProfiles.intInvoiceID)>
                                                            <a href="#application.mainURL#/sysadmin/invoice/edit/#qWorkerProfiles.intInvoiceID#">Rechnung</a>
                                                        </cfif>
                                                    </td>
                                                </tr>
                                            </cfloop>
                                        <cfelse>
                                            <tr><td colspan="100%" class="text-center text-blue"><cfif len(session.worker_search_admin)>Keine Profile gefunden.<cfelse>Es wurden noch keine Profile publiziert.</cfif></td></tr>
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

