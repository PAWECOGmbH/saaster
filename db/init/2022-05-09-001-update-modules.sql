
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
ADD COLUMN `intNumTestDays` int(11) NOT NULL AFTER `blnBookable`;










INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtOneTime', 'Einmalig', 'One time');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtUnlock', 'Freischalten', 'Unlock');


SET FOREIGN_KEY_CHECKS = 1;