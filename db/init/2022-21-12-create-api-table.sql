SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `api_management`;
CREATE TABLE `api_management`  (
  `intApiID` int(11) NOT NULL AUTO_INCREMENT,
  `strApiName` varchar(100) NULL,
  `strApiKeyHash` varchar(255) NULL,
  `strApiKeySalt` varchar(255) NULL,
  `dtmValidUntil` datetime(6) NULL,
  PRIMARY KEY (`intApiID`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

DROP TABLE IF EXISTS `api_nonce`;
CREATE TABLE `api_nonce`  (
  `intNonceID` int(11) NOT NULL AUTO_INCREMENT,
  `strNonceUUID` varchar(255) NOT NULL,
  `dtmNonceCreated` datetime(6) NOT NULL,
  `intCreatedBy` int(11) NOT NULL,
  PRIMARY KEY (`intNonceID`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

INSERT INTO `system_mappings` VALUES (76, 'sysadm/api-settings', 'handler/sysadmin/api_settings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (77, 'sysadmin/api-settings', 'views/sysadmin/api_settings.cfm', 0, 0, 0);

SET FOREIGN_KEY_CHECKS = 1;