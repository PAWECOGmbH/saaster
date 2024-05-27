SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `frontend_mappings`;
CREATE TABLE `frontend_mappings` (
  `intFrontendMappingsID` int(11) AUTO_INCREMENT,
  `strMapping` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `strPath` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `strMetatitle` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `strMetadescription` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `strhtmlcodes` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`intFrontendMappingsID`) USING BTREE,
  UNIQUE INDEX `_strMapping`(`strMapping`(255)) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

DROP TABLE IF EXISTS `frontend_mappings_trans`;
CREATE TABLE `frontend_mappings_trans` (
  `intfrontend_mappings_transID` int(11) AUTO_INCREMENT,
  `intFrontendMappingsID` int(11),
  `strMapping` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `strPath` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `strMetatitle` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `strMetadescription` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `strhtmlcodes` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `intLanguageID` int(11),
  PRIMARY KEY (`intfrontend_mappings_transID`) USING BTREE,
  UNIQUE INDEX `_strMapping`(`strMapping`(255)) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

DELETE FROM system_mappings
WHERE intSystemMappingID = 1
OR intSystemMappingID = 2
OR intSystemMappingID = 3
OR intSystemMappingID = 58
OR intSystemMappingID = 78;

INSERT INTO `frontend_mappings` VALUES (1, 'login', 'frontend/login.cfm', '', '', '');
INSERT INTO `frontend_mappings` VALUES (2, 'register', 'frontend/register.cfm', '', '', '');
INSERT INTO `frontend_mappings` VALUES (3, 'password', 'frontend/password.cfm', '', '', '');
INSERT INTO `frontend_mappings` VALUES (4, 'plans', 'frontend/plans.cfm', '', '', '');
INSERT INTO `frontend_mappings` VALUES (5, 'mfa', 'frontend/mfa.cfm', '', '', '');



SET FOREIGN_KEY_CHECKS = 1;