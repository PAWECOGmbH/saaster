
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





-- ----------------------------
-- Table structure for timezones
-- ----------------------------
DROP TABLE IF EXISTS `timezones`;
CREATE TABLE `timezones`  (
  `intTimeZoneID` int(11) NOT NULL AUTO_INCREMENT,
  `strUTC` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strCity` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strCountry` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`intTimeZoneID`) USING BTREE,
  UNIQUE INDEX `_intTimeZoneID`(`intTimeZoneID`) USING BTREE,
  INDEX `_strUTC`(`strUTC`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 85 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of timezones
-- ----------------------------
INSERT INTO `timezones` VALUES (1, 'UTC-10:00', 'Hawaii', 'Pacific/Honolulu');
INSERT INTO `timezones` VALUES (2, 'UTC-09:00', 'Alaska', 'America/Anchorage');
INSERT INTO `timezones` VALUES (3, 'UTC-08:00', 'Baja California', 'America/Santa Isabel');
INSERT INTO `timezones` VALUES (4, 'UTC-08:00', 'Pacific Time (US and Canada)', 'America/Los Angeles');
INSERT INTO `timezones` VALUES (5, 'UTC-07:00', 'Chihuahua, La Paz, Mazatlan', 'America/Chihuahua');
INSERT INTO `timezones` VALUES (6, 'UTC-07:00', 'Arizona', 'America/Phoenix');
INSERT INTO `timezones` VALUES (7, 'UTC-07:00', 'Mountain Time (US and Canada)', 'America/Denver');
INSERT INTO `timezones` VALUES (8, 'UTC-06:00', 'Central America', 'America/Guatemala');
INSERT INTO `timezones` VALUES (9, 'UTC-06:00', 'Central Time (US and Canada)', 'America/Chicago');
INSERT INTO `timezones` VALUES (10, 'UTC-06:00', 'Saskatchewan', 'America/Regina');
INSERT INTO `timezones` VALUES (11, 'UTC-06:00', 'Guadalajara, Mexico City, Monterey', 'America/Mexico City');
INSERT INTO `timezones` VALUES (12, 'UTC-05:00', 'Bogota, Lima, Quito', 'America/Bogota');
INSERT INTO `timezones` VALUES (13, 'UTC-05:00', 'Indiana (East)', 'America/Indiana/Indianapolis');
INSERT INTO `timezones` VALUES (14, 'UTC-05:00', 'Eastern Time (US and Canada)', 'America/New York');
INSERT INTO `timezones` VALUES (15, 'UTC-04:00', 'Atlantic Time (Canada)', 'America/Halifax');
INSERT INTO `timezones` VALUES (16, 'UTC-04:00', 'Asuncion', 'America/Asuncion');
INSERT INTO `timezones` VALUES (17, 'UTC-04:00', 'Georgetown, La Paz, Manaus, San Juan', 'America/La Paz');
INSERT INTO `timezones` VALUES (18, 'UTC-04:00', 'Cuiaba', 'America/Cuiaba');
INSERT INTO `timezones` VALUES (19, 'UTC-04:00', 'Santiago', 'America/Santiago');
INSERT INTO `timezones` VALUES (20, 'UTC-03:00', 'Brasilia', 'America/Sao Paulo');
INSERT INTO `timezones` VALUES (21, 'UTC-03:00', 'Greenland', 'America/Godthab');
INSERT INTO `timezones` VALUES (22, 'UTC-03:00', 'Cayenne, Fortaleza', 'America/Cayenne');
INSERT INTO `timezones` VALUES (23, 'UTC-03:00', 'Buenos Aires', 'America/Argentina/Buenos Aires');
INSERT INTO `timezones` VALUES (24, 'UTC-03:00', 'Montevideo', 'America/Montevideo');
INSERT INTO `timezones` VALUES (25, 'UTC-02:00', 'Coordinated Universal Time-2', 'Etc/GMT+2');
INSERT INTO `timezones` VALUES (26, 'UTC-01:00', 'Cape Verde', 'Atlantic/Cape Verde');
INSERT INTO `timezones` VALUES (27, 'UTC-01:00', 'Azores', 'Atlantic/Azores');
INSERT INTO `timezones` VALUES (28, 'UTC+00:00', 'Casablanca', 'Africa/Casablanca');
INSERT INTO `timezones` VALUES (29, 'UTC+00:00', 'Monrovia, Reykjavik', 'Atlantic/Reykjavik');
INSERT INTO `timezones` VALUES (30, 'UTC+00:00', 'Dublin, Edinburgh, Lisbon, London', 'Europe/London');
INSERT INTO `timezones` VALUES (31, 'UTC+00:00', 'Coordinated Universal Time', 'Etc/GMT');
INSERT INTO `timezones` VALUES (32, 'UTC+01:00', 'Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna', 'Europe/Berlin');
INSERT INTO `timezones` VALUES (33, 'UTC+01:00', 'Brussels, Copenhagen, Madrid, Paris', 'Europe/Paris');
INSERT INTO `timezones` VALUES (34, 'UTC+01:00', 'West Central Africa', 'Africa/Lagos');
INSERT INTO `timezones` VALUES (35, 'UTC+01:00', 'Belgrade, Bratislava, Budapest, Ljubljana, Prague', 'Europe/Budapest');
INSERT INTO `timezones` VALUES (36, 'UTC+01:00', 'Sarajevo, Skopje, Warsaw, Zagreb', 'Europe/Warsaw');
INSERT INTO `timezones` VALUES (37, 'UTC+01:00', 'Windhoek', 'Africa/Windhoek');
INSERT INTO `timezones` VALUES (38, 'UTC+02:00', 'Athens, Bucharest, Istanbul', 'Europe/Istanbul');
INSERT INTO `timezones` VALUES (39, 'UTC+02:00', 'Helsinki, Kiev, Riga, Sofia, Tallinn, Vilnius', 'Europe/Kiev');
INSERT INTO `timezones` VALUES (40, 'UTC+02:00', 'Cairo', 'Africa/Cairo');
INSERT INTO `timezones` VALUES (41, 'UTC+02:00', 'Damascus', 'Asia/Damascus');
INSERT INTO `timezones` VALUES (42, 'UTC+02:00', 'Amman', 'Asia/Amman');
INSERT INTO `timezones` VALUES (43, 'UTC+02:00', 'Harare, Pretoria', 'Africa/Johannesburg');
INSERT INTO `timezones` VALUES (44, 'UTC+02:00', 'Jerusalem', 'Asia/Jerusalem');
INSERT INTO `timezones` VALUES (45, 'UTC+02:00', 'Beirut', 'Asia/Beirut');
INSERT INTO `timezones` VALUES (46, 'UTC+03:00', 'Baghdad', 'Asia/Baghdad');
INSERT INTO `timezones` VALUES (47, 'UTC+03:00', 'Minsk', 'Europe/Minsk');
INSERT INTO `timezones` VALUES (48, 'UTC+03:00', 'Kuwait, Riyadh', 'Asia/Riyadh');
INSERT INTO `timezones` VALUES (49, 'UTC+03:00', 'Nairobi', 'Africa/Nairobi');
INSERT INTO `timezones` VALUES (50, 'UTC+04:00', 'Moscow, St. Petersburg, Volgograd', 'Europe/Moscow');
INSERT INTO `timezones` VALUES (51, 'UTC+04:00', 'Tbilisi', 'Asia/Tbilisi');
INSERT INTO `timezones` VALUES (52, 'UTC+04:00', 'Yerevan', 'Asia/Yerevan');
INSERT INTO `timezones` VALUES (53, 'UTC+04:00', 'Abu Dhabi, Muscat', 'Asia/Dubai');
INSERT INTO `timezones` VALUES (54, 'UTC+04:00', 'Baku', 'Asia/Baku');
INSERT INTO `timezones` VALUES (55, 'UTC+04:00', 'Port Louis', 'Indian/Mauritius');
INSERT INTO `timezones` VALUES (56, 'UTC+05:00', 'Tashkent', 'Asia/Tashkent');
INSERT INTO `timezones` VALUES (57, 'UTC+05:00', 'Islamabad, Karachi', 'Asia/Karachi');
INSERT INTO `timezones` VALUES (58, 'UTC+06:00', 'Astana', 'Asia/Almaty');
INSERT INTO `timezones` VALUES (59, 'UTC+06:00', 'Dhaka', 'Asia/Dhaka');
INSERT INTO `timezones` VALUES (60, 'UTC+06:00', 'Yekaterinburg', 'Asia/Yekaterinburg');
INSERT INTO `timezones` VALUES (61, 'UTC+07:00', 'Bangkok, Hanoi, Jakarta', 'Asia/Bangkok');
INSERT INTO `timezones` VALUES (62, 'UTC+07:00', 'Novosibirsk', 'Asia/Novosibirsk');
INSERT INTO `timezones` VALUES (63, 'UTC+08:00', 'Krasnoyarsk', 'Asia/Krasnoyarsk');
INSERT INTO `timezones` VALUES (64, 'UTC+08:00', 'Ulaanbaatar', 'Asia/Ulaanbaatar');
INSERT INTO `timezones` VALUES (65, 'UTC+08:00', 'Beijing, Chongqing, Hong Kong, Urumqi', 'Asia/Shanghai');
INSERT INTO `timezones` VALUES (66, 'UTC+08:00', 'Perth', 'Australia/Perth');
INSERT INTO `timezones` VALUES (67, 'UTC+08:00', 'Kuala Lumpur, Singapore', 'Asia/Singapore');
INSERT INTO `timezones` VALUES (68, 'UTC+08:00', 'Taipei', 'Asia/Taipei');
INSERT INTO `timezones` VALUES (69, 'UTC+09:00', 'Irkutsk', 'Asia/Irkutsk');
INSERT INTO `timezones` VALUES (70, 'UTC+09:00', 'Seoul', 'Asia/Seoul');
INSERT INTO `timezones` VALUES (71, 'UTC+09:00', 'Osaka, Sapporo, Tokyo', 'Asia/Tokyo');
INSERT INTO `timezones` VALUES (72, 'UTC+10:00', 'Hobart', 'Australia/Hobart');
INSERT INTO `timezones` VALUES (73, 'UTC+10:00', 'Yakutsk', 'Asia/Yakutsk');
INSERT INTO `timezones` VALUES (74, 'UTC+10:00', 'Brisbane', 'Australia/Brisbane');
INSERT INTO `timezones` VALUES (75, 'UTC+10:00', 'Guam, Port Moresby', 'Pacific/Port_Moresby');
INSERT INTO `timezones` VALUES (76, 'UTC+10:00', 'Canberra, Melbourne, Sydney', 'Australia/Sydney');
INSERT INTO `timezones` VALUES (77, 'UTC+11:00', 'Vladivostok', 'Asia/Vladivostok');
INSERT INTO `timezones` VALUES (78, 'UTC+11:00', 'Solomon Islands, New Caledonia', 'Pacific/Guadalcanal');
INSERT INTO `timezones` VALUES (79, 'UTC+12:00', 'Coordinated Universal Time+12', 'Etc/GMT-12');
INSERT INTO `timezones` VALUES (80, 'UTC+12:00', 'Fiji, Marshall Islands', 'Pacific/Fiji');
INSERT INTO `timezones` VALUES (81, 'UTC+12:00', 'Magadan', 'Asia/Magadan');
INSERT INTO `timezones` VALUES (82, 'UTC+12:00', 'Auckland, Wellington', 'Pacific/Auckland');
INSERT INTO `timezones` VALUES (83, 'UTC+13:00', 'Nuku\'alofa', 'Pacific/Tongatapu');
INSERT INTO `timezones` VALUES (84, 'UTC+13:00', 'Samoa', 'Pacific/Apia');

SET FOREIGN_KEY_CHECKS = 1;
