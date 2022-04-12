<cfscript>
    objInvoice = createObject("component", "com.invoices");
    qInvoices = objInvoice.getInvoices(session.customer_id);
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
                <cfif structKeyExists(session, "alert")>
                    #session.alert#
                </cfif>
            </div>
            <div class="row">
                <div class="col-md-12 col-lg-12">
                    <div class="card">
                        <div class="table-responsive">
                            <table class="table table-vcenter table-mobile-md card-table">
                                <thead>
                                    <tr>
                                        <th>#getTrans('titInvoiceNumber')#</th>
                                        <th>#getTrans('titInvoiceDate')#</th>
                                        <th>#getTrans('txtDueDate')#</th>
                                        <th>#getTrans('titTitle')#</th>
                                        <th class="text-end">#getTrans('titTotalAmount')#</th>
                                        <th class="text-center">#getTrans('titPaymentStatus')#</th>
                                        <th class="w-1"></th>
                                    </tr>
                                </thead>
                                <tbody>
                                <cfloop query="qInvoices">
                                    <tr>
                                        <td>#qInvoices.invoiceNumber#</td>
                                        <td>#lsDateFormat(qInvoices.invoiceDate)#</td>
                                        <td>#lsDateFormat(qInvoices.invoiceDueDate)#</td>
                                        <td>#qInvoices.invoiceTitle#</td>
                                        <td class="text-end">#qInvoices.invoiceCurrency# #numberFormat(qInvoices.invoiceTotal, "__.__")#</td>
                                        <td class="text-center">#objInvoice.getInvoiceStatusBadge(session.lng, qInvoices.invoiceStatusColor, qInvoices.invoiceStatusVariable)#</td>
                                        <td class="text-end">
                                            <div class="btn-list flex-nowrap">
                                                <span class="dropdown">
                                                    <button type="button" class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown">
                                                        #getTrans('blnAction')#
                                                    </button>
                                                    <div class="dropdown-menu dropdown-menu-end">
                                                        <a class="dropdown-item" href="#application.mainURL#/account-settings/invoice/#qInvoices.invoiceID#">#getTrans('txtViewInvoice')#</a>
                                                        <a class="dropdown-item" href="#application.mainURL#/account-settings/invoice/print/#qInvoices.invoiceID#">#getTrans('txtPrintInvoice')#</a>
                                                    </div>
                                                </span>
                                            </div>

                                        </td>
                                    </tr>
                                </cfloop>
                                </tbody>

                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </cfoutput>

    </div>
</div>

<cfinclude template="/includes/footer.cfm">


