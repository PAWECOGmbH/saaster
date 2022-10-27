SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES ('notifications', 'views/customer/notifications.cfm', 0, 0, 0);


INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES 
('txtNotificationStatus', 'Status(gelesen)', 'Status(read)'),
('txtNotificationTitle', 'Benachrichtigungs Titel', 'Notification title'),
('txtNotificationCreated', 'erstellt am', 'created'),
('titNotifications', 'Benachrichtigungen', 'Notifications'),
('txtShowAllNotifications', 'Alle Benachrichtigungen Anzeigen', 'Show all notifications'),
('txtNotificationDelete', 'Wollen Sie diese Benachrichtigung löschen?', 'Do you want to delete this notification?'),
('titDeleteNotification', 'Benachrichtigung löschen', 'Delete notification'),
('txtMultipleNotificationDelete', 'Wollen Sie die ausgewählten Benachrichtigungen löschen?', 'Do you want to delete the selected notifications?'),
('titMultipleNotificationDelete', 'Benachrichtigungen löschen', 'Delete notifications'),
('alertNotificationDeleted', 'Die Benachrichtigung wurde gelöscht.', 'The notification have been deleted.'),
('alertMultipleNotificationDeleted', 'Die Benachrichtigungen wurden gelöscht.', 'The notifications have been deleted.');




SET FOREIGN_KEY_CHECKS = 1;