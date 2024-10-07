
<cfscript>

    objAds = new backend.myapp.com.admin.ads();

    if (structKeyExists(form, "delete")) {
        structDelete(session, "ad_search_admin");
    }

    param name="session.ad_search_admin" default="";
    param name="session.ad_order_admin" default="";
    param name="url.sort" default="start";
    param name="url.dest" default="up";
    param name="session.status" default="0";

    if (structKeyExists(form, "search") and len(trim(form.search))) {
        session.ad_search_admin = form.search;
    }

    if (structKeyExists(form, "status")) {
        session.status = form.status;
    }

    switch(url.sort) {
        case "number":
            if (url.dest eq "up") {
                session.ad_order_admin = "ss_ads.intAdID";
                dest = "down";
            } else {
                session.ad_order_admin = "ss_ads.intAdID DESC";
                dest = "up";
            }
            break;

        case "title":
            if (url.dest eq "up") {
                session.ad_order_admin = "ss_ads.strJobTitle";
                dest = "down";
            } else {
                session.ad_order_admin = "ss_ads.strJobTitle DESC";
                dest = "up";
            }
            break;

        case "start":
            if (url.dest eq "up") {
                session.ad_order_admin = "ss_ads.dteStart";
                dest = "down";
            } else {
                session.ad_order_admin = "ss_ads.dteStart DESC";
                dest = "up";
            }
            break;

        case "end":
            if (url.dest eq "up") {
                session.ad_order_admin = "ss_ads.dteEnd";
                dest = "down";
            } else {
                session.ad_order_admin = "ss_ads.dteEnd DESC";
                dest = "up";
            }
            break;

        case "status":
            if (url.dest eq "up") {
                session.ad_order_admin = "status";
                dest = "down";
            } else {
                session.ad_order_admin = "status DESC";
                dest = "up";
            }
            break;

        case "customer":
            if (url.dest eq "up") {
                session.ad_order_admin = "customerName";
                dest = "down";
            } else {
                session.ad_order_admin = "customerName DESC";
                dest = "up";
            }
            break;

        default:
            session.ad_order_admin = "ss_ads.intAdID DESC";
            dest = "up";

    }

    qAds = objAds.getAds(session.ad_order_admin, session.ad_search_admin, session.status);
    adsTotal = objAds.getTotalAds(session.status);

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
                        <h3 class="card-title">Inserate Übersicht (#qAds.recordCount#)</h3>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <form method="post">
                                <label class="form-label">Es werden max. 20 Einträge angezeigt. Bitte die Suche benutzen:</label>
                                <div class="row">
                                    <div class="col-lg-4">
                                        <div class="input-group">
                                            <input type="text" class="form-control me-1" name="search" placeholder="Inseratnummer, Inseratetitel oder Kunde">
                                            <button class="btn btn-icon me-2" aria-label="Button">
                                                <svg xmlns="http://www.w3.org/2000/svg" class="icon" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"></path><path d="M10 10m-7 0a7 7 0 1 0 14 0a7 7 0 1 0 -14 0"></path><path d="M21 21l-6 -6"></path></svg>
                                            </button>
                                            <cfif len(trim(session.ad_search_admin))>
                                                <button class="btn bg-red-lt" name="delete">
                                                    <i class="fas fa-times me-2"></i>
                                                    Suche löschen
                                                </button>
                                            </cfif>
                                        </div>
                                    </div>
                                    <div class="col-lg-3 ms-auto">
                                        <select class="form-select" name="status" onchange="this.form.submit()">
                                            <option value="0" <cfif session.status eq 0>selected</cfif>>Alle anzeigen</option>
                                            <option value="1" <cfif session.status eq 1>selected</cfif>>Nur aktive anzeigen</option>
                                            <option value="2" <cfif session.status eq 2>selected</cfif>>Nur deaktivierte anzeigen</option>
                                            <option value="3" <cfif session.status eq 3>selected</cfif>>Nur pausierte anzeigen</option>
                                            <option value="4" <cfif session.status eq 4>selected</cfif>>Nur beendete anzeigen</option>
                                            <option value="5" <cfif session.status eq 5>selected</cfif>>Nur archivierte anzeigen</option>
                                        </select>
                                    </div>
                                </div>
                            </form>
                        </div>
                        <div class="card">
                            <div class="table-responsive">
                                <table class="table table-vcenter card-table">
                                    <thead>
                                        <tr>
                                            <th class="text-center" class="w-1"><a href="?sort=number&dest=#dest#">Nummer <i class="fas fa-sort"></i></a></th>
                                            <th><a href="?sort=title&dest=#dest#">Titel <i class="fas fa-sort"></i></a></th>
                                            <th class="text-center"><a href="?sort=start&dest=#dest#">Start <i class="fas fa-sort"></i></a></th>
                                            <th class="text-center"><a href="?sort=end&dest=#dest#">Ende <i class="fas fa-sort"></i></a></th>
                                            <th class="text-center"><a href="?sort=status&dest=#dest#">Status <i class="fas fa-sort"></i></a></th>
                                            <th><a href="?sort=customer&dest=#dest#">Kunde <i class="fas fa-sort"></i></a></th>
                                            <th class="w-1"></th>
                                            <th class="w-1"></th>
                                            <th class="w-1"></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfif qAds.recordCount>
                                            <cfloop query="qAds">
                                                <tr>
                                                    <td class="text-center">#qAds.intAdID#</td>
                                                    <td>#qAds.strJobTitle#</td>
                                                    <td class="text-center">
                                                        <cfif isDate(qAds.dteStart)>
                                                            #dateFormat(getTime.utc2local(qAds.dteStart), "dd.mm.yyyy")#
                                                        <cfelse>
                                                            -
                                                        </cfif>
                                                    </td>
                                                    <cfif qAds.blnActive eq 1>
                                                        <td class="text-center" id="date-field-#qAds.intAdID#" ondblclick="editDateField(#qAds.intAdID#)"><span style="border-bottom: 2px dotted black;">#dateFormat(getTime.utc2local(qAds.dteEnd), "dd.mm.yyyy")#</span></td>
                                                        <form id="date-form-#qAds.intAdID#" action="#application.mainURL#/admin/handler/ads?id=#qAds.intAdID#" method="post" style="display:none;">
                                                            <input type="hidden" name="updatedDate" id="hidden-date-#qAds.intAdID#">
                                                        </form>
                                                    <cfelse>
                                                        <td class="text-center">
                                                            <cfif isDate(qAds.dteEnd)>
                                                                #dateFormat(getTime.utc2local(qAds.dteEnd), "dd.mm.yyyy")#
                                                            <cfelse>
                                                                -
                                                            </cfif>
                                                        </td>
                                                    </cfif>
                                                    <td class="text-center text-#qAds.class#">#qAds.status#</td>
                                                    <td class="text-secondary"><a href="#application.mainURL#/sysadmin/customers/details/#qAds.intCustomerID#">#qAds.customerName#</a></td>
                                                    <td>
                                                        <cfif len(qAds.mapping)>
                                                            <a href="#application.mainURL#/#qAds.mapping#?backend" target="_blank">Ansehen</a>
                                                        </cfif>
                                                    </td>
                                                    <cfif qAds.blnActive eq 1>
                                                        <cfif qAds.blnArchived eq 0>
                                                            <td><a href="##?" onclick="sweetAlert('info', '#application.mainURL#/admin/handler/ads?deactivate=#qAds.intAdID#', 'Inserat deaktivieren', 'Soll dieses Inserat deaktiviert werden? Der Kunde selbst kann das Inserat nicht mehr reaktivieren!', 'Abbrechen', 'Jetzt deaktivieren')">Deaktivieren</a></td>
                                                        <cfelse>
                                                            <td>&nbsp;</td>
                                                        </cfif>
                                                    <cfelse>
                                                        <cfif isDate(qAds.dteStart)>
                                                            <td><a href="#application.mainURL#/admin/handler/ads?activate=#qAds.intAdID#">Aktivieren</a></td>
                                                        </cfif>
                                                    </cfif>
                                                    <td>
                                                        <cfif isNumeric(qAds.intInvoiceID)>
                                                            <a href="#application.mainURL#/sysadmin/invoice/edit/#qAds.intInvoiceID#">Rechnung</a>
                                                        </cfif>
                                                    </td>
                                                </tr>
                                            </cfloop>

                                        <cfelse>
                                            <tr><td colspan="100%" class="text-center text-info">Keine Inserate gefunden!</td></tr>
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