
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `modules_prices`
ADD COLUMN `decPriceOneTime` decimal(10, 2) NULL AFTER `decPriceYearly`;

RENAME TABLE customer_plans TO customer_bookings;

ALTER TABLE `customer_bookings`
CHANGE COLUMN `intCustomerPlanID` `intCustomerBookingID` int(11) NOT NULL AUTO_INCREMENT FIRST,
MODIFY COLUMN `intPlanID` int(11) NULL AFTER `intCustomerID`,
ADD COLUMN `intModuleID` int(11) NULL AFTER `intPlanID`,
DROP PRIMARY KEY,
ADD PRIMARY KEY (`intCustomerBookingID`) USING BTREE,
ADD INDEX `_intModuleID`(`intModuleID`) USING BTREE,
ADD CONSTRAINT `frn_cp_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `modules`
ADD COLUMN `intNumTestDays` int(11) NOT NULL AFTER `blnBookable`,
ADD COLUMN `strSettingPath` varchar(255) NULL AFTER `intNumTestDays`;

DROP TABLE customer_modules;

CREATE TABLE `customer_bookings_history`  (
  `intHistoryID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intPlanID` int(11) NULL DEFAULT NULL,
  `intModuleID` int(11) NULL DEFAULT NULL,
  `dtmStartDate` date NULL DEFAULT NULL,
  `dtmEndDate` date NULL DEFAULT NULL,
  `dtmEndTestDate` date NULL DEFAULT NULL,
  `blnPaused` tinyint(1) NOT NULL DEFAULT 0,
  `strRecurring` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intHistoryID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intPlanID`(`intPlanID`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_cbh_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cbh_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cbh_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION
);


UPDATE system_translations SET strStringEN = 'Users' WHERE intSystTransID = 123;
UPDATE system_translations SET strStringEN = 'Users overview' WHERE intSystTransID = 124;



INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtOneTime', 'Einmalig', 'One time');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titPlansAndModules', 'Pläne und Module', 'Plans and modules');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titYourPlan', 'Plan', 'Plan');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtChangePlan', 'Plan ändern', 'Change plan');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgNoPlanBooked', 'Sie haben noch keinen Plan gebucht', 'You have not booked a plan yet');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtBookNow', 'Jetzt buchen', 'Book now');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtPlanStatus', 'Status', 'Status');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtRenewPlanOn', 'Ihr Plan wird verlängert am', 'Your plan will be renewed on');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtFreeForever', 'Für immer kostenlos', 'Free of charge forever');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtExpired', 'Abgelaufen', 'Expired');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtPlanExpired', 'Ihr Abonnement ist abgelaufen', 'Your subscription has expired');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtTest', 'Test', 'Test');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtTestUntil', 'Sie können testen bis zum Ablaufdatum', 'You can test until the expiry date');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtTestTimeExpired', 'Ihre Testzeit ist abgelaufen', 'Your test time has expired');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtCanceled', 'Gekündigt', 'Canceled');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtSubscriptionCanceled', 'Abonnement gekündigt. Ihre Daten werden nach dem Ablaufdatum gelöscht.', 'Subscription cancelled. Your data will be deleted after the expiry date.');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtRenewNow', 'Jetzt verlängern', 'Renew now');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtUpgradePlanNow', 'Plan jetzt upgraden!', 'Upgrade plan now!');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtCancelPlan', 'Plan kündigen', 'Cancel plan');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtBookedOn', 'Gebucht am', 'Booked on');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgCancelPlanWarningText', 'Wenn Sie Ihr Anonnement kündigen, können Sie bis zum Ende der Laufzeit weiterarbeiten. Danach werden alle Daten dieses Plans gelöscht. Möchten Sie diesen Plan wirklich kündigen?', 'If you cancel your subscription, you can continue until the end of the term. After that, all data in this plan will be deleted. Do you really want to cancel this plan?');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnDontCancel', 'Nein, nicht kündigen!', 'No, do not cancel!');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnYesCancel', 'Ja, kündigen!', 'Yes, cancel!');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgCanceledSuccessful', 'Ihr Abonnement wurde erfolgreich gekündigt. Am Ende der Laufzeit werden Ihre Daten gelöscht.', 'Your subscription has been successfully cancelled. At the end of the term, your data will be deleted.');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtExpiryDate', 'Ablaufdatum', 'Expiry date');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnRevokeCancellation', 'Kündigung zurückziehen', 'Revoke cancellation');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgRevokedSuccessful', 'Die Kündigung wurde erfolgreich zurückgezogen. Ihr Abonnement ist wieder aktiv.', 'The cancellation has been successfully revoked. Your subscription is active again.');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtInformation', 'Information', 'Information');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtCancel', 'Kündigen', 'Cancel');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgCancelModuleWarningText', 'Wenn Sie dieses Modul kündigen, können Sie bis zum Ende der Laufzeit weiterarbeiten. Danach werden alle Daten dieses Moduls gelöscht. Möchten Sie dieses Modul wirklich kündigen?', 'If you cancel this module, you can continue working until the end of the term. After that, all data of this module will be deleted. Do you really want to cancel this module?');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtIncludedInPlans', 'Dieses Modul ist in folgenden Plänen bereits enthalten', 'This module is already included in the following plans');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtOneTimePayment', 'Einmalige Zahlung', 'One time payment');
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtIncludedInPlan', 'Im Plan enthalten', 'Included in plan');



INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ('cancel', 'handler/cancel.cfm', 0, 1, 0);


SET FOREIGN_KEY_CHECKS = 1;