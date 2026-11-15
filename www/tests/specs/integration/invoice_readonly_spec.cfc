component extends="tests.support.integration_spec" {
    function run() {
        describe("Read-only invoices after customer deletion", () => {
            beforeEach(() => {
                logout(); recordLogs();
                variables.customer = variables.fixtures.createCustomer();
                variables.fixtures.createUser(customerID=variables.customer);
                variables.admin = variables.fixtures.createUser(customerID=variables.fixtures.createCustomer(), sysAdmin=true, superAdmin=true);
                variables.invoices = new backend.core.com.invoices();
                variables.documents = new backend.core.com.invoice_documents();
                variables.invoiceID = variables.invoices.createInvoice({customerID:variables.customer,title:"Retained invoice",language:"en"}).newInvoiceID;
                expect(variables.invoices.insertInvoicePositions({invoiceID:variables.invoiceID,
                    positions:[{title:"Service",quantity:1,price:100,vat:0,discountPercent:0,unit:"x",description:""}]}).success).toBeTrue();
                variables.invoices.setInvoiceStatus(variables.invoiceID, 2);
                expect(variables.invoices.insertPayment({invoiceID:variables.invoiceID,customerID:variables.customer,date:now(),amount:25,type:"Bank"}).success).toBeTrue();
                variables.positionID = variables.invoices.getInvoiceData(variables.invoiceID).positions[1].invoicePosID;
                variables.paymentID = variables.invoices.getInvoicePayments(variables.invoiceID).intPaymentID;
                expect(application.objCustomer.deleteAccount(variables.customer).success).toBeTrue();
                variables.before = retainedState();
            });
            it("blocks document, payment and status mutations in the service and preserves the exact archive", () => {
                expect(variables.invoices.isReadOnly(variables.invoiceID)).toBeTrue();
                expect(variables.invoices.updateInvoice({invoiceID:variables.invoiceID,title:"Changed"}).success).toBeFalse();
                expect(variables.invoices.updatePosition({invoicePosID:variables.positionID,title:"Changed"}).success).toBeFalse();
                expect(variables.invoices.insertInvoicePositions({invoiceID:variables.invoiceID,positions:[]}).success).toBeFalse();
                expect(variables.invoices.deletePosition(variables.positionID).success).toBeFalse();
                expect(variables.invoices.recalculateInvoice(variables.invoiceID).success).toBeFalse();
                expect(variables.invoices.insertPayment({invoiceID:variables.invoiceID,date:now(),amount:10,type:"Manual"}).success).toBeFalse();
                expect(() => variables.invoices.deletePayment(variables.paymentID)).toThrow("InvoiceDocument.Immutable");
                expect(() => variables.invoices.deleteInvoice(variables.invoiceID)).toThrow("InvoiceDocument.Immutable");
                expect(() => variables.invoices.setInvoiceStatus(variables.invoiceID)).toThrow("InvoiceDocument.Immutable");
                loop array=[1,2,3,4,5,6] item="local.status" {
                    variables.requestedStatus = local.status;
                    expect(() => variables.invoices.setInvoiceStatus(variables.invoiceID,variables.requestedStatus)).toThrow("InvoiceDocument.Immutable");
                }
                expect(retainedState()).toBe(variables.before);
            });
            it("rejects forged POST and GET actions even for an authenticated Sysadmin", () => {
                local.auth = authenticate();
                loop array=[{settings:variables.invoiceID,title:"Changed"}, {new_position:variables.invoiceID},
                    {edit_position:variables.positionID}, {payments:variables.invoiceID,amount:10}, {delete_payment:variables.paymentID}] item="local.fields" {
                    local.response = mutate(local.auth, "POST", local.fields, "&invoiceID=0");
                    expect(local.response.statusCode).toInclude("403", left(local.response.fileContent,400));
                    expect(local.response.fileContent).toInclude("read-only");
                }
                loop array=["&i=" & variables.invoiceID & "&status=1", "&i=" & variables.invoiceID & "&status=5",
                    "&i=" & variables.invoiceID & "&status=delete", "&i=" & variables.invoiceID & "&open",
                    "&delete_pos=" & variables.positionID & "&invoiceID=0"] item="local.action" {
                    expect(mutate(local.auth,"GET",{},local.action).statusCode).toInclude("403");
                }
                expect(retainedState()).toBe(variables.before);
            });
            it("renders only viewing actions, including a read-only payment dialog", () => {
                local.html = renderInvoice("admin");
                expect(local.html).toInclude("recorded payments are read-only");
                expect(local.html).notToInclude('name="settings"');
                expect(local.html).notToInclude('name="new_position"');
                expect(local.html).notToInclude('name="edit_position"');
                expect(local.html).notToInclude("ajax_payments.cfm");
                expect(local.html).toInclude("/invoice/print/" & variables.invoiceID);
                local.payments = renderInvoice("admin-payments");
                expect(local.payments).toInclude("Bank");
                expect(local.payments).toInclude("payments are read-only");
                expect(local.payments).notToInclude("<form");
                expect(local.payments).notToInclude("deletePayment(");
                expect(local.payments).notToInclude('name="amount"');
                local.list = renderInvoice("admin-list");
                local.link = find("/sysadmin/invoice/edit/" & variables.invoiceID, local.list);
                expect(local.link).toBeGT(0);
                local.start = findLast("<tr>",left(local.list,local.link));
                local.row = mid(local.list,local.start,find("</tr>",local.list,local.link)-local.start);
                expect(local.row).toInclude("View invoice");
                expect(local.row).notToInclude("Cancel invoice");
                expect(local.row).notToInclude("Undo cancellation");
                expect(local.row).notToInclude("Delete invoice");
                expect(retainedState()).toBe(variables.before);
            });
            it("still allows payment tracking and cancellation for an existing customer", () => {
                local.id = variables.invoices.createInvoice({customerID:variables.admin.customerID,title:"Live account"}).newInvoiceID;
                variables.invoices.insertInvoicePositions({invoiceID:local.id,positions:[{title:"Service",quantity:1,price:100,vat:0,discountPercent:0,unit:"x",description:""}]});
                variables.invoices.setInvoiceStatus(local.id,2);
                expect(variables.invoices.insertPayment({invoiceID:local.id,date:now(),amount:10,type:"Bank"}).success).toBeTrue();
                local.payment = variables.invoices.getInvoicePayments(local.id).intPaymentID;
                variables.invoices.deletePayment(local.payment);
                expect(variables.invoices.getInvoicePayments(local.id).recordCount).toBe(0);
                variables.invoices.setInvoiceStatus(local.id,5);
                expect(variables.invoices.getInvoiceData(local.id).paymentstatusID).toBe(5);
            });
        });
    }
    private string function retainedState() {
        local.params = {id:{type:"integer",value:variables.invoiceID}};
        return serializeJSON({
            invoice:queryExecute(options={datasource:application.datasource},params=local.params,sql="SELECT * FROM invoices WHERE intInvoiceID=:id"),
            positions:queryExecute(options={datasource:application.datasource},params=local.params,sql="SELECT * FROM invoice_positions WHERE intInvoiceID=:id ORDER BY intInvoicePosID"),
            payments:variables.invoices.getInvoicePayments(variables.invoiceID),
            document:queryExecute(options={datasource:application.datasource},params=local.params,
                sql="SELECT CAST(jsonSnapshot AS CHAR) AS snapshot, SHA2(binPDF,256) AS pdf FROM invoice_documents WHERE intInvoiceID=:id")
        });
    }
    private string function renderInvoice(required string view) {
        cfhttp(url="http://127.0.0.1/tests/support/invoice_render_probe.cfm?view=" & arguments.view & "&invoiceID=" & variables.invoiceID & "&userID=" & variables.admin.userID,
            result="local.response",redirect=false,timeout=40);
        expect(isJSON(local.response.fileContent)).toBeTrue(left(local.response.fileContent,400));
        return deserializeJSON(local.response.fileContent).html;
    }
    private struct function authenticate() {
        cfhttp(url="http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=sysadmin/invoices&userID=" & variables.admin.userID,
            result="local.response",redirect=false,timeout=40);
        expect(local.response.statusCode).toInclude("200",left(local.response.fileContent,400));
        local.cookies = local.response.responseHeader["Set-Cookie"] ?: [];
        if (!isArray(local.cookies)) local.cookies=[local.cookies];
        local.parts=[];
        loop array=local.cookies item="local.cookie" { arrayAppend(local.parts,listFirst(local.cookie,";")); }
        local.auth={cookies:arrayToList(local.parts,"; ")};
        loop list="csrf_token,context_token" item="local.key" {
            local.match=reFind('name="' & local.key & '" value="([^"]*)"',local.response.fileContent,1,true);
            expect(local.match.len[1]).toBeGT(0);
            local.auth[local.key]=mid(local.response.fileContent,local.match.pos[2],local.match.len[2]);
        }
        return local.auth;
    }
    private struct function mutate(required struct auth,required string method,required struct fields,string extra="") {
        local.query="http://127.0.0.1/tests/support/organization_flow_probe.cfm?route=sysadm/invoices" & arguments.extra;
        if (arguments.method eq "GET") local.query &= "&csrf_token=" & urlEncodedFormat(arguments.auth.csrf_token) & "&context_token=" & urlEncodedFormat(arguments.auth.context_token);
        cfhttp(url=local.query,method=arguments.method,result="local.response",redirect=false,timeout=40) {
            cfhttpparam(type="header",name="Cookie",value=arguments.auth.cookies);
            if (arguments.method eq "POST") {
                cfhttpparam(type="formfield",name="csrf_token",value=arguments.auth.csrf_token);
                cfhttpparam(type="formfield",name="context_token",value=arguments.auth.context_token);
                loop collection=arguments.fields item="local.key" {
                    cfhttpparam(type="formfield",name=local.key,value=arguments.fields[local.key]);
                }
            }
        }
        return local.response;
    }
}
