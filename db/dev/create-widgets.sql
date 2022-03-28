SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for widgets
-- ----------------------------
DROP TABLE IF EXISTS `widgets`;
CREATE TABLE `widgets`  (
  `intWidgetID` int(11) NOT NULL AUTO_INCREMENT,
  `strWidgetName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strFilePath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 1,
  `intRatioID` int(2) NULL DEFAULT 1,
  PRIMARY KEY (`intWidgetID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of widgets
-- ----------------------------
INSERT INTO `widgets` VALUES (1, 'Test widget 1', 'modules/sales.cfm', 1, 3);
INSERT INTO `widgets` VALUES (2, 'Test widget 2', 'modules/sales.cfm', 1, 3);

SET FOREIGN_KEY_CHECKS = 1;