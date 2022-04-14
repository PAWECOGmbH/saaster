
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for currencies
-- ----------------------------
DROP TABLE IF EXISTS `currencies`;
CREATE TABLE `currencies`  (
  `intCurrencyID` int(11) NOT NULL AUTO_INCREMENT,
  `strCurrencyISO` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strCurrencyEN` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strCurrency` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strCurrencySign` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intPrio` int(11) NOT NULL,
  `blnDefault` tinyint(1) NOT NULL DEFAULT 0,
  `blnActive` tinyint(1) NOT NULL DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCurrencyID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of currencies
-- ----------------------------
INSERT INTO `currencies` VALUES (1, 'USD', 'US Dollar', 'US Dollar', '$', 1, 1, 1, now());
INSERT INTO `currencies` VALUES (2, 'EUR', 'Euro', 'Euro', 'EUR', 2, 0, 1, now());
INSERT INTO `currencies` VALUES (3, 'CHF', 'Swiss Francs', 'Schweizer Franken', 'CHF', 3, 0, 0, now());
INSERT INTO `currencies` VALUES (4, 'GBP', 'Pound sterling', 'Pound sterling', '£', 4, 0, 0, now());

SET FOREIGN_KEY_CHECKS = 1;