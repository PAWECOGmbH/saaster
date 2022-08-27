SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titWaiting', 'Wartet', 'Waiting');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtWaitingForPayment', 'Wartet auf Bezahlung', 'Waiting for payment');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtRenewModuleOn', 'Ihr Modul wird verlängert am', 'Your module will be renewed on');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtAfterwards', 'Danach', 'Afterwards');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtOr', 'oder', 'or');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnDepPayMethod', 'Mit hinterlegter Zahlungsart bezahlen', 'Pay with deposited payment method');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnOtherPayMethod', 'Andere Zahlungsart wählen', 'Choose other payment method');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgInvoicePaid', 'Die Rechnung wurde erfolgreich bezahlt. Vielen Dank!', 'The invoice has been paid successfully. Thank you very much!');

UPDATE system_translations
SET strStringDE = 'Leider konnten wir keine Ihrer registrierten Zahlungsmethoden belasten. Bitte prüfen Sie die Zahlungsarten.',
    strStringEN = 'Unfortunately, we could not charge any of your registered payment methods. Please check the payment methods.'
WHERE intSystTransID = 278;

ALTER TABLE `modules`
ADD COLUMN `blnFree` tinyint(1) NULL DEFAULT 0 AFTER `strSettingPath`;



SET FOREIGN_KEY_CHECKS = 1;