SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `frontend_mappings`;
CREATE TABLE `frontend_mappings` (
  `intFrontendMappingsID` int(11) AUTO_INCREMENT,
  `strMapping` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `strPath` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `strMetatitle` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `strMetadescription` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `strhtmlcodes` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`intFrontendMappingsID`) USING BTREE,
  UNIQUE INDEX `_strMapping`(`strMapping`(255)) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 81 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;