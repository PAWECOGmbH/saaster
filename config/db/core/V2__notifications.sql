SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM system_translations WHERE strVariable = 'txtNotificationStatus';
DELETE FROM system_translations WHERE strVariable = 'txtNotificationTitle';
DELETE FROM system_translations WHERE strVariable = 'txtNotificationCreated';

UPDATE system_translations SET strStringDE = 'Meldungen' WHERE strVariable = 'titNotifications';
UPDATE system_translations SET strStringDE = 'Alle Meldungen anzeigen' WHERE strVariable = 'txtShowAllNotifications';
UPDATE system_translations SET strStringDE = 'Möchten Sie diese Meldung löschen?' WHERE strVariable = 'txtNotificationDelete';
UPDATE system_translations SET strStringDE = 'Meldung löschen' WHERE strVariable = 'titDeleteNotification';
UPDATE system_translations SET strStringDE = 'Möchten Sie die ausgewählten Meldungen löschen?' WHERE strVariable = 'txtMultipleNotificationDelete';
UPDATE system_translations SET strStringDE = 'Meldungen löschen' WHERE strVariable = 'titMultipleNotificationDelete';

UPDATE system_translations
SET strStringDE = 'Meldung gelöscht.',
    strStringEN = 'Notification deleted.'
WHERE strVariable = 'alertNotificationDeleted';

UPDATE system_translations
SET strStringDE = 'Meldungen gelöscht.',
    strStringEN = 'Notifications deleted.'
WHERE strVariable = 'alertMultipleNotificationDeleted';


INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titDateTime', 'Datum/Zeit', 'Date/Time');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('msgNoNotifications', 'Keine Meldungen vorhanden.', 'No messages available.');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titNotification', 'Meldung', 'Notification');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titStatus', 'Status', 'Status');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtMarkAsRead', 'Als gelesen markieren', 'Mark as read');



SET FOREIGN_KEY_CHECKS = 1;