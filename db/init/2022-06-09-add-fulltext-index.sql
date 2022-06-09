SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `customers` 
ADD FULLTEXT INDEX `FulltextStrings`(`strCompanyName`, `strContactPerson`, `strAddress`, `strZIP`, `strCity`);