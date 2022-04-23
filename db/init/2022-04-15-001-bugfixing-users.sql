SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;


INSERT INTO `system_translations` VALUES (180, 'titSuperAdmin', 'Superadmin', 'Superadmin', now());
INSERT INTO `system_translations` VALUES (181, 'txtSetUserAsSuperAdmin', 'Dieses Benutzer als Superadmin festlegen', 'Set this user as Superadmin', now());
INSERT INTO `system_translations` VALUES (182, 'msgMaxUsersReached', 'Sie haben die maximal zulässige Anzahl Benutzer mit Ihrem gebuchten Plan erreicht. Bitte führen Sie ein Upgrade durch.', 'You have reached the maximum number of users allowed with your booked plan. Please upgrade.', now());
INSERT INTO `system_translations` VALUES (183, 'titPayment', 'Zahlung', 'Payment', now());
INSERT INTO `system_translations` VALUES (184, 'txtMonthlyPayment', 'Bei monatlicher Zahlung', 'On monthly payment', now());
INSERT INTO `system_translations` VALUES (185, 'txtYearlyPayment', 'Bei jährlicher Zahlung', 'On annual payment', now());


INSERT INTO `system_mappings` VALUES (62, 'sysadmin/system-settings', 'views/sysadmin/system_settings.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (63, 'book', 'frontend/book.cfm', 0, 0, 0, now());



UPDATE system_mappings SET blnOnlyAdmin = 0 WHERE intSystemMappingID = 33;



DROP TRIGGER `insertSettings`;
DROP TRIGGER `deleteSettings`;

DROP TABLE `system_settings_trans`;
DROP TABLE `customer_system_settings`;

ALTER TABLE `invoices`
DROP FOREIGN KEY `frn_inv_invstat`;
ALTER TABLE `invoices`
ADD CONSTRAINT `frn_inv_invstat` FOREIGN KEY (`intPaymentStatusID`) REFERENCES `invoice_status` (`intPaymentStatusID`) ON DELETE RESTRICT ON UPDATE NO ACTION;

ALTER TABLE `customer_plans`
MODIFY COLUMN `intCustomerPlanID` int(11) NOT NULL AUTO_INCREMENT FIRST,
ADD COLUMN `dtmEndTestDate` date NULL AFTER `dtmEndDate`,
MODIFY COLUMN `dtmEndDate` date NULL,
MODIFY COLUMN `dtmStartDate` date NULL;

ALTER TABLE `plans`
ADD COLUMN `blnFree` tinyint(1) NULL DEFAULT 0 AFTER `intNumTestDays`;

ALTER TABLE `currencies`
ADD COLUMN `strCurrencySign` varchar(20) NULL AFTER `strCurrency`;


SET FOREIGN_KEY_CHECKS = 1;