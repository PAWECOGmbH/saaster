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
  `blnPermDisplay` tinyint(1) NULL DEFAULT 1,
  PRIMARY KEY (`intWidgetID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of widgets
-- ----------------------------
INSERT INTO `widgets` VALUES (1, 'Last Login', 'widgets/welcome.cfm', 1, 3, 1);
INSERT INTO `widgets` VALUES (2, 'Sales', 'widgets/sales.cfm', 1, 3, 1);
INSERT INTO `widgets` VALUES (3, 'Revenue', 'widgets/revenue.cfm', 1, 4, 1);
INSERT INTO `widgets` VALUES (4, 'New clients', 'widgets/new-clients.cfm', 1, 4, 1);
INSERT INTO `widgets` VALUES (5, 'Active users', 'widgets/active-users.cfm', 1, 4, 1);


SET FOREIGN_KEY_CHECKS = 1;