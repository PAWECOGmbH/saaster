-- Demo customers for development: companies in different situations, with users, bookings,
-- invoices, payments, payment methods, tenants and notifications.
--
-- Every demo user logs in with the password  Saaster-Demo-2026!
-- (main users are super admins; e-mail addresses use the reserved top-level domain .example)
--
--   1001 Alpine Bakery AG (CH, CHF, de)      Standard monthly + Easy ERP monthly, payment method,
--                                             invoices paid and open, CHF with 8.1% VAT
--   1002 Nordwind Logistik GmbH (DE, EUR, de) Advanced yearly, MailChimp in its test phase,
--                                             one invoice paid, one partly paid
--   1003 Bright Pixel Ltd (GB, USD, en)       Standard monthly waiting for payment, overdue invoice
--   1004 Green Garden Studio (US, USD, en)    Free plan and the free Todo module
--   1005 Summit Consulting GmbH (CH, de)      Standard in its test phase, no payment method
--   1006 Old Harbor Trading Inc (US, en)      Advanced and Easy ERP canceled, running until their end date
--   1007 Cedar & Co KG (AT, EUR, de)          Standard expired, a canceled and a draft invoice
--   1008 Riverside Media GmbH (DE, en/de)     Advanced yearly with a waiting downgrade to Standard,
--                                             Easy ERP yearly, an inactive user
--   1009 Lakeside Labs SA (FR, EUR, en)       Enterprise yearly with two tenants (1010 Paris, 1011 Berlin)
--   1012 Dormant Ventures (US, en)            inactive customer without bookings
--
-- Data only - the tables come from the migrations (config/db/core). Run it after
-- create-plans.sql and create-modules.sql (it books their plans 1-4 and modules 1-3).
-- Dates are relative to the day of the import, so the bookings are always current.
-- Running it again replaces customers 1001-1099 and everything that belongs to them
-- (users, bookings, invoices, payments, notifications - ON DELETE CASCADE).
--
-- Import (see readme.md): cat ./config/db/dev/create-customers.sql | docker exec -i <mysql container> mysql -u <user> -p<password> <database>

SET NAMES utf8mb4;

SET @today = CURDATE();
SET @now = UTC_TIMESTAMP();
-- Argon2id hash of "Saaster-Demo-2026!" (global.cfc::hashPassword)
SET @password = '$argon2id$v=19$m=19456,t=2,p=1$4cmXB3REA9udGAnL0X4Dsw$7nb6tEL7bSvnJwNr02mnCIPQ12IIy7we/iHrF4g5MQo';

-- Sub-tenants first, then their parents and the rest
DELETE FROM customers WHERE intCustomerID BETWEEN 1001 AND 1099 AND intCustParentID > 0;
DELETE FROM customers WHERE intCustomerID BETWEEN 1001 AND 1099;


