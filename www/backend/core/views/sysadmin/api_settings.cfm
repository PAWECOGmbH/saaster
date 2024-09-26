


<cfscript>

    objSysadmin = new backend.core.com.sysadmin();
    qApiUser = objSysadmin.getApi();

</cfscript>

<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">
            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">
                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">API settings</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">API settings</li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="##" data-bs-toggle="modal" data-bs-target="##api_new" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> New API
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
                        <div class="card-body">
                            <cfif not qApiUser.recordCount>
                                <p>No API created yet!</p>
                            <cfelse>
                                <div class="card">
                                    <div class="table-responsive">
                                        <table class="table table-vcenter table-mobile-md card-table">
                                            <thead>
                                                <tr>
                                                    <th width="25%">ID</th>
                                                    <th width="40%">Name</th>
                                                    <th width="25%">Valid until</th>
                                                    <th width="5%"></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfoutput query="qApiUser">
                                                    <tr>
                                                        <td>
                                                            <div class="d-flex py-1 align-items-center">
                                                                <div class="flex-fill">
                                                                    #qApiUser.intApiID#
                                                                </div>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            #qApiUser.strApiName#
                                                        </td>
                                                        <td>
                                                            <cfset untilDate = LSDateTimeFormat( qApiUser.dtmValidUntil, "dd.mm.yyyy")>
                                                            #untilDate#
                                                        </td>
                                                        <td>
                                                            <div class="btn-list flex-nowrap">
                                                                <a href="##?" class="btn" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/api-settings?deleteAPI=#qApiUser.intApiID#', 'Delete API', 'If you delete an API, the key linked to this API will no longer work. Do you really want to delete? ', 'No, cancel!', 'Yes, delete!')">Delete</a>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </cfoutput>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>                                    
                            </cfif>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div id="api_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
            <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                <form action="#application.mainURL#/sysadm/api-settings" method="post" style="width: 100%;">
                    <input type="hidden" name="new_api">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">New API</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <div class="col-lg-5 mb-3">
                                    <label class="form-label">Name</label>
                                    <input type="text" name="api_name" class="form-control" autocomplete="off" maxlength="100" required>
                                </div>
                                <div class="col-lg-6 mb-3">
                                    <label class="form-label">Key</label>
                                    <input type="text" id="apiKey" name="api_key" class="form-control input-icon" autocomplete="off" maxlength="100" required>
                                </div>
                                <div style="display: flex; justify-content: center; align-items: center; cursor: pointer;" class="col-lg-1 mb-3">
                                    <i id="keygen" style="padding-top: 26px;" class="fa-sharp fa-solid fa-arrow-rotate-right"></i>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-5 mb-3">
                                    <label class="form-label">Valid until</label>
                                    <input type="date" name="api_until_date" class="form-control mb-2" id="datepicker-default" required>
                                </div>
                                <div class="col-lg-6 mb-3">
                                   <strong>Note:</strong> You will not be able to retrieve the API key after the API is created, so it is essential to copy the key before closing this window.
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                            <button type="submit" class="btn btn-primary ms-auto">
                                Add API
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </cfoutput>

    

</div>

