
/* Create database for saaster.io */

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;


INSERT INTO `system_translations` ('strVariable', 'strStringDE', 'strStringEN', 'timestamp')
VALUES ('txtContact', 'Kontakt', 'Contact', now());

INSERT INTO `system_translations` ('strVariable', 'strStringDE', 'strStringEN', 'timestamp')
VALUES ('txtNetwork', 'Netzwerk', 'Network', now());