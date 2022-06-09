<cfscript>
    param name="session.invoice_page" default=1 type="numeric";
    local.objInvoice = new com.invoices();
    local.getEntries = 20;
    local.invoice_start = 0;

    local.qTotalInvoices = objInvoice.getInvoices(session.customer_id).totalCount;
    local.pages = ceiling(local.qTotalInvoices / local.getEntries);

    // Check if url "page" exists and if it matches the requirments
    if (structKeyExists(url, "page") and isNumeric(url.page) and not url.page lte 0 and not url.page gt local.pages) {
        session.invoice_page = url.page;
    } else {
        if (local.qTotalInvoices gt 0) {
            location url="#application.mainurl#/account-settings/invoices?page=1" addtoken="false";
        }
    }

    if (session.invoice_page gt 1){
        local.tPage = session.invoice_page - 1;
        local.valueToAdd = 20 * tPage;
        local.invoice_start = local.invoice_start + local.valueToAdd;
    }

    local.qInvoices = objInvoice.getInvoices(session.customer_id,local.invoice_start,local.getEntries);
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

            <cfif !ArrayIsEmpty(local.qInvoices.arrayInvoices)>
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
                                    <cfloop index="i" array="#local.qInvoices.arrayInvoices#">
                                        <tr>
                                            <td>#i.invoiceNumber#</td>
                                            <td>#lsDateFormat(getTime.utc2local(utcDate=i.invoiceDate))#</td>
                                            <td>#lsDateFormat(getTime.utc2local(utcDate=i.invoiceDueDate))#</td>
                                            <td>#i.invoiceTitle#</td>
                                            <td class="text-end">#i.invoiceCurrency# #lsNumberFormat(i.invoiceTotal)#</td>
                                            <td class="text-center">#objInvoice.getInvoiceStatusBadge(session.lng, i.invoiceStatusColor, i.invoiceStatusVariable)#</td>
                                            <td class="text-end">
                                                <div class="btn-list flex-nowrap">
                                                    <button type="button" class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown">
                                                        #getTrans('blnAction')#
                                                    </button>
                                                    <div class="dropdown-menu dropdown-menu-end">
                                                        <a class="dropdown-item" href="#application.mainURL#/account-settings/invoice/#i.invoiceID#">#getTrans('txtViewInvoice')#</a>
                                                        <a class="dropdown-item" href="#application.mainURL#/account-settings/invoice/print/#i.invoiceID#">#getTrans('txtPrintInvoice')#</a>
                                                    </div>
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
                <cfif local.pages neq 1>
                    <div class="card-body">
                        <ul class="pagination justify-content-center" id="pagination">

                            <!--- Prev arrow --->
                            <li class="page-item <cfif session.invoice_page eq 1>disabled</cfif>">
                                <a class="page-link" href="#application.mainURL#/account-settings/invoices?page=#session.invoice_page-1#" tabindex="-1" aria-disabled="true">
                                    <i class="fas fa-angle-left"></i>
                                </a>
                            </li>

                            <!--- Pages --->
                            <cfloop index="i" from="1" to="#local.pages#">
                                <li class="page-item <cfif session.invoice_page eq i>active</cfif>">
                                    <a class="page-link" href="#application.mainURL#/account-settings/invoices?page=#i#">#i#</a>
                                </li>
                            </cfloop>

                            <!--- Next arrow --->
                            <li class="page-item <cfif session.invoice_page gte local.pages>disabled</cfif>">
                                <a class="page-link" href="#application.mainURL#/account-settings/invoices?page=#session.invoice_page+1#">
                                    <i class="fas fa-angle-right"></i>
                                </a>
                            </li>
                        </ul>
                    </div>
                </cfif>
            <cfelse>
                <div class="alert alert-primary" role="alert">
                    #getTrans('txtNoInvoices')#
                </div>
            </cfif>
        </cfoutput>

    </div>
</div>

<cfinclude template="/includes/footer.cfm">


