SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

/* Create tabelle status */
DROP TABLE IF EXISTS 'ticket_status';
CREATE TABLE 'ticket_status'  (
  'intStatusID' int(11) NOT NULL AUTO_INCREMENT,
  'strName' varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY ('intStatusID') USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

/* Create tabelle ticket */
DROP TABLE IF EXISTS 'ticket';
CREATE TABLE 'ticket'  (
  'intTicketID' int(11) NOT NULL AUTO_INCREMENT,
  'intStatusID' int(11) NOT NULL,
  'intUserID' int(11) NOT NULL,
  'intWorkerID' int(11) NULL DEFAULT NULL,
  'strReference' varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  'strDescription' varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  'dtmOpen' datetime NULL DEFAULT NULL,
  'strUUID' varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY ('intTicketID') USING BTREE,
  INDEX '_intStatusID'('intStatusID') USING BTREE,
  INDEX '_intUserID'('intUserID') USING BTREE,
  INDEX '_intWorkerID'('intWorkerID') USING BTREE,
  INDEX '_strUUID'('strUUID') USING BTREE,
  CONSTRAINT 'frn_tick_ticket_status' FOREIGN KEY ('intStatusID') REFERENCES 'ticket_status' ('intStatusID') ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT 'frn_tick_users_1' FOREIGN KEY ('intUserID') REFERENCES 'users' ('intUserID') ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT 'frn_tick_users_2' FOREIGN KEY ('intWorkerID') REFERENCES 'users' ('intUserID') ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

/* Create tabelle answer */
DROP TABLE IF EXISTS 'ticket_answer';
CREATE TABLE 'ticket_answer'  (
  'intAnswerID' int(11) NOT NULL AUTO_INCREMENT,
  'intTicketID' int(11) NOT NULL,
  'intUserID' int(11) NOT NULL,
  'strAnswer' varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  'dtmSent' datetime NULL DEFAULT NULL,
  PRIMARY KEY ('intAnswerID') USING BTREE,
  INDEX '_intTicketID'('intTicketID') USING BTREE,
  INDEX '_intUserID'('intUserID') USING BTREE,
  CONSTRAINT 'frn_ta_ticket' FOREIGN KEY ('intTicketID') REFERENCES 'ticket' ('intTicketID') ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT 'frn_ta_users' FOREIGN KEY ('intUserID') REFERENCES 'users' ('intUserID') ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

/* System mapping entries */
INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES 
('sysadmin/ticketsystem', 'views/sysadmin/ticket_list.cfm', 0, 0, 1),
('sysadmin/ticketsystem/new', 'views/sysadmin/ticket_new.cfm', 0, 0, 1),
('sysadmin/ticketsystem/detail', 'views/sysadmin/ticket_detail.cfm', 0, 0, 1),
('ticket/new', 'views/customer/ticket_new.cfm', 0, 0, 0),
('ticket/detail', 'views/customer/ticket_detail.cfm', 0, 0, 0),
('ticket/check', 'views/customer/ticket_check.cfm', 0, 0, 0),
('ticket', 'handler/ticket.cfm', 0, 0, 1);

/* Language variables*/
INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES 
('titSupport', 'Hilfe', 'Support'),
('txtReference', 'Betreff', 'Reference'),
('txtDescription', 'Beschreibung', 'Description'),
('txtSend', 'Senden', 'Send'),
('txtTicket', 'Ticket', 'Ticket'),
('txtNew', 'Neu', 'New'),
('txtCheck', 'Überprüfen', 'Check'),
('txtCheckFirst', 'Dein Support-Ticket mit der Ticketnummer: ', 'Your support ticket with the ticket number: '),
('txtCheckSecond', ' wurde erfolgreich übermittelt.', ' has been sent successfully.'),
('txtCheckThird', 'Wir werden uns schnellstmöglich bei Ihnen melden!', 'We will contact you as soon as possible!'),
('titTicketnumber', 'Ticketnummer', 'Ticket number'),
('txtInfo', 'Info', 'Info'),
('txtUser', 'Benutzer', 'User'),
('txtCreated', 'Erstellt', 'Created'),
('txtStatus', 'Status', 'Status'),
('txtWorker', 'Mitarbeiter', 'Worker'),
('txtClose', 'Schliessen', 'Close'),
('txtReferenceError', 'Geben Sie einen Betreff an!', 'Enter a reference!'),
('txtDescriptionError', 'Geben Sie eine Beschreibung ein!', 'Enter a description!'),
('txtDescriptionReferenceError', 'Geben Sie eine Beschreibung und Betreff ein!', 'Enter a description and reference!'),
('txtCreateTicketError', 'Abfrage zum Erstellen des Tickets konnte nicht ausgeführt werden!', 'Could not execute query to create ticket!'),
('txtCheckUuidError', 'Abfrage qUuidCheck konnte nicht ausgeführt werden!', 'Could not execute query qUuidCheck!'),
('txtAnswerCreated', 'Antwort erfolgreich gesendet!', 'Response sent successfully!'),
('txtAnswerError', 'Geben Sie eine Antwort ein!', 'Enter a answer!'),
('txtTicketError', 'Geben Sie eine Antwort auf Ihr Ticket ein!', 'Enter a reply to your ticket!'),
('txtCreateAnswerError', 'Die Abfrage zum Erstellen der Antwort konnte nicht ausgeführt werden!', 'Could not execute query to create answer!'),
('txtTicketUserError', 'Ticket nicht gefunden!', 'Ticket not found!'),
('txtAnswerStatusError', 'Das Ticket hat den falschen Status um eine antwort zu senden!', 'The ticket has the wrong status to send a reply!'),
('txtEmailError', 'E-Mail konnte nicht gesendet werden!', 'Could not send E-Mail!'),
('txtEmailUserError', 'Abfrage zum Abrufen von Benutzerdaten konnte nicht ausgeführt werden!', 'Could not execute query to get user data!'),
('txtTicketCheckError', 'Die Abfrage zum Suchen von Tickets vom Benutzer konnte nicht ausgeführt werden!', 'Could not execute query to find tickets from user!'),
('txtTicketAmountError', 'Du hast bereits drei Tickets, die noch nicht abgeschlossen sind!', 'You already have three tickets that are not yet closed!');

/* Ticket status entries */
INSERT INTO ticket_status (strName)
VALUES 
('New'),
('Processing'),
('Closed');



SET FOREIGN_KEY_CHECKS = 1;