SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `database`.`optin` 
ADD COLUMN `strLanguage` varchar(2) NULL AFTER `strEmail`;