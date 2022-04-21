
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `modules_trans` DROP COLUMN `strPicture`;

ALTER TABLE `modules_trans`
MODIFY COLUMN `strModuleName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `intLanguageID`,
ADD COLUMN `strShortDescription` varchar(100) NULL AFTER `strModuleName`;

ALTER TABLE `modules_trans` DROP FOREIGN KEY `frn_modules_trans`;

ALTER TABLE `modules_trans` CHANGE COLUMN `intModulID` `intModuleID` int(11) NOT NULL AFTER `intModulTransID`,
DROP INDEX `_intModulID`, ADD INDEX `_intModuleID` (`intModuleID`) USING BTREE,
ADD CONSTRAINT `frn_modules_trans` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION;

DROP TABLE IF EXISTS `modules_prices`;
CREATE TABLE `modules_prices`  (
  `intModulePriceID` int(11) NOT NULL AUTO_INCREMENT,
  `intModuleID` int(11) NOT NULL,
  `intCurrencyID` int(11) NOT NULL,
  `decPriceMonthly` decimal(10, 2) NULL DEFAULT NULL,
  `decPriceYearly` decimal(10, 2) NULL DEFAULT NULL,
  `decVat` decimal(10, 2) NULL DEFAULT NULL,
  `blnIsNet` tinyint(1) NOT NULL DEFAULT 1,
  `intVatType` int(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`intModulePriceID`) USING BTREE,
  INDEX `_intCurrencyID`(`intCurrencyID`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_mp_currencies` FOREIGN KEY (`intCurrencyID`) REFERENCES `currencies` (`intCurrencyID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_mp_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;
