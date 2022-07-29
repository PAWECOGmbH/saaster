
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS customer_bookings_history;
DROP TABLE IF EXISTS notifications_trans;

ALTER TABLE `invoices`
CHANGE COLUMN `intCustomerBookingID` `intBookingID` int(11) NULL DEFAULT 0 AFTER `strLanguageISO`;

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ('account-settings/plans', 'views/customer/plans.cfm', 0, 1, 0);

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ('plan-settings', 'handler/plans.cfm', 0, 1, 0);

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ('account-settings/payment', 'views/customer/payment.cfm', 0, 1, 0);

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ('payment-settings', 'handler/payment.cfm', 0, 1, 0);



ALTER TABLE `payrexx`
ADD COLUMN `blnDefault` tinyint(1) NOT NULL DEFAULT 0,
ADD COLUMN `blnFailed` tinyint(1) NOT NULL DEFAULT 0;

ALTER TABLE `database`.`bookings`

DROP PRIMARY KEY,
ADD PRIMARY KEY (`intBookingID`, `blnFailed`) USING BTREE;


-- ----------------------------
-- Table structure for bookings
-- ----------------------------
DROP TABLE IF EXISTS `bookings`;
CREATE TABLE `bookings`  (
  `intBookingID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intPlanID` int(11) NULL DEFAULT NULL,
  `intModuleID` int(11) NULL DEFAULT NULL,
  `dteStartDate` date NULL DEFAULT NULL,
  `dteEndDate` date NULL DEFAULT NULL,
  `strRecurring` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strStatus` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intBookingID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intPlanID`(`intPlanID`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_cb_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cb_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cb_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `intNotificationID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intUserID` int(11) NULL DEFAULT NULL,
  `dtmCreated` datetime NULL DEFAULT NULL,
  `strTitleVar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescrVar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strLink` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strLinkTextVar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dtmRead` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intNotificationID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_noti_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


UPDATE system_translations
SET strStringDE = 'Diesen Benutzer als Superadmin festlegen'
WHERE intSystTransID = 180;

UPDATE system_translations
SET strStringDE = 'Wenn Sie downgraden, wird der neue Plan erst nach Ablauf des aktuellen Plans aktiviert. Der Plan wird aktiviert am:',
    strStringEN = 'If you downgrade, the new plan will only be activated after the current plan expires. The plan will be activated on:'
WHERE intSystTransID = 235;

UPDATE system_translations
SET strStringDE = 'Möchten Sie auf den gewählten Plan upgraden?',
    strStringEN = 'Would you like to upgrade to the selected plan?'
WHERE intSystTransID = 242;

UPDATE system_translations
SET strStringDE = 'Ihr Plan',
    strStringEN = 'Your Plan'
WHERE intSystTransID = 189;

UPDATE system_translations
SET strStringDE = 'Sehen Sie Ihre Rechnungen ein und/oder bezahlen Sie sie',
    strStringEN = 'View and/or pay your invoices'
WHERE intSystTransID = 164;

DELETE FROM system_translations WHERE intSystTransID = 244;

ALTER TABLE `notifications` DROP FOREIGN KEY `frn_noti_user`;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titPlans', 'Pläne', 'Plans');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titEditPlan', 'Bearbeiten Sie Ihren Plan', 'Edit your plan');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titBillingCycle', 'Abrechnungszeitraum', 'Billing cycle');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titOrderSummary', 'Zusammenfassung der Bestellung', 'Order summary');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtUpdatePlan', 'Bearbeiten Sie Ihren aktuellen Plan', 'Edit your current plan');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtNewPlanName', 'Neuer Plan', 'New plan');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtActivationOn', 'Aktivierung am', 'Activation on');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titYourCurrentPlan', 'Ihr aktueller Plan', 'Your current plan');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titCycle', 'Zyklus', 'Cycle');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titPlan', 'Plan', 'Plan');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titCycleChange', 'Zykluswechsel', 'Cycle change');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titPaymentSettings', 'Zahlungseinstellungen', 'Payment settings');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtPaymentSettings', 'Bearbeiten Sie Ihre Zahlungseinstellungen', 'Edit your payment settings');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtNoPaymentMethod', 'Sie haben noch keine Zahlungsart erfasst.', 'You have not added a payment method yet.');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnAddPaymentMethod', 'Zahlungsart erfassen', 'Add payment method');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnRemovePaymentMethod', 'Zahlungsart entfernen', 'Remove payment method');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgNeedOnePaymentType', 'Sie benötigen mindestens eine Zahlungsart. Erfassen Sie eine andere Zahlungsart, wenn Sie diese löschen möchten.', 'You need at least one payment method. Add another payment method if you want to delete it.');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgPaymentMethodDeleted', 'Die Zahlungsart wurde erfolgreich gelöscht', 'The payment method has been deleted successfully');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgWeDoNotCharge', 'Bitte beachten Sie, dass beim Hinzufügen einer neuen Zahlungsart der Betrag von 1.- in Ihrer Währung angezeigt wird. Dies dient lediglich zur Validierung Ihrer Zahlungsart und wird NICHT belastet.', 'Please note that when you add a new payment method, the amount of 1.- will be displayed in your currency. This is only to validate your payment method and will NOT be charged.');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgPaymentMethodAdded', 'Die neue Zahlungsart wurde erfolgreich erfasst.', 'The new payment method has been added successfully.');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgRemovePaymentMethod', 'Möchten Sie diese Zahlungsart wirklich entfernen?', 'Do you really want to remove this payment method?');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgCannotCharge', 'Leider konnten wir die von Ihnen hinterlegte Standard-Zahlungsart nicht abbuchen. Bitte erfassen Sie eine neue Zahlungsart und entfernen Sie die nicht funktionierende Zahlungsart.', 'Unfortunately, we were unable to charge the default payment method you registered. Please enter a new payment method and remove the one that does not work.');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titChargingNotPossible', 'Belastung nicht möglich', 'Charging not possible');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtChargingNotPossible', 'Leider konnten wir eine Ihrer registrierten Zahlungsart nicht belasten. Bitte prüfen Sie die Zahlungsarten.', 'Unfortunately, we were unable to debit one of your registered payment methods. Please check the payment methods.');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titModule', 'Modul', 'Module');

SET FOREIGN_KEY_CHECKS = 1;