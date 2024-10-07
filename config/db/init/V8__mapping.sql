SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO `frontend_mappings` (strMapping, strPath)
VALUES ('arbeitgeber', 'frontend/company.cfm');

ALTER TABLE `ss_comapny` RENAME `ss_company`;

ALTER TABLE `ss_company`
ADD COLUMN `strURLSlug` varchar(255) NULL AFTER `strCompanyDescription`;



SET FOREIGN_KEY_CHECKS = 1;