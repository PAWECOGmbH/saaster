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
    qLayout = objSysadmin.getSystemSetting('settingLayout');
    qColorPrimary = objSysadmin.getSystemSetting('settingColorPrimary');
    qColorSecondary = objSysadmin.getSystemSetting('settingColorSecondary');
    qSwissQrBill = objSysadmin.getSystemSetting('settingSwissQrBill');
    qSwissQrIBAN = objSysadmin.getSystemSetting('settingIBANnumber');
    qSwissQrRef = objSysadmin.getSystemSetting('settingQRreference');
    customerData = application.objSysAdmin.getSysAdminData();
    countryData = application.objCustomer.getUserDataByID(customerData.customerID);


</cfscript>


<cfoutput>
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
                                        <select name="#qRoundFactor.strSettingVariable#" class="form-select w-50" id="roundFactorSelect">
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
                                        <div id="QrBillContainer" style="display: none;">
                                            <div class="row">
                                                <p>#qSwissQrBill.strDescription#</p>
                                                <div class="col-lg-4">
                                                    <select name="#qSwissQrBill.strSettingVariable#" class="form-select w-50" id="QrBillCheckbox">
                                                        <option value="0" <cfif qSwissQrBill.strDefaultValue eq 0>selected</cfif>>No</option>
                                                        <option value="1" <cfif qSwissQrBill.strDefaultValue eq 1>selected</cfif>>Yes</option>
                                                    </select>
                                                </div>
                                                <div class="col-lg-8">
                                                    <a href="##" id="extraLink" class="btn" style="display: none;" data-bs-toggle="modal" data-bs-target="##qr_data">Manage QR data</a>
                                                </div>
                                            </div>
                                            <div id="qr_data" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
                                                <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">Swiss QR invoice data</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <div class="row mb-3">
                                                                <div class="col-lg-6">
                                                                    <b>Invoice address:</b><br /><br />
                                                                    #customerData.companyName#<br />
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
                                                            <div class="mb-3">
                                                                <label class="form-label">IBAN number:</label>
                                                                <input type="text" name="settingIBANnumber" class="form-control" autocomplete="off" value="#qSwissQrIBAN.strDefaultValue#" maxlength="30">
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label">QR reference number:</label>
                                                                <input type="text" name="settingQRreference" class="form-control" autocomplete="off" value="#qSwissQrRef.strDefaultValue#" maxlength="30">
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
                                            <option value="1" <cfif qInvoiceNet.strDefaultValue eq 1>selected</cfif>>Net</option>
                                            <option value="0" <cfif qInvoiceNet.strDefaultValue eq 0>selected</cfif>>Gross</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card-body">

                            <h3>Button settings</h3>
                            <div class="border align-baseline p-3">
                                <div class="row">
                                    <div class="col-lg-3 mb-1 d-flex justify-content-between align-items-center">
                                        <p class="no-margin">#qColorPrimary.strDescription#</p>
                                        <input type="color" class="form-control form-control-color color-width" name="#qColorPrimary.strSettingVariable#" value="#qColorPrimary.strDefaultValue#">
                                    </div>
                                    <div class="col-lg-1"></div>
                                    <div class="col-lg-3 mb-1 d-flex justify-content-between align-items-center">
                                        <p class="no-margin">#qColorSecondary.strDescription#</p>
                                        <input type="color" class="form-control form-control-color color-width" name="#qColorSecondary.strSettingVariable#" value="#qColorSecondary.strDefaultValue#">
                                    </div>
                                    <div class="col-lg-5"></div>
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
                                                <img src="../dist/img/layout/horizontal.png" alt="Horizontal" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="horizontalDark" class="form-imagecheck-input" #getLayout.horizontalDark#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Horizontal dark</p>
                                                <img src="../dist/img/layout/horizontalDark.png" alt="Horizontal dark" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="navbarSticky" class="form-imagecheck-input" #getLayout.navbarSticky#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Navbar sticky</p>
                                                <img src="../dist/img/layout/navbarSticky.png" alt="Navbar sticky" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="condensed" class="form-imagecheck-input" #getLayout.condensed#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Condensed</p>
                                                <img src="../dist/img/layout/condensed.png" alt="Condensed" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="navbarDark" class="form-imagecheck-input" #getLayout.navbarDark#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Navbar dark</p>
                                                <img src="../dist/img/layout/navbarDark.png" alt="Navbar dark" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="navbarOverlap" class="form-imagecheck-input" #getLayout.navbarOverlap#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Navbar overlap</p>
                                                <img src="../dist/img/layout/navbarOverlap.png" alt="Navbar overlap" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="verticalTransparent" class="form-imagecheck-input" #getLayout.verticalTransparent#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Vertical</p>
                                                <img src="../dist/img/layout/verticalTransparent.png" alt="Vertical transparent" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="vertical" class="form-imagecheck-input" #getLayout.vertical#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Vertical dark</p>
                                                <img src="../dist/img/layout/vertical.png" alt="Vertical" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="rightVertical" class="form-imagecheck-input" #getLayout.rightVertical#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Right vertical</p>
                                                <img src="../dist/img/layout/rightVertical.png" alt="Right vertical" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="combined" class="form-imagecheck-input" #getLayout.combined#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Combined</p>
                                                <img src="../dist/img/layout/combined.png" alt="Combined" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="fluid" class="form-imagecheck-input" #getLayout.fluid#/>
                                                <span class="form-imagecheck-figure"><p style="margin:2px 30px; display:block;">Fluid</p>
                                                <img src="../dist/img/layout/fluid.png" alt="Fluid" class="form-imagecheck-image">
                                                </span>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-6 col-lg-4">
                                            <label class="form-imagecheck mb-2">
                                                <input name="settingLayout" type="radio" value="fluidVertical" class="form-imagecheck-input" #getLayout.fluidVertical#/>
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

    

</div>

</cfoutput>