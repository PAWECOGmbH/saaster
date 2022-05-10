
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `modules_prices`
ADD COLUMN `decPriceOneTime` decimal(10, 2) NULL AFTER `decPriceYearly`;

SET FOREIGN_KEY_CHECKS = 1;