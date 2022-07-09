
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titDowngrade', 'Downgrade', 'Downgrade');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtYouAreDowngrading', 'Sie sind im Begriff, Ihren Plan zu downgraden. Bitte bedenken Sie, dass die Restlaufzeit Ihres aktuellen Plans nicht erstattet wird und der neue Plan sofort aktiviert wird. Sie Sie sicher, dass Sie Ihren Plan downgraden möchten?', 'You are about to downgrade your plan. Please note that the remaining period of your current plan will not be refunded and the new plan will be activated immediately. Are you sure you want to downgrade your plan?');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnYesDowngrade', 'Ja, jetzt downgraden!', 'Yes, downgrade now!');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnWantWait', 'Nein, ich will warten!', 'No, I want to wait!');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titDowngradeNotPossible', 'Downgrade nicht möglich!', 'Downgrade not possible!');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtDowngradeNotPossibleText', 'Um Ihren aktuellen Plan downgraden zu können, müssen Sie einige Ihrer Benutzer löschen. Anzahl zu löschende Benutzer:', 'To downgrade your current plan, you need to delete some of your users. Number of users to delete:');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnToTheUsers', 'Zu den Benutzern', 'To the users');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titUpgrade', 'Upgrade', 'Upgrade');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtYouAreUpgrading', 'Sie sind im Begriff, Ihren aktuellen Plan zu upgraden.', 'You are about to upgrade your current plan.');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtToPayToday', 'Der heute zu bezahlende Betrag:', 'The amount to pay today:');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtYouCantUpgrade', 'Der von Ihnen gewünschte Plan kann noch nicht geändert werden, das der Betrag kleiner ist, als Sie bereits bezahlt haben. Bitte warten Sie, bis die aktuelle Laufzeit kurz vor dem Ende steht.', 'The plan you have requested cannot yet be changed because the amount is less than you have already paid. Please wait until the current period is about to end.');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnYesUpgrade', 'Ja, jetzt upgraden!', 'Yes, upgrade now!');


ALTER TABLE `payrexx`
DROP COLUMN `blnPreAuthorization`,
ADD COLUMN `strCardNumber` varchar(20) NULL AFTER `strPaymentBrand`;

ALTER TABLE `payrexx`
ADD CONSTRAINT `frn_payrexx_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `payrexx`
RENAME INDEX `frn_payrexx_customer` TO `_intCustomerID`,
ADD INDEX `_intTransactionID`(`intTransactionID`) USING BTREE;

ALTER TABLE `payrexx`
DROP COLUMN `strUUID`;

ALTER TABLE `invoices`
ADD COLUMN `intCustomerBookingID` int(11) NULL DEFAULT 0 AFTER `strLanguageISO`;

SET FOREIGN_KEY_CHECKS = 1;