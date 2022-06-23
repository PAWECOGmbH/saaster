SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `countries` 
ADD FULLTEXT INDEX `FulltextStrings`(`strCountryName`, `strLocale`, `strISO1`, `strISO2`, `strCurrency`, `strRegion`, `strSubRegion`);