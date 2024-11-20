SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

UPDATE frontend_mappings SET strPath = 'templates/login.cfm' WHERE strMapping = 'login';
UPDATE frontend_mappings SET strPath = 'templates/register.cfm' WHERE strMapping = 'register';
UPDATE frontend_mappings SET strPath = 'templates/password.cfm' WHERE strMapping = 'password';
UPDATE frontend_mappings SET strPath = 'templates/plans.cfm' WHERE strMapping = 'plans';
UPDATE frontend_mappings SET strPath = 'templates/mfa.cfm' WHERE strMapping = 'mfa';


SET FOREIGN_KEY_CHECKS = 1;