-- ---------------------------------------------------------------------------
-- Customers (countries and timezones from the migrations: CH 149, DE 218, AT 130,
-- GB 147, US 163, FR 209 / Europe/Berlin 32, Europe/London 30, Europe/Paris 33,
-- America/New_York 14, America/Los_Angeles 4)
-- ---------------------------------------------------------------------------
INSERT INTO customers (intCustomerID, intCustParentID, dtmInsertDate, dtmMutDate, blnActive, strCompanyName, strContactPerson, strAddress, strZIP, strCity, intCountryID, intTimezoneID, strPhone, strEmail, strWebsite, strBillingAccountName, strBillingEmail, strBillingAddress) VALUES
(1001, 0, DATE_SUB(@now, INTERVAL 400 DAY), @now, 1, 'Alpine Bakery AG', 'Anna Meier', 'Bahnhofstrasse 12', '8001', 'Zürich', 149, 32, '+41 44 123 45 67', 'info@alpine-bakery.example', 'https://alpine-bakery.example', 'Alpine Bakery AG, Buchhaltung', 'billing@alpine-bakery.example', 'Postfach 120\r\n8021 Zürich'),
(1002, 0, DATE_SUB(@now, INTERVAL 300 DAY), @now, 1, 'Nordwind Logistik GmbH', 'Jonas Becker', 'Speicherstadt 4', '20457', 'Hamburg', 218, 32, '+49 40 555 01 23', 'kontakt@nordwind.example', 'https://nordwind.example', NULL, NULL, NULL),
(1003, 0, DATE_SUB(@now, INTERVAL 45 DAY), @now, 1, 'Bright Pixel Ltd', 'Oliver Smith', '221 Camden High Street', 'NW1 7BU', 'London', 147, 30, '+44 20 7946 0123', 'hello@brightpixel.example', 'https://brightpixel.example', NULL, NULL, NULL),
(1004, 0, DATE_SUB(@now, INTERVAL 60 DAY), @now, 1, 'Green Garden Studio', 'Emma Johnson', '815 SE Hawthorne Blvd', '97214', 'Portland', 163, 4, '+1 503 555 0188', 'studio@greengarden.example', NULL, NULL, NULL, NULL),
(1005, 0, DATE_SUB(@now, INTERVAL 20 DAY), @now, 1, 'Summit Consulting GmbH', 'Noah Brunner', 'Marktgasse 30', '3011', 'Bern', 149, 32, '+41 31 555 22 11', 'office@summit-consulting.example', NULL, NULL, NULL, NULL),
(1006, 0, DATE_SUB(@now, INTERVAL 200 DAY), @now, 1, 'Old Harbor Trading Inc', 'Liam Brown', '1 Long Wharf', '02110', 'Boston', 163, 14, '+1 617 555 0145', 'trade@oldharbor.example', NULL, NULL, NULL, NULL),
(1007, 0, DATE_SUB(@now, INTERVAL 120 DAY), @now, 1, 'Cedar & Co KG', 'Lena Gruber', 'Mariahilfer Strasse 77', '1060', 'Wien', 130, 32, '+43 1 555 34 56', 'office@cedar-co.example', NULL, NULL, NULL, NULL),
(1008, 0, DATE_SUB(@now, INTERVAL 220 DAY), @now, 1, 'Riverside Media GmbH', 'Felix Wagner', 'Rheinufer 9', '50668', 'Köln', 218, 32, '+49 221 555 78 90', 'team@riverside-media.example', 'https://riverside-media.example', NULL, NULL, NULL),
(1009, 0, DATE_SUB(@now, INTERVAL 40 DAY), @now, 1, 'Lakeside Labs SA', 'Chloé Martin', '12 Quai Saint-Antoine', '69002', 'Lyon', 209, 33, '+33 4 55 55 01 01', 'contact@lakeside-labs.example', 'https://lakeside-labs.example', 'Lakeside Labs SA - Comptabilité', 'compta@lakeside-labs.example', '12 Quai Saint-Antoine\r\n69002 Lyon'),
(1010, 1009, DATE_SUB(@now, INTERVAL 35 DAY), @now, 1, 'Lakeside Labs Paris', 'Paul Dubois', '48 Rue de Rivoli', '75004', 'Paris', 209, 33, NULL, 'paris@lakeside-labs.example', NULL, NULL, NULL, NULL),
(1011, 1009, DATE_SUB(@now, INTERVAL 30 DAY), @now, 1, 'Lakeside Labs Berlin', 'Marie Lefèvre', 'Torstrasse 101', '10119', 'Berlin', 218, 32, NULL, 'berlin@lakeside-labs.example', NULL, NULL, NULL, NULL),
(1012, 0, DATE_SUB(@now, INTERVAL 500 DAY), @now, 0, 'Dormant Ventures', 'Grace Miller', '400 Market Street', '19106', 'Philadelphia', 163, 14, NULL, 'grace@dormant.example', NULL, NULL, NULL, NULL);


