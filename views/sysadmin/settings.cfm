<cfscript>
    qCustomSettings = queryExecute (
        options = {datasource = application.datasource},
        sql = "
            SELECT *
            FROM custom_settings
            ORDER BY intCustomSettingID DESC
        "
    );

    qSystemSettings = queryExecute (
        options = {datasource = application.datasource},
        sql = "
            SELECT *
            FROM system_settings
            ORDER BY intSystSettingID DESC
        "
    );

    getModal = createObject("component", "com.translate");
</cfscript>

<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Settings</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Settings</li>
                        </ol>
                    </div>


                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="container-xl">
            <div class="row">
                <div class="col-md-12 col-lg-12">
                    <div class="card">
                        <ul class="nav nav-tabs" data-bs-toggle="tabs">
                            <li class="nav-item"><a href="##custom" class="nav-link active" data-bs-toggle="tab">Custom settings</a></li>
                            <li class="nav-item"><a href="##system" class="nav-link" data-bs-toggle="tab">System settings</a></li>
                        </ul>
                    </div>
                    <div class="tab-content">
                        <div id="custom" class="card tab-pane show active">
                            <div class="card-body">
                                <div class="card-title">Custom settings</div>
                                <p>Here you can create your own settings. These settings are made available to an admin to set up his system and are not affected by any system updates.</p>
                                <div class="table-responsive">
                                    <table class="table table-vcenter card-table">
                                        <thead>
                                            <tr>
                                                <th width="5%"></th>
                                                <th width="25%">setting variable</th>
                                                <th width="25%">Default value</th>
                                                <th width="30%">Description</th>
                                                <th width="5%"></th>
                                                <th width="5%"></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <form action="#application.mainURL#/sysadm/settings" method="post">
                                                <input type="hidden" name="new_setting">
                                                <tr>
                                                    <td class="bottom_line small">add<br>new</td>
                                                    <td class="bottom_line"><input type="text" name="variable" class="form-control" maxlength="100" autocomplete="off" required></td>
                                                    <td class="bottom_line"><input type="text" name="value" class="form-control" maxlength="255" autocomplete="off" required></td>
                                                    <td class="bottom_line"><textarea class="form-control" name="desc" data-bs-toggle="autosize" placeholder="Short description" maxlength="500"></textarea></td>
                                                    <td class="bottom_line text-end"><input type="submit" title="Save" value="&##xf00c" class="fa fa-input text-green fa_icon" style="font-size: 20px;"></td>
                                                    <td class="bottom_line"></td>
                                                </tr>
                                            </form>
                                            <cfoutput query="qCustomSettings">
                                                <form action="#application.mainURL#/sysadm/settings" method="post">
                                                    <input type="hidden" name="edit_setting" value="#qCustomSettings.intCustomSettingID#">
                                                    <tr>
                                                        <td></td>
                                                        <td><input type="text" name="variable" value="#qCustomSettings.strSettingVariable#" maxlength="100" class="form-control" required></td>
                                                        <td>
                                                            <div class="input-group input-group-flat">
                                                                <input type="text" name="value" value="#qCustomSettings.strDefaultValue#" maxlength="255" class="form-control" required>
                                                                <span class="input-group-text">
                                                                    <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##cust_value_#qCustomSettings.intCustomSettingID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate default value"></i></a>
                                                                </span>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <div class="input-group input-group-flat">
                                                                <textarea class="form-control" name="desc" data-bs-toggle="autosize" placeholder="Short description" maxlength="500">#qCustomSettings.strDescription#</textarea>
                                                                <span class="input-group-text">
                                                                    <a href="##?" class="input-group-link" data-bs-toggle="modal" data-bs-target="##cust_desc_#qCustomSettings.intCustomSettingID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate description"></i></a>
                                                                </span>
                                                            </div>
                                                        </td>
                                                        <td class="text-end"><input type="submit" title="Save" value="&##xf00c" class="fa fa-input text-green fa_icon" style="font-size: 20px;"></td>
                                                        <td class="text-left"><input type="submit" title="Delete" name="delete" value="&##xf00d" class="fa fa-input text-red fa_icon h4" style="font-size: 20px;"></td>
                                                    </tr>
                                                </form>
                                                #getModal.init('custom_settings', 'strDefaultValue', qCustomSettings.intCustomSettingID, 255).openModal('cust_value', cgi.path_info, 'Translate default value')#
                                                #getModal.init('custom_settings', 'strDescription', qCustomSettings.intCustomSettingID, 500).openModal('cust_desc', cgi.path_info, 'Translate description')#
                                            </cfoutput>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div id="system" class="card tab-pane show">
                            <div class="card-body">
                                <div class="card-title">System settings</div>
                                <p class="text-red">These settings are made available to an admin to set up his system. These entries should never be changed, otherwise the system will no longer be updateable!</p>
                                <div class="table-responsive">
                                    <table class="table table-vcenter card-table">
                                        <thead>
                                            <tr>
                                                <th width="25%">Variable</th>
                                                <th width="25%">Default value</th>
                                                <th width="50%">Description</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfoutput query="qSystemSettings">
                                                <tr>
                                                    <td>#qSystemSettings.strSettingVariable#</td>
                                                    <td>#qSystemSettings.strDefaultValue#<a href="##?" class="input-group-link px-3" data-bs-toggle="modal" data-bs-target="##syst_value_#qSystemSettings.intSystSettingID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate default value"></i></a></td>
                                                    <td>
                                                        #qSystemSettings.strDescription#
                                                        <a href="##?" class="input-group-link px-3" data-bs-toggle="modal" data-bs-target="##syst_desc_#qSystemSettings.intSystSettingID#"><i class="fas fa-globe" data-bs-toggle="tooltip" data-bs-placement="top" title="Translate description"></i></a>
                                                    </td>
                                                </tr>
                                                #getModal.init('system_settings', 'strDefaultValue', qSystemSettings.intSystSettingID, 255).openModal('syst_value', '/sysadmin/settings##system', 'Translate default value')#
                                                #getModal.init('system_settings', 'strDescription', qSystemSettings.intSystSettingID, 500).openModal('syst_desc', '/sysadmin/settings##system', 'Translate description')#
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
