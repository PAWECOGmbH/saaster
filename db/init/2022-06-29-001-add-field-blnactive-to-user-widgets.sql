SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `database`.`user_widgets` 
ADD COLUMN `blnActive` tinyint(1) NULL AFTER `intPrio`;

SET FOREIGN_KEY_CHECKS = 1;