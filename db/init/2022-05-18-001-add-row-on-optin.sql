SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `optin` 
ADD COLUMN `strLanguage` varchar(2) NULL AFTER `strEmail`;