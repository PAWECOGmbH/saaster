SET NAMES utf8mb4;

-- Existing non-drafts were issued before snapshots existed. Mark them once.
SET @add_invoice_issued = NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'invoices' AND COLUMN_NAME = 'blnDocumentIssued'
);
SET @invoice_issued_sql = IF(@add_invoice_issued,
    'ALTER TABLE invoices ADD COLUMN blnDocumentIssued TINYINT(1) NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE invoice_issued_stmt FROM @invoice_issued_sql;
EXECUTE invoice_issued_stmt;
DEALLOCATE PREPARE invoice_issued_stmt;
UPDATE invoices SET blnDocumentIssued = 1 WHERE @add_invoice_issued AND intPaymentStatusID <> 1;

-- Keep the issued document independent of customer, user and billing settings.
CREATE TABLE IF NOT EXISTS invoice_documents (
    intInvoiceID INT NOT NULL,
    intOriginalCustomerID INT NOT NULL,
    strCustomerName VARCHAR(255) NOT NULL,
    strCustomerEmail VARCHAR(255) NOT NULL,
    strCaptureSource VARCHAR(20) NOT NULL,
    dtmCapturedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    jsonSnapshot JSON NOT NULL,
    binPDF LONGBLOB NOT NULL,
    PRIMARY KEY (intInvoiceID),
    KEY idx_invoice_documents_customer (intOriginalCustomerID),
    CONSTRAINT frn_invoice_document_invoice FOREIGN KEY (intInvoiceID)
        REFERENCES invoices (intInvoiceID) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A deletion must first archive and explicitly detach the invoices. Never cascade.
-- Leave a correct constraint untouched on repeated runs. Upgrade the FK and nullable
-- column together so there is no intermediate schema without deletion protection.
SET @invoice_customer_fk = (
    SELECT CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'invoices'
      AND COLUMN_NAME = 'intCustomerID' AND REFERENCED_TABLE_NAME = 'customers'
    LIMIT 1
);
SET @invoice_customer_ready = EXISTS (
    SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS r
    INNER JOIN information_schema.COLUMNS c
        ON c.TABLE_SCHEMA = r.CONSTRAINT_SCHEMA AND c.TABLE_NAME = r.TABLE_NAME
    WHERE r.CONSTRAINT_SCHEMA = DATABASE() AND r.TABLE_NAME = 'invoices'
      AND r.CONSTRAINT_NAME = @invoice_customer_fk
      AND r.DELETE_RULE IN ('RESTRICT', 'NO ACTION')
      AND r.UPDATE_RULE IN ('RESTRICT', 'NO ACTION')
      AND c.COLUMN_NAME = 'intCustomerID' AND c.IS_NULLABLE = 'YES'
);
-- MySQL cannot drop and recreate the same FK name in this combined ALTER.
-- Constraint names are schema-wide: choose a free name, including on older V32 schemas.
SET @invoice_customer_new_fk = IF(
    NOT EXISTS (
        SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS
        WHERE CONSTRAINT_SCHEMA = DATABASE() AND CONSTRAINT_NAME = 'frn_inv_customer'
    ),
    'frn_inv_customer',
    CONCAT('frn_inv_customer_v32_', (
        SELECT COALESCE(MAX(CAST(SUBSTRING(CONSTRAINT_NAME, LENGTH('frn_inv_customer_v32_') + 1) AS UNSIGNED)), 0) + 1
        FROM information_schema.REFERENTIAL_CONSTRAINTS
        WHERE CONSTRAINT_SCHEMA = DATABASE() AND CONSTRAINT_NAME REGEXP '^frn_inv_customer_v32_[0-9]+$'
    ))
);
SET @invoice_customer_sql = IF(@invoice_customer_ready, 'SELECT 1', CONCAT(
    'ALTER TABLE invoices ',
    IF(@invoice_customer_fk IS NULL, '', CONCAT(
        'DROP FOREIGN KEY `', REPLACE(@invoice_customer_fk, '`', '``'), '`, ')),
    'MODIFY intCustomerID INT NULL, ',
    'ADD CONSTRAINT `', REPLACE(@invoice_customer_new_fk, '`', '``'), '` FOREIGN KEY (intCustomerID) ',
    'REFERENCES customers (intCustomerID) ON DELETE RESTRICT ON UPDATE RESTRICT'
));
PREPARE invoice_customer_stmt FROM @invoice_customer_sql;
EXECUTE invoice_customer_stmt;
DEALLOCATE PREPARE invoice_customer_stmt;

-- Persist the deletion intent independently of the account; no grace period.
CREATE TABLE IF NOT EXISTS account_deletions (
    intCustomerID INT NOT NULL,
    intRootCustomerID INT NOT NULL,
    intActorUserID INT NOT NULL,
    strStatus VARCHAR(20) NOT NULL DEFAULT 'requested',
    strLastError VARCHAR(255) NOT NULL DEFAULT '',
    dtmRequestedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dtmCompletedAt DATETIME NULL,
    PRIMARY KEY (intCustomerID),
    KEY idx_account_deletion_root (intRootCustomerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Running work must drain before cleanup. Unknown payment outcomes never expire silently.
CREATE TABLE IF NOT EXISTS account_operations (
    strToken VARCHAR(36) NOT NULL,
    intCustomerID INT NOT NULL,
    strKind VARCHAR(20) NOT NULL,
    strStatus VARCHAR(20) NOT NULL DEFAULT 'running',
    dtmStartedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (strToken),
    KEY idx_account_operation_customer (intCustomerID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS account_deletion_steps (
    intCustomerID INT NOT NULL,
    strStep VARCHAR(100) NOT NULL,
    dtmCompletedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (intCustomerID, strStep)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Upgrade earlier V32 lifecycle tables without replacing pending operations.
SET @account_operation_invoice_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'account_operations' AND column_name = 'intInvoiceID'
);
SET @account_operation_sql = IF(@account_operation_invoice_exists = 0,
    'ALTER TABLE account_operations ADD COLUMN intInvoiceID INT NULL', 'SELECT 1');
PREPARE account_operation_statement FROM @account_operation_sql;
EXECUTE account_operation_statement;
DEALLOCATE PREPARE account_operation_statement;

SET @account_operation_reference_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'account_operations' AND column_name = 'strPaymentReference'
);
SET @account_operation_sql = IF(@account_operation_reference_exists = 0,
    'ALTER TABLE account_operations ADD COLUMN strPaymentReference VARCHAR(255) NULL', 'SELECT 1');
PREPARE account_operation_statement FROM @account_operation_sql;
EXECUTE account_operation_statement;
DEALLOCATE PREPARE account_operation_statement;

-- Preserve customized wording on every rerun.
INSERT IGNORE INTO system_translations (strVariable, strStringDE, strStringEN) VALUES
    ('msgAccountDeletionPending', 'Ihr Konto wird gelöscht. Neue Buchungen und Abbuchungen sind gesperrt. Falls die Bereinigung noch aussteht, wenden Sie sich an den Support.', 'Your account is being deleted. New bookings and charges are blocked. If cleanup is still pending, contact support.');

INSERT IGNORE INTO system_translations (strVariable, strStringDE, strStringEN) VALUES
    ('msgAccountHasTenants', 'Dieses Konto kann erst gelöscht werden, wenn alle zugehörigen Mandanten einzeln gelöscht wurden. Deaktivierte Mandanten und noch nicht abgeschlossene Löschungen zählen ebenfalls dazu.', 'This account can only be deleted after all its tenants have been deleted individually. Inactive tenants and pending deletions also count.');

INSERT IGNORE INTO system_translations (strVariable, strStringDE, strStringEN) VALUES
    ('txtAccountDeletionWarning', 'Der Zugang zu diesem Konto und die Daten Ihrer gebuchten Module werden dauerhaft gelöscht. Ihre Abonnements werden sofort beendet. Dieser Vorgang kann nicht rückgängig gemacht werden.', 'Access to this account and your module data will be permanently deleted. Your subscriptions stop immediately. This action cannot be undone.'),
    ('txtAccountDeletionPassword', 'Bestätigen Sie mit Ihrem eigenen Passwort', 'Confirm with your own password'),
    ('txtAccountDeletionConfirm', 'Ich bestätige die endgültige Löschung dieses Kontos.', 'I confirm the permanent deletion of this account.'),
    ('msgAccountDeletionComplete', 'Das Konto wurde gelöscht.', 'The account has been deleted.'),
    ('msgAccountDeletionStarted', 'Die Löschung wurde gestartet. Der Zugriff ist gesperrt und Ihre Abonnements sind beendet. Die Bereinigung ist noch nicht abgeschlossen. Falls sie nicht abgeschlossen werden kann, wenden Sie sich an den Support.', 'Deletion has started. Access is blocked and your subscriptions have stopped. Cleanup is not complete yet. Contact support if it cannot be completed.'),
    ('msgAccountDeletionIdentity', 'Ihr Passwort konnte nicht bestätigt werden. Versuchen Sie es bei wiederholten Fehlversuchen später erneut.', 'Your password could not be verified. Try again later if there have been repeated failed attempts.'),
    ('msgAccountDeletionDenied', 'Dieses Konto kann von Ihnen nicht gelöscht werden.', 'You cannot delete this account.'),
    ('btnAccountDeletionRetry', 'Löschung fortsetzen', 'Continue deletion');

INSERT IGNORE INTO system_translations (strVariable, strStringDE, strStringEN) VALUES
('txtAccountDeletionPending', 'Löschung ausstehend', 'Deletion pending');

INSERT IGNORE INTO system_translations (strVariable, strStringDE, strStringEN) VALUES
    ('txtAccountDeletionFailed', 'Löschung fehlgeschlagen', 'Deletion failed'),
    ('msgAccountDeletionFailed', 'Die Bereinigung konnte nicht abgeschlossen werden. Der Zugriff bleibt gesperrt und die Abonnements sind beendet. Bitte wenden Sie sich an den Support. Nach Behebung der Ursache kann die bestehende Löschung fortgesetzt werden.', 'Cleanup could not be completed. Access remains blocked and subscriptions have stopped. Please contact support. Once the cause has been resolved, the existing deletion can be continued.');
