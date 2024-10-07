SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `ss_ads`
ADD COLUMN `intMappingID` int NULL AFTER `intInvoiceID`,
ADD INDEX `_intMappingID`(`intMappingID`) USING BTREE,
ADD CONSTRAINT `frn_ads_mappings` FOREIGN KEY (`intMappingID`)
REFERENCES `frontend_mappings` (`intFrontendMappingsID`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `ss_company`
DROP COLUMN `strURLSlug`,
ADD COLUMN `intMappingID` int NULL AFTER `strCompanyDescription`;

SET FOREIGN_KEY_CHECKS = 1;