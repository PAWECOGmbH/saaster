SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for system_mappings
-- ----------------------------
DROP TABLE IF EXISTS `system_mappings`;
CREATE TABLE `system_mappings`  (
  `intSystemMappingID` int(11) NOT NULL AUTO_INCREMENT,
  `strMapping` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strPath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `blnOnlyAdmin` tinyint(1) NOT NULL DEFAULT 0,
  `blnOnlySuperAdmin` tinyint(1) NOT NULL DEFAULT 0,
  `blnOnlySysAdmin` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intSystemMappingID`) USING BTREE,
  UNIQUE INDEX `_strMapping`(`strMapping`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 81 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_mappings
-- ----------------------------
INSERT INTO `system_mappings` VALUES (1, 'login', 'frontend/login.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (2, 'register', 'frontend/register.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (3, 'password', 'frontend/password.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (4, 'dashboard', 'backend/core/views/dashboard.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (5, 'account-settings/my-profile', 'backend/core/views/customer/my-profile.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (6, 'customer', 'backend/core/handler/customer.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (7, 'global', 'backend/core/handler/global.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (9, 'logincheck', 'frontend/core/handler/register.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (12, 'account-settings', 'backend/core/views/customer/account-settings.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (13, 'account-settings/company', 'backend/core/views/customer/company-edit.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (14, 'account-settings/tenants', 'backend/core/views/customer/tenants.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (15, 'account-settings/users', 'backend/core/views/customer/users.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (17, 'account-settings/reset-password', 'backend/core/views/customer/reset-password.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (19, 'account-settings/user/new', 'backend/core/views/customer/user_new.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (20, 'account-settings/user/edit', 'backend/core/views/customer/user_edit.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (21, 'account-settings/tenant/new', 'backend/core/views/customer/tenant_new.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (23, 'account-settings/invoices', 'backend/core/views/invoices/invoices.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (25, 'account-settings/invoice', 'backend/core/views/invoices/invoice.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (26, 'account-settings/modules', 'backend/core/views/customer/modules.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (27, 'invoices', 'backend/core/handler/invoices.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (29, 'sysadmin/mappings', 'backend/core/views/sysadmin/mappings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (31, 'sysadmin/translations', 'backend/core/views/sysadmin/translations.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (32, 'sysadmin/settings', 'backend/core/views/sysadmin/settings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (33, 'user', 'backend/core/handler/user.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (34, 'sysadmin/languages', 'backend/core/views/sysadmin/languages.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (36, 'sysadmin/countries', 'backend/core/views/sysadmin/countries.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (37, 'sysadmin/countries/import', 'backend/core/views/sysadmin/country_import.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (39, 'sysadmin/modules', 'backend/core/views/sysadmin/modules.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (41, 'sysadmin/modules/edit', 'backend/core/views/sysadmin/module_edit.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (42, 'sysadmin/widgets', 'backend/core/views/sysadmin/widgets.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (43, 'sysadm/mappings', 'backend/core/handler/sysadmin/mappings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (44, 'sysadm/translations', 'backend/core/handler/sysadmin/translations.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (45, 'sysadm/languages', 'backend/core/handler/sysadmin/languages.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (46, 'sysadm/settings', 'backend/core/handler/sysadmin/settings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (47, 'sysadm/countries', 'backend/core/handler/sysadmin/countries.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (48, 'sysadm/modules', 'backend/core/handler/sysadmin/modules.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (49, 'account-settings/invoice/print', 'backend/core/views/invoices/print.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (50, 'sysadm/widgets', 'backend/core/handler/sysadmin/widgets.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (51, 'sysadmin/plans', 'backend/core/views/sysadmin/plans.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (52, 'sysadmin/currencies', 'backend/core/views/sysadmin/currencies.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (53, 'sysadm/currencies', 'backend/core/handler/sysadmin/currencies.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (54, 'sysadm/plans', 'backend/core/handler/sysadmin/plans.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (55, 'sysadmin/plan/edit', 'backend/core/views/sysadmin/plan_edit.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (56, 'sysadmin/plangroups', 'backend/core/views/sysadmin/plan_groups.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (57, 'sysadmin/planfeatures', 'backend/core/views/sysadmin/plan_features.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (58, 'plans', 'frontend/plans.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (59, 'sysadmin/invoices', 'backend/core/views/sysadmin/invoices.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (60, 'sysadm/invoices', 'backend/core/handler/sysadmin/invoices.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (61, 'sysadmin/invoice/edit', 'backend/core/views/sysadmin/invoice_edit.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (62, 'sysadmin/customers', 'backend/core/views/sysadmin/customers.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (63, 'sysadm/customers', 'backend/core/handler/sysadmin/customers.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (64, 'sysadmin/customers/edit', 'backend/core/views/sysadmin/customers_edit.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (65, 'sysadmin/customers/details', 'backend/core/views/sysadmin/customers_details.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (66, 'sysadmin/system-settings', 'backend/core/views/sysadmin/system_settings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (67, 'book', 'backend/core/handler/book.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (68, 'cancel', 'backend/core/handler/cancel.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (69, 'dashboard-settings', 'backend/core/handler/dashboard.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (70, 'account-settings/plans', 'backend/core/views/customer/plans.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (71, 'plan-settings', 'backend/core/handler/plans.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (72, 'account-settings/payment', 'backend/core/views/customer/payment.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (73, 'payment-settings', 'backend/core/handler/payment.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (74, 'account-settings/settings', 'backend/core/views/customer/settings.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (75, 'notifications', 'backend/core/views/notifications/overview.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (76, 'sysadm/api-settings', 'backend/core/handler/sysadmin/api_settings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (77, 'sysadmin/api-settings', 'backend/core/views/sysadmin/api_settings.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (78, 'mfa', 'frontend/mfa.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (79, 'sysadmin/logs', 'backend/core/views/sysadmin/logs.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (80, 'sysadm/logs', 'backend/core/handler/sysadmin/logs.cfm', 0, 0, 1);

SET FOREIGN_KEY_CHECKS = 1;
