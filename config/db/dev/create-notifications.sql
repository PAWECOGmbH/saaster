-- Demo notifications for the first account of the installation (customer 1, user 1 - usually
-- the sysadmin who ran the setup). Five unread and three read ones, spread over the last days.
-- The demo customers of create-customers.sql get their own notifications there.
--
-- Data only. Running it again replaces these notifications (recognised by their description
-- variable) instead of adding them a second time. Nothing happens before the setup created
-- the first account.
--
-- Import (see readme.md): cat ./config/db/dev/create-notifications.sql | docker exec -i <mysql container> mysql -u <user> -p<password> <database>

SET NAMES utf8mb4;

DELETE FROM notifications
WHERE intCustomerID = 1 AND intUserID = 1 AND strDescrVar = 'errSystemStoppedFixProblem';

INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitleVar, strDescrVar, strLink, strLinkTextVar, dtmRead)
SELECT 1, 1, DATE_SUB(UTC_TIMESTAMP(), INTERVAL n.ageHours HOUR), n.title, 'errSystemStoppedFixProblem', n.link, 'btnActivate',
       IF(n.readHours IS NULL, NULL, DATE_SUB(UTC_TIMESTAMP(), INTERVAL n.readHours HOUR))
FROM (
    SELECT 0 AS ageHours, 'txtInformation' AS title, '/account-settings/company' AS link, NULL AS readHours
    UNION ALL SELECT 2, 'formInvoiceInfo', '/account-settings/tenants', NULL
    UNION ALL SELECT 24, 'txtNetwork', '/account-settings/users', NULL
    UNION ALL SELECT 48, 'titTimezone', '/account-settings/reset-password', NULL
    UNION ALL SELECT 72, 'titDowngrade', '/account-settings', NULL
    UNION ALL SELECT 120, 'titModule', '/account-settings/modules', 96
    UNION ALL SELECT 192, 'titNotifications', '/account-settings', 168
    UNION ALL SELECT 288, 'titStatus', '/account-settings', 288
) AS n
WHERE EXISTS (SELECT 1 FROM users WHERE intUserID = 1 AND intCustomerID = 1);
