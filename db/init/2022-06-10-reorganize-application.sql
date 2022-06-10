

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for config
-- ----------------------------
DROP TABLE IF EXISTS `config`;
CREATE TABLE `config`  (
  `strVariable` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strValue` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strDescription` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of config
-- ----------------------------
INSERT INTO `config` VALUES ('applicationname', 'saaster.io', 'The name of your application.cfc');
INSERT INTO `config` VALUES ('sessiontimeout', 'createTimeSpan(00,03,00,00)', 'Plaes use createTimespan tag directly');
INSERT INTO `config` VALUES ('pdf_type', 'classic', 'You can use \"modern\" or \"classic\"');
INSERT INTO `config` VALUES ('requesttimeout', '60', 'RequestTimeout in seconds');
INSERT INTO `config` VALUES ('appName', 'SaaSTER', 'Here you can choose any name');
INSERT INTO `config` VALUES ('appOwner', 'The SaaSTER Company ltd.', 'Enter the name of the operator (Your company)');
INSERT INTO `config` VALUES ('fromEmail', 'SaaSTER Company <info@saaster.io>', 'From which e-mail address should the system e-mails be sent?');
INSERT INTO `config` VALUES ('toEmail', 'info@saaster.io', 'Enter the email address of the administrator');
INSERT INTO `config` VALUES ('mainURL', 'http://localhost', 'Enter the URL of your project (incl. http:// or https://)');
INSERT INTO `config` VALUES ('usersIP', '82.136.122.104', 'The IP of the user is assigned by the system in live operation. For local applications, you can use one of the following IPs: \r\n82.136.122.104 for Switzerland;\r\n80.136.122.10 for Germany;\r\n23.105.140.49 for USA;\r\n193.32.210.90 for UK;\r\n');
INSERT INTO `config` VALUES ('userTempImg', 'http://www.clker.com/cliparts/A/Y/O/m/o/N/placeholder-md.png', 'This is a placeholder for the user image. Please only enter an absolute path that can be called up online.');

SET FOREIGN_KEY_CHECKS = 1;
