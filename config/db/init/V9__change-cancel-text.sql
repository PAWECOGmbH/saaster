SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

UPDATE system_translations
SET strStringDE = 'Ihr Abonnement wurde erfolgreich gekündigt.',
    strStringEN = 'Your subscription has been successfully cancelled.'
WHERE intSystTransID = 210;

SET FOREIGN_KEY_CHECKS = 1;