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
) ENGINE = InnoDB AUTO_INCREMENT = 81 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 81 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;