component extends="tests.support.integration_spec" {
    function run() {
        describe("Immediate account deletion lifecycle", () => {
            beforeEach(() => {
                logout();
                recordLogs();
                variables.lifecycle = new backend.core.com.account_lifecycle();
                variables.cleanup = new backend.core.com.account_deletion();
                variables.customerID = variables.fixtures.createCustomer();
                variables.password = "Deletion test password 123!";
                variables.owner = variables.fixtures.createUser(customerID=variables.customerID, superAdmin=true,
                    passwordHash=application.objGlobal.hashPassword(variables.password));
                loginAs(variables.owner);
                variables.originalPayrexx = duplicate(application.payrexxStruct);
                application.payrexxStruct = {payrexxAPIurl: "http://127.0.0.1/tests/support/payrexx_mock.cfm?route=/", payrexxAPIinstance: "regression", payrexxAPIkey: "test-key"};
            });
            afterEach(() => {
                application.payrexxStruct = variables.originalPayrexx;
            });
            it("requires the exact actor's password and deletion permission", () => {
                expect(variables.lifecycle.requestDeletion(variables.owner.userID, variables.customerID, "wrong").reason).toBe("identity");
                local.member = variables.fixtures.createUser(customerID=variables.customerID, passwordHash=application.objGlobal.hashPassword(variables.password));
                expect(variables.lifecycle.requestDeletion(local.member.userID, variables.customerID, variables.password).reason).toBe("permission");
                expect(variables.lifecycle.isDeleting(variables.customerID)).toBeFalse();
            });
            it("freezes access and admission immediately and records an idempotent request", () => {
                expect(requestDeletion().success).toBeTrue();
                expect(variables.lifecycle.isDeleting(variables.customerID)).toBeTrue();
                expect(execute("SELECT blnActive FROM customers WHERE intCustomerID = :id").blnActive).toBe(0);
                expect(variables.lifecycle.beginOperation(variables.customerID, "charge")).toBe("");
                expect(variables.lifecycle.beginOperation(variables.customerID, "booking")).toBe("");
                local.before = execute("SELECT dtmRequestedAt FROM account_deletions WHERE intCustomerID = :id").dtmRequestedAt;
                expect(requestDeletion().success).toBeTrue();
                expect(execute("SELECT dtmRequestedAt FROM account_deletions WHERE intCustomerID = :id").dtmRequestedAt).toBe(local.before);
            });
            it("waits for running or uncertain charges without deleting their accounting data", () => {
                local.token = variables.lifecycle.beginOperation(variables.customerID, "charge");
                expect(len(local.token)).toBeGT(0);
                expect(requestDeletion().success).toBeTrue();
                expect(variables.cleanup.process(variables.customerID).reason).toBe("operations");
                variables.lifecycle.finishOperation(local.token, true);
                expect(variables.cleanup.process(variables.customerID).reason).toBe("operations");
                expect(execute("SELECT intCustomerID FROM customers WHERE intCustomerID = :id").recordCount).toBe(1);
                variables.lifecycle.finishOperation(local.token);
                local.result = variables.cleanup.process(variables.customerID);
                expect(local.result.success).toBeTrue(serializeJSON(variables.logRecorder.getCalls()));
                expect(execute("SELECT intCustomerID FROM customers WHERE intCustomerID = :id").recordCount).toBe(0);
                expect(variables.cleanup.process(variables.customerID).success).toBeTrue();
            });
            it("blocks a second charge until an unknown outcome has been reconciled", () => {
                local.token = variables.lifecycle.beginOperation(variables.customerID, "charge");
                variables.lifecycle.finishOperation(local.token, true);
                expect(variables.lifecycle.beginOperation(variables.customerID, "charge")).toBe("");
                variables.lifecycle.finishOperation(local.token);
                local.next = variables.lifecycle.beginOperation(variables.customerID, "charge");
                expect(len(local.next)).toBeGT(0);
                variables.lifecycle.finishOperation(local.next);
            });
            it("keeps the stopped account and progress when token revocation fails, then resumes", () => {
                execute("INSERT INTO payrexx (intCustomerID, dtmTimeUTC, intGatewayID, intTransactionID, strStatus) VALUES (:id, UTC_TIMESTAMP(), 40964971, 40964971, 'authorized')");
                expect(requestDeletion().success).toBeTrue();
                application.payrexxStruct.payrexxAPIkey = "wrong-test-key";
                expect(variables.cleanup.process(variables.customerID).reason).toBe("cleanup");
                expect(execute("SELECT blnActive FROM customers WHERE intCustomerID = :id").blnActive).toBe(0);
                expect(execute("SELECT strStep FROM account_deletion_steps WHERE intCustomerID = :id").recordCount).toBeGT(0);
                application.payrexxStruct.payrexxAPIkey = "test-key";
                expect(variables.cleanup.process(variables.customerID).success).toBeTrue(serializeJSON(variables.logRecorder.getCalls()));
                expect(execute("SELECT strStatus FROM account_deletions WHERE intCustomerID = :id").strStatus).toBe("completed");
                expect(execute("SELECT intPayrexxID FROM payrexx WHERE intCustomerID = :id").recordCount).toBe(0);
            });
            it("retains issued invoices and recorded payments through the complete cleanup", () => {
                local.invoices = new backend.core.com.invoices();
                local.documents = new backend.core.com.invoice_documents();
                local.created = local.invoices.createInvoice({customerID:variables.customerID, language:"en", title:"Deletion lifecycle invoice"});
                expect(local.created.success).toBeTrue(local.created.message);
                local.id = local.created.newInvoiceID;
                expect(local.invoices.insertInvoicePositions({invoiceID:local.id, positions:[{title:"Service", quantity:1, price:100, vat:0, discountPercent:0, unit:"x", description:""}]}).success).toBeTrue();
                local.invoices.setInvoiceStatus(local.id, 2);
                local.pdfHash = hash(local.documents.download(local.id));
                expect(local.invoices.insertPayment({invoiceID:local.id, customerID:variables.customerID, date:now(), amount:25, type:"Bank"}).success).toBeTrue();
                expect(requestDeletion().success).toBeTrue();
                expect(variables.cleanup.process(variables.customerID).success).toBeTrue(serializeJSON(variables.logRecorder.getCalls()));
                expect(local.invoices.getInvoiceData(local.id).customerID).toBe(0);
                expect(local.invoices.getInvoiceData(local.id).amountPaid).toBe(25);
                expect(hash(local.documents.download(local.id))).toBe(local.pdfHash);
            });
            it("fails closed when a registered module has lost its cleanup implementation", () => {
                local.moduleID = variables.fixtures.createModule();
                execute("UPDATE modules SET strSettingPath = 'backend/modules/missing_deletion_test/settings' WHERE intModuleID = :module", {module:{type:"integer",value:local.moduleID}});
                expect(requestDeletion().success).toBeTrue();
                expect(variables.cleanup.process(variables.customerID).reason).toBe("cleanup");
                expect(execute("SELECT intCustomerID FROM customers WHERE intCustomerID = :id").recordCount).toBe(1);
                // Restore the test-only registration; no production module is removed.
                execute("UPDATE modules SET strSettingPath = '' WHERE intModuleID = :module", {module:{type:"integer",value:local.moduleID}});
                expect(variables.cleanup.process(variables.customerID).success).toBeTrue();
            });
            it("rolls back the whole relational finalization when a customer cannot be removed", () => {
                execute("CREATE TABLE deletion_test_restrict (intCustomerID INT PRIMARY KEY, FOREIGN KEY (intCustomerID) REFERENCES customers (intCustomerID) ON DELETE RESTRICT)");
                try {
                    execute("INSERT INTO deletion_test_restrict VALUES (:id)");
                    expect(requestDeletion().success).toBeTrue();
                    expect(variables.cleanup.process(variables.customerID).reason).toBe("cleanup");
                    expect(execute("SELECT intCustomerID FROM customers WHERE intCustomerID = :id").recordCount).toBe(1);
                } finally {
                    execute("DROP TABLE deletion_test_restrict");
                }
                expect(variables.cleanup.process(variables.customerID).success).toBeTrue();
            });
            it("stops active, waiting and trial bookings and prevents their reactivation", () => {
                local.moduleID = variables.fixtures.createModule();
                local.bookings = [];
                loop list="active,waiting,test,payment,canceled" item="local.status" {
                    arrayAppend(local.bookings, variables.fixtures.createBooking(customerID=variables.customerID, moduleID=local.moduleID,
                        status=local.status, startDate=dateFormat(now(), "yyyy-mm-dd"), endDate=dateFormat(dateAdd("m",1,now()), "yyyy-mm-dd")));
                }
                expect(requestDeletion().success).toBeTrue();
                expect(execute("SELECT intBookingID FROM bookings WHERE intCustomerID = :id AND (strStatus <> 'canceled' OR dteEndDate >= UTC_DATE())").recordCount).toBe(0);
                expect(new backend.core.com.modules().getModuleAccessBookings(variables.customerID, local.moduleID).recordCount).toBe(0);
                expect(new backend.core.com.invoices().createInvoice({customerID:variables.customerID}).success).toBeFalse();
                expect(new backend.core.com.book().checkBooking(variables.customerID, {}, "monthly").success).toBeFalse();
            });
            it("keeps the invoice and exact provider reference after an ambiguous payment response", () => {
                local.invoices = new backend.core.com.invoices();
                local.created = local.invoices.createInvoice({customerID:variables.customerID, language:"en", title:"Unknown payment test"});
                expect(local.created.success).toBeTrue(local.created.message);
                local.id = local.created.newInvoiceID;
                execute("INSERT INTO payrexx (intCustomerID, dtmTimeUTC, intGatewayID, intTransactionID, strStatus) VALUES (:id, UTC_TIMESTAMP(), 40964971, 40964971, 'authorized')");
                application.payrexxStruct.payrexxAPIurl = "http://127.0.0.1/tests/support/payrexx_mock.cfm?route=/JsonError/";
                expect(local.invoices.payInvoice(local.id).success).toBeFalse();
                local.operation = execute("SELECT * FROM account_operations WHERE intCustomerID = :id AND strKind = 'charge'");
                expect(local.operation.recordCount).toBe(1);
                expect(local.operation.intInvoiceID).toBe(local.id);
                expect(local.operation.strStatus).toBe("uncertain");
                expect(local.operation.strPaymentReference).toInclude(variables.customerID & "@");
                local.invoices.deleteInvoice(local.id);
                expect(local.invoices.getInvoiceData(local.id).customerID).toBe(variables.customerID);
                expect(requestDeletion().success).toBeTrue();
                expect(variables.cleanup.process(variables.customerID).reason).toBe("operations");
            });
            it("limits activated organizations to their owner and platform administrators", () => {
                local.member = variables.fixtures.createUser(customerID=variables.customerID);
                application.objMembershipMigration.activate(variables.owner.userID, variables.customerID, variables.owner.userID, true);
                execute("UPDATE organization_memberships SET strRoleKey = 'organization.admin' WHERE intOrganizationID = :id AND intUserID = :member", {member:{type:"integer",value:local.member.userID}});
                expect(variables.lifecycle.canDelete(variables.owner.userID, variables.customerID)).toBeTrue();
                expect(variables.lifecycle.canDelete(local.member.userID, variables.customerID)).toBeFalse();
                local.platform = variables.fixtures.createUser(customerID=variables.fixtures.createCustomer(), sysAdmin=true);
                expect(variables.lifecycle.canDelete(local.platform.userID, variables.customerID)).toBeTrue();
                session.supportLogin = true;
                expect(variables.lifecycle.canDelete(local.platform.userID, variables.customerID)).toBeFalse();
                structDelete(session, "supportLogin");
            });
            it("blocks parent deletion for owners and sysadmins even with an obsolete cascade argument", () => {
                local.tenant = variables.fixtures.createCustomer(parentID=variables.customerID, active=false);
                expect(requestDeletion().reason).toBe("tenants");
                local.platform = variables.fixtures.createUser(customerID=variables.fixtures.createCustomer(), sysAdmin=true,
                    passwordHash=application.objGlobal.hashPassword(variables.password));
                expect(variables.lifecycle.requestDeletion(actorID=local.platform.userID, customerID=variables.customerID,
                    password=variables.password, includeTenants=true).reason).toBe("tenants");
                expect(variables.lifecycle.isDeleting(variables.customerID)).toBeFalse();
                expect(execute("SELECT blnActive FROM customers WHERE intCustomerID = :id").blnActive).toBe(1);
                expect(variables.lifecycle.isDeleting(local.tenant)).toBeFalse();
            });
            it("requires every tenant deletion to finish before the parent can be requested", () => {
                local.tenant = variables.fixtures.createCustomer(parentID=variables.customerID);
                local.sibling = variables.fixtures.createCustomer(parentID=variables.customerID);
                local.work = variables.lifecycle.beginOperation(local.tenant, "request");
                expect(variables.lifecycle.requestDeletion(variables.owner.userID, local.tenant, variables.password).success).toBeTrue();
                expect(variables.cleanup.process(local.tenant).reason).toBe("operations");
                expect(requestDeletion().reason).toBe("tenants");
                expect(variables.lifecycle.isDeleting(local.sibling)).toBeFalse();
                variables.lifecycle.finishOperation(local.work);
                expect(variables.cleanup.process(local.tenant).success).toBeTrue();
                expect(requestDeletion().reason).toBe("tenants");
                expect(variables.lifecycle.requestDeletion(variables.owner.userID, local.sibling, variables.password).success).toBeTrue();
                expect(variables.cleanup.process(local.sibling).success).toBeTrue();
                expect(execute("SELECT blnActive FROM customers WHERE intCustomerID = :id").blnActive).toBe(1);
                expect(requestDeletion().success).toBeTrue();
                expect(variables.cleanup.process(variables.customerID).success).toBeTrue();
            });
            it("protects the platform operator even without tenants", () => {
                variables.fixtures.createUser(customerID=variables.customerID, sysAdmin=true);
                expect(requestDeletion().reason).toBe("protected");
            });
            it("still creates tenants for an available parent", () => {
                local.previousIP = session.usersIP ?: "";
                session.usersIP = "";
                try {
                    local.result = application.objCustomer.insertTenant({customerID:variables.customerID, userID:variables.owner.userID,
                        company_name:"TestBox tenant creation", contact_person:"TestBox Contact"});
                    expect(local.result.success).toBeTrue(local.result.message);
                    expect(execute("SELECT intCustomerID FROM customers WHERE intCustParentID = :id").recordCount).toBe(1);
                    expect(requestDeletion().reason).toBe("tenants");
                } finally {
                    session.usersIP = local.previousIP;
                    local.children = execute("SELECT intCustomerID FROM customers WHERE intCustParentID = :id");
                    loop query=local.children { application.objCustomer.deleteAccount(local.children.intCustomerID); }
                }
            });
            it("rejects tenant creation after a deletion request and rechecks children during cleanup", () => {
                expect(requestDeletion().success).toBeTrue();
                expect(application.objCustomer.insertTenant({customerID:variables.customerID, userID:variables.owner.userID,
                    company_name:"Blocked tenant", contact_person:"Test"}).success).toBeFalse();
                // Simulate a late write from an extension that bypassed the core creation service.
                local.tenant = variables.fixtures.createCustomer(parentID=variables.customerID);
                expect(variables.cleanup.process(variables.customerID).reason).toBe("tenants");
                expect(execute("SELECT strStep FROM account_deletion_steps WHERE intCustomerID = :id").recordCount).toBe(0);
                expect(variables.lifecycle.isDeleting(local.tenant)).toBeFalse();
            });
            it("rejects old batch deletion requests before running any cleanup", () => {
                local.tenant = variables.fixtures.createCustomer(parentID=variables.customerID);
                execute("INSERT INTO account_deletions (intCustomerID, intRootCustomerID, intActorUserID) VALUES (:id,:id,:actor), (:tenant,:id,:actor)", {tenant:{type:"integer",value:local.tenant}});
                expect(variables.cleanup.process(variables.customerID).reason).toBe("scope");
                expect(execute("SELECT strStep FROM account_deletion_steps WHERE intCustomerID = :id").recordCount).toBe(0);
            });
            it("removes a single account while preserving identities linked outside it", () => {
                local.outside = variables.fixtures.createCustomer();
                execute("INSERT INTO customer_user (intCustomerID, intUserID, blnStandard) VALUES (:outside, :actor, 0)", {outside:{type:"integer",value:local.outside}});
                expect(requestDeletion().success).toBeTrue();
                local.result = variables.cleanup.process(variables.customerID);
                expect(local.result.success).toBeTrue(serializeJSON(variables.logRecorder.getCalls()));
                expect(execute("SELECT intCustomerID FROM customers WHERE intCustomerID = :id").recordCount).toBe(0);
                expect(execute("SELECT intUserID FROM users WHERE intUserID = :actor").recordCount).toBe(1);
            });
        });
    }
    private struct function requestDeletion() {
        return variables.lifecycle.requestDeletion(variables.owner.userID, variables.customerID, variables.password);
    }
    private query function execute(required string sql, struct params = {}) {
        arguments.params.id = {type:"integer",value:variables.customerID};
        arguments.params.actor = {type:"integer",value:variables.owner.userID};
        return queryExecute(options={datasource:application.datasource},params=arguments.params,sql=arguments.sql);
    }
}
