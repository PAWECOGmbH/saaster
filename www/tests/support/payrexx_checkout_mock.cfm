<cfscript>
if (!structKeyExists(application,"checkoutMock")) { header statuscode=404; abort; }
mock = application.checkoutMock;
route = listFirst(url.route ?: "","?");
object = listFirst(route,"/");
id = val(listLast(route,"/"));
method = cgi.request_method;
arrayAppend(mock.calls,method & " " & object & " " & id);
content type="application/json" reset=true;
if (method eq "DELETE" and (getHTTPRequestData().headers["X-API-KEY"] ?: "") neq "test-key") {
    header statuscode=403; writeOutput(serializeJSON({status:"error"})); abort;
}
if (object eq "Gateway" and method eq "POST") {
    mock.payload = duplicate(form);
    mock.admitted = queryExecute(options={datasource:application.datasource},params={reference:{type:"varchar",value:form.referenceId}},
        sql="SELECT strStatus FROM payrexx_checkouts WHERE strReference=:reference").strStatus;
    if (structKeyExists(mock,"deleteOnCreate")) {
        new backend.core.com.account_lifecycle().requestDeletion(argumentCollection=mock.deleteOnCreate);
        mock.deletionDuringCreate = new backend.core.com.account_deletion().process(mock.deleteOnCreate.customerID);
    }
    if (mock.failCreate ?: false) { header statuscode=500; writeOutput(serializeJSON({status:"error"})); abort; }
    writeOutput(serializeJSON({status:"success",data:[{id:mock.gateway,hash:"fixture",link:"https://example.invalid/checkout"}]}));
} else if (object eq "Gateway" and method eq "GET") {
    if ((mock.removed ?: false) or (mock.missing ?: false)) { header statuscode=404; writeOutput(serializeJSON({status:"error"})); abort; }
    writeOutput(serializeJSON({status:"success",data:[{id:mock.gateway,invoices:[{currency:"CHF",transactions:mock.events}]}]}));
} else if (object eq "Gateway" and method eq "DELETE") {
    if (mock.failDelete ?: false) { header statuscode=500; writeOutput(serializeJSON({status:"error"})); abort; }
    mock.removed=true;
    writeOutput(serializeJSON({status:"success"}));
} else if (object eq "Transaction" and method eq "GET") {
    writeOutput(serializeJSON({status:"success",data:mock.events}));
} else if (object eq "Transaction" and method eq "DELETE") {
    if (mock.failRevoke ?: false) { header statuscode=500; writeOutput(serializeJSON({status:"error"})); abort; }
    writeOutput(serializeJSON({status:"success"}));
} else {
    header statuscode=400; writeOutput(serializeJSON({status:"error"}));
}
</cfscript>
