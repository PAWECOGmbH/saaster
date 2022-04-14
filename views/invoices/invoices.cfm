<cfscript>
    qInvoices = createObject("component", "com.invoices").getInvoices(session.customer_id);
</cfscript>

<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <div class="container-xl">
        <cfoutput>
            <div class="row">
                <div class="page-header mb-3">
                    <h4 class="page-title">#getTrans('titInvoices')#</h4>
                    <ol class="breadcrumb breadcrumb-dots">
                        <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="#application.mainURL#/account-settings">#getTrans('txtAccountSettings')#</a></li>
                        <li class="breadcrumb-item active">#getTrans('titInvoices')#</li>
                    </ol>
                </div>
            </div>
            <cfif structKeyExists(session, "alert")>
                #session.alert#
            </cfif>
            <div class="row">
                <div class="col-md-12 col-lg-12">
                    <div class="card">
                        <div class="table-responsive">
                            <table class="table table-vcenter table-mobile-md card-table">
                                <thead>
                                    <tr>
                                        <th data-label="number">#getTrans('titInvoiceNumber')#</th>
                                        <th data-label="date">#getTrans('titInvoiceDate')#</th>
                                        <th data-label="title">#getTrans('titTitle')#</th>
                                        <th data-label="amount" class="text-end">#getTrans('titTotalAmount')#</th>
                                        <th data-label="status" class="text-center">#getTrans('titPaymentStatus')#</th>
                                        <th data-label="button" class="w-1"></th>
                                    </tr>
                                </thead>
                                <tbody>
                                <cfloop query="qInvoices">
                                    <tr>
                                        <td data-label="number">#qInvoices.invoiceNumber#</td>
                                        <td data-label="date">#lsDateFormat(qInvoices.invoiceDate)#</td>
                                        <td data-label="title">#qInvoices.invoiceTitle#</td>
                                        <td data-label="amount" class="text-end">#qInvoices.invoiceCurrency# #numberFormat(qInvoices.invoiceTotal, "__.__")#</td>
                                        <td data-label="status" class="text-center" style="color: #qInvoices.invoiceStatusColor#"><b>#getTrans(qInvoices.invoiceStatusVariable)#</b></td>
                                        <td data-label="button" class="text-end">
                                            <div class="btn-list flex-nowrap">
                                                
                                                <button type="button" class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown">
                                                    #getTrans('blnAction')#
                                                </button>
                                                <div class="dropdown-menu dropdown-menu-end">
                                                    <a class="dropdown-item" href="#application.mainURL#/account-settings/invoice/#qInvoices.invoiceID#">#getTrans('txtViewInvoice')#</a>
                                                    <a class="dropdown-item" href="#application.mainURL#/account-settings/invoice/print/#qInvoices.invoiceID#">#getTrans('txtPrintInvoice')#</a>
                                                    <cfif session.admin>
                                                        <a class="dropdown-item" style="cursor: pointer;" onclick="sweetAlert('warning', '#application.mainURL#/invoices?delete=#qInvoices.invoiceID#', '#getTrans("btnDeleteInvoice")#', '#getTrans("txtDeleteInvoiceConfirmText")#', '#getTrans("btnNoCancel")#', '#getTrans("btnYesDelete")#')">#getTrans('btnDeleteInvoice')#</a>
                                                    </cfif>
                                                </div>
                                                
                                            </div>

                                        </td>
                                    </tr>
                                </cfloop>
                                </tbody>
                                <!--- <cfif qInvoices.recordCount lte 2>
                                    <!--- Spacer in order to show the action button correctly --->
                                    <tr><td colspan="100%"><br /><br /><br /></td></tr>


                                </cfif> --->
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </cfoutput>

    </div>
</div>

<cfinclude template="/includes/footer.cfm">


