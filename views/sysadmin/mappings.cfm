<cfscript>
    qCustomMappings = queryExecute (
        options = {datasource = application.datasource},
        sql = "
            SELECT *
            FROM custom_mappings
            ORDER BY intCustomMappingID DESC
        "
    )
    qSystemMappings = queryExecute (
        options = {datasource = application.datasource},
        sql = "
            SELECT *
            FROM system_mappings
        "
    )
</cfscript>

<cfinclude template="/includes/header.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Mappings</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Mappings</li>
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
                <div class="col-md-12 col-lg-12">
                    <div class="card">
                        <ul class="nav nav-tabs" data-bs-toggle="tabs">
                            <li class="nav-item"><a href="##custom" class="nav-link active" data-bs-toggle="tab">Custom mappings</a></li>
                            <li class="nav-item"><a href="##system" class="nav-link" data-bs-toggle="tab">System mappings</a></li>
                        </ul>
                    </div>
                    <div class="tab-content">
                        <div id="custom" class="card tab-pane show active">
                            <div class="card-body">
                                <div class="card-title">Custom mappings</div>
                                <p>Here you can create your own mappings. These mappings are not affected by any system updates.</p>
                                <div class="table-responsive">
                                    <table class="table table-vcenter card-table">
                                        <thead>
                                            <tr>
                                                <th></th>
                                                <th>Mapping</th>
                                                <th>Path</th>
                                                <th class="text-center">users</th>
                                                <th class="text-center">only<br>admins</th>
                                                <th class="text-center">only<br>super admins</th>
                                                <th class="text-center">only<br>sys admins</th>
                                                <th></th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <form action="#application.mainURL#/sysadm/mappings" method="post">
                                                <input type="hidden" name="new_mapping">
                                                <tr>
                                                    <td class="bottom_line small">add<br>new</td>
                                                    <td class="bottom_line"><input type="text" name="mapping" class="form-control" required></td>
                                                    <td class="bottom_line"><input type="text" name="path" class="form-control" required></td>
                                                    <td class="bottom_line text-center"><input type="radio" name="admin" value="public" class="form-check-input" checked></td>
                                                    <td class="bottom_line text-center"><input type="radio" name="admin" value="admin" class="form-check-input"></td>
                                                    <td class="bottom_line text-center"><input type="radio" name="admin" value="superadmin" class="form-check-input"></td>
                                                    <td class="bottom_line text-center"><input type="radio" name="admin" value="sysadmin" class="form-check-input"></td>
                                                    <td class="bottom_line text-end"><input type="submit" title="Save" value="&##xf00c" class="fa fa-input text-green fa_icon" style="font-size: 20px;"></td>
                                                    <td class="bottom_line"></td>
                                                </tr>
                                            </form>
                                            <cfloop query="qCustomMappings">
                                                <cfif qCustomMappings.intModuleID gt 0>
                                                    <cfset disabled = "disabled">
                                                <cfelse>
                                                    <cfset disabled = "">
                                                </cfif>
                                                <form action="#application.mainURL#/sysadm/mappings" method="post">
                                                    <input type="hidden" name="edit_mapping" value="#qCustomMappings.intCustomMappingID#">
                                                    <tr>
                                                        <td></td>
                                                        <td><input type="text" name="mapping" value="#qCustomMappings.strMapping#" class="form-control" #disabled#></td>
                                                        <td><input type="text" name="path" value="#qCustomMappings.strPath#" class="form-control" #disabled#></td>
                                                        <td class="text-center"><input type="radio" name="admin" value="public" class="form-check-input" <cfif !qCustomMappings.blnOnlyAdmin and !qCustomMappings.blnOnlySuperAdmin and !qCustomMappings.blnOnlySysAdmin>checked</cfif>></td>
                                                        <td class="text-center"><input type="radio" name="admin" value="admin" class="form-check-input" <cfif qCustomMappings.blnOnlyAdmin eq 1>checked</cfif>></td>
                                                        <td class="text-center"><input type="radio" name="admin" value="superadmin" class="form-check-input" <cfif qCustomMappings.blnOnlySuperAdmin eq 1>checked</cfif>></td>
                                                        <td class="text-center"><input type="radio" name="admin" value="sysadmin" class="form-check-input" <cfif qCustomMappings.blnOnlySysAdmin eq 1>checked</cfif>></td>
                                                        <td class="text-end"><cfif not len(disabled)><input type="submit" title="Save" value="&##xf00c" class="fa fa-input text-green fa_icon" style="font-size: 20px;"></cfif></td>
                                                        <td class="text-left"><cfif not len(disabled)><input type="submit" title="Delete" name="delete" value="&##xf00d" class="fa fa-input text-red fa_icon" style="font-size: 20px;"></cfif></td>
                                                    </tr>
                                                </form>
                                            </cfloop>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div id="system" class="card tab-pane show">
                            <div class="card-body">
                                <div class="card-title">System mappings</div>
                                <p class="text-red">The following entries should never be changed, otherwise the system will no longer be updateable!</p>
                                <div class="table-responsive">
                                    <table class="table table-vcenter card-table">
                                        <thead>
                                            <tr>
                                                <th></th>
                                                <th>Mapping</th>
                                                <th>Path</th>
                                                <th class="text-center">Only Admins</th>
                                                <th class="text-center">Only SuperAdmins</th>
                                                <th class="text-center">Only SysAdmins</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfoutput query="qSystemMappings">
                                                <tr>
                                                    <td></td>
                                                    <td>#qSystemMappings.strMapping#</td>
                                                    <td>#qSystemMappings.strPath#</td>
                                                    <td class="text-center">#qSystemMappings.blnOnlyAdmin#</td>
                                                    <td class="text-center">#qSystemMappings.blnOnlySuperAdmin#</td>
                                                    <td class="text-center">#qSystemMappings.blnOnlySysAdmin#</td>
                                                </tr>
                                            </cfoutput>
                                        </tbody>
                                    </table>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">

</div>