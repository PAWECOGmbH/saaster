SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES
('sysadmin/mapping/edit', 'backend/core/views/sysadmin/mapping_edit.cfm', 0, 0, 1);

SET FOREIGN_KEY_CHECKS = 1;