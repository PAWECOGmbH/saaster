<cfscript>
    setting showdebugoutput = false;
    param name="url.invoiceID" default=0 type="numeric";
    if(!isNumeric(url.invoiceID)){
        abort;
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

    </div>
    <div class="modal-footer">
        <a href="##" class="btn btn-link link-secondary" data-bs-dismiss="modal">Cancel</a>
        <button type="submit" class="btn btn-primary ms-auto">Save changes</button>
    </div>
</form>

</cfoutput>