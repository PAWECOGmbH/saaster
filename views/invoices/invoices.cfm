<cfscript>
    param name="session.invoice_start" default=1 type="numeric";
    local.getEntries = 20;

    // Check if url "start" exists and if it matches the requirments
    if (structKeyExists(url, "start")) {
        if(not isNumeric(url.start))
            location url="#application.mainurl#/account-settings/invoices?start=1" addtoken="false";

        if (sgn(url.start) eq "-1")
            location url="#application.mainurl#/account-settings/invoices?start=1" addtoken="false";
            
        session.invoice_start = url.start;
    }

    // Pagination
    local.next = session.invoice_start+getEntries;
    local.prev = session.invoice_start-getEntries;
    session.invoice_sql_start = session.invoice_start-1;
    
    local.objInvoice = new com.invoices();
    local.qInvoices = objInvoice.getInvoices(session.customer_id,session.invoice_sql_start,local.getEntries);

    //Redirect if value larger then total invoices
    if (structKeyExists(url, "start") and url.start GT local.qInvoices.totalCount)
        location url="#application.mainurl#/account-settings/invoices?start=1" addtoken="false";

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
                                <cfloop index="i" array="#local.qInvoices.arrayInvoices#">
                                    <!--- <cfdump  var="#i.invoiceCurrency#"> --->
                                    <tr>
                                        <td>#i.invoiceNumber#</td>
                                        <td>#lsDateFormat(i.invoiceDate)#</td>
                                        <td>#lsDateFormat(i.invoiceDueDate)#</td>
                                        <td>#i.invoiceTitle#</td>
                                        <td class="text-end">#i.invoiceCurrency# #lsNumberFormat(i.invoiceTotal, '__,___.__')#</td>
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
            <div class="pt-4 card-footer d-flex align-items-center">
                <ul class="pagination m-0 ms-auto">
                    <li class="page-item <cfif session.invoice_start lt getEntries>disabled</cfif>">
                        <a class="page-link" href="#application.mainURL#/account-settings/invoices?start=#local.prev#" tabindex="-1" aria-disabled="true">
                            <i class="fas fa-angle-left"></i> prev
                        </a>
                    </li>
                    <li class="ms-3 page-item <cfif local.qInvoices.totalCount lt next>disabled</cfif>">
                        <a class="page-link" href="#application.mainURL#/account-settings/invoices?start=#local.next#">
                            next <i class="fas fa-angle-right"></i>
                        </a>
                    </li>
                </ul>
            </div>
        </cfoutput>

    </div>
</div>

<cfinclude template="/includes/footer.cfm">


