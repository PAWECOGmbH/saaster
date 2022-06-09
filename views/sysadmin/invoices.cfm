
<cfscript>

    param name="session.i_search" default="" type="string";
    param name="session.i_sort" default="invoiceNumber" type="string";
    param name="session.i_start" default=1 type="numeric";
    param name="session.status" default=0 type="numeric";
    param name="status_sql" default="";

    // Check if url "start" exists
    if (structKeyExists(url, "start") and not isNumeric(url.start)) {
        abort;
    }

    // Pagination
    getEntries = 10;
    if( structKeyExists(url, 'start')){
        session.i_start = url.start;
    }
    next = session.i_start+getEntries;
    prev = session.i_start-getEntries;
    session.sql_i_start = session.i_start-1;

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

    // Status
    if(structKeyExists(form, 'status')){
        session.status = form.status;
        if (session.status gt 0) {
            status_sql = "AND invoices.intPaymentStatusID = #session.status#";
        }
    }

    qTotalInvoices = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT COUNT(intInvoiceID) as totalInvoices
            FROM invoices
        "
    )

    if (len(trim(session.i_search))) {

        qInvoices = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT  invoices.intInvoiceID,
                        CONCAT(invoices.strPrefix, '', invoices.intInvoiceNumber) as invoiceNumber,
                        invoices.strInvoiceTitle,
                        invoices.dtmInvoiceDate,
                        invoices.dtmDueDate,
                        invoices.strCurrency,
                        invoices.decTotalPrice,
                        invoice_status.strInvoiceStatusVariable,
                        invoice_status.strColor,
                        IF(
                            LENGTH(customers.strCompanyName),
                            customers.strCompanyName,
                            IF(
                                LENGTH(invoices.intUserID),
                                (
                                    SELECT CONCAT(users.strFirstName, ' ', users.strLastName)
                                    FROM users
                                    WHERE intUserID = invoices.intUserID
                                ),
                                customers.strContactPerson
                            )
                        ) as customerName

                FROM invoices

                INNER JOIN invoice_status ON 1=1
                AND invoices.intPaymentStatusID = invoice_status.intPaymentStatusID
                #status_sql#

                INNER JOIN customers ON 1=1
                AND invoices.intCustomerID = customers.intCustomerID

                WHERE (
                    CONCAT(invoices.strPrefix, '', invoices.intInvoiceNumber) LIKE '%#session.i_search#%' OR
                    invoices.strInvoiceTitle LIKE '%#session.i_search#%' OR
                    invoices.decTotalPrice LIKE '%#session.i_search#%' OR
                    invoices.strCurrency LIKE '%#session.i_search#%' OR
                    customers.strCompanyName LIKE '%#session.i_search#%' OR
                    customers.strContactPerson LIKE '%#session.i_search#%' OR
                        (
                            SELECT CONCAT(users.strFirstName, ' ', users.strLastName)
                            FROM users
                            WHERE intUserID = invoices.intUserID
                        ) LIKE '%#replace(session.i_search, " ", "%", "all")#%'

                    )

                ORDER BY #session.i_sort#
                LIMIT #session.sql_i_start#, #getEntries#
            "
        )


    } else {


        qInvoices = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT  invoices.intInvoiceID,
                        CONCAT(invoices.strPrefix, '', invoices.intInvoiceNumber) as invoiceNumber,
                        invoices.strInvoiceTitle,
                        invoices.dtmInvoiceDate,
                        invoices.dtmDueDate,
                        invoices.strCurrency,
                        invoices.decTotalPrice,
                        invoice_status.strInvoiceStatusVariable,
                        invoice_status.strColor,
                        IF(
                            LENGTH(customers.strCompanyName),
                            customers.strCompanyName,
                            IF(
                                LENGTH(invoices.intUserID),
                                (
                                    SELECT CONCAT(users.strFirstName, ' ', users.strLastName)
                                    FROM users
                                    WHERE intUserID = invoices.intUserID
                                ),
                                customers.strContactPerson
                            )
                        ) as customerName

                FROM invoices

                INNER JOIN invoice_status ON 1=1
                AND invoices.intPaymentStatusID = invoice_status.intPaymentStatusID
                #status_sql#

                INNER JOIN customers ON 1=1
                AND invoices.intCustomerID = customers.intCustomerID

                ORDER BY #session.i_sort#
                LIMIT #session.sql_i_start#, #getEntries#
            "
        )

    }

    objInvoice = new com.invoices();

