SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO `system_settings` (strSettingVariable, strDefaultValue, strDescription)
VALUES ('settingColorPrimary', '#206bc4', 'Choose a primary color:'),
('settingColorSecondary', '#626976', 'Choose a secondary color:');

SET FOREIGN_KEY_CHECKS = 1;