
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;


-- ----------------------------
-- Table structure for modules
-- ----------------------------
DROP TABLE IF EXISTS `modules`;
CREATE TABLE `modules`  (
  `intModuleID` int(11) NOT NULL AUTO_INCREMENT,
  `strModuleName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strShortDescription` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `blnActive` tinyint(1) NOT NULL,
  `strTabPrefix` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPicture` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnBookable` tinyint(1) NOT NULL,
  `intNumTestDays` int(11) NOT NULL,
  `strSettingPath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intPrio` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intModuleID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of modules
-- ----------------------------
INSERT INTO `modules` VALUES (1, 'Free Todo list app', 'Let your tasks be done', '<p>With this small but powerful tool for task management, you always have all your tasks under control. Simply click on \"Activate\" and get started :-)<br></p>', 1, 'todo_', '', 0, 0, 1, '2022-03-28 14:54:17');
INSERT INTO `modules` VALUES (2, 'Easy ERP', 'Manage your contacts using Easy CRM', '<p>Manage your contacts easily with Easy ERP. Many features are included here, such as:<br><br>- Create and manage contacts<br>- Customer history<br>- Acquisition<br>- Appointment management<br>- and much more...<br></p>', 1, 'easy-erp_', '', 1, 30, 2, '2022-03-28 15:19:23');

-- ----------------------------
-- Table structure for modules_prices
-- ----------------------------
DROP TABLE IF EXISTS `modules_prices`;
CREATE TABLE `modules_prices`  (
  `intModulePriceID` int(11) NOT NULL AUTO_INCREMENT,
  `intModuleID` int(11) NOT NULL,
  `intCurrencyID` int(11) NOT NULL,
  `decPriceMonthly` decimal(10, 2) NULL DEFAULT NULL,
  `decPriceYearly` decimal(10, 2) NULL DEFAULT NULL,
  `decPriceOneTime` decimal(10, 2) NULL DEFAULT NULL,
  `decVat` decimal(10, 2) NULL DEFAULT NULL,
  `blnIsNet` tinyint(1) NOT NULL DEFAULT 1,
  `intVatType` int(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`intModulePriceID`) USING BTREE,
  INDEX `_intCurrencyID`(`intCurrencyID`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_mp_currencies` FOREIGN KEY (`intCurrencyID`) REFERENCES `currencies` (`intCurrencyID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_mp_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of modules_prices
-- ----------------------------
INSERT INTO `modules_prices` VALUES (1, 1, 1, 0.00, 0.00, 0.00, 0.00, 0, 3);
INSERT INTO `modules_prices` VALUES (2, 1, 2, 0.00, 0.00, 0.00, 0.00, 0, 3);
INSERT INTO `modules_prices` VALUES (3, 2, 1, 29.00, 290.00, 0.00, 7.70, 1, 1);
INSERT INTO `modules_prices` VALUES (4, 2, 2, 35.00, 350.00, 0.00, 7.70, 1, 1);

-- ----------------------------
-- Table structure for modules_trans
-- ----------------------------
DROP TABLE IF EXISTS `modules_trans`;
CREATE TABLE `modules_trans`  (
  `intModulTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intModuleID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strModuleName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strShortDescription` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intModulTransID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_modules_trans` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_mt_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of modules_trans
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
