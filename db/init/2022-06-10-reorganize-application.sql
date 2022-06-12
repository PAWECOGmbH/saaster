

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of config
-- ----------------------------
INSERT INTO `config` VALUES ('applicationname', 'saaster.io', 'The name of your application.cfc');
INSERT INTO `config` VALUES ('sessiontimeout', 'createTimespan(00,03,00,00)', 'Please use the timespan tag directly');
INSERT INTO `config` VALUES ('pdf_type', 'classic', 'You can use \"modern\" or \"classic\"');
INSERT INTO `config` VALUES ('requesttimeout', '60', 'RequestTimeout in seconds');
INSERT INTO `config` VALUES ('appName', 'SaaSTER', 'Here you can choose any name');
INSERT INTO `config` VALUES ('appOwner', 'The SaaSTER Company ltd.', 'Enter the name of the operator (Your company)');
INSERT INTO `config` VALUES ('fromEmail', 'SaaSTER Company <info@saaster.io>', 'From which e-mail address should the system e-mails be sent?');
INSERT INTO `config` VALUES ('toEmail', 'info@saaster.io', 'Enter the email address of the administrator');
INSERT INTO `config` VALUES ('mainURL', 'http://localhost', 'Enter the URL of your project (incl. http:// or https://)');
INSERT INTO `config` VALUES ('usersIP', '62.171.127.255', 'If you are setting up the project for the local environment, enter any public IP address. If it is a live application, please enter \"live\".');
INSERT INTO `config` VALUES ('userTempImg', 'http://www.clker.com/cliparts/A/Y/O/m/o/N/placeholder-md.png', 'This is a placeholder for the user image. Please only enter an absolute path that can be called up online.');

SET FOREIGN_KEY_CHECKS = 1;
