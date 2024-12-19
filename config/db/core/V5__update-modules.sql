
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `modules`
ADD COLUMN `strRedirectPath` varchar(255) NULL AFTER `blnFree`;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES
('txt404Text', 'Die angeforderte Seite wurde leider nicht gefunden!', 'The requested page could not be found!');


SET FOREIGN_KEY_CHECKS = 1;