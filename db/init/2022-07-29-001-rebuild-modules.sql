
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `custom_mappings`
ADD COLUMN `intModuleID` int(11) NULL AFTER `blnOnlySysAdmin`;

ALTER TABLE `custom_mappings`
ADD INDEX `_intModuleID`(`intModuleID`) USING BTREE,
ADD CONSTRAINT `frn_cm_modules` FOREIGN KEY (`intModuleID`) REFERENCES `database`.`modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION;


SET FOREIGN_KEY_CHECKS = 1;