-- ---------------------------------------------------------------------------
-- Users. The trigger insertConnect links every user to its own customer as standard tenant.
-- ---------------------------------------------------------------------------
INSERT INTO users (intUserID, intCustomerID, dtmInsertDate, dtmMutDate, strSalutation, strFirstName, strLastName, strEmail, strPasswordHash, strPasswordSalt, strPhone, strLanguage, blnActive, dtmLastLogin, blnAdmin, blnSuperAdmin, blnSysAdmin) VALUES
(1001, 1001, DATE_SUB(@now, INTERVAL 400 DAY), @now, 'Frau', 'Anna', 'Meier', 'anna.meier@alpine-bakery.example', @password, '', '+41 79 555 10 01', 'de', 1, DATE_SUB(@now, INTERVAL 1 DAY), 1, 1, 0),
(1002, 1001, DATE_SUB(@now, INTERVAL 300 DAY), @now, 'Herr', 'Lukas', 'Huber', 'lukas.huber@alpine-bakery.example', @password, '', NULL, 'de', 1, DATE_SUB(@now, INTERVAL 3 DAY), 1, 0, 0),
(1003, 1001, DATE_SUB(@now, INTERVAL 100 DAY), @now, 'Frau', 'Sara', 'Keller', 'sara.keller@alpine-bakery.example', @password, '', NULL, 'de', 1, DATE_SUB(@now, INTERVAL 10 DAY), 0, 0, 0),
(1004, 1002, DATE_SUB(@now, INTERVAL 300 DAY), @now, 'Herr', 'Jonas', 'Becker', 'jonas.becker@nordwind.example', @password, '', '+49 171 555 20 02', 'de', 1, DATE_SUB(@now, INTERVAL 2 DAY), 1, 1, 0),
(1005, 1002, DATE_SUB(@now, INTERVAL 150 DAY), @now, 'Ms', 'Mia', 'Schulz', 'mia.schulz@nordwind.example', @password, '', NULL, 'en', 1, DATE_SUB(@now, INTERVAL 5 DAY), 1, 0, 0),
(1006, 1003, DATE_SUB(@now, INTERVAL 45 DAY), @now, 'Mr', 'Oliver', 'Smith', 'oliver.smith@brightpixel.example', @password, '', '+44 7700 900123', 'en', 1, DATE_SUB(@now, INTERVAL 4 DAY), 1, 1, 0),
(1007, 1004, DATE_SUB(@now, INTERVAL 60 DAY), @now, 'Ms', 'Emma', 'Johnson', 'emma.johnson@greengarden.example', @password, '', NULL, 'en', 1, DATE_SUB(@now, INTERVAL 20 DAY), 1, 1, 0),
(1008, 1005, DATE_SUB(@now, INTERVAL 20 DAY), @now, 'Herr', 'Noah', 'Brunner', 'noah.brunner@summit-consulting.example', @password, '', NULL, 'de', 1, @now, 1, 1, 0),
(1009, 1006, DATE_SUB(@now, INTERVAL 200 DAY), @now, 'Mr', 'Liam', 'Brown', 'liam.brown@oldharbor.example', @password, '', NULL, 'en', 1, DATE_SUB(@now, INTERVAL 7 DAY), 1, 1, 0),
(1010, 1007, DATE_SUB(@now, INTERVAL 120 DAY), @now, 'Frau', 'Lena', 'Gruber', 'lena.gruber@cedar-co.example', @password, '', NULL, 'de', 1, DATE_SUB(@now, INTERVAL 16 DAY), 1, 1, 0),
(1011, 1008, DATE_SUB(@now, INTERVAL 220 DAY), @now, 'Mr', 'Felix', 'Wagner', 'felix.wagner@riverside-media.example', @password, '', NULL, 'en', 1, DATE_SUB(@now, INTERVAL 1 DAY), 1, 1, 0),
(1012, 1008, DATE_SUB(@now, INTERVAL 180 DAY), @now, 'Frau', 'Clara', 'Hoffmann', 'clara.hoffmann@riverside-media.example', @password, '', NULL, 'de', 0, DATE_SUB(@now, INTERVAL 90 DAY), 0, 0, 0),
(1013, 1009, DATE_SUB(@now, INTERVAL 40 DAY), @now, 'Mme', 'Chloé', 'Martin', 'chloe.martin@lakeside-labs.example', @password, '', '+33 6 55 55 01 02', 'en', 1, @now, 1, 1, 0),
(1014, 1009, DATE_SUB(@now, INTERVAL 38 DAY), @now, 'M.', 'Hugo', 'Bernard', 'hugo.bernard@lakeside-labs.example', @password, '', NULL, 'en', 1, DATE_SUB(@now, INTERVAL 2 DAY), 1, 0, 0),
(1015, 1010, DATE_SUB(@now, INTERVAL 35 DAY), @now, 'M.', 'Paul', 'Dubois', 'paul.dubois@lakeside-labs.example', @password, '', NULL, 'en', 1, DATE_SUB(@now, INTERVAL 6 DAY), 0, 0, 0),
(1016, 1012, DATE_SUB(@now, INTERVAL 500 DAY), @now, 'Ms', 'Grace', 'Miller', 'grace.miller@dormant.example', @password, '', NULL, 'en', 1, DATE_SUB(@now, INTERVAL 400 DAY), 1, 1, 0);

