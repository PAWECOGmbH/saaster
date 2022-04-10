
<cfscript>

objInvoice = new com.invoices();

if (structKeyExists(form, "new_invoice")) {

    if (isNumeric(form.new_invoice)) {

        invoiceData = structNew();

        param name="form.title" default="";
        setting = application.objGlobal;

        invoiceData['customerID'] = form.new_invoice;
        invoiceData['prefix'] = setting.getSetting(invoiceData.customerID, 'settingInvoicePrefix');
        invoiceData['title'] = form.title;
        invoiceData['currency'] = setting.getDefaultCurrency().iso;
        invoiceData['isNet'] = setting.getSetting(invoiceData.customerID, 'settingInvoiceNet');
        invoiceData['vatType'] = setting.getSetting(invoiceData.customerID, 'settingStandardVatType');

        if (!len(trim(invoiceData.currency))) {
            invoiceData.currency = "USD";
        }
        if (!isNumeric(invoiceData.isNet)) {
            invoiceData.isNet = 1;
        }
        if (!isNumeric(invoiceData.vatType)) {
            invoiceData.vatType = 1;
        }

        createInvoice = objInvoice.createInvoice(invoiceData);

        if (createInvoice.success) {
            getAlert('msgInvoiceCreated');
            location url="#application.mainURL#/sysadmin/invoice/edit/#createInvoice.newInvoiceID#" addtoken="false";
        } else {
            getAlert(createInvoice.message, 'danger');
            location url="#application.mainURL#/sysadmin/invoices" addtoken="false";
        }


    }

}



<!--- Delete invoice --->
if (structKeyExists(url, "delete")) {

    param name="url.delete" default="0";

    if (!isNumeric(url.delete) or url.delete lte 0) {
        getAlert('No invoice found!', 'danger');
        location url="#application.mainURL#/sysadmin/invoices" addtoken="false";
    }

    queryExecute(
        options = {datasource = application.datasource, result="getAnswer"},
        params = {
            invoiceID: {type: "numeric", value: url.delete}
        },
        sql = "
            DELETE FROM invoices WHERE intInvoiceID = :invoiceID
        "
    )

    if (getAnswer.recordCount) {
        getAlert('msgInvoiceDeleted', 'success');
    } else {
        getAlert('No invoice found!', 'danger');
    }

    location url="#application.mainURL#/sysadmin/invoices" addtoken="false";

}


