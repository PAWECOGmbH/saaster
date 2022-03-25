
/* Create database for saaster.io */

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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
  `strTimezone` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strFlagSVG` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intPrio` int(4) NOT NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 0,
  `blnDefault` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`intCountryID`) USING BTREE,
  UNIQUE INDEX `_intCountryID`(`intCountryID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Records of countries
-- ----------------------------
INSERT INTO `countries` VALUES (1, 'Montenegro', 1, 'sr_ME', 'ME', 'MNE', 'EUR', 'Europe', 'Southeast Europe', '', 'https://flagcdn.com/me.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (2, 'Tokelau', 1, '', 'TK', 'TKL', 'NZD', 'Oceania', 'Polynesia', 'UTC+13:00', 'https://flagcdn.com/tk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (3, 'Cuba', 1, '', 'CU', 'CUB', 'CUC', 'Americas', 'Caribbean', 'UTC-05:00', 'https://flagcdn.com/cu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (4, 'Guadeloupe', 1, '', 'GP', 'GLP', 'EUR', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/gp.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (5, 'Greece', 1, 'el_GR', 'GR', 'GRC', 'EUR', 'Europe', 'Southern Europe', '', 'https://flagcdn.com/gr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (6, 'Martinique', 1, '', 'MQ', 'MTQ', 'EUR', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/mq.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (7, 'Venezuela', 1, 'es_VE', 'VE', 'VEN', 'VES', 'Americas', 'South America', 'UTC-04:00', 'https://flagcdn.com/ve.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (8, 'United States Minor Outlying Islands', 1, 'en_UM', 'UM', 'UMI', 'USD', 'Americas', 'North America', 'UTC-11:00', 'https://flagcdn.com/um.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (9, 'Samoa', 1, '', 'WS', 'WSM', 'WST', 'Oceania', 'Polynesia', 'UTC+13:00', 'https://flagcdn.com/ws.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (10, 'Cambodia', 1, 'km_KH', 'KH', 'KHM', 'KHR', 'Asia', 'South-Eastern Asia', 'UTC+07:00', 'https://flagcdn.com/kh.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (11, 'Hong Kong', 1, 'en_HK', 'HK', 'HKG', 'HKD', 'Asia', 'Eastern Asia', 'UTC+08:00', 'https://flagcdn.com/hk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (12, 'Mauritania', 1, '', 'MR', 'MRT', 'MRU', 'Africa', 'Western Africa', 'UTC', 'https://flagcdn.com/mr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (13, 'Yemen', 1, 'ar_YE', 'YE', 'YEM', 'YER', 'Asia', 'Western Asia', 'UTC+03:00', 'https://flagcdn.com/ye.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (14, 'Djibouti', 1, 'aa_DJ', 'DJ', 'DJI', 'DJF', 'Africa', 'Eastern Africa', 'UTC+03:00', 'https://flagcdn.com/dj.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (15, 'British Virgin Islands', 1, '', 'VG', 'VGB', 'USD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/vg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (16, 'Egypt', 1, 'ar_EG', 'EG', 'EGY', 'EGP', 'Africa', 'Northern Africa', 'UTC+02:00', 'https://flagcdn.com/eg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (17, 'Croatia', 1, 'hr_HR', 'HR', 'HRV', 'HRK', 'Europe', 'Southeast Europe', 'UTC+01:00', 'https://flagcdn.com/hr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (18, 'Liechtenstein', 1, 'de_LI', 'LI', 'LIE', 'CHF', 'Europe', 'Western Europe', 'UTC+01:00', 'https://flagcdn.com/li.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (19, 'Kazakhstan', 1, 'kk_KZ', 'KZ', 'KAZ', 'KZT', 'Asia', 'Central Asia', 'UTC+05:00', 'https://flagcdn.com/kz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (20, 'Denmark', 1, 'da_DK', 'DK', 'DNK', 'DKK', 'Europe', 'Northern Europe', 'UTC-04:00', 'https://flagcdn.com/dk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (21, 'Benin', 1, '', 'BJ', 'BEN', 'XOF', 'Africa', 'Western Africa', 'UTC+01:00', 'https://flagcdn.com/bj.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (22, 'Northern Mariana Islands', 1, 'en_MP', 'MP', 'MNP', 'USD', 'Oceania', 'Micronesia', 'UTC+10:00', 'https://flagcdn.com/mp.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (23, 'Bermuda', 1, '', 'BM', 'BMU', 'BMD', 'Americas', 'North America', 'UTC-04:00', 'https://flagcdn.com/bm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (24, 'Italy', 1, 'it_IT', 'IT', 'ITA', 'EUR', 'Europe', 'Southern Europe', 'UTC+01:00', 'https://flagcdn.com/it.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (25, 'South Georgia', 1, '', 'GS', 'SGS', 'SHP', 'Antarctic', '', 'UTC-02:00', 'https://flagcdn.com/gs.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (26, 'South Africa', 1, 'af_ZA', 'ZA', 'ZAF', 'ZAR', 'Africa', 'Southern Africa', 'UTC+02:00', 'https://flagcdn.com/za.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (27, 'Rwanda', 1, 'rw_RW', 'RW', 'RWA', 'RWF', 'Africa', 'Eastern Africa', 'UTC+02:00', 'https://flagcdn.com/rw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (28, 'Macau', 1, 'zh_MO', 'MO', 'MAC', 'MOP', 'Asia', 'Eastern Asia', 'UTC+08:00', 'https://flagcdn.com/mo.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (29, 'Burundi', 1, '', 'BI', 'BDI', 'BIF', 'Africa', 'Eastern Africa', 'UTC+02:00', 'https://flagcdn.com/bi.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (30, 'French Guiana', 1, '', 'GF', 'GUF', 'EUR', 'Americas', 'South America', 'UTC-03:00', 'https://flagcdn.com/gf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (31, 'Ukraine', 1, 'ru_UA', 'UA', 'UKR', 'UAH', 'Europe', 'Eastern Europe', 'UTC+02:00', 'https://flagcdn.com/ua.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (32, 'Togo', 1, 'ee_TG', 'TG', 'TGO', 'XOF', 'Africa', 'Western Africa', 'UTC', 'https://flagcdn.com/tg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (33, 'Taiwan', 1, 'zh_TW', 'TW', 'TWN', 'TWD', 'Asia', 'Eastern Asia', 'UTC+08:00', 'https://flagcdn.com/tw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (34, 'Antarctica', 1, '', 'AQ', 'ATA', '', 'Antarctic', '', 'UTC-03:00', 'https://flagcdn.com/aq.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (35, 'Cook Islands', 1, '', 'CK', 'COK', 'CKD', 'Oceania', 'Polynesia', 'UTC-10:00', 'https://flagcdn.com/ck.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (36, 'Guinea-Bissau', 1, '', 'GW', 'GNB', 'XOF', 'Africa', 'Western Africa', 'UTC', 'https://flagcdn.com/gw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (37, 'Sint Maarten', 1, '', 'SX', 'SXM', 'ANG', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/sx.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (38, 'Ivory Coast', 1, 'kfo_CI', 'CI', 'CIV', 'XOF', 'Africa', 'Western Africa', 'UTC', 'https://flagcdn.com/ci.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (39, 'Iceland', 1, 'is_IS', 'IS', 'ISL', 'ISK', 'Europe', 'Northern Europe', 'UTC', 'https://flagcdn.com/is.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (40, 'Paraguay', 1, 'es_PY', 'PY', 'PRY', 'PYG', 'Americas', 'South America', 'UTC-04:00', 'https://flagcdn.com/py.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (41, 'Eswatini', 1, 'ss_SZ', 'SZ', 'SWZ', 'SZL', 'Africa', 'Southern Africa', 'UTC+02:00', 'https://flagcdn.com/sz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (42, 'Hungary', 1, 'hu_HU', 'HU', 'HUN', 'HUF', 'Europe', 'Central Europe', 'UTC+01:00', 'https://flagcdn.com/hu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (43, 'Heard Island and McDonald Islands', 1, '', 'HM', 'HMD', '', 'Antarctic', '', 'UTC+05:00', 'https://flagcdn.com/hm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (44, 'Moldova', 1, 'ro_MD', 'MD', 'MDA', 'MDL', 'Europe', 'Eastern Europe', 'UTC+02:00', 'https://flagcdn.com/md.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (45, 'Chile', 1, 'es_CL', 'CL', 'CHL', 'CLP', 'Americas', 'South America', 'UTC-06:00', 'https://flagcdn.com/cl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (46, 'Greenland', 1, 'kl_GL', 'GL', 'GRL', 'DKK', 'Americas', 'North America', 'UTC-04:00', 'https://flagcdn.com/gl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (47, 'Nauru', 1, '', 'NR', 'NRU', 'AUD', 'Oceania', 'Micronesia', 'UTC+12:00', 'https://flagcdn.com/nr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (48, 'Uruguay', 1, 'es_UY', 'UY', 'URY', 'UYU', 'Americas', 'South America', 'UTC-03:00', 'https://flagcdn.com/uy.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (49, 'Ecuador', 1, 'es_EC', 'EC', 'ECU', 'USD', 'Americas', 'South America', 'UTC-06:00', 'https://flagcdn.com/ec.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (50, 'Sri Lanka', 1, 'si_LK', 'LK', 'LKA', 'LKR', 'Asia', 'Southern Asia', 'UTC+05:30', 'https://flagcdn.com/lk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (51, 'Saint Pierre and Miquelon', 1, '', 'PM', 'SPM', 'EUR', 'Americas', 'North America', 'UTC-03:00', 'https://flagcdn.com/pm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (52, 'Guatemala', 1, 'es_GT', 'GT', 'GTM', 'GTQ', 'Americas', 'Central America', 'UTC-06:00', 'https://flagcdn.com/gt.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (53, 'Ghana', 1, 'ak_GH', 'GH', 'GHA', 'GHS', 'Africa', 'Western Africa', 'UTC', 'https://flagcdn.com/gh.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (54, 'Israel', 1, 'he_IL', 'IL', 'ISR', 'ILS', 'Asia', 'Western Asia', 'UTC+02:00', 'https://flagcdn.com/il.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (55, 'Mozambique', 1, '', 'MZ', 'MOZ', 'MZN', 'Africa', 'Eastern Africa', 'UTC+02:00', 'https://flagcdn.com/mz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (56, 'Bhutan', 1, 'dz_BT', 'BT', 'BTN', 'BTN', 'Asia', 'Southern Asia', 'UTC+06:00', 'https://flagcdn.com/bt.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (57, 'Cayman Islands', 1, '', 'KY', 'CYM', 'KYD', 'Americas', 'Caribbean', 'UTC-05:00', 'https://flagcdn.com/ky.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (58, 'North Korea', 1, '', 'KP', 'PRK', 'KPW', 'Asia', 'Eastern Asia', 'UTC+09:00', 'https://flagcdn.com/kp.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (59, 'Bahrain', 1, 'ar_BH', 'BH', 'BHR', 'BHD', 'Asia', 'Western Asia', 'UTC+03:00', 'https://flagcdn.com/bh.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (60, 'Faroe Islands', 1, 'fo_FO', 'FO', 'FRO', 'DKK', 'Europe', 'Northern Europe', 'UTC+00:00', 'https://flagcdn.com/fo.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (61, 'Aruba', 1, '', 'AW', 'ABW', 'AWG', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/aw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (62, 'Iraq', 1, 'ar_IQ', 'IQ', 'IRQ', 'IQD', 'Asia', 'Western Asia', 'UTC+03:00', 'https://flagcdn.com/iq.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (63, 'British Indian Ocean Territory', 1, '', 'IO', 'IOT', 'USD', 'Africa', 'Eastern Africa', 'UTC+06:00', 'https://flagcdn.com/io.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (64, 'Morocco', 1, 'ar_MA', 'MA', 'MAR', 'MAD', 'Africa', 'Northern Africa', 'UTC', 'https://flagcdn.com/ma.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (65, 'North Macedonia', 1, 'mk_MK', 'MK', 'MKD', 'MKD', 'Europe', 'Southeast Europe', 'UTC+01:00', 'https://flagcdn.com/mk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (66, 'Poland', 1, 'pl_PL', 'PL', 'POL', 'PLN', 'Europe', 'Central Europe', 'UTC+01:00', 'https://flagcdn.com/pl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (67, 'Solomon Islands', 1, '', 'SB', 'SLB', 'SBD', 'Oceania', 'Melanesia', 'UTC+11:00', 'https://flagcdn.com/sb.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (68, 'Brazil', 1, 'pt_BR', 'BR', 'BRA', 'BRL', 'Americas', 'South America', 'UTC-05:00', 'https://flagcdn.com/br.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (69, 'Slovenia', 1, 'sl_SI', 'SI', 'SVN', 'EUR', 'Europe', 'Central Europe', 'UTC+01:00', 'https://flagcdn.com/si.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (70, 'Oman', 1, 'ar_OM', 'OM', 'OMN', 'OMR', 'Asia', 'Western Asia', 'UTC+04:00', 'https://flagcdn.com/om.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (71, 'Thailand', 1, 'th_TH', 'TH', 'THA', 'THB', 'Asia', 'South-Eastern Asia', 'UTC+07:00', 'https://flagcdn.com/th.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (72, 'Central African Republic', 1, '', 'CF', 'CAF', 'XAF', 'Africa', 'Middle Africa', 'UTC+01:00', 'https://flagcdn.com/cf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (73, 'El Salvador', 1, 'es_SV', 'SV', 'SLV', 'USD', 'Americas', 'Central America', 'UTC-06:00', 'https://flagcdn.com/sv.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (74, 'Armenia', 1, 'hy_AM', 'AM', 'ARM', 'AMD', 'Asia', 'Western Asia', 'UTC+04:00', 'https://flagcdn.com/am.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (75, 'Honduras', 1, 'es_HN', 'HN', 'HND', 'HNL', 'Americas', 'Central America', 'UTC-06:00', 'https://flagcdn.com/hn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (76, 'Zambia', 1, '', 'ZM', 'ZMB', 'ZMW', 'Africa', 'Eastern Africa', 'UTC+02:00', 'https://flagcdn.com/zm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (77, 'Svalbard and Jan Mayen', 1, '', 'SJ', 'SJM', 'NOK', 'Europe', 'Northern Europe', 'UTC+01:00', 'https://flagcdn.com/sj.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (78, 'Luxembourg', 1, 'de_LU', 'LU', 'LUX', 'EUR', 'Europe', 'Western Europe', 'UTC+01:00', 'https://flagcdn.com/lu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (79, 'Colombia', 1, 'es_CO', 'CO', 'COL', 'COP', 'Americas', 'South America', 'UTC-05:00', 'https://flagcdn.com/co.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (80, 'Barbados', 1, '', 'BB', 'BRB', 'BBD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/bb.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (81, 'Libya', 1, 'ar_LY', 'LY', 'LBY', 'LYD', 'Africa', 'Northern Africa', 'UTC+01:00', 'https://flagcdn.com/ly.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (82, 'Serbia', 1, 'sr_RS', 'RS', 'SRB', 'RSD', 'Europe', 'Southeast Europe', 'UTC+01:00', 'https://flagcdn.com/rs.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (83, 'Monaco', 1, 'fr_MC', 'MC', 'MCO', 'EUR', 'Europe', 'Western Europe', 'UTC+01:00', 'https://flagcdn.com/mc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (84, 'Sweden', 1, 'sv_SE', 'SE', 'SWE', 'SEK', 'Europe', 'Northern Europe', 'UTC+01:00', 'https://flagcdn.com/se.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (85, 'Niger', 1, 'ha_NE', 'NE', 'NER', 'XOF', 'Africa', 'Western Africa', 'UTC+01:00', 'https://flagcdn.com/ne.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (86, 'Angola', 1, '', 'AO', 'AGO', 'AOA', 'Africa', 'Middle Africa', 'UTC+01:00', 'https://flagcdn.com/ao.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (87, 'Panama', 1, 'es_PA', 'PA', 'PAN', 'PAB', 'Americas', 'Central America', 'UTC-05:00', 'https://flagcdn.com/pa.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (88, 'Mauritius', 1, '', 'MU', 'MUS', 'MUR', 'Africa', 'Eastern Africa', 'UTC+04:00', 'https://flagcdn.com/mu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (89, 'Tanzania', 1, 'sw_TZ', 'TZ', 'TZA', 'TZS', 'Africa', 'Eastern Africa', 'UTC+03:00', 'https://flagcdn.com/tz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (90, 'Mali', 1, '', 'ML', 'MLI', 'XOF', 'Africa', 'Western Africa', 'UTC', 'https://flagcdn.com/ml.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (91, 'Cameroon', 1, '', 'CM', 'CMR', 'XAF', 'Africa', 'Middle Africa', 'UTC+01:00', 'https://flagcdn.com/cm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (92, 'Georgia', 1, 'ka_GE', 'GE', 'GEO', 'GEL', 'Asia', 'Western Asia', 'UTC-04:00', 'https://flagcdn.com/ge.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (93, 'Gambia', 1, '', 'GM', 'GMB', 'GMD', 'Africa', 'Western Africa', 'UTC+00:00', 'https://flagcdn.com/gm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (94, 'Malta', 1, 'en_MT', 'MT', 'MLT', 'EUR', 'Europe', 'Southern Europe', 'UTC+01:00', 'https://flagcdn.com/mt.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (95, 'American Samoa', 1, 'en_AS', 'AS', 'ASM', 'USD', 'Oceania', 'Polynesia', 'UTC-11:00', 'https://flagcdn.com/as.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (96, 'Zimbabwe', 1, 'en_ZW', 'ZW', 'ZWE', 'ZWL', 'Africa', 'Southern Africa', 'UTC+02:00', 'https://flagcdn.com/zw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (97, 'Belize', 1, 'en_BZ', 'BZ', 'BLZ', 'BZD', 'Americas', 'Central America', 'UTC-06:00', 'https://flagcdn.com/bz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (98, 'Saint Kitts and Nevis', 1, '', 'KN', 'KNA', 'XCD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/kn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (99, 'Vatican City', 1, '', 'VA', 'VAT', 'EUR', 'Europe', 'Southern Europe', 'UTC+01:00', 'https://flagcdn.com/va.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (100, 'Micronesia', 1, '', 'FM', 'FSM', 'USD', 'Oceania', 'Micronesia', 'UTC+10:00', 'https://flagcdn.com/fm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (101, 'Chad', 1, '', 'TD', 'TCD', 'XAF', 'Africa', 'Middle Africa', 'UTC+01:00', 'https://flagcdn.com/td.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (102, 'Belarus', 1, 'be_BY', 'BY', 'BLR', 'BYN', 'Europe', 'Eastern Europe', 'UTC+03:00', 'https://flagcdn.com/by.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (103, 'Canada', 1, 'en_CA', 'CA', 'CAN', 'CAD', 'Americas', 'North America', 'UTC-08:00', 'https://flagcdn.com/ca.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (104, 'Argentina', 1, 'es_AR', 'AR', 'ARG', 'ARS', 'Americas', 'South America', 'UTC-03:00', 'https://flagcdn.com/ar.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (105, 'Suriname', 1, '', 'SR', 'SUR', 'SRD', 'Americas', 'South America', 'UTC-03:00', 'https://flagcdn.com/sr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (106, 'Australia', 1, 'en_AU', 'AU', 'AUS', 'AUD', 'Oceania', 'Australia and New Zealand', 'UTC+05:00', 'https://flagcdn.com/au.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (107, 'Guinea', 1, 'kpe_GN', 'GN', 'GIN', 'GNF', 'Africa', 'Western Africa', 'UTC', 'https://flagcdn.com/gn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (108, 'South Sudan', 1, '', 'SS', 'SSD', 'SSP', 'Africa', 'Middle Africa', 'UTC+03:00', 'https://flagcdn.com/ss.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (109, 'Namibia', 1, 'af_NA', 'NA', 'NAM', 'NAD', 'Africa', 'Southern Africa', 'UTC+01:00', 'https://flagcdn.com/na.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (110, 'Qatar', 1, 'ar_QA', 'QA', 'QAT', 'QAR', 'Asia', 'Western Asia', 'UTC+03:00', 'https://flagcdn.com/qa.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (111, 'Myanmar', 1, 'my_MM', 'MM', 'MMR', 'MMK', 'Asia', 'South-Eastern Asia', 'UTC+06:30', 'https://flagcdn.com/mm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (112, 'Falkland Islands', 1, '', 'FK', 'FLK', 'FKP', 'Americas', 'South America', 'UTC-04:00', 'https://flagcdn.com/fk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (113, 'Ireland', 1, 'en_IE', 'IE', 'IRL', 'EUR', 'Europe', 'Northern Europe', 'UTC', 'https://flagcdn.com/ie.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (114, 'São Tomé and Príncipe', 1, '', 'ST', 'STP', 'STN', 'Africa', 'Middle Africa', 'UTC', 'https://flagcdn.com/st.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (115, 'Bouvet Island', 1, '', 'BV', 'BVT', '', 'Antarctic', '', 'UTC+01:00', 'https://flagcdn.com/bv.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (116, 'Lithuania', 1, 'lt_LT', 'LT', 'LTU', 'EUR', 'Europe', 'Northern Europe', 'UTC+02:00', 'https://flagcdn.com/lt.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (117, 'DR Congo', 1, 'ln_CD', 'CD', 'COD', 'CDF', 'Africa', 'Middle Africa', 'UTC+01:00', 'https://flagcdn.com/cd.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (118, 'Philippines', 1, 'en_PH', 'PH', 'PHL', 'PHP', 'Asia', 'South-Eastern Asia', 'UTC+08:00', 'https://flagcdn.com/ph.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (119, 'Brunei', 1, 'ms_BN', 'BN', 'BRN', 'BND', 'Asia', 'South-Eastern Asia', 'UTC+08:00', 'https://flagcdn.com/bn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (120, 'Sierra Leone', 1, '', 'SL', 'SLE', 'SLL', 'Africa', 'Western Africa', 'UTC', 'https://flagcdn.com/sl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (121, 'Mongolia', 1, 'mn_MN', 'MN', 'MNG', 'MNT', 'Asia', 'Eastern Asia', 'UTC+07:00', 'https://flagcdn.com/mn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (122, 'Western Sahara', 1, '', 'EH', 'ESH', 'DZD', 'Africa', 'Northern Africa', 'UTC+00:00', 'https://flagcdn.com/eh.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (123, 'Pitcairn Islands', 1, '', 'PN', 'PCN', 'NZD', 'Oceania', 'Polynesia', 'UTC-08:00', 'https://flagcdn.com/pn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (124, 'Sudan', 1, 'ar_SD', 'SD', 'SDN', 'SDG', 'Africa', 'Northern Africa', 'UTC+03:00', 'https://flagcdn.com/sd.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (125, 'Timor-Leste', 1, '', 'TL', 'TLS', 'USD', 'Asia', 'South-Eastern Asia', 'UTC+09:00', 'https://flagcdn.com/tl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (126, 'Anguilla', 1, '', 'AI', 'AIA', 'XCD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/ai.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (127, 'Curaçao', 1, '', 'CW', 'CUW', 'ANG', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/cw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (128, 'Republic of the Congo', 1, 'ln_CG', 'CG', 'COG', 'XAF', 'Africa', 'Middle Africa', 'UTC+01:00', 'https://flagcdn.com/cg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (129, 'Finland', 1, 'fi_FI', 'FI', 'FIN', 'EUR', 'Europe', 'Northern Europe', 'UTC+02:00', 'https://flagcdn.com/fi.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (130, 'Austria', 1, 'de_AT', 'AT', 'AUT', 'EUR', 'Europe', 'Central Europe', 'UTC+01:00', 'https://flagcdn.com/at.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (131, 'Ethiopia', 1, 'aa_ET', 'ET', 'ETH', 'ETB', 'Africa', 'Eastern Africa', 'UTC+03:00', 'https://flagcdn.com/et.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (132, 'Saint Martin', 1, '', 'MF', 'MAF', 'EUR', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/mf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (133, 'Saint Vincent and the Grenadines', 1, '', 'VC', 'VCT', 'XCD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/vc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (134, 'Bosnia and Herzegovina', 1, 'bs_BA', 'BA', 'BIH', 'BAM', 'Europe', 'Southeast Europe', 'UTC+01:00', 'https://flagcdn.com/ba.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (135, 'Comoros', 1, '', 'KM', 'COM', 'KMF', 'Africa', 'Eastern Africa', 'UTC+03:00', 'https://flagcdn.com/km.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (136, 'Caribbean Netherlands', 1, '', 'BQ', 'BES', 'USD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/bq.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (137, 'Norway', 1, 'nb_NO', 'NO', 'NOR', 'NOK', 'Europe', 'Northern Europe', 'UTC+01:00', 'https://flagcdn.com/no.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (138, 'Kuwait', 1, 'ar_KW', 'KW', 'KWT', 'KWD', 'Asia', 'Western Asia', 'UTC+03:00', 'https://flagcdn.com/kw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (139, 'Burkina Faso', 1, '', 'BF', 'BFA', 'XOF', 'Africa', 'Western Africa', 'UTC', 'https://flagcdn.com/bf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (140, 'Wallis and Futuna', 1, '', 'WF', 'WLF', 'XPF', 'Oceania', 'Polynesia', 'UTC+12:00', 'https://flagcdn.com/wf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (141, 'Bangladesh', 1, 'bn_BD', 'BD', 'BGD', 'BDT', 'Asia', 'Southern Asia', 'UTC+06:00', 'https://flagcdn.com/bd.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (142, 'Dominica', 1, '', 'DM', 'DMA', 'XCD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/dm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (143, 'Jamaica', 1, 'en_JM', 'JM', 'JAM', 'JMD', 'Americas', 'Caribbean', 'UTC-05:00', 'https://flagcdn.com/jm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (144, 'Andorra', 1, '', 'AD', 'AND', 'EUR', 'Europe', 'Southern Europe', 'UTC+01:00', 'https://flagcdn.com/ad.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (145, 'Gibraltar', 1, '', 'GI', 'GIB', 'GIP', 'Europe', 'Southern Europe', 'UTC+01:00', 'https://flagcdn.com/gi.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (146, 'Malaysia', 1, 'ms_MY', 'MY', 'MYS', 'MYR', 'Asia', 'South-Eastern Asia', 'UTC+08:00', 'https://flagcdn.com/my.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (147, 'United Kingdom', 1, 'en_GB', 'GB', 'GBR', 'GBP', 'Europe', 'Northern Europe', 'UTC-08:00', 'https://flagcdn.com/gb.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (148, 'Madagascar', 1, '', 'MG', 'MDG', 'MGA', 'Africa', 'Eastern Africa', 'UTC+03:00', 'https://flagcdn.com/mg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (149, 'Switzerland', 1, 'de_CH', 'CH', 'CHE', 'CHF', 'Europe', 'Western Europe', 'UTC+01:00', 'https://flagcdn.com/ch.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (150, 'Tuvalu', 1, '', 'TV', 'TUV', 'AUD', 'Oceania', 'Polynesia', 'UTC+12:00', 'https://flagcdn.com/tv.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (151, 'Algeria', 1, 'ar_DZ', 'DZ', 'DZA', 'DZD', 'Africa', 'Northern Africa', 'UTC+01:00', 'https://flagcdn.com/dz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (152, 'Russia', 1, 'ru_RU', 'RU', 'RUS', 'RUB', 'Europe', 'Eastern Europe', 'UTC+03:00', 'https://flagcdn.com/ru.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (153, 'Vietnam', 1, 'vi_VN', 'VN', 'VNM', 'VND', 'Asia', 'South-Eastern Asia', 'UTC+07:00', 'https://flagcdn.com/vn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (154, 'Cocos (Keeling) Islands', 1, '', 'CC', 'CCK', 'AUD', 'Oceania', 'Australia and New Zealand', 'UTC+06:30', 'https://flagcdn.com/cc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (155, 'Nepal', 1, 'ne_NP', 'NP', 'NPL', 'NPR', 'Asia', 'Southern Asia', 'UTC+05:45', 'https://flagcdn.com/np.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (156, 'Netherlands', 1, 'nl_NL', 'NL', 'NLD', 'EUR', 'Europe', 'Western Europe', 'UTC-04:00', 'https://flagcdn.com/nl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (157, 'Kiribati', 1, '', 'KI', 'KIR', 'AUD', 'Oceania', 'Micronesia', 'UTC+12:00', 'https://flagcdn.com/ki.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (158, 'Liberia', 1, 'kpe_LR', 'LR', 'LBR', 'LRD', 'Africa', 'Western Africa', 'UTC', 'https://flagcdn.com/lr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (159, 'Somalia', 1, 'so_SO', 'SO', 'SOM', 'SOS', 'Africa', 'Eastern Africa', 'UTC+03:00', 'https://flagcdn.com/so.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (160, 'Romania', 1, 'ro_RO', 'RO', 'ROU', 'RON', 'Europe', 'Southeast Europe', 'UTC+02:00', 'https://flagcdn.com/ro.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (161, 'Marshall Islands', 1, 'en_MH', 'MH', 'MHL', 'USD', 'Oceania', 'Micronesia', 'UTC+12:00', 'https://flagcdn.com/mh.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (162, 'Spain', 1, 'ca_ES', 'ES', 'ESP', 'EUR', 'Europe', 'Southern Europe', 'UTC', 'https://flagcdn.com/es.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (163, 'United States', 1, 'en_US', 'US', 'USA', 'USD', 'Americas', 'North America', 'UTC-12:00', 'https://flagcdn.com/us.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (164, 'Réunion', 1, '', 'RE', 'REU', 'EUR', 'Africa', 'Eastern Africa', 'UTC+04:00', 'https://flagcdn.com/re.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (165, 'Singapore', 1, 'en_SG', 'SG', 'SGP', 'SGD', 'Asia', 'South-Eastern Asia', 'UTC+08:00', 'https://flagcdn.com/sg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (166, 'Tunisia', 1, 'ar_TN', 'TN', 'TUN', 'TND', 'Africa', 'Northern Africa', 'UTC+01:00', 'https://flagcdn.com/tn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (167, 'Azerbaijan', 1, 'az_AZ', 'AZ', 'AZE', 'AZN', 'Asia', 'Western Asia', 'UTC+04:00', 'https://flagcdn.com/az.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (168, 'Papua New Guinea', 1, '', 'PG', 'PNG', 'PGK', 'Oceania', 'Melanesia', 'UTC+10:00', 'https://flagcdn.com/pg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (169, 'Lesotho', 1, 'st_LS', 'LS', 'LSO', 'LSL', 'Africa', 'Southern Africa', 'UTC+02:00', 'https://flagcdn.com/ls.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (170, 'Bahamas', 1, '', 'BS', 'BHS', 'BSD', 'Americas', 'Caribbean', 'UTC-05:00', 'https://flagcdn.com/bs.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (171, 'China', 1, 'bo_CN', 'CN', 'CHN', 'CNY', 'Asia', 'Eastern Asia', 'UTC+08:00', 'https://flagcdn.com/cn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (172, 'Mayotte', 1, '', 'YT', 'MYT', 'EUR', 'Africa', 'Eastern Africa', 'UTC+03:00', 'https://flagcdn.com/yt.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (173, 'Senegal', 1, 'fr_SN', 'SN', 'SEN', 'XOF', 'Africa', 'Western Africa', 'UTC', 'https://flagcdn.com/sn.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (174, 'Cyprus', 1, 'el_CY', 'CY', 'CYP', 'EUR', 'Europe', 'Southern Europe', 'UTC+02:00', 'https://flagcdn.com/cy.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (175, 'United Arab Emirates', 1, 'ar_AE', 'AE', 'ARE', 'AED', 'Asia', 'Western Asia', 'UTC+04:00', 'https://flagcdn.com/ae.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (176, 'Turkmenistan', 1, '', 'TM', 'TKM', 'TMT', 'Asia', 'Central Asia', 'UTC+05:00', 'https://flagcdn.com/tm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (177, 'Laos', 1, 'lo_LA', 'LA', 'LAO', 'LAK', 'Asia', 'South-Eastern Asia', 'UTC+07:00', 'https://flagcdn.com/la.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (178, 'Belgium', 1, 'de_BE', 'BE', 'BEL', 'EUR', 'Europe', 'Western Europe', 'UTC+01:00', 'https://flagcdn.com/be.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (179, 'Jordan', 1, 'ar_JO', 'JO', 'JOR', 'JOD', 'Asia', 'Western Asia', 'UTC+03:00', 'https://flagcdn.com/jo.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (180, 'Palestine', 1, '', 'PS', 'PSE', 'EGP', 'Asia', 'Western Asia', 'UTC+02:00', 'https://flagcdn.com/ps.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (181, 'Seychelles', 1, '', 'SC', 'SYC', 'SCR', 'Africa', 'Eastern Africa', 'UTC+04:00', 'https://flagcdn.com/sc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (182, 'Uzbekistan', 1, 'uz_UZ', 'UZ', 'UZB', 'UZS', 'Asia', 'Central Asia', 'UTC+05:00', 'https://flagcdn.com/uz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (183, 'New Caledonia', 1, '', 'NC', 'NCL', 'XPF', 'Oceania', 'Melanesia', 'UTC+11:00', 'https://flagcdn.com/nc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (184, 'Åland Islands', 1, '', 'AX', 'ALA', 'EUR', 'Europe', 'Northern Europe', 'UTC+02:00', 'https://flagcdn.com/ax.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (185, 'Nicaragua', 1, 'es_NI', 'NI', 'NIC', 'NIO', 'Americas', 'Central America', 'UTC-06:00', 'https://flagcdn.com/ni.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (186, 'Guam', 1, 'en_GU', 'GU', 'GUM', 'USD', 'Oceania', 'Micronesia', 'UTC+10:00', 'https://flagcdn.com/gu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (187, 'Kenya', 1, 'kam_KE', 'KE', 'KEN', 'KES', 'Africa', 'Eastern Africa', 'UTC+03:00', 'https://flagcdn.com/ke.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (188, 'French Polynesia', 1, '', 'PF', 'PYF', 'XPF', 'Oceania', 'Polynesia', 'UTC-10:00', 'https://flagcdn.com/pf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (189, 'Jersey', 1, '', 'JE', 'JEY', 'GBP', 'Europe', 'Northern Europe', 'UTC+01:00', 'https://flagcdn.com/je.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (190, 'Czechia', 1, 'cs_CZ', 'CZ', 'CZE', 'CZK', 'Europe', 'Central Europe', 'UTC+01:00', 'https://flagcdn.com/cz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (191, 'Uganda', 1, '', 'UG', 'UGA', 'UGX', 'Africa', 'Eastern Africa', 'UTC+03:00', 'https://flagcdn.com/ug.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (192, 'New Zealand', 1, 'en_NZ', 'NZ', 'NZL', 'NZD', 'Oceania', 'Australia and New Zealand', 'UTC-11:00', 'https://flagcdn.com/nz.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (193, 'Montserrat', 1, '', 'MS', 'MSR', 'XCD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/ms.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (194, 'Saint Barthélemy', 1, '', 'BL', 'BLM', 'EUR', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/bl.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (195, 'Costa Rica', 1, 'es_CR', 'CR', 'CRI', 'CRC', 'Americas', 'Central America', 'UTC-06:00', 'https://flagcdn.com/cr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (196, 'Mexico', 1, 'es_MX', 'MX', 'MEX', 'MXN', 'Americas', 'North America', 'UTC-08:00', 'https://flagcdn.com/mx.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (197, 'Eritrea', 1, 'aa_ER', 'ER', 'ERI', 'ERN', 'Africa', 'Eastern Africa', 'UTC+03:00', 'https://flagcdn.com/er.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (198, 'Grenada', 1, '', 'GD', 'GRD', 'XCD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/gd.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (199, 'Antigua and Barbuda', 1, '', 'AG', 'ATG', 'XCD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/ag.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (200, 'Japan', 1, 'ja_JP', 'JP', 'JPN', 'JPY', 'Asia', 'Eastern Asia', 'UTC+09:00', 'https://flagcdn.com/jp.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (201, 'Slovakia', 1, 'sk_SK', 'SK', 'SVK', 'EUR', 'Europe', 'Central Europe', 'UTC+01:00', 'https://flagcdn.com/sk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (202, 'United States Virgin Islands', 1, 'en_VI', 'VI', 'VIR', 'USD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/vi.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (203, 'Kosovo', 1, '', 'XK', 'UNK', 'EUR', 'Europe', 'Southeast Europe', 'UTC+01:00', 'https://flagcdn.com/xk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (204, 'Vanuatu', 1, '', 'VU', 'VUT', 'VUV', 'Oceania', 'Melanesia', 'UTC+11:00', 'https://flagcdn.com/vu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (205, 'Palau', 1, '', 'PW', 'PLW', 'USD', 'Oceania', 'Micronesia', 'UTC+09:00', 'https://flagcdn.com/pw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (206, 'Botswana', 1, 'en_BW', 'BW', 'BWA', 'BWP', 'Africa', 'Southern Africa', 'UTC+02:00', 'https://flagcdn.com/bw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (207, 'Tonga', 1, 'to_TO', 'TO', 'TON', 'TOP', 'Oceania', 'Polynesia', 'UTC+13:00', 'https://flagcdn.com/to.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (208, 'Fiji', 1, '', 'FJ', 'FJI', 'FJD', 'Oceania', 'Melanesia', 'UTC+12:00', 'https://flagcdn.com/fj.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (209, 'France', 1, 'fr_FR', 'FR', 'FRA', 'EUR', 'Europe', 'Western Europe', 'UTC-10:00', 'https://flagcdn.com/fr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (210, 'Albania', 1, 'sq_AL', 'AL', 'ALB', 'ALL', 'Europe', 'Southeast Europe', 'UTC+01:00', 'https://flagcdn.com/al.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (211, 'Portugal', 1, 'pt_PT', 'PT', 'PRT', 'EUR', 'Europe', 'Southern Europe', 'UTC-01:00', 'https://flagcdn.com/pt.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (212, 'Niue', 1, '', 'NU', 'NIU', 'NZD', 'Oceania', 'Polynesia', 'UTC-11:00', 'https://flagcdn.com/nu.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (213, 'Peru', 1, 'es_PE', 'PE', 'PER', 'PEN', 'Americas', 'South America', 'UTC-05:00', 'https://flagcdn.com/pe.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (214, 'Indonesia', 1, 'id_ID', 'ID', 'IDN', 'IDR', 'Asia', 'South-Eastern Asia', 'UTC+07:00', 'https://flagcdn.com/id.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (215, 'Saint Lucia', 1, '', 'LC', 'LCA', 'XCD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/lc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (216, 'Guernsey', 1, '', 'GG', 'GGY', 'GBP', 'Europe', 'Northern Europe', 'UTC+00:00', 'https://flagcdn.com/gg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (217, 'Kyrgyzstan', 1, 'ky_KG', 'KG', 'KGZ', 'KGS', 'Asia', 'Central Asia', 'UTC+06:00', 'https://flagcdn.com/kg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (218, 'Germany', 1, 'de_DE', 'DE', 'DEU', 'EUR', 'Europe', 'Western Europe', 'UTC+01:00', 'https://flagcdn.com/de.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (219, 'Bolivia', 1, 'es_BO', 'BO', 'BOL', 'BOB', 'Americas', 'South America', 'UTC-04:00', 'https://flagcdn.com/bo.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (220, 'Dominican Republic', 1, 'es_DO', 'DO', 'DOM', 'DOP', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/do.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (221, 'Puerto Rico', 1, 'es_PR', 'PR', 'PRI', 'USD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/pr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (222, 'Lebanon', 1, 'ar_LB', 'LB', 'LBN', 'LBP', 'Asia', 'Western Asia', 'UTC+02:00', 'https://flagcdn.com/lb.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (223, 'Maldives', 1, 'dv_MV', 'MV', 'MDV', 'MVR', 'Asia', 'Southern Asia', 'UTC+05:00', 'https://flagcdn.com/mv.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (224, 'San Marino', 1, '', 'SM', 'SMR', 'EUR', 'Europe', 'Southern Europe', 'UTC+01:00', 'https://flagcdn.com/sm.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (225, 'South Korea', 1, 'ko_KR', 'KR', 'KOR', 'KRW', 'Asia', 'Eastern Asia', 'UTC+09:00', 'https://flagcdn.com/kr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (226, 'Norfolk Island', 1, '', 'NF', 'NFK', 'AUD', 'Oceania', 'Australia and New Zealand', 'UTC+11:30', 'https://flagcdn.com/nf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (227, 'Syria', 1, 'ar_SY', 'SY', 'SYR', 'SYP', 'Asia', 'Western Asia', 'UTC+02:00', 'https://flagcdn.com/sy.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (228, 'Afghanistan', 1, 'fa_AF', 'AF', 'AFG', 'AFN', 'Asia', 'Southern Asia', 'UTC+04:30', 'https://upload.wikimedia.org/wikipedia/commons/5/5c/Flag_of_the_Taliban.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (229, 'Malawi', 1, 'ny_MW', 'MW', 'MWI', 'MWK', 'Africa', 'Eastern Africa', 'UTC+02:00', 'https://flagcdn.com/mw.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (230, 'Tajikistan', 1, 'tg_TJ', 'TJ', 'TJK', 'TJS', 'Asia', 'Central Asia', 'UTC+05:00', 'https://flagcdn.com/tj.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (231, 'Turkey', 1, 'ku_TR', 'TR', 'TUR', 'TRY', 'Asia', 'Western Asia', 'UTC+03:00', 'https://flagcdn.com/tr.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (232, 'Equatorial Guinea', 1, '', 'GQ', 'GNQ', 'XAF', 'Africa', 'Middle Africa', 'UTC+01:00', 'https://flagcdn.com/gq.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (233, 'Turks and Caicos Islands', 1, '', 'TC', 'TCA', 'USD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/tc.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (234, 'India', 1, 'as_IN', 'IN', 'IND', 'INR', 'Asia', 'Southern Asia', 'UTC+05:30', 'https://flagcdn.com/in.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (235, 'Nigeria', 1, 'cch_NG', 'NG', 'NGA', 'NGN', 'Africa', 'Western Africa', 'UTC+01:00', 'https://flagcdn.com/ng.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (236, 'Pakistan', 1, 'en_PK', 'PK', 'PAK', 'PKR', 'Asia', 'Southern Asia', 'UTC+05:00', 'https://flagcdn.com/pk.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (237, 'Latvia', 1, 'lv_LV', 'LV', 'LVA', 'EUR', 'Europe', 'Northern Europe', 'UTC+02:00', 'https://flagcdn.com/lv.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (238, 'Iran', 1, 'fa_IR', 'IR', 'IRN', 'IRR', 'Asia', 'Southern Asia', 'UTC+03:30', 'https://flagcdn.com/ir.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (239, 'Cape Verde', 1, '', 'CV', 'CPV', 'CVE', 'Africa', 'Western Africa', 'UTC-01:00', 'https://flagcdn.com/cv.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (240, 'French Southern and Antarctic Lands', 1, '', 'TF', 'ATF', 'EUR', 'Antarctic', '', 'UTC+05:00', 'https://flagcdn.com/tf.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (241, 'Bulgaria', 1, 'bg_BG', 'BG', 'BGR', 'BGN', 'Europe', 'Southeast Europe', 'UTC+02:00', 'https://flagcdn.com/bg.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (242, 'Estonia', 1, 'et_EE', 'EE', 'EST', 'EUR', 'Europe', 'Northern Europe', 'UTC+02:00', 'https://flagcdn.com/ee.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (243, 'Christmas Island', 1, '', 'CX', 'CXR', 'AUD', 'Oceania', 'Australia and New Zealand', 'UTC+07:00', 'https://flagcdn.com/cx.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (244, 'Haiti', 1, '', 'HT', 'HTI', 'HTG', 'Americas', 'Caribbean', 'UTC-05:00', 'https://flagcdn.com/ht.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (245, 'Saint Helena, Ascension and Tristan da Cunha', 1, '', 'SH', 'SHN', 'GBP', 'Africa', 'Western Africa', 'UTC+00:00', 'https://flagcdn.com/sh.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (246, 'Isle of Man', 1, '', 'IM', 'IMN', 'GBP', 'Europe', 'Northern Europe', 'UTC+00:00', 'https://flagcdn.com/im.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (247, 'Gabon', 1, '', 'GA', 'GAB', 'XAF', 'Africa', 'Middle Africa', 'UTC+01:00', 'https://flagcdn.com/ga.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (248, 'Guyana', 1, '', 'GY', 'GUY', 'GYD', 'Americas', 'South America', 'UTC-04:00', 'https://flagcdn.com/gy.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (249, 'Saudi Arabia', 1, 'ar_SA', 'SA', 'SAU', 'SAR', 'Asia', 'Western Asia', 'UTC+03:00', 'https://flagcdn.com/sa.svg', 0, 0, 0);
INSERT INTO `countries` VALUES (250, 'Trinidad and Tobago', 1, 'en_TT', 'TT', 'TTO', 'TTD', 'Americas', 'Caribbean', 'UTC-04:00', 'https://flagcdn.com/tt.svg', 0, 0, 0);


-- ----------------------------
-- Table structure for countries_trans
-- ----------------------------
DROP TABLE IF EXISTS `countries_trans`;
CREATE TABLE `countries_trans`  (
  `intCountryTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intCountryID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strCountryName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCountryTransID`) USING BTREE,
  INDEX `_intCountryID`(`intCountryID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_ct_countries` FOREIGN KEY (`intCountryID`) REFERENCES `countries` (`intCountryID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_ct_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


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
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intLanguageID`) USING BTREE,
  UNIQUE INDEX `_strLanguageISO`(`strLanguageISO`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Records of languages
-- ----------------------------
INSERT INTO `languages` VALUES (1, 'en', 'English', 'English', 1, 1, 1, now());
INSERT INTO `languages` VALUES (2, 'de', 'German', 'Deutsch', 2, 0, 1, now());


-- ----------------------------
-- Table structure for currencies
-- ----------------------------
DROP TABLE IF EXISTS `currencies`;
CREATE TABLE `currencies`  (
  `intCurrencyID` int(11) NOT NULL AUTO_INCREMENT,
  `strCurrencyISO` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strCurrencyEN` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strCurrency` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intPrio` int(11) NOT NULL,
  `blnDefault` tinyint(1) NOT NULL DEFAULT 0,
  `blnActive` tinyint(1) NOT NULL DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCurrencyID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

INSERT INTO `currencies` VALUES (1, 'USD', 'US Dollar', 'US Dollar', 1, 0, 0, now());
INSERT INTO `currencies` VALUES (2, 'EUR', 'Euro', 'Euro', 2, 0, 0, now());
INSERT INTO `currencies` VALUES (3, 'CHF', 'Swiss Francs', 'Schweizer Franken', 3, 0, 0, now());
INSERT INTO `currencies` VALUES (4, 'GBP', 'Pound sterling', 'Pound sterling', 4, 0, 0, now());


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
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCustomMappingID`) USING BTREE,
  UNIQUE INDEX `_strMapping`(`strMapping`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for custom_settings
-- ----------------------------
DROP TABLE IF EXISTS `custom_settings`;
CREATE TABLE `custom_settings`  (
  `intCustomSettingID` int(11) NOT NULL AUTO_INCREMENT,
  `strSettingVariable` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDefaultValue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCustomSettingID`) USING BTREE,
  UNIQUE INDEX `_intCustomSettingID`(`intCustomSettingID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for custom_settings_trans
-- ----------------------------
DROP TABLE IF EXISTS `custom_settings_trans`;
CREATE TABLE `custom_settings_trans`  (
  `intCustSetTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomSettingID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strDefaultValue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCustSetTransID`) USING BTREE,
  INDEX `_intCustomSettingID`(`intCustomSettingID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_cst_cust_settings` FOREIGN KEY (`intCustomSettingID`) REFERENCES `custom_settings` (`intCustomSettingID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cst_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for custom_translations
-- ----------------------------
DROP TABLE IF EXISTS `custom_translations`;
CREATE TABLE `custom_translations`  (
  `intCustTransID` int(11) NOT NULL AUTO_INCREMENT,
  `strVariable` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strStringDE` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strStringEN` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCustTransID`) USING BTREE,
  UNIQUE INDEX `_strVariable`(`strVariable`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for customer_custom_settings
-- ----------------------------
DROP TABLE IF EXISTS `customer_custom_settings`;
CREATE TABLE `customer_custom_settings`  (
  `intCustCustomSettingID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intCustomSettingID` int(11) NOT NULL,
  `strSettingValue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCustCustomSettingID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intCustomSettingID`(`intCustomSettingID`) USING BTREE,
  CONSTRAINT `frn_ccs_custom_settings` FOREIGN KEY (`intCustomSettingID`) REFERENCES `custom_settings` (`intCustomSettingID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_ccs_customers` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for customer_modules
-- ----------------------------
DROP TABLE IF EXISTS `customer_modules`;
CREATE TABLE `customer_modules`  (
  `intCustModuleID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intModuleID` int(11) NOT NULL,
  `dtmActivated` datetime NOT NULL,
  `dtmTestUntil` datetime NULL DEFAULT NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 1,
  `blnPaused` tinyint(1) NOT NULL DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCustModuleID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intModuleID`(`intModuleID`) USING BTREE,
  CONSTRAINT `frn_cm_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cust_mod` FOREIGN KEY (`intModuleID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for customer_plans
-- ----------------------------
DROP TABLE IF EXISTS `customer_plans`;
CREATE TABLE `customer_plans`  (
  `intCustomerPlanID` int(11) NOT NULL,
  `intCustomerID` int(11) NOT NULL,
  `intPlanID` int(11) NOT NULL,
  `dtmStartDate` date NOT NULL,
  `dtmEndDate` date NOT NULL,
  `blnPaused` tinyint(1) NOT NULL DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCustomerPlanID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intPlanID`(`intPlanID`) USING BTREE,
  CONSTRAINT `frn_cp_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cp_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for customer_system_settings
-- ----------------------------
DROP TABLE IF EXISTS `customer_system_settings`;
CREATE TABLE `customer_system_settings`  (
  `intCustSystSettingID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intSystSettingID` int(11) NOT NULL,
  `strSettingValue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCustSystSettingID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intSystSettingID`(`intSystSettingID`) USING BTREE,
  CONSTRAINT `frn_css_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_css_system_settings` FOREIGN KEY (`intSystSettingID`) REFERENCES `system_settings` (`intSystSettingID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for customer_user
-- ----------------------------
DROP TABLE IF EXISTS `customer_user`;
CREATE TABLE `customer_user`  (
  `intCustUserID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NULL DEFAULT NULL,
  `intUserID` int(11) NULL DEFAULT NULL,
  `blnStandard` tinyint(1) NOT NULL DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCustUserID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intUserID`(`intUserID`) USING BTREE,
  CONSTRAINT `frn_cu_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_cu_users` FOREIGN KEY (`intUserID`) REFERENCES `users` (`intUserID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for customers
-- ----------------------------
DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers`  (
  `intCustomerID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustParentID` int(11) NOT NULL DEFAULT 0,
  `dtmInsertDate` datetime NOT NULL,
  `dtmMutDate` datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `blnActive` tinyint(1) NOT NULL DEFAULT 0,
  `strCompanyName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strContactPerson` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strAddress` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strAddress2` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strZIP` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strCity` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intCountryID` int(11) NULL DEFAULT 1,
  `strPhone` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strEmail` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strWebsite` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strLogo` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strBillingAccountName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strBillingEmail` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strBillingAddress` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strBillingInfo` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `blnOwnerAccount` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'The owner account is assigned to the owner of the present project.',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intCustomerID`) USING BTREE,
  UNIQUE INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intCountryID`(`intCountryID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


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
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intInvoicePosID`) USING BTREE,
  INDEX `_intInvoiceID`(`intInvoiceID`) USING BTREE,
  CONSTRAINT `frn_pos_invoice` FOREIGN KEY (`intInvoiceID`) REFERENCES `invoices` (`intInvoiceID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Records of invoice_status
-- ----------------------------
INSERT INTO `invoice_status` VALUES (1, 'statInvoiceOpen', 'red');
INSERT INTO `invoice_status` VALUES (2, 'statInvoicePaid', 'darkgreen');
INSERT INTO `invoice_status` VALUES (3, 'statInvoicePartPaid', 'orange');
INSERT INTO `invoice_status` VALUES (4, 'statInvoiceOverPay', 'darkblue');
INSERT INTO `invoice_status` VALUES (5, 'statInvoiceCanceled', 'darkred');


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
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intInvoiceVatID`) USING BTREE,
  INDEX `_intInvoiceID`(`intInvoiceID`) USING BTREE,
  CONSTRAINT `frn_invoice_vat` FOREIGN KEY (`intInvoiceID`) REFERENCES `invoices` (`intInvoiceID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for invoices
-- ----------------------------
DROP TABLE IF EXISTS `invoices`;
CREATE TABLE `invoices`  (
  `intInvoiceID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intInvoiceNumber` int(11) NOT NULL,
  `strPrefix` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strInvoiceTitle` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dtmInvoiceDate` date NOT NULL,
  `dtmDueDate` date NOT NULL,
  `strCurrency` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `blnIsNet` tinyint(1) NOT NULL DEFAULT 1,
  `intVatType` int(1) NOT NULL COMMENT '1=incl; 2=excl; 3=no vat',
  `decSubTotalPrice` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `decTotalPrice` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `strTotalText` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intPaymentStatusID` int(11) NOT NULL DEFAULT 1,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intInvoiceID`) USING BTREE,
  UNIQUE INDEX `_intInvoiceID`(`intInvoiceID`) USING BTREE,
  UNIQUE INDEX `_intInvoiceNumber`(`intInvoiceNumber`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intPaymentStatusID`(`intPaymentStatusID`) USING BTREE,
  CONSTRAINT `frn_inv_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_inv_invstat` FOREIGN KEY (`intPaymentStatusID`) REFERENCES `invoice_status` (`intPaymentStatusID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for modules
-- ----------------------------
DROP TABLE IF EXISTS `modules`;
CREATE TABLE `modules`  (
  `intModuleID` int(11) NOT NULL AUTO_INCREMENT,
  `strModuleName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strShortDescription` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `blnActive` tinyint(1) NOT NULL DEFAULT 0,
  `strTabPrefix` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strPicture` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `blnBookable` tinyint(1) NOT NULL DEFAULT 1,
  `intPrio` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intModuleID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for modules_trans
-- ----------------------------
DROP TABLE IF EXISTS `modules_trans`;
CREATE TABLE `modules_trans`  (
  `intModulTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intModulID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strModuleName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strPicture` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intModulTransID`) USING BTREE,
  INDEX `_intModulID`(`intModulID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_modules_trans` FOREIGN KEY (`intModulID`) REFERENCES `modules` (`intModuleID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_mt_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `intNotificationID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `intUserID` int(11) NOT NULL,
  `dtmCreated` datetime NULL DEFAULT NULL,
  `strTitle` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strLink` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dtmRead` datetime NULL DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intNotificationID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  INDEX `_intUserID`(`intUserID`) USING BTREE,
  CONSTRAINT `frn_noti_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_noti_user` FOREIGN KEY (`intUserID`) REFERENCES `users` (`intUserID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for notifications_trans
-- ----------------------------
DROP TABLE IF EXISTS `notifications_trans`;
CREATE TABLE `notifications_trans`  (
  `intNotTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intNotificationID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strTitle` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `strLink` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intNotTransID`) USING BTREE,
  INDEX `_intNotificationID`(`intNotificationID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_noti_trans` FOREIGN KEY (`intNotificationID`) REFERENCES `notifications` (`intNotificationID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_nt_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


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
  `strUUID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intOptinID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for payments
-- ----------------------------
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments`  (
  `intPaymentID` int(11) NOT NULL AUTO_INCREMENT,
  `intInvoiceID` int(11) NOT NULL,
  `intCustomerID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `decAmount` decimal(10, 2) NOT NULL,
  `strCurrency` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `dtmPayDate` date NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intPaymentID`) USING BTREE,
  INDEX `_intInvoiceID`(`intInvoiceID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_pay_invoice` FOREIGN KEY (`intInvoiceID`) REFERENCES `invoices` (`intInvoiceID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for plan_features
-- ----------------------------
DROP TABLE IF EXISTS `plan_features`;
CREATE TABLE `plan_features`  (
  `intPlanFeatureID` int(11) NOT NULL AUTO_INCREMENT,
  `strFeatureName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strDescription` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `blnCategory` tinyint(1) NOT NULL DEFAULT 0,
  `intPrio` int(5) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intPlanFeatureID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


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
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intPlanFeatTransID`) USING BTREE,
  INDEX `_intPlanFeatureID`(`intPlanFeatureID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_pft_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_pft_plan_features` FOREIGN KEY (`intPlanFeatureID`) REFERENCES `plan_features` (`intPlanFeatureID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


-- ----------------------------
-- Table structure for plan_groups
-- ----------------------------
DROP TABLE IF EXISTS `plan_groups`;
CREATE TABLE `plan_groups`  (
  `intPlanGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `strGroupName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `intCountryID` int(11) NULL DEFAULT NULL,
  `intPrio` int(11) NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intPlanGroupID`) USING BTREE,
  INDEX `_intCountryID`(`intCountryID`) USING BTREE,
  CONSTRAINT `frn_pg_countries` FOREIGN KEY (`intCountryID`) REFERENCES `countries` (`intCountryID`) ON DELETE RESTRICT ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


-- ----------------------------
-- Table structure for plan_groups_trans
-- ----------------------------
DROP TABLE IF EXISTS `plan_groups_trans`;
CREATE TABLE `plan_groups_trans`  (
  `intPlanGroupTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intPlanGroupID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strGroupName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intPlanGroupTransID`) USING BTREE,
  INDEX `_intPlanGroupID`(`intPlanGroupID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_pgt_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_pgt_plangroups` FOREIGN KEY (`intPlanGroupID`) REFERENCES `plan_groups` (`intPlanGroupID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


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
  `intPrio` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intPlanID`) USING BTREE,
  INDEX `_intPlanGroupID`(`intPlanGroupID`) USING BTREE,
  CONSTRAINT `frn_plans_plan_group` FOREIGN KEY (`intPlanGroupID`) REFERENCES `plan_groups` (`intPlanGroupID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


-- ----------------------------
-- Table structure for plans_modules
-- ----------------------------
DROP TABLE IF EXISTS `plans_modules`;
CREATE TABLE `plans_modules`  (
  `intPlanModuleID` int(11) NOT NULL AUTO_INCREMENT,
  `intPlanID` int(11) NOT NULL,
  `intModuleID` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intPlanModuleID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


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
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intPlansPlanFeatID`) USING BTREE,
  INDEX `_intPlanID`(`intPlanID`) USING BTREE,
  INDEX `_intPlanFeatureID`(`intPlanFeatureID`) USING BTREE,
  CONSTRAINT `frn_ppf_plan_features` FOREIGN KEY (`intPlanFeatureID`) REFERENCES `plan_features` (`intPlanFeatureID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_ppf_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


-- ----------------------------
-- Table structure for plans_plan_features_trans
-- ----------------------------
DROP TABLE IF EXISTS `plans_plan_features_trans`;
CREATE TABLE `plans_plan_features_trans`  (
  `intPlansPlanFeatTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intPlansPlanFeatID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strValue` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intPlansPlanFeatTransID`) USING BTREE,
  INDEX `_intPlansPlanFeatID`(`intPlansPlanFeatID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_ppft_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_ppft_plans_plan_features` FOREIGN KEY (`intPlansPlanFeatID`) REFERENCES `plans_plan_features` (`intPlansPlanFeatID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


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
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intPlanTransID`) USING BTREE,
  INDEX `_intPlanID`(`intPlanID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_pt_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_pt_plans` FOREIGN KEY (`intPlanID`) REFERENCES `plans` (`intPlanID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


-- ----------------------------
-- Table structure for setup_saaster
-- ----------------------------
DROP TABLE IF EXISTS `setup_saaster`;
CREATE TABLE `setup_saaster`  (
  `intDefaultCountryID` int(3) NULL DEFAULT NULL,
  `blnWorldWide` tinyint(1) NULL DEFAULT NULL,
  `strCountryList` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intDefaultLanguageID` int(3) NULL DEFAULT NULL,
  `intDefaultCurrencyID` int(3) NULL DEFAULT NULL,
  `blnFinished` tinyint(1) NOT NULL DEFAULT 0
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;


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
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intSystemMappingID`) USING BTREE,
  UNIQUE INDEX `_strMapping`(`strMapping`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Records of system_mappings
-- ----------------------------
INSERT INTO `system_mappings` VALUES (1, 'login', 'frontend/login.cfm', 0, 0, 0, now());
INSERT INTO `system_mappings` VALUES (2, 'register', 'frontend/register.cfm', 0, 0, 0, now());
INSERT INTO `system_mappings` VALUES (3, 'password', 'frontend/password.cfm', 0, 0, 0, now());
INSERT INTO `system_mappings` VALUES (4, 'dashboard', 'views/dashboard.cfm', 0, 0, 0, now());
INSERT INTO `system_mappings` VALUES (5, 'account-settings/my-profile', 'views/customer/my-profile.cfm', 0, 0, 0, now());
INSERT INTO `system_mappings` VALUES (6, 'customer', 'handler/customer.cfm', 0, 1, 0, now());
INSERT INTO `system_mappings` VALUES (7, 'global', 'handler/global.cfm', 0, 0, 0, now());
INSERT INTO `system_mappings` VALUES (9, 'registration', 'handler/register.cfm', 0, 0, 0, now());
INSERT INTO `system_mappings` VALUES (12, 'account-settings', 'views/customer/account-settings.cfm', 0, 0, 0, now());
INSERT INTO `system_mappings` VALUES (13, 'account-settings/company', 'views/customer/company-edit.cfm', 1, 0, 0, now());
INSERT INTO `system_mappings` VALUES (14, 'account-settings/tenants', 'views/customer/tenants.cfm', 0, 1, 0, now());
INSERT INTO `system_mappings` VALUES (15, 'account-settings/users', 'views/customer/users.cfm', 1, 0, 0, now());
INSERT INTO `system_mappings` VALUES (16, 'modules', 'views/modules/modules.cfm', 1, 0, 0, now());
INSERT INTO `system_mappings` VALUES (17, 'account-settings/reset-password', 'views/customer/reset-password.cfm', 0, 0, 0, now());
INSERT INTO `system_mappings` VALUES (19, 'account-settings/user/new', 'views/customer/user_new.cfm', 1, 0, 0, now());
INSERT INTO `system_mappings` VALUES (20, 'account-settings/user/edit', 'views/customer/user_edit.cfm', 1, 0, 0, now());
INSERT INTO `system_mappings` VALUES (21, 'account-settings/tenant/new', 'views/customer/tenant_new.cfm', 0, 1, 0, now());
INSERT INTO `system_mappings` VALUES (23, 'account-settings/invoices', 'views/invoices/invoices.cfm', 1, 0, 0, now());
INSERT INTO `system_mappings` VALUES (25, 'account-settings/invoice', 'views/invoices/invoice.cfm', 1, 0, 0, now());
INSERT INTO `system_mappings` VALUES (26, 'account-settings/modules', 'views/modules/modules.cfm', 1, 0, 0, now());
INSERT INTO `system_mappings` VALUES (27, 'invoices', 'handler/invoices.cfm', 1, 0, 0, now());
INSERT INTO `system_mappings` VALUES (29, 'sysadmin/mappings', 'views/sysadmin/mappings.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (31, 'sysadmin/translations', 'views/sysadmin/translations.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (32, 'sysadmin/settings', 'views/sysadmin/settings.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (33, 'user', 'handler/user.cfm', 1, 0, 0, now());
INSERT INTO `system_mappings` VALUES (34, 'sysadmin/languages', 'views/sysadmin/languages.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (36, 'sysadmin/countries', 'views/sysadmin/countries.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (37, 'sysadmin/countries/import', 'views/sysadmin/country_import.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (39, 'sysadmin/modules', 'views/sysadmin/modules.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (41, 'sysadmin/modules/edit', 'views/sysadmin/module_edit.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (42, 'sysadmin/widgets', 'views/sysadmin/widgets.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (43, 'sysadm/mappings', 'handler/sysadmin/mappings.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (44, 'sysadm/translations', 'handler/sysadmin/translations.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (45, 'sysadm/languages', 'handler/sysadmin/languages.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (46, 'sysadm/settings', 'handler/sysadmin/settings.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (47, 'sysadm/countries', 'handler/sysadmin/countries.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (48, 'sysadm/modules', 'handler/sysadmin/modules.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (49, 'account-settings/invoice/print', 'views/invoices/print.cfm', 1, 0, 0, now());
INSERT INTO `system_mappings` VALUES (50, 'sysadm/widgets', 'handler/sysadmin/widgets.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (51, 'sysadmin/plans', 'views/sysadmin/plans.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (52, 'sysadmin/currencies', 'views/sysadmin/currencies.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (53, 'sysadm/currencies', 'handler/sysadmin/currencies.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (54, 'sysadm/plans', 'handler/sysadmin/plans.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (55, 'sysadmin/plan/edit', 'views/sysadmin/plan_edit.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (56, 'sysadmin/plangroups', 'views/sysadmin/plan_groups.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (57, 'sysadmin/planfeatures', 'views/sysadmin/plan_features.cfm', 0, 0, 1, now());
INSERT INTO `system_mappings` VALUES (58, 'plans', 'frontend/plans.cfm', 0, 0, 0, now());


-- ----------------------------
-- Table structure for system_settings
-- ----------------------------
DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE `system_settings`  (
  `intSystSettingID` int(11) NOT NULL AUTO_INCREMENT,
  `strSettingVariable` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDefaultValue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intSystSettingID`) USING BTREE,
  UNIQUE INDEX `_intSystSettingID`(`intSystSettingID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_settings
-- ----------------------------
INSERT INTO `system_settings` VALUES (1, 'settingInvoiceNumberStart', '1000', 'New invoice: At which invoice number should the system start?', now());
INSERT INTO `system_settings` VALUES (2, 'settingRoundFactor', '5', 'The rounding factor for invoice amounts. Note: Currently only 5 (0.05 Switzerland) or 1 (0.01 rest of the world) are available.', now());


-- ----------------------------
-- Table structure for system_settings_trans
-- ----------------------------
DROP TABLE IF EXISTS `system_settings_trans`;
CREATE TABLE `system_settings_trans`  (
  `intSystSetTransID` int(11) NOT NULL AUTO_INCREMENT,
  `intSystSettingID` int(11) NOT NULL,
  `intLanguageID` int(11) NOT NULL,
  `strDefaultValue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strDescription` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intSystSetTransID`) USING BTREE,
  INDEX `_intSystSettingID`(`intSystSettingID`) USING BTREE,
  INDEX `_intLanguageID`(`intLanguageID`) USING BTREE,
  CONSTRAINT `frn_sst_languages` FOREIGN KEY (`intLanguageID`) REFERENCES `languages` (`intLanguageID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_sst_system_setting` FOREIGN KEY (`intSystSettingID`) REFERENCES `system_settings` (`intSystSettingID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for system_translations
-- ----------------------------
DROP TABLE IF EXISTS `system_translations`;
CREATE TABLE `system_translations`  (
  `intSystTransID` int(11) NOT NULL AUTO_INCREMENT,
  `strVariable` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strStringDE` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `strStringEN` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intSystTransID`) USING BTREE,
  UNIQUE INDEX `_strVariable`(`strVariable`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 174 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_translations
-- ----------------------------
INSERT INTO `system_translations` VALUES (1, 'alertAccountCreatedLogin', 'Ihr Account wurde erfolgreich erstellt. Bitte loggen Sie sich nun ein.', 'Your account has been successfully created. Please log in now.', now());
INSERT INTO `system_translations` VALUES (2, 'alertChoosePassword', 'Bitte vergeben Sie sich ein starkes Passwort mit mindestens 8 Zeichen.', 'Please assign yourself a strong password with at least 8 characters.', now());
INSERT INTO `system_translations` VALUES (3, 'alertEmailAlreadyUsed', 'Diese E-Mail-Adresse wurde bereits benutzt!', 'This email address has already been used!', now());
INSERT INTO `system_translations` VALUES (4, 'alertEnterAddress', 'Bitte geben Sie Ihre Adresse ein!', 'Please enter your address!', now());
INSERT INTO `system_translations` VALUES (5, 'alertEnterCity', 'Bitte geben Sie Ihre Ortschaft ein!', 'Please enter your City!', now());
INSERT INTO `system_translations` VALUES (6, 'alertEnterCompany', 'Bitte geben Sie den Firmennamen ein!', 'Please enter company name!', now());
INSERT INTO `system_translations` VALUES (7, 'alertEnterEmail', 'Bitte geben Sie eine gültige E-Mail-Adresse ein!', 'Please enter a valid e-mail address!', now());
INSERT INTO `system_translations` VALUES (8, 'alertEnterFirstName', 'Bitte geben Sie Ihren Vornamen ein!', 'Please enter your first name!', now());
INSERT INTO `system_translations` VALUES (9, 'alertEnterName', 'Bitte geben Sie Ihren Namen ein!', 'Please enter your name!', now());
INSERT INTO `system_translations` VALUES (10, 'alertEnterPassword1', 'Bitte geben Sie das Passwort ein!', 'Please enter the password!', now());
INSERT INTO `system_translations` VALUES (11, 'alertEnterPassword2', 'Bitte bestätigen Sie das Passwort!', 'Please confirm the password!', now());
INSERT INTO `system_translations` VALUES (12, 'alertEnterZIP', 'Bitte geben Sie Ihre PLZ ein!', 'Please enter your ZIP!', now());
INSERT INTO `system_translations` VALUES (13, 'alertErrorOccured', 'Es ist ein Fehler aufgetreten. Bitte versuchen Sie nocheinmal.', 'An error has occurred. Please try again.', now());
INSERT INTO `system_translations` VALUES (14, 'alertHasAccountAlready', 'Diese E-Mail-Adresse wurde bereits verwendet. Bitte loggen Sie sich ein oder setzen Sie Ihr Passwort zurück.', 'This email address has already been used. Please log in or reset your password.', now());
INSERT INTO `system_translations` VALUES (15, 'alertIfAccountFoundEmail', 'Wenn wir einen Account mit dieser E-Mail-Adresse finden, werden wir Ihnen einen Link senden, um Ihr Passwort zurückzusetzen.', 'If we find an account with this email address, we will send you a link to reset your password.', now());
INSERT INTO `system_translations` VALUES (16, 'alertLoggedOut', 'Sie haben sich erfolgreich abgemeldet.', 'You have successfully logged out.', now());
INSERT INTO `system_translations` VALUES (17, 'alertNewUserCreated', 'Der neue Benutzer wurde erfolgreich angelegt und es wurde ein Aktivierungslink gesendet.', 'The new user has been created successfully and an activation link has been sent.', now());
INSERT INTO `system_translations` VALUES (18, 'alertNotValidAnymore', 'Dieser Link ist leider nicht mehr gültig!', 'Sorry, this link is no longer valid!', now());
INSERT INTO `system_translations` VALUES (19, 'alertOptinSent', 'Wir haben Ihnen an die von Ihnen angegebene Adresse ein E-Mail gesendet. Bitte klicken Sie auf den darin enthaltenen Link, um Ihre E-Mail-Adresse zu bestätigen.', 'We have sent you an email to the address you provided. Please click on the link contained therein to confirm your email address.', now());
INSERT INTO `system_translations` VALUES (20, 'alertPasswordResetSuccess', 'Ihr Passwort wurde erfolgreich zurückgesetzt. Bitte loggen Sie sich nun ein.', 'Your password has been successfully reset. Please log in now.', now());
INSERT INTO `system_translations` VALUES (21, 'alertPasswordResetSuccessfully', 'Ihr neues Passwort wurde erfolgreich gespeichert.', 'Your new password has been successfully saved.', now());
INSERT INTO `system_translations` VALUES (22, 'alertPasswordsNotSame', 'Die beiden Passwörter stimmen nicht überein! Probieren Sie nochmal.', 'The two passwords do not match! Try again.', now());
INSERT INTO `system_translations` VALUES (23, 'alertSessionExpired', 'Ihre Session ist leider abgelaufen, bitte loggen Sie sich erneut ein.', 'Sorry, your session has expired, please log in again.', now());
INSERT INTO `system_translations` VALUES (24, 'alertTenantAdded', 'Der neue Mandant wurde erfolgreich erstellt. Sie können die Firma entweder hier oder oben im Header auswählen.', 'The new tenant has been successfully created. You can select the company either here or in the header above.', now());
INSERT INTO `system_translations` VALUES (25, 'alertTenantDeleted', 'Der Mandant wurde erfolgreich gelöscht.', 'The tenant has been successfully deleted.', now());
INSERT INTO `system_translations` VALUES (26, 'alertWrongLogin', 'Die E-Mail-Adresse und/oder das Passwort ist falsch, bitte versuchen Sie es nochmal.', 'The email address and/or password is incorrect, please try again.', now());
INSERT INTO `system_translations` VALUES (27, 'blnAction', 'Aktion', 'Action', now());
INSERT INTO `system_translations` VALUES (28, 'btnActivate', 'Aktivieren', 'Activate', now());
INSERT INTO `system_translations` VALUES (29, 'btnClose', 'Schliessen', 'Close', now());
INSERT INTO `system_translations` VALUES (30, 'btnDeactivate', 'Deaktivieren', 'Deactivate', now());
INSERT INTO `system_translations` VALUES (31, 'btnDelete', 'Löschen', 'Delete', now());
INSERT INTO `system_translations` VALUES (32, 'btnEdit', 'Bearbeiten', 'Edit', now());
INSERT INTO `system_translations` VALUES (33, 'btnNewTenant', 'Mandant hinzufügen', 'New tenant', now());
INSERT INTO `system_translations` VALUES (34, 'btnNewUser', 'Benutzer hinzufügen', 'New user', now());
INSERT INTO `system_translations` VALUES (35, 'btnNoCancel', 'Nein, abbrechen!', 'No, cancel!', now());
INSERT INTO `system_translations` VALUES (36, 'btnSave', 'Speichern', 'Save', now());
INSERT INTO `system_translations` VALUES (37, 'btnSendActivLink', 'Aktivierungslink senden', 'Send activation link', now());
INSERT INTO `system_translations` VALUES (38, 'btnSetStandard', 'Als Standard definieren', 'Define as standard', now());
INSERT INTO `system_translations` VALUES (39, 'btnSwitchToThisCompany', 'Zur dieser Firma wechseln', 'Switch to this company', now());
INSERT INTO `system_translations` VALUES (40, 'btnUpload', 'Hochladen', 'Upload', now());
INSERT INTO `system_translations` VALUES (41, 'btnYesDelete', 'Ja, löschen!', 'Yes, delete!', now());
INSERT INTO `system_translations` VALUES (42, 'errContactNumberAlreadyUsedTitle', 'Diese Kontaktnummer wurde bereits verwendet', 'This contact number has already been used', now());
INSERT INTO `system_translations` VALUES (43, 'errSystemStoppedFixProblem', 'Das System wurde gestoppt. Bitte lösen Sie das Problem, um das System wieder zu starten.', 'The system has been stopped. Please fix the problem in order to restart the system.', now());
INSERT INTO `system_translations` VALUES (44, 'formAddress', 'Adresse', 'Address', now());
INSERT INTO `system_translations` VALUES (45, 'formAddress2', 'Zusatzadresse', 'Additional address', now());
INSERT INTO `system_translations` VALUES (46, 'formAlreadyHaveAccount', 'Sie haben bereits einen Account?', 'Already have account?', now());
INSERT INTO `system_translations` VALUES (47, 'formCity', 'Ort', 'City', now());
INSERT INTO `system_translations` VALUES (48, 'formCompanyName', 'Firma', 'Company Name', now());
INSERT INTO `system_translations` VALUES (49, 'formContactName', 'Ansprechperson', 'Contact person', now());
INSERT INTO `system_translations` VALUES (50, 'formCountry', 'Land', 'Country', now());
INSERT INTO `system_translations` VALUES (51, 'formEmailAddress', 'E-Mail Adresse', 'Email address', now());
INSERT INTO `system_translations` VALUES (52, 'formEnterCompanyName', 'Firmenname eingeben', 'Enter Company Name', now());
INSERT INTO `system_translations` VALUES (53, 'formEnterEmail', 'E-Mail eingeben', 'Enter email', now());
INSERT INTO `system_translations` VALUES (54, 'formEnterFirstName', 'Vorname eingeben', 'Enter First Name', now());
INSERT INTO `system_translations` VALUES (55, 'formEnterName', 'Name eingeben', 'Enter Name', now());
INSERT INTO `system_translations` VALUES (56, 'formFirstName', 'Vorname', 'First Name', now());
INSERT INTO `system_translations` VALUES (57, 'formForgotPassword', 'Passwort vergessen?', 'Password forgotten?', now());
INSERT INTO `system_translations` VALUES (58, 'formInvoiceAddress', 'Adresse für Rechnungen', 'Invoice address', now());
INSERT INTO `system_translations` VALUES (59, 'formInvoiceEmail', 'E-Mail-Adresse für Rechnungen', 'Invoice email address', now());
INSERT INTO `system_translations` VALUES (60, 'formInvoiceInfo', 'Information für Rechnungen', 'Invoice information', now());
INSERT INTO `system_translations` VALUES (61, 'formMobile', 'Mobile', 'Mobile', now());
INSERT INTO `system_translations` VALUES (62, 'formName', 'Name', 'Name', now());
INSERT INTO `system_translations` VALUES (63, 'formPassword', 'Passwort', 'Password', now());
INSERT INTO `system_translations` VALUES (64, 'formPassword2', 'Passwort bestätigen', 'Confirm password', now());
INSERT INTO `system_translations` VALUES (65, 'formPhone', 'Telefon', 'Phone', now());
INSERT INTO `system_translations` VALUES (66, 'formRegisterText', 'Sie haben noch keinen Account?', 'Don`t have an account yet?', now());
INSERT INTO `system_translations` VALUES (67, 'formReset', 'Zurücksetzen', 'Reset', now());
INSERT INTO `system_translations` VALUES (68, 'formSalutation', 'Anrede', 'Salutation', now());
INSERT INTO `system_translations` VALUES (69, 'formSignIn', 'Einloggen', 'Sign in', now());
INSERT INTO `system_translations` VALUES (70, 'formSignUp', 'Registrieren', 'Sign up', now());
INSERT INTO `system_translations` VALUES (71, 'formStandard', 'Standard', 'Standard', now());
INSERT INTO `system_translations` VALUES (72, 'formWebsite', 'Webseite', 'Website', now());
INSERT INTO `system_translations` VALUES (73, 'formZIP', 'PLZ', 'ZIP', now());
INSERT INTO `system_translations` VALUES (74, 'msgAccountDisabledByAdmin', 'Ihr Account wurde vorübergehend deaktiviert. Bitte melden Sie sich bei Ihrem Administrator.', 'Your account has been temporarily disabled. Please contact your administrator.', now());
INSERT INTO `system_translations` VALUES (75, 'msgChangesSaved', 'Ihre Änderungen wurden erfolgreich gespeichert.', 'Your changes have been saved successfully.', now());
INSERT INTO `system_translations` VALUES (76, 'msgFileTooLarge', 'Die hochgeladene Datei ist zu gross!', 'The uploaded file is too large!', now());
INSERT INTO `system_translations` VALUES (77, 'msgFileUploadedSuccessfully', 'Die Datei wurde erfolgreich hochgeladen.', 'The file has been uploaded successfully.', now());
INSERT INTO `system_translations` VALUES (78, 'msgNoAccess', 'Sie haben leider keinen Zugriff auf den verlangten Bereich. Bitte melden Sie sich bei Ihrem Administrator.', 'Sorry, you do not have access to the requested section. Please contact your administrator.', now());
INSERT INTO `system_translations` VALUES (79, 'msgPleaseChooseFile', 'Bitte wählen Sie eine Datei!', 'Please choose a file!', now());
INSERT INTO `system_translations` VALUES (80, 'msgUserDeleted', 'Der Benutzer wurde erfolgreich gelöscht.', 'The user has been successfully deleted.', now());
INSERT INTO `system_translations` VALUES (81, 'msgUserGotInvitation', 'Der Aktivierungslink wurde erfolgreich gesendet.', 'The activation link has been sent successfully.', now());
INSERT INTO `system_translations` VALUES (82, 'statInvoiceCanceled', 'Storniert', 'Canceled', now());
INSERT INTO `system_translations` VALUES (83, 'statInvoiceOpen', 'Offen', 'Open', now());
INSERT INTO `system_translations` VALUES (84, 'statInvoiceOverPay', 'Überzahlung', 'Overpayment', now());
INSERT INTO `system_translations` VALUES (85, 'statInvoicePaid', 'Bezahlt', 'Paid', now());
INSERT INTO `system_translations` VALUES (86, 'statInvoicePartPaid', 'Teilweise bezahlt', 'Partial paid', now());
INSERT INTO `system_translations` VALUES (87, 'subjectConfirmEmail', 'Bitte bestätigen Sie Ihre E-Mail-Adresse', 'Please confirm your email address', now());
INSERT INTO `system_translations` VALUES (89, 'thisLanguage', 'Deutsch', 'English', now());
INSERT INTO `system_translations` VALUES (90, 'titActive', 'Aktiv', 'Active', now());
INSERT INTO `system_translations` VALUES (91, 'titAdmin', 'Administrator', 'Administrator', now());
INSERT INTO `system_translations` VALUES (92, 'titChoosePassword', 'Passwort wählen', 'Choose password', now());
INSERT INTO `system_translations` VALUES (93, 'titCreateNewAccount', 'Neuen Account anlegen', 'Create New Account', now());
INSERT INTO `system_translations` VALUES (94, 'titDeleteTenant', 'Mandant löschen', 'Delete tenant', now());
INSERT INTO `system_translations` VALUES (95, 'titDeleteUser', 'Benutzer löschen', 'Delete user', now());
INSERT INTO `system_translations` VALUES (96, 'titDescription', 'Beschreibung', 'Description', now());
INSERT INTO `system_translations` VALUES (97, 'titDiscount', 'Rabatt', 'Discount', now());
INSERT INTO `system_translations` VALUES (98, 'titEditCompany', 'Firma bearbeiten', 'Edit company', now());
INSERT INTO `system_translations` VALUES (99, 'titGeneralSettings', 'Allgemeine Einstellungen', 'General settings', now());
INSERT INTO `system_translations` VALUES (100, 'titHello', 'Guten Tag', 'Hello', now());
INSERT INTO `system_translations` VALUES (101, 'titInvoice', 'Rechnung', 'Invoice', now());
INSERT INTO `system_translations` VALUES (102, 'titInvoiceDate', 'Rechnungsdatum', 'Invoice date', now());
INSERT INTO `system_translations` VALUES (103, 'titInvoiceNumber', 'Rechnungsnummer', 'Invoice number', now());
INSERT INTO `system_translations` VALUES (104, 'titInvoices', 'Rechnungen', 'Invoices', now());
INSERT INTO `system_translations` VALUES (105, 'titInvoiceSettings', 'Rechnungseinstellungen', 'Invoice settings', now());
INSERT INTO `system_translations` VALUES (106, 'titLogo', 'Logo', 'Logo', now());
INSERT INTO `system_translations` VALUES (107, 'titMainCompany', 'Hauptfirma', 'Main company', now());
INSERT INTO `system_translations` VALUES (108, 'titMandanten', 'Mandanten', 'Tenants', now());
INSERT INTO `system_translations` VALUES (109, 'titModules', 'Module', 'Modules', now());
INSERT INTO `system_translations` VALUES (110, 'titMyCompany', 'Meine Firma', 'My company', now());
INSERT INTO `system_translations` VALUES (111, 'titMyPhoto', 'Mein Foto', 'My Photo', now());
INSERT INTO `system_translations` VALUES (112, 'titNewUser', 'Erfassen Sie hier einen neuen Benutzer', 'Create a new user here', now());
INSERT INTO `system_translations` VALUES (113, 'titPaymentStatus', 'Zahlstatus', 'Payment status', now());
INSERT INTO `system_translations` VALUES (114, 'titPhoto', 'Foto', 'Photo', now());
INSERT INTO `system_translations` VALUES (115, 'titPos', 'Pos.', 'Pos.', now());
INSERT INTO `system_translations` VALUES (116, 'titQuantity', 'Menge', 'Quantity', now());
INSERT INTO `system_translations` VALUES (117, 'titResetPassword', 'Passwort zurücksetzen', 'Reset password', now());
INSERT INTO `system_translations` VALUES (118, 'titSinglePrice', 'Einzelpreis', 'Single price', now());
INSERT INTO `system_translations` VALUES (119, 'titTenantOverview', 'Mandantenübersicht', 'Tenant overview', now());
INSERT INTO `system_translations` VALUES (120, 'titTitle', 'Titel', 'Title', now());
INSERT INTO `system_translations` VALUES (121, 'titTotal', 'Total', 'Total', now());
INSERT INTO `system_translations` VALUES (122, 'titTotalAmount', 'Totalbetrag', 'Total amount', now());
INSERT INTO `system_translations` VALUES (123, 'titUser', 'Benutzer', 'User', now());
INSERT INTO `system_translations` VALUES (124, 'titUserOverview', 'Benutzerübersicht', 'User overview', now());
INSERT INTO `system_translations` VALUES (125, 'txtAccountSettings', 'Kontoeinstellungen', 'Account settings', now());
INSERT INTO `system_translations` VALUES (126, 'txtActivateThisUser', 'Diesen Benutzer aktivieren', 'Activate this user', now());
INSERT INTO `system_translations` VALUES (127, 'txtAddOrEditModules', 'Bestellen Sie neue Module oder bearbeiten Sie bestehende', 'Order new modules or edit existing ones', now());
INSERT INTO `system_translations` VALUES (128, 'txtAddOrEditTenants', 'Erfassen oder bearbeiten Sie Mandanten', 'Add or edit tenants', now());
INSERT INTO `system_translations` VALUES (129, 'txtAddOrEditUser', 'Erfassen oder bearbeiten Sie Benutzer', 'Add or edit users', now());
INSERT INTO `system_translations` VALUES (130, 'txtClickOrDragDropImage', 'Klicken oder Logo hierher ziehen', 'Click or drag the logo here', now());
INSERT INTO `system_translations` VALUES (131, 'txtClickOrDragDropImageToReplace', 'Klicken oder Logo hierher ziehen, um das Logo zu ersetzen', 'Click or drag logo here to replace the logo', now());
INSERT INTO `system_translations` VALUES (132, 'txtDeleteLogo', 'Logo löschen', 'Delete logo', now());
INSERT INTO `system_translations` VALUES (133, 'txtDeletePhoto', 'Foto löschen', 'Delete photo', now());
INSERT INTO `system_translations` VALUES (134, 'txtDeleteTenantConfirmText', 'Vorsicht, Sie sind im Begriff, einen Mandanten zu löschen. Wenn Sie fortfahren, werden sämtliche Daten dieses Mandaten unwiderruflich gelöscht! Möchten Sie fortfahren?', 'Caution, you are about to delete a tenant. If you continue, all data of this tenant will be irrevocably deleted! Do you want to continue?', now());
INSERT INTO `system_translations` VALUES (135, 'txtDeleteUserConfirmText', 'Sind Sie ganz sicher, dass Sie diesen Benutzer löschen möchten? Dieser Vorgang kann nicht rückgängig gemacht werden!', 'Are you sure you want to delete this user? This operation cannot be undone!', now());
INSERT INTO `system_translations` VALUES (136, 'txtDueDate', 'Zahlbar bis', 'Due date', now());
INSERT INTO `system_translations` VALUES (137, 'txtEditProfile', 'Profil bearbeiten', 'Edit Profile', now());
INSERT INTO `system_translations` VALUES (138, 'txtEditYourProfile', 'Hier können Sie Ihr eigenes Profil bearbeiten', 'Here you can edit your own profile', now());
INSERT INTO `system_translations` VALUES (139, 'txtExemptTax', 'Betrag von Steuer befreit', 'Amount exempted from tax', now());
INSERT INTO `system_translations` VALUES (140, 'txtInvitationFrom', 'Einladung von', 'Invitation from', now());
INSERT INTO `system_translations` VALUES (141, 'txtInvitationMail', 'Sie wurden von @sender_name@ als Benutzer von @project_name@ registriert. Bitte folgen Sie diesem Link, um die Registrierung abzuschliessen: ', 'You have been added by @sender_name@ as a user of @project_name@. Please follow this link to complete the registration: ', now());
INSERT INTO `system_translations` VALUES (142, 'txtLogout', 'Logout', 'Logout', now());
INSERT INTO `system_translations` VALUES (143, 'txtMyCompanyDescription', 'Bearbeiten Sie Ihre Firmenangaben, Ihr Logo und Ihre Rechnungseinstellungen', 'Edit your company details, logo and invoice settings', now());
INSERT INTO `system_translations` VALUES (144, 'txtMyProfile', 'Mein Profil', 'My profile', now());
INSERT INTO `system_translations` VALUES (145, 'txtNewTenant', 'Erfassen Sie hier einen neuen Mandanten', 'Create a new tenant here', now());
INSERT INTO `system_translations` VALUES (146, 'txtPayInvoice', 'Rechnug bezahlen', 'Pay invoice', now());
INSERT INTO `system_translations` VALUES (147, 'txtPleaseConfirmEmail', 'Vielen Dank für Ihre Registrierung. Um Ihren Account zu erstellen, bestätigen Sie bitte Ihre E-Mail-Adresse, indem Sie auf diesen Link klicken:', 'Thank you for registering. To create your account, please confirm your email address by clicking on this link:', now());
INSERT INTO `system_translations` VALUES (148, 'txtPlusVat', 'Zzgl. MwSt.', 'Plus VAT.', now());
INSERT INTO `system_translations` VALUES (149, 'txtPrint', 'Drucken', 'Print', now());
INSERT INTO `system_translations` VALUES (150, 'txtPrintInvoice', 'Rechnung drucken', 'Print invoice', now());
INSERT INTO `system_translations` VALUES (151, 'txtProfile', 'Profil', 'Profile', now());
INSERT INTO `system_translations` VALUES (152, 'txtRegards', 'Mit freundlichem Gruss', 'Best regards', now());
INSERT INTO `system_translations` VALUES (153, 'txtRegisterLinkNotWorking', 'Falls der Link mit Klick nicht funktioniert, kopieren Sie ihn bitte komplett in die Adresszeile Ihres Browsers.', 'If the link does not work with a click, please copy it completely into the address line of your browser.', now());
INSERT INTO `system_translations` VALUES (154, 'txtRemoveLogo', 'Logo entfernen', 'Remove logo', now());
INSERT INTO `system_translations` VALUES (155, 'txtResetOwnPassword', 'Setzen Sie bei Bedarf Ihr eigenes Passwort zurück', 'Reset your own password if necessary', now());
INSERT INTO `system_translations` VALUES (156, 'txtResetPassword', 'Um Ihr Passwort zurückzusetzen, klicken Sie bitte auf den folgenden Link:', 'To reset your password, please click on the following link:', now());
INSERT INTO `system_translations` VALUES (157, 'txtSettings', 'Einstellungen', 'Settings', now());
INSERT INTO `system_translations` VALUES (158, 'txtSetUserAsAdmin', 'Diesen Benutzer als Admin festlegen', 'Set this user as admin', now());
INSERT INTO `system_translations` VALUES (159, 'txtTotalExcl', 'Betrag exkl. Steuer', 'Amount excl. tax', now());
INSERT INTO `system_translations` VALUES (160, 'txtTotalIncl', 'Betrag inkl. Steuer', 'Amount incl. tax', now());
INSERT INTO `system_translations` VALUES (161, 'txtVatIncluded', 'Im Preis enthaltene Steuer', 'Tax included in the price', now());
INSERT INTO `system_translations` VALUES (162, 'txtView', 'Anzeigen', 'View', now());
INSERT INTO `system_translations` VALUES (163, 'txtViewInvoice', 'Rechnung anzeigen', 'View invoice', now());
INSERT INTO `system_translations` VALUES (164, 'txtViewInvoices', 'Sehen Sie Ihre Rechnungen ein und verwalten Sie Ihre Zahlungseinstellungen', 'View your invoices and manage your payment settings', now());
INSERT INTO `system_translations` VALUES (165, 'txtWhichTenants', 'Auf welche Mandanten hat der Benutzer Zugriff?', 'Which tenants does the user have access to?', now());
INSERT INTO `system_translations` VALUES (166, 'txtYourTeam', 'Ihr Team vom Kundendienst', 'Your Customer Service Team', now());
INSERT INTO `system_translations` VALUES (167, 'btnDeleteInvoice', 'Rechnung löschen', 'Delete invoice', now());
INSERT INTO `system_translations` VALUES (168, 'txtDeleteInvoiceConfirmText', 'Möchten Sie diese Rechnung endgültig löschen?', 'Do you want to delete this invoice permanently?', now());
INSERT INTO `system_translations` VALUES (169, 'msgInvoiceDeleted', 'Die Rechnung wurde erfolgreich gelöscht.', 'The invoice has been deleted successfully.', now());
INSERT INTO `system_translations` VALUES (170, 'formLanguage', 'Sprache', 'Language', now());
INSERT INTO `system_translations` VALUES (171, 'btnEditUser', 'Benutzer editieren', 'Edit user', now());
INSERT INTO `system_translations` VALUES (172, 'titEditUser', 'Editieren Sie hier den bestehenden Benutzer', 'Edit the existing user here', now());
INSERT INTO `system_translations` VALUES (173, 'txtOnRequest', 'Auf Anfrage', 'On request', now());
INSERT INTO `system_translations` VALUES (174, 'txtFree', 'Gratis', 'Free', now());
INSERT INTO `system_translations` VALUES (175, 'txtMonthly', 'Monatlich', 'Monthly', now());
INSERT INTO `system_translations` VALUES (176, 'txtYearly', 'Jährlich', 'Yearly', now());


-- ----------------------------
-- Table structure for user_widgets
-- ----------------------------
DROP TABLE IF EXISTS `user_widgets`;
CREATE TABLE `user_widgets`  (
  `intUserWidgetID` int(11) NOT NULL AUTO_INCREMENT,
  `intWidgetID` int(11) NOT NULL,
  `intUserID` int(11) NOT NULL,
  `intPrio` int(11) NOT NULL,
  PRIMARY KEY (`intUserWidgetID`) USING BTREE,
  INDEX `_intUserID`(`intUserID`) USING BTREE,
  INDEX `_intWidgetID`(`intWidgetID`) USING BTREE,
  CONSTRAINT `frn_uw_user` FOREIGN KEY (`intUserID`) REFERENCES `users` (`intUserID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `frn_uw_widgets` FOREIGN KEY (`intWidgetID`) REFERENCES `widgets` (`intWidgetID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `intUserID` int(11) NOT NULL AUTO_INCREMENT,
  `intCustomerID` int(11) NOT NULL,
  `dtmInsertDate` datetime NOT NULL,
  `dtmMutDate` datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP,
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
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intUserID`) USING BTREE,
  UNIQUE INDEX `_intUserID`(`intUserID`) USING BTREE,
  INDEX `_intCustomerID`(`intCustomerID`) USING BTREE,
  CONSTRAINT `frn_user_customer` FOREIGN KEY (`intCustomerID`) REFERENCES `customers` (`intCustomerID`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Table structure for widget_ratio
-- ----------------------------
DROP TABLE IF EXISTS `widget_ratio`;
CREATE TABLE `widget_ratio`  (
  `intRatioID` int(11) NOT NULL AUTO_INCREMENT,
  `intSizeRatio` int(3) NOT NULL,
  `strDescription` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`intRatioID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

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
  PRIMARY KEY (`intWidgetID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;


-- ----------------------------
-- Function structure for func beautify
-- ----------------------------
DROP FUNCTION IF EXISTS `beautify`;
delimiter ;;
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
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(


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

/* Closing */

'--', '-'),
'---', '-'),
'----', '-')
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table customers
-- ----------------------------
DROP TRIGGER IF EXISTS `insertSettings`;
delimiter ;;
CREATE TRIGGER `insertSettings` AFTER INSERT ON `customers` FOR EACH ROW INSERT INTO customer_system_settings (intCustomerID, intSystSettingID, strSettingValue)
SELECT NEW.intCustomerID, intSystSettingID, strDefaultValue
FROM system_settings
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table customers
-- ----------------------------
DROP TRIGGER IF EXISTS `insertCustomSettings`;
delimiter ;;
CREATE TRIGGER `insertCustomSettings` AFTER INSERT ON `customers` FOR EACH ROW INSERT INTO customer_custom_settings (intCustomerID, intCustomSettingID, strSettingValue)
SELECT NEW.intCustomerID, intCustomSettingID, strDefaultValue
FROM custom_settings
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table customers
-- ----------------------------
DROP TRIGGER IF EXISTS `deleteSettings`;
delimiter ;;
CREATE TRIGGER `deleteSettings` BEFORE DELETE ON `customers` FOR EACH ROW DELETE FROM customer_system_settings
WHERE intCustomerID = OLD.intCustomerID
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table customers
-- ----------------------------
DROP TRIGGER IF EXISTS `deleteCustomSettings`;
delimiter ;;
CREATE TRIGGER `deleteCustomSettings` BEFORE DELETE ON `customers` FOR EACH ROW DELETE FROM customer_custom_settings
WHERE intCustomerID = OLD.intCustomerID
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table users
-- ----------------------------
DROP TRIGGER IF EXISTS `insertConnect`;
delimiter ;;
CREATE TRIGGER `insertConnect` AFTER INSERT ON `users` FOR EACH ROW INSERT INTO customer_user (intCustomerID, intUserID, blnStandard)
VALUES (NEW.intCustomerID, NEW.intUserID, 1)
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
