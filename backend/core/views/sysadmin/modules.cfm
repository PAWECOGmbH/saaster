<cfscript>

    objSysadmin = new backend.core.com.sysadmin();
    qModules = objSysadmin.getModules();

</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Modules</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Modules</li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="##" data-bs-toggle="modal" data-bs-target="##module_new" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> Add module
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
                            The modules are project-specific applications written by saaster.io users. End customers can activate and use these modules.
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table card-table table-vcenter text-nowrap">
                                    <thead>
                                        <tr>
                                            <th width="5%"></th>
                                            <th width="5%" class="text-center">Prio</th>
                                            <th width="20%">Module name</th>
                                            <th width="35%">Short description</th>
                                            <th width="10%" class="text-center">Active</th>
                                            <th width="10%" class="text-center">Bookable</th>
                                            <th width="5%"></th>
                                            <th width="5%"></th>
                                        </tr>
                                    </thead>
                                    <cfif qModules.recordCount>
                                        <tbody <cfif qModules.recordCount gt 1>id="dragndrop_body"</cfif>>
                                            <cfloop query="qModules">
                                                <tr id="sort_#qModules.intModuleID#">
                                                    <td class="move text-center"><cfif qModules.recordCount gt 1><i class="fas fa-bars hand" style="cursor: grab;"></i></cfif></td>
                                                    <td class="text-center">#qModules.intPrio#</td>
                                                    <td>#qModules.strModuleName#</td>
                                                    <td>#qModules.strShortDescription#</td>
                                                    <td class="text-center">#yesNoFormat(qModules.blnActive)#</td>
                                                    <td class="text-center">#yesNoFormat(qModules.blnBookable)#</td>
                                                    <td><a href="#application.mainURL#/sysadmin/modules/edit/#qModules.intModuleID#" class="btn">Edit</a></td>
                                                    <td><a href="##?" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/modules?delete_module=#qModules.intModuleID#', 'Delete module', 'Are you sure you want to delete this module?', 'No, cancel!', 'Yes, delete!')">Delete</a></td>
                                                </tr>

                                            </cfloop>
                                        </tbody>
                                    <cfelse>
                                        <tbody>
                                            <tr><td colspan="100%" class="text-center text-red">You have not added any modules yet</td></tr>
                                        </tbody>
                                    </cfif>
                                    <div id="module_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                        <div class="modal-dialog modal-sm modal-dialog-centered" role="document">
                                            <form action="#application.mainURL#/sysadm/modules" method="post">
                                            <input type="hidden" name="new_module">
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">New module</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="mb-3">
                                                            <label class="form-label">Module name</label>
                                                            <input type="text" name="module_name" class="form-control" autocomplete="off" maxlength="50" required>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                        <button type="submit" class="btn btn-primary ms-auto">
                                                            Save module
                                                        </button>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </table>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    

</div>



<cfif qModules.recordCount gt 1>
    <cfoutput>
    <script>
        // Save new prio
        function fnSaveSort(){

            var jsonTmp = "[";
                $('##dragndrop_body > tr').each(function (i, row) {
                    var divbox = $(this).attr('id');
                    var aTR = divbox.split('_');
                    var newslist = 0;
                    jsonTmp += "{\"prio\" :" + (i+1) + ',';
                    if(newslist != 0){
                        var setlist = JSON.stringify(newslist);
                        jsonTmp += "\"strBoxList\" :" + setlist + ',';
                    }
                    jsonTmp += "\"intModuleID\" :" + aTR[1] + '},';
                }
            );
            jsonTmp += jsonTmp.slice(0,-1);
            jsonTmp += "]]";
            var ajaxResponse = $.ajax({
                type: "post",
                url: "#application.mainURL#/backend/core/handler/ajax_sort.cfm?modules",
                contentType: "application/json",
                data: JSON.stringify( jsonTmp )
            })
            // Response
            ajaxResponse.then(
                function( apiResponse ){
                    if(apiResponse.trim() == 'ok'){
                        location.href = '#application.mainURL#/sysadmin/modules';
                    }
                }
            );
        }
    </script>
    </cfoutput>
</cfif>