<cfscript>

    // Exception handling for sef and invoice id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisInvoiceID = thiscontent.thisID

    if (!isNumeric(thisInvoiceID) or thisInvoiceID lte 0) {
        location url="#application.mainURL#/account-settings/invoices" addtoken="false";
    }

    // Get the invoice data
    objInvoices = new backend.core.com.invoices();
    getInvoiceData = objInvoices.getInvoiceData(thisInvoiceID);
    if(not isStruct(getInvoiceData) or not arrayLen(getInvoiceData.positions)){
        location url="#application.mainURL#/account-settings/invoices" addtoken="false";
    }

    // Is the user allowed to see this invoice?
    checkTenantRange = application.objGlobal.checkTenantRange(session.user_id, getInvoiceData.customerID)
    if (not checkTenantRange) {
        location url="#application.mainURL#/account-settings/invoices" addtoken="false";
    }

    // The user has canceled the Payrexx payment, make log
    if (structKeyExists(url, "psp_response") and url.psp_response eq "cancel") {
        logWrite("user", "info", "Pay invoice: The user has canceled the Payrexx payment process [CustomerID: #session.customer_id#, UserID: #session.user_id#, InvoiceID: #thisInvoiceID#]");
    }

    // Get customer data
    getCustomerData = application.objCustomer.getCustomerData(getInvoiceData.customerID);

    // Get invoice address block
    addressBlock = objInvoices.getInvoiceAddress(thisInvoiceID);

    // Get existent payments
    qPayments = objInvoices.getInvoicePayments(thisInvoiceID);

    // Get sysadmin data
    sysAdminData = new backend.core.com.sysadmin().getSysAdminData();

