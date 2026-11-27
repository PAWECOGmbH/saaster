SET NAMES utf8mb4;

-- Optional accent colors (corporate design): none, a Tabler color or a custom color.
INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingThemeAccent', 'none', 'Accent color (none, Tabler color or custom color)'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingThemeAccent'
);

INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingColorAccent', '#f76707', 'Custom accent color'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingColorAccent'
);

INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingThemeAccent2', 'none', 'Second accent color (none, Tabler color or custom color)'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingThemeAccent2'
);

INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingColorAccent2', '#0ca678', 'Custom second accent color'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingColorAccent2'
);
