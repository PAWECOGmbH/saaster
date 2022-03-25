<cfscript>
    // Exception handling for sef and user id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisModuleID = thiscontent.thisID;

    if(not isNumeric(thisModuleID) or thisModuleID lte 0) {
        location url="#application.mainURL#/sysadmin/modules" addtoken="false";
    }

    qModule = queryExecute(
        options = {datasource = application.datasource},
        params = {
            thisModuleID: {type: "numeric", value: thisModuleID}
        },
        sql = "
            SELECT *
            FROM modules
            WHERE intModuleID = :thisModuleID
        "
    );

    if(not qModule.recordCount){
        location url="#application.mainURL#/sysadmin/modules" addtoken="false";
    }
</cfscript>

<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Edit module</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/sysadmin/modules">Modules</a></li>
                            <li class="breadcrumb-item active">#qModule.strModuleName#</li>
                        </ol>
                    </div>
                    <div class="page-header col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="#application.mainURL#/sysadmin/modules" class="btn btn-primary">
                            <i class="fas fa-angle-double-left pe-3"></i> Back to overview
                        </a>
                    </div>

                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="container-xl">
            <div class="row">
                <div class="col-lg-12">
                    <div class="card">
                        <form id="submit_form" method="post" action="#application.mainURL#/sysadm/modules" enctype="multipart/form-data">
                        <input type="hidden" name="edit_module" value="#qModule.intModuleID#">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-lg-6">
                                        <div class="row mb-3">
                                            <div class="col-lg-3">
                                                <label class="form-check form-switch">
                                                    <input class="form-check-input" type="checkbox" name="bookable" <cfif qModule.blnBookable>checked</cfif>>
                                                    <span class="form-check-label">Bookable</span>
                                                </label>
                                            </div>
                                            <div class="col-lg-9">
                                                <label class="form-check form-switch">
                                                    <input class="form-check-input" type="checkbox" name="active" <cfif qModule.blnActive>checked</cfif>>
                                                    <span class="form-check-label">Active</span>
                                                </label>
                                            </div>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Module name *</label>
                                            <input type="text" class="form-control" name="module_name" autocomplete="off" maxlength="50" value="#HTMLEditFormat(qModule.strModuleName)#" required>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Short description</label>
                                            <textarea class="form-control" name="short_desc" rows="3" maxlength="100">#qModule.strShortDescription#</textarea>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Table prefix *</label>
                                            <input type="text" class="form-control" name="prefix" placeholder="e.g. mymod_" autocomplete="off" maxlength="50" value="#HTMLEditFormat(qModule.strTabPrefix)#" required>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Picture/Logo</label>
                                            <cfif len(trim(qModule.strPicture))>
                                                <div class="col-lg-3 mt-3 text-center">
                                                    <p><img src="#application.mainURL#/userdata/images/modules/#qModule.strPicture#" class="avatar avatar-xl avatar-rounded"></p>
                                                    <p><a href="#application.mainURL#/sysadm/modules?delete_pic=#qModule.intModuleID#">Delete picture</a></p>
                                                </div>
                                            <cfelse>
                                                <input name="pic" type="file" accept=".jpg, .jpeg, .png, .svg, .bmp" class="dropify" data-height="100" data-allowed-file-extensions='["jpg", "jpeg", "png", "svg", "bmp"]' data-max-file-size="3M" />
                                            </cfif>
                                        </div>
                                    </div>
                                    <div class="col-lg-6">
                                        <div class="mb-3">
                                            <label class="form-label">Description</label>
                                            <textarea class="form-control" id="editor" name="desc" rows="20">#qModule.strDescription#</textarea>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="card-footer">
                                <button id="submit_button" type="submit" class="btn btn-primary">Save module</button>
                                <button type="button" class="btn bg-red-lt float-end" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/modules?delete_module=#qModule.intModuleID#', 'Delete module', 'Are you sure you want to delete this module?', 'No, cancel!', 'Yes, delete!')">Delete module</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>
