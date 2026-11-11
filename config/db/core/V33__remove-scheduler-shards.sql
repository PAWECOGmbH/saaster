SET NAMES utf8mb4;

-- V23 copied all legacy jobs to scheduler_jobs. The running scheduler no longer uses these tables.
DROP TABLE IF EXISTS
    `scheduler_01`,
    `scheduler_02`,
    `scheduler_03`,
    `scheduler_04`,
    `scheduler_05`,
    `scheduler_06`,
    `scheduler_07`,
    `scheduler_08`,
    `scheduler_09`,
    `scheduler_10`,
    `scheduler_11`,
    `scheduler_12`,
    `scheduler_13`,
    `scheduler_14`,
    `scheduler_15`,
    `scheduler_16`,
    `scheduler_17`,
    `scheduler_18`,
    `scheduler_19`,
    `scheduler_20`;
