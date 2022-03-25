
<cfscript>

objInvoices = createObject("component", "com.invoices");

<!--- Delete invoice --->
if (structKeyExists(url, "delete")) {

    param name="url.delete" default="0";

    if (!isNumeric(url.delete) or url.delete lte 0) {
        getAlert('No invoice found!', 'danger');
        location url="#application.mainURL#/account-settings/invoices" addtoken="false";
    }
        
    <!--- Get customerID of the invoice to be deleted --->
    getCustomerID = objInvoices.getInvoiceData(url.delete).customerID;

    if (!isNumeric(getCustomerID) or getCustomerID eq 0) {
        getAlert('No customer found!', 'danger');
        location url="#application.mainURL#/account-settings/invoices" addtoken="false";
    }    

    <!--- Check whether the user is allowed to delete --->
    checkTenantRange = application.objGlobal.checkTenantRange(session.user_id, getCustomerID);
    if (!checkTenantRange) {
        getAlert('You are not allowed to delete this invoice!', 'danger');
        location url="#application.mainURL#/account-settings/invoices" addtoken="false";
    } 

    <!--- Delete invoice --->
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
        getAlert('No user found!', 'danger');
    }     

    location url="#application.mainURL#/account-settings/invoices" addtoken="false";

}



</cfscript>