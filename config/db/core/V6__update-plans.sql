-- add redirect after booking a plan
ALTER TABLE `plans`
ADD COLUMN `strRedirectPath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL AFTER `strBookingLink`;
