-- Demo modules for development: a free Todo app, Easy ERP (monthly/yearly, 30 test days)
-- and MailChimp API (one-time, 10 test days), with translations, prices and settings mappings.
--
-- Data only - the tables come from the migrations (config/db/core). Running it again
-- replaces modules 1-3 (their translations, prices, mappings, scheduletasks, widgets links
-- and bookings go with them through ON DELETE CASCADE).
--
-- Import (see readme.md): cat ./config/db/dev/create-modules.sql | docker exec -i <mysql container> mysql -u <user> -p<password> <database>

SET NAMES utf8mb4;

-- The migrations create USD, EUR and CHF, EUR and CHF inactive. The demo prices use all three.
UPDATE currencies SET blnActive = 1 WHERE strCurrencyISO IN ('USD', 'EUR', 'CHF');

DELETE FROM modules WHERE intModuleID BETWEEN 1 AND 3;

-- modules
INSERT INTO `modules` (`intModuleID`, `strModuleName`, `strShortDescription`, `strDescription`, `blnActive`, `strTabPrefix`, `strPicture`, `blnBookable`, `intNumTestDays`, `intDurationDays`, `strSettingPath`, `blnFree`, `strRedirectPath`, `intPrio`) VALUES (1, 'Free Todo list app', 'Let your tasks be done', '<p>With this small but powerful tool for task management, you always have all your tasks under control. Simply click on \"Activate\" and get started :-)<br></p>', 1, 'todo', '', 1, 0, 0, 'backend/modules/todo/settings', 1, '', 1);
INSERT INTO `modules` (`intModuleID`, `strModuleName`, `strShortDescription`, `strDescription`, `blnActive`, `strTabPrefix`, `strPicture`, `blnBookable`, `intNumTestDays`, `intDurationDays`, `strSettingPath`, `blnFree`, `strRedirectPath`, `intPrio`) VALUES (2, 'Easy ERP', 'Manage your contacts using Easy CRM', '<p>Manage your contacts easily with Easy ERP. Many features are included here, such as:<br><br>- Create and manage contacts<br>- Customer history<br>- Acquisition<br>- Appointment management<br>- and much more...<br></p>', 1, 'easyerp', '', 1, 30, 0, 'backend/modules/easyerp/settings', 0, '', 2);
INSERT INTO `modules` (`intModuleID`, `strModuleName`, `strShortDescription`, `strDescription`, `blnActive`, `strTabPrefix`, `strPicture`, `blnBookable`, `intNumTestDays`, `intDurationDays`, `strSettingPath`, `blnFree`, `strRedirectPath`, `intPrio`) VALUES (3, 'MailChimp API', 'Automatically transfer your customers to MailChimp', '<p>With the newsletter marketing tool MailChimp, you serve all your customers with a newsletter. Connect your account with MailChimp and let this module take care of the synchronisation.</p>', 1, 'mailchimp', '', 1, 10, 0, 'backend/modules/mailchimp/settings', 0, '', 3);

-- modules_trans
INSERT INTO `modules_trans` (`intModuleID`, `intLanguageID`, `strModuleName`, `strShortDescription`, `strDescription`) VALUES (1, 2, 'Gratis ToDo-Listen App', 'Erledige alle deine Aufgaben', '<p>Mit diesem kleinen, aber feinen Tool zur Aufgabenverwaltung haben Sie alle Ihre Aufgaben immer im Griff. Klicken Sie einfach auf \"Aktivieren\" und legen Sie los :-)<br></p>');
INSERT INTO `modules_trans` (`intModuleID`, `intLanguageID`, `strModuleName`, `strShortDescription`, `strDescription`) VALUES (2, 2, 'Easy ERP', 'Verwalten Sie Ihre Kontakte mit Easy CRM', '<p>Verwalten Sie Ihre Kontakte ganz einfach mit Easy ERP. Viele Funktionen sind hier enthalten, wie z.B.:<br><br>- Kontakte erstellen und verwalten<br>- Kundenhistorie<br>- Akquisition<br>- Terminverwaltung<br>- und vieles mehr...<br></p>');
INSERT INTO `modules_trans` (`intModuleID`, `intLanguageID`, `strModuleName`, `strShortDescription`, `strDescription`) VALUES (3, 2, 'MailChimp API', 'Übertragen Sie Ihre Kunden automtaisch zu MailChimp', '<p>Mit dem Newsletter-Marketing-Tool MailChimp bedienen Sie alle Ihre Kunden mit einem Newsletter. Verbinden Sie Ihren Account mit MailChimp und überlassen Sie die Synchronisation diesem Modul.</p>');

-- custom_mappings
INSERT INTO `custom_mappings` (`strMapping`, `strPath`, `blnOnlyAdmin`, `blnOnlySuperAdmin`, `blnOnlySysAdmin`, `intModuleID`) VALUES ('backend/modules/todo/settings', 'backend/modules/todo/settings.cfm', 1, 0, 0, 1);
INSERT INTO `custom_mappings` (`strMapping`, `strPath`, `blnOnlyAdmin`, `blnOnlySuperAdmin`, `blnOnlySysAdmin`, `intModuleID`) VALUES ('backend/modules/easyerp/settings', 'backend/modules/easyerp/settings.cfm', 1, 0, 0, 2);
INSERT INTO `custom_mappings` (`strMapping`, `strPath`, `blnOnlyAdmin`, `blnOnlySuperAdmin`, `blnOnlySysAdmin`, `intModuleID`) VALUES ('backend/modules/mailchimp/settings', 'backend/modules/mailchimp/settings.cfm', 1, 0, 0, 3);

-- modules_prices (one row per active currency)
INSERT INTO `modules_prices` (intModuleID, intCurrencyID, decPriceMonthly, decPriceYearly, decPriceOneTime, decVat, blnIsNet, intVatType)
SELECT '1', intCurrencyID, '0.00', '0.00', '0.00', '0.00', '0', '3'
FROM currencies
WHERE blnActive = 1;
INSERT INTO `modules_prices` (intModuleID, intCurrencyID, decPriceMonthly, decPriceYearly, decPriceOneTime, decVat, blnIsNet, intVatType)
SELECT '2', intCurrencyID, '29.00', '290.00', '0.00', '0.00', '0', '3'
FROM currencies
WHERE blnActive = 1;
INSERT INTO `modules_prices` (intModuleID, intCurrencyID, decPriceMonthly, decPriceYearly, decPriceOneTime, decVat, blnIsNet, intVatType)
SELECT '3', intCurrencyID, '0.00', '0.00', '29.00', '0.00', '0', '3'
FROM currencies
WHERE blnActive = 1;
