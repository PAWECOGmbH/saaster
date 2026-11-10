component extends="tests.support.integration_spec" {

    function run() {
        describe("Retained invoice documents", () => {
            beforeEach(() => {
                variables.customerID = variables.fixtures.createCustomer();
                variables.user = variables.fixtures.createUser(customerID=variables.customerID);
                variables.invoices = new backend.core.com.invoices();
                variables.documents = new backend.core.com.invoice_documents();
                local.created = variables.invoices.createInvoice({customerID: variables.customerID, language: "en", title: "TestBox retained invoice"});
                expect(local.created.success).toBeTrue(local.created.message);
                variables.invoiceID = local.created.newInvoiceID;
                local.positions = variables.invoices.insertInvoicePositions({invoiceID: variables.invoiceID, positions: [{title: "Service", description: "", quantity: 1, discountPercent: 0, vat: 0, price: 100, unit: "x"}]});
                expect(local.positions.success).toBeTrue(local.positions.message);
            });

            it("freezes the recipient and PDF on issue and keeps drafts editable", () => {
                expect(variables.documents.isArchived(variables.invoiceID)).toBeFalse();
                variables.invoices.setInvoiceStatus(variables.invoiceID, 2);
                local.before = variables.documents.getSnapshot(variables.invoiceID);
                local.pdf = variables.documents.download(variables.invoiceID);
                queryExecute(options={datasource: application.datasource}, params={id: {type: "integer", value: variables.customerID}}, sql="UPDATE customers SET strCompanyName = 'Changed name', strAddress = 'Changed address' WHERE intCustomerID = :id");
                expect(variables.documents.getSnapshot(variables.invoiceID).addressHTML).toBe(local.before.addressHTML);
                expect(variables.invoices.getInvoiceAddress(variables.invoiceID)).toBe(local.before.addressHTML);
                expect(hash(variables.documents.download(variables.invoiceID))).toBe(hash(local.pdf));
                expect(local.before.captureSource).toBe("issued");
                expect(variables.invoices.updateInvoice({invoiceID: variables.invoiceID, title: "Changed"}).success).toBeFalse();
                expect(() => variables.invoices.setInvoiceStatus(variables.invoiceID, 1)).toThrow("InvoiceDocument.Immutable");
                expect(() => variables.invoices.deleteInvoice(variables.invoiceID)).toThrow("InvoiceDocument.Immutable");
            });

            it("retains legacy invoices and payments while detaching the deleted account", () => {
                queryExecute(options={datasource: application.datasource}, params={id: {type: "integer", value: variables.invoiceID}}, sql="UPDATE invoices SET intPaymentStatusID = 2, strUUID = 'old-download-token' WHERE intInvoiceID = :id");
                transaction {
                    variables.documents.retainForDeletion(variables.customerID);
                    queryExecute(options={datasource: application.datasource}, params={id: {type: "integer", value: variables.customerID}}, sql="DELETE FROM customers WHERE intCustomerID = :id");
                }
                expect(variables.invoices.getInvoiceData(variables.invoiceID).customerID).toBe(0);
                expect(variables.documents.getSnapshot(variables.invoiceID).captureSource).toBe("legacy");
                expect(isBinary(variables.documents.download(variables.invoiceID))).toBeTrue();
                expect(variables.invoices.getInvoice("old-download-token").recordCount).toBe(0);
            });

            it("keeps payments and lets the platform administrator find a deleted customer's invoice", () => {
                variables.invoices.setInvoiceStatus(variables.invoiceID, 2);
                local.pdf = variables.documents.download(variables.invoiceID);
                local.payment = variables.invoices.insertPayment({invoiceID: variables.invoiceID, customerID: variables.customerID, date: now(), amount: 25, type: "Bank"});
                expect(local.payment.success).toBeTrue(local.payment.message);
                local.deleted = application.objCustomer.deleteAccount(variables.customerID);
                expect(local.deleted.success).toBeTrue(local.deleted.message);
                expect(variables.invoices.getInvoicePayments(variables.invoiceID).recordCount).toBe(1);
                expect(variables.invoices.getInvoiceData(variables.invoiceID).amountPaid).toBe(25);
                expect(hash(variables.documents.download(variables.invoiceID))).toBe(hash(local.pdf));
                local.snapshot = variables.documents.getSnapshot(variables.invoiceID);
                local.results = application.objSysadmin.getAllInvoicesSearch(search=local.snapshot.customer.email, term=local.snapshot.customer.email, start=0, status="", sort="invoiceNumber DESC");
                expect(valueList(local.results.intInvoiceID)).toInclude(toString(variables.invoiceID));
                local.adminCustomer = variables.fixtures.createCustomer();
                local.admin = variables.fixtures.createUser(customerID=local.adminCustomer, sysAdmin=true);
                cfhttp(url="http://127.0.0.1/tests/support/invoice_render_probe.cfm?view=admin&invoiceID=#variables.invoiceID#&userID=#local.admin.userID#", result="local.response", redirect=false);
                expect(local.response.statusCode).toInclude("200", left(reReplace(reReplace(local.response.fileContent, "(?s)<style.*?</style>", "", "all"), "<[^>]+>", " ", "all"), 3000));
                expect(isJSON(local.response.fileContent)).toBeTrue(left(local.response.fileContent, 300));
                local.html = deserializeJSON(local.response.fileContent).html;
                expect(local.html).toInclude("Customer account deleted");
                expect(local.html).notToInclude("Send invoice by email");
                expect(local.html).notToInclude('name="settings"');
                expect(local.html).notToInclude('name="new_position"');
                expect(local.html).notToInclude('name="edit_position"');
                expect(variables.invoices.updateInvoice({invoiceID:variables.invoiceID,title:"Tampered archive"}).success).toBeFalse();
                local.position = variables.invoices.getInvoiceData(variables.invoiceID).positions[1].invoicePosID;
                expect(variables.invoices.updatePosition({invoicePosID:local.position,title:"Tampered position"}).success).toBeFalse();
                expect(variables.invoices.deletePosition(local.position).success).toBeFalse();
                expect(variables.invoices.insertInvoicePositions({invoiceID:variables.invoiceID,positions:[]}).success).toBeFalse();
                expect(variables.invoices.recalculateInvoice(variables.invoiceID).success).toBeFalse();
                expect(hash(variables.documents.download(variables.invoiceID))).toBe(hash(local.pdf));
                expect(local.html).notToInclude("status=1&amp;");
                expect(local.html).notToInclude("##qInvoice.");
                cfhttp(url="http://127.0.0.1/tests/support/invoice_render_probe.cfm?view=admin-list&userID=#local.admin.userID#", result="local.listResponse", redirect=false);
                expect(isJSON(local.listResponse.fileContent)).toBeTrue(left(local.listResponse.fileContent, 300));
                expect(deserializeJSON(local.listResponse.fileContent).html).toInclude(local.snapshot.customer.companyName);
                cfhttp(url="http://127.0.0.1/tests/support/invoice_render_probe.cfm?view=print&invoiceID=#variables.invoiceID#&userID=#local.admin.userID#", result="local.download", redirect=false, getAsBinary="yes");
                expect(hash(local.download.fileContent)).toBe(hash(local.pdf));
                local.other = variables.fixtures.createUser(customerID=local.adminCustomer);
                cfhttp(url="http://127.0.0.1/tests/support/invoice_render_probe.cfm?view=print&invoiceID=#variables.invoiceID#&userID=#local.other.userID#", result="local.denied", redirect=false);
                expect(local.denied.statusCode).toInclude("302");
            });

            it("rolls back deletion when an older invoice cannot be captured", () => {
                recordLogs();
                local.issuer = application.objSysadmin.getSysAdminData();
                local.issuerCustomer = local.issuer.customerID;
                if (!val(local.issuerCustomer)) {
                    local.issuerCustomer = variables.fixtures.createCustomer();
                    variables.fixtures.createUser(customerID=local.issuerCustomer, sysAdmin=true);
                }
                queryExecute(options={datasource: application.datasource}, params={id: {type: "integer", value: local.issuerCustomer}}, sql="UPDATE customers SET strLogo = 'testbox-missing-invoice-logo.png' WHERE intCustomerID = :id");
                queryExecute(options={datasource: application.datasource}, params={id: {type: "integer", value: variables.invoiceID}}, sql="UPDATE invoices SET intPaymentStatusID = 2, blnDocumentIssued = 1 WHERE intInvoiceID = :id");
                try {
                    local.deleted = application.objCustomer.deleteAccount(variables.customerID);
                } finally {
                    queryExecute(options={datasource: application.datasource}, params={id: {type: "integer", value: local.issuerCustomer}, logo: {type: "varchar", value: local.issuer.logo}}, sql="UPDATE customers SET strLogo = :logo WHERE intCustomerID = :id");
                }
                expect(local.deleted.success).toBeFalse();
                expect(application.objCustomer.getCustomerData(variables.customerID).customerID).toBe(variables.customerID);
                expect(variables.invoices.getInvoiceData(variables.invoiceID).customerID).toBe(variables.customerID);
                expect(variables.documents.isArchived(variables.invoiceID)).toBeFalse();
            });

            it("rejects direct customer deletion and never deletes issued invoices as drafts", () => {
                variables.invoices.setInvoiceStatus(variables.invoiceID, 2);
                expect(() => queryExecute(options={datasource: application.datasource}, params={id: {type: "integer", value: variables.customerID}}, sql="DELETE FROM customers WHERE intCustomerID = :id")).toThrow();
                expect(variables.documents.isArchived(variables.invoiceID)).toBeTrue();
                expect(variables.invoices.insertInvoicePositions({invoiceID: variables.invoiceID, positions: []}).success).toBeFalse();
                local.position = variables.invoices.getInvoiceData(variables.invoiceID).positions[1].invoicePosID;
                expect(variables.invoices.deletePosition(local.position).success).toBeFalse();
                expect(variables.invoices.updatePosition({invoicePosID: local.position, title: "Changed"}).success).toBeFalse();
            });
            it("previews drafts without issuing them and removes only unissued drafts on deletion", () => {
                expect(isBinary(variables.documents.download(variables.invoiceID))).toBeTrue();
                expect(variables.documents.isArchived(variables.invoiceID)).toBeFalse();
                local.updated = variables.invoices.updateInvoice({invoiceID: variables.invoiceID, title: "Updated draft", isNet: true, vatType: 1, currency: "CHF", language: "en"});
                expect(local.updated.success).toBeTrue(local.updated.message);
                expect(application.objCustomer.deleteAccount(variables.customerID).success).toBeTrue();
                expect(structKeyExists(variables.invoices.getInvoiceData(variables.invoiceID), "number")).toBeFalse();
            });

            it("preserves the Swiss QR slip and issuer when payment settings change", () => {
                local.originalSettings = {};
                loop list="settingSwissQrBill,settingIBANnumber,settingQRreference" item="local.setting" {
                    local.originalSettings[local.setting] = application.objSysadmin.getSystemSetting(local.setting).strDefaultValue;
                }
                local.originalIssuer = application.objSysadmin.getSysAdminData();
                local.issuerID = local.originalIssuer.customerID;
                if (!val(local.issuerID)) {
                    local.issuerID = variables.fixtures.createCustomer();
                    variables.fixtures.createUser(customerID=local.issuerID, sysAdmin=true);
                }
                try {
                    queryExecute(options={datasource: application.datasource}, sql="UPDATE system_settings SET strDefaultValue = CASE strSettingVariable WHEN 'settingSwissQrBill' THEN '1' WHEN 'settingIBANnumber' THEN 'CH44 3199 9123 0008 8901 2' ELSE 'RF18539007547034' END WHERE strSettingVariable IN ('settingSwissQrBill', 'settingIBANnumber', 'settingQRreference')");
                    queryExecute(options={datasource: application.datasource}, params={id: {type: "integer", value: local.issuerID}}, sql="UPDATE customers SET strAddress = 'Teststrasse 1', strZIP = '8000', strCity = 'Zürich' WHERE intCustomerID = :id");
                    queryExecute(options={datasource: application.datasource}, params={id: {type: "integer", value: variables.customerID}}, sql="UPDATE customers SET strAddress = 'Kundenstrasse 2', strZIP = '3000', strCity = 'Bern' WHERE intCustomerID = :id");
                    queryExecute(options={datasource: application.datasource}, params={id: {type: "integer", value: variables.invoiceID}}, sql="UPDATE invoices SET strCurrency = 'CHF' WHERE intInvoiceID = :id");
                    variables.invoices.setInvoiceStatus(variables.invoiceID, 2);
                    local.pdf = variables.documents.download(variables.invoiceID);
                    cfpdf(action="getInfo", source=local.pdf, name="local.info");
                    expect(local.info.totalPages).toBe(2);
                    expect(variables.documents.getSnapshot(variables.invoiceID).qr.billerIBAN).toBe("CH44 3199 9123 0008 8901 2");
                    queryExecute(options={datasource: application.datasource}, sql="UPDATE system_settings SET strDefaultValue = '' WHERE strSettingVariable = 'settingIBANnumber'");
                    queryExecute(options={datasource: application.datasource}, params={id: {type: "integer", value: local.issuerID}}, sql="UPDATE customers SET strAddress = 'New issuer address' WHERE intCustomerID = :id");
                    expect(variables.documents.getSnapshot(variables.invoiceID).issuer.address).toBe("Teststrasse 1");
                    expect(hash(variables.documents.download(variables.invoiceID))).toBe(hash(local.pdf));
                } finally {
                    queryExecute(options={datasource: application.datasource}, params={id: {type: "integer", value: local.issuerID}, address: {type: "varchar", value: local.originalIssuer.address}, zip: {type: "varchar", value: local.originalIssuer.zip}, city: {type: "varchar", value: local.originalIssuer.city}}, sql="UPDATE customers SET strAddress = :address, strZIP = :zip, strCity = :city WHERE intCustomerID = :id");
                    loop collection=local.originalSettings item="local.setting" {
                        queryExecute(options={datasource: application.datasource}, params={setting: {type: "varchar", value: local.setting}, value: {type: "varchar", value: local.originalSettings[local.setting]}}, sql="UPDATE system_settings SET strDefaultValue = :value WHERE strSettingVariable = :setting");
                    }
                }
            });
        });
    }
}
