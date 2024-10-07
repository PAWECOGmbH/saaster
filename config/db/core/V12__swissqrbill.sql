SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO `system_settings` (strSettingVariable, strDefaultValue, strDescription)
VALUES
('settingSwissQrBill', '0', 'Do you want to activate the Swiss QR bill?'),
('settingIBANnumber', '', 'Your IBAN number'),
('settingQRreference', '', 'Your QR reference number');




SET FOREIGN_KEY_CHECKS = 1;