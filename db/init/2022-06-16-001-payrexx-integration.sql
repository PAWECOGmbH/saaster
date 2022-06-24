SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `payments` DROP COLUMN `timestamp`;

ALTER TABLE `payments`
ADD COLUMN `intPayrexxID` int(11) NULL AFTER `strPaymentType`;

-- ----------------------------
-- Table structure for payrexx
-- ----------------------------
DROP TABLE IF EXISTS `payrexx`;
CREATE TABLE `payrexx`  (
  `intPayrexxID` int(11) NOT NULL AUTO_INCREMENT,
  `strUUID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intCustomerID` int(11) NULL DEFAULT NULL,
  `dtmTimeUTC` datetime NULL DEFAULT NULL,
  `intGatewayID` int(11) NULL DEFAULT NULL,
  `intTransactionID` int(11) NULL DEFAULT NULL,
  `blnPreAuthorization` tinyint(1) NULL DEFAULT NULL,
  `strStatus` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strLanguage` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPSP` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intPSPID` int(11) NULL DEFAULT NULL,
  `decAmount` decimal(10, 2) NULL DEFAULT NULL,
  `decPayrexxFee` decimal(10, 2) NULL DEFAULT NULL,
  `strPaymentBrand` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intPayrexxID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


SET FOREIGN_KEY_CHECKS = 1;