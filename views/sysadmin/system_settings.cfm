<cfscript>
    cfparam(name="application.layoutStruct.horizontal" default="");
    cfparam(name="application.layoutStruct.horizontalDark" default="");
    cfparam(name="application.layoutStruct.vertical" default="");
    cfparam(name="application.layoutStruct.verticalTransparent" default="");
    cfparam(name="application.layoutStruct.rightVertical" default="");
    cfparam(name="application.layoutStruct.condensed" default="");
    cfparam(name="application.layoutStruct.combined" default="");
    cfparam(name="application.layoutStruct.navbarDark" default="");
    cfparam(name="application.layoutStruct.navbarSticky" default="");
    cfparam(name="application.layoutStruct.navbarOverlap" default="");
    cfparam(name="application.layoutStruct.fluid" default="");
    cfparam(name="application.layoutStruct.fluidVertical" default="");



    // Function query execute system settings
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
    qLayout = systemSetting('settingLayout');

</cfscript>

<cfinclude template="/includes/header.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="#application.layoutStruct.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#application.layoutStruct.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
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
        <div class="#application.layoutStruct.layoutPage#">
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
                            <div class="card-body">
                                <h3>Layout settings</h3>
                                <div class="border align-baseline p-3">
                                    <div class="col-12">
                                        <div class="row g-2">
                                            <div class="col-6">
                                                <label class="form-imagecheck mb-2">
                                                    <input name="settingLayout" type="radio" value="horizontal" class="form-imagecheck-input" #application.layoutStruct.horizontal#/>
                                                    <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Horizontal</p>
                                                    <img src="../dist/img/layout/horizontal.png" alt="Horizontal" class="form-imagecheck-image">
                                                    </span>
                                                </label>
                                            </div>
                                            <div class="col-6">
                                                <label class="form-imagecheck mb-2">
                                                    <input name="settingLayout" type="radio" value="horizontalDark" class="form-imagecheck-input" #application.layoutStruct.horizontalDark#/>
                                                    <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Horizontal dark</p>
                                                    <img src="../dist/img/layout/horizontalDark.png" alt="Horizontal dark" class="form-imagecheck-image">
                                                    </span>
                                                </label>
                                            </div>
                                            <div class="col-6">
                                                <label class="form-imagecheck mb-2">
                                                    <input name="settingLayout" type="radio" value="navbarSticky" class="form-imagecheck-input" #application.layoutStruct.navbarSticky#/>
                                                    <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Navbar sticky</p>
                                                    <img src="../dist/img/layout/navbarSticky.png" alt="Navbar sticky" class="form-imagecheck-image">
                                                    </span>
                                                </label>
                                            </div>
                                            <div class="col-6">
                                                <label class="form-imagecheck mb-2">
                                                    <input name="settingLayout" type="radio" value="condensed" class="form-imagecheck-input" #application.layoutStruct.condensed#/>
                                                    <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Condensed</p>
                                                    <img src="../dist/img/layout/condensed.png" alt="Condensed" class="form-imagecheck-image">
                                                    </span>
                                                </label>
                                            </div>
                                            <div class="col-6">
                                                <label class="form-imagecheck mb-2">
                                                    <input name="settingLayout" type="radio" value="navbarDark" class="form-imagecheck-input" #application.layoutStruct.navbarDark#/>
                                                    <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Navbar dark</p>
                                                    <img src="../dist/img/layout/navbarDark.png" alt="Navbar dark" class="form-imagecheck-image">
                                                    </span>
                                                </label>
                                            </div>
                                            <div class="col-6">
                                                <label class="form-imagecheck mb-2">
                                                    <input name="settingLayout" type="radio" value="navbarOverlap" class="form-imagecheck-input" #application.layoutStruct.navbarOverlap#/>
                                                    <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Navbar overlap</p>
                                                    <img src="../dist/img/layout/navbarOverlap.png" alt="Navbar overlap" class="form-imagecheck-image">
                                                    </span>
                                                </label>
                                            </div>
                                            <div class="col-6">
                                                <label class="form-imagecheck mb-2">
                                                    <input name="settingLayout" type="radio" value="verticalTransparent" class="form-imagecheck-input" #application.layoutStruct.verticalTransparent#/>
                                                    <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Vertical</p>
                                                    <img src="../dist/img/layout/verticalTransparent.png" alt="Vertical transparent" class="form-imagecheck-image">
                                                    </span>
                                                </label>
                                            </div>
                                            <div class="col-6">
                                                <label class="form-imagecheck mb-2">
                                                    <input name="settingLayout" type="radio" value="vertical" class="form-imagecheck-input" #application.layoutStruct.vertical#/>
                                                    <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Vertical dark</p>
                                                    <img src="../dist/img/layout/vertical.png" alt="Vertical" class="form-imagecheck-image">
                                                    </span>
                                                </label>
                                            </div>
                                            <div class="col-6">
                                                <label class="form-imagecheck mb-2">
                                                    <input name="settingLayout" type="radio" value="rightVertical" class="form-imagecheck-input" #application.layoutStruct.rightVertical#/>
                                                    <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Right vertical</p>
                                                    <img src="../dist/img/layout/rightVertical.png" alt="Right vertical" class="form-imagecheck-image">
                                                    </span>
                                                </label>
                                            </div>
                                            <div class="col-6">
                                                <label class="form-imagecheck mb-2">
                                                    <input name="settingLayout" type="radio" value="combined" class="form-imagecheck-input" #application.layoutStruct.combined#/>
                                                    <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Combined</p>
                                                    <img src="../dist/img/layout/combined.png" alt="Combined" class="form-imagecheck-image">
                                                    </span>
                                                </label>
                                            </div>
                                            <div class="col-6">
                                                <label class="form-imagecheck mb-2">
                                                    <input name="settingLayout" type="radio" value="fluid" class="form-imagecheck-input" #application.layoutStruct.fluid#/>
                                                    <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Fluid</p>
                                                    <img src="../dist/img/layout/fluid.png" alt="Fluid" class="form-imagecheck-image">
                                                    </span>
                                                </label>
                                            </div>
                                            <div class="col-6">
                                                <label class="form-imagecheck mb-2">
                                                    <input name="settingLayout" type="radio" value="fluidVertical" class="form-imagecheck-input" #application.layoutStruct.fluidVertical#/>
                                                    <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Fluid vertical</p>
                                                    <img src="../dist/img/layout/fluidVertical.png" alt="Fluid vertical" class="form-imagecheck-image">
                                                    </span>
                                                </label>
                                            </div>
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