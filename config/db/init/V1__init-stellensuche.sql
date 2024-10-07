
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for api_management
-- ----------------------------
DROP TABLE IF EXISTS `api_management`;
CREATE TABLE `api_management`  (
  `intApiID` int(11) NOT NULL AUTO_INCREMENT,
  `strApiName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strApiKeyHash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strApiKeySalt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dtmValidUntil` datetime(6) NULL DEFAULT NULL,
  PRIMARY KEY (`intApiID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_management
-- ----------------------------

-- ----------------------------
-- Table structure for api_nonce
-- ----------------------------
DROP TABLE IF EXISTS `api_nonce`;
CREATE TABLE `api_nonce`  (
  `intNonceID` int(11) NOT NULL AUTO_INCREMENT,
  `strNonceUUID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `dtmNonceCreated` datetime(6) NOT NULL,
  `intCreatedBy` int(11) NOT NULL,
  PRIMARY KEY (`intNonceID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_nonce
-- ----------------------------

-- ----------------------------
-- Table structure for bookings
-- ----------------------------
DROP TABLE IF EXISTS `bookings`;
CREATE TABLE `bookings`  (
  `intBookingID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intPlanID` int(11) NULL DEFAULT NULL,
  `intModuleID` int(11) NULL DEFAULT NULL,
  `dteStartDate` date NULL DEFAULT NULL,
  `dteEndDate` date NULL DEFAULT NULL,
  `strRecurring` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strStatus` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intBookingID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intPlanID`(`intPlanID`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_cb_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cb_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cb_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of bookings
-- ----------------------------
INSERT INTO `bookings` VALUES (15, 2, 1, NULL, '2024-05-28', '3000-01-01', 'onetime', 'free');
INSERT INTO `bookings` VALUES (19, 3, 4, NULL, '2024-07-12', '2024-08-12', 'monthly', 'active');
INSERT INTO `bookings` VALUES (20, 4, 4, NULL, '2024-07-12', '2024-08-12', 'monthly', 'canceled');
INSERT INTO `bookings` VALUES (21, 5, 1, NULL, '2024-07-12', '3000-01-01', 'onetime', 'free');
INSERT INTO `bookings` VALUES (22, 6, 5, NULL, '2024-07-12', '3000-01-01', 'onetime', 'free');

-- ----------------------------
-- Table structure for countries
-- ----------------------------
DROP TABLE IF EXISTS `countries`;
CREATE TABLE `countries`  (
  `intCountryID` int(11) NOT NULL AUTO_INCREMENT,
  `strCountryName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intLanguageID` int(11) NULL DEFAULT NULL,
  `strLocale` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strISO1` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strISO2` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strCurrency` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strRegion` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strSubRegion` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intTimezoneID` smallint(3) NULL DEFAULT NULL,
  `strFlagSVG` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intPrio` int(4) NOT NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 0,
  `blnDefault` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intCountryID`) USING BTREE,
  UNIQUE INDEX `_intCountryID`(`intCountryID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  INDEX `_intTimezoneID`(`intTimezoneID`) USING BTREE,
  FULLTEXT INDEX `FulltextStrings`(`strCountryName`, `strLocale`, `strISO1`, `strISO2`, `strCurrency`, `strRegion`, `strSubRegion`)
) ENGINE = InnoDB AUTO_INCREMENT = 251 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of countries
-- ----------------------------
INSERT INTO `countries` VALUES (1, 'Montenegro', 1, 'sr_ME', 'ME', 'MNE', 'EUR', 'Europe', 'Southeast Europe', 38, 'https://flagcdn.com/me.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (2, 'Tokelau', 1, '	en_TK', 'TK', 'TKL', 'NZD', 'Oceania', 'Polynesia', 83, 'https://flagcdn.com/tk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (3, 'Cuba', 1, 'es_CU', 'CU', 'CUB', 'CUC', 'Americas', 'Caribbean', 11, 'https://flagcdn.com/cu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (4, 'Guadeloupe', 1, '	fr_GP', 'GP', 'GLP', 'EUR', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/gp.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (5, 'Greece', 1, 'el_GR', 'GR', 'GRC', 'EUR', 'Europe', 'Southern Europe', 47, 'https://flagcdn.com/gr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (6, 'Martinique', 1, 'fr_MQ', 'MQ', 'MTQ', 'EUR', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/mq.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (7, 'Venezuela', 1, 'es_VE', 'VE', 'VEN', 'VES', 'Americas', 'South America', 15, 'https://flagcdn.com/ve.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (8, 'United States Minor Outlying Islands', 1, 'en_UM', 'UM', 'UMI', 'USD', 'Americas', 'North America', 1, 'https://flagcdn.com/um.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (9, 'Samoa', 1, 'en_WS', 'WS', 'WSM', 'WST', 'Oceania', 'Polynesia', 84, 'https://flagcdn.com/ws.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (10, 'Cambodia', 1, 'km_KH', 'KH', 'KHM', 'KHR', 'Asia', 'South-Eastern Asia', 6, 'https://flagcdn.com/kh.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (11, 'Hong Kong', 1, 'en_HK', 'HK', 'HKG', 'HKD', 'Asia', 'Eastern Asia', 65, 'https://flagcdn.com/hk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (12, 'Mauritania', 1, '	ar_MR', 'MR', 'MRT', 'MRU', 'Africa', 'Western Africa', 28, 'https://flagcdn.com/mr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (13, 'Yemen', 1, 'ar_YE', 'YE', 'YEM', 'YER', 'Asia', 'Western Asia', 48, 'https://flagcdn.com/ye.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (14, 'Djibouti', 1, 'aa_DJ', 'DJ', 'DJI', 'DJF', 'Africa', 'Eastern Africa', 48, 'https://flagcdn.com/dj.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (15, 'British Virgin Islands', 1, '	en_VG', 'VG', 'VGB', 'USD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/vg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (16, 'Egypt', 1, 'ar_EG', 'EG', 'EGY', 'EGP', 'Africa', 'Northern Africa', 40, 'https://flagcdn.com/eg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (17, 'Croatia', 1, 'hr_HR', 'HR', 'HRV', 'HRK', 'Europe', 'Southeast Europe', 36, 'https://flagcdn.com/hr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (18, 'Liechtenstein', 1, 'de_LI', 'LI', 'LIE', 'CHF', 'Europe', 'Western Europe', 33, 'https://flagcdn.com/li.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (19, 'Kazakhstan', 1, 'kk_KZ', 'KZ', 'KAZ', 'KZT', 'Asia', 'Central Asia', 56, 'https://flagcdn.com/kz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (20, 'Denmark', 1, 'da_DK', 'DK', 'DNK', 'DKK', 'Europe', 'Northern Europe', 32, 'https://flagcdn.com/dk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (21, 'Benin', 1, '	fr_BJ', 'BJ', 'BEN', 'XOF', 'Africa', 'Western Africa', 34, 'https://flagcdn.com/bj.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (22, 'Northern Mariana Islands', 1, 'en_MP', 'MP', 'MNP', 'USD', 'Oceania', 'Micronesia', 76, 'https://flagcdn.com/mp.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (23, 'Bermuda', 1, '	en_BM', 'BM', 'BMU', 'BMD', 'Americas', 'North America', 21, 'https://flagcdn.com/bm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (24, 'Italy', 1, 'it_IT', 'IT', 'ITA', 'EUR', 'Europe', 'Southern Europe', 33, 'https://flagcdn.com/it.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (25, 'South Georgia', 1, '	ka', 'GS', 'SGS', 'SHP', 'Antarctic', '', 25, 'https://flagcdn.com/gs.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (26, 'South Africa', 1, 'af_ZA', 'ZA', 'ZAF', 'ZAR', 'Africa', 'Southern Africa', 40, 'https://flagcdn.com/za.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (27, 'Rwanda', 1, 'rw_RW', 'RW', 'RWA', 'RWF', 'Africa', 'Eastern Africa', 40, 'https://flagcdn.com/rw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (28, 'Macau', 1, 'zh_MO', 'MO', 'MAC', 'MOP', 'Asia', 'Eastern Asia', 65, 'https://flagcdn.com/mo.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (29, 'Burundi', 1, '	rn_BI', 'BI', 'BDI', 'BIF', 'Africa', 'Eastern Africa', 27, 'https://flagcdn.com/bi.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (30, 'French Guiana', 1, '	fr_GF', 'GF', 'GUF', 'EUR', 'Americas', 'South America', 20, 'https://flagcdn.com/gf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (31, 'Ukraine', 1, 'ru_UA', 'UA', 'UKR', 'UAH', 'Europe', 'Eastern Europe', 39, 'https://flagcdn.com/ua.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (32, 'Togo', 1, 'ee_TG', 'TG', 'TGO', 'XOF', 'Africa', 'Western Africa', 28, 'https://flagcdn.com/tg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (33, 'Taiwan', 1, 'zh_TW', 'TW', 'TWN', 'TWD', 'Asia', 'Eastern Asia', 68, 'https://flagcdn.com/tw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (34, 'Antarctica', 1, '	en_US', 'AQ', 'ATA', '', 'Antarctic', '', 72, 'https://flagcdn.com/aq.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (35, 'Cook Islands', 1, '	en_CK', 'CK', 'COK', 'CKD', 'Oceania', 'Polynesia', 1, 'https://flagcdn.com/ck.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (36, 'Guinea-Bissau', 1, '	pt_GW', 'GW', 'GNB', 'XOF', 'Africa', 'Western Africa', 28, 'https://flagcdn.com/gw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (37, 'Sint Maarten', 1, '	en_SX', 'SX', 'SXM', 'ANG', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/sx.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (38, 'Ivory Coast', 1, 'kfo_CI', 'CI', 'CIV', 'XOF', 'Africa', 'Western Africa', 28, 'https://flagcdn.com/ci.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (39, 'Iceland', 1, 'is_IS', 'IS', 'ISL', 'ISK', 'Europe', 'Northern Europe', 30, 'https://flagcdn.com/is.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (40, 'Paraguay', 1, 'es_PY', 'PY', 'PRY', 'PYG', 'Americas', 'South America', 16, 'https://flagcdn.com/py.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (41, 'Eswatini', 1, 'ss_SZ', 'SZ', 'SWZ', 'SZL', 'Africa', 'Southern Africa', 43, 'https://flagcdn.com/sz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (42, 'Hungary', 1, 'hu_HU', 'HU', 'HUN', 'HUF', 'Europe', 'Central Europe', 36, 'https://flagcdn.com/hu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (43, 'Heard Island and McDonald Islands', 1, '	en_AU', 'HM', 'HMD', '', 'Antarctic', '', 60, 'https://flagcdn.com/hm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (44, 'Moldova', 1, 'ro_MD', 'MD', 'MDA', 'MDL', 'Europe', 'Eastern Europe', 39, 'https://flagcdn.com/md.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (45, 'Chile', 1, 'es_CL', 'CL', 'CHL', 'CLP', 'Americas', 'South America', 19, 'https://flagcdn.com/cl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (46, 'Greenland', 1, 'kl_GL', 'GL', 'GRL', 'DKK', 'Americas', 'North America', 21, 'https://flagcdn.com/gl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (47, 'Nauru', 1, '	en_NR', 'NR', 'NRU', 'AUD', 'Oceania', 'Micronesia', 79, 'https://flagcdn.com/nr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (48, 'Uruguay', 1, 'es_UY', 'UY', 'URY', 'UYU', 'Americas', 'South America', 24, 'https://flagcdn.com/uy.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (49, 'Ecuador', 1, 'es_EC', 'EC', 'ECU', 'USD', 'Americas', 'South America', 12, 'https://flagcdn.com/ec.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (50, 'Sri Lanka', 1, 'si_LK', 'LK', 'LKA', 'LKR', 'Asia', 'Southern Asia', 57, 'https://flagcdn.com/lk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (51, 'Saint Pierre and Miquelon', 1, 'fr_FR', 'PM', 'SPM', 'EUR', 'Americas', 'North America', 25, 'https://flagcdn.com/pm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (52, 'Guatemala', 1, 'es_GT', 'GT', 'GTM', 'GTQ', 'Americas', 'Central America', 8, 'https://flagcdn.com/gt.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (53, 'Ghana', 1, 'ak_GH', 'GH', 'GHA', 'GHS', 'Africa', 'Western Africa', 28, 'https://flagcdn.com/gh.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (54, 'Israel', 1, 'he_IL', 'IL', 'ISR', 'ILS', 'Asia', 'Western Asia', 44, 'https://flagcdn.com/il.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (55, 'Mozambique', 1, '	pt_MZ', 'MZ', 'MOZ', 'MZN', 'Africa', 'Eastern Africa', 41, 'https://flagcdn.com/mz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (56, 'Bhutan', 1, 'dz_BT', 'BT', 'BTN', 'BTN', 'Asia', 'Southern Asia', 59, 'https://flagcdn.com/bt.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (57, 'Cayman Islands', 1, '	en_KY', 'KY', 'CYM', 'KYD', 'Americas', 'Caribbean', 13, 'https://flagcdn.com/ky.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (58, 'North Korea', 1, '	ko_KP', 'KP', 'PRK', 'KPW', 'Asia', 'Eastern Asia', 68, 'https://flagcdn.com/kp.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (59, 'Bahrain', 1, 'ar_BH', 'BH', 'BHR', 'BHD', 'Asia', 'Western Asia', 46, 'https://flagcdn.com/bh.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (60, 'Faroe Islands', 1, 'fo_FO', 'FO', 'FRO', 'DKK', 'Europe', 'Northern Europe', 32, 'https://flagcdn.com/fo.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (61, 'Aruba', 1, 'nl_AW', 'AW', 'ABW', 'AWG', 'Americas', 'Caribbean', 17, 'https://flagcdn.com/aw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (62, 'Iraq', 1, 'ar_IQ', 'IQ', 'IRQ', 'IQD', 'Asia', 'Western Asia', 48, 'https://flagcdn.com/iq.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (63, 'British Indian Ocean Territory', 1, '	en_IO', 'IO', 'IOT', 'USD', 'Africa', 'Eastern Africa', 58, 'https://flagcdn.com/io.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (64, 'Morocco', 1, 'ar_MA', 'MA', 'MAR', 'MAD', 'Africa', 'Northern Africa', 28, 'https://flagcdn.com/ma.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (65, 'North Macedonia', 1, 'mk_MK', 'MK', 'MKD', 'MKD', 'Europe', 'Southeast Europe', 36, 'https://flagcdn.com/mk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (66, 'Poland', 1, 'pl_PL', 'PL', 'POL', 'PLN', 'Europe', 'Central Europe', 36, 'https://flagcdn.com/pl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (67, 'Solomon Islands', 1, '	en_SB', 'SB', 'SLB', 'SBD', 'Oceania', 'Melanesia', 78, 'https://flagcdn.com/sb.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (68, 'Brazil', 1, 'pt_BR', 'BR', 'BRA', 'BRL', 'Americas', 'South America', 20, 'https://flagcdn.com/br.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (69, 'Slovenia', 1, 'sl_SI', 'SI', 'SVN', 'EUR', 'Europe', 'Central Europe', 36, 'https://flagcdn.com/si.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (70, 'Oman', 1, 'ar_OM', 'OM', 'OMN', 'OMR', 'Asia', 'Western Asia', 53, 'https://flagcdn.com/om.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (71, 'Thailand', 1, 'th_TH', 'TH', 'THA', 'THB', 'Asia', 'South-Eastern Asia', 61, 'https://flagcdn.com/th.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (72, 'Central African Republic', 1, '	fr_CF', 'CF', 'CAF', 'XAF', 'Africa', 'Middle Africa', 40, 'https://flagcdn.com/cf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (73, 'El Salvador', 1, 'es_SV', 'SV', 'SLV', 'USD', 'Americas', 'Central America', 13, 'https://flagcdn.com/sv.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (74, 'Armenia', 1, 'hy_AM', 'AM', 'ARM', 'AMD', 'Asia', 'Western Asia', 52, 'https://flagcdn.com/am.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (75, 'Honduras', 1, 'es_HN', 'HN', 'HND', 'HNL', 'Americas', 'Central America', 13, 'https://flagcdn.com/hn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (76, 'Zambia', 1, '	en_ZM', 'ZM', 'ZMB', 'ZMW', 'Africa', 'Eastern Africa', 40, 'https://flagcdn.com/zm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (77, 'Svalbard and Jan Mayen', 1, '	nb_SJ', 'SJ', 'SJM', 'NOK', 'Europe', 'Northern Europe', 32, 'https://flagcdn.com/sj.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (78, 'Luxembourg', 1, 'de_LU', 'LU', 'LUX', 'EUR', 'Europe', 'Western Europe', 32, 'https://flagcdn.com/lu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (79, 'Colombia', 1, 'es_CO', 'CO', 'COL', 'COP', 'Americas', 'South America', 15, 'https://flagcdn.com/co.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (80, 'Barbados', 1, '	en_BB', 'BB', 'BRB', 'BBD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/bb.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (81, 'Libya', 1, 'ar_LY', 'LY', 'LBY', 'LYD', 'Africa', 'Northern Africa', 40, 'https://flagcdn.com/ly.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (82, 'Serbia', 1, 'sr_RS', 'RS', 'SRB', 'RSD', 'Europe', 'Southeast Europe', 35, 'https://flagcdn.com/rs.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (83, 'Monaco', 1, 'fr_MC', 'MC', 'MCO', 'EUR', 'Europe', 'Western Europe', 33, 'https://flagcdn.com/mc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (84, 'Sweden', 1, 'sv_SE', 'SE', 'SWE', 'SEK', 'Europe', 'Northern Europe', 32, 'https://flagcdn.com/se.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (85, 'Niger', 1, 'ha_NE', 'NE', 'NER', 'XOF', 'Africa', 'Western Africa', 37, 'https://flagcdn.com/ne.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (86, 'Angola', 1, '	pt_AO', 'AO', 'AGO', 'AOA', 'Africa', 'Middle Africa', 37, 'https://flagcdn.com/ao.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (87, 'Panama', 1, 'es_PA', 'PA', 'PAN', 'PAB', 'Americas', 'Central America', 12, 'https://flagcdn.com/pa.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (88, 'Mauritius', 1, '	en_MU', 'MU', 'MUS', 'MUR', 'Africa', 'Eastern Africa', 53, 'https://flagcdn.com/mu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (89, 'Tanzania', 1, 'sw_TZ', 'TZ', 'TZA', 'TZS', 'Africa', 'Eastern Africa', 40, 'https://flagcdn.com/tz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (90, 'Mali', 1, 'bm_ML', 'ML', 'MLI', 'XOF', 'Africa', 'Western Africa', 28, 'https://flagcdn.com/ml.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (91, 'Cameroon', 1, '	mgo_CM', 'CM', 'CMR', 'XAF', 'Africa', 'Middle Africa', 37, 'https://flagcdn.com/cm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (92, 'Georgia', 1, 'ka_GE', 'GE', 'GEO', 'GEL', 'Asia', 'Western Asia', 51, 'https://flagcdn.com/ge.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (93, 'Gambia', 1, '	en_GM', 'GM', 'GMB', 'GMD', 'Africa', 'Western Africa', 28, 'https://flagcdn.com/gm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (94, 'Malta', 1, 'en_MT', 'MT', 'MLT', 'EUR', 'Europe', 'Southern Europe', 33, 'https://flagcdn.com/mt.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (95, 'American Samoa', 1, 'en_AS', 'AS', 'ASM', 'USD', 'Oceania', 'Polynesia', 84, 'https://flagcdn.com/as.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (96, 'Zimbabwe', 1, 'en_ZW', 'ZW', 'ZWE', 'ZWL', 'Africa', 'Southern Africa', 27, 'https://flagcdn.com/zw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (97, 'Belize', 1, 'en_BZ', 'BZ', 'BLZ', 'BZD', 'Americas', 'Central America', 8, 'https://flagcdn.com/bz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (98, 'Saint Kitts and Nevis', 1, '	en_KN', 'KN', 'KNA', 'XCD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/kn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (99, 'Vatican City', 1, '	it_VA', 'VA', 'VAT', 'EUR', 'Europe', 'Southern Europe', 33, 'https://flagcdn.com/va.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (100, 'Micronesia', 1, '	en_FM', 'FM', 'FSM', 'USD', 'Oceania', 'Micronesia', 75, 'https://flagcdn.com/fm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (101, 'Chad', 1, '	ar_TD', 'TD', 'TCD', 'XAF', 'Africa', 'Middle Africa', 40, 'https://flagcdn.com/td.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (102, 'Belarus', 1, 'be_BY', 'BY', 'BLR', 'BYN', 'Europe', 'Eastern Europe', 47, 'https://flagcdn.com/by.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (103, 'Canada', 1, 'en_CA', 'CA', 'CAN', 'CAD', 'Americas', 'North America', 10, 'https://flagcdn.com/ca.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (104, 'Argentina', 1, 'es_AR', 'AR', 'ARG', 'ARS', 'Americas', 'South America', 23, 'https://flagcdn.com/ar.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (105, 'Suriname', 1, '	nl_SR', 'SR', 'SUR', 'SRD', 'Americas', 'South America', 20, 'https://flagcdn.com/sr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (106, 'Australia', 1, 'en_AU', 'AU', 'AUS', 'AUD', 'Oceania', 'Australia and New Zealand', 66, 'https://flagcdn.com/au.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (107, 'Guinea', 1, 'kpe_GN', 'GN', 'GIN', 'GNF', 'Africa', 'Western Africa', 28, 'https://flagcdn.com/gn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (108, 'South Sudan', 1, '	nus_SS', 'SS', 'SSD', 'SSP', 'Africa', 'Middle Africa', 40, 'https://flagcdn.com/ss.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (109, 'Namibia', 1, 'af_NA', 'NA', 'NAM', 'NAD', 'Africa', 'Southern Africa', 43, 'https://flagcdn.com/na.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (110, 'Qatar', 1, 'ar_QA', 'QA', 'QAT', 'QAR', 'Asia', 'Western Asia', 48, 'https://flagcdn.com/qa.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (111, 'Myanmar', 1, 'my_MM', 'MM', 'MMR', 'MMK', 'Asia', 'South-Eastern Asia', 59, 'https://flagcdn.com/mm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (112, 'Falkland Islands', 1, '	en_FK', 'FK', 'FLK', 'FKP', 'Americas', 'South America', 23, 'https://flagcdn.com/fk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (113, 'Ireland', 1, 'en_IE', 'IE', 'IRL', 'EUR', 'Europe', 'Northern Europe', 30, 'https://flagcdn.com/ie.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (114, 'São Tomé and Príncipe', 1, '	pt_ST', 'ST', 'STP', 'STN', 'Africa', 'Middle Africa', 37, 'https://flagcdn.com/st.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (115, 'Bouvet Island', 1, '	nb_NO', 'BV', 'BVT', '', 'Antarctic', '', 37, 'https://flagcdn.com/bv.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (116, 'Lithuania', 1, 'lt_LT', 'LT', 'LTU', 'EUR', 'Europe', 'Northern Europe', 47, 'https://flagcdn.com/lt.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (117, 'DR Congo', 1, 'ln_CD', 'CD', 'COD', 'CDF', 'Africa', 'Middle Africa', 37, 'https://flagcdn.com/cd.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (118, 'Philippines', 1, 'en_PH', 'PH', 'PHL', 'PHP', 'Asia', 'South-Eastern Asia', 68, 'https://flagcdn.com/ph.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (119, 'Brunei', 1, 'ms_BN', 'BN', 'BRN', 'BND', 'Asia', 'South-Eastern Asia', 66, 'https://flagcdn.com/bn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (120, 'Sierra Leone', 1, '	en_SL', 'SL', 'SLE', 'SLL', 'Africa', 'Western Africa', 28, 'https://flagcdn.com/sl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (121, 'Mongolia', 1, 'mn_MN', 'MN', 'MNG', 'MNT', 'Asia', 'Eastern Asia', 64, 'https://flagcdn.com/mn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (122, 'Western Sahara', 1, '	ar_EH', 'EH', 'ESH', 'DZD', 'Africa', 'Northern Africa', 28, 'https://flagcdn.com/eh.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (123, 'Pitcairn Islands', 1, '	en_PN', 'PN', 'PCN', 'NZD', 'Oceania', 'Polynesia', 1, 'https://flagcdn.com/pn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (124, 'Sudan', 1, 'ar_SD', 'SD', 'SDN', 'SDG', 'Africa', 'Northern Africa', 40, 'https://flagcdn.com/sd.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (125, 'Timor-Leste', 1, '	pt_TL', 'TL', 'TLS', 'USD', 'Asia', 'South-Eastern Asia', 66, 'https://flagcdn.com/tl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (126, 'Anguilla', 1, '	en_AI', 'AI', 'AIA', 'XCD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/ai.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (127, 'Curaçao', 1, '	nl_CW', 'CW', 'CUW', 'ANG', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/cw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (128, 'Republic of the Congo', 1, 'ln_CG', 'CG', 'COG', 'XAF', 'Africa', 'Middle Africa', 37, 'https://flagcdn.com/cg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (129, 'Finland', 1, 'fi_FI', 'FI', 'FIN', 'EUR', 'Europe', 'Northern Europe', 39, 'https://flagcdn.com/fi.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (130, 'Austria', 1, 'de_AT', 'AT', 'AUT', 'EUR', 'Europe', 'Central Europe', 36, 'https://flagcdn.com/at.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (131, 'Ethiopia', 1, 'aa_ET', 'ET', 'ETH', 'ETB', 'Africa', 'Eastern Africa', 40, 'https://flagcdn.com/et.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (132, 'Saint Martin', 1, '	fr_MF', 'MF', 'MAF', 'EUR', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/mf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (133, 'Saint Vincent and the Grenadines', 1, '	en_VC', 'VC', 'VCT', 'XCD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/vc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (134, 'Bosnia and Herzegovina', 1, 'bs_BA', 'BA', 'BIH', 'BAM', 'Europe', 'Southeast Europe', 36, 'https://flagcdn.com/ba.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (135, 'Comoros', 1, '	fr_KM', 'KM', 'COM', 'KMF', 'Africa', 'Eastern Africa', 40, 'https://flagcdn.com/km.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (136, 'Caribbean Netherlands', 1, '	nl_BQ', 'BQ', 'BES', 'USD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/bq.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (137, 'Norway', 1, 'nb_NO', 'NO', 'NOR', 'NOK', 'Europe', 'Northern Europe', 32, 'https://flagcdn.com/no.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (138, 'Kuwait', 1, 'ar_KW', 'KW', 'KWT', 'KWD', 'Asia', 'Western Asia', 48, 'https://flagcdn.com/kw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (139, 'Burkina Faso', 1, '	fr_BF', 'BF', 'BFA', 'XOF', 'Africa', 'Western Africa', 28, 'https://flagcdn.com/bf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (140, 'Wallis and Futuna', 1, '	fr_WF', 'WF', 'WLF', 'XPF', 'Oceania', 'Polynesia', 80, 'https://flagcdn.com/wf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (141, 'Bangladesh', 1, 'bn_BD', 'BD', 'BGD', 'BDT', 'Asia', 'Southern Asia', 59, 'https://flagcdn.com/bd.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (142, 'Dominica', 1, '	en_DM', 'DM', 'DMA', 'XCD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/dm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (143, 'Jamaica', 1, 'en_JM', 'JM', 'JAM', 'JMD', 'Americas', 'Caribbean', 11, 'https://flagcdn.com/jm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (144, 'Andorra', 1, '	ca_AD', 'AD', 'AND', 'EUR', 'Europe', 'Southern Europe', 30, 'https://flagcdn.com/ad.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (145, 'Gibraltar', 1, '	en_GI', 'GI', 'GIB', 'GIP', 'Europe', 'Southern Europe', 30, 'https://flagcdn.com/gi.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (146, 'Malaysia', 1, 'ms_MY', 'MY', 'MYS', 'MYR', 'Asia', 'South-Eastern Asia', 67, 'https://flagcdn.com/my.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (147, 'United Kingdom', 1, 'en_GB', 'GB', 'GBR', 'GBP', 'Europe', 'Northern Europe', 30, 'https://flagcdn.com/gb.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (148, 'Madagascar', 1, '		en_MG', 'MG', 'MDG', 'MGA', 'Africa', 'Eastern Africa', 53, 'https://flagcdn.com/mg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (149, 'Switzerland', 2, 'de_CH', 'CH', 'CHE', 'CHF', 'Europe', 'Western Europe', 32, 'https://flagcdn.com/ch.svg', 1, 1, 1);
INSERT INTO `countries` VALUES (150, 'Tuvalu', 1, '	en_TV', 'TV', 'TUV', 'AUD', 'Oceania', 'Polynesia', 80, 'https://flagcdn.com/tv.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (151, 'Algeria', 1, 'ar_DZ', 'DZ', 'DZA', 'DZD', 'Africa', 'Northern Africa', 28, 'https://flagcdn.com/dz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (152, 'Russia', 1, 'ru_RU', 'RU', 'RUS', 'RUB', 'Europe', 'Eastern Europe', 47, 'https://flagcdn.com/ru.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (153, 'Vietnam', 1, 'vi_VN', 'VN', 'VNM', 'VND', 'Asia', 'South-Eastern Asia', 61, 'https://flagcdn.com/vn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (154, 'Cocos (Keeling) Islands', 1, '	en_CC', 'CC', 'CCK', 'AUD', 'Oceania', 'Australia and New Zealand', 59, 'https://flagcdn.com/cc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (155, 'Nepal', 1, 'ne_NP', 'NP', 'NPL', 'NPR', 'Asia', 'Southern Asia', 59, 'https://flagcdn.com/np.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (156, 'Netherlands', 1, 'nl_NL', 'NL', 'NLD', 'EUR', 'Europe', 'Western Europe', 32, 'https://flagcdn.com/nl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (157, 'Kiribati', 1, '	en_KI', 'KI', 'KIR', 'AUD', 'Oceania', 'Micronesia', 75, 'https://flagcdn.com/ki.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (158, 'Liberia', 1, 'kpe_LR', 'LR', 'LBR', 'LRD', 'Africa', 'Western Africa', 29, 'https://flagcdn.com/lr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (159, 'Somalia', 1, 'so_SO', 'SO', 'SOM', 'SOS', 'Africa', 'Eastern Africa', 48, 'https://flagcdn.com/so.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (160, 'Romania', 1, 'ro_RO', 'RO', 'ROU', 'RON', 'Europe', 'Southeast Europe', 36, 'https://flagcdn.com/ro.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (161, 'Marshall Islands', 1, 'en_MH', 'MH', 'MHL', 'USD', 'Oceania', 'Micronesia', 75, 'https://flagcdn.com/mh.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (162, 'Spain', 1, 'ca_ES', 'ES', 'ESP', 'EUR', 'Europe', 'Southern Europe', 30, 'https://flagcdn.com/es.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (163, 'United States', 1, 'en_US', 'US', 'USA', 'USD', 'Americas', 'North America', 8, 'https://flagcdn.com/us.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (164, 'Réunion', 1, '	fr_RE', 'RE', 'REU', 'EUR', 'Africa', 'Eastern Africa', 53, 'https://flagcdn.com/re.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (165, 'Singapore', 1, 'en_SG', 'SG', 'SGP', 'SGD', 'Asia', 'South-Eastern Asia', 67, 'https://flagcdn.com/sg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (166, 'Tunisia', 1, 'ar_TN', 'TN', 'TUN', 'TND', 'Africa', 'Northern Africa', 40, 'https://flagcdn.com/tn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (167, 'Azerbaijan', 1, 'az_AZ', 'AZ', 'AZE', 'AZN', 'Asia', 'Western Asia', 48, 'https://flagcdn.com/az.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (168, 'Papua New Guinea', 1, '	en_PG', 'PG', 'PNG', 'PGK', 'Oceania', 'Melanesia', 75, 'https://flagcdn.com/pg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (169, 'Lesotho', 1, 'st_LS', 'LS', 'LSO', 'LSL', 'Africa', 'Southern Africa', 43, 'https://flagcdn.com/ls.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (170, 'Bahamas', 1, '	en_BS', 'BS', 'BHS', 'BSD', 'Americas', 'Caribbean', 11, 'https://flagcdn.com/bs.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (171, 'China', 1, 'bo_CN', 'CN', 'CHN', 'CNY', 'Asia', 'Eastern Asia', 65, 'https://flagcdn.com/cn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (172, 'Mayotte', 1, '	fr_YT', 'YT', 'MYT', 'EUR', 'Africa', 'Eastern Africa', 40, 'https://flagcdn.com/yt.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (173, 'Senegal', 1, 'fr_SN', 'SN', 'SEN', 'XOF', 'Africa', 'Western Africa', 28, 'https://flagcdn.com/sn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (174, 'Cyprus', 1, 'el_CY', 'CY', 'CYP', 'EUR', 'Europe', 'Southern Europe', 44, 'https://flagcdn.com/cy.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (175, 'United Arab Emirates', 1, 'ar_AE', 'AE', 'ARE', 'AED', 'Asia', 'Western Asia', 53, 'https://flagcdn.com/ae.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (176, 'Turkmenistan', 1, '	tk_TM', 'TM', 'TKM', 'TMT', 'Asia', 'Central Asia', 56, 'https://flagcdn.com/tm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (177, 'Laos', 1, 'lo_LA', 'LA', 'LAO', 'LAK', 'Asia', 'South-Eastern Asia', 61, 'https://flagcdn.com/la.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (178, 'Belgium', 1, 'de_BE', 'BE', 'BEL', 'EUR', 'Europe', 'Western Europe', 32, 'https://flagcdn.com/be.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (179, 'Jordan', 1, 'ar_JO', 'JO', 'JOR', 'JOD', 'Asia', 'Western Asia', 42, 'https://flagcdn.com/jo.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (180, 'Palestine', 1, '	ar_PS', 'PS', 'PSE', 'EGP', 'Asia', 'Western Asia', 54, 'https://flagcdn.com/ps.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (181, 'Seychelles', 1, '	en_SC', 'SC', 'SYC', 'SCR', 'Africa', 'Eastern Africa', 53, 'https://flagcdn.com/sc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (182, 'Uzbekistan', 1, 'uz_UZ', 'UZ', 'UZB', 'UZS', 'Asia', 'Central Asia', 56, 'https://flagcdn.com/uz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (183, 'New Caledonia', 1, '	fr_NC', 'NC', 'NCL', 'XPF', 'Oceania', 'Melanesia', 80, 'https://flagcdn.com/nc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (184, 'Åland Islands', 1, '	sv_AX', 'AX', 'ALA', 'EUR', 'Europe', 'Northern Europe', 32, 'https://flagcdn.com/ax.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (185, 'Nicaragua', 1, 'es_NI', 'NI', 'NIC', 'NIO', 'Americas', 'Central America', 8, 'https://flagcdn.com/ni.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (186, 'Guam', 1, 'en_GU', 'GU', 'GUM', 'USD', 'Oceania', 'Micronesia', 75, 'https://flagcdn.com/gu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (187, 'Kenya', 1, 'kam_KE', 'KE', 'KEN', 'KES', 'Africa', 'Eastern Africa', 49, 'https://flagcdn.com/ke.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (188, 'French Polynesia', 1, '	fr_PF', 'PF', 'PYF', 'XPF', 'Oceania', 'Polynesia', 1, 'https://flagcdn.com/pf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (189, 'Jersey', 1, '	en_JE', 'JE', 'JEY', 'GBP', 'Europe', 'Northern Europe', 33, 'https://flagcdn.com/je.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (190, 'Czechia', 1, 'cs_CZ', 'CZ', 'CZE', 'CZK', 'Europe', 'Central Europe', 36, 'https://flagcdn.com/cz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (191, 'Uganda', 1, '	lg_UG', 'UG', 'UGA', 'UGX', 'Africa', 'Eastern Africa', 40, 'https://flagcdn.com/ug.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (192, 'New Zealand', 1, 'en_NZ', 'NZ', 'NZL', 'NZD', 'Oceania', 'Australia and New Zealand', 82, 'https://flagcdn.com/nz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (193, 'Montserrat', 1, '	en_MS', 'MS', 'MSR', 'XCD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/ms.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (194, 'Saint Barthélemy', 1, '	fr_BL', 'BL', 'BLM', 'EUR', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/bl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (195, 'Costa Rica', 1, 'es_CR', 'CR', 'CRI', 'CRC', 'Americas', 'Central America', 8, 'https://flagcdn.com/cr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (196, 'Mexico', 1, 'es_MX', 'MX', 'MEX', 'MXN', 'Americas', 'North America', 11, 'https://flagcdn.com/mx.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (197, 'Eritrea', 1, 'aa_ER', 'ER', 'ERI', 'ERN', 'Africa', 'Eastern Africa', 40, 'https://flagcdn.com/er.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (198, 'Grenada', 1, '	en_GD', 'GD', 'GRD', 'XCD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/gd.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (199, 'Antigua and Barbuda', 1, '	en_AG', 'AG', 'ATG', 'XCD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/ag.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (200, 'Japan', 1, 'ja_JP', 'JP', 'JPN', 'JPY', 'Asia', 'Eastern Asia', 71, 'https://flagcdn.com/jp.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (201, 'Slovakia', 1, 'sk_SK', 'SK', 'SVK', 'EUR', 'Europe', 'Central Europe', 36, 'https://flagcdn.com/sk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (202, 'United States Virgin Islands', 1, 'en_VI', 'VI', 'VIR', 'USD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/vi.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (203, 'Kosovo', 1, '	sq_XK', 'XK', 'UNK', 'EUR', 'Europe', 'Southeast Europe', 36, 'https://flagcdn.com/xk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (204, 'Vanuatu', 1, '	en_VU', 'VU', 'VUT', 'VUV', 'Oceania', 'Melanesia', 80, 'https://flagcdn.com/vu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (205, 'Palau', 1, '	en_PW', 'PW', 'PLW', 'USD', 'Oceania', 'Micronesia', 75, 'https://flagcdn.com/pw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (206, 'Botswana', 1, 'en_BW', 'BW', 'BWA', 'BWP', 'Africa', 'Southern Africa', 43, 'https://flagcdn.com/bw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (207, 'Tonga', 1, 'to_TO', 'TO', 'TON', 'TOP', 'Oceania', 'Polynesia', 80, 'https://flagcdn.com/to.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (208, 'Fiji', 1, '	en_FJ', 'FJ', 'FJI', 'FJD', 'Oceania', 'Melanesia', 80, 'https://flagcdn.com/fj.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (209, 'France', 1, 'fr_FR', 'FR', 'FRA', 'EUR', 'Europe', 'Western Europe', 30, 'https://flagcdn.com/fr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (210, 'Albania', 1, 'sq_AL', 'AL', 'ALB', 'ALL', 'Europe', 'Southeast Europe', 36, 'https://flagcdn.com/al.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (211, 'Portugal', 1, 'pt_PT', 'PT', 'PRT', 'EUR', 'Europe', 'Southern Europe', 30, 'https://flagcdn.com/pt.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (212, 'Niue', 1, '	en_NU', 'NU', 'NIU', 'NZD', 'Oceania', 'Polynesia', 1, 'https://flagcdn.com/nu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (213, 'Peru', 1, 'es_PE', 'PE', 'PER', 'PEN', 'Americas', 'South America', 16, 'https://flagcdn.com/pe.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (214, 'Indonesia', 1, 'id_ID', 'ID', 'IDN', 'IDR', 'Asia', 'South-Eastern Asia', 61, 'https://flagcdn.com/id.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (215, 'Saint Lucia', 1, '	en_LC', 'LC', 'LCA', 'XCD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/lc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (216, 'Guernsey', 1, '	en_GG', 'GG', 'GGY', 'GBP', 'Europe', 'Northern Europe', 30, 'https://flagcdn.com/gg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (217, 'Kyrgyzstan', 1, 'ky_KG', 'KG', 'KGZ', 'KGS', 'Asia', 'Central Asia', 56, 'https://flagcdn.com/kg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (218, 'Germany', 1, 'de_DE', 'DE', 'DEU', 'EUR', 'Europe', 'Western Europe', 32, 'https://flagcdn.com/de.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (219, 'Bolivia', 1, 'es_BO', 'BO', 'BOL', 'BOB', 'Americas', 'South America', 16, 'https://flagcdn.com/bo.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (220, 'Dominican Republic', 1, 'es_DO', 'DO', 'DOM', 'DOP', 'Americas', 'Caribbean', 11, 'https://flagcdn.com/do.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (221, 'Puerto Rico', 1, 'es_PR', 'PR', 'PRI', 'USD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/pr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (222, 'Lebanon', 1, 'ar_LB', 'LB', 'LBN', 'LBP', 'Asia', 'Western Asia', 45, 'https://flagcdn.com/lb.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (223, 'Maldives', 1, 'dv_MV', 'MV', 'MDV', 'MVR', 'Asia', 'Southern Asia', 57, 'https://flagcdn.com/mv.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (224, 'San Marino', 1, '	it_SM', 'SM', 'SMR', 'EUR', 'Europe', 'Southern Europe', 32, 'https://flagcdn.com/sm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (225, 'South Korea', 1, 'ko_KR', 'KR', 'KOR', 'KRW', 'Asia', 'Eastern Asia', 70, 'https://flagcdn.com/kr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (226, 'Norfolk Island', 1, '	en_NF', 'NF', 'NFK', 'AUD', 'Oceania', 'Australia and New Zealand', 80, 'https://flagcdn.com/nf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (227, 'Syria', 1, 'ar_SY', 'SY', 'SYR', 'SYP', 'Asia', 'Western Asia', 48, 'https://flagcdn.com/sy.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (228, 'Afghanistan', 1, 'fa_AF', 'AF', 'AFG', 'AFN', 'Asia', 'Southern Asia', 57, 'https://upload.wikimedia.org/wikipedia/commons/5/5c/Flag_of_the_Taliban.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (229, 'Malawi', 1, 'ny_MW', 'MW', 'MWI', 'MWK', 'Africa', 'Eastern Africa', 40, 'https://flagcdn.com/mw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (230, 'Tajikistan', 1, 'tg_TJ', 'TJ', 'TJK', 'TJS', 'Asia', 'Central Asia', 57, 'https://flagcdn.com/tj.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (231, 'Turkey', 1, 'ku_TR', 'TR', 'TUR', 'TRY', 'Asia', 'Western Asia', 39, 'https://flagcdn.com/tr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (232, 'Equatorial Guinea', 1, '	es_GQ', 'GQ', 'GNQ', 'XAF', 'Africa', 'Middle Africa', 37, 'https://flagcdn.com/gq.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (233, 'Turks and Caicos Islands', 1, '	en_TC', 'TC', 'TCA', 'USD', 'Americas', 'Caribbean', 11, 'https://flagcdn.com/tc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (234, 'India', 1, 'as_IN', 'IN', 'IND', 'INR', 'Asia', 'Southern Asia', 57, 'https://flagcdn.com/in.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (235, 'Nigeria', 1, 'cch_NG', 'NG', 'NGA', 'NGN', 'Africa', 'Western Africa', 34, 'https://flagcdn.com/ng.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (236, 'Pakistan', 1, 'en_PK', 'PK', 'PAK', 'PKR', 'Asia', 'Southern Asia', 57, 'https://flagcdn.com/pk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (237, 'Latvia', 1, 'lv_LV', 'LV', 'LVA', 'EUR', 'Europe', 'Northern Europe', 39, 'https://flagcdn.com/lv.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (238, 'Iran', 1, 'fa_IR', 'IR', 'IRN', 'IRR', 'Asia', 'Southern Asia', 48, 'https://flagcdn.com/ir.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (239, 'Cape Verde', 1, '	kea_CV', 'CV', 'CPV', 'CVE', 'Africa', 'Western Africa', 26, 'https://flagcdn.com/cv.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (240, 'French Southern and Antarctic Lands', 1, '	fr', 'TF', 'ATF', 'EUR', 'Antarctic', '', 55, 'https://flagcdn.com/tf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (241, 'Bulgaria', 1, 'bg_BG', 'BG', 'BGR', 'BGN', 'Europe', 'Southeast Europe', 36, 'https://flagcdn.com/bg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (242, 'Estonia', 1, 'et_EE', 'EE', 'EST', 'EUR', 'Europe', 'Northern Europe', 39, 'https://flagcdn.com/ee.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (243, 'Christmas Island', 1, '	en_CX', 'CX', 'CXR', 'AUD', 'Oceania', 'Australia and New Zealand', 61, 'https://flagcdn.com/cx.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (244, 'Haiti', 1, '	fr_HT', 'HT', 'HTI', 'HTG', 'Americas', 'Caribbean', 11, 'https://flagcdn.com/ht.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (245, 'Saint Helena, Ascension and Tristan da Cunha', 1, '	en_GB', 'SH', 'SHN', 'GBP', 'Africa', 'Western Africa', 28, 'https://flagcdn.com/sh.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (246, 'Isle of Man', 1, '	en_IM', 'IM', 'IMN', 'GBP', 'Europe', 'Northern Europe', 30, 'https://flagcdn.com/im.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (247, 'Gabon', 1, '	fr_GA', 'GA', 'GAB', 'XAF', 'Africa', 'Middle Africa', 37, 'https://flagcdn.com/ga.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (248, 'Guyana', 1, '	en_GY', 'GY', 'GUY', 'GYD', 'Americas', 'South America', 29, 'https://flagcdn.com/gy.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (249, 'Saudi Arabia', 1, 'ar_SA', 'SA', 'SAU', 'SAR', 'Asia', 'Western Asia', 48, 'https://flagcdn.com/sa.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (250, 'Trinidad and Tobago', 1, 'en_TT', 'TT', 'TTO', 'TTD', 'Americas', 'Caribbean', 15, 'https://flagcdn.com/tt.svg', 0, 0, 0);

-- ----------------------------
-- Table structure for countries_trans
-- ----------------------------
DROP TABLE IF EXISTS `countries_trans`;
CREATE TABLE `countries_trans`  (
  `intCountryTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intCountryID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strCountryName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`intCountryTransID`) USING BTREE,
  INDEX `_intCountryID`(`intCountryID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_ct_countries` FOREIGN KEY (`intCountryID`) REFERENCES `countries` (`intCountryID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_ct_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of countries_trans
-- ----------------------------

-- ----------------------------
-- Table structure for currencies
-- ----------------------------
DROP TABLE IF EXISTS `currencies`;
CREATE TABLE `currencies`  (
  `intCurrencyID` int(11) NOT NULL AUTO_INCREMENT,
  `strCurrencyISO` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strCurrencyEN` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strCurrency` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strCurrencySign` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intPrio` int(11) NOT NULL,
  `blnDefault` tinyint(1) NOT NULL DEFAULT 0,
  `blnActive` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intCurrencyID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of currencies
-- ----------------------------
INSERT INTO `currencies` VALUES (3, 'CHF', 'CHF', 'CHF', 'CHF', 1, 1, 1);

-- ----------------------------
-- Table structure for custom_mappings
-- ----------------------------
DROP TABLE IF EXISTS `custom_mappings`;
CREATE TABLE `custom_mappings`  (
  `intCustomMappingID` int(11) NOT NULL AUTO_INCREMENT,
  `strMapping` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strPath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `blnOnlyAdmin` tinyint(1) NOT NULL DEFAULT 0,
  `blnOnlySuperAdmin` tinyint(1) NOT NULL DEFAULT 0,
  `blnOnlySysAdmin` tinyint(1) NOT NULL DEFAULT 0,
  `intModuleID` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`intCustomMappingID`) USING BTREE,
  UNIQUE INDEX `_strMapping`(`strMapping`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_cm_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of custom_mappings
-- ----------------------------
INSERT INTO `custom_mappings` VALUES (11, 'admin/industries', 'backend/myapp/views/admin/industries.cfm', 0, 0, 1, NULL);
INSERT INTO `custom_mappings` VALUES (12, 'admin/contract-types', 'backend/myapp/views/admin/contract_types.cfm', 0, 0, 1, NULL);
INSERT INTO `custom_mappings` VALUES (13, 'admin/job-positions', 'backend/myapp/views/admin/job_positions.cfm', 0, 0, 1, NULL);
INSERT INTO `custom_mappings` VALUES (14, 'admin/ads', 'backend/myapp/views/admin/ads.cfm', 0, 0, 1, NULL);
INSERT INTO `custom_mappings` VALUES (15, 'admin/handler/ads', 'backend/myapp/handler/admin/ads.cfm', 0, 0, 1, NULL);
INSERT INTO `custom_mappings` VALUES (16, 'admin/handler/contract-types', 'backend/myapp/handler/admin/contract_types.cfm', 0, 0, 1, NULL);
INSERT INTO `custom_mappings` VALUES (17, 'admin/handler/job-positions', 'backend/myapp/handler/admin/job_positions.cfm', 0, 0, 1, NULL);
INSERT INTO `custom_mappings` VALUES (18, 'admin/handler/industries', 'backend/myapp/handler/admin/industries.cfm', 0, 0, 1, NULL);
INSERT INTO `custom_mappings` VALUES (19, 'employee/profile', 'backend/myapp/views/employee/profile.cfm', 0, 0, 0, NULL);
INSERT INTO `custom_mappings` VALUES (20, 'handler/profile', 'backend/myapp/handler/profile.cfm', 0, 0, 0, NULL);
INSERT INTO `custom_mappings` VALUES (21, 'employee/ads/new', 'backend/myapp/views/employee/ads_new.cfm', 0, 0, 0, NULL);
INSERT INTO `custom_mappings` VALUES (22, 'handler/ads', 'backend/myapp/handler/ads.cfm', 0, 0, 0, NULL);
INSERT INTO `custom_mappings` VALUES (23, 'employee/ads/edit', 'backend/myapp/views/employee/ads_edit.cfm', 0, 0, 0, NULL);
INSERT INTO `custom_mappings` VALUES (24, 'employee/ads/settings', 'backend/myapp/views/employee/settings.cfm', 0, 0, 0, NULL);
INSERT INTO `custom_mappings` VALUES (25, 'employer/profile', 'backend/myapp/views/employer/profile.cfm', 0, 0, 0, NULL);
INSERT INTO `custom_mappings` VALUES (26, 'employer/ads', 'backend/myapp/views/employer/ads.cfm', 0, 0, 0, NULL);
INSERT INTO `custom_mappings` VALUES (27, 'employer/ads/new', 'backend/myapp/views/employer/ads_new.cfm', 0, 0, 0, NULL);
INSERT INTO `custom_mappings` VALUES (28, 'employer/ads/archive', 'backend/myapp/views/employer/ads_archive.cfm', 0, 0, 0, NULL);
INSERT INTO `custom_mappings` VALUES (29, 'employer/ads/edit', 'backend/myapp/views/employer/ads_edit.cfm', 0, 0, 0, NULL);
INSERT INTO `custom_mappings` VALUES (30, 'admin/worker-profiles', 'backend/myapp/views/admin/worker_profiles.cfm', 0, 0, 1, NULL);
INSERT INTO `custom_mappings` VALUES (31, 'admin/handler/worker', 'backend/myapp/handler/admin/worker.cfm', 0, 0, 1, NULL);

-- ----------------------------
-- Table structure for custom_translations
-- ----------------------------
DROP TABLE IF EXISTS `custom_translations`;
CREATE TABLE `custom_translations`  (
  `intCustTransID` int(11) NOT NULL AUTO_INCREMENT,
  `strVariable` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strStringDE` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strStringEN` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`intCustTransID`) USING BTREE,
  UNIQUE INDEX `_strVariable`(`strVariable`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of custom_translations
-- ----------------------------

-- ----------------------------
-- Table structure for customer_user
-- ----------------------------
DROP TABLE IF EXISTS `customer_user`;
CREATE TABLE `customer_user`  (
  `intCustUserID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NULL DEFAULT NULL,
  `intUserID` int(11) NULL DEFAULT NULL,
  `blnStandard` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intCustUserID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intUserID`(`intUserID`) USING BTREE,
  CONSTRAINT `frn_cu_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cu_users` FOREIGN KEY (`intUserID`) REFERENCES `users` (`intUserID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of customer_user
-- ----------------------------
INSERT INTO `customer_user` VALUES (1, 1, 1, 1);
INSERT INTO `customer_user` VALUES (2, 2, 2, 1);
INSERT INTO `customer_user` VALUES (3, 3, 3, 1);
INSERT INTO `customer_user` VALUES (4, 4, 4, 1);
INSERT INTO `customer_user` VALUES (5, 5, 5, 1);
INSERT INTO `customer_user` VALUES (6, 6, 6, 1);

-- ----------------------------
-- Table structure for customers
-- ----------------------------
DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers`  (
  `intCustomerID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustParentID` int(11) NOT NULL DEFAULT 0,
  `dtmInsertDate` datetime NOT NULL,
  `dtmMutDate` datetime NOT NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 0,
  `strCompanyName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strContactPerson` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strAddress` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strAddress2` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strZIP` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strCity` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intCountryID` int(11) NULL DEFAULT 1,
  `intTimezoneID` smallint(6) NULL DEFAULT NULL,
  `strPhone` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strEmail` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strWebsite` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strLogo` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strBillingAccountName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strBillingEmail` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strBillingAddress` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strBillingInfo` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`intCustomerID`) USING BTREE,
  UNIQUE INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intCountryID`(`intCountryID`) USING BTREE,
  FULLTEXT INDEX `FulltextStrings`(`strCompanyName`, `strContactPerson`, `strAddress`, `strZIP`, `strCity`, `strEmail`)
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of customers
-- ----------------------------
INSERT INTO `customers` VALUES (1, 0, '2024-05-07 14:38:29', '2024-05-14 15:13:39', 1, 'PAWECO GmbH', 'Patirck Trüssel', 'Bösch 63', '', '6331', 'Hünenberg', 149, 32, '', 'info@paweco.ch', '', '16441dbb7114403398d8812f9edc5cc8.png', '', '', '', '');
INSERT INTO `customers` VALUES (2, 0, '2024-05-28 06:48:17', '2024-05-29 13:52:46', 1, 'PAWECO GmbH', 'Patrick Trüssel', 'Haldenrain 20', 'Haus 5', '6205', 'Eich', 149, 32, '', 'pt@paweco.ch', '', 'd6c27ef4d8c04ddf8766a20459e53103.png', '', '', '', '');
INSERT INTO `customers` VALUES (3, 0, '2024-07-11 14:26:31', '2024-07-12 08:20:11', 1, '', 'Hans Müller', 'Teststrasse', '', '5555', 'St. Glück', 149, 32, '', 'hans@mueller.com', '', NULL, '', '', '', '');
INSERT INTO `customers` VALUES (4, 0, '2024-07-12 15:08:50', '2024-07-12 15:09:48', 1, '', 'Franziska Ritter', 'Haldenrain 20', '', '6205', 'Eich', 149, 32, '', 'fr@paweco.ch', '', NULL, '', '', '', '');
INSERT INTO `customers` VALUES (5, 0, '2024-07-12 15:14:06', '2024-07-15 14:57:53', 1, 'Meyer Transporte AG', 'Mike Meyer', 'Teststrasse', '', '4444', 'Hünenberg', 149, 32, '', 'mike@meyer.ch', '', NULL, 'Meyer Transporte AG', 'invoice@meyer.ch', 'Teststrasse\r\n4444 Hünenberg', '');
INSERT INTO `customers` VALUES (6, 0, '2024-07-12 15:40:20', '2024-07-12 16:01:57', 1, '', 'Paul Lötscher', 'Glücklichstrasse 55', '', '562589', 'St. Glück', 149, 32, '', 'p@loetscher.ch', '', NULL, '', '', '', '');

-- ----------------------------
-- Table structure for frontend_mappings
-- ----------------------------
DROP TABLE IF EXISTS `frontend_mappings`;
CREATE TABLE `frontend_mappings`  (
  `intFrontendMappingsID` int(11) NOT NULL AUTO_INCREMENT,
  `strMapping` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strMetatitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strMetadescription` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strhtmlcodes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`intFrontendMappingsID`) USING BTREE,
  UNIQUE INDEX `_strMapping`(`strMapping`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of frontend_mappings
-- ----------------------------
INSERT INTO `frontend_mappings` VALUES (1, 'login', 'frontend/login.cfm', '', '', '');
INSERT INTO `frontend_mappings` VALUES (2, 'register', 'frontend/register.cfm', '', '', '');
INSERT INTO `frontend_mappings` VALUES (3, 'password', 'frontend/password.cfm', '', '', '');
INSERT INTO `frontend_mappings` VALUES (4, 'plans', 'frontend/plans.cfm', '', '', '');
INSERT INTO `frontend_mappings` VALUES (5, 'mfa', 'frontend/mfa.cfm', '', '', '');
INSERT INTO `frontend_mappings` VALUES (6, 'fachkraefte-suchen', 'frontend/spec_search.cfm', 'Fachkräfte suchen', 'Fachkräfte suchen', '');
INSERT INTO `frontend_mappings` VALUES (7, 'stelle-suchen', 'frontend/job_search.cfm', 'Stelle suchen', 'Stelle suchen', '');

-- ----------------------------
-- Table structure for frontend_mappings_trans
-- ----------------------------
DROP TABLE IF EXISTS `frontend_mappings_trans`;
CREATE TABLE `frontend_mappings_trans`  (
  `intfrontend_mappings_transID` int(11) NOT NULL AUTO_INCREMENT,
  `intFrontendMappingsID` int(11) NULL DEFAULT NULL,
  `strMapping` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strMetatitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strMetadescription` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strhtmlcodes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `intLanguageID` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`intfrontend_mappings_transID`) USING BTREE,
  UNIQUE INDEX `_strMapping`(`strMapping`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of frontend_mappings_trans
-- ----------------------------

-- ----------------------------
-- Table structure for invoice_positions
-- ----------------------------
DROP TABLE IF EXISTS `invoice_positions`;
CREATE TABLE `invoice_positions`  (
  `intInvoicePosID` int(11) NOT NULL AUTO_INCREMENT,
  `intInvoiceID` int(11) NOT NULL,
  `intPosNumber` int(11) NULL DEFAULT NULL,
  `strTitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `decSinglePrice` decimal(10, 2) NULL DEFAULT NULL,
  `decQuantity` decimal(10, 2) NULL DEFAULT NULL,
  `strUnit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intDiscountPercent` decimal(10, 2) NULL DEFAULT NULL,
  `decTotalPrice` decimal(10, 2) NULL DEFAULT NULL,
  `decVat` decimal(10, 2) NULL DEFAULT NULL,
  PRIMARY KEY (`intInvoicePosID`) USING BTREE,
  INDEX `_intInvoiceID`(`intInvoiceID`) USING BTREE,
  CONSTRAINT `frn_pos_invoice` FOREIGN KEY (`intInvoiceID`) REFERENCES `invoices` (`intInvoiceID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of invoice_positions
-- ----------------------------
INSERT INTO `invoice_positions` VALUES (1, 1, 1, 'FINDEN LASSEN! 12.07.2024 - 12.08.2024', '', 39.90, 1.00, 'Monat', 0.00, 39.90, 8.10);
INSERT INTO `invoice_positions` VALUES (2, 2, 1, 'Projektleiter/in Herstellung, befristet für 12 Monate', 'Inserat vom 12.07.2024bis 08.01.2025', 170.00, 1.00, '', 0.00, 170.00, 8.10);
INSERT INTO `invoice_positions` VALUES (3, 3, 1, 'FINDEN LASSEN! 12.07.2024 - 12.08.2024', '', 39.90, 1.00, 'Monat', 0.00, 39.90, 8.10);
INSERT INTO `invoice_positions` VALUES (4, 4, 1, 'Sachbearbeitung Sozialdienste (m/w/d)', 'Inserat vom 15.07.2024bis 11.01.2025', 170.00, 1.00, '', 0.00, 170.00, 8.10);

-- ----------------------------
-- Table structure for invoice_status
-- ----------------------------
DROP TABLE IF EXISTS `invoice_status`;
CREATE TABLE `invoice_status`  (
  `intPaymentStatusID` int(11) NOT NULL AUTO_INCREMENT,
  `strInvoiceStatusVariable` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strColor` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`intPaymentStatusID`) USING BTREE,
  UNIQUE INDEX `_intPaymentStatusID`(`intPaymentStatusID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of invoice_status
-- ----------------------------
INSERT INTO `invoice_status` VALUES (1, 'statInvoiceDraft', 'muted');
INSERT INTO `invoice_status` VALUES (2, 'statInvoiceOpen', 'blue');
INSERT INTO `invoice_status` VALUES (3, 'statInvoicePaid', 'green');
INSERT INTO `invoice_status` VALUES (4, 'statInvoicePartPaid', 'orange');
INSERT INTO `invoice_status` VALUES (5, 'statInvoiceCanceled', 'purple');
INSERT INTO `invoice_status` VALUES (6, 'statInvoiceOverDue', 'red');

-- ----------------------------
-- Table structure for invoice_vat
-- ----------------------------
DROP TABLE IF EXISTS `invoice_vat`;
CREATE TABLE `invoice_vat`  (
  `intInvoiceVatID` int(11) NOT NULL AUTO_INCREMENT,
  `intInvoiceID` int(11) NOT NULL,
  `decVat` decimal(10, 2) NOT NULL,
  `strVatText` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `decVatAmount` decimal(10, 2) NOT NULL,
  PRIMARY KEY (`intInvoiceVatID`) USING BTREE,
  INDEX `_intInvoiceID`(`intInvoiceID`) USING BTREE,
  CONSTRAINT `frn_invoice_vat` FOREIGN KEY (`intInvoiceID`) REFERENCES `invoices` (`intInvoiceID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of invoice_vat
-- ----------------------------

-- ----------------------------
-- Table structure for invoices
-- ----------------------------
DROP TABLE IF EXISTS `invoices`;
CREATE TABLE `invoices`  (
  `intInvoiceID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intUserID` int(11) NULL DEFAULT NULL,
  `intInvoiceNumber` int(11) NOT NULL,
  `strPrefix` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strInvoiceTitle` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dtmInvoiceDate` datetime NOT NULL,
  `dtmDueDate` datetime NOT NULL,
  `strCurrency` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `blnIsNet` tinyint(1) NOT NULL DEFAULT 1,
  `intVatType` int(1) NOT NULL COMMENT '1=incl; 2=excl; 3=no vat',
  `decSubTotalPrice` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `decTotalPrice` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `strTotalText` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intPaymentStatusID` int(11) NOT NULL DEFAULT 1,
  `strLanguageISO` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intBookingID` int(11) NULL DEFAULT 0,
  `strUUID` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intInvoiceID`) USING BTREE,
  UNIQUE INDEX `_intInvoiceID`(`intInvoiceID`) USING BTREE,
  UNIQUE INDEX `_intInvoiceNumber`(`intInvoiceNumber`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intPaymentStatusID`(`intPaymentStatusID`) USING BTREE,
  FULLTEXT INDEX `FulltextStrings`(`strInvoiceTitle`, `strCurrency`),
  CONSTRAINT `frn_inv_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_inv_invstat` FOREIGN KEY (`intPaymentStatusID`) REFERENCES `invoice_status` (`intPaymentStatusID`) ON DELETE RESTRICT ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of invoices
-- ----------------------------
INSERT INTO `invoices` VALUES (1, 3, NULL, 1000, 'INV-', 'Upgrade: FINDEN LASSEN!', '2024-07-12 13:34:55', '2024-07-12 13:34:55', 'CHF', 0, 3, 39.90, 39.90, 'Betrag von Steuer befreit', 3, 'de', 19, '8f5997a2f0c8436a8a971d6b8794448741853c1fbd074e448e284caae033413b');
INSERT INTO `invoices` VALUES (2, 2, 2, 1001, 'INV-', 'Ihr Inserat auf Stellensuche.ch', '2024-07-12 00:00:00', '2024-07-22 00:00:00', 'CHF', 0, 3, 170.00, 170.00, 'Betrag von Steuer befreit', 2, 'de', 0, NULL);
INSERT INTO `invoices` VALUES (3, 4, NULL, 1002, 'INV-', 'Plan: FINDEN LASSEN!', '2024-07-12 15:09:33', '2024-07-12 15:09:33', 'CHF', 0, 3, 39.90, 39.90, 'Betrag von Steuer befreit', 3, 'de', 20, '1d13235a21744df88ba035b274f1fc2deb0eed16e3964975a917e53b6daba775');
INSERT INTO `invoices` VALUES (4, 5, 5, 1003, 'INV-', 'Ihr Inserat auf Stellensuche.ch', '2024-07-15 00:00:00', '2024-07-25 00:00:00', 'CHF', 0, 3, 170.00, 170.00, 'Betrag von Steuer befreit', 2, 'de', 0, NULL);

-- ----------------------------
-- Table structure for languages
-- ----------------------------
DROP TABLE IF EXISTS `languages`;
CREATE TABLE `languages`  (
  `intLanguageID` int(11) NOT NULL AUTO_INCREMENT,
  `strLanguageISO` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strLanguageEN` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strLanguage` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intPrio` int(11) NOT NULL,
  `blnDefault` tinyint(1) NOT NULL DEFAULT 0,
  `blnChooseable` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intLanguageID`) USING BTREE,
  UNIQUE INDEX `_strLanguageISO`(`strLanguageISO`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of languages
-- ----------------------------
INSERT INTO `languages` VALUES (1, 'en', 'English', 'English', 2, 0, 0);
INSERT INTO `languages` VALUES (2, 'de', 'German', 'Deutsch', 1, 1, 1);

-- ----------------------------
-- Table structure for modules
-- ----------------------------
DROP TABLE IF EXISTS `modules`;
CREATE TABLE `modules`  (
  `intModuleID` int(11) NOT NULL AUTO_INCREMENT,
  `strModuleName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strShortDescription` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `blnActive` tinyint(1) NOT NULL,
  `strTabPrefix` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPicture` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnBookable` tinyint(1) NOT NULL,
  `intNumTestDays` int(11) NOT NULL,
  `strSettingPath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnFree` tinyint(1) NULL DEFAULT 0,
  `intPrio` int(11) NOT NULL,
  PRIMARY KEY (`intModuleID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of modules
-- ----------------------------

-- ----------------------------
-- Table structure for modules_prices
-- ----------------------------
DROP TABLE IF EXISTS `modules_prices`;
CREATE TABLE `modules_prices`  (
  `intModulePriceID` int(11) NOT NULL AUTO_INCREMENT,
  `intModuleID` int(11) NOT NULL,
  `intCurrencyID` int(11) NOT NULL,
  `decPriceMonthly` decimal(10, 2) NULL DEFAULT NULL,
  `decPriceYearly` decimal(10, 2) NULL DEFAULT NULL,
  `decPriceOneTime` decimal(10, 2) NULL DEFAULT NULL,
  `decVat` decimal(10, 2) NULL DEFAULT NULL,
  `blnIsNet` tinyint(1) NOT NULL DEFAULT 1,
  `intVatType` int(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`intModulePriceID`) USING BTREE,
  INDEX `_intCurrencyID`(`intCurrencyID`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_mp_currencies` FOREIGN KEY (`intCurrencyID`) REFERENCES `currencies` (`intCurrencyID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_mp_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of modules_prices
-- ----------------------------

-- ----------------------------
-- Table structure for modules_trans
-- ----------------------------
DROP TABLE IF EXISTS `modules_trans`;
CREATE TABLE `modules_trans`  (
  `intModulTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intModuleID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strModuleName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strShortDescription` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`intModulTransID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_modules_trans` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_mt_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of modules_trans
-- ----------------------------

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `intNotificationID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intUserID` int(11) NULL DEFAULT NULL,
  `dtmCreated` datetime NULL DEFAULT NULL,
  `strTitleVar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescrVar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strLink` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strLinkTextVar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dtmRead` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intNotificationID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_noti_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notifications
-- ----------------------------

-- ----------------------------
-- Table structure for optin
-- ----------------------------
DROP TABLE IF EXISTS `optin`;
CREATE TABLE `optin`  (
  `intOptinID` int(11) NOT NULL AUTO_INCREMENT,
  `strFirstName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strLastName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strCompanyName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strEmail` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strLanguage` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strUUID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`intOptinID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of optin
-- ----------------------------

-- ----------------------------
-- Table structure for payments
-- ----------------------------
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments`  (
  `intPaymentID` int(11) NOT NULL AUTO_INCREMENT,
  `intInvoiceID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `decAmount` decimal(10, 2) NOT NULL,
  `dtmPayDate` datetime NOT NULL,
  `strPaymentType` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intPayrexxID` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`intPaymentID`) USING BTREE,
  INDEX `_intInvoiceID`(`intInvoiceID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_pay_invoice` FOREIGN KEY (`intInvoiceID`) REFERENCES `invoices` (`intInvoiceID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of payments
-- ----------------------------
INSERT INTO `payments` VALUES (1, 1, 3, 39.90, '2024-07-12 13:35:00', 'Visa', 1);
INSERT INTO `payments` VALUES (2, 3, 4, 39.90, '2024-07-12 15:09:38', 'Visa', 2);

-- ----------------------------
-- Table structure for payrexx
-- ----------------------------
DROP TABLE IF EXISTS `payrexx`;
CREATE TABLE `payrexx`  (
  `intPayrexxID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NULL DEFAULT NULL,
  `dtmTimeUTC` datetime NULL DEFAULT NULL,
  `intGatewayID` int(11) NULL DEFAULT NULL,
  `intTransactionID` int(11) NULL DEFAULT NULL,
  `strStatus` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strLanguage` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPSP` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intPSPID` int(11) NULL DEFAULT NULL,
  `decAmount` decimal(10, 2) NULL DEFAULT NULL,
  `decPayrexxFee` decimal(10, 2) NULL DEFAULT NULL,
  `strPaymentBrand` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strCardNumber` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnDefault` tinyint(1) NOT NULL DEFAULT 0,
  `blnFailed` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intPayrexxID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intTransactionID`(`intTransactionID`) USING BTREE,
  CONSTRAINT `frn_payrexx_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of payrexx
-- ----------------------------
INSERT INTO `payrexx` VALUES (1, 3, '2024-07-12 13:34:26', 17861800, 16188441, 'authorized', 'de', 'Payrexx_Payments', 26, 0.00, 0.00, 'Visa', 'xxxxxxxxxxxx4242', 1, 0);
INSERT INTO `payrexx` VALUES (2, 4, '2024-07-12 15:09:26', 17863886, 16190655, 'authorized', 'de', 'Payrexx_Payments', 26, 0.00, 0.00, 'Visa', 'xxxxxxxxxxxx4242', 1, 0);

-- ----------------------------
-- Table structure for plan_features
-- ----------------------------
DROP TABLE IF EXISTS `plan_features`;
CREATE TABLE `plan_features`  (
  `intPlanFeatureID` int(11) NOT NULL AUTO_INCREMENT,
  `strFeatureName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strDescription` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `blnCategory` tinyint(1) NOT NULL DEFAULT 0,
  `strVariable` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intPrio` int(5) NOT NULL,
  PRIMARY KEY (`intPlanFeatureID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of plan_features
-- ----------------------------
INSERT INTO `plan_features` VALUES (1, 'Kosten pro Inserat', '', 0, 'varAdCosts', 1);
INSERT INTO `plan_features` VALUES (2, 'Laufzeit in Tagen', '', 0, 'varAdDuringDays', 2);

-- ----------------------------
-- Table structure for plan_features_trans
-- ----------------------------
DROP TABLE IF EXISTS `plan_features_trans`;
CREATE TABLE `plan_features_trans`  (
  `intPlanFeatTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intPlanFeatureID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strFeatureName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`intPlanFeatTransID`) USING BTREE,
  INDEX `_intPlanFeatureID`(`intPlanFeatureID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_pft_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_pft_plan_features` FOREIGN KEY (`intPlanFeatureID`) REFERENCES `plan_features` (`intPlanFeatureID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of plan_features_trans
-- ----------------------------

-- ----------------------------
-- Table structure for plan_groups
-- ----------------------------
DROP TABLE IF EXISTS `plan_groups`;
CREATE TABLE `plan_groups`  (
  `intPlanGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `strGroupName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intCountryID` int(11) NULL DEFAULT NULL,
  `intPrio` int(11) NOT NULL,
  PRIMARY KEY (`intPlanGroupID`) USING BTREE,
  INDEX `_intCountryID`(`intCountryID`) USING BTREE,
  CONSTRAINT `frn_pg_countries` FOREIGN KEY (`intCountryID`) REFERENCES `countries` (`intCountryID`) ON DELETE RESTRICT ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of plan_groups
-- ----------------------------
INSERT INTO `plan_groups` VALUES (1, 'Arbeitgeber', 149, 1);
INSERT INTO `plan_groups` VALUES (2, 'Arbeitnehmer', 149, 2);

-- ----------------------------
-- Table structure for plan_groups_trans
-- ----------------------------
DROP TABLE IF EXISTS `plan_groups_trans`;
CREATE TABLE `plan_groups_trans`  (
  `intPlanGroupTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intPlanGroupID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strGroupName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intPlanGroupTransID`) USING BTREE,
  INDEX `_intPlanGroupID`(`intPlanGroupID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_pgt_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_pgt_plangroups` FOREIGN KEY (`intPlanGroupID`) REFERENCES `plan_groups` (`intPlanGroupID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of plan_groups_trans
-- ----------------------------

-- ----------------------------
-- Table structure for plan_prices
-- ----------------------------
DROP TABLE IF EXISTS `plan_prices`;
CREATE TABLE `plan_prices`  (
  `intPlanPriceID` int(11) NOT NULL AUTO_INCREMENT,
  `intPlanID` int(11) NOT NULL,
  `intCurrencyID` int(11) NOT NULL,
  `decPriceMonthly` decimal(10, 2) NULL DEFAULT NULL,
  `decPriceYearly` decimal(10, 2) NULL DEFAULT NULL,
  `decVat` decimal(10, 2) NULL DEFAULT NULL,
  `blnIsNet` tinyint(1) NOT NULL DEFAULT 1,
  `intVatType` int(1) NOT NULL DEFAULT 1,
  `blnOnRequest` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intPlanPriceID`) USING BTREE,
  INDEX `_intPlanID`(`intPlanID`) USING BTREE,
  INDEX `_intCurrencyID`(`intCurrencyID`) USING BTREE,
  CONSTRAINT `frn_pp_currency` FOREIGN KEY (`intCurrencyID`) REFERENCES `currencies` (`intCurrencyID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_pp_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of plan_prices
-- ----------------------------
INSERT INTO `plan_prices` VALUES (1, 2, 3, 80.00, 800.00, 8.10, 1, 1, 0);
INSERT INTO `plan_prices` VALUES (2, 4, 3, 39.90, 350.00, 8.10, 0, 3, 0);

-- ----------------------------
-- Table structure for plans
-- ----------------------------
DROP TABLE IF EXISTS `plans`;
CREATE TABLE `plans`  (
  `intPlanID` int(11) NOT NULL AUTO_INCREMENT,
  `intPlanGroupID` int(11) NOT NULL,
  `strPlanName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strShortDescription` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strDescription` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strButtonName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strBookingLink` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnRecommended` tinyint(1) NULL DEFAULT 0,
  `intMaxUsers` int(11) NULL DEFAULT NULL,
  `intNumTestDays` int(11) NULL DEFAULT 0,
  `blnFree` tinyint(1) NULL DEFAULT 0,
  `blnDefaultPlan` tinyint(1) NULL DEFAULT 0,
  `intPrio` int(11) NOT NULL,
  PRIMARY KEY (`intPlanID`) USING BTREE,
  INDEX `_intPlanGroupID`(`intPlanGroupID`) USING BTREE,
  CONSTRAINT `frn_plans_plan_group` FOREIGN KEY (`intPlanGroupID`) REFERENCES `plan_groups` (`intPlanGroupID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of plans
-- ----------------------------
INSERT INTO `plans` VALUES (1, 1, 'Inserate ohne Abo', '', '<ul><li>CHF 170.- pro Inserat<br></li><li>6 Wochen Laufzeit pro Inserat<br></li><li>Jederzeit pausier- oder stopbar<br></li><li>So viele Inserate wie gewünscht veröffentlichen</li><li>2 Benutzer können Inserate verwalten<br></li></ul>', 'Anmelden', '', 0, 2, 0, 1, 1, 1);
INSERT INTO `plans` VALUES (2, 1, 'Inserate mit Abo', '', '<ul><li>CHF 100.- pro Inserat (statt 170.-)<br></li><li>6 Wochen Laufzeit pro Inserat</li><li>Jederzeit pausier- oder stopbar<br></li><li>So viele Inserate wie gewünscht veröffentlichen</li><li>3 Benutzer können Inserate verwalten</li></ul>', 'Kaufen', '', 1, 3, 0, 0, 0, 2);
INSERT INTO `plans` VALUES (4, 2, 'FINDEN LASSEN!', '', '<ul><li>Persönliches Stellenprofil</li><li>Sie bestimmen, welche Daten öffentlich sind</li><li>Online bis auf Widerruf</li><li>Jederzeit kündbar<br></li></ul>', 'Anmelden', '', 1, 1, 0, 0, 0, 2);
INSERT INTO `plans` VALUES (5, 2, 'FINDEN!', '', '<ul><li>Kostenlos registrieren<br></li><li>Persönliches Profil für Bewerbungen<br></li><li>Per Klick auf Stellen bewerben</li></ul>', 'Anmelden', '', 0, 1, 0, 1, 1, 1);

-- ----------------------------
-- Table structure for plans_modules
-- ----------------------------
DROP TABLE IF EXISTS `plans_modules`;
CREATE TABLE `plans_modules`  (
  `intPlanModuleID` int(11) NOT NULL AUTO_INCREMENT,
  `intPlanID` int(11) NOT NULL,
  `intModuleID` int(11) NOT NULL,
  PRIMARY KEY (`intPlanModuleID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of plans_modules
-- ----------------------------

-- ----------------------------
-- Table structure for plans_plan_features
-- ----------------------------
DROP TABLE IF EXISTS `plans_plan_features`;
CREATE TABLE `plans_plan_features`  (
  `intPlansPlanFeatID` int(11) NOT NULL AUTO_INCREMENT,
  `intPlanID` int(11) NOT NULL,
  `intPlanFeatureID` int(11) NOT NULL,
  `blnCheckmark` tinyint(1) NULL DEFAULT 0,
  `strValue` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intPlansPlanFeatID`) USING BTREE,
  INDEX `_intPlanID`(`intPlanID`) USING BTREE,
  INDEX `_intPlanFeatureID`(`intPlanFeatureID`) USING BTREE,
  CONSTRAINT `frn_ppf_plan_features` FOREIGN KEY (`intPlanFeatureID`) REFERENCES `plan_features` (`intPlanFeatureID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_ppf_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of plans_plan_features
-- ----------------------------
INSERT INTO `plans_plan_features` VALUES (1, 1, 1, 0, '170');
INSERT INTO `plans_plan_features` VALUES (2, 1, 2, 0, '180');
INSERT INTO `plans_plan_features` VALUES (3, 2, 1, 0, '100');
INSERT INTO `plans_plan_features` VALUES (4, 2, 2, 0, '180');
INSERT INTO `plans_plan_features` VALUES (5, 4, 1, 0, '60');
INSERT INTO `plans_plan_features` VALUES (6, 4, 2, 0, '99999');
INSERT INTO `plans_plan_features` VALUES (7, 5, 1, 0, '0');
INSERT INTO `plans_plan_features` VALUES (8, 5, 2, 0, '0');

-- ----------------------------
-- Table structure for plans_plan_features_trans
-- ----------------------------
DROP TABLE IF EXISTS `plans_plan_features_trans`;
CREATE TABLE `plans_plan_features_trans`  (
  `intPlansPlanFeatTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intPlansPlanFeatID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strValue` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intPlansPlanFeatTransID`) USING BTREE,
  INDEX `_intPlansPlanFeatID`(`intPlansPlanFeatID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_ppft_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_ppft_plans_plan_features` FOREIGN KEY (`intPlansPlanFeatID`) REFERENCES `plans_plan_features` (`intPlansPlanFeatID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of plans_plan_features_trans
-- ----------------------------

-- ----------------------------
-- Table structure for plans_trans
-- ----------------------------
DROP TABLE IF EXISTS `plans_trans`;
CREATE TABLE `plans_trans`  (
  `intPlanTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intPlanID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strPlanName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strShortDescription` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strDescription` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strButtonName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strBookingLink` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intPlanTransID`) USING BTREE,
  INDEX `_intPlanID`(`intPlanID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_pt_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_pt_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of plans_trans
-- ----------------------------

-- ----------------------------
-- Table structure for schedulecontrol
-- ----------------------------
DROP TABLE IF EXISTS `schedulecontrol`;
CREATE TABLE `schedulecontrol`  (
  `intControlID` int(11) NOT NULL AUTO_INCREMENT,
  `strTaskName` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `dtmStart` datetime NULL DEFAULT NULL,
  `dtmEnd` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intControlID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of schedulecontrol
-- ----------------------------
INSERT INTO `schedulecontrol` VALUES (1, 'task_01', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (2, 'task_02', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (3, 'task_03', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (4, 'task_04', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (5, 'task_05', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (6, 'task_06', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (7, 'task_07', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (8, 'task_08', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (9, 'task_09', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (10, 'task_10', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (11, 'task_11', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (12, 'task_12', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (13, 'task_13', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (14, 'task_14', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (15, 'task_15', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (16, 'task_16', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (17, 'task_17', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (18, 'task_18', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (19, 'task_19', '2024-05-07 14:35:11', '2024-05-07 14:35:12');
INSERT INTO `schedulecontrol` VALUES (20, 'task_20', '2024-05-07 14:35:11', '2024-05-07 14:35:12');

-- ----------------------------
-- Table structure for scheduler_01
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_01`;
CREATE TABLE `scheduler_01`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_01` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_01` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_01
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_02
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_02`;
CREATE TABLE `scheduler_02`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_02` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_02` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_02
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_03
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_03`;
CREATE TABLE `scheduler_03`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_03` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_03` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_03
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_04
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_04`;
CREATE TABLE `scheduler_04`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_04` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_04` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_04
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_05
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_05`;
CREATE TABLE `scheduler_05`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_05` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_05` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_05
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_06
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_06`;
CREATE TABLE `scheduler_06`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_06` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_06` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_06
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_07
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_07`;
CREATE TABLE `scheduler_07`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_07` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_07` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_07
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_08
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_08`;
CREATE TABLE `scheduler_08`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_08` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_08` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_08
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_09
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_09`;
CREATE TABLE `scheduler_09`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_09` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_09` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_09
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_10
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_10`;
CREATE TABLE `scheduler_10`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_10` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_10` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_10
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_11
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_11`;
CREATE TABLE `scheduler_11`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_11` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_11` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_11
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_12
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_12`;
CREATE TABLE `scheduler_12`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_12` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_12` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_12
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_13
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_13`;
CREATE TABLE `scheduler_13`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_13` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_13` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_13
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_14
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_14`;
CREATE TABLE `scheduler_14`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_14` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_14` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_14
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_15
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_15`;
CREATE TABLE `scheduler_15`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_15` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_15` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_15
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_16
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_16`;
CREATE TABLE `scheduler_16`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_16` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_16` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_16
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_17
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_17`;
CREATE TABLE `scheduler_17`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_17` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_17` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_17
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_18
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_18`;
CREATE TABLE `scheduler_18`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_18` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_18` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_18
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_19
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_19`;
CREATE TABLE `scheduler_19`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_19` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_19` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_19
-- ----------------------------

-- ----------------------------
-- Table structure for scheduler_20
-- ----------------------------
DROP TABLE IF EXISTS `scheduler_20`;
CREATE TABLE `scheduler_20`  (
  `intSchedulerID` int(11) NOT NULL AUTO_INCREMENT,
  `intScheduletaskID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `dtmLastRun` datetime NULL DEFAULT NULL,
  `dtmNextRun` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`intSchedulerID`) USING BTREE,
  INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_scheduler_customers_20` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_scheduler_sched_20` FOREIGN KEY (`intScheduletaskID`) REFERENCES `scheduletasks` (`intScheduletaskID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduler_20
-- ----------------------------

-- ----------------------------
-- Table structure for scheduletasks
-- ----------------------------
DROP TABLE IF EXISTS `scheduletasks`;
CREATE TABLE `scheduletasks`  (
  `intScheduletaskID` int(11) NOT NULL AUTO_INCREMENT,
  `strName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intModuleID` int(11) NULL DEFAULT NULL,
  `dtmStartTime` datetime NULL DEFAULT NULL,
  `strPath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intIterationMinutes` int(11) NOT NULL DEFAULT 5,
  `blnActive` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intScheduletaskID`) USING BTREE,
  UNIQUE INDEX `_intScheduletaskID`(`intScheduletaskID`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_sch_module` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scheduletasks
-- ----------------------------

-- ----------------------------
-- Table structure for ss_ads
-- ----------------------------
DROP TABLE IF EXISTS `ss_ads`;
CREATE TABLE `ss_ads`  (
  `intAdID` int(11) NOT NULL AUTO_INCREMENT,
  `strUUID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intCustomerID` int(11) NOT NULL,
  `intUserID` int(11) NULL DEFAULT NULL,
  `blnAdTypeID` int(11) NOT NULL DEFAULT 1 COMMENT '1 = job ad | 2 = specialist ad',
  `blnActive` tinyint(1) NOT NULL DEFAULT 0,
  `blnPaused` tinyint(1) NOT NULL DEFAULT 0,
  `blnArchived` tinyint(1) NOT NULL DEFAULT 0,
  `dteStart` date NULL DEFAULT NULL,
  `dteEnd` date NULL DEFAULT NULL,
  `strJobTitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strJobDescription` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `lngMinWorkload` int(3) NULL DEFAULT NULL,
  `lngMaxWorkload` int(3) NULL DEFAULT NULL,
  `intContractTypeID` int(11) NOT NULL,
  `intJobPositionID` int(11) NULL DEFAULT NULL,
  `strJobStarting` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnShowApplication` tinyint(1) NOT NULL DEFAULT 1,
  `strVideoLink` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intInvoiceID` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`intAdID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_blnAdTypeID`(`blnAdTypeID`) USING BTREE,
  INDEX `_intContractTypeID`(`intContractTypeID`) USING BTREE,
  INDEX `_intJobPositionID`(`intJobPositionID`) USING BTREE,
  INDEX `_blnActive`(`blnActive`) USING BTREE,
  CONSTRAINT `frn_ads_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ss_ads
-- ----------------------------
INSERT INTO `ss_ads` VALUES (5, '9c62d2bb-405e-11ef-895a-0242ac190002', 3, 3, 2, 0, 0, 0, NULL, NULL, 'Informatiker EFZ mit 20 Jahre Erfahrung', '<p>hjkfhjkfh<br></p>', 100, 100, 1, 6, 'Nach Vereinbarung', 1, '', NULL);
INSERT INTO `ss_ads` VALUES (6, 'fcdf0029-405f-11ef-895a-0242ac190002', 2, 2, 1, 1, 0, 1, '2024-07-12', '2024-07-12', 'Projektleiter/in Herstellung, befristet für 12 Monate', '<p>dzukdzkz<br></p>', 20, 20, 2, 5, 'Nach Vereinbarung', 1, '', 2);
INSERT INTO `ss_ads` VALUES (8, '46de3439-4063-11ef-895a-0242ac190002', 4, 4, 2, 0, 0, 0, NULL, NULL, 'Florist*in mit eidg. Fachausweis', '<p>gh kjdhgkjdghj kdghjdghj dghj dghj dghjdg<br></p>', 50, 60, 3, 5, 'Nach Vereinbarung', 1, 'https://youtu.be/APq02E8zsfg', NULL);
INSERT INTO `ss_ads` VALUES (9, 'db58a000-4064-11ef-895a-0242ac190002', 2, 2, 1, 0, 0, 0, NULL, NULL, 'Projektleiter/in Herstellung, befristet für 12 Monate', '<p>dghj sh jdghj gthj gtj btrs ujhsfrghjsgfjgfhjsgfhj<br></p>', 100, 100, 2, 5, 'Nach Vereinbarung', 1, 'https://youtu.be/APq02E8zsfg', NULL);
INSERT INTO `ss_ads` VALUES (10, '296cbe13-4065-11ef-895a-0242ac190002', 6, 6, 2, 0, 0, 0, NULL, NULL, 'Informatiker EFZ', '<p>adfhg adf gdafg adfg adfgh fghnsgfhjkm dgh ydfhb adfgh jadh sfghjn wsfj dghkjruz lidthzj stkjd g kjeg<br></p>', 80, 100, 1, 6, 'Sofort', 1, 'https://player.vimeo.com/video/951346486', NULL);
INSERT INTO `ss_ads` VALUES (11, 'd9e43022-42ba-11ef-bdd3-0242ac190002', 5, 5, 1, 1, 0, 0, '2024-07-15', '2025-01-11', 'Sachbearbeitung Sozialdienste (m/w/d)', '<p>dghj sjhj hgjgghd<br></p>', 30, 50, 3, 6, 'Nach Vereinbarung', 1, '', 4);

-- ----------------------------
-- Table structure for ss_ads_history
-- ----------------------------
DROP TABLE IF EXISTS `ss_ads_history`;
CREATE TABLE `ss_ads_history`  (
  `intAdsHistoryID` int(11) NOT NULL AUTO_INCREMENT,
  `intAdID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `intUserID` int(11) NULL DEFAULT NULL,
  `dtmProcessDate` datetime NOT NULL,
  `strDescription` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intAdsHistoryID`) USING BTREE,
  INDEX `_intAdID`(`intAdID`) USING BTREE,
  CONSTRAINT `frn_ah_ads` FOREIGN KEY (`intAdID`) REFERENCES `ss_ads` (`intAdID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ss_ads_history
-- ----------------------------
INSERT INTO `ss_ads_history` VALUES (4, 5, 3, 3, '2024-07-12 14:54:17', 'Neues Jobprofil erstellt');
INSERT INTO `ss_ads_history` VALUES (5, 5, 3, 3, '2024-07-12 14:55:11', 'Jobprofil publiziert');
INSERT INTO `ss_ads_history` VALUES (6, 6, 2, 2, '2024-07-12 15:04:08', 'Neues Inserat erstellt');
INSERT INTO `ss_ads_history` VALUES (7, 6, 2, 2, '2024-07-12 15:04:14', 'Inserat aktiviert (12.07.2024 bis 08.01.2025)');
INSERT INTO `ss_ads_history` VALUES (8, 6, 2, 2, '2024-07-12 15:04:53', 'Inserat beendet');
INSERT INTO `ss_ads_history` VALUES (9, 6, 2, 2, '2024-07-12 15:04:57', 'Inserat mit ID 6 kopiert');
INSERT INTO `ss_ads_history` VALUES (10, 8, 4, 4, '2024-07-12 15:27:41', 'Neues Jobprofil erstellt');
INSERT INTO `ss_ads_history` VALUES (11, 8, 4, 4, '2024-07-12 15:27:47', 'Jobprofil publiziert');
INSERT INTO `ss_ads_history` VALUES (12, 9, 2, 2, '2024-07-12 15:38:59', 'Neues Inserat erstellt');
INSERT INTO `ss_ads_history` VALUES (13, 9, 2, 2, '2024-07-12 15:39:05', 'Inserat bearbeitet');
INSERT INTO `ss_ads_history` VALUES (14, 10, 6, 6, '2024-07-12 15:41:10', 'Neues Jobprofil erstellt');
INSERT INTO `ss_ads_history` VALUES (15, 10, 6, 6, '2024-07-12 15:41:19', 'Jobprofil publiziert');
INSERT INTO `ss_ads_history` VALUES (16, 10, 6, 6, '2024-07-12 15:41:20', 'Jobprofil deaktiviert');
INSERT INTO `ss_ads_history` VALUES (17, 10, 6, 6, '2024-07-12 15:55:11', 'Jobprofil publiziert');
INSERT INTO `ss_ads_history` VALUES (18, 8, 4, 4, '2024-07-15 09:20:49', 'Jobprofil deaktiviert');
INSERT INTO `ss_ads_history` VALUES (19, 8, 4, 4, '2024-07-15 09:20:51', 'Jobprofil publiziert');
INSERT INTO `ss_ads_history` VALUES (20, 6, 1, 1, '2024-07-15 09:29:34', 'Inserat durch Admin reaktiviert');
INSERT INTO `ss_ads_history` VALUES (21, 11, 5, 5, '2024-07-15 14:59:36', 'Neues Inserat erstellt');
INSERT INTO `ss_ads_history` VALUES (22, 11, 5, 5, '2024-07-15 14:59:58', 'Inserat aktiviert (15.07.2024 bis 11.01.2025)');

-- ----------------------------
-- Table structure for ss_ads_locations
-- ----------------------------
DROP TABLE IF EXISTS `ss_ads_locations`;
CREATE TABLE `ss_ads_locations`  (
  `intAdsLocationID` int(11) NOT NULL AUTO_INCREMENT,
  `intAdID` int(11) NOT NULL,
  `intLocationID` int(11) NOT NULL,
  PRIMARY KEY (`intAdsLocationID`) USING BTREE,
  INDEX `_intAdID`(`intAdID`) USING BTREE,
  INDEX `_intLocationID`(`intLocationID`) USING BTREE,
  CONSTRAINT `frn_al_ads` FOREIGN KEY (`intAdID`) REFERENCES `ss_ads` (`intAdID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_al_locations` FOREIGN KEY (`intLocationID`) REFERENCES `ss_locations` (`intLocationID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ss_ads_locations
-- ----------------------------
INSERT INTO `ss_ads_locations` VALUES (11, 5, 1525);
INSERT INTO `ss_ads_locations` VALUES (12, 5, 172);
INSERT INTO `ss_ads_locations` VALUES (13, 5, 1715);
INSERT INTO `ss_ads_locations` VALUES (14, 6, 1525);
INSERT INTO `ss_ads_locations` VALUES (15, 6, 172);
INSERT INTO `ss_ads_locations` VALUES (16, 6, 1715);
INSERT INTO `ss_ads_locations` VALUES (20, 8, 1715);
INSERT INTO `ss_ads_locations` VALUES (21, 8, 184);
INSERT INTO `ss_ads_locations` VALUES (22, 8, 1681);
INSERT INTO `ss_ads_locations` VALUES (23, 8, 2184);
INSERT INTO `ss_ads_locations` VALUES (25, 9, 2777);
INSERT INTO `ss_ads_locations` VALUES (26, 10, 2761);
INSERT INTO `ss_ads_locations` VALUES (27, 11, 2761);

-- ----------------------------
-- Table structure for ss_applications
-- ----------------------------
DROP TABLE IF EXISTS `ss_applications`;
CREATE TABLE `ss_applications`  (
  `intApplicationID` int(11) NOT NULL AUTO_INCREMENT,
  `intWorkerProfileID` int(11) NOT NULL,
  `intAdID` int(11) NOT NULL,
  `dtmApplieted` datetime NULL DEFAULT NULL,
  `blnOpen` tinyint(4) NOT NULL DEFAULT 1,
  `blnDone` tinyint(4) NOT NULL DEFAULT 0,
  `strAppLetter` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`intApplicationID`) USING BTREE,
  INDEX `_intWorkerProfileID`(`intWorkerProfileID`) USING BTREE,
  INDEX `_intAdID`(`intAdID`) USING BTREE,
  INDEX `_blnOpen`(`blnOpen`) USING BTREE,
  INDEX `_blnDone`(`blnDone`) USING BTREE,
  CONSTRAINT `frn_appl_wp` FOREIGN KEY (`intWorkerProfileID`) REFERENCES `ss_worker_profiles` (`intWorkerProfileID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ss_applications
-- ----------------------------

-- ----------------------------
-- Table structure for ss_comapny
-- ----------------------------
DROP TABLE IF EXISTS `ss_comapny`;
CREATE TABLE `ss_comapny`  (
  `intCompanyID` int(11) NOT NULL AUTO_INCREMENT,
  `strCompanyDescription` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`intCompanyID`) USING BTREE,
  UNIQUE INDEX `_intCompanyID`(`intCompanyID`) USING BTREE,
  CONSTRAINT `frn_company_customer` FOREIGN KEY (`intCompanyID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ss_comapny
-- ----------------------------
INSERT INTO `ss_comapny` VALUES (2, '<p>fdg hfshfsgh fsgdcbg dfhgfhgfh gfh gfsh gfsh gfsh gf fdg hfshfsgh fsgdcbg dfhgfhgfh gfh gfsh gfsh gfsh gf fdg <em>hfshfsgh </em>fsgdcbg dfhgfhgfh gfh gfsh gfsh gfsh gf fdg hfshfsgh fsgdcbg dfhgfhgfh gfh gfsh gfsh gfsh gf fdg hfshfsgh fsgdcbg dfhgfhgfh gfh gfsh gfsh gfsh gf fdg hfshfsgh fsgdcbg dfhgfhgfh gfh gfsh gfsh gfsh gf fdg hfshfsgh <a href=\"https://www.paweco.ch\" target=\"new\">fsgdcbg</a><dfhgfhgfh> gfh gfsh gfsh gfsh gf fdg hfshfsgh fsgdcbg dfhgfhgfh gfh gfsh gfsh gfsh gf <br></dfhgfhgfh></p><blockquote>fdg hfshfsgh fsgdcbg <strong>dfhgfhgfh</strong> gfh gfsh gfsh gfsh gf fdg hfshfsgh \r\nfsgdcbg dfhgfhgfh gfh gfsh gfsh gfsh gf fdg hfshfsgh fsgdcbg dfhgfhgfh \r\ngfh gfsh gfsh gfsh gf fdg hfshfsgh <invalidtag href=\"\">fsgdcbg dfhgfhgfh gfh gfsh gfsh gfsh \r\ngf fdg hfshfsgh fsgdcbg dfhgfhgfh gfh gfsh gfsh gfsh gf fdg hfshfsgh \r\nfsgdcbg dfhgfhgfh gfh gfsh gfsh gfsh gf fdg hfshfsgh fsgdcbg <br></invalidtag></blockquote><ul><li>ghnfxshfsghsfg</li><li>fsghsfghsfghsf</li><li>sfghsfghsfhgsfg</li><li>hsfghsfghsfgh</li></ul>');

-- ----------------------------
-- Table structure for ss_contract_types
-- ----------------------------
DROP TABLE IF EXISTS `ss_contract_types`;
CREATE TABLE `ss_contract_types`  (
  `intContractTypeID` int(11) NOT NULL AUTO_INCREMENT,
  `strName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`intContractTypeID`) USING BTREE,
  UNIQUE INDEX `_intContractTypeID`(`intContractTypeID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ss_contract_types
-- ----------------------------
INSERT INTO `ss_contract_types` VALUES (1, 'Unbefristeter Arbeitsvertrag', 1);
INSERT INTO `ss_contract_types` VALUES (2, 'Befristeter Arbeitsvertrag', 1);
INSERT INTO `ss_contract_types` VALUES (3, 'Teilzeitvertrag', 1);

-- ----------------------------
-- Table structure for ss_indestries_ads
-- ----------------------------
DROP TABLE IF EXISTS `ss_indestries_ads`;
CREATE TABLE `ss_indestries_ads`  (
  `intIndustriesAds` int(11) NOT NULL AUTO_INCREMENT,
  `intIndustryID` int(11) NOT NULL,
  `intAdID` int(11) NOT NULL,
  PRIMARY KEY (`intIndustriesAds`) USING BTREE,
  INDEX `_intIndustryID`(`intIndustryID`) USING BTREE,
  INDEX `_intAdID`(`intAdID`) USING BTREE,
  CONSTRAINT `frn_ia_ads` FOREIGN KEY (`intAdID`) REFERENCES `ss_ads` (`intAdID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_ia_industries` FOREIGN KEY (`intIndustryID`) REFERENCES `ss_industries` (`intIndustryID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ss_indestries_ads
-- ----------------------------
INSERT INTO `ss_indestries_ads` VALUES (10, 13, 5);
INSERT INTO `ss_indestries_ads` VALUES (11, 11, 5);
INSERT INTO `ss_indestries_ads` VALUES (12, 14, 5);
INSERT INTO `ss_indestries_ads` VALUES (13, 16, 5);
INSERT INTO `ss_indestries_ads` VALUES (14, 19, 6);
INSERT INTO `ss_indestries_ads` VALUES (15, 14, 6);
INSERT INTO `ss_indestries_ads` VALUES (16, 16, 6);
INSERT INTO `ss_indestries_ads` VALUES (20, 19, 8);
INSERT INTO `ss_indestries_ads` VALUES (22, 19, 9);
INSERT INTO `ss_indestries_ads` VALUES (23, 17, 10);
INSERT INTO `ss_indestries_ads` VALUES (24, 9, 10);
INSERT INTO `ss_indestries_ads` VALUES (25, 5, 11);
INSERT INTO `ss_indestries_ads` VALUES (26, 11, 11);
INSERT INTO `ss_indestries_ads` VALUES (27, 9, 11);

-- ----------------------------
-- Table structure for ss_industries
-- ----------------------------
DROP TABLE IF EXISTS `ss_industries`;
CREATE TABLE `ss_industries`  (
  `intIndustryID` int(11) NOT NULL AUTO_INCREMENT,
  `strName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 1,
  `blnProposal` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intIndustryID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ss_industries
-- ----------------------------
INSERT INTO `ss_industries` VALUES (1, 'Sozialpädagogik', 1, 0);
INSERT INTO `ss_industries` VALUES (2, 'Sozialhilfe und Kindes- Erwachsenenschutz', 1, 0);
INSERT INTO `ss_industries` VALUES (3, 'Gesundheitswesen', 1, 0);
INSERT INTO `ss_industries` VALUES (4, 'Jugendarbeit', 1, 0);
INSERT INTO `ss_industries` VALUES (5, 'Asylwesen', 1, 0);
INSERT INTO `ss_industries` VALUES (6, 'Arbeitagogik und Arbeitsintegration', 1, 0);
INSERT INTO `ss_industries` VALUES (7, 'Kaufmännische Berufe', 1, 0);
INSERT INTO `ss_industries` VALUES (8, 'Öffentliche Verwaltung', 1, 0);
INSERT INTO `ss_industries` VALUES (9, 'Technische Berufe', 1, 0);
INSERT INTO `ss_industries` VALUES (10, 'Handwerkliche Berufe', 1, 0);
INSERT INTO `ss_industries` VALUES (11, 'Bauwesen', 1, 0);
INSERT INTO `ss_industries` VALUES (12, 'Psycholgie und Therapie', 1, 0);
INSERT INTO `ss_industries` VALUES (13, 'Banken und Versicherungen', 1, 0);
INSERT INTO `ss_industries` VALUES (14, 'Detailhandel', 1, 0);
INSERT INTO `ss_industries` VALUES (15, 'Schulen', 1, 0);
INSERT INTO `ss_industries` VALUES (16, 'Gastronomie', 1, 0);
INSERT INTO `ss_industries` VALUES (17, 'Informatik', 1, 0);
INSERT INTO `ss_industries` VALUES (18, 'Personalwesen', 1, 0);
INSERT INTO `ss_industries` VALUES (19, 'Andere Berufe', 1, 0);

-- ----------------------------
-- Table structure for ss_job_positions
-- ----------------------------
DROP TABLE IF EXISTS `ss_job_positions`;
CREATE TABLE `ss_job_positions`  (
  `intJobPositionID` int(11) NOT NULL AUTO_INCREMENT,
  `strName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`intJobPositionID`) USING BTREE,
  UNIQUE INDEX `_intJobPositionID`(`intJobPositionID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ss_job_positions
-- ----------------------------
INSERT INTO `ss_job_positions` VALUES (5, 'Angestellt', 1);
INSERT INTO `ss_job_positions` VALUES (6, 'Führungsposition', 1);

-- ----------------------------
-- Table structure for ss_locations
-- ----------------------------
DROP TABLE IF EXISTS `ss_locations`;
CREATE TABLE `ss_locations`  (
  `intLocationID` int(11) NOT NULL AUTO_INCREMENT,
  `strName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strCanton` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`intLocationID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2785 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ss_locations
-- ----------------------------
INSERT INTO `ss_locations` VALUES (1, 'Aeugst am Albis', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (2, 'Affoltern am Albis', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (3, 'Bonstetten', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (4, 'Hausen am Albis', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (5, 'Hedingen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (6, 'Kappel am Albis', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (7, 'Knonau', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (8, 'Maschwanden', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (9, 'Mettmenstetten', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (10, 'Obfelden', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (11, 'Ottenbach', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (12, 'Rifferswil', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (13, 'Stallikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (14, 'Wettswil am Albis', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (15, 'Adlikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (16, 'Benken (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (17, 'Berg am Irchel', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (18, 'Buch am Irchel', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (19, 'Dachsen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (20, 'Dorf', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (21, 'Feuerthalen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (22, 'Flaach', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (23, 'Flurlingen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (24, 'Andelfingen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (25, 'Henggart', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (26, 'Humlikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (27, 'Kleinandelfingen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (28, 'Laufen-Uhwiesen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (29, 'Marthalen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (30, 'Oberstammheim', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (31, 'Ossingen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (32, 'Rheinau', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (33, 'Thalheim an der Thur', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (34, 'Trüllikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (35, 'Truttikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (36, 'Unterstammheim', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (37, 'Volken', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (38, 'Waltalingen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (39, 'Bachenbülach', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (40, 'Bassersdorf', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (41, 'Bülach', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (42, 'Dietlikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (43, 'Eglisau', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (44, 'Embrach', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (45, 'Freienstein-Teufen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (46, 'Glattfelden', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (47, 'Hochfelden', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (48, 'Höri', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (49, 'Hüntwangen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (50, 'Kloten', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (51, 'Lufingen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (52, 'Nürensdorf', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (53, 'Oberembrach', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (54, 'Opfikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (55, 'Rafz', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (56, 'Rorbas', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (57, 'Wallisellen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (58, 'Wasterkingen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (59, 'Wil (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (60, 'Winkel', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (61, 'Bachs', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (62, 'Boppelsen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (63, 'Buchs (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (64, 'Dällikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (65, 'Dänikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (66, 'Dielsdorf', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (67, 'Hüttikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (68, 'Neerach', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (69, 'Niederglatt', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (70, 'Niederhasli', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (71, 'Niederweningen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (72, 'Oberglatt', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (73, 'Oberweningen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (74, 'Otelfingen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (75, 'Regensberg', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (76, 'Regensdorf', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (77, 'Rümlang', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (78, 'Schleinikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (79, 'Schöfflisdorf', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (80, 'Stadel', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (81, 'Steinmaur', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (82, 'Weiach', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (83, 'Bäretswil', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (84, 'Bubikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (85, 'Dürnten', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (86, 'Fischenthal', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (87, 'Gossau (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (88, 'Grüningen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (89, 'Hinwil', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (90, 'Rüti (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (91, 'Seegräben', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (92, 'Wald (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (93, 'Wetzikon (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (94, 'Adliswil', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (95, 'Hirzel', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (96, 'Horgen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (97, 'Hütten', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (98, 'Kilchberg (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (99, 'Langnau am Albis', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (100, 'Oberrieden', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (101, 'Richterswil', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (102, 'Rüschlikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (103, 'Schönenberg (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (104, 'Thalwil', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (105, 'Wädenswil', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (106, 'Erlenbach (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (107, 'Herrliberg', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (108, 'Hombrechtikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (109, 'Küsnacht (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (110, 'Männedorf', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (111, 'Meilen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (112, 'Oetwil am See', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (113, 'Stäfa', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (114, 'Uetikon am See', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (115, 'Zumikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (116, 'Zollikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (117, 'Bauma', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (118, 'Fehraltorf', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (119, 'Hittnau', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (120, 'Illnau-Effretikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (121, 'Kyburg', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (122, 'Lindau', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (123, 'Pfäffikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (124, 'Russikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (125, 'Sternenberg', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (126, 'Weisslingen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (127, 'Wila', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (128, 'Wildberg', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (129, 'Dübendorf', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (130, 'Egg', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (131, 'Fällanden', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (132, 'Greifensee', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (133, 'Maur', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (134, 'Mönchaltorf', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (135, 'Schwerzenbach', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (136, 'Uster', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (137, 'Volketswil', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (138, 'Wangen-Brüttisellen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (139, 'Altikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (140, 'Bertschikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (141, 'Brütten', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (142, 'Dägerlen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (143, 'Dättlikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (144, 'Dinhard', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (145, 'Elgg', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (146, 'Ellikon an der Thur', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (147, 'Elsau', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (148, 'Hagenbuch', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (149, 'Hettlingen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (150, 'Hofstetten (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (151, 'Neftenbach', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (152, 'Pfungen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (153, 'Rickenbach (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (154, 'Schlatt (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (155, 'Seuzach', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (156, 'Turbenthal', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (157, 'Wiesendangen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (158, 'Winterthur', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (159, 'Zell (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (160, 'Aesch (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (161, 'Birmensdorf (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (162, 'Dietikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (163, 'Geroldswil', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (164, 'Oberengstringen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (165, 'Oetwil an der Limmat', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (166, 'Schlieren', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (167, 'Uitikon', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (168, 'Unterengstringen', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (169, 'Urdorf', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (170, 'Weiningen (ZH)', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (171, 'Zürich', 'Zürich', 1);
INSERT INTO `ss_locations` VALUES (172, 'Aarberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (173, 'Bargen (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (174, 'Grossaffoltern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (175, 'Kallnach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (176, 'Kappelen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (177, 'Lyss', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (178, 'Meikirch', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (179, 'Niederried bei Kallnach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (180, 'Radelfingen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (181, 'Rapperswil (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (182, 'Schüpfen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (183, 'Seedorf (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (184, 'Aarwangen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (185, 'Auswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (186, 'Bannwil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (187, 'Bleienbach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (188, 'Busswil bei Melchnau', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (189, 'Gondiswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (190, 'Gutenburg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (191, 'Kleindietwil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (192, 'Langenthal', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (193, 'Leimiswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (194, 'Lotzwil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (195, 'Madiswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (196, 'Melchnau', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (197, 'Obersteckholz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (198, 'Oeschenbach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (199, 'Reisiswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (200, 'Roggwil (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (201, 'Rohrbach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (202, 'Rohrbachgraben', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (203, 'Rütschelen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (204, 'Schwarzhäusern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (205, 'Thunstetten', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (206, 'Untersteckholz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (207, 'Ursenbach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (208, 'Wynau', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (209, 'Bern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (210, 'Bolligen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (211, 'Bremgarten bei Bern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (212, 'Kirchlindach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (213, 'Köniz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (214, 'Muri bei Bern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (215, 'Oberbalm', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (216, 'Stettlen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (217, 'Vechigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (218, 'Wohlen bei Bern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (219, 'Zollikofen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (220, 'Ittigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (221, 'Ostermundigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (222, 'Biel/Bienne', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (223, 'Evilard', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (224, 'Arch', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (225, 'Büetigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (226, 'Büren an der Aare', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (227, 'Busswil bei Büren', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (228, 'Diessbach bei Büren', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (229, 'Dotzigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (230, 'Lengnau (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (231, 'Leuzigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (232, 'Meienried', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (233, 'Meinisberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (234, 'Oberwil bei Büren', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (235, 'Pieterlen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (236, 'Rüti bei Büren', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (237, 'Wengi', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (238, 'Aefligen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (239, 'Alchenstorf', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (240, 'Bäriswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (241, 'Burgdorf', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (242, 'Ersigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (243, 'Hasle bei Burgdorf', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (244, 'Heimiswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (245, 'Hellsau', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (246, 'Hindelbank', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (247, 'Höchstetten', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (248, 'Kernenried', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (249, 'Kirchberg (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (250, 'Koppigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (251, 'Krauchthal', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (252, 'Lyssach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (253, 'Mötschwil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (254, 'Niederösch', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (255, 'Oberburg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (256, 'Oberösch', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (257, 'Rüdtligen-Alchenflüh', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (258, 'Rumendingen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (259, 'Rüti bei Lyssach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (260, 'Willadingen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (261, 'Wynigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (262, 'Corgémont', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (263, 'Cormoret', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (264, 'Cortébert', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (265, 'Courtelary', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (266, 'La Ferrière', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (267, 'La Heutte', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (268, 'Mont-Tramelan', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (269, 'Orvin', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (270, 'Péry', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (271, 'Plagne', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (272, 'Renan (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (273, 'Romont (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (274, 'Saint-Imier', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (275, 'Sonceboz-Sombeval', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (276, 'Sonvilier', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (277, 'Tramelan', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (278, 'Vauffelin', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (279, 'Villeret', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (280, 'Brüttelen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (281, 'Erlach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (282, 'Finsterhennen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (283, 'Gals', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (284, 'Gampelen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (285, 'Ins', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (286, 'Lüscherz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (287, 'Müntschemier', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (288, 'Siselen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (289, 'Treiten', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (290, 'Tschugg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (291, 'Vinelz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (292, 'Ballmoos', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (293, 'Bangerten', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (294, 'Bätterkinden', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (295, 'Büren zum Hof', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (296, 'Deisswil bei Münchenbuchsee', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (297, 'Diemerswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (298, 'Etzelkofen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (299, 'Fraubrunnen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (300, 'Grafenried', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (301, 'Jegenstorf', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (302, 'Iffwil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (303, 'Limpach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (304, 'Mattstetten', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (305, 'Moosseedorf', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (306, 'Mülchi', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (307, 'Münchenbuchsee', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (308, 'Münchringen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (309, 'Ruppoldsried', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (310, 'Schalunen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (311, 'Scheunen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (312, 'Urtenen-Schönbühl', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (313, 'Utzenstorf', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (314, 'Wiggiswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (315, 'Wiler bei Utzenstorf', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (316, 'Zauggenried', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (317, 'Zielebach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (318, 'Zuzwil (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (319, 'Adelboden', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (320, 'Aeschi bei Spiez', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (321, 'Frutigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (322, 'Kandergrund', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (323, 'Kandersteg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (324, 'Krattigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (325, 'Reichenbach im Kandertal', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (326, 'Beatenberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (327, 'Bönigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (328, 'Brienz (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (329, 'Brienzwiler', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (330, 'Därligen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (331, 'Grindelwald', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (332, 'Gsteigwiler', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (333, 'Gündlischwand', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (334, 'Habkern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (335, 'Hofstetten bei Brienz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (336, 'Interlaken', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (337, 'Iseltwald', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (338, 'Lauterbrunnen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (339, 'Leissigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (340, 'Lütschental', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (341, 'Matten bei Interlaken', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (342, 'Niederried bei Interlaken', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (343, 'Oberried am Brienzersee', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (344, 'Ringgenberg (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (345, 'Saxeten', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (346, 'Schwanden bei Brienz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (347, 'Unterseen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (348, 'Wilderswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (349, 'Aeschlen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (350, 'Arni (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (351, 'Biglen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (352, 'Bleiken bei Oberdiessbach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (353, 'Bowil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (354, 'Brenzikofen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (355, 'Freimettigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (356, 'Grosshöchstetten', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (357, 'Häutligen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (358, 'Herbligen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (359, 'Kiesen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (360, 'Konolfingen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (361, 'Landiswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (362, 'Linden', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (363, 'Mirchel', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (364, 'Münsingen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (365, 'Niederhünigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (366, 'Oberdiessbach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (367, 'Oberthal', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (368, 'Oppligen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (369, 'Rubigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (370, 'Schlosswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (371, 'Tägertschi', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (372, 'Walkringen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (373, 'Worb', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (374, 'Zäziwil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (375, 'Oberhünigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (376, 'Allmendingen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (377, 'Trimstein', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (378, 'Wichtrach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (379, 'Clavaleyres', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (380, 'Ferenbalm', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (381, 'Frauenkappelen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (382, 'Golaten', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (383, 'Gurbrü', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (384, 'Kriechenwil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (385, 'Laupen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (386, 'Mühleberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (387, 'Münchenwiler', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (388, 'Neuenegg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (389, 'Wileroltigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (390, 'Belprahon', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (391, 'Bévilard', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (392, 'Champoz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (393, 'Châtelat', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (394, 'Corcelles (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (395, 'Court', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (396, 'Crémines', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (397, 'Eschert', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (398, 'Grandval', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (399, 'Loveresse', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (400, 'Malleray', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (401, 'Monible', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (402, 'Moutier', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (403, 'Perrefitte', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (404, 'Pontenet', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (405, 'Reconvilier', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (406, 'Roches (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (407, 'Saicourt', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (408, 'Saules (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (409, 'Schelten', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (410, 'Seehof', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (411, 'Sornetan', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (412, 'Sorvilier', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (413, 'Souboz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (414, 'Tavannes', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (415, 'Rebévelier', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (416, 'Diesse', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (417, 'Lamboing', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (418, 'La Neuveville', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (419, 'Nods', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (420, 'Prêles', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (421, 'Aegerten', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (422, 'Bellmund', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (423, 'Brügg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (424, 'Bühl', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (425, 'Epsach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (426, 'Hagneck', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (427, 'Hermrigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (428, 'Jens', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (429, 'Ipsach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (430, 'Ligerz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (431, 'Merzligen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (432, 'Mörigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (433, 'Nidau', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (434, 'Orpund', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (435, 'Port', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (436, 'Safnern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (437, 'Scheuren', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (438, 'Schwadernau', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (439, 'Studen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (440, 'Sutz-Lattrigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (441, 'Täuffelen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (442, 'Tüscherz-Alfermée', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (443, 'Twann', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (444, 'Walperswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (445, 'Worben', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (446, 'Därstetten', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (447, 'Diemtigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (448, 'Erlenbach im Simmental', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (449, 'Niederstocken', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (450, 'Oberstocken', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (451, 'Oberwil im Simmental', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (452, 'Reutigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (453, 'Spiez', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (454, 'Wimmis', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (455, 'Gadmen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (456, 'Guttannen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (457, 'Hasliberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (458, 'Innertkirchen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (459, 'Meiringen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (460, 'Schattenhalb', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (461, 'Boltigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (462, 'Lenk', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (463, 'St. Stephan', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (464, 'Zweisimmen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (465, 'Gsteig', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (466, 'Lauenen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (467, 'Saanen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (468, 'Albligen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (469, 'Guggisberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (470, 'Rüschegg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (471, 'Wahlern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (472, 'Belp', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (473, 'Belpberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (474, 'Burgistein', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (475, 'Gelterfingen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (476, 'Gerzensee', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (477, 'Gurzelen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (478, 'Jaberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (479, 'Kaufdorf', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (480, 'Kehrsatz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (481, 'Kienersrüti', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (482, 'Kirchdorf (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (483, 'Kirchenthurnen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (484, 'Lohnstorf', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (485, 'Mühledorf (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (486, 'Mühlethurnen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (487, 'Niedermuhlern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (488, 'Noflen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (489, 'Riggisberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (490, 'Rüeggisberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (491, 'Rümligen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (492, 'Rüti bei Riggisberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (493, 'Seftigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (494, 'Toffen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (495, 'Uttigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (496, 'Wattenwil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (497, 'Wald (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (498, 'Eggiwil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (499, 'Langnau im Emmental', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (500, 'Lauperswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (501, 'Röthenbach im Emmental', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (502, 'Rüderswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (503, 'Schangnau', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (504, 'Signau', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (505, 'Trub', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (506, 'Trubschachen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (507, 'Amsoldingen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (508, 'Blumenstein', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (509, 'Buchholterberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (510, 'Eriz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (511, 'Fahrni', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (512, 'Forst', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (513, 'Heiligenschwendi', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (514, 'Heimberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (515, 'Hilterfingen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (516, 'Höfen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (517, 'Homberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (518, 'Horrenbach-Buchen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (519, 'Längenbühl', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (520, 'Oberhofen am Thunersee', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (521, 'Oberlangenegg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (522, 'Pohlern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (523, 'Schwendibach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (524, 'Sigriswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (525, 'Steffisburg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (526, 'Teuffenthal (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (527, 'Thierachern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (528, 'Thun', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (529, 'Uebeschi', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (530, 'Uetendorf', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (531, 'Unterlangenegg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (532, 'Wachseldorn', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (533, 'Zwieselberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (534, 'Affoltern im Emmental', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (535, 'Dürrenroth', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (536, 'Eriswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (537, 'Huttwil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (538, 'Lützelflüh', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (539, 'Rüegsau', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (540, 'Sumiswald', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (541, 'Trachselwald', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (542, 'Walterswil (BE)', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (543, 'Wyssachen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (544, 'Attiswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (545, 'Berken', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (546, 'Bettenhausen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (547, 'Bollodingen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (548, 'Farnern', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (549, 'Graben', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (550, 'Heimenhausen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (551, 'Hermiswil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (552, 'Herzogenbuchsee', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (553, 'Inkwil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (554, 'Niederbipp', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (555, 'Niederönz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (556, 'Oberbipp', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (557, 'Oberönz', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (558, 'Ochlenberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (559, 'Röthenbach bei Herzogenbuchsee', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (560, 'Rumisberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (561, 'Seeberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (562, 'Thörigen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (563, 'Walliswil bei Niederbipp', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (564, 'Walliswil bei Wangen', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (565, 'Wangen an der Aare', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (566, 'Wangenried', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (567, 'Wanzwil', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (568, 'Wiedlisbach', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (569, 'Wolfisberg', 'Bern / Berne', 1);
INSERT INTO `ss_locations` VALUES (570, 'Doppleschwand', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (571, 'Entlebuch', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (572, 'Escholzmatt', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (573, 'Flühli', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (574, 'Hasle (LU)', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (575, 'Marbach (LU)', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (576, 'Romoos', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (577, 'Schüpfheim', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (578, 'Werthenstein', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (579, 'Aesch (LU)', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (580, 'Altwis', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (581, 'Ballwil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (582, 'Emmen', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (583, 'Ermensee', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (584, 'Eschenbach (LU)', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (585, 'Gelfingen', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (586, 'Hämikon', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (587, 'Hitzkirch', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (588, 'Hochdorf', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (589, 'Hohenrain', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (590, 'Inwil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (591, 'Lieli', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (592, 'Mosen', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (593, 'Müswangen', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (594, 'Rain', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (595, 'Retschwil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (596, 'Römerswil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (597, 'Rothenburg', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (598, 'Schongau', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (599, 'Sulz (LU)', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (600, 'Adligenswil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (601, 'Buchrain', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (602, 'Dierikon', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (603, 'Ebikon', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (604, 'Gisikon', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (605, 'Greppen', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (606, 'Honau', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (607, 'Horw', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (608, 'Kriens', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (609, 'Littau', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (610, 'Luzern', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (611, 'Malters', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (612, 'Meggen', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (613, 'Meierskappel', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (614, 'Root', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (615, 'Schwarzenberg', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (616, 'Udligenswil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (617, 'Vitznau', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (618, 'Weggis', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (619, 'Beromünster', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (620, 'Büron', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (621, 'Buttisholz', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (622, 'Eich', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (623, 'Geuensee', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (624, 'Grosswangen', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (625, 'Gunzwil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (626, 'Hildisrieden', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (627, 'Knutwil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (628, 'Mauensee', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (629, 'Neudorf', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (630, 'Neuenkirch', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (631, 'Nottwil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (632, 'Oberkirch', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (633, 'Pfeffikon', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (634, 'Rickenbach (LU)', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (635, 'Ruswil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (636, 'Schenkon', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (637, 'Schlierbach', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (638, 'Sempach', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (639, 'Sursee', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (640, 'Triengen', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (641, 'Winikon', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (642, 'Wolhusen', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (643, 'Alberswil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (644, 'Altbüron', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (645, 'Altishofen', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (646, 'Buchs (LU)', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (647, 'Dagmersellen', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (648, 'Ebersecken', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (649, 'Egolzwil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (650, 'Ettiswil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (651, 'Fischbach', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (652, 'Gettnau', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (653, 'Grossdietwil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (654, 'Hergiswil bei Willisau', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (655, 'Kottwil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (656, 'Langnau bei Reiden', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (657, 'Luthern', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (658, 'Menznau', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (659, 'Nebikon', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (660, 'Ohmstal', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (661, 'Pfaffnau', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (662, 'Reiden', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (663, 'Richenthal', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (664, 'Roggliswil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (665, 'Schötz', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (666, 'Uffikon', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (667, 'Ufhusen', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (668, 'Wauwil', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (669, 'Wikon', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (670, 'Willisau Land', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (671, 'Willisau Stadt', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (672, 'Zell (LU)', 'Luzern', 1);
INSERT INTO `ss_locations` VALUES (673, 'Altdorf (UR)', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (674, 'Andermatt', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (675, 'Attinghausen', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (676, 'Bauen', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (677, 'Bürglen (UR)', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (678, 'Erstfeld', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (679, 'Flüelen', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (680, 'Göschenen', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (681, 'Gurtnellen', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (682, 'Hospental', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (683, 'Isenthal', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (684, 'Realp', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (685, 'Schattdorf', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (686, 'Seedorf (UR)', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (687, 'Seelisberg', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (688, 'Silenen', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (689, 'Sisikon', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (690, 'Spiringen', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (691, 'Unterschächen', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (692, 'Wassen', 'Uri', 1);
INSERT INTO `ss_locations` VALUES (693, 'Einsiedeln', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (694, 'Gersau', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (695, 'Feusisberg', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (696, 'Freienbach', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (697, 'Wollerau', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (698, 'Küssnacht (SZ)', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (699, 'Altendorf', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (700, 'Galgenen', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (701, 'Innerthal', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (702, 'Lachen', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (703, 'Reichenburg', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (704, 'Schübelbach', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (705, 'Tuggen', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (706, 'Vorderthal', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (707, 'Wangen (SZ)', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (708, 'Alpthal', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (709, 'Arth', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (710, 'Illgau', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (711, 'Ingenbohl', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (712, 'Lauerz', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (713, 'Morschach', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (714, 'Muotathal', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (715, 'Oberiberg', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (716, 'Riemenstalden', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (717, 'Rothenthurm', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (718, 'Sattel', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (719, 'Schwyz', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (720, 'Steinen', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (721, 'Steinerberg', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (722, 'Unteriberg', 'Schwyz', 1);
INSERT INTO `ss_locations` VALUES (723, 'Alpnach', 'Obwalden', 1);
INSERT INTO `ss_locations` VALUES (724, 'Engelberg', 'Obwalden', 1);
INSERT INTO `ss_locations` VALUES (725, 'Giswil', 'Obwalden', 1);
INSERT INTO `ss_locations` VALUES (726, 'Kerns', 'Obwalden', 1);
INSERT INTO `ss_locations` VALUES (727, 'Lungern', 'Obwalden', 1);
INSERT INTO `ss_locations` VALUES (728, 'Sachseln', 'Obwalden', 1);
INSERT INTO `ss_locations` VALUES (729, 'Sarnen', 'Obwalden', 1);
INSERT INTO `ss_locations` VALUES (730, 'Beckenried', 'Nidwalden', 1);
INSERT INTO `ss_locations` VALUES (731, 'Buochs', 'Nidwalden', 1);
INSERT INTO `ss_locations` VALUES (732, 'Dallenwil', 'Nidwalden', 1);
INSERT INTO `ss_locations` VALUES (733, 'Emmetten', 'Nidwalden', 1);
INSERT INTO `ss_locations` VALUES (734, 'Ennetbürgen', 'Nidwalden', 1);
INSERT INTO `ss_locations` VALUES (735, 'Ennetmoos', 'Nidwalden', 1);
INSERT INTO `ss_locations` VALUES (736, 'Hergiswil (NW)', 'Nidwalden', 1);
INSERT INTO `ss_locations` VALUES (737, 'Oberdorf (NW)', 'Nidwalden', 1);
INSERT INTO `ss_locations` VALUES (738, 'Stans', 'Nidwalden', 1);
INSERT INTO `ss_locations` VALUES (739, 'Stansstad', 'Nidwalden', 1);
INSERT INTO `ss_locations` VALUES (740, 'Wolfenschiessen', 'Nidwalden', 1);
INSERT INTO `ss_locations` VALUES (741, 'Betschwanden', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (742, 'Bilten', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (743, 'Braunwald', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (744, 'Elm', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (745, 'Engi', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (746, 'Ennenda', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (747, 'Filzbach', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (748, 'Glarus', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (749, 'Haslen', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (750, 'Leuggelbach', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (751, 'Linthal', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (752, 'Luchsingen', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (753, 'Matt', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (754, 'Mitlödi', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (755, 'Mollis', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (756, 'Mühlehorn', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (757, 'Näfels', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (758, 'Netstal', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (759, 'Nidfurn', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (760, 'Niederurnen', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (761, 'Oberurnen', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (762, 'Obstalden', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (763, 'Riedern', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (764, 'Rüti (GL)', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (765, 'Schwanden (GL)', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (766, 'Schwändi', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (767, 'Sool', 'Glarus', 1);
INSERT INTO `ss_locations` VALUES (768, 'Baar', 'Zug', 1);
INSERT INTO `ss_locations` VALUES (769, 'Cham', 'Zug', 1);
INSERT INTO `ss_locations` VALUES (770, 'Hünenberg', 'Zug', 1);
INSERT INTO `ss_locations` VALUES (771, 'Menzingen', 'Zug', 1);
INSERT INTO `ss_locations` VALUES (772, 'Neuheim', 'Zug', 1);
INSERT INTO `ss_locations` VALUES (773, 'Oberägeri', 'Zug', 1);
INSERT INTO `ss_locations` VALUES (774, 'Risch', 'Zug', 1);
INSERT INTO `ss_locations` VALUES (775, 'Steinhausen', 'Zug', 1);
INSERT INTO `ss_locations` VALUES (776, 'Unterägeri', 'Zug', 1);
INSERT INTO `ss_locations` VALUES (777, 'Walchwil', 'Zug', 1);
INSERT INTO `ss_locations` VALUES (778, 'Zug', 'Zug', 1);
INSERT INTO `ss_locations` VALUES (779, 'Autavaux', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (780, 'Bollion', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (781, 'Bussy (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (782, 'Châbles', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (783, 'Châtillon (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (784, 'Cheiry', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (785, 'Cheyres', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (786, 'Cugy (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (787, 'Domdidier', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (788, 'Dompierre (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (789, 'Estavayer-le-Lac', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (790, 'Fétigny', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (791, 'Font', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (792, 'Forel (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (793, 'Gletterens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (794, 'Léchelles', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (795, 'Lully (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (796, 'Ménières', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (797, 'Montagny (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (798, 'Montbrelloz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (799, 'Morens (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (800, 'Murist', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (801, 'Nuvilly', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (802, 'Prévondavaux', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (803, 'Rueyres-les-Prés', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (804, 'Russy', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (805, 'Saint-Aubin (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (806, 'Seiry', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (807, 'Sévaz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (808, 'Surpierre', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (809, 'Vallon', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (810, 'Villeneuve (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (811, 'Vuissens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (812, 'Les Montets', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (813, 'Delley-Portalban', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (814, 'Auboranges', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (815, 'Billens-Hennens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (816, 'Chapelle (Glâne)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (817, 'Le Châtelard', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (818, 'Châtonnaye', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (819, 'Ecublens (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (820, 'Esmonts', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (821, 'Grangettes', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (822, 'Massonnens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (823, 'Mézières (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (824, 'Montet (Glâne)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (825, 'Romont (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (826, 'Rue', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (827, 'Siviriez', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (828, 'Ursy', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (829, 'Villaz-Saint-Pierre', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (830, 'Vuarmarens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (831, 'Vuisternens-devant-Romont', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (832, 'Villorsonnens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (833, 'Torny', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (834, 'La Folliaz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (835, 'Haut-Intyamon', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (836, 'Pont-en-Ogoz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (837, 'Botterens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (838, 'Broc', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (839, 'Bulle', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (840, 'Cerniat (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (841, 'Charmey', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (842, 'Châtel-sur-Montsalvens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (843, 'Corbières', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (844, 'Crésuz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (845, 'Echarlens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (846, 'Grandvillard', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (847, 'Gruyères', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (848, 'Hauteville', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (849, 'Jaun', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (850, 'Marsens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (851, 'Morlon', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (852, 'Le Pâquier (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (853, 'Pont-la-Ville', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (854, 'Riaz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (855, 'La Roche', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (856, 'Sâles', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (857, 'Sorens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (858, 'La Tour-de-Trême', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (859, 'Vaulruz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (860, 'Villarbeney', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (861, 'Villarvolard', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (862, 'Vuadens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (863, 'Bas-Intyamon', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (864, 'Arconciel', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (865, 'Autafond', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (866, 'Autigny', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (867, 'Avry', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (868, 'Belfaux', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (869, 'Chénens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (870, 'Chésopelloz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (871, 'Corminboeuf', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (872, 'Corpataux-Magnedens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (873, 'Corserey', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (874, 'Cottens (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (875, 'Ependes (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (876, 'Farvagny', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (877, 'Ferpicloz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (878, 'Fribourg', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (879, 'Givisiez', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (880, 'Granges-Paccot', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (881, 'Grolley', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (882, 'Marly', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (883, 'Matran', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (884, 'Neyruz (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (885, 'Noréaz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (886, 'Pierrafortscha', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (887, 'Ponthaux', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (888, 'Le Mouret', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (889, 'Prez-vers-Noréaz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (890, 'Rossens (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (891, 'Le Glèbe', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (892, 'Senèdes', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (893, 'Treyvaux', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (894, 'Villars-sur-Glâne', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (895, 'Villarsel-sur-Marly', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (896, 'Vuisternens-en-Ogoz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (897, 'Hauterive (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (898, 'La Brillaz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (899, 'La Sonnaz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (900, 'Agriswil', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (901, 'Barberêche', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (902, 'Büchslen', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (903, 'Courgevaux', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (904, 'Courlevon', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (905, 'Courtepin', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (906, 'Cressier (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (907, 'Fräschels', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (908, 'Galmiz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (909, 'Gempenach', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (910, 'Greng', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (911, 'Gurmels', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (912, 'Jeuss', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (913, 'Kerzers', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (914, 'Kleinbösingen', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (915, 'Lurtigen', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (916, 'Meyriez', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (917, 'Misery-Courtion', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (918, 'Muntelier', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (919, 'Murten', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (920, 'Ried bei Kerzers', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (921, 'Salvenach', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (922, 'Ulmiz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (923, 'Villarepos', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (924, 'Bas-Vully', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (925, 'Haut-Vully', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (926, 'Wallenried', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (927, 'Alterswil', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (928, 'Brünisried', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (929, 'Düdingen', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (930, 'Giffers', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (931, 'Bösingen', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (932, 'Heitenried', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (933, 'Oberschrot', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (934, 'Plaffeien', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (935, 'Plasselb', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (936, 'Rechthalten', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (937, 'St. Antoni', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (938, 'St. Silvester', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (939, 'St. Ursen', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (940, 'Schmitten (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (941, 'Tafers', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (942, 'Tentlingen', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (943, 'Ueberstorf', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (944, 'Wünnewil-Flamatt', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (945, 'Zumholz', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (946, 'Attalens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (947, 'Bossonnens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (948, 'Châtel-Saint-Denis', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (949, 'Granges (Veveyse)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (950, 'Remaufens', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (951, 'Saint-Martin (FR)', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (952, 'Semsales', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (953, 'Le Flon', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (954, 'La Verrerie', 'Fribourg / Freiburg', 1);
INSERT INTO `ss_locations` VALUES (955, 'Egerkingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (956, 'Härkingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (957, 'Kestenholz', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (958, 'Neuendorf', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (959, 'Niederbuchsiten', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (960, 'Oberbuchsiten', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (961, 'Oensingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (962, 'Wolfwil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (963, 'Aedermannsdorf', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (964, 'Balsthal', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (965, 'Gänsbrunnen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (966, 'Herbetswil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (967, 'Holderbank (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (968, 'Laupersdorf', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (969, 'Matzendorf', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (970, 'Mümliswil-Ramiswil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (971, 'Welschenrohr', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (972, 'Aetigkofen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (973, 'Aetingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (974, 'Balm bei Messen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (975, 'Bibern (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (976, 'Biezwil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (977, 'Brügglen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (978, 'Brunnenthal', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (979, 'Gossliwil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (980, 'Hessigkofen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (981, 'Küttigkofen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (982, 'Kyburg-Buchegg', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (983, 'Lüsslingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (984, 'Lüterkofen-Ichertswil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (985, 'Lüterswil-Gächliwil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (986, 'Messen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (987, 'Mühledorf (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (988, 'Nennigkofen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (989, 'Oberramsern', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (990, 'Schnottwil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (991, 'Tscheppach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (992, 'Unterramsern', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (993, 'Bättwil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (994, 'Büren (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (995, 'Dornach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (996, 'Gempen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (997, 'Hochwald', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (998, 'Hofstetten-Flüh', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (999, 'Metzerlen-Mariastein', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1000, 'Nuglar-St. Pantaleon', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1001, 'Rodersdorf', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1002, 'Seewen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1003, 'Witterswil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1004, 'Hauenstein-Ifenthal', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1005, 'Kienberg', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1006, 'Lostorf', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1007, 'Niedererlinsbach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1008, 'Niedergösgen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1009, 'Obererlinsbach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1010, 'Obergösgen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1011, 'Rohr (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1012, 'Stüsslingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1013, 'Trimbach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1014, 'Winznau', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1015, 'Wisen (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1016, 'Aeschi (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1017, 'Biberist', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1018, 'Bolken', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1019, 'Deitingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1020, 'Derendingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1021, 'Etziken', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1022, 'Gerlafingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1023, 'Halten', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1024, 'Heinrichswil-Winistorf', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1025, 'Hersiwil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1026, 'Horriwil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1027, 'Hüniken', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1028, 'Kriegstetten', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1029, 'Lohn-Ammannsegg', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1030, 'Luterbach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1031, 'Obergerlafingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1032, 'Oekingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1033, 'Recherswil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1034, 'Steinhof', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1035, 'Subingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1036, 'Zuchwil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1037, 'Balm bei Günsberg', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1038, 'Bellach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1039, 'Bettlach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1040, 'Feldbrunnen-St. Niklaus', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1041, 'Flumenthal', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1042, 'Grenchen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1043, 'Günsberg', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1044, 'Hubersdorf', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1045, 'Kammersrohr', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1046, 'Langendorf', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1047, 'Lommiswil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1048, 'Niederwil (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1049, 'Oberdorf (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1050, 'Riedholz', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1051, 'Rüttenen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1052, 'Selzach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1053, 'Boningen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1054, 'Däniken', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1055, 'Dulliken', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1056, 'Eppenberg-Wöschnau', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1057, 'Fulenbach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1058, 'Gretzenbach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1059, 'Gunzgen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1060, 'Hägendorf', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1061, 'Kappel (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1062, 'Olten', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1063, 'Rickenbach (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1064, 'Schönenwerd', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1065, 'Starrkirch-Wil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1066, 'Walterswil (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1067, 'Wangen bei Olten', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1068, 'Solothurn', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1069, 'Bärschwil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1070, 'Beinwil (SO)', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1071, 'Breitenbach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1072, 'Büsserach', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1073, 'Erschwil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1074, 'Fehren', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1075, 'Grindel', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1076, 'Himmelried', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1077, 'Kleinlützel', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1078, 'Meltingen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1079, 'Nunningen', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1080, 'Zullwil', 'Solothurn', 1);
INSERT INTO `ss_locations` VALUES (1081, 'Basel', 'Basel-Stadt', 1);
INSERT INTO `ss_locations` VALUES (1082, 'Bettingen', 'Basel-Stadt', 1);
INSERT INTO `ss_locations` VALUES (1083, 'Riehen', 'Basel-Stadt', 1);
INSERT INTO `ss_locations` VALUES (1084, 'Aesch (BL)', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1085, 'Allschwil', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1086, 'Arlesheim', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1087, 'Biel-Benken', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1088, 'Binningen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1089, 'Birsfelden', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1090, 'Bottmingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1091, 'Ettingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1092, 'Münchenstein', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1093, 'Muttenz', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1094, 'Oberwil (BL)', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1095, 'Pfeffingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1096, 'Reinach (BL)', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1097, 'Schönenbuch', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1098, 'Therwil', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1099, 'Blauen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1100, 'Brislach', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1101, 'Burg im Leimental', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1102, 'Dittingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1103, 'Duggingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1104, 'Grellingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1105, 'Laufen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1106, 'Liesberg', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1107, 'Nenzlingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1108, 'Roggenburg', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1109, 'Röschenz', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1110, 'Wahlen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1111, 'Zwingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1112, 'Arisdorf', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1113, 'Augst', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1114, 'Bubendorf', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1115, 'Frenkendorf', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1116, 'Füllinsdorf', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1117, 'Giebenach', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1118, 'Hersberg', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1119, 'Lausen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1120, 'Liestal', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1121, 'Lupsingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1122, 'Pratteln', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1123, 'Ramlinsburg', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1124, 'Seltisberg', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1125, 'Ziefen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1126, 'Anwil', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1127, 'Böckten', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1128, 'Buckten', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1129, 'Buus', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1130, 'Diepflingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1131, 'Gelterkinden', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1132, 'Häfelfingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1133, 'Hemmiken', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1134, 'Itingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1135, 'Känerkinden', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1136, 'Kilchberg (BL)', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1137, 'Läufelfingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1138, 'Maisprach', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1139, 'Nusshof', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1140, 'Oltingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1141, 'Ormalingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1142, 'Rickenbach (BL)', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1143, 'Rothenfluh', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1144, 'Rümlingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1145, 'Rünenberg', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1146, 'Sissach', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1147, 'Tecknau', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1148, 'Tenniken', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1149, 'Thürnen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1150, 'Wenslingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1151, 'Wintersingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1152, 'Wittinsburg', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1153, 'Zeglingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1154, 'Zunzgen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1155, 'Arboldswil', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1156, 'Bennwil', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1157, 'Bretzwil', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1158, 'Diegten', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1159, 'Eptingen', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1160, 'Hölstein', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1161, 'Lampenberg', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1162, 'Langenbruck', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1163, 'Lauwil', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1164, 'Liedertswil', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1165, 'Niederdorf', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1166, 'Oberdorf (BL)', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1167, 'Reigoldswil', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1168, 'Titterten', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1169, 'Waldenburg', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (1170, 'Gächlingen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1171, 'Guntmadingen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1172, 'Löhningen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1173, 'Neunkirch', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1174, 'Altdorf (SH)', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1175, 'Bibern (SH)', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1176, 'Büttenhardt', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1177, 'Dörflingen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1178, 'Hofen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1179, 'Lohn (SH)', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1180, 'Opfertshofen (SH)', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1181, 'Stetten (SH)', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1182, 'Thayngen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1183, 'Bargen (SH)', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1184, 'Beringen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1185, 'Buchberg', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1186, 'Hemmental', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1187, 'Merishausen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1188, 'Neuhausen am Rheinfall', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1189, 'Rüdlingen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1190, 'Schaffhausen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1191, 'Beggingen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1192, 'Schleitheim', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1193, 'Siblingen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1194, 'Buch (SH)', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1195, 'Hemishofen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1196, 'Ramsen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1197, 'Stein am Rhein', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1198, 'Hallau', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1199, 'Oberhallau', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1200, 'Trasadingen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1201, 'Wilchingen', 'Schaffhausen', 1);
INSERT INTO `ss_locations` VALUES (1202, 'Herisau', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1203, 'Hundwil', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1204, 'Schönengrund', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1205, 'Schwellbrunn', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1206, 'Stein (AR)', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1207, 'Urnäsch', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1208, 'Waldstatt', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1209, 'Bühler', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1210, 'Gais', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1211, 'Speicher', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1212, 'Teufen (AR)', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1213, 'Trogen', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1214, 'Grub (AR)', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1215, 'Heiden', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1216, 'Lutzenberg', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1217, 'Rehetobel', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1218, 'Reute (AR)', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1219, 'Wald (AR)', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1220, 'Walzenhausen', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1221, 'Wolfhalden', 'Appenzell Ausserrhoden', 1);
INSERT INTO `ss_locations` VALUES (1222, 'Appenzell', 'Appenzell Innerrhoden', 1);
INSERT INTO `ss_locations` VALUES (1223, 'Gonten', 'Appenzell Innerrhoden', 1);
INSERT INTO `ss_locations` VALUES (1224, 'Rüte', 'Appenzell Innerrhoden', 1);
INSERT INTO `ss_locations` VALUES (1225, 'Schlatt-Haslen', 'Appenzell Innerrhoden', 1);
INSERT INTO `ss_locations` VALUES (1226, 'Schwende', 'Appenzell Innerrhoden', 1);
INSERT INTO `ss_locations` VALUES (1227, 'Oberegg', 'Appenzell Innerrhoden', 1);
INSERT INTO `ss_locations` VALUES (1228, 'Häggenschwil', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1229, 'Muolen', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1230, 'St. Gallen', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1231, 'Wittenbach', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1232, 'Berg (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1233, 'Eggersriet', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1234, 'Goldach', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1235, 'Mörschwil', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1236, 'Rorschach', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1237, 'Rorschacherberg', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1238, 'Steinach', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1239, 'Tübach', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1240, 'Untereggen', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1241, 'Au (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1242, 'Balgach', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1243, 'Berneck', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1244, 'Diepoldsau', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1245, 'Rheineck', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1246, 'St. Margrethen', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1247, 'Thal', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1248, 'Widnau', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1249, 'Altstätten', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1250, 'Eichberg', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1251, 'Marbach (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1252, 'Oberriet (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1253, 'Rebstein', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1254, 'Rüthi (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1255, 'Buchs (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1256, 'Gams', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1257, 'Grabs', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1258, 'Sennwald', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1259, 'Sevelen', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1260, 'Wartau', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1261, 'Bad Ragaz', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1262, 'Flums', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1263, 'Mels', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1264, 'Pfäfers', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1265, 'Quarten', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1266, 'Sargans', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1267, 'Vilters-Wangs', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1268, 'Walenstadt', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1269, 'Amden', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1270, 'Benken (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1271, 'Kaltbrunn', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1272, 'Rieden', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1273, 'Schänis', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1274, 'Weesen', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1275, 'Ernetschwil', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1276, 'Eschenbach (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1277, 'Goldingen', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1278, 'Gommiswald', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1279, 'Jona', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1280, 'Rapperswil (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1281, 'St. Gallenkappel', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1282, 'Schmerikon', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1283, 'Uznach', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1284, 'Alt St. Johann', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1285, 'Ebnat-Kappel', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1286, 'Stein (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1287, 'Wildhaus', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1288, 'Nesslau-Krummenau', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1289, 'Brunnadern', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1290, 'Hemberg', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1291, 'Krinau', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1292, 'Lichtensteig', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1293, 'Oberhelfenschwil', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1294, 'St. Peterzell', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1295, 'Wattwil', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1296, 'Bütschwil', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1297, 'Kirchberg (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1298, 'Lütisburg', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1299, 'Mosnang', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1300, 'Degersheim', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1301, 'Flawil', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1302, 'Ganterschwil', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1303, 'Jonschwil', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1304, 'Mogelsberg', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1305, 'Oberuzwil', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1306, 'Uzwil', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1307, 'Bronschhofen', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1308, 'Niederbüren', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1309, 'Niederhelfenschwil', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1310, 'Oberbüren', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1311, 'Wil (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1312, 'Zuzwil (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1313, 'Andwil (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1314, 'Gaiserwald', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1315, 'Gossau (SG)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1316, 'Waldkirch', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (1317, 'Alvaschein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1318, 'Mon', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1319, 'Mutten', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1320, 'Stierva', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1321, 'Tiefencastel', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1322, 'Vaz/Obervaz', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1323, 'Alvaneu', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1324, 'Brienz/Brinzauls', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1325, 'Lantsch/Lenz', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1326, 'Schmitten (GR)', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1327, 'Surava', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1328, 'Bergün/Bravuogn', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1329, 'Filisur', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1330, 'Wiesen (GR)', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1331, 'Bivio', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1332, 'Cunter', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1333, 'Marmorera', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1334, 'Mulegns', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1335, 'Riom-Parsonz', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1336, 'Salouf', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1337, 'Savognin', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1338, 'Sur', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1339, 'Tinizong-Rona', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1340, 'Brusio', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1341, 'Poschiavo', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1342, 'Castrisch', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1343, 'Falera', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1344, 'Flond', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1345, 'Ilanz', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1346, 'Laax', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1347, 'Ladir', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1348, 'Luven', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1349, 'Pitasch', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1350, 'Riein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1351, 'Ruschein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1352, 'Sagogn', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1353, 'Schluein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1354, 'Schnaus', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1355, 'Sevgein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1356, 'Valendas', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1357, 'Versam', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1358, 'Cumbel', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1359, 'Duvin', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1360, 'Degen', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1361, 'Lumbrein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1362, 'Morissen', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1363, 'St. Martin', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1364, 'Suraua', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1365, 'Surcuolm', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1366, 'Vals', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1367, 'Vignogn', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1368, 'Vella', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1369, 'Vrin', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1370, 'Andiast', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1371, 'Obersaxen', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1372, 'Pigniu', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1373, 'Rueun', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1374, 'Siat', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1375, 'Waltensburg/Vuorz', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1376, 'Almens', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1377, 'Feldis/Veulden', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1378, 'Fürstenau', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1379, 'Paspels', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1380, 'Pratval', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1381, 'Rodels', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1382, 'Rothenbrunnen', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1383, 'Scharans', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1384, 'Scheid', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1385, 'Sils im Domleschg', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1386, 'Trans', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1387, 'Tumegl/Tomils', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1388, 'Safien', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1389, 'Tenna', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1390, 'Cazis', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1391, 'Flerden', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1392, 'Masein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1393, 'Portein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1394, 'Präz', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1395, 'Sarn', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1396, 'Tartar', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1397, 'Thusis', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1398, 'Tschappina', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1399, 'Urmein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1400, 'Avers', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1401, 'Hinterrhein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1402, 'Medels im Rheinwald', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1403, 'Nufenen', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1404, 'Splügen', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1405, 'Sufers', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1406, 'Andeer', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1407, 'Ausserferrera', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1408, 'Casti-Wergenstein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1409, 'Clugin', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1410, 'Donat', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1411, 'Innerferrera', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1412, 'Lohn (GR)', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1413, 'Mathon', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1414, 'Pignia', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1415, 'Rongellen', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1416, 'Zillis-Reischen', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1417, 'Bonaduz', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1418, 'Domat/Ems', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1419, 'Rhäzüns', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1420, 'Felsberg', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1421, 'Flims', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1422, 'Tamins', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1423, 'Trin', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1424, 'Ardez', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1425, 'Guarda', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1426, 'Lavin', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1427, 'Susch', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1428, 'Tarasp', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1429, 'Zernez', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1430, 'Ramosch', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1431, 'Samnaun', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1432, 'Tschlin', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1433, 'Ftan', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1434, 'Scuol', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1435, 'Sent', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1436, 'Bondo', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1437, 'Castasegna', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1438, 'Soglio', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1439, 'Stampa', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1440, 'Vicosoprano', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1441, 'Bever', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1442, 'Celerina/Schlarigna', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1443, 'Madulain', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1444, 'Pontresina', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1445, 'La Punt-Chamues-ch', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1446, 'Samedan', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1447, 'St. Moritz', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1448, 'S-chanf', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1449, 'Sils im Engadin/Segl', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1450, 'Silvaplana', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1451, 'Zuoz', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1452, 'Arvigo', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1453, 'Braggio', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1454, 'Buseno', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1455, 'Castaneda', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1456, 'Cauco', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1457, 'Rossa', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1458, 'Santa Maria in Calanca', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1459, 'Selma', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1460, 'Lostallo', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1461, 'Mesocco', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1462, 'Soazza', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1463, 'Cama', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1464, 'Grono', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1465, 'Leggia', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1466, 'Roveredo (GR)', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1467, 'San Vittore', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1468, 'Verdabbio', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1469, 'Fuldera', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1470, 'Lü', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1471, 'Müstair', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1472, 'Sta. Maria Val Müstair', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1473, 'Tschierv', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1474, 'Valchava', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1475, 'Davos', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1476, 'Fideris', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1477, 'Furna', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1478, 'Jenaz', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1479, 'Klosters-Serneus', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1480, 'Conters im Prättigau', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1481, 'Küblis', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1482, 'Saas', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1483, 'Luzein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1484, 'St. Antönien Ascharina', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1485, 'St. Antönien', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1486, 'Chur', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1487, 'Churwalden', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1488, 'Malix', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1489, 'Parpan', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1490, 'Praden', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1491, 'Tschiertschen', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1492, 'Arosa', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1493, 'Calfreisen', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1494, 'Castiel', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1495, 'Langwies', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1496, 'Lüen', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1497, 'Maladers', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1498, 'Molinis', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1499, 'Pagig', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1500, 'Peist', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1501, 'St. Peter', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1502, 'Haldenstein', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1503, 'Igis', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1504, 'Mastrils', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1505, 'Says', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1506, 'Trimmis', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1507, 'Untervaz', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1508, 'Zizers', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1509, 'Fläsch', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1510, 'Jenins', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1511, 'Maienfeld', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1512, 'Malans', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1513, 'Grüsch', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1514, 'Schiers', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1515, 'Fanas', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1516, 'Seewis im Prättigau', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1517, 'Valzeina', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1518, 'Breil/Brigels', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1519, 'Disentis/Mustér', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1520, 'Medel (Lucmagn)', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1521, 'Schlans', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1522, 'Sumvitg', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1523, 'Tujetsch', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1524, 'Trun', 'Graubünden / Grigioni', 1);
INSERT INTO `ss_locations` VALUES (1525, 'Aarau', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1526, 'Biberstein', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1527, 'Buchs (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1528, 'Densbüren', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1529, 'Erlinsbach', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1530, 'Gränichen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1531, 'Hirschthal', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1532, 'Küttigen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1533, 'Muhen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1534, 'Oberentfelden', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1535, 'Rohr (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1536, 'Suhr', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1537, 'Unterentfelden', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1538, 'Baden', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1539, 'Bellikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1540, 'Bergdietikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1541, 'Birmenstorf (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1542, 'Ennetbaden', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1543, 'Fislisbach', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1544, 'Freienwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1545, 'Gebenstorf', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1546, 'Killwangen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1547, 'Künten', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1548, 'Mägenwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1549, 'Mellingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1550, 'Neuenhof', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1551, 'Niederrohrdorf', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1552, 'Oberehrendingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1553, 'Oberrohrdorf', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1554, 'Obersiggenthal', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1555, 'Remetschwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1556, 'Spreitenbach', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1557, 'Stetten (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1558, 'Turgi', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1559, 'Unterehrendingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1560, 'Untersiggenthal', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1561, 'Wettingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1562, 'Wohlenschwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1563, 'Würenlingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1564, 'Würenlos', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1565, 'Arni (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1566, 'Berikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1567, 'Bremgarten (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1568, 'Büttikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1569, 'Dottikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1570, 'Eggenwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1571, 'Fischbach-Göslikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1572, 'Hägglingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1573, 'Hermetschwil-Staffeln', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1574, 'Hilfikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1575, 'Jonen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1576, 'Niederwil (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1577, 'Oberlunkhofen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1578, 'Oberwil-Lieli', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1579, 'Rudolfstetten-Friedlisberg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1580, 'Sarmenstorf', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1581, 'Tägerig', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1582, 'Uezwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1583, 'Unterlunkhofen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1584, 'Villmergen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1585, 'Widen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1586, 'Wohlen (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1587, 'Zufikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1588, 'Islisberg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1589, 'Auenstein', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1590, 'Birr', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1591, 'Birrhard', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1592, 'Bözen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1593, 'Brugg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1594, 'Effingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1595, 'Elfingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1596, 'Gallenkirch', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1597, 'Habsburg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1598, 'Hausen (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1599, 'Hottwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1600, 'Linn', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1601, 'Lupfig', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1602, 'Mandach', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1603, 'Mönthal', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1604, 'Mülligen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1605, 'Oberbözberg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1606, 'Oberflachs', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1607, 'Remigen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1608, 'Riniken', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1609, 'Rüfenach', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1610, 'Scherz', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1611, 'Schinznach-Bad', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1612, 'Schinznach-Dorf', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1613, 'Stilli', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1614, 'Thalheim (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1615, 'Umiken', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1616, 'Unterbözberg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1617, 'Veltheim (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1618, 'Villigen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1619, 'Villnachern', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1620, 'Windisch', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1621, 'Beinwil am See', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1622, 'Birrwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1623, 'Burg (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1624, 'Dürrenäsch', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1625, 'Gontenschwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1626, 'Holziken', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1627, 'Leimbach (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1628, 'Leutwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1629, 'Menziken', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1630, 'Oberkulm', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1631, 'Reinach (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1632, 'Schlossrued', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1633, 'Schmiedrued', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1634, 'Schöftland', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1635, 'Teufenthal (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1636, 'Unterkulm', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1637, 'Zetzwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1638, 'Eiken', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1639, 'Etzgen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1640, 'Frick', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1641, 'Gansingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1642, 'Gipf-Oberfrick', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1643, 'Herznach', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1644, 'Hornussen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1645, 'Ittenthal', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1646, 'Kaisten', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1647, 'Laufenburg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1648, 'Mettau', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1649, 'Münchwilen (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1650, 'Oberhof', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1651, 'Oberhofen (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1652, 'Oeschgen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1653, 'Schwaderloch', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1654, 'Sisseln', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1655, 'Sulz (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1656, 'Ueken', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1657, 'Wil (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1658, 'Wittnau', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1659, 'Wölflinswil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1660, 'Zeihen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1661, 'Ammerswil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1662, 'Boniswil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1663, 'Brunegg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1664, 'Dintikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1665, 'Egliswil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1666, 'Fahrwangen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1667, 'Hallwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1668, 'Hendschiken', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1669, 'Holderbank (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1670, 'Hunzenschwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1671, 'Lenzburg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1672, 'Meisterschwanden', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1673, 'Möriken-Wildegg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1674, 'Niederlenz', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1675, 'Othmarsingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1676, 'Rupperswil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1677, 'Schafisheim', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1678, 'Seengen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1679, 'Seon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1680, 'Staufen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1681, 'Abtwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1682, 'Aristau', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1683, 'Auw', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1684, 'Beinwil (Freiamt)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1685, 'Benzenschwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1686, 'Besenbüren', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1687, 'Bettwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1688, 'Boswil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1689, 'Bünzen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1690, 'Buttwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1691, 'Dietwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1692, 'Geltwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1693, 'Kallern', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1694, 'Merenschwand', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1695, 'Mühlau', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1696, 'Muri (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1697, 'Oberrüti', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1698, 'Rottenschwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1699, 'Sins', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1700, 'Waltenschwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1701, 'Hellikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1702, 'Kaiseraugst', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1703, 'Magden', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1704, 'Möhlin', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1705, 'Mumpf', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1706, 'Obermumpf', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1707, 'Olsberg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1708, 'Rheinfelden', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1709, 'Schupfart', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1710, 'Stein (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1711, 'Wallbach', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1712, 'Wegenstetten', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1713, 'Zeiningen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1714, 'Zuzgen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1715, 'Aarburg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1716, 'Attelwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1717, 'Bottenwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1718, 'Brittnau', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1719, 'Kirchleerau', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1720, 'Kölliken', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1721, 'Moosleerau', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1722, 'Murgenthal', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1723, 'Oftringen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1724, 'Reitnau', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1725, 'Rothrist', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1726, 'Safenwil', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1727, 'Staffelbach', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1728, 'Strengelbach', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1729, 'Uerkheim', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1730, 'Vordemwald', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1731, 'Wiliberg', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1732, 'Zofingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1733, 'Baldingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1734, 'Böbikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1735, 'Böttstein', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1736, 'Döttingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1737, 'Endingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1738, 'Fisibach', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1739, 'Full-Reuenthal', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1740, 'Kaiserstuhl', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1741, 'Klingnau', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1742, 'Koblenz', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1743, 'Leibstadt', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1744, 'Lengnau (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1745, 'Leuggern', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1746, 'Mellikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1747, 'Rekingen (AG)', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1748, 'Rietheim', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1749, 'Rümikon', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1750, 'Schneisingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1751, 'Siglistorf', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1752, 'Tegerfelden', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1753, 'Unterendingen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1754, 'Wislikofen', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1755, 'Zurzach', 'Aargau', 1);
INSERT INTO `ss_locations` VALUES (1756, 'Arbon', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1757, 'Dozwil', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1758, 'Egnach', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1759, 'Hefenhofen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1760, 'Horn', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1761, 'Kesswil', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1762, 'Roggwil (TG)', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1763, 'Romanshorn', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1764, 'Salmsach', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1765, 'Sommeri', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1766, 'Uttwil', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1767, 'Amriswil', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1768, 'Bischofszell', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1769, 'Erlen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1770, 'Hauptwil-Gottshaus', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1771, 'Hohentannen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1772, 'Kradolf-Schönenberg', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1773, 'Sulgen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1774, 'Zihlschlacht-Sitterdorf', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1775, 'Basadingen-Schlattingen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1776, 'Diessenhofen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1777, 'Schlatt (TG)', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1778, 'Aadorf', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1779, 'Felben-Wellhausen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1780, 'Frauenfeld', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1781, 'Gachnang', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1782, 'Hüttlingen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1783, 'Matzingen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1784, 'Neunforn', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1785, 'Stettfurt', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1786, 'Thundorf', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1787, 'Uesslingen-Buch', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1788, 'Warth-Weiningen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1789, 'Altnau', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1790, 'Bottighofen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1791, 'Ermatingen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1792, 'Gottlieben', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1793, 'Güttingen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1794, 'Kemmental', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1795, 'Kreuzlingen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1796, 'Langrickenbach', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1797, 'Lengwil', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1798, 'Münsterlingen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1799, 'Tägerwilen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1800, 'Wäldi', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1801, 'Affeltrangen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1802, 'Bettwiesen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1803, 'Bichelsee-Balterswil', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1804, 'Braunau', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1805, 'Eschlikon', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1806, 'Fischingen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1807, 'Lommis', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1808, 'Münchwilen (TG)', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1809, 'Rickenbach (TG)', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1810, 'Schönholzerswilen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1811, 'Sirnach', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1812, 'Tobel-Tägerschen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1813, 'Wängi', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1814, 'Wilen (TG)', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1815, 'Wuppenau', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1816, 'Berlingen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1817, 'Eschenz', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1818, 'Herdern', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1819, 'Homburg', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1820, 'Hüttwilen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1821, 'Mammern', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1822, 'Müllheim', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1823, 'Pfyn', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1824, 'Raperswilen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1825, 'Salenstein', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1826, 'Steckborn', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1827, 'Wagenhausen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1828, 'Amlikon-Bissegg', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1829, 'Berg (TG)', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1830, 'Birwinken', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1831, 'Bürglen (TG)', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1832, 'Bussnang', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1833, 'Märstetten', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1834, 'Weinfelden', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1835, 'Wigoltingen', 'Thurgau', 1);
INSERT INTO `ss_locations` VALUES (1836, 'Arbedo-Castione', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1837, 'Bellinzona', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1838, 'Cadenazzo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1839, 'Camorino', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1840, 'Giubiasco', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1841, 'Gnosca', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1842, 'Gorduno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1843, 'Gudo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1844, 'Isone', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1845, 'Lumino', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1846, 'Medeglia', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1847, 'Moleno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1848, 'Monte Carasso', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1849, 'Pianezzo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1850, 'Preonzo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1851, 'Sant\'Antonino', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1852, 'Sant\'Antonio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1853, 'Sementina', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1854, 'Aquila', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1855, 'Campo (Blenio)', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1856, 'Ghirone', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1857, 'Ludiano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1858, 'Malvaglia', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1859, 'Olivone', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1860, 'Semione', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1861, 'Torre', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1862, 'Acquarossa', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1863, 'Airolo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1864, 'Anzonico', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1865, 'Bedretto', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1866, 'Bodio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1867, 'Calonico', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1868, 'Calpiogna', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1869, 'Campello', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1870, 'Cavagnago', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1871, 'Chiggiogna', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1872, 'Chironico', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1873, 'Dalpe', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1874, 'Faido', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1875, 'Giornico', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1876, 'Mairengo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1877, 'Osco', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1878, 'Personico', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1879, 'Pollegio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1880, 'Prato (Leventina)', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1881, 'Quinto', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1882, 'Rossura', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1883, 'Sobrio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1884, 'Ascona', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1885, 'Borgnone', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1886, 'Brione (Verzasca)', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1887, 'Brione sopra Minusio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1888, 'Brissago', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1889, 'Caviano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1890, 'Cavigliano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1891, 'Contone', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1892, 'Corippo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1893, 'Cugnasco', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1894, 'Frasco', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1895, 'Gerra (Gambarogno)', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1896, 'Gerra (Verzasca)', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1897, 'Gordola', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1898, 'Gresso', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1899, 'Indemini', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1900, 'Intragna', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1901, 'Lavertezzo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1902, 'Locarno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1903, 'Losone', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1904, 'Magadino', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1905, 'Mergoscia', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1906, 'Minusio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1907, 'Mosogno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1908, 'Muralto', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1909, 'Orselina', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1910, 'Palagnedra', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1911, 'Piazzogna', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1912, 'Ronco sopra Ascona', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1913, 'San Nazzaro', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1914, 'Sant\'Abbondio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1915, 'Sonogno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1916, 'Tegna', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1917, 'Tenero-Contra', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1918, 'Vergeletto', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1919, 'Verscio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1920, 'Vira (Gambarogno)', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1921, 'Vogorno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1922, 'Onsernone', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1923, 'Isorno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1924, 'Agno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1925, 'Aranno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1926, 'Arogno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1927, 'Astano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1928, 'Barbengo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1929, 'Bedano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1930, 'Bedigliora', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1931, 'Bidogno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1932, 'Bioggio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1933, 'Bironico', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1934, 'Bissone', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1935, 'Bogno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1936, 'Brusino Arsizio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1937, 'Cademario', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1938, 'Cadempino', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1939, 'Cadro', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1940, 'Camignolo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1941, 'Canobbio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1942, 'Carabbia', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1943, 'Carabietta', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1944, 'Carona', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1945, 'Caslano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1946, 'Certara', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1947, 'Cimadera', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1948, 'Comano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1949, 'Corticiasca', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1950, 'Croglio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1951, 'Cureglia', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1952, 'Curio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1953, 'Grancia', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1954, 'Gravesano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1955, 'Iseo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1956, 'Lamone', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1957, 'Lugaggia', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1958, 'Lugano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1959, 'Magliaso', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1960, 'Manno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1961, 'Maroggia', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1962, 'Massagno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1963, 'Melano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1964, 'Melide', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1965, 'Mezzovico-Vira', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1966, 'Miglieglia', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1967, 'Monteggio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1968, 'Morcote', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1969, 'Muzzano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1970, 'Neggio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1971, 'Novaggio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1972, 'Origlio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1973, 'Paradiso', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1974, 'Ponte Capriasca', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1975, 'Ponte Tresa', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1976, 'Porza', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1977, 'Pura', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1978, 'Rivera', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1979, 'Rovio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1980, 'Savosa', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1981, 'Sessa', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1982, 'Sigirino', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1983, 'Sonvico', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1984, 'Sorengo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1985, 'Capriasca', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1986, 'Torricella-Taverne', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1987, 'Valcolla', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1988, 'Vernate', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1989, 'Vezia', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1990, 'Vico Morcote', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1991, 'Villa Luganese', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1992, 'Collina d\'Oro', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1993, 'Alto Malcantone', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1994, 'Arzo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1995, 'Balerna', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1996, 'Besazio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1997, 'Bruzella', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1998, 'Cabbio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (1999, 'Caneggio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2000, 'Capolago', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2001, 'Castel San Pietro', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2002, 'Chiasso', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2003, 'Coldrerio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2004, 'Genestrerio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2005, 'Ligornetto', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2006, 'Mendrisio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2007, 'Meride', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2008, 'Morbio Inferiore', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2009, 'Morbio Superiore', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2010, 'Muggio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2011, 'Novazzano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2012, 'Rancate', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2013, 'Riva San Vitale', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2014, 'Sagno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2015, 'Stabio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2016, 'Tremona', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2017, 'Vacallo', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2018, 'Biasca', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2019, 'Claro', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2020, 'Cresciano', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2021, 'Iragna', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2022, 'Lodrino', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2023, 'Osogna', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2024, 'Avegno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2025, 'Bignasco', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2026, 'Bosco/Gurin', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2027, 'Campo (Vallemaggia)', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2028, 'Cavergno', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2029, 'Cerentino', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2030, 'Cevio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2031, 'Gordevio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2032, 'Linescio', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2033, 'Maggia', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2034, 'Lavizzara', 'Ticino', 1);
INSERT INTO `ss_locations` VALUES (2035, 'Aigle', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2036, 'Bex', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2037, 'Chessel', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2038, 'Corbeyrier', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2039, 'Gryon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2040, 'Lavey-Morcles', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2041, 'Leysin', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2042, 'Noville', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2043, 'Ollon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2044, 'Ormont-Dessous', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2045, 'Ormont-Dessus', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2046, 'Rennaz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2047, 'Roche (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2048, 'Villeneuve (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2049, 'Yvorne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2050, 'Apples', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2051, 'Aubonne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2052, 'Ballens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2053, 'Berolle', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2054, 'Bière', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2055, 'Bougy-Villars', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2056, 'Féchy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2057, 'Gimel', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2058, 'Longirod', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2059, 'Marchissy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2060, 'Mollens (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2061, 'Montherod', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2062, 'Pizy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2063, 'Saint-George', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2064, 'Saint-Livres', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2065, 'Saint-Oyens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2066, 'Saubraz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2067, 'Avenches', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2068, 'Bellerive (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2069, 'Chabrey', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2070, 'Constantine', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2071, 'Cudrefin', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2072, 'Donatyre', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2073, 'Faoug', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2074, 'Montmagny', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2075, 'Mur (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2076, 'Oleyres', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2077, 'Vallamand', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2078, 'Villars-le-Grand', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2079, 'Bettens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2080, 'Bournens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2081, 'Boussens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2082, 'La Chaux (Cossonay)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2083, 'Chavannes-le-Veyron', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2084, 'Chevilly', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2085, 'Cossonay', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2086, 'Cottens (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2087, 'Cuarnens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2088, 'Daillens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2089, 'Dizy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2090, 'Eclépens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2091, 'Ferreyres', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2092, 'Gollion', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2093, 'Grancy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2094, 'L\'Isle', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2095, 'Lussery-Villars', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2096, 'Mauraz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2097, 'Mex (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2098, 'Moiry', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2099, 'Mont-la-Ville', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2100, 'Montricher', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2101, 'Orny', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2102, 'Pampigny', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2103, 'Penthalaz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2104, 'Penthaz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2105, 'Pompaples', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2106, 'La Sarraz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2107, 'Senarclens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2108, 'Sévery', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2109, 'Sullens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2110, 'Vufflens-la-Ville', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2111, 'Assens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2112, 'Bercher', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2113, 'Bioley-Orjulaz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2114, 'Bottens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2115, 'Bretigny-sur-Morrens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2116, 'Cugy (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2117, 'Dommartin', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2118, 'Echallens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2119, 'Eclagnens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2120, 'Essertines-sur-Yverdon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2121, 'Etagnières', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2122, 'Fey', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2123, 'Froideville', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2124, 'Goumoens-la-Ville', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2125, 'Goumoens-le-Jux', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2126, 'Malapalud', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2127, 'Morrens (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2128, 'Naz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2129, 'Oulens-sous-Echallens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2130, 'Pailly', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2131, 'Penthéréaz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2132, 'Poliez-le-Grand', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2133, 'Poliez-Pittet', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2134, 'Rueyres', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2135, 'Saint-Barthélemy (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2136, 'Sugnens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2137, 'Villars-le-Terroir', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2138, 'Villars-Tiercelin', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2139, 'Vuarrens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2140, 'Bonvillars', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2141, 'Bullet', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2142, 'Champagne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2143, 'Concise', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2144, 'Corcelles-près-Concise', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2145, 'Fiez', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2146, 'Fontaines-sur-Grandson', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2147, 'Fontanezier', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2148, 'Giez', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2149, 'Grandevent', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2150, 'Grandson', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2151, 'Mauborget', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2152, 'Mutrux', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2153, 'Novalles', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2154, 'Onnens (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2155, 'Provence', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2156, 'Romairon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2157, 'Sainte-Croix', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2158, 'Vaugondry', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2159, 'Villars-Burquin', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2160, 'Belmont-sur-Lausanne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2161, 'Cheseaux-sur-Lausanne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2162, 'Crissier', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2163, 'Epalinges', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2164, 'Jouxtens-Mézery', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2165, 'Lausanne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2166, 'Le Mont-sur-Lausanne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2167, 'Paudex', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2168, 'Prilly', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2169, 'Pully', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2170, 'Renens (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2171, 'Romanel-sur-Lausanne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2172, 'Chexbres', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2173, 'Cully', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2174, 'Epesses', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2175, 'Forel (Lavaux)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2176, 'Grandvaux', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2177, 'Lutry', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2178, 'Puidoux', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2179, 'Riex', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2180, 'Rivaz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2181, 'Saint-Saphorin (Lavaux)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2182, 'Savigny', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2183, 'Villette (Lavaux)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2184, 'Aclens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2185, 'Bremblens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2186, 'Buchillon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2187, 'Bussigny-près-Lausanne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2188, 'Bussy-Chardonney', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2189, 'Chavannes-près-Renens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2190, 'Chigny', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2191, 'Clarmont', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2192, 'Colombier (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2193, 'Denens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2194, 'Denges', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2195, 'Echandens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2196, 'Echichens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2197, 'Ecublens (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2198, 'Etoy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2199, 'Lavigny', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2200, 'Lonay', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2201, 'Lully (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2202, 'Lussy-sur-Morges', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2203, 'Monnaz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2204, 'Morges', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2205, 'Préverenges', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2206, 'Reverolle', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2207, 'Romanel-sur-Morges', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2208, 'Saint-Prex', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2209, 'Saint-Saphorin-sur-Morges', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2210, 'Saint-Sulpice (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2211, 'Tolochenaz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2212, 'Vaux-sur-Morges', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2213, 'Villars-Sainte-Croix', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2214, 'Villars-sous-Yens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2215, 'Vufflens-le-Château', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2216, 'Vullierens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2217, 'Yens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2218, 'Boulens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2219, 'Brenles', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2220, 'Bussy-sur-Moudon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2221, 'Chapelle-sur-Moudon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2222, 'Chavannes-sur-Moudon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2223, 'Chesalles-sur-Moudon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2224, 'Correvon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2225, 'Cremin', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2226, 'Curtilles', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2227, 'Denezy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2228, 'Dompierre (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2229, 'Forel-sur-Lucens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2230, 'Hermenches', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2231, 'Lovatens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2232, 'Lucens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2233, 'Martherenges', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2234, 'Montaubion-Chardonney', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2235, 'Moudon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2236, 'Neyruz-sur-Moudon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2237, 'Ogens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2238, 'Oulens-sur-Lucens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2239, 'Peyres-Possens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2240, 'Prévonloup', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2241, 'Rossenges', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2242, 'Saint-Cierges', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2243, 'Sarzens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2244, 'Sottens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2245, 'Syens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2246, 'Thierrens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2247, 'Villars-le-Comte', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2248, 'Villars-Mendraz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2249, 'Vucherens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2250, 'Arnex-sur-Nyon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2251, 'Arzier', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2252, 'Bassins', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2253, 'Begnins', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2254, 'Bogis-Bossey', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2255, 'Borex', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2256, 'Chavannes-de-Bogis', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2257, 'Chavannes-des-Bois', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2258, 'Chéserex', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2259, 'Coinsins', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2260, 'Commugny', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2261, 'Coppet', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2262, 'Crans-près-Céligny', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2263, 'Crassier', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2264, 'Duillier', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2265, 'Eysins', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2266, 'Founex', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2267, 'Genolier', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2268, 'Gingins', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2269, 'Givrins', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2270, 'Gland', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2271, 'Grens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2272, 'Mies', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2273, 'Nyon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2274, 'Prangins', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2275, 'La Rippe', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2276, 'Saint-Cergue', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2277, 'Signy-Avenex', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2278, 'Tannay', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2279, 'Trélex', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2280, 'Le Vaud', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2281, 'Vich', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2282, 'L\'Abergement', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2283, 'Agiez', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2284, 'Arnex-sur-Orbe', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2285, 'Ballaigues', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2286, 'Baulmes', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2287, 'Bavois', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2288, 'Bofflens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2289, 'Bretonnières', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2290, 'Chavornay', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2291, 'Les Clées', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2292, 'Corcelles-sur-Chavornay', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2293, 'Croy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2294, 'Juriens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2295, 'Lignerolle', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2296, 'Montcherand', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2297, 'Orbe', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2298, 'La Praz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2299, 'Premier', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2300, 'Rances', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2301, 'Romainmôtier-Envy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2302, 'Sergey', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2303, 'Valeyres-sous-Rances', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2304, 'Vallorbe', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2305, 'Vaulion', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2306, 'Vuiteboeuf', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2307, 'Bussigny-sur-Oron', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2308, 'Carrouge (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2309, 'Châtillens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2310, 'Chesalles-sur-Oron', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2311, 'Corcelles-le-Jorat', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2312, 'Les Cullayes', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2313, 'Ecoteaux', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2314, 'Essertes', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2315, 'Ferlens (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2316, 'Maracon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2317, 'Mézières (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2318, 'Montpreveyres', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2319, 'Oron-la-Ville', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2320, 'Oron-le-Châtel', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2321, 'Palézieux', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2322, 'Peney-le-Jorat', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2323, 'Ropraz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2324, 'Servion', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2325, 'Les Tavernes', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2326, 'Les Thioleyres', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2327, 'Vuibroye', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2328, 'Vulliens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2329, 'Cerniaz (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2330, 'Champtauroz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2331, 'Chevroux', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2332, 'Combremont-le-Grand', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2333, 'Combremont-le-Petit', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2334, 'Corcelles-près-Payerne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2335, 'Grandcour', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2336, 'Granges-près-Marnand', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2337, 'Henniez', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2338, 'Marnand', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2339, 'Missy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2340, 'Payerne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2341, 'Rossens (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2342, 'Sassel', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2343, 'Sédeilles', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2344, 'Seigneux', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2345, 'Trey', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2346, 'Treytorrens (Payerne)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2347, 'Villars-Bramard', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2348, 'Villarzel', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2349, 'Château-d\'Oex', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2350, 'Rossinière', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2351, 'Rougemont', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2352, 'Allaman', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2353, 'Bursinel', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2354, 'Bursins', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2355, 'Burtigny', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2356, 'Dully', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2357, 'Essertines-sur-Rolle', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2358, 'Gilly', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2359, 'Luins', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2360, 'Mont-sur-Rolle', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2361, 'Perroy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2362, 'Rolle', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2363, 'Tartegnin', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2364, 'Vinzel', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2365, 'L\'Abbaye', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2366, 'Le Chenit', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2367, 'Le Lieu', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2368, 'Blonay', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2369, 'Chardonne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2370, 'Corseaux', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2371, 'Corsier-sur-Vevey', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2372, 'Jongny', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2373, 'Montreux', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2374, 'Saint-Légier-La Chiésaz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2375, 'La Tour-de-Peilz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2376, 'Vevey', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2377, 'Veytaux', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2378, 'Belmont-sur-Yverdon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2379, 'Bioley-Magnoux', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2380, 'Chamblon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2381, 'Champvent', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2382, 'Chanéaz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2383, 'Chavannes-le-Chêne', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2384, 'Chêne-Pâquier', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2385, 'Cheseaux-Noréaz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2386, 'Cronay', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2387, 'Cuarny', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2388, 'Démoret', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2389, 'Donneloye', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2390, 'Ependes (VD)', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2391, 'Essert-Pittet', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2392, 'Essert-sous-Champvent', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2393, 'Gossens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2394, 'Gressy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2395, 'Mathod', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2396, 'Mézery-près-Donneloye', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2397, 'Molondin', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2398, 'Montagny-près-Yverdon', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2399, 'Oppens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2400, 'Orges', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2401, 'Orzens', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2402, 'Pomy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2403, 'Prahins', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2404, 'Rovray', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2405, 'Suchy', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2406, 'Suscévaz', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2407, 'Treycovagnes', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2408, 'Ursins', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2409, 'Valeyres-sous-Montagny', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2410, 'Valeyres-sous-Ursins', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2411, 'Villars-Epeney', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2412, 'Villars-sous-Champvent', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2413, 'Vugelles-La Mothe', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2414, 'Yverdon-les-Bains', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2415, 'Yvonand', 'Vaud', 1);
INSERT INTO `ss_locations` VALUES (2416, 'Birgisch', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2417, 'Brig-Glis', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2418, 'Eggerberg', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2419, 'Mund', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2420, 'Naters', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2421, 'Ried-Brig', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2422, 'Simplon', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2423, 'Termen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2424, 'Zwischbergen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2425, 'Ardon', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2426, 'Chamoson', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2427, 'Conthey', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2428, 'Nendaz', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2429, 'Vétroz', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2430, 'Bagnes', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2431, 'Bourg-Saint-Pierre', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2432, 'Liddes', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2433, 'Orsières', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2434, 'Sembrancher', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2435, 'Vollèges', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2436, 'Bellwald', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2437, 'Binn', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2438, 'Blitzingen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2439, 'Ernen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2440, 'Fiesch', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2441, 'Fieschertal', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2442, 'Lax', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2443, 'Niederwald', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2444, 'Obergesteln', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2445, 'Oberwald', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2446, 'Ulrichen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2447, 'Grafschaft', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2448, 'Münster-Geschinen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2449, 'Reckingen-Gluringen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2450, 'Les Agettes', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2451, 'Ayent', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2452, 'Evolène', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2453, 'Hérémence', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2454, 'Mase', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2455, 'Nax', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2456, 'Saint-Martin (VS)', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2457, 'Vernamiège', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2458, 'Vex', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2459, 'Agarn', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2460, 'Albinen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2461, 'Bratsch', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2462, 'Ergisch', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2463, 'Erschmatt', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2464, 'Gampel', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2465, 'Inden', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2466, 'Leuk', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2467, 'Leukerbad', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2468, 'Oberems', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2469, 'Salgesch', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2470, 'Turtmann', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2471, 'Unterems', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2472, 'Varen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2473, 'Guttet-Feschel', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2474, 'Bovernier', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2475, 'Charrat', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2476, 'Fully', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2477, 'Isérables', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2478, 'Leytron', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2479, 'Martigny', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2480, 'Martigny-Combe', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2481, 'Riddes', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2482, 'Saillon', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2483, 'Saxon', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2484, 'Trient', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2485, 'Champéry', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2486, 'Collombey-Muraz', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2487, 'Monthey', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2488, 'Port-Valais', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2489, 'Saint-Gingolph', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2490, 'Troistorrents', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2491, 'Val-d\'Illiez', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2492, 'Vionnaz', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2493, 'Vouvry', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2494, 'Betten', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2495, 'Bister', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2496, 'Bitsch', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2497, 'Filet', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2498, 'Grengiols', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2499, 'Martisberg', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2500, 'Mörel', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2501, 'Riederalp', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2502, 'Ausserberg', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2503, 'Blatten', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2504, 'Bürchen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2505, 'Eischoll', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2506, 'Ferden', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2507, 'Hohtenn', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2508, 'Kippel', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2509, 'Niedergesteln', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2510, 'Raron', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2511, 'Steg', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2512, 'Unterbäch', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2513, 'Wiler (Lötschen)', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2514, 'Collonges', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2515, 'Dorénaz', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2516, 'Evionnaz', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2517, 'Finhaut', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2518, 'Massongex', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2519, 'Mex (VS)', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2520, 'Saint-Maurice', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2521, 'Salvan', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2522, 'Vernayaz', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2523, 'Vérossaz', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2524, 'Ayer', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2525, 'Chalais', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2526, 'Chandolin', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2527, 'Chermignon', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2528, 'Chippis', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2529, 'Grimentz', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2530, 'Grône', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2531, 'Icogne', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2532, 'Lens', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2533, 'Miège', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2534, 'Mollens (VS)', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2535, 'Montana', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2536, 'Randogne', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2537, 'Saint-Jean', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2538, 'Saint-Léonard', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2539, 'Saint-Luc', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2540, 'Sierre', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2541, 'Venthône', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2542, 'Veyras', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2543, 'Vissoie', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2544, 'Arbaz', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2545, 'Grimisuat', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2546, 'Salins', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2547, 'Savièse', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2548, 'Sion', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2549, 'Veysonnaz', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2550, 'Baltschieder', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2551, 'Eisten', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2552, 'Embd', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2553, 'Grächen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2554, 'Lalden', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2555, 'Randa', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2556, 'Saas Almagell', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2557, 'Saas Balen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2558, 'Saas Fee', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2559, 'Saas Grund', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2560, 'St. Niklaus', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2561, 'Stalden (VS)', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2562, 'Staldenried', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2563, 'Täsch', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2564, 'Törbel', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2565, 'Visp', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2566, 'Visperterminen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2567, 'Zeneggen', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2568, 'Zermatt', 'Valais / Wallis', 1);
INSERT INTO `ss_locations` VALUES (2569, 'Auvernier', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2570, 'Bevaix', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2571, 'Bôle', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2572, 'Boudry', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2573, 'Brot-Dessous', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2574, 'Colombier (NE)', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2575, 'Corcelles-Cormondrèche', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2576, 'Cortaillod', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2577, 'Fresens', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2578, 'Gorgier', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2579, 'Montalchez', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2580, 'Peseux', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2581, 'Rochefort', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2582, 'Saint-Aubin-Sauges', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2583, 'Vaumarcus', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2584, 'La Chaux-de-Fonds', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2585, 'Les Planchettes', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2586, 'La Sagne', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2587, 'Les Brenets', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2588, 'La Brévine', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2589, 'Brot-Plamboz', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2590, 'Le Cerneux-Péquignot', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2591, 'La Chaux-du-Milieu', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2592, 'Le Locle', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2593, 'Les Ponts-de-Martel', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2594, 'Cornaux', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2595, 'Cressier (NE)', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2596, 'Enges', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2597, 'Hauterive (NE)', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2598, 'Le Landeron', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2599, 'Lignières', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2600, 'Marin-Epagnier', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2601, 'Neuchâtel', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2602, 'Saint-Blaise', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2603, 'Thielle-Wavre', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2604, 'Boudevilliers', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2605, 'Cernier', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2606, 'Chézard-Saint-Martin', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2607, 'Coffrane', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2608, 'Dombresson', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2609, 'Engollon', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2610, 'Fenin-Vilars-Saules', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2611, 'Fontainemelon', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2612, 'Fontaines (NE)', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2613, 'Les Geneveys-sur-Coffrane', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2614, 'Les Hauts-Geneveys', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2615, 'Montmollin', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2616, 'Le Pâquier (NE)', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2617, 'Savagnier', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2618, 'Valangin', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2619, 'Villiers', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2620, 'Les Bayards', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2621, 'Boveresse', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2622, 'Buttes', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2623, 'La Côte-aux-Fées', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2624, 'Couvet', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2625, 'Fleurier', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2626, 'Môtiers (NE)', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2627, 'Noiraigue', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2628, 'Saint-Sulpice (NE)', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2629, 'Travers', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2630, 'Les Verrières', 'Neuchâtel', 1);
INSERT INTO `ss_locations` VALUES (2631, 'Aire-la-Ville', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2632, 'Anières', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2633, 'Avully', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2634, 'Avusy', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2635, 'Bardonnex', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2636, 'Bellevue', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2637, 'Bernex', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2638, 'Carouge (GE)', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2639, 'Cartigny', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2640, 'Céligny', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2641, 'Chancy', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2642, 'Chêne-Bougeries', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2643, 'Chêne-Bourg', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2644, 'Choulex', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2645, 'Collex-Bossy', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2646, 'Collonge-Bellerive', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2647, 'Cologny', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2648, 'Confignon', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2649, 'Corsier (GE)', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2650, 'Dardagny', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2651, 'Genève', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2652, 'Genthod', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2653, 'Le Grand-Saconnex', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2654, 'Gy', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2655, 'Hermance', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2656, 'Jussy', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2657, 'Laconnex', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2658, 'Lancy', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2659, 'Meinier', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2660, 'Meyrin', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2661, 'Onex', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2662, 'Perly-Certoux', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2663, 'Plan-les-Ouates', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2664, 'Pregny-Chambésy', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2665, 'Presinge', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2666, 'Puplinge', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2667, 'Russin', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2668, 'Satigny', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2669, 'Soral', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2670, 'Thônex', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2671, 'Troinex', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2672, 'Vandoeuvres', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2673, 'Vernier', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2674, 'Versoix', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2675, 'Veyrier', 'Genève', 1);
INSERT INTO `ss_locations` VALUES (2676, 'Bassecourt', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2677, 'Boécourt', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2678, 'Bourrignon', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2679, 'Châtillon (JU)', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2680, 'Corban', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2681, 'Courchapoix', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2682, 'Courfaivre', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2683, 'Courrendlin', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2684, 'Courroux', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2685, 'Courtételle', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2686, 'Delémont', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2687, 'Develier', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2688, 'Ederswiler', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2689, 'Glovelier', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2690, 'Mervelier', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2691, 'Mettembert', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2692, 'Montsevelier', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2693, 'Movelier', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2694, 'Pleigne', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2695, 'Rebeuvelier', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2696, 'Rossemaison', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2697, 'Saulcy', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2698, 'Soulce', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2699, 'Soyhières', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2700, 'Undervelier', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2701, 'Vermes', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2702, 'Vicques', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2703, 'Vellerat', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2704, 'Le Bémont (JU)', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2705, 'Les Bois', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2706, 'Les Breuleux', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2707, 'La Chaux-des-Breuleux', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2708, 'Les Enfers', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2709, 'Epauvillers', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2710, 'Epiquerez', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2711, 'Les Genevez (JU)', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2712, 'Goumois', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2713, 'Lajoux (JU)', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2714, 'Montfaucon', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2715, 'Montfavergier', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2716, 'Muriaux', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2717, 'Le Noirmont', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2718, 'Le Peuchapatte', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2719, 'Les Pommerats', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2720, 'Saignelégier', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2721, 'Saint-Brais', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2722, 'Soubey', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2723, 'Alle', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2724, 'Asuel', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2725, 'Beurnevésin', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2726, 'Boncourt', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2727, 'Bonfol', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2728, 'Bressaucourt', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2729, 'Buix', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2730, 'Bure', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2731, 'Charmoille', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2732, 'Chevenez', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2733, 'Coeuve', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2734, 'Cornol', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2735, 'Courchavon', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2736, 'Courgenay', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2737, 'Courtedoux', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2738, 'Courtemaîche', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2739, 'Damphreux', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2740, 'Damvant', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2741, 'Fahy', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2742, 'Fontenais', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2743, 'Fregiécourt', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2744, 'Grandfontaine', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2745, 'Lugnez', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2746, 'Miécourt', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2747, 'Montenol', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2748, 'Montignez', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2749, 'Montmelon', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2750, 'Ocourt', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2751, 'Pleujouse', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2752, 'Porrentruy', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2753, 'Réclère', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2754, 'Roche-d\'Or', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2755, 'Rocourt', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2756, 'Saint-Ursanne', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2757, 'Seleute', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2758, 'Vendlincourt', 'Jura', 1);
INSERT INTO `ss_locations` VALUES (2759, 'Zürich (Kanton)', 'Zürich ', 1);
INSERT INTO `ss_locations` VALUES (2760, 'Bern (Kanton)', 'Bern ', 1);
INSERT INTO `ss_locations` VALUES (2761, 'Luzern (Kanton)', 'Luzern ', 1);
INSERT INTO `ss_locations` VALUES (2762, 'Uri (Kanton)', 'Uri ', 1);
INSERT INTO `ss_locations` VALUES (2763, 'Schwyz (Kanton)', 'Schwyz ', 1);
INSERT INTO `ss_locations` VALUES (2764, 'Obwalden (Kanton)', 'Obwalden ', 1);
INSERT INTO `ss_locations` VALUES (2765, 'Nidwalden (Kanton)', 'Nidwalden ', 1);
INSERT INTO `ss_locations` VALUES (2766, 'Glarus (Kanton)', 'Glarus ', 1);
INSERT INTO `ss_locations` VALUES (2767, 'Zug (Kanton)', 'Zug ', 1);
INSERT INTO `ss_locations` VALUES (2768, 'Freiburg (Kanton)', 'Freiburg ', 1);
INSERT INTO `ss_locations` VALUES (2769, 'Solothurn (Kanton)', 'Solothurn ', 1);
INSERT INTO `ss_locations` VALUES (2770, 'Basel-Stadt (Kanton)', 'Basel-Stadt', 1);
INSERT INTO `ss_locations` VALUES (2771, 'Basel-Landschaft (Kanton)', 'Basel-Landschaft', 1);
INSERT INTO `ss_locations` VALUES (2772, 'Schaffhausen (Kanton)', 'Schaffhausen ', 1);
INSERT INTO `ss_locations` VALUES (2773, 'Appenzell A.Rh (Kanton)', 'Appenzell A.Rh', 1);
INSERT INTO `ss_locations` VALUES (2774, 'Appenzell I.Rh. (Kanton)', 'Appenzell I.Rh.', 1);
INSERT INTO `ss_locations` VALUES (2775, 'St. Gallen (Kanton)', 'St. Gallen', 1);
INSERT INTO `ss_locations` VALUES (2776, 'Graubünden (Kanton)', 'Graubünden ', 1);
INSERT INTO `ss_locations` VALUES (2777, 'Aargau (Kanton)', 'Aargau ', 1);
INSERT INTO `ss_locations` VALUES (2778, 'Thurgau (Kanton)', 'Thurgau ', 1);
INSERT INTO `ss_locations` VALUES (2779, 'Tessin (Kanton)', 'Tessin ', 1);
INSERT INTO `ss_locations` VALUES (2780, 'Waadt (Kanton)', 'Waadt ', 1);
INSERT INTO `ss_locations` VALUES (2781, 'Wallis (Kanton)', 'Wallis ', 1);
INSERT INTO `ss_locations` VALUES (2782, 'Neuenburg (Kanton)', 'Neuenburg ', 1);
INSERT INTO `ss_locations` VALUES (2783, 'Genf (Kanton)', 'Genf ', 1);
INSERT INTO `ss_locations` VALUES (2784, 'Jura (Kanton)', 'Jura ', 1);

-- ----------------------------
-- Table structure for ss_uploads
-- ----------------------------
DROP TABLE IF EXISTS `ss_uploads`;
CREATE TABLE `ss_uploads`  (
  `intUploadID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intUserID` int(11) NULL DEFAULT NULL,
  `strFile` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dtmUploadDate` datetime NOT NULL,
  PRIMARY KEY (`intUploadID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ss_uploads
-- ----------------------------
INSERT INTO `ss_uploads` VALUES (3, 4, 4, 'hr-auszug.pdf', '2024-07-12 17:12:07');

-- ----------------------------
-- Table structure for ss_worker_profiles
-- ----------------------------
DROP TABLE IF EXISTS `ss_worker_profiles`;
CREATE TABLE `ss_worker_profiles`  (
  `intWorkerProfileID` int(11) NOT NULL AUTO_INCREMENT,
  `intUserID` int(11) NOT NULL,
  `intAdID` int(11) NULL DEFAULT NULL,
  `blnPublic` tinyint(1) NOT NULL DEFAULT 0,
  `blnShowSalutation` tinyint(1) NOT NULL DEFAULT 1,
  `blnShowFirstName` tinyint(1) NOT NULL DEFAULT 1,
  `blnShowLastName` tinyint(1) NOT NULL DEFAULT 1,
  `blnShowEmail` tinyint(1) NOT NULL DEFAULT 1,
  `blnShowTel` tinyint(1) NOT NULL DEFAULT 1,
  `blnShowMobile` tinyint(1) NOT NULL DEFAULT 1,
  `blnShowStreet` tinyint(1) NOT NULL DEFAULT 1,
  `blnShowZipCity` tinyint(1) NOT NULL DEFAULT 1,
  `blnShowPhoto` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`intWorkerProfileID`) USING BTREE,
  UNIQUE INDEX `_intUserID`(`intUserID`) USING BTREE,
  INDEX `_intAdID`(`intAdID`) USING BTREE,
  CONSTRAINT `frn_wp_customer` FOREIGN KEY (`intUserID`) REFERENCES `users` (`intUserID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ss_worker_profiles
-- ----------------------------
INSERT INTO `ss_worker_profiles` VALUES (1, 3, 5, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1);
INSERT INTO `ss_worker_profiles` VALUES (5, 4, 8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO `ss_worker_profiles` VALUES (7, 6, 10, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1);

-- ----------------------------
-- Table structure for system_mappings
-- ----------------------------
DROP TABLE IF EXISTS `system_mappings`;
CREATE TABLE `system_mappings`  (
  `intSystemMappingID` int(11) NOT NULL AUTO_INCREMENT,
  `strMapping` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strPath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `blnOnlyAdmin` tinyint(1) NOT NULL DEFAULT 0,
  `blnOnlySuperAdmin` tinyint(1) NOT NULL DEFAULT 0,
  `blnOnlySysAdmin` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intSystemMappingID`) USING BTREE,
  UNIQUE INDEX `_strMapping`(`strMapping`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 81 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_mappings
-- ----------------------------
INSERT INTO `system_mappings` VALUES (4, 'dashboard', 'backend/core/views/dashboard.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (5, 'account-settings/my-profile', 'backend/core/views/customer/my-profile.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (6, 'customer', 'backend/core/handler/customer.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (7, 'global', 'backend/core/handler/global.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (9, 'logincheck', 'frontend/core/handler/register.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (12, 'account-settings', 'backend/core/views/customer/account-settings.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (13, 'account-settings/company', 'backend/core/views/customer/company-edit.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (14, 'account-settings/tenants', 'backend/core/views/customer/tenants.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (15, 'account-settings/users', 'backend/core/views/customer/users.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (17, 'account-settings/reset-password', 'backend/core/views/customer/reset-password.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (19, 'account-settings/user/new', 'backend/core/views/customer/user_new.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (20, 'account-settings/user/edit', 'backend/core/views/customer/user_edit.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (21, 'account-settings/tenant/new', 'backend/core/views/customer/tenant_new.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (23, 'account-settings/invoices', 'backend/core/views/invoices/invoices.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (25, 'account-settings/invoice', 'backend/core/views/invoices/invoice.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (26, 'account-settings/modules', 'backend/core/views/customer/modules.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (27, 'invoices', 'backend/core/handler/invoices.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (29, 'sysadmin/mappings', 'backend/core/views/sysadmin/mappings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (31, 'sysadmin/translations', 'backend/core/views/sysadmin/translations.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (32, 'sysadmin/settings', 'backend/core/views/sysadmin/settings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (33, 'user', 'backend/core/handler/user.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (34, 'sysadmin/languages', 'backend/core/views/sysadmin/languages.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (36, 'sysadmin/countries', 'backend/core/views/sysadmin/countries.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (37, 'sysadmin/countries/import', 'backend/core/views/sysadmin/country_import.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (39, 'sysadmin/modules', 'backend/core/views/sysadmin/modules.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (41, 'sysadmin/modules/edit', 'backend/core/views/sysadmin/module_edit.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (42, 'sysadmin/widgets', 'backend/core/views/sysadmin/widgets.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (43, 'sysadm/mappings', 'backend/core/handler/sysadmin/mappings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (44, 'sysadm/translations', 'backend/core/handler/sysadmin/translations.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (45, 'sysadm/languages', 'backend/core/handler/sysadmin/languages.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (46, 'sysadm/settings', 'backend/core/handler/sysadmin/settings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (47, 'sysadm/countries', 'backend/core/handler/sysadmin/countries.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (48, 'sysadm/modules', 'backend/core/handler/sysadmin/modules.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (49, 'account-settings/invoice/print', 'backend/core/views/invoices/print.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (50, 'sysadm/widgets', 'backend/core/handler/sysadmin/widgets.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (51, 'sysadmin/plans', 'backend/core/views/sysadmin/plans.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (52, 'sysadmin/currencies', 'backend/core/views/sysadmin/currencies.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (53, 'sysadm/currencies', 'backend/core/handler/sysadmin/currencies.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (54, 'sysadm/plans', 'backend/core/handler/sysadmin/plans.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (55, 'sysadmin/plan/edit', 'backend/core/views/sysadmin/plan_edit.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (56, 'sysadmin/plangroups', 'backend/core/views/sysadmin/plan_groups.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (57, 'sysadmin/planfeatures', 'backend/core/views/sysadmin/plan_features.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (59, 'sysadmin/invoices', 'backend/core/views/sysadmin/invoices.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (60, 'sysadm/invoices', 'backend/core/handler/sysadmin/invoices.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (61, 'sysadmin/invoice/edit', 'backend/core/views/sysadmin/invoice_edit.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (62, 'sysadmin/customers', 'backend/core/views/sysadmin/customers.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (63, 'sysadm/customers', 'backend/core/handler/sysadmin/customers.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (64, 'sysadmin/customers/edit', 'backend/core/views/sysadmin/customers_edit.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (65, 'sysadmin/customers/details', 'backend/core/views/sysadmin/customers_details.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (66, 'sysadmin/system-settings', 'backend/core/views/sysadmin/system_settings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (67, 'book', 'backend/core/handler/book.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (68, 'cancel', 'backend/core/handler/cancel.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (69, 'dashboard-settings', 'backend/core/handler/dashboard.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (70, 'account-settings/plans', 'backend/core/views/customer/plans.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (71, 'plan-settings', 'backend/core/handler/plans.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (72, 'account-settings/payment', 'backend/core/views/customer/payment.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (73, 'payment-settings', 'backend/core/handler/payment.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (74, 'account-settings/settings', 'backend/core/views/customer/settings.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (75, 'notifications', 'backend/core/views/notifications/overview.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (76, 'sysadm/api-settings', 'backend/core/handler/sysadmin/api_settings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (77, 'sysadmin/api-settings', 'backend/core/views/sysadmin/api_settings.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (79, 'sysadmin/logs', 'backend/core/views/sysadmin/logs.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (80, 'sysadm/logs', 'backend/core/handler/sysadmin/logs.cfm', 0, 0, 1);

-- ----------------------------
-- Table structure for system_settings
-- ----------------------------
DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE `system_settings`  (
  `intSystSettingID` int(11) NOT NULL AUTO_INCREMENT,
  `strSettingVariable` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDefaultValue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intSystSettingID`) USING BTREE,
  UNIQUE INDEX `_intSystSettingID`(`intSystSettingID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_settings
-- ----------------------------
INSERT INTO `system_settings` VALUES (1, 'settingInvoiceNumberStart', '1000', 'New invoice: At which invoice number should the system start?');
INSERT INTO `system_settings` VALUES (2, 'settingRoundFactor', '1', 'The rounding factor for invoice amounts. Note: Currently only 5 (0.05 Switzerland) or 1 (0.01 rest of the world) are available.');
INSERT INTO `system_settings` VALUES (3, 'settingStandardVatType', '3', 'Which vat type should be set by default?');
INSERT INTO `system_settings` VALUES (4, 'settingInvoicePrefix', 'INV-', 'Invoices can be preceded by a short prefix. Enter it here.');
INSERT INTO `system_settings` VALUES (5, 'settingInvoiceNet', '1', 'Decide whether the invoices are issued \"net\" by default.');
INSERT INTO `system_settings` VALUES (6, 'settingLayout', 'horizontal', 'Choose a layout you want to use');
INSERT INTO `system_settings` VALUES (7, 'settingColorPrimary', '#39abb8', 'Choose a primary color:');
INSERT INTO `system_settings` VALUES (8, 'settingColorSecondary', '#39abb8', 'Choose a secondary color:');
INSERT INTO `system_settings` VALUES (9, 'settingSwissQrBill', '0', 'Do you want to activate the Swiss QR bill?');
INSERT INTO `system_settings` VALUES (10, 'settingIBANnumber', '', 'Your IBAN number');
INSERT INTO `system_settings` VALUES (11, 'settingQRreference', '', 'Your QR reference number');

-- ----------------------------
-- Table structure for system_translations
-- ----------------------------
DROP TABLE IF EXISTS `system_translations`;
CREATE TABLE `system_translations`  (
  `intSystTransID` int(11) NOT NULL AUTO_INCREMENT,
  `strVariable` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strStringDE` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strStringEN` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`intSystTransID`) USING BTREE,
  UNIQUE INDEX `_strVariable`(`strVariable`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 333 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_translations
-- ----------------------------
INSERT INTO `system_translations` VALUES (1, 'alertAccountCreatedLogin', 'Ihr Account wurde erfolgreich erstellt. Bitte loggen Sie sich nun ein.', 'Your account has been successfully created. Please log in now.');
INSERT INTO `system_translations` VALUES (2, 'alertChoosePassword', 'Bitte vergeben Sie sich ein starkes Passwort mit mindestens 8 Zeichen.', 'Please assign yourself a strong password with at least 8 characters.');
INSERT INTO `system_translations` VALUES (3, 'alertEmailAlreadyUsed', 'Diese E-Mail-Adresse wurde bereits benutzt!', 'This email address has already been used!');
INSERT INTO `system_translations` VALUES (4, 'alertEnterAddress', 'Bitte geben Sie Ihre Adresse ein!', 'Please enter your address!');
INSERT INTO `system_translations` VALUES (5, 'alertEnterCity', 'Bitte geben Sie Ihre Ortschaft ein!', 'Please enter your City!');
INSERT INTO `system_translations` VALUES (6, 'alertEnterCompany', 'Bitte geben Sie den Firmennamen ein!', 'Please enter company name!');
INSERT INTO `system_translations` VALUES (7, 'alertEnterEmail', 'Bitte geben Sie eine gültige E-Mail-Adresse ein!', 'Please enter a valid e-mail address!');
INSERT INTO `system_translations` VALUES (8, 'alertEnterFirstName', 'Bitte geben Sie Ihren Vornamen ein!', 'Please enter your first name!');
INSERT INTO `system_translations` VALUES (9, 'alertEnterName', 'Bitte geben Sie Ihren Namen ein!', 'Please enter your name!');
INSERT INTO `system_translations` VALUES (10, 'alertEnterPassword1', 'Bitte geben Sie das Passwort ein!', 'Please enter the password!');
INSERT INTO `system_translations` VALUES (11, 'alertEnterPassword2', 'Bitte bestätigen Sie das Passwort!', 'Please confirm the password!');
INSERT INTO `system_translations` VALUES (12, 'alertEnterZIP', 'Bitte geben Sie Ihre PLZ ein!', 'Please enter your ZIP!');
INSERT INTO `system_translations` VALUES (13, 'alertErrorOccured', 'Es ist ein Fehler aufgetreten. Bitte versuchen Sie nocheinmal.', 'An error has occurred. Please try again.');
INSERT INTO `system_translations` VALUES (14, 'alertHasAccountAlready', 'Diese E-Mail-Adresse wurde bereits verwendet. Bitte loggen Sie sich ein oder setzen Sie Ihr Passwort zurück.', 'This email address has already been used. Please log in or reset your password.');
INSERT INTO `system_translations` VALUES (15, 'alertIfAccountFoundEmail', 'Wenn wir einen Account mit dieser E-Mail-Adresse finden, werden wir Ihnen einen Link senden, um Ihr Passwort zurückzusetzen.', 'If we find an account with this email address, we will send you a link to reset your password.');
INSERT INTO `system_translations` VALUES (16, 'alertLoggedOut', 'Sie haben sich erfolgreich abgemeldet.', 'You have successfully logged out.');
INSERT INTO `system_translations` VALUES (17, 'alertNewUserCreated', 'Der neue Benutzer wurde erfolgreich angelegt und es wurde ein Aktivierungslink gesendet.', 'The new user has been created successfully and an activation link has been sent.');
INSERT INTO `system_translations` VALUES (18, 'alertNotValidAnymore', 'Dieser Link ist leider nicht mehr gültig!', 'Sorry, this link is no longer valid!');
INSERT INTO `system_translations` VALUES (19, 'alertOptinSent', 'Wir haben Ihnen an die von Ihnen angegebene Adresse ein E-Mail gesendet. Bitte klicken Sie auf den darin enthaltenen Link, um Ihre E-Mail-Adresse zu bestätigen.', 'We have sent you an email to the address you provided. Please click on the link contained therein to confirm your email address.');
INSERT INTO `system_translations` VALUES (20, 'alertPasswordResetSuccess', 'Ihr Passwort wurde erfolgreich zurückgesetzt. Bitte loggen Sie sich nun ein.', 'Your password has been successfully reset. Please log in now.');
INSERT INTO `system_translations` VALUES (21, 'alertPasswordResetSuccessfully', 'Ihr neues Passwort wurde erfolgreich gespeichert.', 'Your new password has been successfully saved.');
INSERT INTO `system_translations` VALUES (22, 'alertPasswordsNotSame', 'Die beiden Passwörter stimmen nicht überein! Probieren Sie nochmal.', 'The two passwords do not match! Try again.');
INSERT INTO `system_translations` VALUES (23, 'alertSessionExpired', 'Ihre Session ist leider abgelaufen, bitte loggen Sie sich erneut ein.', 'Sorry, your session has expired, please log in again.');
INSERT INTO `system_translations` VALUES (24, 'alertTenantAdded', 'Der neue Mandant wurde erfolgreich erstellt. Sie können die Firma entweder hier oder oben im Header auswählen.', 'The new tenant has been successfully created. You can select the company either here or in the header above.');
INSERT INTO `system_translations` VALUES (25, 'alertTenantDeleted', 'Der Mandant wurde erfolgreich gelöscht.', 'The tenant has been successfully deleted.');
INSERT INTO `system_translations` VALUES (26, 'alertWrongLogin', 'Die E-Mail-Adresse und/oder das Passwort ist falsch, bitte versuchen Sie es nochmal.', 'The email address and/or password is incorrect, please try again.');
INSERT INTO `system_translations` VALUES (27, 'blnAction', 'Aktion', 'Action');
INSERT INTO `system_translations` VALUES (28, 'btnActivate', 'Aktivieren', 'Activate');
INSERT INTO `system_translations` VALUES (29, 'btnClose', 'Schliessen', 'Close');
INSERT INTO `system_translations` VALUES (30, 'btnDeactivate', 'Deaktivieren', 'Deactivate');
INSERT INTO `system_translations` VALUES (31, 'btnDelete', 'Löschen', 'Delete');
INSERT INTO `system_translations` VALUES (32, 'btnEdit', 'Bearbeiten', 'Edit');
INSERT INTO `system_translations` VALUES (33, 'btnNewTenant', 'Mandant hinzufügen', 'New tenant');
INSERT INTO `system_translations` VALUES (34, 'btnNewUser', 'Benutzer hinzufügen', 'New user');
INSERT INTO `system_translations` VALUES (35, 'btnNoCancel', 'Nein, abbrechen!', 'No, cancel!');
INSERT INTO `system_translations` VALUES (36, 'btnSave', 'Speichern', 'Save');
INSERT INTO `system_translations` VALUES (37, 'btnSendActivLink', 'Aktivierungslink senden', 'Send activation link');
INSERT INTO `system_translations` VALUES (38, 'btnSetStandard', 'Als Standard definieren', 'Define as standard');
INSERT INTO `system_translations` VALUES (39, 'btnSwitchToThisCompany', 'Zur dieser Firma wechseln', 'Switch to this company');
INSERT INTO `system_translations` VALUES (40, 'btnUpload', 'Hochladen', 'Upload');
INSERT INTO `system_translations` VALUES (41, 'btnYesDelete', 'Ja, löschen!', 'Yes, delete!');
INSERT INTO `system_translations` VALUES (42, 'errContactNumberAlreadyUsedTitle', 'Diese Kontaktnummer wurde bereits verwendet', 'This contact number has already been used');
INSERT INTO `system_translations` VALUES (43, 'errSystemStoppedFixProblem', 'Das System wurde gestoppt. Bitte lösen Sie das Problem, um das System wieder zu starten.', 'The system has been stopped. Please fix the problem in order to restart the system.');
INSERT INTO `system_translations` VALUES (44, 'formAddress', 'Adresse', 'Address');
INSERT INTO `system_translations` VALUES (45, 'formAddress2', 'Zusatzadresse', 'Additional address');
INSERT INTO `system_translations` VALUES (46, 'formAlreadyHaveAccount', 'Sie haben bereits einen Account?', 'Already have account?');
INSERT INTO `system_translations` VALUES (47, 'formCity', 'Ort', 'City');
INSERT INTO `system_translations` VALUES (48, 'formCompanyName', 'Firma', 'Company Name');
INSERT INTO `system_translations` VALUES (49, 'formContactName', 'Ansprechperson', 'Contact person');
INSERT INTO `system_translations` VALUES (50, 'formCountry', 'Land', 'Country');
INSERT INTO `system_translations` VALUES (51, 'formEmailAddress', 'E-Mail Adresse', 'Email address');
INSERT INTO `system_translations` VALUES (52, 'formEnterCompanyName', 'Firmenname eingeben', 'Enter Company Name');
INSERT INTO `system_translations` VALUES (53, 'formEnterEmail', 'E-Mail eingeben', 'Enter email');
INSERT INTO `system_translations` VALUES (54, 'formEnterFirstName', 'Vorname eingeben', 'Enter First Name');
INSERT INTO `system_translations` VALUES (55, 'formEnterName', 'Name eingeben', 'Enter Name');
INSERT INTO `system_translations` VALUES (56, 'formFirstName', 'Vorname', 'First Name');
INSERT INTO `system_translations` VALUES (57, 'formForgotPassword', 'Passwort vergessen?', 'Password forgotten?');
INSERT INTO `system_translations` VALUES (58, 'formInvoiceAddress', 'Adresse für Rechnungen', 'Invoice address');
INSERT INTO `system_translations` VALUES (59, 'formInvoiceEmail', 'E-Mail-Adresse für Rechnungen', 'Invoice email address');
INSERT INTO `system_translations` VALUES (60, 'formInvoiceInfo', 'Information für Rechnungen', 'Invoice information');
INSERT INTO `system_translations` VALUES (61, 'formMobile', 'Mobile', 'Mobile');
INSERT INTO `system_translations` VALUES (62, 'formName', 'Name', 'Name');
INSERT INTO `system_translations` VALUES (63, 'formPassword', 'Passwort', 'Password');
INSERT INTO `system_translations` VALUES (64, 'formPassword2', 'Passwort bestätigen', 'Confirm password');
INSERT INTO `system_translations` VALUES (65, 'formPhone', 'Telefon', 'Phone');
INSERT INTO `system_translations` VALUES (66, 'formRegisterText', 'Sie haben noch keinen Account?', 'Don`t have an account yet?');
INSERT INTO `system_translations` VALUES (67, 'formReset', 'Zurücksetzen', 'Reset');
INSERT INTO `system_translations` VALUES (68, 'formSalutation', 'Anrede', 'Salutation');
INSERT INTO `system_translations` VALUES (69, 'formSignIn', 'Einloggen', 'Sign in');
INSERT INTO `system_translations` VALUES (70, 'formSignUp', 'Registrieren', 'Sign up');
INSERT INTO `system_translations` VALUES (71, 'formStandard', 'Standard', 'Standard');
INSERT INTO `system_translations` VALUES (72, 'formWebsite', 'Webseite', 'Website');
INSERT INTO `system_translations` VALUES (73, 'formZIP', 'PLZ', 'ZIP');
INSERT INTO `system_translations` VALUES (74, 'msgAccountDisabledByAdmin', 'Ihr Account wurde vorübergehend deaktiviert. Bitte melden Sie sich bei Ihrem Administrator.', 'Your account has been temporarily disabled. Please contact your administrator.');
INSERT INTO `system_translations` VALUES (75, 'msgChangesSaved', 'Ihre Änderungen wurden erfolgreich gespeichert.', 'Your changes have been saved successfully.');
INSERT INTO `system_translations` VALUES (76, 'msgFileTooLarge', 'Die hochgeladene Datei ist zu gross!', 'The uploaded file is too large!');
INSERT INTO `system_translations` VALUES (77, 'msgFileUploadedSuccessfully', 'Die Datei wurde erfolgreich hochgeladen.', 'The file has been uploaded successfully.');
INSERT INTO `system_translations` VALUES (78, 'msgNoAccess', 'Sie haben leider keinen Zugriff auf den verlangten Bereich. Bitte melden Sie sich bei Ihrem Administrator.', 'Sorry, you do not have access to the requested section. Please contact your administrator.');
INSERT INTO `system_translations` VALUES (79, 'msgPleaseChooseFile', 'Bitte wählen Sie eine Datei!', 'Please choose a file!');
INSERT INTO `system_translations` VALUES (80, 'msgUserDeleted', 'Der Benutzer wurde erfolgreich gelöscht.', 'The user has been successfully deleted.');
INSERT INTO `system_translations` VALUES (81, 'msgUserGotInvitation', 'Der Aktivierungslink wurde erfolgreich gesendet.', 'The activation link has been sent successfully.');
INSERT INTO `system_translations` VALUES (82, 'statInvoiceCanceled', 'Storniert', 'Canceled');
INSERT INTO `system_translations` VALUES (83, 'statInvoiceOpen', 'Offen', 'Open');
INSERT INTO `system_translations` VALUES (84, 'statInvoiceOverPay', 'Überzahlung', 'Overpayment');
INSERT INTO `system_translations` VALUES (85, 'statInvoicePaid', 'Bezahlt', 'Paid');
INSERT INTO `system_translations` VALUES (86, 'statInvoicePartPaid', 'Teilweise bezahlt', 'Partial paid');
INSERT INTO `system_translations` VALUES (87, 'subjectConfirmEmail', 'Bitte bestätigen Sie Ihre E-Mail-Adresse', 'Please confirm your email address');
INSERT INTO `system_translations` VALUES (89, 'thisLanguage', 'Deutsch', 'English');
INSERT INTO `system_translations` VALUES (90, 'titActive', 'Aktiv', 'Active');
INSERT INTO `system_translations` VALUES (91, 'titAdmin', 'Administrator', 'Administrator');
INSERT INTO `system_translations` VALUES (92, 'titChoosePassword', 'Passwort wählen', 'Choose password');
INSERT INTO `system_translations` VALUES (93, 'titCreateNewAccount', 'Neuen Account anlegen', 'Create New Account');
INSERT INTO `system_translations` VALUES (94, 'titDeleteTenant', 'Mandant löschen', 'Delete tenant');
INSERT INTO `system_translations` VALUES (95, 'titDeleteUser', 'Benutzer löschen', 'Delete user');
INSERT INTO `system_translations` VALUES (96, 'titDescription', 'Beschreibung', 'Description');
INSERT INTO `system_translations` VALUES (97, 'titDiscount', 'Rabatt', 'Discount');
INSERT INTO `system_translations` VALUES (98, 'titEditCompany', 'Firma bearbeiten', 'Edit company');
INSERT INTO `system_translations` VALUES (99, 'titGeneralSettings', 'Allgemeine Einstellungen', 'General settings');
INSERT INTO `system_translations` VALUES (100, 'titHello', 'Guten Tag', 'Hello');
INSERT INTO `system_translations` VALUES (101, 'titInvoice', 'Rechnung', 'Invoice');
INSERT INTO `system_translations` VALUES (102, 'titInvoiceDate', 'Rechnungsdatum', 'Invoice date');
INSERT INTO `system_translations` VALUES (103, 'titInvoiceNumber', 'Rechnungsnummer', 'Invoice number');
INSERT INTO `system_translations` VALUES (104, 'titInvoices', 'Rechnungen', 'Invoices');
INSERT INTO `system_translations` VALUES (105, 'titInvoiceSettings', 'Rechnungseinstellungen', 'Invoice settings');
INSERT INTO `system_translations` VALUES (106, 'titLogo', 'Logo', 'Logo');
INSERT INTO `system_translations` VALUES (107, 'titMainCompany', 'Hauptfirma', 'Main company');
INSERT INTO `system_translations` VALUES (108, 'titMandanten', 'Mandanten', 'Tenants');
INSERT INTO `system_translations` VALUES (109, 'titModules', 'Module', 'Modules');
INSERT INTO `system_translations` VALUES (110, 'titMyCompany', 'Meine Firma', 'My company');
INSERT INTO `system_translations` VALUES (111, 'titMyPhoto', 'Mein Foto', 'My Photo');
INSERT INTO `system_translations` VALUES (112, 'titNewUser', 'Erfassen Sie hier einen neuen Benutzer', 'Create a new user here');
INSERT INTO `system_translations` VALUES (113, 'titPaymentStatus', 'Zahlstatus', 'Payment status');
INSERT INTO `system_translations` VALUES (114, 'titPhoto', 'Foto', 'Photo');
INSERT INTO `system_translations` VALUES (115, 'titPos', 'Pos.', 'Pos.');
INSERT INTO `system_translations` VALUES (116, 'titQuantity', 'Menge', 'Quantity');
INSERT INTO `system_translations` VALUES (117, 'titResetPassword', 'Passwort zurücksetzen', 'Reset password');
INSERT INTO `system_translations` VALUES (118, 'titSinglePrice', 'Einzelpreis', 'Single price');
INSERT INTO `system_translations` VALUES (119, 'titTenantOverview', 'Mandantenübersicht', 'Tenant overview');
INSERT INTO `system_translations` VALUES (120, 'titTitle', 'Titel', 'Title');
INSERT INTO `system_translations` VALUES (121, 'titTotal', 'Total', 'Total');
INSERT INTO `system_translations` VALUES (122, 'titTotalAmount', 'Totalbetrag', 'Total amount');
INSERT INTO `system_translations` VALUES (123, 'titUser', 'Benutzer', 'Users');
INSERT INTO `system_translations` VALUES (124, 'titUserOverview', 'Benutzerübersicht', 'Users overview');
INSERT INTO `system_translations` VALUES (125, 'txtAccountSettings', 'Kontoeinstellungen', 'Account settings');
INSERT INTO `system_translations` VALUES (126, 'txtActivateThisUser', 'Diesen Benutzer aktivieren', 'Activate this user');
INSERT INTO `system_translations` VALUES (127, 'txtAddOrEditModules', 'Bestellen Sie neue Module oder bearbeiten Sie bestehende', 'Order new modules or edit existing ones');
INSERT INTO `system_translations` VALUES (128, 'txtAddOrEditTenants', 'Erfassen oder bearbeiten Sie Mandanten', 'Add or edit tenants');
INSERT INTO `system_translations` VALUES (129, 'txtAddOrEditUser', 'Erfassen oder bearbeiten Sie Benutzer', 'Add or edit users');
INSERT INTO `system_translations` VALUES (130, 'txtClickOrDragDropImage', 'Klicken oder Logo hierher ziehen', 'Click or drag the logo here');
INSERT INTO `system_translations` VALUES (131, 'txtClickOrDragDropImageToReplace', 'Klicken oder Logo hierher ziehen, um das Logo zu ersetzen', 'Click or drag logo here to replace the logo');
INSERT INTO `system_translations` VALUES (132, 'txtDeleteLogo', 'Logo löschen', 'Delete logo');
INSERT INTO `system_translations` VALUES (133, 'txtDeletePhoto', 'Foto löschen', 'Delete photo');
INSERT INTO `system_translations` VALUES (134, 'txtDeleteTenantConfirmText', 'Vorsicht, Sie sind im Begriff, einen Mandanten zu löschen. Wenn Sie fortfahren, werden sämtliche Daten dieses Mandaten unwiderruflich gelöscht! Möchten Sie fortfahren?', 'Caution, you are about to delete a tenant. If you continue, all data of this tenant will be irrevocably deleted! Do you want to continue?');
INSERT INTO `system_translations` VALUES (135, 'txtDeleteUserConfirmText', 'Sind Sie ganz sicher, dass Sie diesen Benutzer löschen möchten? Dieser Vorgang kann nicht rückgängig gemacht werden!', 'Are you sure you want to delete this user? This operation cannot be undone!');
INSERT INTO `system_translations` VALUES (136, 'txtDueDate', 'Zahlbar bis', 'Due date');
INSERT INTO `system_translations` VALUES (137, 'txtEditProfile', 'Profil bearbeiten', 'Edit Profile');
INSERT INTO `system_translations` VALUES (138, 'txtEditYourProfile', 'Hier können Sie Ihr eigenes Profil bearbeiten', 'Here you can edit your own profile');
INSERT INTO `system_translations` VALUES (139, 'txtExemptTax', 'Betrag von Steuer befreit', 'Amount exempted from tax');
INSERT INTO `system_translations` VALUES (140, 'txtInvitationFrom', 'Einladung von', 'Invitation from');
INSERT INTO `system_translations` VALUES (141, 'txtInvitationMail', 'Sie wurden von @sender_name@ als Benutzer von @project_name@ registriert. Bitte folgen Sie diesem Link, um die Registrierung abzuschliessen: ', 'You have been added by @sender_name@ as a user of @project_name@. Please follow this link to complete the registration: ');
INSERT INTO `system_translations` VALUES (142, 'txtLogout', 'Logout', 'Logout');
INSERT INTO `system_translations` VALUES (143, 'txtMyCompanyDescription', 'Bearbeiten Sie Ihre Firmenangaben, Ihr Logo und Ihre Rechnungseinstellungen', 'Edit your company details, logo and invoice settings');
INSERT INTO `system_translations` VALUES (144, 'txtMyProfile', 'Mein Profil', 'My profile');
INSERT INTO `system_translations` VALUES (145, 'txtNewTenant', 'Erfassen Sie hier einen neuen Mandanten', 'Create a new tenant here');
INSERT INTO `system_translations` VALUES (146, 'txtPayInvoice', 'Rechnug bezahlen', 'Pay invoice');
INSERT INTO `system_translations` VALUES (147, 'txtPleaseConfirmEmail', 'Vielen Dank für Ihre Registrierung. Um Ihren Account zu erstellen, bestätigen Sie bitte Ihre E-Mail-Adresse, indem Sie auf diesen Link klicken:', 'Thank you for registering. To create your account, please confirm your email address by clicking on this link:');
INSERT INTO `system_translations` VALUES (148, 'txtPlusVat', 'Zzgl. MwSt.', 'Plus VAT.');
INSERT INTO `system_translations` VALUES (149, 'txtPrint', 'Drucken', 'Print');
INSERT INTO `system_translations` VALUES (150, 'txtPrintInvoice', 'Rechnung drucken', 'Print invoice');
INSERT INTO `system_translations` VALUES (151, 'txtProfile', 'Profil', 'Profile');
INSERT INTO `system_translations` VALUES (152, 'txtRegards', 'Mit freundlichem Gruss', 'Best regards');
INSERT INTO `system_translations` VALUES (153, 'txtRegisterLinkNotWorking', 'Falls der Link mit Klick nicht funktioniert, kopieren Sie ihn bitte komplett in die Adresszeile Ihres Browsers.', 'If the link does not work with a click, please copy it completely into the address line of your browser.');
INSERT INTO `system_translations` VALUES (154, 'txtRemoveLogo', 'Logo entfernen', 'Remove logo');
INSERT INTO `system_translations` VALUES (155, 'txtResetOwnPassword', 'Setzen Sie bei Bedarf Ihr eigenes Passwort zurück', 'Reset your own password if necessary');
INSERT INTO `system_translations` VALUES (156, 'txtResetPassword', 'Um Ihr Passwort zurückzusetzen, klicken Sie bitte auf den folgenden Link:', 'To reset your password, please click on the following link:');
INSERT INTO `system_translations` VALUES (157, 'txtSettings', 'Einstellungen', 'Settings');
INSERT INTO `system_translations` VALUES (158, 'txtSetUserAsAdmin', 'Diesen Benutzer als Admin festlegen', 'Set this user as admin');
INSERT INTO `system_translations` VALUES (159, 'txtTotalExcl', 'Betrag exkl. Steuer', 'Amount excl. tax');
INSERT INTO `system_translations` VALUES (160, 'txtTotalIncl', 'Betrag inkl. Steuer', 'Amount incl. tax');
INSERT INTO `system_translations` VALUES (161, 'txtVatIncluded', 'Im Preis enthaltene Steuer', 'Tax included in the price');
INSERT INTO `system_translations` VALUES (162, 'txtView', 'Anzeigen', 'View');
INSERT INTO `system_translations` VALUES (163, 'txtViewInvoice', 'Rechnung anzeigen', 'View invoice');
INSERT INTO `system_translations` VALUES (164, 'txtViewInvoices', 'Sehen Sie Ihre Rechnungen ein und/oder bezahlen Sie sie', 'View and/or pay your invoices');
INSERT INTO `system_translations` VALUES (165, 'txtWhichTenants', 'Auf welche Mandanten hat der Benutzer Zugriff?', 'Which tenants does the user have access to?');
INSERT INTO `system_translations` VALUES (166, 'txtYourTeam', 'Ihr Team vom Kundendienst', 'Your Customer Service Team');
INSERT INTO `system_translations` VALUES (167, 'btnDeleteInvoice', 'Rechnung löschen', 'Delete invoice');
INSERT INTO `system_translations` VALUES (168, 'txtDeleteInvoiceConfirmText', 'Möchten Sie diese Rechnung endgültig löschen?', 'Do you want to delete this invoice permanently?');
INSERT INTO `system_translations` VALUES (169, 'msgInvoiceDeleted', 'Die Rechnung wurde erfolgreich gelöscht.', 'The invoice has been deleted successfully.');
INSERT INTO `system_translations` VALUES (170, 'formLanguage', 'Sprache', 'Language');
INSERT INTO `system_translations` VALUES (171, 'btnEditUser', 'Benutzer editieren', 'Edit user');
INSERT INTO `system_translations` VALUES (172, 'titEditUser', 'Editieren Sie hier den bestehenden Benutzer', 'Edit the existing user here');
INSERT INTO `system_translations` VALUES (173, 'txtOnRequest', 'Auf Anfrage', 'On request');
INSERT INTO `system_translations` VALUES (174, 'txtFree', 'Gratis', 'Free');
INSERT INTO `system_translations` VALUES (175, 'txtMonthly', 'Monatlich', 'Monthly');
INSERT INTO `system_translations` VALUES (176, 'txtYearly', 'Jährlich', 'Yearly');
INSERT INTO `system_translations` VALUES (177, 'statInvoiceDraft', 'Entwurf', 'Draft');
INSERT INTO `system_translations` VALUES (178, 'statInvoiceOverDue', 'Überfällig', 'Overdue');
INSERT INTO `system_translations` VALUES (179, 'titSuperAdmin', 'Superadmin', 'Superadmin');
INSERT INTO `system_translations` VALUES (180, 'txtSetUserAsSuperAdmin', 'Diesen Benutzer als Superadmin festlegen', 'Set this user as Superadmin');
INSERT INTO `system_translations` VALUES (181, 'msgMaxUsersReached', 'Sie haben die maximal zulässige Anzahl Benutzer mit Ihrem gebuchten Plan erreicht. Bitte führen Sie ein Upgrade durch.', 'You have reached the maximum number of users allowed with your booked plan. Please upgrade.');
INSERT INTO `system_translations` VALUES (182, 'titPayment', 'Zahlung', 'Payment');
INSERT INTO `system_translations` VALUES (183, 'txtMonthlyPayment', 'Bei monatlicher Zahlung', 'On monthly payment');
INSERT INTO `system_translations` VALUES (184, 'txtYearlyPayment', 'Bei jährlicher Zahlung', 'On annual payment');
INSERT INTO `system_translations` VALUES (185, 'TitYear', 'Jahr', 'Year');
INSERT INTO `system_translations` VALUES (186, 'TitMonth', 'Monat', 'Month');
INSERT INTO `system_translations` VALUES (187, 'txtOneTime', 'Einmalig', 'One time');
INSERT INTO `system_translations` VALUES (188, 'titPlansAndModules', 'Pläne und Module', 'Plans and modules');
INSERT INTO `system_translations` VALUES (189, 'titYourPlan', 'Ihr Plan', 'Your Plan');
INSERT INTO `system_translations` VALUES (190, 'txtChangePlan', 'Plan ändern', 'Change plan');
INSERT INTO `system_translations` VALUES (191, 'msgNoPlanBooked', 'Sie haben noch keinen Plan gebucht', 'You have not booked a plan yet');
INSERT INTO `system_translations` VALUES (192, 'txtBookNow', 'Jetzt buchen', 'Book now');
INSERT INTO `system_translations` VALUES (193, 'txtPlanStatus', 'Status', 'Status');
INSERT INTO `system_translations` VALUES (194, 'txtRenewPlanOn', 'Ihr Plan wird verlängert am', 'Your plan will be renewed on');
INSERT INTO `system_translations` VALUES (195, 'txtFreeForever', 'Für immer kostenlos', 'Free of charge forever');
INSERT INTO `system_translations` VALUES (196, 'txtExpired', 'Abgelaufen', 'Expired');
INSERT INTO `system_translations` VALUES (197, 'txtPlanExpired', 'Ihr Abonnement ist abgelaufen', 'Your subscription has expired');
INSERT INTO `system_translations` VALUES (198, 'txtTest', 'Test', 'Test');
INSERT INTO `system_translations` VALUES (199, 'txtTestUntil', 'Sie können testen bis zum Ablaufdatum', 'You can test until the expiry date');
INSERT INTO `system_translations` VALUES (200, 'txtTestTimeExpired', 'Ihre Testzeit ist abgelaufen', 'Your test time has expired');
INSERT INTO `system_translations` VALUES (201, 'txtCanceled', 'Gekündigt', 'Canceled');
INSERT INTO `system_translations` VALUES (202, 'txtSubscriptionCanceled', 'Abonnement gekündigt. Sie können es bis zum Ablaufdatum weiter nutzen.', 'Subscription cancelled. You can continue to use it until the expiry date.');
INSERT INTO `system_translations` VALUES (203, 'txtRenewNow', 'Jetzt verlängern', 'Renew now');
INSERT INTO `system_translations` VALUES (204, 'txtUpgradePlanNow', 'Plan jetzt upgraden!', 'Upgrade plan now!');
INSERT INTO `system_translations` VALUES (205, 'txtCancelPlan', 'Plan kündigen', 'Cancel plan');
INSERT INTO `system_translations` VALUES (206, 'txtBookedOn', 'Gebucht am', 'Booked on');
INSERT INTO `system_translations` VALUES (207, 'msgCancelPlanWarningText', 'Wenn Sie Ihr Anonnement kündigen, können Sie bis zum Ende der Laufzeit weiterarbeiten. Danach werden alle Daten dieses Plans gelöscht. Möchten Sie diesen Plan wirklich kündigen?', 'If you cancel your subscription, you can continue until the end of the term. After that, all data in this plan will be deleted. Do you really want to cancel this plan?');
INSERT INTO `system_translations` VALUES (208, 'btnDontCancel', 'Nein, nicht kündigen!', 'No, do not cancel!');
INSERT INTO `system_translations` VALUES (209, 'btnYesCancel', 'Ja, kündigen!', 'Yes, cancel!');
INSERT INTO `system_translations` VALUES (210, 'msgCanceledSuccessful', 'Ihr Abonnement wurde erfolgreich gekündigt.', 'Your subscription has been successfully cancelled.');
INSERT INTO `system_translations` VALUES (211, 'txtExpiryDate', 'Ablaufdatum', 'Expiry date');
INSERT INTO `system_translations` VALUES (212, 'btnRevokeCancellation', 'Kündigung zurückziehen', 'Revoke cancellation');
INSERT INTO `system_translations` VALUES (213, 'msgRevokedSuccessful', 'Die Kündigung wurde erfolgreich zurückgezogen. Ihr Abonnement ist wieder aktiv.', 'The cancellation has been successfully revoked. Your subscription is active again.');
INSERT INTO `system_translations` VALUES (214, 'txtInformation', 'Information', 'Information');
INSERT INTO `system_translations` VALUES (215, 'txtCancel', 'Kündigen', 'Cancel');
INSERT INTO `system_translations` VALUES (216, 'msgCancelModuleWarningText', 'Wenn Sie dieses Modul kündigen, können Sie bis zum Ende der Laufzeit weiterarbeiten. Danach werden alle Daten dieses Moduls gelöscht. Möchten Sie dieses Modul wirklich kündigen?', 'If you cancel this module, you can continue working until the end of the term. After that, all data of this module will be deleted. Do you really want to cancel this module?');
INSERT INTO `system_translations` VALUES (217, 'txtIncludedInPlans', 'Dieses Modul ist in folgenden Plänen bereits enthalten', 'This module is already included in the following plans');
INSERT INTO `system_translations` VALUES (218, 'txtOneTimePayment', 'Einmalige Zahlung', 'One time payment');
INSERT INTO `system_translations` VALUES (219, 'txtIncludedInPlan', 'Im Plan enthalten', 'Included in plan');
INSERT INTO `system_translations` VALUES (220, 'msgThanksForPurchaseFindInvoice', 'Vielen Dank für Ihren Einkauf. Sie finden Ihre Rechnung/Quittung unter Kontoeinstellungen -> Rechnungen.', 'Thank you for your purchase. You can find your invoice/receipt under Account Settings -> Invoices.');
INSERT INTO `system_translations` VALUES (221, 'msgModuleActivated', 'Das gewünschte Modul wurde erfolgreich freigeschaltet.', 'The desired module has been successfully activated.');
INSERT INTO `system_translations` VALUES (222, 'msgPlanActivated', 'Der gewünschte Plan wurde erfolgreich freigeschaltet.', 'The desired plan has been successfully activated.');
INSERT INTO `system_translations` VALUES (223, 'txtUpdateInformation', 'Bitte ergänzen Sie die fehlenden Informationen', 'Please fill in the missing information');
INSERT INTO `system_translations` VALUES (224, 'txtAgreePolicy', 'Ich stimme den Datenschutzbestimmungen zu', 'I agree the privacy policy');
INSERT INTO `system_translations` VALUES (225, 'txtNoInvoices', 'Keine Rechnungen vorhanden!', 'No invoices available!');
INSERT INTO `system_translations` VALUES (226, 'txtContact', 'Kontakt', 'Contact');
INSERT INTO `system_translations` VALUES (227, 'txtNetwork', 'Netzwerk', 'Network');
INSERT INTO `system_translations` VALUES (228, 'titBookedModules', 'Bereits gebuchte Module', 'Already booked modules');
INSERT INTO `system_translations` VALUES (229, 'titAvailableModules', 'Verfügbare Module', 'Available modules');
INSERT INTO `system_translations` VALUES (230, 'titTimezone', 'Zeitzone', 'Timezone');
INSERT INTO `system_translations` VALUES (231, 'txtIncoPayments', 'Zahlungseingang', 'Incoming payment');
INSERT INTO `system_translations` VALUES (232, 'txtRemainingAmount', 'Restbetrag', 'Remaining amount');
INSERT INTO `system_translations` VALUES (233, 'txtComfirmEmailChange', 'Bitte aktivieren Sie die neue E-Mail Adresse!', 'Please activate the new email address!');
INSERT INTO `system_translations` VALUES (234, 'titDowngrade', 'Downgrade', 'Downgrade');
INSERT INTO `system_translations` VALUES (235, 'txtYouAreDowngrading', 'Wenn Sie downgraden, wird der neue Plan erst nach Ablauf des aktuellen Plans aktiviert. Der Plan wird aktiviert am:', 'If you downgrade, the new plan will only be activated after the current plan expires. The plan will be activated on:');
INSERT INTO `system_translations` VALUES (236, 'btnYesDowngrade', 'Ja, jetzt downgraden!', 'Yes, downgrade now!');
INSERT INTO `system_translations` VALUES (237, 'btnWantWait', 'Nein, ich will warten!', 'No, I want to wait!');
INSERT INTO `system_translations` VALUES (238, 'titDowngradeNotPossible', 'Downgrade nicht möglich!', 'Downgrade not possible!');
INSERT INTO `system_translations` VALUES (239, 'txtDowngradeNotPossibleText', 'Um Ihren aktuellen Plan downgraden zu können, müssen Sie einige Ihrer Benutzer löschen. Anzahl zu löschende Benutzer:', 'To downgrade your current plan, you need to delete some of your users. Number of users to delete:');
INSERT INTO `system_translations` VALUES (240, 'btnToTheUsers', 'Zu den Benutzern', 'To the users');
INSERT INTO `system_translations` VALUES (241, 'titUpgrade', 'Upgrade', 'Upgrade');
INSERT INTO `system_translations` VALUES (242, 'txtYouAreUpgrading', 'Möchten Sie auf den gewählten Plan upgraden?', 'Would you like to upgrade to the selected plan?');
INSERT INTO `system_translations` VALUES (243, 'txtToPayToday', 'Der heute zu bezahlende Betrag:', 'The amount to pay today:');
INSERT INTO `system_translations` VALUES (245, 'btnYesUpgrade', 'Ja, jetzt upgraden!', 'Yes, upgrade now!');
INSERT INTO `system_translations` VALUES (246, 'bnEditDashboard', 'Dashboard bearbeiten', 'Edit dashboard');
INSERT INTO `system_translations` VALUES (247, 'bnEndEditDashboard', 'Fertig', 'Finished');
INSERT INTO `system_translations` VALUES (248, 'txtWidgetVisible', 'Sichtbar im Dashboard', 'Visible in dashboard');
INSERT INTO `system_translations` VALUES (249, 'txtWidgetHidden', 'Unsichtbar im Dashboard', 'Hidden in dashboard');
INSERT INTO `system_translations` VALUES (250, 'txtCheckWidgetPath', 'Überprüfen Sie den Widgetpfad', 'Check the widget path');
INSERT INTO `system_translations` VALUES (251, 'txtPrivacyPolicy', 'Beispiel Text', 'Example text');
INSERT INTO `system_translations` VALUES (252, 'titlePrivacyPolicy', 'Datenschutzerklärung', 'Privacy policy');
INSERT INTO `system_translations` VALUES (253, 'msgFileUploadError', 'Fehler beim hochladen der Datei!', 'An error occurred while uploading the file!');
INSERT INTO `system_translations` VALUES (254, 'titRenewal', 'Verlängerung', 'Renewal');
INSERT INTO `system_translations` VALUES (255, 'titPlans', 'Pläne', 'Plans');
INSERT INTO `system_translations` VALUES (256, 'titEditPlan', 'Bearbeiten Sie Ihren Plan', 'Edit your plan');
INSERT INTO `system_translations` VALUES (257, 'titBillingCycle', 'Abrechnungszeitraum', 'Billing cycle');
INSERT INTO `system_translations` VALUES (258, 'titOrderSummary', 'Zusammenfassung der Bestellung', 'Order summary');
INSERT INTO `system_translations` VALUES (259, 'txtUpdatePlan', 'Bearbeiten Sie Ihren aktuellen Plan', 'Edit your current plan');
INSERT INTO `system_translations` VALUES (260, 'txtNewPlanName', 'Neuer Plan', 'New plan');
INSERT INTO `system_translations` VALUES (261, 'txtActivationOn', 'Aktivierung am', 'Activation on');
INSERT INTO `system_translations` VALUES (262, 'titYourCurrentPlan', 'Ihr aktueller Plan', 'Your current plan');
INSERT INTO `system_translations` VALUES (263, 'titCycleChange', 'Zykluswechsel', 'Cycle change');
INSERT INTO `system_translations` VALUES (264, 'titPaymentSettings', 'Zahlungseinstellungen', 'Payment settings');
INSERT INTO `system_translations` VALUES (265, 'txtPaymentSettings', 'Bearbeiten Sie Ihre Zahlungseinstellungen', 'Edit your payment settings');
INSERT INTO `system_translations` VALUES (266, 'txtNoPaymentMethod', 'Sie haben noch keine Zahlungsart erfasst.', 'You have not added a payment method yet.');
INSERT INTO `system_translations` VALUES (267, 'btnAddPaymentMethod', 'Zahlungsart erfassen', 'Add payment method');
INSERT INTO `system_translations` VALUES (268, 'btnRemovePaymentMethod', 'Zahlungsart entfernen', 'Remove payment method');
INSERT INTO `system_translations` VALUES (269, 'msgNeedOnePaymentType', 'Sie benötigen mindestens eine Zahlungsart. Erfassen Sie eine andere Zahlungsart, wenn Sie diese löschen möchten.', 'You need at least one payment method. Add another payment method if you want to delete it.');
INSERT INTO `system_translations` VALUES (270, 'msgPaymentMethodDeleted', 'Die Zahlungsart wurde erfolgreich gelöscht', 'The payment method has been deleted successfully');
INSERT INTO `system_translations` VALUES (272, 'msgPaymentMethodAdded', 'Die neue Zahlungsart wurde erfolgreich erfasst.', 'The new payment method has been added successfully.');
INSERT INTO `system_translations` VALUES (273, 'msgRemovePaymentMethod', 'Möchten Sie diese Zahlungsart wirklich entfernen?', 'Do you really want to remove this payment method?');
INSERT INTO `system_translations` VALUES (274, 'msgCannotCharge', 'Leider konnten wir die von Ihnen hinterlegte Standard-Zahlungsart nicht abbuchen. Bitte erfassen Sie eine neue Zahlungsart und entfernen Sie die nicht funktionierende Zahlungsart.', 'Unfortunately, we were unable to charge the default payment method you registered. Please enter a new payment method and remove the one that does not work.');
INSERT INTO `system_translations` VALUES (275, 'titChargingNotPossible', 'Belastung nicht möglich', 'Charging not possible');
INSERT INTO `system_translations` VALUES (276, 'txtChargingNotPossible', 'Leider konnten wir keine Ihrer registrierten Zahlungsmethoden belasten. Bitte prüfen Sie die Zahlungsarten.', 'Unfortunately, we could not charge any of your registered payment methods. Please check the payment methods.');
INSERT INTO `system_translations` VALUES (278, 'titModule', 'Modul', 'Module');
INSERT INTO `system_translations` VALUES (279, 'txtRemove', 'Entfernen', 'Remove');
INSERT INTO `system_translations` VALUES (280, 'titWaiting', 'Wartet', 'Waiting');
INSERT INTO `system_translations` VALUES (281, 'txtWaitingForPayment', 'Wartet auf Bezahlung', 'Waiting for payment');
INSERT INTO `system_translations` VALUES (282, 'txtRenewModuleOn', 'Ihr Modul wird verlängert am', 'Your module will be renewed on');
INSERT INTO `system_translations` VALUES (283, 'txtAfterwards', 'Danach', 'Afterwards');
INSERT INTO `system_translations` VALUES (284, 'txtOr', 'oder', 'or');
INSERT INTO `system_translations` VALUES (285, 'btnDepPayMethod', 'Mit hinterlegter Zahlungsart bezahlen', 'Pay with deposited payment method');
INSERT INTO `system_translations` VALUES (286, 'btnOtherPayMethod', 'Andere Zahlungsart wählen', 'Choose other payment method');
INSERT INTO `system_translations` VALUES (287, 'msgInvoicePaid', 'Die Rechnung wurde erfolgreich bezahlt. Vielen Dank!', 'The invoice has been paid successfully. Thank you very much!');
INSERT INTO `system_translations` VALUES (288, 'titInvoiceReady', 'Ihre Rechnung/Quittung steht zum Download bereit', 'Your invoice/receipt is ready to download');
INSERT INTO `system_translations` VALUES (289, 'txtDownloadInvoice', 'Mit dem folgendem Button können Sie Ihre Rechnung/Quittung einsehen und downloaden:', 'With the following button you can view and download your invoice/receipt:');
INSERT INTO `system_translations` VALUES (290, 'btnDownloadInvoice', 'Rechnung downloaden', 'Download invoice');
INSERT INTO `system_translations` VALUES (291, 'txtPleasePayInvoice', 'Vielen Dank für Ihre Bestellung. Gerne schalten wir Ihr Produkt nach Zahlung der Rechnung frei. Klicken Sie auf den Button, um direkt zur Rechnung zu gelangen (Login benötigt):', 'Thank you for your order. We will be happy to activate your product after payment of the invoice. Click on the button to go directly to the invoice (login required):');
INSERT INTO `system_translations` VALUES (292, 'titCompanyUser', 'Firma und Benutzer', 'Company and user');
INSERT INTO `system_translations` VALUES (293, 'titDeleteAccount', 'Konto löschen', 'Delete account');
INSERT INTO `system_translations` VALUES (294, 'txtDeleteAccount', 'Bitte bedenken Sie, dass beim Löschen des Kontos Ihre Daten per sofort gelöscht werden. Allfälliges Guthaben wird NICHT erstattet! Sind Sie sicher, dass Sie Ihren Account unwiederruflich löschen möchten? Wenn ja, geben Sie bitte Ihre Login-Daten ein und klicken Sie auf \"Definitiv löschen\".', 'Please note that when you delete your account, your data will be deleted immediately. Any credit balance will NOT be refunded! Are you sure you want to delete your account irrevocably? If so, please enter your login data and click on \"Delete definitely\".');
INSERT INTO `system_translations` VALUES (295, 'btnDeleteDefinitely', 'Definitiv löschen', 'Delete definitely');
INSERT INTO `system_translations` VALUES (296, 'btnTestNow', 'Jetzt testen', 'Test now');
INSERT INTO `system_translations` VALUES (297, 'txtEmailUpdated', 'Die E-Mail wurde aktualisiert!', 'The e-mail has been updated!');
INSERT INTO `system_translations` VALUES (301, 'titNotifications', 'Meldungen', 'Notifications');
INSERT INTO `system_translations` VALUES (302, 'txtShowAllNotifications', 'Alle Meldungen anzeigen', 'Show all notifications');
INSERT INTO `system_translations` VALUES (303, 'txtNotificationDelete', 'Möchten Sie diese Meldung löschen?', 'Do you want to delete this notification?');
INSERT INTO `system_translations` VALUES (304, 'titDeleteNotification', 'Meldung löschen', 'Delete notification');
INSERT INTO `system_translations` VALUES (305, 'txtMultipleNotificationDelete', 'Möchten Sie die ausgewählten Meldungen löschen?', 'Do you want to delete the selected notifications?');
INSERT INTO `system_translations` VALUES (306, 'titMultipleNotificationDelete', 'Meldungen löschen', 'Delete notifications');
INSERT INTO `system_translations` VALUES (307, 'alertNotificationDeleted', 'Meldung gelöscht.', 'Notification deleted.');
INSERT INTO `system_translations` VALUES (308, 'alertMultipleNotificationDeleted', 'Meldungen gelöscht.', 'Notifications deleted.');
INSERT INTO `system_translations` VALUES (309, 'txtTechInform', 'Es tut uns leid, aber auf unserem Server ist ein interner Fehler aufgetreten. Der Techniker wurde informiert...', 'We are sorry, but our server encountered an internal error. The technician got informed...');
INSERT INTO `system_translations` VALUES (310, 'txtTakeBack', 'Bring mich zurück', 'Take me back');
INSERT INTO `system_translations` VALUES (311, 'titCycle', 'Zyklus', 'Cycle');
INSERT INTO `system_translations` VALUES (312, 'titPlan', 'Plan', 'Plan');
INSERT INTO `system_translations` VALUES (313, 'titDateTime', 'Datum/Zeit', 'Date/Time');
INSERT INTO `system_translations` VALUES (314, 'msgNoNotifications', 'Keine Meldungen vorhanden.', 'No messages available.');
INSERT INTO `system_translations` VALUES (315, 'titNotification', 'Meldung', 'Notification');
INSERT INTO `system_translations` VALUES (316, 'titStatus', 'Status', 'Status');
INSERT INTO `system_translations` VALUES (317, 'txtMarkAsRead', 'Als gelesen markieren', 'Mark as read');
INSERT INTO `system_translations` VALUES (318, 'txtSubjectMFA', 'Ihr Code für die Zwei-Faktor-Authentifizierung', 'Your multi-factor authentication code');
INSERT INTO `system_translations` VALUES (319, 'txtMfaCode', 'Nachfolgend finden Sie den Code für die Zwei-Faktor-Authentifizierung', 'Below is your multi-factor authentication code');
INSERT INTO `system_translations` VALUES (320, 'txtThreeTimeTry', 'Sie haben insgesamt drei Versuche, sich mit diesem Code anzumelden.', 'You have a total of three attempts to log in with this code.');
INSERT INTO `system_translations` VALUES (321, 'txtCodeValidity', 'Dieser Code ist nur für eine Stunde gültig.', 'This code is valid for one hour only.');
INSERT INTO `system_translations` VALUES (322, 'titMfa', 'Zwei-Faktor-Authentifizierung', 'Multi-factor authentication');
INSERT INTO `system_translations` VALUES (323, 'txtMfaLable', 'Zwei-Faktor-Authentifizierungs-Code', 'Multi-factor authentication code');
INSERT INTO `system_translations` VALUES (324, 'txtResendMfa', 'Code erneut senden', 'Resend code');
INSERT INTO `system_translations` VALUES (325, 'txtErrorMfaCode', 'Ihr Code ist nicht korrekt, bitte versuchen Sie es erneut!', 'Your code is incorrect, please try again!');
INSERT INTO `system_translations` VALUES (326, 'txtResendDone', 'Der Code wurde gesendet.', 'The code has been sent.');
INSERT INTO `system_translations` VALUES (327, 'txtmfaLead', 'Bitte geben Sie den per E-Mail erhaltenen Code ins Feld ein:', 'Please enter the code received by email into the field:');
INSERT INTO `system_translations` VALUES (328, 'titSysAdmin', 'Sysadmin', 'Sysadmin');
INSERT INTO `system_translations` VALUES (329, 'txtSetUserAsSysAdmin', 'Diesen Benutzer als Sysadmin festlegen', 'Set this user as sysadmin');
INSERT INTO `system_translations` VALUES (330, 'alertCantDeleteAccount', 'Sie haben einen oder mehrere Mandanten erstellt, welche keine eigenen Benutzer besitzen. Sie können Ihren Account erst löschen, wenn alle Mandanten mindestens einen eigenen Benutzer besitzen.', 'You have created one or more tenants that do not have their own users. You can only delete your account once all tenants have at least one user of their own.');
INSERT INTO `system_translations` VALUES (331, 'titCouldNotCharge', 'Ihre Zahlungsart kann nicht abgebucht werden', 'Your payment method cannot be charged');
INSERT INTO `system_translations` VALUES (332, 'msgCouldNotCharge', 'Leider konnten wir Ihre hinterlegte Zahlungsart nicht belasten. Damit Sie Ihr Produkt weiterhin nutzen können, begleichen Sie bitte die offene Rechnung und hinterlegen Sie bitte eine funktionierende Zahlungsart. Besten Dank!', 'Unfortunately, we were unable to charge your payment method. So that you can continue to use your product, please settle the outstanding invoice and enter a functioning payment method. Thank you very much!');

-- ----------------------------
-- Table structure for timezones
-- ----------------------------
DROP TABLE IF EXISTS `timezones`;
CREATE TABLE `timezones`  (
  `intTimeZoneID` int(11) NOT NULL AUTO_INCREMENT,
  `strUTC` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strCity` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strTimezone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`intTimeZoneID`) USING BTREE,
  UNIQUE INDEX `_intTimeZoneID`(`intTimeZoneID`) USING BTREE,
  INDEX `_strTimezone`(`strTimezone`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 85 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of timezones
-- ----------------------------
INSERT INTO `timezones` VALUES (1, 'UTC-10:00', 'Hawaii', 'Pacific/Honolulu');
INSERT INTO `timezones` VALUES (2, 'UTC-09:00', 'Alaska', 'America/Anchorage');
INSERT INTO `timezones` VALUES (3, 'UTC-08:00', 'Baja California', 'America/Santa_Isabel');
INSERT INTO `timezones` VALUES (4, 'UTC-08:00', 'Pacific Time (US and Canada)', 'America/Los_Angeles');
INSERT INTO `timezones` VALUES (5, 'UTC-07:00', 'Chihuahua, La Paz, Mazatlan', 'America/Chihuahua');
INSERT INTO `timezones` VALUES (6, 'UTC-07:00', 'Arizona', 'America/Phoenix');
INSERT INTO `timezones` VALUES (7, 'UTC-07:00', 'Mountain Time (US and Canada)', 'America/Denver');
INSERT INTO `timezones` VALUES (8, 'UTC-06:00', 'Central America', 'America/Guatemala');
INSERT INTO `timezones` VALUES (9, 'UTC-06:00', 'Central Time (US and Canada)', 'America/Chicago');
INSERT INTO `timezones` VALUES (10, 'UTC-06:00', 'Saskatchewan', 'America/Regina');
INSERT INTO `timezones` VALUES (11, 'UTC-06:00', 'Guadalajara, Mexico City, Monterey', 'America/Mexico_City');
INSERT INTO `timezones` VALUES (12, 'UTC-05:00', 'Bogota, Lima, Quito', 'America/Bogota');
INSERT INTO `timezones` VALUES (13, 'UTC-05:00', 'Indiana (East)', 'America/Indiana/Indi');
INSERT INTO `timezones` VALUES (14, 'UTC-05:00', 'Eastern Time (US and Canada)', 'America/New_York');
INSERT INTO `timezones` VALUES (15, 'UTC-04:00', 'Atlantic Time (Canada)', 'America/Halifax');
INSERT INTO `timezones` VALUES (16, 'UTC-04:00', 'Asuncion', 'America/Asuncion');
INSERT INTO `timezones` VALUES (17, 'UTC-04:00', 'Georgetown, La Paz, Manaus, San Juan', 'America/La_Paz');
INSERT INTO `timezones` VALUES (18, 'UTC-04:00', 'Cuiaba', 'America/Cuiaba');
INSERT INTO `timezones` VALUES (19, 'UTC-04:00', 'Santiago', 'America/Santiago');
INSERT INTO `timezones` VALUES (20, 'UTC-03:00', 'Brasilia', 'America/Sao_Paulo');
INSERT INTO `timezones` VALUES (21, 'UTC-03:00', 'Greenland', 'America/Godthab');
INSERT INTO `timezones` VALUES (22, 'UTC-03:00', 'Cayenne, Fortaleza', 'America/Cayenne');
INSERT INTO `timezones` VALUES (23, 'UTC-03:00', 'Buenos Aires', 'America/Argentina/Bu');
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
INSERT INTO `timezones` VALUES (60, 'UTC+05:00', 'Yekaterinburg', 'Asia/Yekaterinburg');
INSERT INTO `timezones` VALUES (61, 'UTC+07:00', 'Bangkok, Hanoi, Jakarta', 'Asia/Bangkok');
INSERT INTO `timezones` VALUES (62, 'UTC+07:00', 'Novosibirsk', 'Asia/Novosibirsk');
INSERT INTO `timezones` VALUES (63, 'UTC+07:00', 'Krasnoyarsk', 'Asia/Krasnoyarsk');
INSERT INTO `timezones` VALUES (64, 'UTC+08:00', 'Ulaanbaatar', 'Asia/Ulaanbaatar');
INSERT INTO `timezones` VALUES (65, 'UTC+08:00', 'Beijing, Chongqing, Hong Kong, Urumqi', 'Asia/Shanghai');
INSERT INTO `timezones` VALUES (66, 'UTC+08:00', 'Perth', 'Australia/Perth');
INSERT INTO `timezones` VALUES (67, 'UTC+08:00', 'Kuala Lumpur, Singapore', 'Asia/Singapore');
INSERT INTO `timezones` VALUES (68, 'UTC+08:00', 'Taipei', 'Asia/Taipei');
INSERT INTO `timezones` VALUES (69, 'UTC+08:00', 'Irkutsk', 'Asia/Irkutsk');
INSERT INTO `timezones` VALUES (70, 'UTC+09:00', 'Seoul', 'Asia/Seoul');
INSERT INTO `timezones` VALUES (71, 'UTC+09:00', 'Osaka, Sapporo, Tokyo', 'Asia/Tokyo');
INSERT INTO `timezones` VALUES (72, 'UTC+10:00', 'Hobart', 'Australia/Hobart');
INSERT INTO `timezones` VALUES (73, 'UTC+09:00', 'Yakutsk', 'Asia/Yakutsk');
INSERT INTO `timezones` VALUES (74, 'UTC+10:00', 'Brisbane', 'Australia/Brisbane');
INSERT INTO `timezones` VALUES (75, 'UTC+10:00', 'Guam, Port Moresby', 'Pacific/Port_Moresby');
INSERT INTO `timezones` VALUES (76, 'UTC+10:00', 'Canberra, Melbourne, Sydney', 'Australia/Sydney');
INSERT INTO `timezones` VALUES (77, 'UTC+11:00', 'Vladivostok', 'Asia/Vladivostok');
INSERT INTO `timezones` VALUES (78, 'UTC+11:00', 'Solomon Islands, New Caledonia', 'Pacific/Guadalcanal');
INSERT INTO `timezones` VALUES (79, 'UTC+12:00', 'Coordinated Universal Time+12', 'Etc/GMT-12');
INSERT INTO `timezones` VALUES (80, 'UTC+12:00', 'Fiji, Marshall Islands', 'Pacific/Fiji');
INSERT INTO `timezones` VALUES (81, 'UTC+11:00', 'Magadan', 'Asia/Magadan');
INSERT INTO `timezones` VALUES (82, 'UTC+12:00', 'Auckland, Wellington', 'Pacific/Auckland');
INSERT INTO `timezones` VALUES (83, 'UTC+13:00', 'Nuku`alofa', 'Pacific/Tongatapu');
INSERT INTO `timezones` VALUES (84, 'UTC+13:00', 'Samoa', 'Pacific/Apia');

-- ----------------------------
-- Table structure for user_widgets
-- ----------------------------
DROP TABLE IF EXISTS `user_widgets`;
CREATE TABLE `user_widgets`  (
  `intUserWidgetID` int(11) NOT NULL AUTO_INCREMENT,
  `intWidgetID` int(11) NOT NULL,
  `intUserID` int(11) NOT NULL,
  `intPrio` int(11) NOT NULL,
  `blnActive` tinyint(1) NULL DEFAULT NULL,
  PRIMARY KEY (`intUserWidgetID`) USING BTREE,
  INDEX `_intUserID`(`intUserID`) USING BTREE,
  INDEX `_intWidgetID`(`intWidgetID`) USING BTREE,
  CONSTRAINT `frn_uw_user` FOREIGN KEY (`intUserID`) REFERENCES `users` (`intUserID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_uw_widgets` FOREIGN KEY (`intWidgetID`) REFERENCES `widgets` (`intWidgetID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_widgets
-- ----------------------------
INSERT INTO `user_widgets` VALUES (1, 1, 1, 1, 1);
INSERT INTO `user_widgets` VALUES (2, 1, 2, 1, 1);
INSERT INTO `user_widgets` VALUES (3, 1, 3, 1, 1);
INSERT INTO `user_widgets` VALUES (4, 1, 4, 1, 1);
INSERT INTO `user_widgets` VALUES (5, 1, 6, 1, 1);
INSERT INTO `user_widgets` VALUES (6, 1, 5, 1, 1);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `intUserID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `dtmInsertDate` datetime NOT NULL,
  `dtmMutDate` datetime NOT NULL,
  `strSalutation` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strFirstName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strLastName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strEmail` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPasswordHash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPasswordSalt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPhone` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strMobile` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPhoto` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strLanguage` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 0,
  `dtmLastLogin` datetime NULL DEFAULT NULL,
  `blnAdmin` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'The admin has access to the main tenant as well as to the tenants to which he has been given access.',
  `blnSuperAdmin` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'The super admin has access to all tenants. The first user of this project is automatically the super admin.',
  `blnSysAdmin` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'The sysadmin is the technical owner of this project',
  `strUUID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intMfaCode` int(11) NULL DEFAULT NULL,
  `dtmMfaDateTime` datetime NULL DEFAULT NULL,
  `blnMfa` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intUserID`) USING BTREE,
  UNIQUE INDEX `_intUserID`(`intUserID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_user_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 1, '2024-05-07 14:38:29', '2024-05-07 14:38:29', 'Herr', 'Patrick', 'Trüssel', 'info@paweco.ch', '9C4F5FF6075517AE835484BACA547E8FAEFE1D090FE59D4843D0FBAC9DDB0CE2321D3399D9AF1123A694100F98CDA6C52942C96A8839E41B82E74BBEBECEA5DB', '3B52E434518F8F1B3607D9D5C2FBD109FDA07E3FB444D71926B799AF081CD943D66920983B091C67E5E0F018B98A41E223772C867A8B38B9F4D81A8FB770F361', '', '', NULL, 'de', 1, '2024-07-16 09:05:29', 1, 1, 1, '', NULL, NULL, 0);
INSERT INTO `users` VALUES (2, 2, '2024-05-28 06:48:17', '2024-05-28 06:48:17', NULL, 'Patrick', 'Trüssel', 'pt@paweco.ch', '4CD996247215AA899D392E43942AB9F0FE7209F65551673C0879C0495568F8179F3AFBF7023CD8864BF5C7D58E75407EB9BACFACBDE99D0069E489E8E918C0E6', '68BDD757B42F1ADAD3E9E618F639FCD39F610D5E7FA6713C94373C79B83C751146855889BD8113A8DD692C97422D5766671211455C322B5EC84E1D9353DA0A51', NULL, NULL, NULL, 'de', 1, '2024-07-12 15:38:03', 1, 1, 0, '', NULL, NULL, 0);
INSERT INTO `users` VALUES (3, 3, '2024-07-11 14:26:31', '2024-07-11 14:26:31', 'Herr', 'Hans', 'Müller', 'hans@mueller.com', '8DA427D2AEBE5F370D8285E553502C730E308D2EE9B59B2DA8714960F932709EE480B0A89F7A59154455C66CCC6179A5AC6265E1FC67F694E9F944AC5EBEC002', '688FA26D4E773BDCED290521C7E6457384BB2DF3E063AA2E61DA69C6D630463E7B442A32855CE07F44F8A07C628132BA45D171C2D9A1ECD83C108E75A7D6F766', '+41415520150', '54654654654', 'c48da0826a924f748fa8da7d4ebc29bb.jpg', 'de', 1, '2024-07-12 13:32:55', 1, 1, 0, '', NULL, NULL, 0);
INSERT INTO `users` VALUES (4, 4, '2024-07-12 15:08:50', '2024-07-12 15:08:50', 'Frau', 'Franziska', 'Ritter', 'fr@paweco.ch', '89080923D82264A1006BBD765CBD7029DE8DF29A2582B083E7BE68A4EE594FFA503496574237A75E75A2A0F8A09C3D7DF875A220E9C580A0582ED3A1858E6D02', '5C9A0603E618F2B481FCA417706B7C84CE5C1555A43E4C15C95FAFB990026783C1A96CCA4A26149A272BE14AFBD2ECDFCB2D83301038B24C019ED3E8C00BC8E6', '041 552 01 50', '54654654654', '976f60d54a64453090b2613ca088f870.jpg', 'de', 1, '2024-07-15 09:26:01', 1, 1, 0, '', NULL, NULL, 0);
INSERT INTO `users` VALUES (5, 5, '2024-07-12 15:14:06', '2024-07-12 15:14:06', 'Herr', 'Mike', 'Meyer', 'mike@meyer.ch', '2CA8C3B1DA5D375CBBDC8EA81CD9947EC097CC23A2A0FDB1E1B2641A0064C1DBE09B1B88842FF2870D546C260A27EADADF7A0776436606E1490F93CF56ECDEC3', 'F66C495951D10417BC54027E2ECC0956D0DB207889FE3CC6AA0545A38E39762679DFCD425F83490AC709C61CF5E5A2B3A54658BF366B6BC45C8C05D45A217DD5', '', '', NULL, 'de', 1, '2024-07-15 14:56:40', 1, 1, 0, '', NULL, NULL, 0);
INSERT INTO `users` VALUES (6, 6, '2024-07-12 15:40:20', '2024-07-12 15:40:20', NULL, 'Paul', 'Lötscher', 'p@loetscher.ch', '7D03F142FA17B96C1E2F6EF6B5750B1F1E0A61DBFAF4574CD419C3C9DC53B7AAC028352A69FE870E3FCB796669D3F94D3F54CBE6C3CC27F4CF627D703AC08E25', 'EF8AB353F5042AB761AA1637EE0C2C6376C394460BAE586846F1A113C47E375292C6FD34CF903D1966FE539052DD109E7EF0B08B362A8DF30307E55F9F09E335', NULL, NULL, NULL, 'de', 1, '2024-07-12 15:40:26', 1, 1, 0, '', NULL, NULL, 0);

-- ----------------------------
-- Table structure for widget_ratio
-- ----------------------------
DROP TABLE IF EXISTS `widget_ratio`;
CREATE TABLE `widget_ratio`  (
  `intRatioID` int(11) NOT NULL AUTO_INCREMENT,
  `intSizeRatio` int(3) NOT NULL,
  `strDescription` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`intRatioID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of widget_ratio
-- ----------------------------
INSERT INTO `widget_ratio` VALUES (1, 12, 'Full width (1/1)');
INSERT INTO `widget_ratio` VALUES (2, 9, 'Three quarter width (3/4)');
INSERT INTO `widget_ratio` VALUES (3, 6, 'Half width (1/2)');
INSERT INTO `widget_ratio` VALUES (4, 4, 'Third width (1/3)');
INSERT INTO `widget_ratio` VALUES (5, 3, 'Quarter width (1/4)');

-- ----------------------------
-- Table structure for widgets
-- ----------------------------
DROP TABLE IF EXISTS `widgets`;
CREATE TABLE `widgets`  (
  `intWidgetID` int(11) NOT NULL AUTO_INCREMENT,
  `strWidgetName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strFilePath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 1,
  `intRatioID` int(2) NULL DEFAULT 1,
  `blnPermDisplay` tinyint(1) NULL DEFAULT 1,
  PRIMARY KEY (`intWidgetID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of widgets
-- ----------------------------
INSERT INTO `widgets` VALUES (1, 'Welcome', 'backend/myapp/widgets/welcome.cfm', 1, 1, 1);

-- ----------------------------
-- Table structure for widgets_modules
-- ----------------------------
DROP TABLE IF EXISTS `widgets_modules`;
CREATE TABLE `widgets_modules`  (
  `intWidgetModuleID` int(11) NOT NULL AUTO_INCREMENT,
  `intWidgetID` int(11) NOT NULL,
  `intModuleID` int(11) NOT NULL,
  PRIMARY KEY (`intWidgetModuleID`) USING BTREE,
  INDEX `frn_wm_widgets`(`intWidgetID`) USING BTREE,
  INDEX `frn_wm_modules`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_wm_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_wm_widgets` FOREIGN KEY (`intWidgetID`) REFERENCES `widgets` (`intWidgetID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of widgets_modules
-- ----------------------------

-- ----------------------------
-- Table structure for widgets_plans
-- ----------------------------
DROP TABLE IF EXISTS `widgets_plans`;
CREATE TABLE `widgets_plans`  (
  `intWidgetPlanID` int(11) NOT NULL AUTO_INCREMENT,
  `intWidgetID` int(11) NOT NULL,
  `intPlanID` int(11) NOT NULL,
  PRIMARY KEY (`intWidgetPlanID`) USING BTREE,
  INDEX `frn_wp_widgets`(`intWidgetID`) USING BTREE,
  INDEX `frn_wp_plans`(`intPlanID`) USING BTREE,
  CONSTRAINT `frn_wp_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_wp_widgets` FOREIGN KEY (`intWidgetID`) REFERENCES `widgets` (`intWidgetID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of widgets_plans
-- ----------------------------

-- ----------------------------
-- Table structure for widgets_trans
-- ----------------------------
DROP TABLE IF EXISTS `widgets_trans`;
CREATE TABLE `widgets_trans`  (
  `intWidgetTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intWidgetID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strWidgetName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`intWidgetTransID`) USING BTREE,
  INDEX `_intWidgetID`(`intWidgetID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_wt_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_wt_widgets` FOREIGN KEY (`intWidgetID`) REFERENCES `widgets` (`intWidgetID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of widgets_trans
-- ----------------------------

-- ----------------------------
-- Function structure for beautify
-- ----------------------------

DROP FUNCTION IF EXISTS `beautify`;
CREATE FUNCTION `beautify`(s NVARCHAR(500))
 RETURNS varchar(500) CHARSET utf8
  DETERMINISTIC
RETURN

/* Always 10 per line */
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(

/* Closing */
REPLACE(REPLACE(REPLACE(

LOWER(TRIM(s)),

'+', ''),
'^', ''),
'$', ''),
':', ''),
')', ''),
'(', ''),
',', ''),
'\\', ''),
'/', ''),
'"', ''),

/* 10 */

'?', ''),
"'", ''),
'&', ''),
'!', ''),
'.', ''),
' ', '-'),
'|', '-'),
'ù','u'),
'ú','u'),
'û','u'),

/* 10 */

'ü','u'),
'ý','y'),
'ë','e'),
'à','a'),
'á','a'),
'â','a'),
'ã','a'),
'ä','a'),
'å','a'),
'æ','a'),

/* 10 */

'ç','c'),
'è','e'),
'é','e'),
'ê','e'),
'ë','e'),
'ì','i'),
'í','i'),
'ě','e'),
'š','s'),
'č','c'),

/* 10 */

'ř','r'),
'ž','z'),
'î','i'),
'ï','i'),
'ð','o'),
'ñ','n'),
'ò','o'),
'ó','o'),
'ô','o'),
'õ','o'),

/* 10 */

'ö','o'),
'ø','o'),
'%', ''),
'#', ''),
'°', ''),
'¬', ''),
'=', ''),
'§', ''),
'@', ''),
'*', ''),

/* 10 */

'¢', 'c'),
'™', ''),
'©', ''),
'®', ''),
'ß', ''),
'[', ''),
']', ''),
'{', ''),
'}', ''),
'_', '-'),

/* 10 */

'£', ''),
'>', ''),
'<', ''),
';', ''),
';', ''),
'¨', ''),

/* Closing */

'--', '-'),
'---', '-'),
'----', '-')
;


DROP TRIGGER IF EXISTS `updPaymStatInsert`;
CREATE TRIGGER `updPaymStatInsert` AFTER INSERT ON `payments` FOR EACH ROW UPDATE invoices
SET intPaymentStatusID = IF(NEW.decAmount >= decTotalPrice, 3, 4)
WHERE intInvoiceID = NEW.intInvoiceID;

DROP TRIGGER IF EXISTS `insertConnect`;
CREATE TRIGGER `insertConnect` AFTER INSERT ON `users` FOR EACH ROW INSERT INTO customer_user (intCustomerID, intUserID, blnStandard)
VALUES (NEW.intCustomerID, NEW.intUserID, 1);

SET FOREIGN_KEY_CHECKS = 1;
