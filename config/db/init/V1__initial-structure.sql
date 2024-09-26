SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


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
INSERT INTO `countries` VALUES (149, 'Switzerland', 1, 'de_CH', 'CH', 'CHE', 'CHF', 'Europe', 'Western Europe', 32, 'https://flagcdn.com/ch.svg', 0, 0, 0);
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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

INSERT INTO `currencies` VALUES (1, 'USD', 'US Dollar', 'US Dollar', '$', 1, 1, 1);
INSERT INTO `currencies` VALUES (2, 'EUR', 'Euro', 'Euro', '€', 2, 0, 1);
INSERT INTO `currencies` VALUES (3, 'CHF', 'Swiss Francs', 'Schweizer Franken', 'CHF', 3, 0, 0);

DROP TABLE IF EXISTS `custom_mappings`;
CREATE TABLE `custom_mappings`  (
  `intCustomMappingID` int(11) NOT NULL AUTO_INCREMENT,
  `strMapping` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strPath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `blnOnlyAdmin` tinyint(1) NOT NULL DEFAULT 0,
  `blnOnlySuperAdmin` tinyint(1) NOT NULL DEFAULT 0,
  `blnOnlySysAdmin` tinyint(1) NOT NULL DEFAULT 0,
  `intModuleID` int(11) NULL,
  PRIMARY KEY (`intCustomMappingID`) USING BTREE,
  UNIQUE INDEX `_strMapping`(`strMapping`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_cm_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

DROP TABLE IF EXISTS `custom_translations`;
CREATE TABLE `custom_translations`  (
  `intCustTransID` int(11) NOT NULL AUTO_INCREMENT,
  `strVariable` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strStringDE` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strStringEN` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`intCustTransID`) USING BTREE,
  UNIQUE INDEX `_strVariable`(`strVariable`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

DROP TABLE IF EXISTS `invoice_status`;
CREATE TABLE `invoice_status`  (
  `intPaymentStatusID` int(11) NOT NULL AUTO_INCREMENT,
  `strInvoiceStatusVariable` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strColor` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`intPaymentStatusID`) USING BTREE,
  UNIQUE INDEX `_intPaymentStatusID`(`intPaymentStatusID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

INSERT INTO `invoice_status` VALUES (1, 'statInvoiceDraft', 'muted');
INSERT INTO `invoice_status` VALUES (2, 'statInvoiceOpen', 'blue');
INSERT INTO `invoice_status` VALUES (3, 'statInvoicePaid', 'green');
INSERT INTO `invoice_status` VALUES (4, 'statInvoicePartPaid', 'orange');
INSERT INTO `invoice_status` VALUES (5, 'statInvoiceCanceled', 'purple');
INSERT INTO `invoice_status` VALUES (6, 'statInvoiceOverDue', 'red');

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
  `strUUID` varchar(100) NULL,
  PRIMARY KEY (`intInvoiceID`) USING BTREE,
  UNIQUE INDEX `_intInvoiceID`(`intInvoiceID`) USING BTREE,
  UNIQUE INDEX `_intInvoiceNumber`(`intInvoiceNumber`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intPaymentStatusID`(`intPaymentStatusID`) USING BTREE,
  FULLTEXT INDEX `FulltextStrings`(`strInvoiceTitle`, `strCurrency`),
  CONSTRAINT `frn_inv_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_inv_invstat` FOREIGN KEY (`intPaymentStatusID`) REFERENCES `invoice_status` (`intPaymentStatusID`) ON DELETE RESTRICT ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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

INSERT INTO `languages` VALUES (1, 'en', 'English', 'English', 1, 1, 1);
INSERT INTO `languages` VALUES (2, 'de', 'German', 'Deutsch', 2, 0, 1);

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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

DROP TABLE IF EXISTS `plan_features`;
CREATE TABLE `plan_features`  (
  `intPlanFeatureID` int(11) NOT NULL AUTO_INCREMENT,
  `strFeatureName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strDescription` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `blnCategory` tinyint(1) NOT NULL DEFAULT 0,
  `strVariable` varchar(100) NULL,
  `intPrio` int(5) NOT NULL,
  PRIMARY KEY (`intPlanFeatureID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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


DROP TABLE IF EXISTS `plan_groups`;
CREATE TABLE `plan_groups`  (
  `intPlanGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `strGroupName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intCountryID` int(11) NULL DEFAULT NULL,
  `intPrio` int(11) NOT NULL,
  PRIMARY KEY (`intPlanGroupID`) USING BTREE,
  INDEX `_intCountryID`(`intCountryID`) USING BTREE,
  CONSTRAINT `frn_pg_countries` FOREIGN KEY (`intCountryID`) REFERENCES `countries` (`intCountryID`) ON DELETE RESTRICT ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

DROP TABLE IF EXISTS `plans_modules`;
CREATE TABLE `plans_modules`  (
  `intPlanModuleID` int(11) NOT NULL AUTO_INCREMENT,
  `intPlanID` int(11) NOT NULL,
  `intModuleID` int(11) NOT NULL,
  PRIMARY KEY (`intPlanModuleID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 70 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

INSERT INTO `system_mappings` VALUES (1, 'login', 'frontend/login.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (2, 'register', 'frontend/register.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (3, 'password', 'frontend/password.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (4, 'dashboard', 'views/dashboard.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (5, 'account-settings/my-profile', 'views/customer/my-profile.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (6, 'customer', 'handler/customer.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (7, 'global', 'handler/global.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (9, 'registration', 'handler/register.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (12, 'account-settings', 'views/customer/account-settings.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (13, 'account-settings/company', 'views/customer/company-edit.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (14, 'account-settings/tenants', 'views/customer/tenants.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (15, 'account-settings/users', 'views/customer/users.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (17, 'account-settings/reset-password', 'views/customer/reset-password.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (19, 'account-settings/user/new', 'views/customer/user_new.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (20, 'account-settings/user/edit', 'views/customer/user_edit.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (21, 'account-settings/tenant/new', 'views/customer/tenant_new.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (23, 'account-settings/invoices', 'views/invoices/invoices.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (25, 'account-settings/invoice', 'views/invoices/invoice.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (26, 'account-settings/modules', 'views/customer/modules.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (27, 'invoices', 'handler/invoices.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (29, 'sysadmin/mappings', 'views/sysadmin/mappings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (31, 'sysadmin/translations', 'views/sysadmin/translations.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (32, 'sysadmin/settings', 'views/sysadmin/settings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (33, 'user', 'handler/user.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (34, 'sysadmin/languages', 'views/sysadmin/languages.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (36, 'sysadmin/countries', 'views/sysadmin/countries.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (37, 'sysadmin/countries/import', 'views/sysadmin/country_import.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (39, 'sysadmin/modules', 'views/sysadmin/modules.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (41, 'sysadmin/modules/edit', 'views/sysadmin/module_edit.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (42, 'sysadmin/widgets', 'views/sysadmin/widgets.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (43, 'sysadm/mappings', 'handler/sysadmin/mappings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (44, 'sysadm/translations', 'handler/sysadmin/translations.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (45, 'sysadm/languages', 'handler/sysadmin/languages.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (46, 'sysadm/settings', 'handler/sysadmin/settings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (47, 'sysadm/countries', 'handler/sysadmin/countries.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (48, 'sysadm/modules', 'handler/sysadmin/modules.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (49, 'account-settings/invoice/print', 'views/invoices/print.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (50, 'sysadm/widgets', 'handler/sysadmin/widgets.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (51, 'sysadmin/plans', 'views/sysadmin/plans.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (52, 'sysadmin/currencies', 'views/sysadmin/currencies.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (53, 'sysadm/currencies', 'handler/sysadmin/currencies.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (54, 'sysadm/plans', 'handler/sysadmin/plans.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (55, 'sysadmin/plan/edit', 'views/sysadmin/plan_edit.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (56, 'sysadmin/plangroups', 'views/sysadmin/plan_groups.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (57, 'sysadmin/planfeatures', 'views/sysadmin/plan_features.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (58, 'plans', 'frontend/plans.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (59, 'sysadmin/invoices', 'views/sysadmin/invoices.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (60, 'sysadm/invoices', 'handler/sysadmin/invoices.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (61, 'sysadmin/invoice/edit', 'views/sysadmin/invoice_edit.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (62, 'sysadmin/customers', 'views/sysadmin/customers.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (63, 'sysadm/customers', 'handler/sysadmin/customers.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (64, 'sysadmin/customers/edit', 'views/sysadmin/customers_edit.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (65, 'sysadmin/customers/details', 'views/sysadmin/customers_details.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (66, 'sysadmin/system-settings', 'views/sysadmin/system_settings.cfm', 0, 0, 1);
INSERT INTO `system_mappings` VALUES (67, 'book', 'frontend/book.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (68, 'cancel', 'handler/cancel.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (69, 'dashboard-settings', 'handler/dashboard.cfm', 0, 0, 0);
INSERT INTO `system_mappings` VALUES (70, 'account-settings/plans', 'views/customer/plans.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (71, 'plan-settings', 'handler/plans.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (72, 'account-settings/payment', 'views/customer/payment.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (73, 'payment-settings', 'handler/payment.cfm', 0, 1, 0);
INSERT INTO `system_mappings` VALUES (74, 'account-settings/settings', 'views/customer/settings.cfm', 1, 0, 0);
INSERT INTO `system_mappings` VALUES (75, 'notifications', 'views/customer/notifications.cfm', 0, 0, 0);

DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE `system_settings`  (
  `intSystSettingID` int(11) NOT NULL AUTO_INCREMENT,
  `strSettingVariable` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDefaultValue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`intSystSettingID`) USING BTREE,
  UNIQUE INDEX `_intSystSettingID`(`intSystSettingID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

INSERT INTO `system_settings` VALUES (1, 'settingInvoiceNumberStart', '1000', 'New invoice: At which invoice number should the system start?');
INSERT INTO `system_settings` VALUES (2, 'settingRoundFactor', '1', 'The rounding factor for invoice amounts. Note: Currently only 5 (0.05 Switzerland) or 1 (0.01 rest of the world) are available.');
INSERT INTO `system_settings` VALUES (3, 'settingStandardVatType', '3', 'Which vat type should be set by default?');
INSERT INTO `system_settings` VALUES (4, 'settingInvoicePrefix', 'INV-', 'Invoices can be preceded by a short prefix. Enter it here.');
INSERT INTO `system_settings` VALUES (5, 'settingInvoiceNet', '1', 'Decide whether the invoices are issued \"net\" by default.');
INSERT INTO `system_settings` VALUES (6, 'settingLayout', 'horizontal', 'Choose a layout you want to use');

DROP TABLE IF EXISTS `system_translations`;
CREATE TABLE `system_translations`  (
  `intSystTransID` int(11) NOT NULL AUTO_INCREMENT,
  `strVariable` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strStringDE` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strStringEN` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`intSystTransID`) USING BTREE,
  UNIQUE INDEX `_strVariable`(`strVariable`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 255 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
INSERT INTO `system_translations` VALUES (202, 'txtSubscriptionCanceled', 'Abonnement gekündigt. Ihre Daten werden nach dem Ablaufdatum gelöscht.', 'Subscription cancelled. Your data will be deleted after the expiry date.');
INSERT INTO `system_translations` VALUES (203, 'txtRenewNow', 'Jetzt verlängern', 'Renew now');
INSERT INTO `system_translations` VALUES (204, 'txtUpgradePlanNow', 'Plan jetzt upgraden!', 'Upgrade plan now!');
INSERT INTO `system_translations` VALUES (205, 'txtCancelPlan', 'Plan kündigen', 'Cancel plan');
INSERT INTO `system_translations` VALUES (206, 'txtBookedOn', 'Gebucht am', 'Booked on');
INSERT INTO `system_translations` VALUES (207, 'msgCancelPlanWarningText', 'Wenn Sie Ihr Anonnement kündigen, können Sie bis zum Ende der Laufzeit weiterarbeiten. Danach werden alle Daten dieses Plans gelöscht. Möchten Sie diesen Plan wirklich kündigen?', 'If you cancel your subscription, you can continue until the end of the term. After that, all data in this plan will be deleted. Do you really want to cancel this plan?');
INSERT INTO `system_translations` VALUES (208, 'btnDontCancel', 'Nein, nicht kündigen!', 'No, do not cancel!');
INSERT INTO `system_translations` VALUES (209, 'btnYesCancel', 'Ja, kündigen!', 'Yes, cancel!');
INSERT INTO `system_translations` VALUES (210, 'msgCanceledSuccessful', 'Ihr Abonnement wurde erfolgreich gekündigt. Am Ende der Laufzeit werden Ihre Daten gelöscht.', 'Your subscription has been successfully cancelled. At the end of the term, your data will be deleted.');
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
INSERT INTO `system_translations` VALUES (255,'titPlans', 'Pläne', 'Plans');
INSERT INTO `system_translations` VALUES (256,'titEditPlan', 'Bearbeiten Sie Ihren Plan', 'Edit your plan');
INSERT INTO `system_translations` VALUES (257,'titBillingCycle', 'Abrechnungszeitraum', 'Billing cycle');
INSERT INTO `system_translations` VALUES (258,'titOrderSummary', 'Zusammenfassung der Bestellung', 'Order summary');
INSERT INTO `system_translations` VALUES (259,'txtUpdatePlan', 'Bearbeiten Sie Ihren aktuellen Plan', 'Edit your current plan');
INSERT INTO `system_translations` VALUES (260,'txtNewPlanName', 'Neuer Plan', 'New plan');
INSERT INTO `system_translations` VALUES (261,'txtActivationOn', 'Aktivierung am', 'Activation on');
INSERT INTO `system_translations` VALUES (262,'titYourCurrentPlan', 'Ihr aktueller Plan', 'Your current plan');
INSERT INTO `system_translations` VALUES (263,'titCycleChange', 'Zykluswechsel', 'Cycle change');
INSERT INTO `system_translations` VALUES (264,'titPaymentSettings', 'Zahlungseinstellungen', 'Payment settings');
INSERT INTO `system_translations` VALUES (265,'txtPaymentSettings', 'Bearbeiten Sie Ihre Zahlungseinstellungen', 'Edit your payment settings');
INSERT INTO `system_translations` VALUES (266,'txtNoPaymentMethod', 'Sie haben noch keine Zahlungsart erfasst.', 'You have not added a payment method yet.');
INSERT INTO `system_translations` VALUES (267,'btnAddPaymentMethod', 'Zahlungsart erfassen', 'Add payment method');
INSERT INTO `system_translations` VALUES (268,'btnRemovePaymentMethod', 'Zahlungsart entfernen', 'Remove payment method');
INSERT INTO `system_translations` VALUES (269,'msgNeedOnePaymentType', 'Sie benötigen mindestens eine Zahlungsart. Erfassen Sie eine andere Zahlungsart, wenn Sie diese löschen möchten.', 'You need at least one payment method. Add another payment method if you want to delete it.');
INSERT INTO `system_translations` VALUES (270,'msgPaymentMethodDeleted', 'Die Zahlungsart wurde erfolgreich gelöscht', 'The payment method has been deleted successfully');
INSERT INTO `system_translations` VALUES (271,'msgWeDoNotCharge', 'Bitte beachten Sie, dass beim Hinzufügen einer neuen Zahlungsart der Betrag von 1.- in Ihrer Währung angezeigt wird. Dies dient lediglich zur Validierung Ihrer Zahlungsart und wird NICHT belastet.', 'Please note that when you add a new payment method, the amount of 1.- will be displayed in your currency. This is only to validate your payment method and will NOT be charged.');
INSERT INTO `system_translations` VALUES (272,'msgPaymentMethodAdded', 'Die neue Zahlungsart wurde erfolgreich erfasst.', 'The new payment method has been added successfully.');
INSERT INTO `system_translations` VALUES (273,'msgRemovePaymentMethod', 'Möchten Sie diese Zahlungsart wirklich entfernen?', 'Do you really want to remove this payment method?');
INSERT INTO `system_translations` VALUES (274,'msgCannotCharge', 'Leider konnten wir die von Ihnen hinterlegte Standard-Zahlungsart nicht abbuchen. Bitte erfassen Sie eine neue Zahlungsart und entfernen Sie die nicht funktionierende Zahlungsart.', 'Unfortunately, we were unable to charge the default payment method you registered. Please enter a new payment method and remove the one that does not work.');
INSERT INTO `system_translations` VALUES (275,'titChargingNotPossible', 'Belastung nicht möglich', 'Charging not possible');
INSERT INTO `system_translations` VALUES (276,'txtChargingNotPossible', 'Leider konnten wir keine Ihrer registrierten Zahlungsmethoden belasten. Bitte prüfen Sie die Zahlungsarten.', 'Unfortunately, we could not charge any of your registered payment methods. Please check the payment methods.');
INSERT INTO `system_translations` VALUES (278,'titModule', 'Modul', 'Module');
INSERT INTO `system_translations` VALUES (279,'txtRemove', 'Entfernen', 'Remove');
INSERT INTO `system_translations` VALUES (280,'titWaiting', 'Wartet', 'Waiting');
INSERT INTO `system_translations` VALUES (281,'txtWaitingForPayment', 'Wartet auf Bezahlung', 'Waiting for payment');
INSERT INTO `system_translations` VALUES (282,'txtRenewModuleOn', 'Ihr Modul wird verlängert am', 'Your module will be renewed on');
INSERT INTO `system_translations` VALUES (283,'txtAfterwards', 'Danach', 'Afterwards');
INSERT INTO `system_translations` VALUES (284,'txtOr', 'oder', 'or');
INSERT INTO `system_translations` VALUES (285,'btnDepPayMethod', 'Mit hinterlegter Zahlungsart bezahlen', 'Pay with deposited payment method');
INSERT INTO `system_translations` VALUES (286,'btnOtherPayMethod', 'Andere Zahlungsart wählen', 'Choose other payment method');
INSERT INTO `system_translations` VALUES (287,'msgInvoicePaid', 'Die Rechnung wurde erfolgreich bezahlt. Vielen Dank!', 'The invoice has been paid successfully. Thank you very much!');
INSERT INTO `system_translations` VALUES (288,'titInvoiceReady', 'Ihre Rechnung/Quittung steht zum Download bereit', 'Your invoice/receipt is ready to download');
INSERT INTO `system_translations` VALUES (289,'txtDownloadInvoice', 'Mit dem folgendem Button können Sie Ihre Rechnung/Quittung einsehen und downloaden:', 'With the following button you can view and download your invoice/receipt:');
INSERT INTO `system_translations` VALUES (290,'btnDownloadInvoice', 'Rechnung downloaden', 'Download invoice');
INSERT INTO `system_translations` VALUES (291,'txtPleasePayInvoice', 'Vielen Dank für Ihre Bestellung. Gerne schalten wir Ihr Produkt nach Zahlung der Rechnung frei. Klicken Sie auf den Button, um direkt zur Rechnung zu gelangen (Login benötigt):', 'Thank you for your order. We will be happy to activate your product after payment of the invoice. Click on the button to go directly to the invoice (login required):');
INSERT INTO `system_translations` VALUES (292,'titCompanyUser', 'Firma und Benutzer', 'Company and user');
INSERT INTO `system_translations` VALUES (293,'titDeleteAccount', 'Konto löschen', 'Delete account');
INSERT INTO `system_translations` VALUES (294,'txtDeleteAccount', 'Bitte bedenken Sie, dass beim Löschen des Kontos Ihre Daten per sofort gelöscht werden. Allfälliges Guthaben wird NICHT erstattet! Sind Sie sicher, dass Sie Ihren Account unwiederruflich löschen möchten? Wenn ja, geben Sie bitte Ihre Login-Daten ein und klicken Sie auf "Definitiv löschen".', 'Please note that when you delete your account, your data will be deleted immediately. Any credit balance will NOT be refunded! Are you sure you want to delete your account irrevocably? If so, please enter your login data and click on "Delete definitely".');
INSERT INTO `system_translations` VALUES (295,'btnDeleteDefinitely', 'Definitiv löschen', 'Delete definitely');
INSERT INTO `system_translations` VALUES (296,'btnTestNow', 'Jetzt testen', 'Test now');
INSERT INTO `system_translations` VALUES (297,'txtEmailUpdated', 'Die E-Mail wurde aktualisiert!', 'The e-mail has been updated!');
INSERT INTO `system_translations` VALUES (298,'txtNotificationStatus', 'Status(gelesen)', 'Status(read)');
INSERT INTO `system_translations` VALUES (299,'txtNotificationTitle', 'Benachrichtigungs Titel', 'Notification title');
INSERT INTO `system_translations` VALUES (300,'txtNotificationCreated', 'erstellt am', 'created');
INSERT INTO `system_translations` VALUES (301,'titNotifications', 'Benachrichtigungen', 'Notifications');
INSERT INTO `system_translations` VALUES (302,'txtShowAllNotifications', 'Alle Benachrichtigungen Anzeigen', 'Show all notifications');
INSERT INTO `system_translations` VALUES (303,'txtNotificationDelete', 'Wollen Sie diese Benachrichtigung löschen?', 'Do you want to delete this notification?');
INSERT INTO `system_translations` VALUES (304,'titDeleteNotification', 'Benachrichtigung löschen', 'Delete notification');
INSERT INTO `system_translations` VALUES (305,'txtMultipleNotificationDelete', 'Wollen Sie die ausgewählten Benachrichtigungen löschen?', 'Do you want to delete the selected notifications?');
INSERT INTO `system_translations` VALUES (306,'titMultipleNotificationDelete', 'Benachrichtigungen löschen', 'Delete notifications');
INSERT INTO `system_translations` VALUES (307,'alertNotificationDeleted', 'Die Benachrichtigung wurde gelöscht.', 'The notification have been deleted.');
INSERT INTO `system_translations` VALUES (308,'alertMultipleNotificationDeleted', 'Die Benachrichtigungen wurden gelöscht.', 'The notifications have been deleted.');
INSERT INTO `system_translations` VALUES (309,'txtTechInform', 'Es tut uns leid, aber auf unserem Server ist ein interner Fehler aufgetreten. Der Techniker wurde informiert...', 'We are sorry, but our server encountered an internal error. The technician got informed...');
INSERT INTO `system_translations` VALUES (310,'txtTakeBack', 'Bring mich zurück', 'Take me back');
INSERT INTO `system_translations` VALUES (311,'titCycle', 'Zyklus', 'Cycle');
INSERT INTO `system_translations` VALUES (312,'titPlan', 'Plan', 'Plan');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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
  PRIMARY KEY (`intUserID`) USING BTREE,
  UNIQUE INDEX `_intUserID`(`intUserID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_user_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

DROP TABLE IF EXISTS `widget_ratio`;
CREATE TABLE `widget_ratio`  (
  `intRatioID` int(11) NOT NULL AUTO_INCREMENT,
  `intSizeRatio` int(3) NOT NULL,
  `strDescription` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`intRatioID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

INSERT INTO `widget_ratio` VALUES (1, 12, 'Full width (1/1)');
INSERT INTO `widget_ratio` VALUES (2, 9, 'Three quarter width (3/4)');
INSERT INTO `widget_ratio` VALUES (3, 6, 'Half width (1/2)');
INSERT INTO `widget_ratio` VALUES (4, 4, 'Third width (1/3)');
INSERT INTO `widget_ratio` VALUES (5, 3, 'Quarter width (1/4)');

DROP TABLE IF EXISTS `widgets`;
CREATE TABLE `widgets`  (
  `intWidgetID` int(11) NOT NULL AUTO_INCREMENT,
  `strWidgetName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strFilePath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 1,
  `intRatioID` int(2) NULL DEFAULT 1,
  `blnPermDisplay` tinyint(1) NULL DEFAULT 1,
  PRIMARY KEY (`intWidgetID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

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

DROP TABLE IF EXISTS `widgets_plans`;
CREATE TABLE `widgets_plans`  (
  `intWidgetPlanID` int(11) NOT NULL AUTO_INCREMENT,
  `intWidgetID` int(11) NOT NULL,
  `intPlanID` int(11) NOT NULL,
  CONSTRAINT `frn_wp_widgets` FOREIGN KEY (`intWidgetID`) REFERENCES `widgets` (`intWidgetID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_wp_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  PRIMARY KEY (`intWidgetPlanID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `widgets_modules`;
CREATE TABLE `widgets_modules`  (
  `intWidgetModuleID` int(11) NOT NULL AUTO_INCREMENT,
  `intWidgetID` int(11) NOT NULL,
  `intModuleID` int(11) NOT NULL,
  CONSTRAINT `frn_wm_widgets` FOREIGN KEY (`intWidgetID`) REFERENCES `widgets` (`intWidgetID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_wm_modules` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  PRIMARY KEY (`intWidgetModuleID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


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
