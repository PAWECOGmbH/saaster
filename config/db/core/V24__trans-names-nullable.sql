-- Issue #689: saving a translation of a plan (country, widget) that had no row for the
-- language yet failed with "Field 'strPlanName' doesn't have a default value".
--
-- The translation modal (backend/core/com/translate.cfc::saveTranslation) creates the row
-- of a language with only the field being translated, e.g. the description. The name
-- columns of these three tables were NOT NULL without a default. They may stay empty now:
-- every query reading them falls back to the name of the base table when the translated
-- name is empty - IF(LENGTH(<translated name>), <translated name>, <base name>).
--
-- MODIFY is safe to run on a database where the columns already allow NULL.

ALTER TABLE `plans_trans`
MODIFY COLUMN `strPlanName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

ALTER TABLE `countries_trans`
MODIFY COLUMN `strCountryName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;

ALTER TABLE `widgets_trans`
MODIFY COLUMN `strWidgetName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL;
