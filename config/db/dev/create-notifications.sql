
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitleVar, strDescrVar, strLink, strLinkTextVar, dtmRead)
VALUES (1, 1, NOW(), 'txtInformation', 'errSystemStoppedFixProblem', 'account-settings/company', 'btnActivate', NULL);

INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitleVar, strDescrVar, strLink, strLinkTextVar, dtmRead)
VALUES (1, 1, NOW(), 'formInvoiceInfo', 'errSystemStoppedFixProblem', 'account-settings/tenants', 'btnActivate', NULL);

INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitleVar, strDescrVar, strLink, strLinkTextVar, dtmRead)
VALUES (1, 1, NOW(), 'txtNetwork', 'errSystemStoppedFixProblem', 'account-settings/users', 'btnActivate', NULL);

INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitleVar, strDescrVar, strLink, strLinkTextVar, dtmRead)
VALUES (1, 1, NOW(), 'titTimezone', 'errSystemStoppedFixProblem', 'account-settings/reset-password', 'btnActivate', NULL);

INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitleVar, strDescrVar, strLink, strLinkTextVar, dtmRead)
VALUES (1, 1, NOW(), 'titDowngrade', 'errSystemStoppedFixProblem', 'account-settings', 'btnActivate', NULL);

INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitleVar, strDescrVar, strLink, strLinkTextVar, dtmRead)
VALUES (1, 1, NOW(), 'titModule', 'errSystemStoppedFixProblem', 'account-settings/modules', 'btnActivate', NULL);

INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitleVar, strDescrVar, strLink, strLinkTextVar, dtmRead)
VALUES (1, 1, NOW(), 'titNotifications', 'errSystemStoppedFixProblem', 'account-settings', 'btnActivate', NULL);

INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitleVar, strDescrVar, strLink, strLinkTextVar, dtmRead)
VALUES (1, 1, NOW(), 'titStatus', 'errSystemStoppedFixProblem', 'account-settings', 'btnActivate', NULL);

SET FOREIGN_KEY_CHECKS = 1;