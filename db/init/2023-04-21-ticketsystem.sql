SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS 'status';
CREATE TABLE 'status'  (
  'intStatusID' int(11) NOT NULL AUTO_INCREMENT,
  'strName' varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY ('intStatusID') USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

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
  CONSTRAINT 'frn_tick_status' FOREIGN KEY ('intStatusID') REFERENCES 'status' ('intStatusID') ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT 'frn_tick_users_1' FOREIGN KEY ('intUserID') REFERENCES 'users' ('intUserID') ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT 'frn_tick_users_2' FOREIGN KEY ('intWorkerID') REFERENCES 'users' ('intUserID') ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS 'answer';
CREATE TABLE 'answer'  (
  'intAnswerID' int(11) NOT NULL AUTO_INCREMENT,
  'intTicketID' int(11) NOT NULL,
  'intUserID' int(11) NOT NULL,
  'strAnswer' varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  'dtmSent' datetime NULL DEFAULT NULL,
  PRIMARY KEY ('intAnswerID') USING BTREE,
  INDEX '_intTicketID'('intTicketID') USING BTREE,
  INDEX '_intUserID'('intUserID') USING BTREE,
  CONSTRAINT 'frn_answ_ticket' FOREIGN KEY ('intTicketID') REFERENCES 'ticket' ('intTicketID') ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT 'frn_answ_users' FOREIGN KEY ('intUserID') REFERENCES 'users' ('intUserID') ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin)
VALUES 
('sysadmin/ticketsystem', 'views/sysadmin/ticket_list.cfm', 0, 0, 1),
('sysadmin/ticketsystem/new', 'views/sysadmin/ticket_new.cfm', 0, 0, 1),
('sysadmin/ticketsystem/detail', 'views/sysadmin/ticket_detail.cfm', 0, 0, 1),
('ticketsystem/new', 'views/customer/ticket_new.cfm', 0, 0, 0),
('ticketsystem/detail', 'views/customer/ticket_detail.cfm', 0, 0, 0),
('ticketsystem/check', 'views/customer/ticket_check.cfm', 0, 0, 0);


SET FOREIGN_KEY_CHECKS = 1;