-- Access to further tenants (the own customer is linked by the trigger)
INSERT INTO customer_user (intCustomerID, intUserID, blnStandard) VALUES
(1010, 1013, 0),
(1011, 1013, 0),
(1010, 1014, 0);


-- ---------------------------------------------------------------------------
-- Bookings (plans 1 Free, 2 Standard, 3 Advanced, 4 Enterprise / modules 1 Todo, 2 Easy ERP, 3 MailChimp)
-- ---------------------------------------------------------------------------
INSERT INTO bookings (intBookingID, intCustomerID, intPlanID, intModuleID, dteStartDate, dteEndDate, strRecurring, strStatus) VALUES
(1001, 1001, 2, NULL, DATE_SUB(@today, INTERVAL 10 DAY), DATE_ADD(@today, INTERVAL 20 DAY), 'monthly', 'active'),
(1002, 1001, NULL, 2, DATE_SUB(@today, INTERVAL 10 DAY), DATE_ADD(@today, INTERVAL 20 DAY), 'monthly', 'active'),
(1003, 1002, 3, NULL, DATE_SUB(@today, INTERVAL 100 DAY), DATE_ADD(@today, INTERVAL 265 DAY), 'yearly', 'active'),
(1004, 1002, NULL, 3, DATE_SUB(@today, INTERVAL 3 DAY), DATE_ADD(@today, INTERVAL 7 DAY), 'test', 'test'),
(1005, 1003, 2, NULL, DATE_SUB(@today, INTERVAL 2 DAY), DATE_ADD(@today, INTERVAL 28 DAY), 'monthly', 'payment'),
(1006, 1004, 1, NULL, DATE_SUB(@today, INTERVAL 60 DAY), '3000-01-01', 'onetime', 'free'),
(1007, 1004, NULL, 1, DATE_SUB(@today, INTERVAL 55 DAY), '3000-01-01', 'onetime', 'free'),
(1008, 1005, 2, NULL, DATE_SUB(@today, INTERVAL 20 DAY), DATE_ADD(@today, INTERVAL 10 DAY), 'test', 'test'),
(1009, 1006, 3, NULL, DATE_SUB(@today, INTERVAL 23 DAY), DATE_ADD(@today, INTERVAL 7 DAY), 'monthly', 'canceled'),
(1010, 1006, NULL, 2, DATE_SUB(@today, INTERVAL 23 DAY), DATE_ADD(@today, INTERVAL 7 DAY), 'monthly', 'canceled'),
(1011, 1007, 2, NULL, DATE_SUB(@today, INTERVAL 45 DAY), DATE_SUB(@today, INTERVAL 15 DAY), 'monthly', 'expired'),
(1012, 1008, 3, NULL, DATE_SUB(@today, INTERVAL 200 DAY), DATE_ADD(@today, INTERVAL 165 DAY), 'yearly', 'active'),
(1013, 1008, 2, NULL, DATE_ADD(@today, INTERVAL 166 DAY), DATE_ADD(@today, INTERVAL 195 DAY), 'monthly', 'waiting'),
(1014, 1008, NULL, 2, DATE_SUB(@today, INTERVAL 200 DAY), DATE_ADD(@today, INTERVAL 165 DAY), 'yearly', 'active'),
(1015, 1009, 4, NULL, DATE_SUB(@today, INTERVAL 30 DAY), DATE_ADD(@today, INTERVAL 335 DAY), 'yearly', 'active');


