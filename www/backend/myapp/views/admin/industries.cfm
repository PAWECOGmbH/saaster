
<cfscript>
    objIndustries = new backend.myapp.com.admin.industries();
    qIndustries = objIndustries.getIndustries(0);
    qProposals = objIndustries.getIndustries(1);
</cfscript>


<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Branchenverwaltung</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">Portaleinstellungen</li>
                            <li class="breadcrumb-item active">Branchen</li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
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
                            <h3 class="card-title">Branchen verwalten</h3>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-lg-6">
                                    <div class="table-responsive">
                                        <table class="table table-vcenter">
                                            <thead>
                                                <tr>
                                                    <th>Branche</th>
                                                    <th class="text-center">Aktiv</th>
                                                    <th></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <form action="#application.mainURL#/admin/handler/industries" method="post">
                                                    <tr>
                                                        <td><input type="text" class="form-control" name="industry_new" placeholder="Neue Branche hinzufügen" required="true" maxlength="50" /></td>
                                                        <td class="text-center"><input type="checkbox" class="form-check-input" name="active" checked></td>
                                                        <td><input type="submit" class="btn btn-green" value="Hinuzfügen"></td>
                                                    </tr>
                                                </form>
                                                <cfloop query="qIndustries">
                                                    <form action="#application.mainURL#/admin/handler/industries" method="post">
                                                        <input type="hidden" name="industry_edit" value="#qIndustries.intIndustryID#">
                                                        <tr>
                                                            <td><input type="text" class="form-control" name="industry" value="#HTMLEditFormat(qIndustries.strName)#" required="true" maxlength="50" /></td>
                                                            <td class="text-center"><input type="checkbox" class="form-check-input" name="active" <cfif qIndustries.blnActive>checked</cfif>></td>
                                                            <td>
                                                                <div class="btn-list">
                                                                    <button type="submit" name="save" class="btn btn-success">
                                                                        <i class="fas fa-check"></i>
                                                                    </button>
                                                                    <button type="submit" name="delete" class="btn btn-danger" onclick="return confirm('Wirklich löschen?')">
                                                                        <i class="fas fa-trash-alt"></i>
                                                                    </button>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </form>
                                                </cfloop>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <div class="col-lg-6">
                                    <div class="table-responsive">
                                        <table class="table table-vcenter">
                                            <thead>
                                                <tr>
                                                    <th width="60%">Vorgeschlagen von Kunden</th>
                                                    <th width="20%"></th>
                                                    <th width="20%"></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfif qProposals.recordCount>
                                                    <cfloop query="qProposals">
                                                        <form action="#application.mainURL#/admin/handler/industries" method="post">
                                                            <input type="hidden" name="proposal" value="#qProposals.intIndustryID#">
                                                            <tr>
                                                                <td>#qProposals.strName#</td>
                                                                <td><input type="submit" name="accept" class="btn btn-outline-success" value="Übernehmen"></td>
                                                                <td><input type="submit" name="decline" class="btn btn-outline-warning" value="Ablehnen" onclick="return confirm('Soll die Branche abgelehnt und gelöscht werden?')"></td>
                                                            </tr>
                                                        </form>
                                                    </cfloop>
                                                <cfelse>
                                                    <tr><td colspan="3" class="text-secondary pt-3 pb-3">Keine Vorschläge vorhanden.</td></tr>
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

</div>



