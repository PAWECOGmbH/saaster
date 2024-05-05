<cfscript>
    param name="session.invoice_c_page" default=1 type="numeric";
    objInvoice = new backend.core.com.invoices();
    getEntries = 20;
    invoice_start = 0;

    qTotalInvoices = objInvoice.getInvoices(session.customer_id).totalCount;
    pages = ceiling(qTotalInvoices / getEntries);

    // Check if url "page" exists and if it matches the requirments
    if (structKeyExists(url, "page") and isNumeric(url.page) and not url.page lte 0 and not url.page gt pages) {
        session.invoice_c_page = url.page;
    } else {
        if (qTotalInvoices gt 0) {
            location url="#application.mainurl#/account-settings/invoices?page=1" addtoken="false";
        }
    }

    if (session.invoice_c_page gt 1){
        tPage = session.invoice_c_page - 1;
        valueToAdd = 20 * tPage;
        invoice_start = invoice_start + valueToAdd;
    }

    qInvoices = objInvoice.getInvoices(session.customer_id, invoice_start, getEntries, 'intInvoiceNumber DESC');
</cfscript>



<cfoutput>
<div class="page-wrapper">
    <div class="#getLayout.layoutPage#">
            <div class="row">
                <div class="#getLayout.layoutPageHeader# mb-3">
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

            <cfif !ArrayIsEmpty(qInvoices.arrayInvoices)>
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
                                    <cfloop array="#qInvoices.arrayInvoices#" index="i">
                                        <tr>
                                            <td>#i.invoiceNumber#</td>
                                            <td>#lsDateFormat(getTime.utc2local(utcDate=i.invoiceDate))#</td>
                                            <td>#lsDateFormat(getTime.utc2local(utcDate=i.invoiceDueDate))#</td>
                                            <td>#i.invoiceTitle#</td>
                                            <td class="text-end">#i.invoiceCurrency# #lsCurrencyFormat(i.invoiceTotal, "none")#</td>
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
                <cfif pages neq 1>
                    <div class="card-body">
                        <ul class="pagination justify-content-center" id="pagination">

                            <!--- First page --->
                            <li class="page-item <cfif session.invoice_c_page eq 1>disabled</cfif>">
                                <a class="page-link" href="#application.mainURL#/account-settings/invoices?page=1" tabindex="-1" aria-disabled="true">
                                    <i class="fas fa-angle-double-left"></i>
                                </a>
                            </li>

                            <!--- Prev arrow --->
                            <li class="page-item <cfif session.invoice_c_page eq 1>disabled</cfif>">
                                <a class="page-link" href="#application.mainURL#/account-settings/invoices?page=#session.invoice_c_page-1#" tabindex="-1" aria-disabled="true">
                                    <i class="fas fa-angle-left"></i>
                                </a>
                            </li>

                            <!--- Pages --->
                            <cfif session.invoice_c_page + 4 gt pages>
                                <cfset blockPage = pages>
                            <cfelse>
                                <cfset blockPage = session.invoice_c_page + 4>
                            </cfif>

                            <cfif blockPage neq pages>
                                <cfloop index="j" from="#session.invoice_c_page#" to="#blockPage#">
                                    <cfif not blockPage gt pages>
                                        <li class="page-item <cfif session.invoice_c_page eq j>active</cfif>">
                                            <a class="page-link" href="#application.mainURL#/account-settings/invoices?page=#j#">#j#</a>
                                        </li>
                                    </cfif>
                                </cfloop>
                            <cfelseif blockPage lt 5>
                                <cfloop index="j" from="1" to="#pages#">
                                    <li class="page-item <cfif session.invoice_c_page eq j>active</cfif>">
                                        <a class="page-link" href="#application.mainURL#/account-settings/invoices?page=#j#">#j#</a>
                                    </li>
                                </cfloop>
                            <cfelse>
                                <cfloop index="j" from="#pages - 4#" to="#pages#">
                                        <li class="page-item <cfif session.invoice_c_page eq j>active</cfif>">
                                            <a class="page-link" href="#application.mainURL#/account-settings/invoices?page=#j#">#j#</a>
                                        </li>
                                </cfloop>
                            </cfif>

                            <!--- Next arrow --->
                            <li class="page-item <cfif session.invoice_c_page gte pages>disabled</cfif>">
                                <a class="page-link" href="#application.mainURL#/account-settings/invoices?page=#session.invoice_c_page+1#">
                                    <i class="fas fa-angle-right"></i>
                                </a>
                            </li>

                            <!--- Last page --->
                            <li class="page-item <cfif session.invoice_c_page gte pages>disabled</cfif>">
                                <a class="page-link" href="#application.mainURL#/account-settings/invoices?page=#pages#">
                                    <i class="fas fa-angle-double-right"></i>
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

    </div>
    

</div>
</cfoutput>