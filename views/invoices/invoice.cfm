<cfscript>
    // Exception handling for sef and invoice id
    param name="thiscontent.thisID" default=0 type="numeric";
    thisInvoiceID = thiscontent.thisID

    if(not isNumeric(thisInvoiceID) or thisInvoiceID lte 0) {
        location url="#application.mainURL#/account-settings/invoices" addtoken="false";
    }

    // Get the invoice data
    getInvoiceData = createObject("component", "com.invoices").getInvoiceData(thisInvoiceID);
    if(not isStruct(getInvoiceData) or not arrayLen(getInvoiceData.positions)){
        location url="#application.mainURL#/account-settings/invoices" addtoken="false";
    }

    // Is the user allowed to see this invoice
    checkTenantRange = application.objGlobal.checkTenantRange(session.user_id, getInvoiceData.customerID)
    if (not checkTenantRange) {
        location url="#application.mainURL#/account-settings/invoices" addtoken="false";
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
                        <h4 class="page-title">#getTrans('titInvoice')#</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings/invoices">#getTrans('titInvoices')#</a></li>
                            <li class="breadcrumb-item active">#getInvoiceData.title#</li>
                        </ol>
                    </div>
                    <div class="page-header col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="#application.mainURL#/account-settings/invoice/print/#thisInvoiceID#" target="_blank" class="btn btn-primary">
                            <i class="fas fa-print pe-3"></i> #getTrans('txtPrintInvoice')#
                        </a>
                    </div>
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
        </div>
        <div class="container-xl">
            <div class="card card-lg ps-5 pe-5">
                <div class="card-body">
                    <div class="row ps-5 pe-5">
                        <div class="col-6 mt-5">
                            <address class="mt-5">
                                #getCustomerData.strBillingAccountName#<br />
                                #replace(getCustomerData.strBillingAddress, chr(13), "<br />")#
                            </address>
                        </div>
                        <div class="col-6 text-end">
                            <cfif len(trim(getCustomerData.strLogo))>
                                <img src="#application.mainURL#/userdata/images/logos/#getCustomerData.strLogo#" alt="logo" style="max-height: 100px;">
                            </cfif>
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
                                    <div class="col-md-8">#dateFormat(getInvoiceData.date, "dd.mm.yyyy")#</div>
                                </div>
                                <div class="row pb-4">
                                    <div class="col-md-4">#getTrans('txtDueDate')#:</div>
                                    <div class="col-md-8">#dateFormat(getInvoiceData.dueDate, "dd.mm.yyyy")#</div>
                                </div>
                            </div>
                            <div class="col-lg-6">
                                #replace(getCustomerData.strBillingInfo, chr(13), "<br />")#
                            </div>
                            <hr class="m-0">
                        </div>
                        <table class="table table-transparent table-responsive">
                            <thead>
                                <tr>
                                    <th class="w-5 pl-0">#getTrans('titPos')#</th>
                                    <th>#getTrans('titDescription')#</th>
                                    <th class="text-end w-15">#getTrans('titQuantity')#</th>
                                    <th class="text-end w-10">#getTrans('titSinglePrice')#</th>
                                    <th class="text-center w-10">#getTrans('titDiscount')#</th>
                                    <th class="text-end w-10 pr-0">#getTrans('titTotal')# #getInvoiceData.currency#</th>
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
                                        <td valign="top" class="text-end">#numberFormat(pos.quantity, "__.__")# #pos.unit#</td>
                                        <td valign="top" class="text-end">
                                            <p class="m-0">#lsnumberFormat(pos.singlePrice, "_,___.__")#</p>
                                            <p class="text-muted small">(#numberFormat(pos.vat, "__.__")#%)</p>
                                        </td>
                                        <td valign="top" class="text-center">#pos.discountPercent#%</td>
                                        <td valign="top" class="text-end pr-0">#lsnumberFormat(pos.totalPrice, "_,___.__")#</td>
                                    </tr>
                                </cfloop>
                                <tr>
                                    <td></td>
                                    <td colspan="4"><b>#getTrans('titTotal')#</b></td>
                                    <td class="text-end pr-0"><b>#lsnumberFormat(getInvoiceData.subtotal, "_,___.__")#</b></td>
                                </tr>
                                <cfif arrayLen(getInvoiceData.vatArray)>
                                    <tr><td colspan="100%" style="border: 0;" class="py-1"></td></tr>
                                    <cfloop array="#getInvoiceData.vatArray#" index="vat">
                                        <tr>
                                            <td class="pb-1 pt-0" style="border: 0;"></td>
                                            <td colspan="4" class="pb-1 pt-0 small" style="border: 0;">#vat.vatText#</td>
                                            <td class="pb-1 pt-0 text-end small" style="border: 0;">#lsnumberFormat(vat.amount, "_,___.__")#</td>
                                        </tr>
                                    </cfloop>
                                    <tr><td colspan="100%" style="border: 0;" class="py-1"></td></tr>
                                </cfif>
                                <tr>
                                    <td style="border-top: 1px solid;"></td>
                                    <td style="border-top: 1px solid;" colspan="4"><b>#getInvoiceData.totaltext#</b></td>
                                    <td style="border-top: 1px solid;" class="text-end pr-0"><b>#lsnumberFormat(getInvoiceData.total, "_,___.__")#</b></td>
                                </tr>
                                <tr><td colspan="100%" style="border-top: 3px double; border-bottom: 0;"></td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
</div>