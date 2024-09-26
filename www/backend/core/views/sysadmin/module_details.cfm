<cfscript>
    fileList = application.objGlobal.buildAllowedFileLists(variables.imageFileTypes);

    allowedFileTypesList = fileList.allowedFileTypesList;
    acceptFileTypesList = fileList.acceptFileTypesList;
</cfscript>
<cfoutput>
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
                    <div class="input-group input-group-flat">
                        <input type="text" class="form-control" name="module_name" autocomplete="off" maxlength="50" value="#HTMLEditFormat(qModule.strModuleName)#" required>
                        <span class="input-group-text">
                            <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##module_name_#qModule.intModuleID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate module name"></i></a>
                        </span>
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label">Short description</label>
                    <div class="input-group input-group-flat">
                        <input type="text" class="form-control" name="short_desc" maxlength="100" value="#HTMLEditFormat(qModule.strShortDescription)#">
                        <span class="input-group-text">
                            <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##short_desc_#qModule.intModuleID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate module name"></i></a>
                        </span>
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label">Module settings</label>
                    <fieldset class="form-fieldset">
                        <div class="mb-3">
                            <small class="form-hint mb-3">So that your client can configure the created module, we will create the folder and the file after saving. In addition, the file <i>navigation.cfm</i> is created, with which you can build the navigation.</small>
                            <label class="mb-1">Folder and table prefix *</label>
                            <input type="text" class="form-control" name="prefix" placeholder="prefix" autocomplete="off" maxlength="20" value="#HTMLEditFormat(qModule.strTabPrefix)#" required>
                            <small class="form-hint">
                                Please also always use the <b>same prefix</b> for your database tables as for your folder name!
                            </small>
                        </div>
                        <cfif len(trim(qModule.strSettingPath))>
                            You can develop your module in this folder: /backend/modules/#qModule.strTabPrefix#/<br />
                            Code your settings in this file: /#qModule.strSettingPath#.cfm<br />
                            Mapping is already set to: <a href="#application.mainURL#/backend/modules/#qModule.strTabPrefix#/settings" target="_blank">#application.mainURL#/backend/modules/#qModule.strTabPrefix#/settings</a>
                        </cfif>
                    </fieldset>
                </div>
                <div class="row mb-3">
                    <div class="col-lg-4">
                        <div class="mb-3">
                            <label class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" name="free" <cfif qModule.blnFree>checked</cfif>>
                                <span class="form-check-label">Free module</span>
                            </label>
                            <small class="form-hint">
                                Activate this module as "Free". All settings in the "Prices" tab then become ineffective.
                            </small>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Number of test days *</label>
                            <cfif qModule.blnFree>
                                <input type="text" class="form-control text-end" value="#qModule.intNumTestDays#" disabled style="cursor: not-allowed;" data-bs-toggle="tooltip" data-bs-placement="top" title="Its a free module">
                            <cfelse>
                                <input type="text" class="form-control text-end" name="test_days" autocomplete="off" maxlength="10" value="#qModule.intNumTestDays#" placeholder="30" required>
                            </cfif>
                            <small class="form-hint">
                                Enter 0 if you don't want to provide any test days.
                            </small>
                        </div>
                    </div>
                    <div class="col-lg-1"></div>
                    <div class="col-lg-7">
                        <label class="form-label">Picture/Logo</label>
                        <cfif len(trim(qModule.strPicture))>
                            <div class="mt-3">
                                <p><img src="#application.mainURL#/userdata/images/modules/#qModule.strPicture#" class="avatar avatar-xl"></p>
                                <p><a href="#application.mainURL#/sysadm/modules?delete_pic=#qModule.intModuleID#">Delete picture</a></p>
                            </div>
                        <cfelse>
                            <input name="pic" type="file" accept="#allowedFileTypesList#" class="dropify" data-height="100" data-allowed-file-extensions='[#acceptFileTypesList#]' data-max-file-size="3M" />
                            <small class="form-hint">
                                Use a square for the best view
                            </small>
                        </cfif>
                    </div>
                </div>
            </div>
            <div class="col-lg-6">
                <div class="row mb-2">
                    <label class="form-label">Description <a href="##?" class="input-group-link ms-2" data-bs-toggle="modal" data-bs-target="##desc_#qModule.intModuleID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate description"></i></a></label>
                </div>
                <textarea class="form-control editor" name="desc" style="height: 400px;">#qModule.strDescription#</textarea>
            </div>
        </div>
    </div>
    <div class="card-footer">
        <button id="submit_button" type="submit" class="btn btn-primary">Save module</button>
    </div>
</form>
#getModal.args('modules', 'strModuleName', qModule.intModuleID).openModal('module_name', cgi.path_info, 'Translate description')#
#getModal.args('modules', 'strShortDescription', qModule.intModuleID).openModal('short_desc', cgi.path_info, 'Translate description')#
#getModal.args('modules', 'strDescription', qModule.intModuleID).openModal('desc', cgi.path_info, 'Translate description', 1)#
</cfoutput>