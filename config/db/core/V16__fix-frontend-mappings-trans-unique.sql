SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- The unique index on intFrontendMappingsID alone only allows one translation row
-- per mapping, regardless of language. Replace with a composite unique index on
-- (intFrontendMappingsID, intLanguageID) so each language can have its own row.
ALTER TABLE frontend_mappings_trans
    DROP INDEX `_intFrontendMappingsID`,
    ADD UNIQUE INDEX `_intFrontendMappingsID_lang` (`intFrontendMappingsID`, `intLanguageID`);

SET FOREIGN_KEY_CHECKS = 1;
