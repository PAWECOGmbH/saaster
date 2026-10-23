-- Links sent by e-mail (invitation, password reset, e-mail change, registration opt-in) expire.
-- The lifetimes are defined in backend/core/com/user.cfc (tokenLifetimeHours) and frontend/core/com/register.cfc.

-- When the token in users.strUUID was issued (UTC)
ALTER TABLE `users` ADD COLUMN `dtmUUIDCreated` datetime NULL DEFAULT NULL AFTER `strUUID`;

-- Tokens that are already out there get the time of this migration, so pending
-- invitations and resets do not become invalid the moment this is deployed.
UPDATE `users` SET `dtmUUIDCreated` = UTC_TIMESTAMP() WHERE `strUUID` IS NOT NULL AND `strUUID` <> '';

-- When a registration opt-in was created (UTC). Existing rows get the time of this migration.
ALTER TABLE `optin` ADD COLUMN `dtmCreated` datetime NULL DEFAULT NULL;
UPDATE `optin` SET `dtmCreated` = UTC_TIMESTAMP();
