
<cfscript>
    param name="session.i_search" default="" type="string";
    param name="session.i_sort" default="invoiceNumber DESC" type="string";
    param name="session.status" default=0 type="numeric";
    param name="session.invoice_page" default=1 type="numeric";
    param name="session.status_sql" default="";

    objSysadmin = new backend.core.com.sysadmin();
    objInvoice = new backend.core.com.invoices();

    getEntries = 10;
    invoice_start = 0;

    // Status
    if(structKeyExists(form, 'status')){
        session.status = form.status;
        if (session.status gt 0) {
            session.status_sql = "AND invoices.intPaymentStatusID = #session.status#";
        }else {
            session.status_sql = "";
        }
    }

    // Search
    if(structKeyExists(form, 'search') and len(trim(form.search))){
        session.i_search = form.search;
    }else if (structKeyExists(form, 'delete') or structKeyExists(url, 'delete')) {
        session.i_search = '';
    }

    // Sorting
    if(structKeyExists(form, 'sort')){
        session.i_sort = form.sort;
    }

    // Filter out unsupport search characters
    searchTerm = ReplaceList(trim(session.i_search),'##,<,>,/,{,},[,],(,),+,,{,},?,*,",'',',',,,,,,,,,,,,,,,');
    searchTerm = replace(searchTerm,' - ', "-", "all");

    if (len(trim(searchTerm))) {
        if (FindNoCase("@",searchTerm)){
            searchString = 'AGAINST (''"#searchTerm#"'' IN BOOLEAN MODE)'
        }else {
            searchString = 'AGAINST (''*''"#searchTerm#"''*'' IN BOOLEAN MODE)'
        }

        qTotalInvoices = objSysadmin.getTotalInvoicesSearch(searchString, searchTerm, invoice_start, session.status_sql, session.i_sort);
    } else {

        qTotalInvoices = objSysadmin.getTotalInvoices(session.status_sql);
    }

    pages = ceiling(qTotalInvoices.totalInvoices / getEntries);

    // Check if url "page" exists and if it matches the requirments
    if (structKeyExists(url, "page") and isNumeric(url.page) and not url.page lte 0 and not url.page gt pages) {
        session.invoice_page = url.page;
    }

    if (session.invoice_page gt 1){
        tPage = session.invoice_page - 1;
        valueToAdd = getEntries * tPage;
        invoice_start = invoice_start + valueToAdd;
    }

    if (len(trim(searchTerm))) {

        qInvoices = objSysadmin.getAllInvoicesSearch(searchString, searchTerm, invoice_start, session.status_sql, session.i_sort);
    } else {

        qInvoices = objSysadmin.getAllInvoices(invoice_start, session.status_sql, session.i_sort);
    }

</cfscript>



