component extends="tests.support.integration_spec" {
    function run() {
        describe("Repeatable V32 account deletion migration", () => {
            beforeEach(() => {
                execute("CREATE TABLE migration_invoice_system_translations (strVariable VARCHAR(100) PRIMARY KEY, strStringDE TEXT, strStringEN TEXT)");
                execute("CREATE TABLE migration_invoice_customers (intCustomerID INT PRIMARY KEY)");
                execute("CREATE TABLE migration_invoice_invoices (
                    intInvoiceID INT PRIMARY KEY, intCustomerID INT NOT NULL, intPaymentStatusID INT NOT NULL,
                    CONSTRAINT migration_invoice_old_customer FOREIGN KEY (intCustomerID)
                    REFERENCES migration_invoice_customers (intCustomerID) ON DELETE CASCADE)");
                execute("INSERT INTO migration_invoice_customers VALUES (1), (2)");
                execute("INSERT INTO migration_invoice_invoices VALUES (11,1,1), (12,1,2)");
            });
            afterEach(() => {
                execute("DROP TABLE IF EXISTS migration_invoice_fk_collision, migration_invoice_system_translations, migration_invoice_account_deletion_steps, migration_invoice_account_operations, migration_invoice_account_deletions, migration_invoice_invoice_documents, migration_invoice_invoices, migration_invoice_customers");
            });

            it("upgrades legacy data once and preserves archives and new work on repeated runs", () => {
                runMigration();
                expect(execute("SELECT blnDocumentIssued FROM migration_invoice_invoices WHERE intInvoiceID = 11").blnDocumentIssued).toBe(0);
                expect(execute("SELECT blnDocumentIssued FROM migration_invoice_invoices WHERE intInvoiceID = 12").blnDocumentIssued).toBe(1);
                // An open invoice being assembled must not become issued on a later migration run.
                execute("INSERT INTO migration_invoice_invoices VALUES (13,2,2,0)");
                execute("INSERT INTO migration_invoice_invoice_documents
                    (intInvoiceID, intOriginalCustomerID, strCustomerName, strCustomerEmail, strCaptureSource, dtmCapturedAt, jsonSnapshot, binPDF)
                    VALUES (12,1,'Müller AG','invoice@example.invalid','legacy','2026-01-02 03:04:05',JSON_OBJECT('version',1),X'255044462D74657374')");
                execute("UPDATE migration_invoice_invoices SET intCustomerID = NULL WHERE intInvoiceID = 12");
                execute("INSERT INTO migration_invoice_account_deletions (intCustomerID, intRootCustomerID, intActorUserID, strStatus) VALUES (1,1,7,'failed')");
                execute("INSERT INTO migration_invoice_account_deletion_steps (intCustomerID, strStep) VALUES (1,'module:todo')");
                execute("INSERT INTO migration_invoice_account_operations (strToken, intCustomerID, strKind, strStatus) VALUES ('test-token',1,'charge','uncertain')");
                execute("UPDATE migration_invoice_system_translations SET strStringDE = 'Custom translation'");
                local.before = archiveState();
                local.schema = execute("SHOW CREATE TABLE migration_invoice_invoices")["Create Table"][1];

                runMigration();
                runMigration();

                expect(archiveState()).toBe(local.before);
                expect(execute("SELECT strStatus FROM migration_invoice_account_deletions WHERE intCustomerID = 1").strStatus).toBe("failed");
                expect(execute("SELECT strStep FROM migration_invoice_account_deletion_steps WHERE intCustomerID = 1").strStep).toBe("module:todo");
                expect(execute("SELECT strStatus FROM migration_invoice_account_operations WHERE strToken = 'test-token'").strStatus).toBe("uncertain");
                expect(execute("SELECT strStringDE FROM migration_invoice_system_translations").strStringDE).toBe("Custom translation");
                expect(execute("SHOW CREATE TABLE migration_invoice_invoices")["Create Table"][1]).toBe(local.schema);
                expect(execute("SELECT blnDocumentIssued FROM migration_invoice_invoices WHERE intInvoiceID = 13").blnDocumentIssued).toBe(0);
                expect(execute("SELECT intInvoiceID FROM migration_invoice_invoices WHERE intInvoiceID = 12 AND intCustomerID IS NULL").recordCount).toBe(1);
                expect(() => execute("DELETE FROM migration_invoice_customers WHERE intCustomerID = 2")).toThrow();
                expect(() => execute("DELETE FROM migration_invoice_invoices WHERE intInvoiceID = 12")).toThrow();
            });

            it("upgrades the original customer constraint when it already has the requested name", () => {
                execute("ALTER TABLE migration_invoice_invoices DROP FOREIGN KEY migration_invoice_old_customer,
                    ADD CONSTRAINT migration_invoice_customer FOREIGN KEY (intCustomerID)
                    REFERENCES migration_invoice_customers (intCustomerID) ON DELETE CASCADE");
                runMigration();
                local.schema = execute("SHOW CREATE TABLE migration_invoice_invoices")["Create Table"][1];
                runMigration();
                expect(execute("SHOW CREATE TABLE migration_invoice_invoices")["Create Table"][1]).toBe(local.schema);
                expect(() => execute("DELETE FROM migration_invoice_customers WHERE intCustomerID = 1")).toThrow();
                execute("UPDATE migration_invoice_invoices SET intCustomerID = NULL WHERE intInvoiceID = 12");
            });

            it("avoids constraint names already used by another table in the schema", () => {
                execute("CREATE TABLE migration_invoice_fk_collision (
                    customer1 INT, customer2 INT,
                    CONSTRAINT migration_invoice_customer FOREIGN KEY (customer1) REFERENCES migration_invoice_customers (intCustomerID),
                    CONSTRAINT migration_invoice_customer_v32_1 FOREIGN KEY (customer2) REFERENCES migration_invoice_customers (intCustomerID))");
                runMigration();
                local.schema = execute("SHOW CREATE TABLE migration_invoice_invoices")["Create Table"][1];
                expect(local.schema).toInclude("migration_invoice_customer_v32_2");
                runMigration();
                expect(execute("SHOW CREATE TABLE migration_invoice_invoices")["Create Table"][1]).toBe(local.schema);
                expect(() => execute("DELETE FROM migration_invoice_customers WHERE intCustomerID = 1")).toThrow();
            });

            it("restores a missing customer constraint without resetting existing issuance state", () => {
                runMigration();
                execute("ALTER TABLE migration_invoice_invoices DROP FOREIGN KEY migration_invoice_customer");
                execute("UPDATE migration_invoice_invoices SET blnDocumentIssued = 0 WHERE intInvoiceID = 12");
                runMigration();
                expect(execute("SELECT blnDocumentIssued FROM migration_invoice_invoices WHERE intInvoiceID = 12").blnDocumentIssued).toBe(0);
                expect(() => execute("DELETE FROM migration_invoice_customers WHERE intCustomerID = 1")).toThrow();
            });
        });
    }

    private string function archiveState() {
        return serializeJSON(execute("SELECT intInvoiceID, intOriginalCustomerID, strCustomerName, strCustomerEmail,
            strCaptureSource, dtmCapturedAt, CAST(jsonSnapshot AS CHAR) AS snapshot, HEX(binPDF) AS pdf
            FROM migration_invoice_invoice_documents ORDER BY intInvoiceID"));
    }

    private void function runMigration() {
        local.source = fileRead("/var/saaster/db/core/V32__invoice-documents.sql", "utf-8");
        // Fixed test-only identifiers: exercise the real migration on an isolated legacy schema.
        loop list="system_translations,account_deletion_steps,account_operations,account_deletions,invoice_documents,invoices,customers" item="local.table" {
            local.source = reReplaceNoCase(local.source, "\b" & local.table & "\b", "migration_invoice_" & local.table, "all");
        }
        local.source = replace(local.source, "frn_inv_customer", "migration_invoice_customer", "all");
        local.source = replace(local.source, "frn_invoice_document_invoice", "migration_invoice_document", "all");
        execute(local.source);
    }

    private any function execute(required string sql) {
        return queryExecute(options={datasource: application.datasource}, sql=arguments.sql);
    }
}
