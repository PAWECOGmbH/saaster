-- Demo dashboard widgets for development, one per kind of assignment:
--   1, 2  shown to everybody (blnPermDisplay)
--   3     only with the module Easy ERP (module 2)
--   4     only with the plans Standard and Advanced (plans 2, 3)
--   5     deactivated by the sysadmin (blnActive = 0) - never shown
-- All of them render backend/myapp/widgets/welcome.cfm, the only widget file in the repository.
--
-- Data only - the tables come from the migrations (config/db/core). Run it after
-- create-plans.sql and create-modules.sql (it links widgets to their IDs). Running it again
-- replaces widgets 1-5; their user settings, links and translations go with them.
--
-- Import (see readme.md): cat ./config/db/dev/create-widgets.sql | docker exec -i <mysql container> mysql -u <user> -p<password> <database>

SET NAMES utf8mb4;

DELETE FROM widgets WHERE intWidgetID BETWEEN 1 AND 5;

-- widget_ratio (from the migrations): 1 = full, 2 = 3/4, 3 = 1/2, 4 = 1/3, 5 = 1/4 width
INSERT INTO `widgets` (`intWidgetID`, `strWidgetName`, `strFilePath`, `blnActive`, `intRatioID`, `blnPermDisplay`) VALUES
(1, 'Last Login', 'backend/myapp/widgets/welcome.cfm', 1, 3, 1),
(2, 'Account overview', 'backend/myapp/widgets/welcome.cfm', 1, 3, 1),
(3, 'Easy ERP contacts', 'backend/myapp/widgets/welcome.cfm', 1, 1, 0),
(4, 'Team workload', 'backend/myapp/widgets/welcome.cfm', 1, 2, 0),
(5, 'Retired widget', 'backend/myapp/widgets/welcome.cfm', 0, 4, 1);

INSERT INTO `widgets_trans` (`intWidgetID`, `intLanguageID`, `strWidgetName`)
SELECT w.id, l.intLanguageID, w.name
FROM (
    SELECT 1 AS id, 'Letzte Anmeldung' AS name
    UNION ALL SELECT 2, 'Kontoübersicht'
    UNION ALL SELECT 3, 'Easy ERP Kontakte'
    UNION ALL SELECT 4, 'Auslastung des Teams'
    UNION ALL SELECT 5, 'Ausgemustertes Widget'
) AS w
CROSS JOIN languages l
WHERE l.strLanguageISO = 'de';

INSERT INTO `widgets_modules` (`intWidgetID`, `intModuleID`) VALUES (3, 2);

INSERT INTO `widgets_plans` (`intWidgetID`, `intPlanID`) VALUES (4, 2), (4, 3);
