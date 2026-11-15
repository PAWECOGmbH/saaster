SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS customer_module_blocks (
    intCustomerID INT NOT NULL,
    intModuleID INT NOT NULL,
    intActorUserID INT NULL,
    dtmBlockedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (intCustomerID, intModuleID),
    CONSTRAINT fk_module_block_customer FOREIGN KEY (intCustomerID) REFERENCES customers (intCustomerID) ON DELETE CASCADE,
    CONSTRAINT fk_module_block_module FOREIGN KEY (intModuleID) REFERENCES modules (intModuleID) ON DELETE CASCADE,
    CONSTRAINT fk_module_block_actor FOREIGN KEY (intActorUserID) REFERENCES users (intUserID) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO system_translations (strVariable, strStringDE, strStringEN) VALUES
    ('btnBlockModule', 'Modul sperren', 'Block module'),
    ('btnUnblockModule', 'Modul freigeben', 'Unblock module'),
    ('txtModuleBlocked', 'Zugriff gesperrt', 'Access blocked'),
    ('txtModuleBlockInfo', 'Die Sperre verhindert den Modulzugriff und weitere Scheduler-Ausführungen. Bereits laufende Aufgaben dürfen fertiglaufen. Abrechnung und Laufzeit laufen weiter; Ihre Daten bleiben erhalten.', 'Blocking prevents module access and further scheduler runs. Tasks already running may finish. Billing and the subscription period continue; your data is preserved.'),
    ('txtModuleUnblockInfo', 'Die Freigabe hebt nur die Zugriffssperre auf. Zugriff und Scheduler-Ausführungen sind wieder möglich, sofern eine gültige Buchung besteht. Die Laufzeit wird nicht verlängert.', 'Unblocking only removes the access restriction. Access and scheduler runs resume if a valid booking exists. The subscription period is not extended.'),
    ('msgModuleBlocked', 'Ihr Zugriff auf dieses Modul wurde gesperrt. Ihr Abonnement bleibt bestehen; Abrechnung und Laufzeit laufen weiter.', 'Your access to this module has been blocked. Your subscription remains in place; billing and the subscription period continue.'),
    ('msgModuleAccessSaved', 'Der Modulzugriff wurde aktualisiert.', 'Module access has been updated.'),
    ('msgModuleAccessInvalid', 'Der Modulzugriff konnte nicht geändert werden. Prüfen Sie den Kunden und die Modulbuchung.', 'Module access could not be changed. Check the customer and module booking.');

-- Update the default customer-facing wording without replacing customized translations.
UPDATE system_translations
SET strStringDE = 'Ihr Zugriff auf dieses Modul wurde gesperrt. Ihr Abonnement bleibt bestehen; Abrechnung und Laufzeit laufen weiter.'
WHERE strVariable = 'msgModuleBlocked'
    AND strStringDE = 'Das Modul ist für diesen Kunden gesperrt. Abrechnung und Laufzeit laufen weiter.';

UPDATE system_translations
SET strStringEN = 'Your access to this module has been blocked. Your subscription remains in place; billing and the subscription period continue.'
WHERE strVariable = 'msgModuleBlocked'
    AND strStringEN = 'The module is blocked for this customer. Billing and the subscription period continue.';
