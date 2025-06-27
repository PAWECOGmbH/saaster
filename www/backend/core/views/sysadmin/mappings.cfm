<cfscript>

    objSysadmin = new backend.core.com.sysadmin();
    getModal = new backend.core.com.translate();

    param name="url.mapping" default="custom";

    switch (url.mapping) {
        case "system":
            qSystemMappings = objSysadmin.getSystemMappings();
            mappingName = "System mappings";
            break;
        case "frontend":
            qFrontendMappings = objSysadmin.getFrontendMappings();
            mappingName = "Frontend mappings";
            break;
        default:
            qCustomMappings = objSysadmin.getCustomMappings();
            mappingName = "Custom mappings";
    }

</cfscript>


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
                            <li class="breadcrumb-item active">#mappingName#</li>
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

                        <cfswitch expression="#url.mapping#">

                            <!--- Custom mappings --->
                            <cfcase value="custom">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div class="card-title">Custom mappings</div>
                                        <a href="#application.mainURL#/backend/core/views/sysadmin/sql_code.cfm?sql_table=custom_mappings&prim_key=strMapping"
                                            data-bs-toggle="tooltip"
                                            data-bs-placement="top"
                                            title="Generate SQL Code for the table custom_mappings"
                                            class="text-decoration-none" target="_blank">
                                                <i class="fas fa-file-code fa-lg me-3 p-0" style="font-size: 20px;"></i>
                                        </a>
                                    </div>

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
                                                        <td class="bottom_line text-end">
                                                            <button type="submit" class="btn btn-x w-50 btn-icon btn-ghost-success">
                                                                <i class="fas fa-check"></i>
                                                            </button>
                                                        </td>
                                                        <td class="bottom_line"></td>
                                                    </tr>
                                                </form>
                                                <cfloop query="qCustomMappings">
                                                    <form action="#application.mainURL#/sysadm/mappings" method="post">
                                                        <input type="hidden" name="edit_mapping" value="#qCustomMappings.intCustomMappingID#">
                                                        <tr>
                                                            <td></td>
                                                            <td><input type="text" name="mapping" value="#qCustomMappings.strMapping#" class="form-control"></td>
                                                            <td><input type="text" name="path" value="#qCustomMappings.strPath#" class="form-control"></td>
                                                            <td class="text-center"><input type="radio" name="admin" value="public" class="form-check-input" <cfif !qCustomMappings.blnOnlyAdmin and !qCustomMappings.blnOnlySuperAdmin and !qCustomMappings.blnOnlySysAdmin>checked</cfif>></td>
                                                            <td class="text-center"><input type="radio" name="admin" value="admin" class="form-check-input" <cfif qCustomMappings.blnOnlyAdmin eq 1>checked</cfif>></td>
                                                            <td class="text-center"><input type="radio" name="admin" value="superadmin" class="form-check-input" <cfif qCustomMappings.blnOnlySuperAdmin eq 1>checked</cfif>></td>
                                                            <td class="text-center"><input type="radio" name="admin" value="sysadmin" class="form-check-input" <cfif qCustomMappings.blnOnlySysAdmin eq 1>checked</cfif>></td>
                                                            <td class="text-end">
                                                                <button type="submit" class="btn btn-x btn-icon btn-ghost-success">
                                                                    <i class="fas fa-check"></i>
                                                                </button>
                                                            </td>
                                                            <td class="text-left">
                                                                <button type="submit" name="delete" class="btn btn-x w-50 btn-icon btn-ghost-danger">
                                                                    <i class="fas fa-trash-alt"></i>
                                                                </button>
                                                            </td>
                                                        </tr>
                                                    </form>
                                                </cfloop>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </cfcase>

                            <!--- Frontend mappings --->
                            <cfcase value="frontend">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div class="card-title">Frontend mappings</div>
                                        <a href="#application.mainURL#/backend/core/views/sysadmin/sql_code.cfm?sql_table=frontend_mappings&prim_key=strMapping"
                                            data-bs-toggle="tooltip"
                                            data-bs-placement="top"
                                            title="Generate SQL Code for the table frontend_mappings"
                                            class="text-decoration-none" target="_blank">
                                                <i class="fas fa-file-code fa-lg me-3 p-0" style="font-size: 20px;"></i>
                                        </a>
                                    </div>

                                    <p>Here you can create your own Frontend mappings. These mappings are not affected by any system updates.</p>
                                    <div class="table-responsive">
                                        <table class="table table-vcenter card-table">
                                            <thead>
                                                <tr>
                                                    <th>Mapping</th>
                                                    <th>Path</th>
                                                    <th></th>
                                                    <th></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <form action="#application.mainURL#/sysadm/mappings" method="post">
                                                    <input type="hidden" name="new_mapping_frontend">
                                                    <tr>
                                                        <td class="bottom_line"><input type="text" name="mapping" class="form-control" required placeholder="Add new mapping"></td>
                                                        <td class="bottom_line"><input type="text" name="path" class="form-control" required placeholder="Add new path"></td>
                                                        <td class="bottom_line">
                                                            <button type="submit" class="btn btn-x w-50 btn-icon btn-ghost-success">
                                                                <i class="fas fa-check"></i>
                                                            </button>
                                                        </td>
                                                        <td class="bottom_line"></td>
                                                    </tr>
                                                </form>
                                                <cfoutput query="qFrontendMappings">
                                                    <form action="#application.mainURL#/sysadmin/mapping/edit" method="post">
                                                        <input type="hidden" name="mappingID" value="#qFrontendMappings.intFrontendMappingsID#">
                                                        <tr>
                                                            <td>#qFrontendMappings.strMapping#</td>
                                                            <td>#qFrontendMappings.strPath#</td>
                                                            <td>
                                                                <button type="submit" class="btn btn-x w-50 btn-icon btn-ghost-info">
                                                                    <i class="fas fa-edit"></i>
                                                                </button>
                                                            </td>
                                                        </tr>
                                                    </form>
                                                </cfoutput>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </cfcase>

                            <!--- System mappings --->
                            <cfcase value="system">
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
                            </cfcase>

                        </cfswitch>

                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
</div>