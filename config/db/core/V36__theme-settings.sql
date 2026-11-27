SET NAMES utf8mb4;

-- Primary color: a Tabler color or the custom color in settingColorPrimary.
-- Installations that changed the original default color keep it as custom color.
INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingThemePrimary',
    IF(
        EXISTS (
            SELECT 1 FROM system_settings
            WHERE strSettingVariable = 'settingColorPrimary'
            AND LOWER(TRIM(COALESCE(strDefaultValue, ''))) NOT IN ('', '#206bc4')
        ),
        'custom',
        'blue'
    ),
    'Primary color (Tabler color or custom color)'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingThemePrimary'
);

INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingColorPrimary', '#206bc4', 'Custom primary color'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingColorPrimary'
);

UPDATE system_settings
SET strDescription = 'Custom primary color'
WHERE strSettingVariable = 'settingColorPrimary';

INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingThemeNavbar', 'default', 'Navigation color'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingThemeNavbar'
);

INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingThemeBase', 'neutral', 'Gray tone'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingThemeBase'
);

INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingThemeRadius', '1', 'Corner radius'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingThemeRadius'
);

INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingThemeFont', 'sans-serif', 'Font'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingThemeFont'
);

-- The secondary color is no longer used; Tabler keeps its own gray secondary color.
DELETE FROM system_settings
WHERE strSettingVariable = 'settingColorSecondary';
