
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `widgets_plans`;
CREATE TABLE `widgets_plans`  (
  `intWidgetPlanID` int(11) NOT NULL AUTO_INCREMENT,
  `intWidgetID` int(11) NOT NULL,
  `intPlanID` int(11) NOT NULL,
  CONSTRAINT `frn_wp_widgets` FOREIGN KEY (`intWidgetID`) REFERENCES `widgets` (`intWidgetID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_wp_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  PRIMARY KEY (`intWidgetPlanID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `widgets_modules`;
CREATE TABLE `widgets_modules`  (
  `intWidgetModuleID` int(11) NOT NULL AUTO_INCREMENT,
  `intWidgetID` int(11) NOT NULL,
  `intModuleID` int(11) NOT NULL,
  CONSTRAINT `frn_wm_widgets` FOREIGN KEY (`intWidgetID`) REFERENCES `widgets` (`intWidgetID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_wm_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  PRIMARY KEY (`intWidgetModuleID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


DROP TABLE IF EXISTS customer_bookings;

ALTER TABLE `widgets`
ADD COLUMN `blnPermDisplay` tinyint(1) NULL DEFAULT 1 AFTER `intRatioID`;


SET FOREIGN_KEY_CHECKS = 1;