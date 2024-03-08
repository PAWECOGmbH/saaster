SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('alertCantDeleteAccount', 'Sie haben einen oder mehrere Mandanten erstellt, welche keine eigenen Benutzer besitzen. Sie können Ihren Account erst löschen, wenn alle Mandanten mindestens einen eigenen Benutzer besitzen.', 'You have created one or more tenants that do not have their own users. You can only delete your account once all tenants have at least one user of their own.');

UPDATE system_translations
SET strStringDE = 'Abonnement gekündigt. Sie können es bis zum Ablaufdatum weiter nutzen.',
    strStringEN = 'Subscription cancelled. You can continue to use it until the expiry date.'
WHERE strVariable = 'txtSubscriptionCanceled';

SET FOREIGN_KEY_CHECKS = 1;