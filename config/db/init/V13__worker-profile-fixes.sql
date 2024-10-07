DROP TABLE IF EXISTS `ss_applications`;
CREATE TABLE `ss_applications`  (
  `intApplicationID` int(11) NOT NULL AUTO_INCREMENT,
  `intUserID` int(11) NOT NULL,
  `intAdID` int(11) NOT NULL,
  `dtmApplieted` datetime NULL DEFAULT NULL,
  `blnDone` tinyint(4) NOT NULL DEFAULT 0,
  `strAppLetter` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`intApplicationID`) USING BTREE,
  INDEX `_intAdID`(`intAdID`) USING BTREE,
  INDEX `_blnDone`(`blnDone`) USING BTREE,
  INDEX `_intUserID`(`intUserID`) USING BTREE,
  CONSTRAINT `frn_app_ads` FOREIGN KEY (`intAdID`) REFERENCES `ss_ads` (`intAdID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_app_users` FOREIGN KEY (`intUserID`) REFERENCES `users` (`intUserID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

