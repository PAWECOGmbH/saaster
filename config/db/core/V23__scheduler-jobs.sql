-- Scheduler: one job table instead of the 20 shard tables scheduler_01..scheduler_20.
--
-- Before: every customer/scheduletask pair was assigned to one of 20 tables, and each
-- of the 20 Lucee tasks (tasks.cfm?task=NN) worked off its own table. The assignment
-- was the source of lost and duplicate entries (issue #655), and a slow task blocked
-- everything else in its table.
--
-- Now: all pairs live in scheduler_jobs. The UNIQUE key makes duplicates impossible.
-- tasks.cfm?task=NN is a worker that claims the next due job with
-- SELECT ... FOR UPDATE SKIP LOCKED, so the workers share the load by themselves.
-- The URLs of the Lucee tasks stay the same.
--
-- The old tables are copied, not dropped: nothing writes to them any more, they only
-- remain as a fallback for this release and are removed by a later migration.

CREATE TABLE IF NOT EXISTS `scheduler_jobs` (
  `intJobID` int NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int NOT NULL,
  `intCustomerID` int NOT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `intDuringSeconds` smallint NULL DEFAULT 0,
  `strLockToken` varchar(40) NULL DEFAULT NULL,
  `dtmLockedUntil` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intJobID`),
  UNIQUE INDEX `_task_customer` (`intScheduletaskID`, `intCustomerID`),
  INDEX `_intCustomerID` (`intCustomerID`),
  INDEX `_dtmNextRun` (`dtmNextRun`),
  CONSTRAINT `frn_scheduler_jobs_task` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_jobs_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- Take over the existing entries. A pair that ended up in more than one table
-- becomes a single job: the earliest next run, so nothing is skipped, and the latest last run.
INSERT IGNORE INTO `scheduler_jobs` (`intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds`)
SELECT `intScheduletaskID`, `intCustomerID`, MIN(`dtmNextRun`), MAX(`dtmLastRun`), MAX(`intDuringSeconds`)
FROM (
  SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_01`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_02`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_03`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_04`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_05`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_06`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_07`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_08`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_09`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_10`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_11`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_12`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_13`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_14`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_15`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_16`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_17`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_18`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_19`
  UNION ALL SELECT `intScheduletaskID`, `intCustomerID`, `dtmNextRun`, `dtmLastRun`, `intDuringSeconds` FROM `scheduler_20`
) AS `shards`
GROUP BY `intScheduletaskID`, `intCustomerID`;
