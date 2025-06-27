SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
VALUES
('settingMailNewRegistrations', '1', 'Would you like to be notified about new registrations by email?');

SET FOREIGN_KEY_CHECKS = 1;