-- ---------------------------------------------------------------------------
-- Payment methods (authorized Payrexx tokens - fake IDs, they never reach Payrexx)
-- ---------------------------------------------------------------------------
INSERT INTO payrexx (intCustomerID, dtmTimeUTC, intGatewayID, intTransactionID, strStatus, strPaymentBrand, strCardNumber, blnDefault, blnFailed) VALUES
(1001, DATE_SUB(@now, INTERVAL 40 DAY), 910010001, 920010001, 'authorized', 'mastercard', '5555', 1, 0),
(1002, DATE_SUB(@now, INTERVAL 100 DAY), 910020001, 920020001, 'authorized', 'visa', '4242', 1, 0),
(1008, DATE_SUB(@now, INTERVAL 200 DAY), 910080001, 920080001, 'authorized', 'visa', '1881', 1, 0),
(1009, DATE_SUB(@now, INTERVAL 30 DAY), 910090001, 920090001, 'authorized', 'american_express', '0005', 1, 0);


-- ---------------------------------------------------------------------------
-- Invoices (status: 1 draft, 2 open, 3 paid, 4 partly paid, 5 canceled, 6 overdue).
-- Numbers 1101-1199; the invoice language follows the customer's main user.
-- ---------------------------------------------------------------------------
INSERT INTO invoices (intInvoiceID, intCustomerID, intUserID, intInvoiceNumber, strPrefix, strInvoiceTitle, dtmInvoiceDate, dtmDueDate, strCurrency, blnIsNet, intVatType, decSubTotalPrice, decTotalPrice, strTotalText, intPaymentStatusID, strLanguageISO, intBookingID, strUUID) VALUES
-- Alpine Bakery: CHF net plus 8.1% VAT
(1001, 1001, NULL, 1101, 'INV-', 'Plan: Standard', DATE_SUB(@now, INTERVAL 40 DAY), DATE_SUB(@now, INTERVAL 10 DAY), 'CHF', 1, 1, 89.00, 96.21, 'Betrag inkl. Steuer', 3, 'de', 1001, NULL),
(1002, 1001, NULL, 1102, 'INV-', 'Plan: Standard', DATE_SUB(@now, INTERVAL 10 DAY), DATE_ADD(@now, INTERVAL 20 DAY), 'CHF', 1, 1, 89.00, 96.21, 'Betrag inkl. Steuer', 2, 'de', 1001, NULL),
(1003, 1001, NULL, 1103, 'INV-', 'Modul: Easy ERP', DATE_SUB(@now, INTERVAL 10 DAY), DATE_SUB(@now, INTERVAL 10 DAY), 'CHF', 0, 3, 29.00, 29.00, 'Betrag von Steuer befreit', 3, 'de', 1002, NULL),
-- Nordwind: paid yearly plan, partly paid service invoice
(1004, 1002, NULL, 1104, 'INV-', 'Plan: Advanced', DATE_SUB(@now, INTERVAL 100 DAY), DATE_SUB(@now, INTERVAL 70 DAY), 'EUR', 0, 3, 1100.00, 1100.00, 'Betrag von Steuer befreit', 3, 'de', 1003, NULL),
(1005, 1002, 1005, 1105, 'INV-', 'Onboarding workshop', DATE_SUB(@now, INTERVAL 25 DAY), DATE_ADD(@now, INTERVAL 5 DAY), 'EUR', 0, 3, 600.00, 600.00, 'Amount exempted from tax', 4, 'en', NULL, NULL),
-- Bright Pixel: overdue
(1006, 1003, NULL, 1106, 'INV-', 'Plan: Standard', DATE_SUB(@now, INTERVAL 32 DAY), DATE_SUB(@now, INTERVAL 2 DAY), 'USD', 0, 3, 89.00, 89.00, 'Amount exempted from tax', 6, 'en', 1005, NULL),
-- Old Harbor: paid, now canceled
(1007, 1006, NULL, 1107, 'INV-', 'Plan: Advanced', DATE_SUB(@now, INTERVAL 23 DAY), DATE_ADD(@now, INTERVAL 7 DAY), 'USD', 0, 3, 158.00, 158.00, 'Amount exempted from tax', 3, 'en', 1009, NULL),
-- Cedar & Co: canceled and draft
(1008, 1007, NULL, 1108, 'INV-', 'Plan: Standard', DATE_SUB(@now, INTERVAL 45 DAY), DATE_SUB(@now, INTERVAL 15 DAY), 'EUR', 0, 3, 89.00, 89.00, 'Betrag von Steuer befreit', 5, 'de', 1011, NULL),
(1009, 1007, NULL, 1109, 'INV-', 'Beratung Datenimport', DATE_SUB(@now, INTERVAL 1 DAY), DATE_ADD(@now, INTERVAL 29 DAY), 'EUR', 0, 3, 450.00, 450.00, 'Betrag von Steuer befreit', 1, 'de', NULL, NULL),
-- Riverside: yearly plan and module, paid
(1010, 1008, NULL, 1110, 'INV-', 'Plan: Advanced', DATE_SUB(@now, INTERVAL 200 DAY), DATE_SUB(@now, INTERVAL 170 DAY), 'EUR', 0, 3, 1390.00, 1390.00, 'Amount exempted from tax', 3, 'en', 1012, NULL),
-- Lakeside Labs: Enterprise, open
(1011, 1009, NULL, 1111, 'INV-', 'Plan: Enterprise', DATE_SUB(@now, INTERVAL 30 DAY), DATE_ADD(@now, INTERVAL 0 DAY), 'EUR', 0, 3, 2500.00, 2500.00, 'Amount exempted from tax', 2, 'en', 1015, NULL);

