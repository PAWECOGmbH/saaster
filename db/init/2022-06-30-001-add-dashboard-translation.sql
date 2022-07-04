SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('bnEditDashboard', 'Dashboard bearbeiten', 'Edit dashboard');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('bnEndEditDashboard', 'Fertig', 'Finished');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtWidgetVisible', 'Sichtbar im Dashboard', 'Visible in dashboard');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtWidgetHidden', 'Unsichtbar im Dashboard', 'Hidden in dashboard');

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ('dashboard-settings', 'handler/dashboard.cfm', 0, 0, 0);

SET FOREIGN_KEY_CHECKS = 1;