</cfscript>

<cfinclude template="/includes/header.cfm">
<cfinclude template="/includes/navigation.cfm">

<div class="page-wrapper">
    <cfoutput>
        <div class="container-xl">

            <div class="row mb-3">
                <div class="col-md-12 col-lg-12">

                    <div class="page-header col-lg-9 col-md-8 col-sm-8 col-xs-12 float-start">
                        <h4 class="page-title">Invoices</h4>
                        <ol class="breadcrumb breadcrumb-dots">
                            <li class="breadcrumb-item"><a href="#application.mainURL#/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item">SysAdmin</li>
                            <li class="breadcrumb-item active">Invoices</li>
                        </ol>
                    </div>
                    <div class="page-header col-lg-3 col-md-4 col-sm-4 col-xs-12 align-items-end float-start">
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
        <div class="container-xl">
            <div class="row">
                <div class="col-lg-12">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Invoices overview #session.i_search#</h3>
                        </div>
                        <div class="card-body">
                            <p>There are <b>#qTotalInvoices.totalInvoices#</b> invoices in the database.</p>
                            <form action="#application.mainURL#/sysadmin/invoices?start=1" method="post">
                                <div class="row">
                                    <div class="col-lg-3">
                                        <label class="form-label">Search for invoice:</label>
                                        <div class="input-group mb-2">
                                            <input type="text" name="search" class="form-control" minlength="3" placeholder="Search for…">
                                            <button class="btn bg-green-lt" type="submit">Go!</button>
                                            <cfif len(trim(session.i_search))>
                                                <button class="btn bg-red-lt" name="delete" type="submit" data-bs-toggle="tooltip" data-bs-placement="top" title="Delete search">
                                                    #session.i_search# <i class="ms-2 fas fa-times"></i>
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
                                                <input type="radio" onclick="this.form.submit()" name="status" value="6" class="form-selectgroup-input" <cfif session.status eq 6>checked</cfif>>
                                                <span class="form-selectgroup-label <cfif session.status neq 6>no-border</cfif>">
                                                    #objInvoice.getInvoiceStatusBadge('en', 'red', 'statInvoiceOverDue')#
                                                </span>
                                            </label>
                                        </div>
                                    </div>
                                    <div class="col-lg-3">
                                        <div class="mb-3">
                                            <div class="form-label">Sort invoices</div>
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
                                                <td>#objInvoice.getInvoiceStatusBadge('en', qInvoices.strColor, qInvoices.strInvoiceStatusVariable)#</td>
                                                <td>#lsDateFormat(qInvoices.dtmDueDate)#</td>
                                                <td>#qInvoices.customerName#</td>
                                                <td>#qInvoices.strCurrency#</td>
                                                <td class="text-end">#lsNumberFormat(qInvoices.decTotalPrice)#</td>
                                                <td class="text-end float-end">
                                                    <div class="btn-list flex-nowrap">
                                                        <button type="button" class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown">
                                                            Action
                                                        </button>
                                                        <div class="dropdown-menu dropdown-menu-end">
                                                            <a class="dropdown-item" href="#application.mainURL#/sysadmin/invoice/edit/#qInvoices.intInvoiceID#">Edit invoice</a>
                                                            <a class="dropdown-item" style="cursor: pointer;" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/invoices?delete=#qInvoices.intInvoiceID#', 'Delete invoice', 'Do you want to delete this invoice permanently?', 'No, cancel!', 'Yes, delete!')">Delete invoice</a>
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
                        <div class="pt-4 card-footer d-flex align-items-center">
                            <ul class="pagination m-0 ms-auto">
                                <li class="page-item <cfif session.i_start lte getEntries>disabled</cfif>">
                                    <a class="page-link" href="#application.mainURL#/sysadmin/invoices?start=#prev#" tabindex="-1" aria-disabled="true">
                                        <i class="fas fa-angle-left"></i> prev
                                    </a>
                                </li>
                                <li class="ms-3 page-item <cfif qTotalInvoices.totalInvoices lt next>disabled</cfif>">
                                    <a class="page-link" href="#application.mainURL#/sysadmin/invoices?start=#next#">
                                        next <i class="fas fa-angle-right"></i>
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </cfoutput>
    <cfinclude template="/includes/footer.cfm">
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
