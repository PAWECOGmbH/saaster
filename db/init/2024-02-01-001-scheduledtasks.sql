SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `schedulecontrol`;
CREATE TABLE `schedulecontrol` (
    `intControlID` int NOT NULL AUTO_INCREMENT,
    `strTaskName` varchar(20) NOT NULL,
    `dtmStart` datetime NULL,
    `dtmEnd` datetime NULL,
    `intCntCustomer` int NULL DEFAULT 0,
    PRIMARY KEY (`intControlID`)
);

INSERT INTO `schedulecontrol` (strTaskName, dtmStart, dtmEnd)
VALUES
('task_01', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_02', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_03', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_04', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_05', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_06', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_07', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_08', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_09', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_10', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_11', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_12', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_13', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_14', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_15', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_16', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_17', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_18', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_19', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND)),
('task_20', NOW(), DATE_ADD(NOW(), INTERVAL 1 SECOND));

DROP TABLE IF EXISTS `scheduletasks`;
CREATE TABLE `scheduletasks`  (
  `intScheduletaskID` int NOT NULL AUTO_INCREMENT,
  `strName` varchar(255) NULL,
  `intModuleID` int NULL,
  `dtmStartTime` datetime NULL,
  `strPath` varchar(255) NULL,
  `intIterationMinutes` int NOT NULL DEFAULT 5,
  `blnActive` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intScheduletaskID`),
  UNIQUE INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intModuleID`(`intModuleID`),
  CONSTRAINT `frn_sch_module` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS `scheduler_01`;
CREATE TABLE `scheduler_01`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_01` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_01` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_02`;
CREATE TABLE `scheduler_02`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_02` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_02` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_03`;
CREATE TABLE `scheduler_03`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_03` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_03` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_04`;
CREATE TABLE `scheduler_04`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_04` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_04` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_05`;
CREATE TABLE `scheduler_05`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_05` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_05` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_06`;
CREATE TABLE `scheduler_06`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_06` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_06` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_07`;
CREATE TABLE `scheduler_07`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_07` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_07` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_08`;
CREATE TABLE `scheduler_08`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_08` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_08` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_09`;
CREATE TABLE `scheduler_09`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_09` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_09` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_10`;
CREATE TABLE `scheduler_10`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_10` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_10` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_11`;
CREATE TABLE `scheduler_11`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_11` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_11` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_12`;
CREATE TABLE `scheduler_12`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_12` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_12` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_13`;
CREATE TABLE `scheduler_13`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_13` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_13` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_14`;
CREATE TABLE `scheduler_14`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_14` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_14` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_15`;
CREATE TABLE `scheduler_15`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_15` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_15` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_16`;
CREATE TABLE `scheduler_16`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_16` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_16` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_17`;
CREATE TABLE `scheduler_17`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_17` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_17` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_18`;
CREATE TABLE `scheduler_18`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_18` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_18` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_19`;
CREATE TABLE `scheduler_19`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_19` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_19` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);
DROP TABLE IF EXISTS `scheduler_20`;
CREATE TABLE `scheduler_20`  (
  `intSchedulerID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmLastRun` datetime NULL,
  `dtmNextRun` datetime NULL,
  PRIMARY KEY (`intSchedulerID`),
  INDEX `_intScheduletaskID`(`intScheduletaskID`),
  INDEX `_intCustomerID`(`intCustomerID`),
  CONSTRAINT `frn_scheduler_sched_20` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_customers_20` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
);








SET FOREIGN_KEY_CHECKS = 1;