
<cfscript>
    qInvoices = new com.sysadmin().getSysAdminInvoices();
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
                            <cfif qInvoices.recordCount>
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
                                                <th class="text-end">Total</th>
                                                <th class="text-end"></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        <cfloop query="qInvoices">
                                            <tr>
                                                <td>#LSDateFormat(qInvoices.invoiceDate)#</td>
                                                <td>#qInvoices.invoiceNumber#</td>
                                                <td>#objInvoice.getInvoiceStatusBadge('en', qInvoices.invoiceStatusColor, qInvoices.invoiceStatusVariable)#</td>
                                                <td>#LSDateFormat(qInvoices.invoiceDueDate)#</td>
                                                <td>#qInvoices.customerName#</td>
                                                <td>#qInvoices.invoiceCurrency#</td>
                                                <td class="text-end">#lsNumberFormat(qInvoices.invoiceTotal, '_,___.__')#</td>
                                                <td class="text-end float-end">
                                                    <div class="btn-list flex-nowrap">
                                                        <span class="dropdown">
                                                            <button type="button" class="btn dropdown-toggle align-text-top" data-bs-toggle="dropdown">
                                                                Action
                                                            </button>
                                                            <div class="dropdown-menu dropdown-menu-end">
                                                                <a class="dropdown-item" href="#application.mainURL#/sysadmin/invoice/edit/#qInvoices.invoiceID#">Edit invoice</a>
                                                                <a class="dropdown-item" style="cursor: pointer;" onclick="sweetAlert('warning', '#application.mainURL#/sysadm/invoices?delete=#qInvoices.invoiceID#', 'Delete invoice', 'Do you want to delete this invoice permanently?', 'No, cancel!', 'Yes, delete!')">Delete invoice</a>
                                                            </div>
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>
                                        </cfloop>
                                        </tbody>

                                    </table>
                                </div>
                            <cfelse>
                                <div class="col-lg-12 text-center text-red">There are no invoices yet.</div>
                            </cfif>
                        </div>
                        <!--- <div class="card-footer">
                        </div> --->
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

<script>
    function showResult(str) {
        if (str.length==0) {
            document.getElementById("livesearch").innerHTML="";
            return;
        }
        var xmlhttp=new XMLHttpRequest();
        xmlhttp.onreadystatechange=function() {
            if (this.readyState==4 && this.status==200) {
                document.getElementById("livesearch").innerHTML=this.responseText;
            }
        }
        xmlhttp.open("GET","/views/sysadmin/ajax_search_customer.cfm?search="+str,true);
        xmlhttp.send();
    }
    function intoTf(c, i) {
        var customer_name = document.getElementById("searchfield");
        customer_name.value = c;
        var customer_id = document.getElementById("customer_id");
        customer_id.value = i;
    }
    function hideResult() {
        document.getElementById("livesearch").innerHTML="";
        return;
    }
</script>
