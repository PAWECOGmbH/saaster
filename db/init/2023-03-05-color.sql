SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO `system_settings` (strSettingVariable, strDefaultValue, strDescription)
VALUES ('settingColorPrimary', '#000000', 'Choose a primary color:'),
('settingColorSecondary', '#000000', 'Choose a secondary color:');

SET FOREIGN_KEY_CHECKS = 1;