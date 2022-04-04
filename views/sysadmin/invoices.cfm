
<cfscript>

    qInvoices = queryExecute (
        options = {datasource = application.datasource},
        sql = "
            SELECT  invoices.intInvoiceID as invoiceID,
                    CONCAT(invoices.strPrefix, '', invoices.intInvoiceNumber) as invoiceNumber,
                    invoices.strInvoiceTitle as invoiceTitle,
                    DATE_FORMAT(invoices.dtmInvoiceDate, '%Y-%m-%d') as invoiceDate,
                    DATE_FORMAT(invoices.dtmDueDate, '%Y-%m-%d') as invoiceDueDate,
                    invoices.strCurrency as invoiceCurrency,
                    invoices.decTotalPrice as invoiceTotal,
                    invoice_status.strInvoiceStatusVariable as invoiceStatusVariable,
                    invoice_status.strColor as invoiceStatusColor,
                    IF(LENGTH(customers.strCompanyName), customers.strCompanyName, CONCAT(users.strFirstName, ' ', users.strLastName)) as customerName

            FROM invoices

            INNER JOIN invoice_status ON 1=1
            AND invoices.intPaymentStatusID = invoice_status.intPaymentStatusID

            INNER JOIN customers ON 1=1
            AND invoices.intCustomerID = customers.intCustomerID

            INNER JOIN users ON 1=1
            AND customers.intCustomerID =
            (
                SELECT usr.intCustomerID
                FROM users usr
                WHERE usr.intCustomerID = customers.intCustomerID
                LIMIT 1
            )

            ORDER BY invoiceDate DESC
        "
    )

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
                            <i class="fas fa-plus pe-3"></i> Create invoice
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
                            <h3 class="card-title">Invoices overview</h3>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-vcenter table-mobile-md card-table">
                                    <thead>
                                        <tr>
                                            <th>Date</th>
                                            <th>Number</th>
                                            <th>Status</th>
                                            <th>Due date</th>
                                            <th>Customer</th>
                                            <th>Currency</th>
                                            <th>Total</th>
                                            <th></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop query="qInvoices">
                                            <tr>
                                                <td></td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="card-footer">
                            footer
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
<input type="hidden" name="new_invoice">
    <div id="invoice_new" class='modal modal-blur fade' data-bs-backdrop='static' data-bs-keyboard='false' tabindex='-1' aria-labelledby='staticBackdropLabel' aria-hidden='true'>
        <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">New invoice</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">

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