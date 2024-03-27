SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO `system_mappings` (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES
('sysadmin/logs', 'views/sysadmin/logs.cfm', 0, 0, 1),
('sysadm/logs', 'handler/sysadmin/logs.cfm', 0, 0, 1);

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES
('titCouldNotCharge', 'Ihre Zahlungsart kann nicht abgebucht werden', 'Your payment method cannot be charged'),
('msgCouldNotCharge', 'Leider konnten wir Ihre hinterlegte Zahlungsart nicht belasten. Damit Sie Ihr Produkt weiterhin nutzen können, begleichen Sie bitte die offene Rechnung und hinterlegen Sie bitte eine funktionierende Zahlungsart. Besten Dank!', 'Unfortunately, we were unable to charge your payment method. So that you can continue to use your product, please settle the outstanding invoice and enter a functioning payment method. Thank you very much!');



SET FOREIGN_KEY_CHECKS = 1;