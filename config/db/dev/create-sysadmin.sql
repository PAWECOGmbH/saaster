
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;


-- ----------------------------
-- Record of customer (sysadmin)
-- ----------------------------
TRUNCATE TABLE `customer_user`;
TRUNCATE TABLE `customers`;
INSERT INTO `customers` (
    intCustParentID,
    dtmInsertDate,
    dtmMutDate,
    blnActive,
    strCompanyName,
    strContactPerson,
    strAddress,
    strAddress2,
    strZIP,
    strCity,
    intCountryID,
    intTimezoneID,
    strPhone,
    strEmail,
    strWebsite,
    strLogo,
    strBillingAccountName,
    strBillingEmail,
    strBillingAddress,
    strBillingInfo
)
VALUES (0, UTC_TIMESTAMP(), UTC_TIMESTAMP(), 1, 'The SaaSter Company Ltd.', 'Peter Pan', 'Workingstreet 199', 'House 5b', '78000', 'Worksher', 0, 31, '041 555 55 55',
'admin@saaster.io', 'https://www.saaster.io', '', 'SaaSter Ldt.', 'office@saaster.io', 'Bookingstreet 100\r\n78010 Worksher 99', 'VAT 555-99-8785-99');

-- ----------------------------
-- Record of user (sysadmin)
-- ----------------------------
TRUNCATE TABLE `users`;
INSERT INTO `users` (
    intCustomerID,
    dtmInsertDate,
    dtmMutDate,
    strSalutation,
    strFirstName,
    strLastName,
    strEmail,
    strPasswordHash,
    strPasswordSalt,
    strPhone,
    strMobile,
    strPhoto,
    strLanguage,
    blnActive,
    dtmLastLogin,
    blnAdmin,
    blnSuperAdmin,
    blnSysAdmin,
    strUUID
)
VALUES (1, UTC_TIMESTAMP(), UTC_TIMESTAMP(), 'Mister', 'Peter', 'Pan', 'admin@saaster.io',
'ECB04C0076C620BA8DF6A0E6F042CA3B3BF9690B54BCC1655A820A189F0DB8DA5204005638723051A6BDBE372A7A83DFF9A82716576350A7700B628AA8B6A4F2',
'B11E536520093328FA2D05E105AA99F4B3A0790E5095286A94B2893084B570A0BE2BFF5856AC0A990FD53FC045B6844DC51CB37B7FA7CC9E9FF9E49D51B37770',
'041 555 55 60', '079 888 55 22', '', 'en', 1, NULL, 1, 1, 1, '');

SET FOREIGN_KEY_CHECKS = 1;