<div class="page-wrapper">
    <cfoutput>
        <div class="#getLayout.layoutPage#">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="#getLayout.layoutPageHeader# col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Invoices</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Invoices</li>
                        </ol>
                    </div>
                    <div class="#getLayout.layoutPageHeader# col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
                        <a href="##" data-bs-toggle="modal" data-bs-target="##invoice_new" class="btn btn-primary">
                            <i class="fas fa-plus pe-3"></i> New invoice
                        </a>
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
                            <h3 class="card-title">Invoices overview #searchTerm#</h3>
                        </div>
                        <div class="card-body">
                            <form action="#application.mainURL#/sysadmin/invoices?page=1" method="post">
                                <div class="row">
                                    <div class="col-lg-8">
                                        <p>There are <b>#qTotalInvoices.totalInvoices#</b> invoices in the database.</p>
                                    </div>
                                    <div class="col-lg-4 invoices-sort">
                                        <div class="form-label invoices-sort-label">Sort invoices</div>
                                        <select class="form-select" name="sort" onchange="this.form.submit()">
                                            <option value="invoiceNumber ASC" <cfif session.i_sort eq "invoiceNumber ASC">selected</cfif>>By invoice number asc</option>
                                            <option value="invoiceNumber DESC" <cfif session.i_sort eq "invoiceNumber DESC">selected</cfif>>By invoice number desc</option>
                                            <option value="dtmInvoiceDate ASC" <cfif session.i_sort eq "dtmInvoiceDate ASC">selected</cfif>>By invoice date asc</option>
                                            <option value="dtmInvoiceDate DESC" <cfif session.i_sort eq "dtmInvoiceDate DESC">selected</cfif>>By invoice date desc</option>
                                            <option value="dtmDueDate ASC" <cfif session.i_sort eq "dtmDueDate ASC">selected</cfif>>By due date asc</option>
                                            <option value="dtmDueDate DESC" <cfif session.i_sort eq "dtmDueDate DESC">selected</cfif>>By due date desc</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-lg-3">
                                        <label class="form-label">Search for invoice:</label>
                                        <div class="input-group mb-2">
                                            <input type="text" name="search" class="form-control" minlength="3" placeholder="Search for…">
                                            <button class="btn bg-green-lt" type="submit">Go!</button>
                                            <cfif len(trim(searchTerm))>
                                                <button class="btn bg-red-lt" name="delete" type="submit" data-bs-toggle="tooltip" data-bs-placement="top" title="Delete search">
                                                    #searchTerm# <i class="ms-2 fas fa-times"></i>
                                                </button>
                                            </cfif>
                                        </div>
                                    </div>
                                    <div class="col-lg-6">
                                        <label class="form-label">&nbsp;</label>
                                        <div class="form-selectgroup">
                                            <label class="form-selectgroup-item">
                                                <input type="radio" onclick="this.form.submit()" name="status" value="0" class="form-selectgroup-input" <cfif session.status eq 0>checked</cfif>>
                                                <span class="form-selectgroup-label <cfif session.status neq 0>no-border</cfif>">
                                                    ALL
                                                </span>
                                            </label>

                                            <label class="form-selectgroup-item">
                                                <input type="radio" onclick="this.form.submit()" name="status" value="1" class="form-selectgroup-input" <cfif session.status eq 1>checked</cfif>>
                                                <span class="form-selectgroup-label <cfif session.status neq 1>no-border</cfif>">
                                                    #objInvoice.getInvoiceStatusBadge('en', 'muted', 'statInvoiceDraft')#
                                                </span>
                                            </label>

                                            <label class="form-selectgroup-item">
                                                <input type="radio" onclick="this.form.submit()" name="status" value="2" class="form-selectgroup-input" <cfif session.status eq 2>checked</cfif>>
                                                <span class="form-selectgroup-label <cfif session.status neq 2>no-border</cfif>">
                                                    #objInvoice.getInvoiceStatusBadge('en', 'blue', 'statInvoiceOpen')#
                                                </span>
                                            </label>

                                            <label class="form-selectgroup-item">
                                                <input type="radio" onclick="this.form.submit()" name="status" value="3" class="form-selectgroup-input" <cfif session.status eq 3>checked</cfif>>
                                                <span class="form-selectgroup-label <cfif session.status neq 3>no-border</cfif>">
                                                    #objInvoice.getInvoiceStatusBadge('en', 'green', 'statInvoicePaid')#
                                                </span>
                                            </label>

                                            <label class="form-selectgroup-item">
                                                <input type="radio" onclick="this.form.submit()" name="status" value="4" class="form-selectgroup-input" <cfif session.status eq 4>checked</cfif>>
                                                <span class="form-selectgroup-label <cfif session.status neq 4>no-border</cfif>">
                                                    #objInvoice.getInvoiceStatusBadge('en', 'orange', 'statInvoicePartPaid')#
                                                </span>
                                            </label>

                                            <label class="form-selectgroup-item">
                                                <input type="radio" onclick="this.form.submit()" name="status" value="5" class="form-selectgroup-input" <cfif session.status eq 5>checked</cfif>>
                                                <span class="form-selectgroup-label <cfif session.status neq 5>no-border</cfif>">
                                                    #objInvoice.getInvoiceStatusBadge('en', 'purple', 'statInvoiceCanceled')#
                                                </span>
                                            </label>

                                            <label class="form-selectgroup-item">
                                                <input type="radio" onclick="this.form.submit()" name="status" value="6" class="form-selectgroup-input" <cfif session.status eq 6>checked</cfif>>
                                                <span class="form-selectgroup-label <cfif session.status neq 6>no-border</cfif>">
                                                    #objInvoice.getInvoiceStatusBadge('en', 'red', 'statInvoiceOverDue')#
                                                </span>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </form>
                            <cfif qInvoices.recordCount>
                                <div class="table-responsive">
                                    <table class="table table-vcenter table-mobile-md card-table">
                                        <thead>
                                            <tr>
                                                <th>Date (UTC)</th>
                                                <th>Number</th>
                                                <th>Status</th>
                                                <th>Due date (UTC)</th>
                                                <th>Title</th>
                                                <th>Customer</th>
                                                <th>Currency</th>
                                                <th class="text-end">Total</th>
                                                <th class="text-end"></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        <cfloop query="qInvoices">
                                            <tr>
                                                <td>#lsDateFormat(qInvoices.dtmInvoiceDate)#</td>
                                                <td>#qInvoices.invoiceNumber#</td>
                                                <td>#objInvoice.getInvoiceStatusBadge(session.lng, qInvoices.strColor, qInvoices.strInvoiceStatusVariable)#</td>
                                                <td>#lsDateFormat(qInvoices.dtmDueDate)#</td>
                                                <td><cfif len(qInvoices.strInvoiceTitle) gt 25>#left(qInvoices.strInvoiceTitle, 25)# ...<cfelse>#qInvoices.strInvoiceTitle#</cfif></td>
                                                <td><cfif len(qInvoices.customerName) gt 25>#left(qInvoices.customerName, 25)# ...<cfelse>#qInvoices.customerName#</cfif></td>
                                                <td>#qInvoices.strCurrency#</td>
                                                <td class="text-end">#lsCurrencyFormat(qInvoices.decTotalPrice, "none")#</td>
                                                <td class="text-end">
                                                    <div class="btn-list flex-nowrap float-end">
                                                        <button type="button" class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown">
                                                            Action
                                                        </button>
                                                        <div class="dropdown-menu dropdown-menu-end">
                                                            <a class="dropdown-item" href="#application.mainURL#/sysadmin/invoice/edit/#qInvoices.intInvoiceID#">Edit invoice</a>
                                                            <a class="dropdown-item" href="#application.mainURL#/sysadm/invoices?i=#qInvoices.intInvoiceID#&email&redirect=#urlEncodedFormat('sysadmin/invoices?del_redirect')#">Send invoice by email</a>
                                                            <cfif qInvoices.intPaymentStatusID eq 1 or qInvoices.intPaymentStatusID eq 2>
                                                                <a class="dropdown-item cursor-pointer" href="#application.mainURL#/sysadm/invoices?i=#qInvoices.intInvoiceID#&status=5&redirect=#urlEncodedFormat('sysadmin/invoices?del_redirect')#">Cancel invoice</a>
                                                            </cfif>
                                                            <a class="dropdown-item cursor-pointer" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/invoices?i=#qInvoices.intInvoiceID#&status=delete&redirect=#urlEncodedFormat('sysadmin/invoices?del_redirect')#', 'Delete invoice', 'Do you want to delete this invoice permanently?', 'No, cancel!', 'Yes, delete!')">Delete invoice</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </cfloop>
                                        </tbody>
                                    </table>
                                </div>
                            <cfelse>
                                <div class="col-lg-12 text-center text-red">There are no invoices found.</div>
                            </cfif>
                        </div>
                        <cfif pages neq 1 and qInvoices.recordCount>
                            <div class="card-body">
                                <ul class="pagination justify-content-center" id="pagination">

                                    <!--- First page --->
                                    <li class="page-item <cfif session.invoice_page eq 1>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/invoices?page=1" tabindex="-1" aria-disabled="true">
                                            <i class="fas fa-angle-double-left"></i>
                                        </a>
                                    </li>

                                    <!--- Prev arrow --->
                                    <li class="page-item <cfif session.invoice_page eq 1>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/invoices?page=#session.invoice_page-1#" tabindex="-1" aria-disabled="true">
                                            <i class="fas fa-angle-left"></i>
                                        </a>
                                    </li>

                                    <!--- Pages --->
                                    <cfif session.invoice_page + 4 gt pages>
                                        <cfset blockPage = pages>
                                    <cfelse>
                                        <cfset blockPage = session.invoice_page + 4>
                                    </cfif>

                                    <cfif blockPage neq pages>
                                        <cfloop index="j" from="#session.invoice_page#" to="#blockPage#">
                                            <cfif not blockPage gt pages>
                                                <li class="page-item <cfif session.invoice_page eq j>active</cfif>">
                                                    <a class="page-link" href="#application.mainURL#/sysadmin/invoices?page=#j#">#j#</a>
                                                </li>
                                            </cfif>
                                        </cfloop>
                                    <cfelseif blockPage lt 5>
                                        <cfloop index="j" from="1" to="#pages#">
                                            <li class="page-item <cfif session.invoice_page eq j>active</cfif>">
                                                <a class="page-link" href="#application.mainURL#/sysadmin/invoices?page=#j#">#j#</a>
                                            </li>
                                        </cfloop>
                                    <cfelse>
                                        <cfloop index="j" from="#pages - 4#" to="#pages#">
                                                <li class="page-item <cfif session.invoice_page eq j>active</cfif>">
                                                    <a class="page-link" href="#application.mainURL#/sysadmin/invoices?page=#j#">#j#</a>
                                                </li>
                                        </cfloop>
                                    </cfif>

                                    <!--- Next arrow --->
                                    <li class="page-item <cfif session.invoice_page gte pages>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/invoices?page=#session.invoice_page+1#">
                                            <i class="fas fa-angle-right"></i>
                                        </a>
                                    </li>

                                    <!--- Last page --->
                                    <li class="page-item <cfif session.invoice_page gte pages>disabled</cfif>">
                                        <a class="page-link" href="#application.mainURL#/sysadmin/invoices?page=#pages#">
                                            <i class="fas fa-angle-double-right"></i>
                                        </a>
                                    </li>
                                </ul>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    

</div>



<cfoutput>
<form action="#application.mainURL#/sysadm/invoices" method="post">
<input type="hidden" name="new_invoice" id="customer_id">
    <div id="invoice_new" class="modal modal-blur fade" tabindex="-1" style="display: none;" aria-hidden="true" data-bs-backdrop='static' data-bs-keyboard='false'>
        <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">New invoice</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Search for customer</label>
                        <input type="text" onkeyup="showResult(this.value)" class="form-control" id="searchfield" autocomplete="off" maxlength="20" required>
                        <div id="livesearch"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Invoice title</label>
                        <input type="text" name="title" class="form-control" maxlength="50">
                    </div>
                </div>
                <div class="modal-footer">
                    <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
                    <button type="submit" class="btn btn-primary ms-auto">
                        Save invoice
                    </button>
                </div>
            </div>
        </div>
    </div>
</form>
</cfoutput>