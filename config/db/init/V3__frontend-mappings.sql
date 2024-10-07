SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO `frontend_mappings` (strMapping, strPath)
VALUES ('stelle', 'frontend/job.cfm');

INSERT INTO `frontend_mappings` (strMapping, strPath)
VALUES ('stelle/bewerben', 'frontend/apply.cfm');

INSERT INTO `frontend_mappings` (strMapping, strPath)
VALUES ('handler/ads', 'frontend/handler/ads.cfm');


SET FOREIGN_KEY_CHECKS = 1;