INSERT INTO invoice_positions (intInvoiceID, intPosNumber, strTitle, strDescription, decSinglePrice, decQuantity, strUnit, intDiscountPercent, decTotalPrice, decVat) VALUES
(1001, 1, CONCAT('Standard ', DATE_FORMAT(DATE_SUB(@today, INTERVAL 40 DAY), '%d.%m.%Y'), ' - ', DATE_FORMAT(DATE_SUB(@today, INTERVAL 11 DAY), '%d.%m.%Y')), 'Bis zu 10 Benutzer', 89.00, 1, 'Monat', 0, 89.00, 8.10),
(1002, 1, CONCAT('Standard ', DATE_FORMAT(DATE_SUB(@today, INTERVAL 10 DAY), '%d.%m.%Y'), ' - ', DATE_FORMAT(DATE_ADD(@today, INTERVAL 20 DAY), '%d.%m.%Y')), 'Bis zu 10 Benutzer', 89.00, 1, 'Monat', 0, 89.00, 8.10),
(1003, 1, CONCAT('Easy ERP ', DATE_FORMAT(DATE_SUB(@today, INTERVAL 10 DAY), '%d.%m.%Y'), ' - ', DATE_FORMAT(DATE_ADD(@today, INTERVAL 20 DAY), '%d.%m.%Y')), 'Kontakte verwalten', 29.00, 1, 'Monat', 0, 29.00, 0.00),
(1004, 1, CONCAT('Advanced ', DATE_FORMAT(DATE_SUB(@today, INTERVAL 100 DAY), '%d.%m.%Y'), ' - ', DATE_FORMAT(DATE_ADD(@today, INTERVAL 265 DAY), '%d.%m.%Y')), 'Bis zu 30 Benutzer', 1100.00, 1, 'Jahr', 0, 1100.00, 0.00),
(1005, 1, 'Onboarding workshop', 'Remote session, half a day', 400.00, 1, 'Session', 0, 400.00, 0.00),
(1005, 2, 'Data migration', 'Import of existing customer data', 100.00, 2, 'Hour', 0, 200.00, 0.00),
(1006, 1, CONCAT('Standard ', DATE_FORMAT(DATE_SUB(@today, INTERVAL 32 DAY), '%m/%d/%Y'), ' - ', DATE_FORMAT(DATE_SUB(@today, INTERVAL 3 DAY), '%m/%d/%Y')), 'Up to 10 users', 89.00, 1, 'Month', 0, 89.00, 0.00),
(1007, 1, CONCAT('Advanced ', DATE_FORMAT(DATE_SUB(@today, INTERVAL 23 DAY), '%m/%d/%Y'), ' - ', DATE_FORMAT(DATE_ADD(@today, INTERVAL 7 DAY), '%m/%d/%Y')), 'Up to 30 users', 129.00, 1, 'Month', 0, 129.00, 0.00),
(1007, 2, 'Easy ERP', 'Manage your contacts', 29.00, 1, 'Month', 0, 29.00, 0.00),
(1008, 1, CONCAT('Standard ', DATE_FORMAT(DATE_SUB(@today, INTERVAL 45 DAY), '%d.%m.%Y'), ' - ', DATE_FORMAT(DATE_SUB(@today, INTERVAL 15 DAY), '%d.%m.%Y')), 'Bis zu 10 Benutzer', 89.00, 1, 'Monat', 0, 89.00, 0.00),
(1009, 1, 'Beratung Datenimport', 'Vorbereitung und Import der Stammdaten', 150.00, 3, 'Stunde', 0, 450.00, 0.00),
(1010, 1, CONCAT('Advanced ', DATE_FORMAT(DATE_SUB(@today, INTERVAL 200 DAY), '%m/%d/%Y'), ' - ', DATE_FORMAT(DATE_ADD(@today, INTERVAL 165 DAY), '%m/%d/%Y')), 'Up to 30 users', 1100.00, 1, 'Year', 0, 1100.00, 0.00),
(1010, 2, 'Easy ERP', 'Manage your contacts', 290.00, 1, 'Year', 0, 290.00, 0.00),
(1011, 1, CONCAT('Enterprise ', DATE_FORMAT(DATE_SUB(@today, INTERVAL 30 DAY), '%m/%d/%Y'), ' - ', DATE_FORMAT(DATE_ADD(@today, INTERVAL 335 DAY), '%m/%d/%Y')), 'Unlimited users, three locations', 2500.00, 1, 'Year', 0, 2500.00, 0.00);