</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">#getTrans('titInvoice')#</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings/invoices">#getTrans('titInvoices')#</a></li>
                            <li class="breadcrumb-item active">#getInvoiceData.title#</li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="#application.mainURL#/account-settings/invoice/print/#thisInvoiceID#" target="_blank" class="btn btn-primary">
                            <i class="fas fa-print pe-2"></i> #getTrans('txtPrintInvoice')#
                        </a>
                    </div>
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="#getLayout.layoutPage#">
            <div class="card card-lg" style="padding: 0 12%;">
                <div class="card-body">
                    <div class="row">
                        <div class="w-10 h1">
                            #objInvoices.getInvoiceStatusBadge(session.lng, getInvoiceData.paymentstatusColor, getInvoiceData.paymentstatusVar)#
                        </div>
                        <div class="col-12 mt-5">
                            <cfif len(trim(sysAdminData.logo))>
                                <img alt="Logo" src="#application.mainURL#/userdata/images/logos/#sysAdminData.logo#" style="display: block; max-width: 250px; float: right;" border="0">
                            <cfelse>
                                <img alt="Logo" src="#application.mainURL#/dist/img/logo.png" style="display: block; max-width: 250px; float: right;" border="0">
                            </cfif>
                        </div>
                        <div class="col-6">
                            <address class="mt-2">
                                #addressBlock#
                            </address>
                        </div>
                        <div class="col-12 mt-5">
                            <p><b>#getTrans('titInvoice')# #getInvoiceData.number#</b></p>
                            <hr class="my-1">
                            <p class="mt-2 h3">#getInvoiceData.title#</p>
                            <hr class="my-1">
                        </div>

                        <div class="row mt-2">
                            <div class="col-lg-6">
                                <div class="row">
                                    <div class="col-md-4">#getTrans('titInvoiceDate')#:</div>
                                    <div class="col-md-8">#lsDateFormat(getTime.utc2local(utcDate=getInvoiceData.date))#</div>
                                </div>
                                <div class="row pb-4">
                                    <div class="col-md-4">#getTrans('txtDueDate')#:</div>
                                    <div class="col-md-8">#lsDateFormat(getTime.utc2local(utcDate=getInvoiceData.dueDate))#</div>
                                </div>
                            </div>
                            <div class="col-lg-6">
                                #replace(getCustomerData.billingInfo, chr(13), "<br />")#
                            </div>
                            <hr class="m-0">
                        </div>
                        <table class="table table-transparent table-responsive">
                            <thead>
                                <tr>
                                    <th width="5%" class="pl-0">#getTrans('titPos')#</th>
                                    <th width="50%">#getTrans('titDescription')#</th>
                                    <th width="15%" class="text-end">#getTrans('titQuantity')#</th>
                                    <th width="15%" class="text-end">#getTrans('titSinglePrice')#</th>
                                    <th width="5%" class="text-end">#getTrans('titDiscount')#</th>
                                    <th width="10%" class="text-end pr-0">#getTrans('titTotal')# #getInvoiceData.currency#</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop array="#getInvoiceData.positions#" index="pos">
                                    <tr>
                                        <td valign="top" class="pl-0">#pos.posNumber#</td>
                                        <td valign="top">
                                            <p class="mb-1"><b>#pos.title#</b></p>
                                            <div class="text-muted">#pos.description#</div>
                                        </td>
                                        <td valign="top" class="text-end">#lsCurrencyFormat(pos.quantity, "none")# #pos.unit#</td>
                                        <td valign="top" class="text-end">
                                            <p class="m-0">#lsCurrencyFormat(pos.singlePrice, "none")#</p>
                                            <cfif pos.vat gt 0>
                                                <p class="text-muted small">(#pos.vat#%)</p>
                                            </cfif>
                                        </td>
                                        <td valign="top" class="text-end"><cfif pos.discountPercent gt 0>#pos.discountPercent#%</cfif></td>
                                        <td valign="top" class="text-end pr-0">#lsCurrencyFormat(pos.totalPrice, "none")#</td>
                                    </tr>
                                </cfloop>
                                <tr>
                                    <td></td>
                                    <td colspan="4"><b>#getTrans('titTotal')#</b></td>
                                    <td class="text-end pr-0"><b>#lsCurrencyFormat(getInvoiceData.subtotal, "none")#</b></td>
                                </tr>


                                <cfif arrayLen(getInvoiceData.vatArray)>
                                    <tr><td colspan="100%" style="border: 0;" class="py-1"></td></tr>
                                    <cfloop array="#getInvoiceData.vatArray#" index="vat">
                                        <tr>
                                            <td class="pb-1 pt-0" style="border: 0;"></td>
                                            <td colspan="4" class="pb-1 pt-0 small" style="border: 0;">#vat.vatText#</td>
                                            <td class="pb-1 pt-0 text-end small" style="border: 0;">#lsCurrencyFormat(vat.amount, "none")#</td>
                                        </tr>
                                    </cfloop>

                                    <tr><td colspan="100%" style="border: 0;" class="py-1"></td></tr>

                                </cfif>
                                <tr>
                                    <td style="border-top: 1px solid;"></td>
                                    <td style="border-top: 1px solid;" colspan="4"><b>#getInvoiceData.totaltext#</b></td>
                                    <td style="border-top: 1px solid;" class="text-end pr-0"><b>#lsCurrencyFormat(getInvoiceData.total, "none")#</b></td>
                                </tr>
                                <cfif qPayments.recordCount>
                                    <cfloop query="qPayments">
                                        <tr>
                                            <td style="border-top: 1px solid;"></td>
                                            <td style="border-top: 1px solid;" colspan="4">#getTrans('txtIncoPayments')# #lsDateFormat(getTime.utc2local(utcDate=qPayments.dtmPayDate))# (#qPayments.strPaymentType#):</td>
                                            <td style="border-top: 1px solid;" class="text-end pr-0">- #lsCurrencyFormat(qPayments.decAmount, "none")#</td>
                                        </tr>

                                    </cfloop>

                                    <tr>
                                        <td style="border-top: 2px inset;"></td>
                                        <td style="border-top: 2px inset;" colspan="4"><b>#getTrans('txtRemainingAmount')#</b></td>
                                        <td style="border-top: 2px inset;" class="text-end pr-0"><b>#lsCurrencyFormat(getInvoiceData.amountOpen, "none")#</b></td>
                                    </tr>
                                </cfif>

                                <tr><td colspan="100%" style="border-top: 3px double; border-bottom: 0;"></td></tr>
                            </tbody>
                        </table>
                        <cfif getInvoiceData.amountOpen gt 0>
                            <div class="row pe-0">
                                <div class="text-end pe-0">
                                    <div class="dropdown">
                                        <button type="button" class="btn btn-green dropdown-toggle" data-bs-toggle="dropdown">
                                            <i class="fas fa-coins pe-2  activate-lock"></i> #getTrans('txtPayInvoice')#
                                        </button>
                                        <div class="dropdown-menu">
                                            <a href="#application.mainURL#/payment-settings?pay=#thisInvoiceID#" class="dropdown-item activate-module">
                                                #getTrans('btnDepPayMethod')#
                                            </a>
                                            <a href="#application.mainURL#/payment-settings?pay=#thisInvoiceID#&other" class="dropdown-item activate-module">
                                                #getTrans('btnOtherPayMethod')#
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    

</div>