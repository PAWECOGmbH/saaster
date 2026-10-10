-- Scheduler lease: every shard run (task_01..task_20) now claims the
-- schedulecontrol row with a unique run token. Only the owner of the token
-- can release the row again, so a stale run that outlived its lease can no
-- longer clear the flag of the run that took over.
SET @stmt = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'schedulecontrol' AND COLUMN_NAME = 'strRunToken') = 0,
  'ALTER TABLE `schedulecontrol`
     ADD COLUMN `strRunToken` varchar(40) NULL DEFAULT NULL AFTER `blnIsRunning`',
  'SELECT 1'
);
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Shards that are still flagged as running from before this migration would
-- block until their lease expires. Release them once.
UPDATE `schedulecontrol`
SET `blnIsRunning` = 0,
    `strRunToken` = NULL
WHERE `blnIsRunning` = 1;
