SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO `system_mappings` (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ("sysadmin/customers","views/sysadmin/customers.cfm",0,0,1);

INSERT INTO `system_mappings` (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ("sysadm/customers","handler/sysadmin/customers.cfm",0,0,1);

INSERT INTO `system_mappings` (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ("sysadmin/customers/edit","views/sysadmin/customers_edit.cfm",0,0,1);

INSERT INTO `system_mappings` (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ("sysadmin/customers/details","views/sysadmin/customers_details.cfm",0,0,1);