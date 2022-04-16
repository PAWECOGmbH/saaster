<cfscript>
    function systemSetting(required string settingVariable) {

        qSystemSettings = queryExecute (
            options = {datasource = application.datasource},
            params = {
                settingVariable: {type: "varchar", value: arguments.settingVariable}
            },
            sql = "
                SELECT *
                FROM system_settings
                WHERE strSettingVariable = :settingVariable
            "
        )

        return qSystemSettings;

    }
    qInvoiceNumberStart = systemSetting('settingInvoiceNumberStart');
    qRoundFactor = systemSetting('settingRoundFactor');
    qInvoicePrefix = systemSetting('settingInvoicePrefix');
    qStandardVatType = systemSetting('settingStandardVatType');
    qInvoiceNet = systemSetting('settingInvoiceNet');
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
                            <li class="breadcrumb-item active">System settings</li>
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
                <div class="col-lg-12">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">System settings</h3>
                        </div>
                        <form action="#application.mainURL#/sysadm/settings" method="post">
                            <input type="hidden" name="edit_sysadmin_settings">
                            <div class="card-body">

                                <h3>Invoice settings</h3>
                                <div class="border align-baseline p-3">
                                    <div class="row">
                                        <div class="col-lg-6">
                                            <p>#qInvoiceNumberStart.strDescription#</p>
                                            <input type="number" name="#qInvoiceNumberStart.strSettingVariable#" value="#qInvoiceNumberStart.strDefaultValue#" class="form-control w-25" required>
                                        </div>
                                        <div class="col-lg-6">
                                            <p>#qRoundFactor.strDescription#</p>
                                            <select name="#qRoundFactor.strSettingVariable#" class="form-select w-50">
                                                <option value="5" <cfif qRoundFactor.strDefaultValue eq 5>selected</cfif>>0.05 Switzerland</option>
                                                <option value="1" <cfif qRoundFactor.strDefaultValue eq 1>selected</cfif>>0.01 rest of the world</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row mt-4">
                                        <div class="col-lg-6">
                                            <p>#qInvoicePrefix.strDescription#</p>
                                            <input type="text" name="#qInvoicePrefix.strSettingVariable#" value="#qInvoicePrefix.strDefaultValue#" class="form-control w-25" maxlength="5">
                                        </div>
                                        <div class="col-lg-6">

                                        </div>
                                    </div>
                                    <div class="row mt-4">
                                        <div class="col-lg-6">
                                            <p>#qStandardVatType.strDescription#</p>
                                            <label class="form-check form-check-inline">
                                                <input class="form-check-input" type="radio" name="#qStandardVatType.strSettingVariable#" value="1" <cfif qStandardVatType.strDefaultValue eq 1 or qStandardVatType.strDefaultValue eq "">checked</cfif>>
                                                <span class="form-check-label small pt-1">Incl. VAT</span>
                                            </label>
                                            <label class="form-check form-check-inline">
                                                <input class="form-check-input" type="radio" name="#qStandardVatType.strSettingVariable#" value="2" <cfif qStandardVatType.strDefaultValue eq 2>checked</cfif>>
                                                <span class="form-check-label small pt-1">Excl. VAT</span>
                                            </label>
                                            <label class="form-check form-check-inline">
                                                <input class="form-check-input" type="radio" name="#qStandardVatType.strSettingVariable#" value="3" <cfif qStandardVatType.strDefaultValue eq 3>checked</cfif>>
                                                <span class="form-check-label small pt-1">No VAT</span>
                                            </label>
                                        </div>
                                        <div class="col-lg-6">
                                            <p>#qInvoiceNet.strDescription#</p>
                                            <select name="#qInvoiceNet.strSettingVariable#" class="form-select w-50">
                                                <option value="1" <cfif qInvoiceNet.strDefaultValue eq 1>selected</cfif>>Netto</option>
                                                <option value="0" <cfif qInvoiceNet.strDefaultValue eq 0>selected</cfif>>Gross (brutto)</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>


                            </div>
                            <div class="card-footer">
                                <button id="submit_button" type="submit" class="btn btn-primary">#getTrans('btnSave')#</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>


