-- Failed login attempts per e-mail address and per client IP (backend/core/com/loginthrottle.cfc).
-- strThrottleKey is "email:<sha-256 of the lower-case address>" or "ip:<address>" - no plain e-mail addresses are stored.
CREATE TABLE IF NOT EXISTS `login_throttle` (
  `strThrottleKey` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intFailures` int NOT NULL DEFAULT 0,
  `dtmFirstFailure` datetime NOT NULL,
  `dtmBlockedUntil` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`strThrottleKey`) USING BTREE,
  INDEX `_dtmBlockedUntil`(`dtmBlockedUntil`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- Message shown on the login page while an address or IP is blocked
INSERT IGNORE INTO `system_translations` (`strVariable`, `strStringDE`, `strStringEN`)
VALUES ('msgTooManyLoginAttempts', 'Zu viele fehlgeschlagene Anmeldeversuche. Bitte versuchen Sie es in 15 Minuten erneut.', 'Too many failed login attempts. Please try again in 15 minutes.');