<!--- Insert position --->
if (structKeyExists(form, "new_position")) {

    if (isNumeric(form.new_position)) {

        posInfo = structNew();
        posInfo['invoiceID'] = form.new_position;
        posInfo['append'] = true;<!--- false, if we have to delete all the positions first --->

        param name="form.position_title" default="";
        param name="form.position_desc" default="";
        param name="form.quantity" default="1";
        param name="form.price" default="0";
        param name="form.vat" default="0";
        param name="form.quantity" default="";
        param name="form.discount" default="0";

        if (!isNumeric(form.quantity)) {
            form.quantity = 1;
        }
        if (!isNumeric(form.price)) {
            form.price = 0;
        }
        if (!isNumeric(form.vat)) {
            form.vat = 0;
        }
        if (!isNumeric(form.discount)) {
            form.discount = 0;
        }

        positionArray = arrayNew(1);
        position = structNew();

        position[1]['title'] = form.position_title;
        position[1]['description'] = form.position_desc;
        position[1]['price'] = form.price;
        position[1]['quantity'] = form.quantity;
        position[1]['unit'] = form.unit;
        position[1]['discountPercent'] = form.discount;
        position[1]['vat'] = form.vat;
        arrayAppend(positionArray, position[1]);

        posInfo['positions'] = positionArray;

        insPosition = objInvoice.insertInvoicePositions(posInfo);

        if (!insPosition.success) {
            getAlert(insPosition.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/invoice/edit/#form.new_position#" addtoken="false";


    }

}


<!--- Edit position --->
if (structKeyExists(form, "edit_position")) {

    param name="form.edit_position" default="0";
    param name="url.invoiceID" default="0";

    if ((isNumeric(form.edit_position) and form.edit_position gt 0) and (isNumeric(url.invoiceID) and url.invoiceID gt 0)) {

        param name="form.position_title" default="";
        param name="form.position_desc" default="";
        param name="form.quantity" default="1";
        param name="form.price" default="0";
        param name="form.vat" default="0";
        param name="form.quantity" default="";
        param name="form.discount" default="0";
        param name="form.pos" default="0";

        if (!isNumeric(form.quantity)) {
            form.quantity = 1;
        }
        if (!isNumeric(form.price)) {
            form.price = 0;
        }
        if (!isNumeric(form.vat)) {
            form.vat = 0;
        }
        if (!isNumeric(form.discount)) {
            form.discount = 0;
        }

        position = structNew();
        position['invoicePosID'] = form.edit_position;
        position['title'] = form.position_title;
        position['description'] = form.position_desc;
        position['price'] = form.price;
        position['quantity'] = form.quantity;
        position['unit'] = form.unit;
        position['discountPercent'] = form.discount;
        position['vat'] = form.vat;
        position['pos'] = form.pos;



        updatePosition = objInvoice.updatePosition(position);

        if (!updatePosition.success) {
            getAlert(updatePosition.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/invoice/edit/#url.invoiceID#" addtoken="false";

    }

}


<!--- Delete position --->
if (structKeyExists(url, "delete_pos")) {

    param name="url.delete_pos" default="0";
    param name="url.invoiceID" default="0";

    if ((isNumeric(url.delete_pos) and url.delete_pos gt 0) and (isNumeric(url.invoiceID) and url.invoiceID gt 0)) {

        delPosition = objInvoice.deletePosition(url.delete_pos);

        if (delPosition.success) {
            location url="#application.mainURL#/sysadmin/invoice/edit/#url.invoiceID#" addtoken="false";
        } else {
            getAlert('There was a problem while deleting a position!', 'warning');
            location url="#application.mainURL#/sysadmin/invoices" addtoken="false";
        }

    }

}



<!--- Update invoice (settings) --->
if (structKeyExists(form, "settings")) {

    if (isNumeric(form.settings)) {

        invoiceID = form.settings;

        param name="form.title" default="";
        param name="form.userID" default="";
        param name="form.currency" default="";
        param name="form.invoice_date" default="";
        param name="form.due_date" default="";
        param name="form.type" default="1";

        if (isDate(form.invoice_date)) {
            invoice_date = form.invoice_date;
        } else {
            invoice_date = objInvoice.getInvoiceData(invoiceID).date;
        }
        if (isDate(form.due_date) and form.due_date gte invoice_date) {
            due_date = form.due_date;
        } else {
            due_date = objInvoice.getInvoiceData(invoiceID).dueDate;
        }
        if (structKeyExists(form, 'netto')) {
            netto = 1;
        } else {
            netto = 0;
        }

        invoiceStruct = structNew();
        invoiceStruct['invoiceID'] = invoiceID;
        invoiceStruct['title'] = form.title;
        invoiceStruct['userID'] = form.userID;
        invoiceStruct['currency'] = form.currency;
        invoiceStruct['invoiceDate'] = invoice_date;
        invoiceStruct['dueDate'] = due_date;
        invoiceStruct['isNet'] = netto;
        invoiceStruct['vatType'] = form.type;

        updInvoice = objInvoice.updateInvoice(invoiceStruct);

        if (updInvoice.success) {
            getAlert('Update successful!');
        } else {
            getAlert(updInvoice.message);
        }

        location url="#application.mainURL#/sysadmin/invoice/edit/#invoiceID#" addtoken="false";

    }

}


<!--- Open the invoice --->
if (structKeyExists(url, "open")) {

    if (isNumeric(url.invoiceID)) {

        <!--- Update position --->
        qNextPosNumber = queryExecute(
            options = {datasource = application.datasource},
            params = {
                invoiceID: {type: "numeric", value: url.invoiceID},
                statusID: {type: "numeric", value: 2}
            },
            sql = "
                UPDATE invoices
                SET intPaymentStatusID = :statusID
                WHERE intInvoiceID = :invoiceID
            "
        )

        location url="#application.mainURL#/sysadmin/invoice/edit/#url.invoiceID#" addtoken="false";

    }

}


<!--- Draft the invoice --->
if (structKeyExists(url, "draft")) {

    if (isNumeric(url.invoiceID)) {

        <!--- Update position --->
        qNextPosNumber = queryExecute(
            options = {datasource = application.datasource},
            params = {
                invoiceID: {type: "numeric", value: url.invoiceID},
                statusID: {type: "numeric", value: 1}
            },
            sql = "
                UPDATE invoices
                SET intPaymentStatusID = :statusID
                WHERE intInvoiceID = :invoiceID
            "
        )

        location url="#application.mainURL#/sysadmin/invoice/edit/#url.invoiceID#" addtoken="false";

    }

}




</cfscript>