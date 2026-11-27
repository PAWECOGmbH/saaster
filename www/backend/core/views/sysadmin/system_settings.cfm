<cfscript>

    cfparam(name="getLayout.horizontal" default="");
    cfparam(name="getLayout.horizontalDark" default="");
    cfparam(name="getLayout.vertical" default="");
    cfparam(name="getLayout.verticalTransparent" default="");
    cfparam(name="getLayout.rightVertical" default="");
    cfparam(name="getLayout.condensed" default="");
    cfparam(name="getLayout.combined" default="");
    cfparam(name="getLayout.navbarDark" default="");
    cfparam(name="getLayout.navbarSticky" default="");
    cfparam(name="getLayout.navbarOverlap" default="");
    cfparam(name="getLayout.fluid" default="");
    cfparam(name="getLayout.fluidVertical" default="");


    objSysadmin = new backend.core.com.sysadmin();
    qInvoiceNumberStart = objSysadmin.getSystemSetting('settingInvoiceNumberStart');
    qRoundFactor = objSysadmin.getSystemSetting('settingRoundFactor');
    qInvoicePrefix = objSysadmin.getSystemSetting('settingInvoicePrefix');
    qStandardVatType = objSysadmin.getSystemSetting('settingStandardVatType');
    qInvoiceNet = objSysadmin.getSystemSetting('settingInvoiceNet');
    invoiceBcc = application.objSettings.getSetting('settingInvoiceBcc');
    yearlyPricePerMonth = application.objSettings.getSetting('settingYearlyPricePerMonth');
    qLayout = objSysadmin.getSystemSetting('settingLayout');
    // Saved theme values, normalized like on every backend page (theme.cfc; a fresh instance also works before a reinit)
    objTheme = new backend.core.com.theme();
    theme = objTheme.themeSetting(application.objSettings.initSystemSettings());
    themeColors = [
        {setting: "settingThemePrimary", colorSetting: "settingColorPrimary", id: "theme-primary", label: "Primary color",
            hint: "For everything clickable: buttons, links, active navigation, checkboxes and focus."},
        {setting: "settingThemeAccent", colorSetting: "settingColorAccent", id: "theme-accent", label: "Accent color",
            hint: "Highlights that are not clickable: page title marker, dashboard widgets, initials and icon tiles."},
        {setting: "settingThemeAccent2", colorSetting: "settingColorAccent2", id: "theme-accent2", label: "Second accent color",
            hint: "Optional, used together with the accent color in its gradients. Without it, the accent color is used alone."}
    ];
    themeSelects = [
        {setting: "settingThemeNavbar", label: "Navigation color", hint: "Colors the top navigation or the sidebar with the primary color. Light primary colors (Yellow, Lime, Green or a light custom color) keep the layout colors so that the navigation stays readable."},
        {setting: "settingThemeBase", label: "Gray tone", hint: "Tints backgrounds, borders and muted text."},
        {setting: "settingThemeRadius", label: "Corner radius", hint: "Applies to buttons, cards, inputs and badges."},
        {setting: "settingThemeFont", label: "Font", hint: "Font family of the backend."}
    ];
    qSwissQrBill = objSysadmin.getSystemSetting('settingSwissQrBill');
    qSwissQrIBAN = objSysadmin.getSystemSetting('settingIBANnumber');
    qSwissQrRef = objSysadmin.getSystemSetting('settingQRreference');
    qrSettingsError = session.qrSettingsError ?: {};
    structDelete(session, "qrSettingsError");
    hasQrSettingsError = !structIsEmpty(qrSettingsError);
    qrBillEnabled = hasQrSettingsError ? qrSettingsError.enabled : qSwissQrBill.strDefaultValue;
    qrIban = hasQrSettingsError ? qrSettingsError.iban : qSwissQrIBAN.strDefaultValue;
    qrReference = hasQrSettingsError ? qrSettingsError.reference : qSwissQrRef.strDefaultValue;
    roundFactor = hasQrSettingsError and listFind("1,5", qrSettingsError.roundFactor) ? qrSettingsError.roundFactor : qRoundFactor.strDefaultValue;
    infoMailNewRegistrations = objSysadmin.getSystemSetting('settingMailNewRegistrations');
    dashboardEditable = objSysadmin.getSystemSetting('settingDashboardEditable');
    customerData = application.objSysAdmin.getSysAdminData();
    countryData = application.objCustomer.getUserDataByID(customerData.customerID);

