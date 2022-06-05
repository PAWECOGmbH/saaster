
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titBookedModules', 'Bereits gebuchte Module', 'Already booked modules');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titAvailableModules', 'Verfügbare Module', 'Available modules');

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('titTimezone', 'Zeitzone', 'Timezone');

UPDATE system_translations
SET strStringDE = 'Bitte ergänzen Sie die fehlenden Informationen',
    strStringEN = 'Please fill in the missing information'
WHERE intSystTransID = 223;


ALTER TABLE customers
ADD COLUMN intTimezoneID smallint(6) NULL AFTER intCountryID;