
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IS EXISTS customer_bookings_history;

ALTER TABLE `invoices`
CHANGE COLUMN `intCustomerBookingID` `intBookingID` int(11) NULL DEFAULT 0 AFTER `strLanguageISO`;

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ('account-settings/plans', 'views/customer/plans.cfm', 0, 1, 0);

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ('plan-settings', 'handler/plans.cfm', 0, 1, 0);


-- ----------------------------
-- Table structure for customer_bookings
-- ----------------------------
DROP TABLE IF EXISTS `customer_bookings`;
CREATE TABLE `customer_bookings`  (
  `intBookingID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intPlanID` int(11) NULL DEFAULT NULL,
  `intModuleID` int(11) NULL DEFAULT NULL,
  `dteStartDate` date NULL DEFAULT NULL,
  `dteEndDate` date NULL DEFAULT NULL,
  `dteEndTestDate` date NULL DEFAULT NULL,
  `strRecurring` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intBookingID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intPlanID`(`intPlanID`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_cb_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cb_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cb_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


UPDATE system_translations
SET strStringDE = 'Diesen Benutzer als Superadmin festlegen'
WHERE intSysteTransID = 180;


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



SET FOREIGN_KEY_CHECKS = 1;