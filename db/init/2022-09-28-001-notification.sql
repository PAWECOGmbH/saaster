SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ('notifications', 'views/customer/notifications.cfm', 0, 0, 0);

SET FOREIGN_KEY_CHECKS = 1;