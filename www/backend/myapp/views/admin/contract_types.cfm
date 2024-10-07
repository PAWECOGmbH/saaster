
<cfscript>
    objContractTypes = new backend.myapp.com.admin.contract_types();
    arrayContractTypes = objContractTypes.getContractTypes();
</cfscript>


<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Vertragsarten</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">Portaleinstellungen</li>
                            <li class="breadcrumb-item active">Vertragsarten</li>
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
                            <h3 class="card-title">Vertragsarten verwalten</h3>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-lg-6">
                                    <div class="table-responsive">
                                        <table class="table table-vcenter">
                                            <thead>
                                                <tr>
                                                    <th>Vertragsart</th>
                                                    <th class="text-center">Aktiv</th>
                                                    <th></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <form action="#application.mainURL#/admin/handler/contract-types" method="post">
                                                    <tr>
                                                        <td><input type="text" class="form-control" name="contract_new" placeholder="Neue Vertragsart hinzufügen" required="true" maxlength="50" /></td>
                                                        <td class="text-center"><input type="checkbox" class="form-check-input" name="active" checked></td>
                                                        <td><input type="submit" class="btn btn-green" value="Hinuzfügen"></td>
                                                    </tr>
                                                </form>
                                                <cfif arrayLen(arrayContractTypes)>
                                                    <cfloop array="#arrayContractTypes#" index="i">
                                                        <form action="#application.mainURL#/admin/handler/contract-types" method="post">
                                                            <input type="hidden" name="contract_edit" value="#i.id#">
                                                            <tr>
                                                                <td><input type="text" class="form-control" name="contract" value="#HTMLEditFormat(i.name)#" required="true" maxlength="50" /></td>
                                                                <td class="text-center"><input type="checkbox" class="form-check-input" name="active" <cfif i.active>checked</cfif>></td>
                                                                <td>
                                                                    <div class="btn-list">
                                                                        <button type="submit" name="save" class="btn btn-success">
                                                                            <i class="fas fa-check"></i>
                                                                        </button>
                                                                        <cfif i.canDelete>
                                                                            <button type="submit" name="delete" class="btn btn-danger" onclick="return confirm('Wirklich löschen?')">
                                                                                <i class="fas fa-trash-alt"></i>
                                                                            </button>
                                                                        <cfelse>
                                                                            <button type="button" class="btn btn-danger disabled">
                                                                                <i class="fas fa-trash-alt"></i>
                                                                            </button>
                                                                        </cfif>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </form>
                                                    </cfloop>
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



