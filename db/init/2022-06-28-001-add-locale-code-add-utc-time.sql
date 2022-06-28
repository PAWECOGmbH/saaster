/*
 Navicat MySQL Data Transfer

 Source Server         : saaster
 Source Server Type    : MySQL
 Source Server Version : 50737
 Source Host           : localhost:3306
 Source Schema         : database

 Target Server Type    : MySQL
 Target Server Version : 50737
 File Encoding         : 65001

 Date: 28/06/2022 17:13:10
*/

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

SET FOREIGN_KEY_CHECKS = 1;
