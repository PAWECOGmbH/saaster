SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `invoices`
ADD COLUMN `intUserID` int(11) NULL DEFAULT NULL AFTER `intCustomerID`;

ALTER TABLE `payments`
DROP COLUMN `strCurrency`,
DROP COLUMN `intCustomerID`,
MODIFY COLUMN `dtmPayDate` datetime NOT NULL,
ADD COLUMN `strPaymentType` varchar(50) NULL AFTER `dtmPayDate`;


CREATE TRIGGER `updPaymStatInsert` AFTER INSERT ON `payments` FOR EACH ROW UPDATE invoices
SET intPaymentStatusID = IF(NEW.decAmount >= decTotalPrice, 3, 4)
WHERE intInvoiceID = NEW.intInvoiceID;



-- ----------------------------
-- Records of system_settings
-- ----------------------------
INSERT INTO `system_settings` VALUES (3, 'settingStandardVatType', '1', 'Which vat type should be set by default?', now());
INSERT INTO `system_settings` VALUES (4, 'settingInvoicePrefix', 'INV-', 'Invoices can be preceded by a short prefix. Enter it here.', now());
INSERT INTO `system_settings` VALUES (5, 'settingInvoiceNet', '1', 'Decide whether the invoices are issued "net" by default.', now());

-- ----------------------------
-- Records of system_mappings
-- ----------------------------
INSERT INTO `system_mappings` VALUES (59, 'sysadmin/invoices', 'views/sysadmin/invoices.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (60, 'sysadm/invoices', 'handler/sysadmin/invoices.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (61, 'sysadmin/invoice/edit', 'views/sysadmin/invoice_edit.cfm', 0, 0, 1, now());

-- ----------------------------
-- Records of system_translations
-- ----------------------------
INSERT INTO `system_translations` VALUES (178, 'statInvoiceDraft', 'Entwurf', 'Draft', now());
INSERT INTO `system_translations` VALUES (179, 'statInvoiceOverDue', 'Überfällig', 'Overdue', now());


-- ----------------------------
-- Records of invoice_status
-- ----------------------------
DELETE FROM invoice_status;
INSERT INTO `invoice_status` VALUES (1, 'statInvoiceDraft', 'muted');
INSERT INTO `invoice_status` VALUES (2, 'statInvoiceOpen', 'blue');
INSERT INTO `invoice_status` VALUES (3, 'statInvoicePaid', 'green');
INSERT INTO `invoice_status` VALUES (4, 'statInvoicePartPaid', 'orange');
INSERT INTO `invoice_status` VALUES (5, 'statInvoiceCanceled', 'purple');
INSERT INTO `invoice_status` VALUES (6, 'statInvoiceOverDue', 'red');








SET FOREIGN_KEY_CHECKS = 1;