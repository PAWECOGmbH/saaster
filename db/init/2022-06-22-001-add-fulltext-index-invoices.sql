SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `invoices` 
ADD FULLTEXT INDEX `FulltextStrings`(`strInvoiceTitle`, `strCurrency`);