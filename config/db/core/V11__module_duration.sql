SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `modules_prices`
    ADD COLUMN `intDurationDays` int NOT NULL DEFAULT 0 AFTER `intVatType`;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtDurationDays', 'Laufzeit (Tage)', 'Runtime days');

SET FOREIGN_KEY_CHECKS = 1;
