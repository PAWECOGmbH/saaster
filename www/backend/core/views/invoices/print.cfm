<cfscript>
    objInvoices = new backend.core.com.invoices();
    invoiceDocuments = new backend.core.com.invoice_documents();
    param name="thiscontent.thisID" default=0 type="numeric";
    bearerAccess = false;
    if (structKeyExists(url, "pdf")) {
        qInvoice = objInvoices.getInvoice(url.pdf);
        if (qInvoice.recordCount and len(trim(url.pdf))) {
            thiscontent.thisID = qInvoice.intInvoiceID;
            bearerAccess = true;
        } else {
            location url="#application.mainURL#/login" addtoken="false";
        }
    }
    thisInvoiceID = val(thiscontent.thisID);
    getInvoiceData = objInvoices.getInvoiceData(thisInvoiceID);
    if (!structKeyExists(getInvoiceData, "number")) {
        location url="#application.mainURL#/login" addtoken="false";
    }
    // Only the platform administrator can read retained invoices of deleted customers.
    platformAccess = (session.sysadmin ?: false) and val(session.user_id ?: 0) gt 0;
    customerAccess = getInvoiceData.customerID gt 0 and val(session.user_id ?: 0) gt 0
        and application.objGlobal.checkTenantRange(session.user_id, getInvoiceData.customerID);
    if (!platformAccess and !(getInvoiceData.customerID gt 0 and bearerAccess) and !customerAccess) {
        location url="#application.mainURL#/login" addtoken="false";
    }
    pdfDocument = invoiceDocuments.download(thisInvoiceID);
    pdfName = "invoice-" & reReplace(getInvoiceData.number, "[^a-zA-Z0-9_-]", "", "all") & ".pdf";
    cfheader(name="Content-Disposition", value='attachment; filename="' & pdfName & '"');
    cfcontent(type="application/pdf", variable=pdfDocument, reset=true);
</cfscript>
