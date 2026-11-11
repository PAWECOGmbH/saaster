SET NAMES utf8mb4;

INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingTenantsEnabled', '1', 'Allow customers to create additional tenants'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingTenantsEnabled'
);
