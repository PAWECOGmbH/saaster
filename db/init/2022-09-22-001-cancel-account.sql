SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titCompanyUser', 'Firma und Benutzer', 'Company and user');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titSystemSettings', 'System Einstellungen', 'System settings');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtSystemSettings', 'Bearbeiten Sie die Einstellungen der Software nach Ihren Wünschen oder löschen Sie Ihren Account.', 'Edit the settings of the software according to your wishes or delete your account.');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titDeleteAccount', 'Konto löschen', 'Delete account');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtDeleteAccount', 'Bitte bedenken Sie, dass beim Löschen des Kontos Ihre Daten per sofort gelöscht werden. Allfälliges Guthaben wird NICHT erstattet! Sind Sie sicher, dass Sie Ihren Account unwiederruflich löschen möchten? Wenn ja, geben Sie bitte Ihre Login-Daten ein und klicken Sie auf "Definitiv löschen".', 'Please note that when you delete your account, your data will be deleted immediately. Any credit balance will NOT be refunded! Are you sure you want to delete your account irrevocably? If so, please enter your login data and click on "Delete definitely".');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('btnDeleteDefinitely', 'Definitiv löschen', 'Delete definitely');



INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ('account-settings/settings', 'views/customer/settings.cfm', 1, 0, 0);

SET FOREIGN_KEY_CHECKS = 1;