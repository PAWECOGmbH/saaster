
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `invoices`
ADD COLUMN `strUUID` varchar(100) NULL AFTER `intBookingID`;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titInvoiceReady', 'Ihre Rechnung/Quittung steht zum Download bereit', 'Your invoice/receipt is ready to download');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtDownloadInvoice', 'Mit dem folgendem Button können Sie Ihre Rechnung/Quittung einsehen und downloaden:', 'With the following button you can view and download your invoice/receipt:');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnDownloadInvoice', 'Rechnung downloaden', 'Download invoice');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtPleasePayInvoice', 'Vielen Dank für Ihre Bestellung. Gerne schalten wir Ihr Produkt nach Zahlung der Rechnung frei. Klicken Sie auf den Button, um direkt zur Rechnung zu gelangen (Login benötigt):', 'Thank you for your order. We will be happy to activate your product after payment of the invoice. Click on the button to go directly to the invoice (login required):');


SET FOREIGN_KEY_CHECKS = 1;