</cfscript>


<cfoutput>
<!--- Tabler's color picker: Coloris in the version of Tabler's package.json, styled by tabler-vendors.css.
      Loaded here only, as tabler-vendors.css also restyles Tom Select, Litepicker and the editor.
      Keep the Tabler version equal to css.cfm (checked by tests/specs/unit/theme_spec.cfc). --->
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@melloware/coloris@0.25.1/dist/coloris.min.css" />
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/@tabler/core@1.7.5/dist/css/tabler-vendors.min.css" />
<script src="https://cdn.jsdelivr.net/npm/@melloware/coloris@0.25.1/dist/umd/coloris.min.js"></script>
<div class="page-wrapper">

    <div class="#getLayout.layoutPage#">

        <div class="row mb-3">
            <div class="col-md-12 col-lg-12">

                <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
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
    <div class="#getLayout.layoutPage#">
        <div class="row">
            <div class="col-lg-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">System settings</h3>
                    </div>
                    <form action="#application.mainURL#/sysadm/settings" method="post">#csrfField()#
                        <input type="hidden" name="edit_sysadmin_settings">
                        <div class="card-body">

                            <h3>Generel settings</h3>
                            <div class="border align-baseline p-3">
                                <div class="row">
                                    <div class="col-lg-6">
                                        <p>#encodeForHTML(infoMailNewRegistrations.strDescription)#</p>
                                        <select name="#encodeForHTML(infoMailNewRegistrations.strSettingVariable)#" class="form-select w-50">
                                            <option value="0" <cfif infoMailNewRegistrations.strDefaultValue eq 0>selected</cfif>>No</option>
                                            <option value="1" <cfif infoMailNewRegistrations.strDefaultValue eq 1>selected</cfif>>Yes</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="row mt-3">
                                    <div class="col-lg-6">
                                        <label class="form-label" for="settingTenantsEnabled">Enable tenants</label>
                                        <select id="settingTenantsEnabled" name="settingTenantsEnabled" class="form-select w-50">
                                            <option value="1" <cfif application.objCustomer.tenantCreationEnabled()>selected</cfif>>Yes</option>
                                            <option value="0" <cfif not application.objCustomer.tenantCreationEnabled()>selected</cfif>>No</option>
                                        </select>
                                        <p class="form-hint">Existing tenants remain accessible when creation is disabled.</p>
                                    </div>
                                </div>
                            </div>

                        </div>

                        <div class="card-body">

                            <h3>Dashboard settings</h3>
                            <div class="border align-baseline p-3">
                                <div class="row">
                                    <div class="col-lg-6">
                                        <p>#encodeForHTML(dashboardEditable.strDescription)#</p>
                                        <select name="#encodeForHTML(dashboardEditable.strSettingVariable)#" class="form-select w-50">
                                            <option value="0" <cfif dashboardEditable.strDefaultValue eq 0>selected</cfif>>No</option>
                                            <option value="1" <cfif dashboardEditable.strDefaultValue eq 1>selected</cfif>>Yes</option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                        </div>

                        <div class="card-body">

                            <h3>Price display</h3>
                            <div class="border p-3 mb-4">
                                <label class="form-check">
                                    <input class="form-check-input" type="radio" name="settingYearlyPricePerMonth" value="0" <cfif yearlyPricePerMonth neq "1">checked</cfif>>
                                    <span class="form-check-label">Show yearly plan prices per year</span>
                                </label>
                                <label class="form-check">
                                    <input class="form-check-input" type="radio" name="settingYearlyPricePerMonth" value="1" <cfif yearlyPricePerMonth eq "1">checked</cfif>>
                                    <span class="form-check-label">Show yearly plan prices per month (billed yearly)</span>
                                </label>
                            </div>
                            <h3>Invoice settings</h3>
                            <div class="border p-3 mb-3">
                                <label class="form-label" for="invoice-bcc">Send a blind copy of invoice emails to #encodeForHTML(application.toEmail)#</label>
                                <select id="invoice-bcc" name="settingInvoiceBcc" class="form-select w-50">
                                    <option value="0" <cfif invoiceBcc neq "1">selected</cfif>>No</option>
                                    <option value="1" <cfif invoiceBcc eq "1">selected</cfif>>Yes</option>
                                </select>
                            </div>
                            <div class="border align-baseline p-3">
                                <div class="row">
                                    <div class="col-lg-6">
                                        <p>#encodeForHTML(qInvoiceNumberStart.strDescription)#</p>
                                        <input type="number" name="#encodeForHTML(qInvoiceNumberStart.strSettingVariable)#" value="#encodeForHTML(qInvoiceNumberStart.strDefaultValue)#" class="form-control w-25" required>
                                    </div>
                                    <div class="col-lg-6">
                                        <p>#encodeForHTML(qRoundFactor.strDescription)#</p>
                                        <select name="#encodeForHTML(qRoundFactor.strSettingVariable)#" class="form-select w-50" id="roundFactorSelect">
                                                            <option value="5" <cfif roundFactor eq 5>selected</cfif>>0.05 Switzerland</option>
                                                            <option value="1" <cfif roundFactor eq 1>selected</cfif>>0.01 rest of the world</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="row mt-4">
                                    <div class="col-lg-6">
                                        <p>#encodeForHTML(qInvoicePrefix.strDescription)#</p>
                                        <input type="text" name="#encodeForHTML(qInvoicePrefix.strSettingVariable)#" value="#encodeForHTML(qInvoicePrefix.strDefaultValue)#" class="form-control w-25" maxlength="5">
                                    </div>
                                    <div class="col-lg-6">
                                        <div id="QrBillContainer" style="display: none;">
                                            <div class="row">
                                                <p>#encodeForHTML(qSwissQrBill.strDescription)#</p>
                                                <div class="col-lg-4">
                                                    <select name="#encodeForHTML(qSwissQrBill.strSettingVariable)#" class="form-select w-50" id="QrBillCheckbox">
                                                        <option value="0" <cfif qrBillEnabled eq 0>selected</cfif>>No</option>
                                                        <option value="1" <cfif qrBillEnabled eq 1>selected</cfif>>Yes</option>
                                                    </select>
                                                </div>
                                                <div class="col-lg-8">
                                                    <a href="##" id="extraLink" class="btn" style="display: none;" data-bs-toggle="modal" data-bs-target="##qr_data">Manage QR data</a>
                                                </div>
                                            </div>
                                            <div id="qr_data" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='qr-data-title' aria-hidden='true'#hasQrSettingsError ? ' data-qr-validation-error="true"' : ''#>
                                                <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <h5 id="qr-data-title" class="modal-title">Swiss QR invoice data</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <div class="row mb-3">
                                                                <div class="col-lg-6">
                                                                    <b>Invoice address:</b><br /><br />
                                                                    #encodeForHTML(customerData.companyName)#<br />
                                                                    #customerData.address#<br />
                                                                    #customerData.zip# #customerData.city#<br />
                                                                    CH
                                                                </div>
                                                                <div class="col-lg-6">
                                                                    <br /><br />
                                                                    <a href="#application.mainURL#/account-settings/company">You can edit your invoice address here</a>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="modal-body mb-3">
                                                            <cfif hasQrSettingsError>
                                                                <div class="alert alert-danger" role="alert">#encodeForHTML(qrSettingsError.message)#</div>
                                                            </cfif>
                                                            <div class="mb-3">
                                                                <label class="form-label" for="qr-iban">IBAN</label>
                                                                <input type="text" id="qr-iban" name="settingIBANnumber" class="form-control" autocomplete="off" value="#encodeForHTMLAttribute(qrIban)#" maxlength="30">
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label" for="qr-reference">Payment reference</label>
                                                                <input type="text" id="qr-reference" name="settingQRreference" class="form-control" autocomplete="off" value="#encodeForHTMLAttribute(qrReference)#" maxlength="40">
                                                            </div>
                                                        </div>
                                                        <div class="modal-body modal-footer pt-3">
                                                            <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                                                            <button type="submit" class="btn btn-primary ms-auto">Save changes</button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row mt-4">
                                    <div class="col-lg-6">
                                        <p>#encodeForHTML(qStandardVatType.strDescription)#</p>
                                        <label class="form-check form-check-inline">
                                            <input class="form-check-input" type="radio" name="#encodeForHTML(qStandardVatType.strSettingVariable)#" value="1" <cfif qStandardVatType.strDefaultValue eq 1 or qStandardVatType.strDefaultValue eq "">checked</cfif>>
                                            <span class="form-check-label small pt-1">Incl. VAT</span>
                                        </label>
                                        <label class="form-check form-check-inline">
                                            <input class="form-check-input" type="radio" name="#encodeForHTML(qStandardVatType.strSettingVariable)#" value="2" <cfif qStandardVatType.strDefaultValue eq 2>checked</cfif>>
                                            <span class="form-check-label small pt-1">Excl. VAT</span>
                                        </label>
                                        <label class="form-check form-check-inline">
                                            <input class="form-check-input" type="radio" name="#encodeForHTML(qStandardVatType.strSettingVariable)#" value="3" <cfif qStandardVatType.strDefaultValue eq 3>checked</cfif>>
                                            <span class="form-check-label small pt-1">No VAT</span>
                                        </label>
                                    </div>
                                    <div class="col-lg-6">
                                        <p>#encodeForHTML(qInvoiceNet.strDescription)#</p>
                                        <select name="#encodeForHTML(qInvoiceNet.strSettingVariable)#" class="form-select w-50">
                                            <option value="1" <cfif qInvoiceNet.strDefaultValue eq 1>selected</cfif>>Net</option>
                                            <option value="0" <cfif qInvoiceNet.strDefaultValue eq 0>selected</cfif>>Gross</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card-body">

                            <h3>Theme settings</h3>
                            <div class="border align-baseline p-3">
                                <cfloop array="#themeColors#" item="themeColor">
                                    <div class="mb-4">
                                        <div class="form-label" id="#themeColor.id#-label">#themeColor.label#</div>
                                        <div class="row g-2 align-items-center" role="radiogroup" aria-labelledby="#themeColor.id#-label">
                                            <cfloop array="#objTheme.choices(themeColor.setting)#" item="themeChoice">
                                                <cfif themeChoice.value eq "none">
                                                    <div class="col-auto">
                                                        <label class="form-colorinput form-colorinput-light" title="None">
                                                            <input name="#themeColor.setting#" type="radio" value="none" class="form-colorinput-input" aria-label="None" <cfif theme[themeColor.setting] eq "none">checked</cfif>>
                                                            <span class="form-colorinput-color theme-swatch-none"></span>
                                                        </label>
                                                    </div>
                                                <cfelseif themeChoice.value neq "custom">
                                                    <div class="col-auto">
                                                        <label class="form-colorinput" title="#encodeForHTMLAttribute(themeChoice.label)#">
                                                            <input name="#themeColor.setting#" type="radio" value="#encodeForHTMLAttribute(themeChoice.value)#" class="form-colorinput-input" aria-label="#encodeForHTMLAttribute(themeChoice.label)#" <cfif theme[themeColor.setting] eq themeChoice.value>checked</cfif>>
                                                            <span class="form-colorinput-color bg-#encodeForHTMLAttribute(themeChoice.value)#"></span>
                                                        </label>
                                                    </div>
                                                </cfif>
                                            </cfloop>
                                            <div class="col-auto d-flex align-items-center gap-2 ms-sm-2 ps-sm-3 border-start">
                                                <label class="form-colorinput" title="Custom color">
                                                    <input id="#themeColor.id#-custom" name="#themeColor.setting#" type="radio" value="custom" class="form-colorinput-input" aria-label="Custom color" <cfif theme[themeColor.setting] eq "custom">checked</cfif>>
                                                    <!--- themeSetting() only returns validated #rrggbb values --->
                                                    <span class="form-colorinput-color" style="background-color: #theme[themeColor.colorSetting]#"></span>
                                                </label>
                                                <label class="small mb-0" for="#themeColor.id#-custom-color">Custom color</label>
                                                <div class="theme-color-field" data-theme-custom-color="#themeColor.id#-custom">
                                                    <input type="text" id="#themeColor.id#-custom-color" class="form-control" name="#themeColor.colorSetting#" value="#encodeForHTMLAttribute(theme[themeColor.colorSetting])#" data-coloris pattern="##[0-9a-fA-F]{6}" maxlength="7" autocomplete="off" spellcheck="false" title="Hex color, e.g. ##1d3557">
                                                </div>
                                            </div>
                                        </div>
                                        <p class="form-hint mt-2">#themeColor.hint#</p>
                                    </div>
                                </cfloop>
                                <p class="form-hint mb-4">Tabler colors are tuned for light and dark mode. A custom color is used as chosen; text on it turns dark when its contrast with white is too low.</p>
                                <div class="row g-3">
                                    <cfloop array="#themeSelects#" item="themeSelect">
                                        <div class="col-md-6 col-xl-3">
                                            <label class="form-label" for="#themeSelect.setting#">#themeSelect.label#</label>
                                            <select id="#themeSelect.setting#" name="#themeSelect.setting#" class="form-select">
                                                <cfloop array="#objTheme.choices(themeSelect.setting)#" item="themeChoice">
                                                    <option value="#encodeForHTMLAttribute(themeChoice.value)#" <cfif theme[themeSelect.setting] eq themeChoice.value>selected</cfif>>#encodeForHTML(themeChoice.label)#</option>
                                                </cfloop>
                                            </select>
                                            <p class="form-hint">#themeSelect.hint#</p>
                                        </div>
                                    </cfloop>
                                </div>
                            </div>
                        </div>
                        <div class="card-body">
                            <h3>Layout settings</h3>
                            <div class="border align-baseline p-3">
                                <div class="col-12">
                                    <div class="row g-3">
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="horizontal" class="form-imagecheck-input" #getLayout.horizontal#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Horizontal</p>
                                                <img src="/backend/dist/img/layout/horizontal.png" alt="Horizontal" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="horizontalDark" class="form-imagecheck-input" #getLayout.horizontalDark#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Horizontal dark</p>
                                                <img src="/backend/dist/img/layout/horizontalDark.png" alt="Horizontal dark" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="navbarSticky" class="form-imagecheck-input" #getLayout.navbarSticky#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Navbar sticky</p>
                                                <img src="/backend/dist/img/layout/navbarSticky.png" alt="Navbar sticky" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="condensed" class="form-imagecheck-input" #getLayout.condensed#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Condensed</p>
                                                <img src="/backend/dist/img/layout/condensed.png" alt="Condensed" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="navbarDark" class="form-imagecheck-input" #getLayout.navbarDark#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Navbar dark</p>
                                                <img src="/backend/dist/img/layout/navbarDark.png" alt="Navbar dark" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="navbarOverlap" class="form-imagecheck-input" #getLayout.navbarOverlap#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Navbar overlap</p>
                                                <img src="/backend/dist/img/layout/navbarOverlap.png" alt="Navbar overlap" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="verticalTransparent" class="form-imagecheck-input" #getLayout.verticalTransparent#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Vertical</p>
                                                <img src="/backend/dist/img/layout/verticalTransparent.png" alt="Vertical transparent" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="vertical" class="form-imagecheck-input" #getLayout.vertical#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Vertical dark</p>
                                                <img src="/backend/dist/img/layout/vertical.png" alt="Vertical" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="rightVertical" class="form-imagecheck-input" #getLayout.rightVertical#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Right vertical</p>
                                                <img src="/backend/dist/img/layout/rightVertical.png" alt="Right vertical" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="combined" class="form-imagecheck-input" #getLayout.combined#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Combined</p>
                                                <img src="/backend/dist/img/layout/combined.png" alt="Combined" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="fluid" class="form-imagecheck-input" #getLayout.fluid#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Fluid</p>
                                                <img src="/backend/dist/img/layout/fluid.png" alt="Fluid" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="fluidVertical" class="form-imagecheck-input" #getLayout.fluidVertical#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Fluid vertical</p>
                                                <img src="/backend/dist/img/layout/fluidVertical.png" alt="Fluid vertical" class="form-imagecheck-image">
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



</div>

</cfoutput>
