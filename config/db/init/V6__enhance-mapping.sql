SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `frontend_mappings`
ADD COLUMN `blnCreatedByApp` tinyint(1) NOT NULL DEFAULT 0 AFTER `strhtmlcodes`;

ALTER TABLE `frontend_mappings_trans`
ADD UNIQUE INDEX `_intFrontendMappingsID`(`intFrontendMappingsID`) USING BTREE,
ADD CONSTRAINT `frn_fm_trans_fm` FOREIGN KEY (`intFrontendMappingsID`) REFERENCES `frontend_mappings` (`intFrontendMappingsID`) ON DELETE CASCADE ON UPDATE NO ACTION;

SET FOREIGN_KEY_CHECKS = 1;