<cfsetting showdebugoutput="no">

<cfscript>
    setting showdebugoutput = false;
    param name="url.invoiceID" default=0 type="numeric";
    if(!isNumeric(url.invoiceID)){
         location url="#application.mainURL#/sysadmin/invoices" addtoken="false";
    }
    thisInvoiceID = url.invoiceID;
    objInvoice = new backend.core.com.invoices();
    qPayments = objInvoice.getInvoicePayments(thisInvoiceID);
    amountOpen = objInvoice.getInvoiceData(thisInvoiceID).amountOpen;
    currency = objInvoice.getInvoiceData(thisInvoiceID).currency;
</cfscript>

<cfoutput>

<form action="#application.mainURL#/sysadm/invoices" method="post" id="sendPayment" data-return="#application.mainURL#/backend/core/views/sysadmin/ajax_payments.cfm?invoiceID=#thisInvoiceID#">
    <input type="hidden" name="payments" value="#thisInvoiceID#">
    <div class="modal-header">
        <h5 class="modal-title">Payments</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
    </div>
    <div class="modal-body">
        <div class="table-responsive">
            <table class="table table-vcenter table-mobile-md card-table">
                <thead>
                    <tr>
                        <th width="35%">Date (UTC)</th>
                        <th width="30%">Payment type</th>
                        <th width="25%" class="text-end">Amount #currency#</th>
                        <th width="10%" class="text-center"></th>
                    </tr>
                </thead>
                <tbody>
                <tr>
                    <td>
                        <div class="input-icon">
                            <span class="input-icon-addon"><i class="far fa-calendar-alt"></i></span>
                            <input class="form-control" placeholder="Select a date" name="payment_date" id="date1" value="#dateFormat(now(), 'yyyy-mm-dd')#" required>
                        </div>
                    </td>
                    <td><input type="text" name="payment_type" class="form-control" maxlength="50" placeholder="Credit card"></td>
                    <td><input type="text" name="amount" class="form-control text-end" maxlength="5" <cfif amountOpen gt 0>value="#amountOpen#"</cfif>></td>
                    <td class="text-center"><i onclick="sendPayment();" class="far fa-check-circle h1 text-green mt-2 cursor-pointer"></i></td>
                </tr>
                <cfloop query="qPayments">
                    <tr>
                        <td>#lsDateFormat(qPayments.dtmPayDate)#</td>
                        <td>#qPayments.strPaymentType#</td>
                        <td class="text-end">#lsCurrencyFormat(qPayments.decAmount, "none")#</td>
                        <td class="text-center"><i onclick="deletePayment(#qPayments.intPaymentID#);" class="fas fa-times h1 text-red mt-2 cursor-pointer"></i></td>
                    </tr>
                </cfloop>
                </tbody>
            </table>
        </div>
    </div>
    <div class="modal-footer">
        <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
        <a href="#application.mainURL#/sysadmin/invoice/edit/#thisInvoiceID#" class="btn btn-primary ms-auto">Done!</a>
    </div>
</form>
</cfoutput>
