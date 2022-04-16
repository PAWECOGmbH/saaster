SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;


INSERT INTO `system_translations` VALUES (180, 'titSuperAdmin', 'Superadmin', 'Superadmin', now());
INSERT INTO `system_translations` VALUES (181, 'txtSetUserAsSuperAdmin', 'Dieses Benutzer als Superadmin festlegen', 'Set this user as Superadmin', now());


INSERT INTO `system_mappings` VALUES (62, 'sysadmin/system-settings', 'views/sysadmin/system_settings.cfm', 0, 0, 1, now());



UPDATE system_mappings SET blnOnlyAdmin = 0 WHERE intSystemMappingID = 33;



DROP TRIGGER `insertSettings`;
DROP TRIGGER `deleteSettings`;

DROP TABLE `system_settings_trans`;
DROP TABLE `customer_system_settings`;


ALTER TABLE `invoices` DROP FOREIGN KEY `frn_inv_invstat`;
ALTER TABLE `invoices`
ADD CONSTRAINT `frn_inv_invstat` FOREIGN KEY (`intPaymentStatusID`) REFERENCES `invoice_status` (`intPaymentStatusID`) ON DELETE RESTRICT ON UPDATE NO ACTION;




SET FOREIGN_KEY_CHECKS = 1;