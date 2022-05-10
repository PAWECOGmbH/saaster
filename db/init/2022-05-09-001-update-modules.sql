
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `modules_prices`
ADD COLUMN `decPriceOneTime` decimal(10, 2) NULL AFTER `decPriceYearly`;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtOneTime', 'Einmalig', 'One time');

SET FOREIGN_KEY_CHECKS = 1;