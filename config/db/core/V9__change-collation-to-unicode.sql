ALTER TABLE `schedulecontrol`
MODIFY COLUMN `strTaskName` varchar(20) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci NOT NULL AFTER `intControlID`;

ALTER TABLE `scheduler_01` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_02` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_03` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_04` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_05` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_06` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_07` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_08` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_09` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_10` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_11` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_12` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_13` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_14` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_15` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_16` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_17` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_18` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_19` COLLATE = utf8mb4_unicode_ci;
ALTER TABLE `scheduler_20` COLLATE = utf8mb4_unicode_ci;

ALTER TABLE `scheduletasks`
MODIFY COLUMN `strName` varchar(255) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `intScheduletaskID`,
MODIFY COLUMN `strPath` varchar(255) CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `dtmStartTime`,
COLLATE = utf8mb4_unicode_ci;