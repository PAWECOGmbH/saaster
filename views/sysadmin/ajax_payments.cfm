<cfscript>
    setting showdebugoutput = false;
    param name="url.invoiceID" default=0 type="numeric";
    if(!isNumeric(url.invoiceID)){
         location url="#application.mainURL#/sysadmin/invoices" addtoken="false";
    }

    thisInvoiceID = url.invoiceID;
    qPayments = new com.invoices().getInvoicePayments(thisInvoiceID);

</cfscript>

<cfoutput>

<form action="#application.mainURL#/sysadm/invoices" method="post">
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
                        <th width="30%">Date</th>
                        <th width="30%">Payment type</th>
                        <th width="20%" class="text-end">Amount</th>
                        <th width="20%" class="text-end"></th>
                    </tr>
                </thead>
                <tbody>
                <tr>
                    <td>
                        <div class="input-icon">
                            <span class="input-icon-addon"><i class="far fa-calendar-alt"></i></span>
                            <input class="form-control" placeholder="Select a date" name="payment_date" id="payment_date" value="#dateFormat(now(), 'yyyy-mm-dd')#" required>
                        </div>
                    </td>
                    <td><input type="text" name="payment_type" class="form-control" maxlength="50" placeholder="Credit card"></td>
                    <td><input type="text" name="amount" class="form-control text-end" maxlength="6" required></td>
                    <td><i onclick="sendPayment();" class="far fa-check-circle h1 text-green mt-2" style="cursor: pointer;" data-bs-toggle="tooltip" data-bs-placement="top" title="Save payment"></i></td>
                </tr>
                <cfloop query="qPayments">
                    <tr>
                        <td>#LSDateFormat(qPayments.dtmPayDate)#</td>
                        <td>#qPayments.strPaymentType#</td>
                        <td class="text-end">#lsNumberFormat(qPayments.decAmount, '_,___.__')# #qPayments.strCurrency#</td>
                        <td class="text-end"></td>
                    </tr>
                </cfloop>
                </tbody>
            </table>
        </div>
    </div>
    <div class="modal-footer">
        <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
        <button type="submit" class="btn btn-primary ms-auto">Save changes</button>
    </div>
</form>
</cfoutput>