-- VAT lines (only VAT type 1 has them): 8.1% of CHF 89.00
INSERT INTO invoice_vat (intInvoiceID, decVat, strVatText, decVatAmount) VALUES
(1001, 8.10, 'Zzgl. MwSt. 8.10%', 7.21),
(1002, 8.10, 'Zzgl. MwSt. 8.10%', 7.21);

INSERT INTO payments (intInvoiceID, intCustomerID, decAmount, dtmPayDate, strPaymentType, intPayrexxID) VALUES
(1001, 1001, 96.21, DATE_SUB(@now, INTERVAL 40 DAY), 'Mastercard', NULL),
(1003, 1001, 29.00, DATE_SUB(@now, INTERVAL 10 DAY), 'Mastercard', NULL),
(1004, 1002, 1100.00, DATE_SUB(@now, INTERVAL 99 DAY), 'Visa', NULL),
(1005, 1002, 250.00, DATE_SUB(@now, INTERVAL 12 DAY), 'Bank transfer', NULL),
(1007, 1006, 158.00, DATE_SUB(@now, INTERVAL 22 DAY), 'Bank transfer', NULL),
(1010, 1008, 1390.00, DATE_SUB(@now, INTERVAL 200 DAY), 'Visa', NULL);


-- ---------------------------------------------------------------------------
-- Notifications for some main users (unread and read)
-- ---------------------------------------------------------------------------
INSERT INTO notifications (intCustomerID, intUserID, dtmCreated, strTitleVar, strDescrVar, strLink, strLinkTextVar, dtmRead) VALUES
(1001, 1001, DATE_SUB(@now, INTERVAL 1 DAY), 'formInvoiceInfo', 'errSystemStoppedFixProblem', '/account-settings/invoices', 'btnActivate', NULL),
(1001, 1001, DATE_SUB(@now, INTERVAL 9 DAY), 'titModule', 'errSystemStoppedFixProblem', '/account-settings/modules', 'btnActivate', DATE_SUB(@now, INTERVAL 8 DAY)),
(1002, 1004, DATE_SUB(@now, INTERVAL 2 DAY), 'titModule', 'errSystemStoppedFixProblem', '/account-settings/modules', 'btnActivate', NULL),
(1003, 1006, DATE_SUB(@now, INTERVAL 1 DAY), 'formInvoiceInfo', 'errSystemStoppedFixProblem', '/account-settings/invoices', 'btnActivate', NULL),
(1005, 1008, @now, 'titStatus', 'errSystemStoppedFixProblem', '/account-settings/plans', 'btnActivate', NULL),
(1009, 1013, DATE_SUB(@now, INTERVAL 3 DAY), 'txtNetwork', 'errSystemStoppedFixProblem', '/account-settings/tenants', 'btnActivate', NULL);
