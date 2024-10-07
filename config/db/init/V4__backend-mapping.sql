
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO `custom_mappings` (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin, intModuleID)
VALUES ('employer/applications', 'backend/myapp/views/employer/applications.cfm', 0, 0, 0, NULL);

INSERT INTO `custom_mappings` (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin, intModuleID)
VALUES ('employer/app-detail', 'backend/myapp/views/employer/app_detail.cfm', 0, 0, 0, NULL);

ALTER TABLE `ss_applications` DROP COLUMN `blnOpen`;

SET FOREIGN_KEY_CHECKS = 1;