component {

    // Internal persistence service. HTTP callers must authorize the invoice before using it.
    public struct function getSnapshot(required numeric invoiceID) {
        local.document = queryExecute(
            options = {datasource: application.datasource},
            params = {id: {type: "integer", value: arguments.invoiceID}},
            sql = "SELECT jsonSnapshot, strCaptureSource, dtmCapturedAt FROM invoice_documents WHERE intInvoiceID = :id"
        );
        if (!local.document.recordCount) return {};
        local.snapshot = deserializeJSON(local.document.jsonSnapshot);
        local.snapshot.captureSource = local.document.strCaptureSource;
        local.snapshot.capturedAt = local.document.dtmCapturedAt;
        return local.snapshot;
    }

    public boolean function isArchived(required numeric invoiceID) {
        return queryExecute(
            options = {datasource: application.datasource},
            params = {id: {type: "integer", value: arguments.invoiceID}},
            sql = "SELECT intInvoiceID FROM invoice_documents WHERE intInvoiceID = :id"
        ).recordCount gt 0;
    }

    public void function lockInvoice(required numeric invoiceID) {
        local.invoice = queryExecute(
            options = {datasource: application.datasource},
            params = {id: {type: "integer", value: arguments.invoiceID}},
            sql = "SELECT intInvoiceID FROM invoices WHERE intInvoiceID = :id FOR UPDATE"
        );
        if (!local.invoice.recordCount) throw(type="InvoiceDocument.Missing", message="Invoice not found.");
    }

    public binary function download(required numeric invoiceID) {
        transaction {
            lockInvoice(arguments.invoiceID);
            local.invoice = new backend.core.com.invoices().getInvoiceData(arguments.invoiceID);
            if (!isArchived(arguments.invoiceID)) {
                if (local.invoice.paymentstatusID eq 1 and !local.invoice.documentIssued) return renderDocument(arguments.invoiceID).pdf;
                capture(arguments.invoiceID, local.invoice.documentIssued ? "legacy" : "issued");
            }
            return queryExecute(
                options = {datasource: application.datasource},
                params = {id: {type: "integer", value: arguments.invoiceID}},
                sql = "SELECT binPDF FROM invoice_documents WHERE intInvoiceID = :id"
            ).binPDF;
        }
    }

    // Store once, in the same transaction as issuance/deletion. Never regenerate an archived PDF.
    public void function capture(required numeric invoiceID, string source = "legacy") {
        if (!listFind("issued,legacy", arguments.source)) throw(type="InvoiceDocument.Source", message="Invalid capture source.");
        transaction {
            lockInvoice(arguments.invoiceID);
            if (isArchived(arguments.invoiceID)) return;
            local.rendered = renderDocument(arguments.invoiceID);
            local.customer = local.rendered.snapshot.customer;
            queryExecute(
                options = {datasource: application.datasource},
                params = {
                    id: {type: "integer", value: arguments.invoiceID},
                    customer: {type: "integer", value: local.rendered.snapshot.invoice.customerID},
                    name: {type: "varchar", value: len(trim(local.customer.companyName)) ? local.customer.companyName : local.customer.contactPerson},
                    email: {type: "varchar", value: local.customer.email},
                    source: {type: "varchar", value: arguments.source},
                    snapshot: {type: "longvarchar", value: serializeJSON(local.rendered.snapshot)},
                    pdf: {type: "blob", value: local.rendered.pdf}
                },
                sql = "INSERT INTO invoice_documents (intInvoiceID, intOriginalCustomerID, strCustomerName, strCustomerEmail, strCaptureSource, jsonSnapshot, binPDF)
                    VALUES (:id, :customer, :name, :email, :source, :snapshot, :pdf)"
            );
            queryExecute(
                options = {datasource: application.datasource},
                params = {id: {type: "integer", value: arguments.invoiceID}},
                sql = "UPDATE invoices SET blnDocumentIssued = 1 WHERE intInvoiceID = :id"
            );
        }
    }

    // Call inside the customer deletion transaction, before removing files or identities.
    // The customer lock also prevents concurrent invoice inserts through the customer FK.
    public void function retainForDeletion(required numeric customerID) {
        queryExecute(
            options = {datasource: application.datasource},
            params = {customer: {type: "integer", value: arguments.customerID}},
            sql = "SELECT intCustomerID FROM customers WHERE intCustomerID = :customer FOR UPDATE"
        );
        local.invoices = queryExecute(
            options = {datasource: application.datasource},
            params = {customer: {type: "integer", value: arguments.customerID}},
            sql = "SELECT intInvoiceID, intPaymentStatusID, blnDocumentIssued FROM invoices WHERE intCustomerID = :customer ORDER BY intInvoiceID FOR UPDATE"
        );
        loop query="local.invoices" {
            // Unissued drafts are not accounting records, unless they were already sent/archived.
            if (local.invoices.intPaymentStatusID eq 1 and !local.invoices.blnDocumentIssued and !isArchived(local.invoices.intInvoiceID)) {
                queryExecute(
                    options = {datasource: application.datasource},
                    params = {id: {type: "integer", value: local.invoices.intInvoiceID}},
                    sql = "DELETE FROM invoices WHERE intInvoiceID = :id"
                );
            } else {
                capture(local.invoices.intInvoiceID, "legacy");
            }
        }
        // Revoke old email links and live account references, retaining positions and payments.
        queryExecute(
            options = {datasource: application.datasource},
            params = {customer: {type: "integer", value: arguments.customerID}},
            sql = "UPDATE invoices SET intCustomerID = NULL, intUserID = NULL, intBookingID = NULL, strUUID = NULL WHERE intCustomerID = :customer"
        );
    }

    // Only document fields are copied. Customer payment tokens and login data must never be archived.
    private struct function documentParty(required struct data) {
        local.party = {};
        loop list="companyName,contactPerson,address,address2,zip,city,countryName,countryISO,email,phone,website,billingAccountName,billingAddress,billingInfo" item="local.key" {
            local.party[local.key] = arguments.data[local.key] ?: "";
        }
        return local.party;
    }

    private struct function renderDocument(required numeric invoiceID) {
        local.objInvoices = new backend.core.com.invoices();
        local.snapshot = {version: 1, invoice: local.objInvoices.getInvoiceData(arguments.invoiceID)};
        if (!structKeyExists(local.snapshot.invoice, "number") or local.snapshot.invoice.customerID lte 0) {
            throw(type="InvoiceDocument.MissingCustomer", message="Cannot capture an invoice without its customer.");
        }
        local.snapshot.customer = documentParty(application.objCustomer.getCustomerData(local.snapshot.invoice.customerID));
        local.issuer = application.objSysadmin.getSysAdminData();
        local.snapshot.issuer = documentParty(local.issuer);
        local.snapshot.addressHTML = local.objInvoices.getInvoiceAddress(arguments.invoiceID);
        local.invoiceLng = local.objInvoices.getDocumentLanguage(local.snapshot.invoice.language);
        local.getTrans = application.objLanguage.getTrans;
        local.getTime = new backend.core.com.time(local.snapshot.invoice.customerID);
        local.qPayments = local.objInvoices.getInvoicePayments(arguments.invoiceID);
        local.previousLocale = getLocale();
        try {
            setLocale(application.objLanguage.toLocale(local.invoiceLng));
            local.snapshot.invoiceDateText = lsDateFormat(local.getTime.utc2local(local.snapshot.invoice.date));
            local.snapshot.dueDateText = lsDateFormat(local.getTime.utc2local(local.snapshot.invoice.dueDate));
            local.logoPath = len(trim(local.issuer.logo)) ? expandPath('/userdata/images/logos/#local.issuer.logo#') : expandPath('/assets/img/logo.png');
            local.logoImage = imageRead(local.logoPath);
            local.logoWidth = min(180, local.logoImage.width);
            local.logoSize = "width: #local.logoWidth#px; height: #round(local.logoImage.height * local.logoWidth / local.logoImage.width)#px;";
            local.snapshot.logoURL = "data:image/png;base64," & toBase64(imageGetBlob(local.logoImage));
            if (application.objSysadmin.getSystemSetting("settingSwissQrBill").strDefaultValue eq 1) {
                local.snapshot.qr = local.objInvoices.setSwissQrInvoiceStruct(local.snapshot.invoice.customerID, local.snapshot.invoice.amountOpen, local.snapshot.invoice.currency, local.snapshot.invoice.number);
            }
            include "invoice_document.cfm";
            return {snapshot: local.snapshot, pdf: local.pdf};
        } finally {
            setLocale(local.previousLocale);
        }
    }
}
