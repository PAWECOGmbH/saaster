
SET NAMES utf8mb4;

-- The old scheduler shards are intentionally retained until V23 runs on every installation.
-- Setting names are not unique in the schema, so check each one before inserting.
INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingInvoiceBcc', '0', 'Send a blind copy of invoice emails to the system administrator'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingInvoiceBcc'
);

INSERT INTO system_settings (strSettingVariable, strDefaultValue, strDescription)
SELECT 'settingYearlyPricePerMonth', '0', 'Display yearly plan prices per month'
WHERE NOT EXISTS (
    SELECT 1 FROM system_settings WHERE strSettingVariable = 'settingYearlyPricePerMonth'
);

-- Preserve translations that an installation has already customized.
UPDATE system_translations
SET strStringDE = 'Rechnung bezahlen'
WHERE strVariable = 'txtPayInvoice' AND strStringDE = 'Rechnug bezahlen';

INSERT IGNORE INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtBilledYearly', 'Jährliche Abrechnung', 'Billed yearly');

-- Initialize priorities only when adding the column; preserve existing widget order on reruns.
SET @v25_add_widget_prio = (
    SELECT COUNT(*) = 0 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'widgets' AND COLUMN_NAME = 'intPrio'
);
SET @v25_widget_prio_sql = IF(
    @v25_add_widget_prio,
    'ALTER TABLE widgets ADD COLUMN intPrio INT NOT NULL DEFAULT 0',
    'SELECT 1'
);
PREPARE v25_widget_prio_stmt FROM @v25_widget_prio_sql;
EXECUTE v25_widget_prio_stmt;
DEALLOCATE PREPARE v25_widget_prio_stmt;

UPDATE widgets SET intPrio = intWidgetID WHERE @v25_add_widget_prio;
