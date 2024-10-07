SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

UPDATE frontend_mappings
SET strMapping = 'frontend/handler/ads'
WHERE intFrontendMappingsID = 10;

SET FOREIGN_KEY_CHECKS = 1;