-- Demo plans for development: one plan group with four plans, their features and prices.
--
-- Data only - the tables come from the migrations (config/db/core). Running it again
-- replaces the demo plans: plan group 1, plans 1-4 and features 1-13 (their translations,
-- prices and bookings go with them through ON DELETE CASCADE).
--
-- Import (see readme.md): cat ./config/db/dev/create-plans.sql | docker exec -i <mysql container> mysql -u <user> -p<password> <database>

SET NAMES utf8mb4;

-- The migrations create USD, EUR and CHF, EUR and CHF inactive. The demo prices use all three.
UPDATE currencies SET blnActive = 1 WHERE strCurrencyISO IN ('USD', 'EUR', 'CHF');

DELETE FROM plans_plan_features_trans WHERE intPlansPlanFeatID BETWEEN 1 AND 40;
DELETE FROM plans WHERE intPlanID BETWEEN 1 AND 4;
DELETE FROM plan_groups WHERE intPlanGroupID = 1;
DELETE FROM plan_features WHERE intPlanFeatureID BETWEEN 1 AND 13;

-- plan_groups
INSERT INTO `plan_groups` (`intPlanGroupID`, `strGroupName`, `intCountryID`, `intPrio`) VALUES (1, 'Pricing worldwide', NULL, 1);

-- plan_groups_trans
INSERT INTO `plan_groups_trans` (`intPlanGroupID`, `intLanguageID`, `strGroupName`) VALUES (1, 2, 'Preise weltweit');

-- plans
INSERT INTO `plans` (`intPlanID`, `intPlanGroupID`, `strPlanName`, `strShortDescription`, `strDescription`, `strButtonName`, `strBookingLink`, `strRedirectPath`, `blnRecommended`, `intMaxUsers`, `intNumTestDays`, `blnTestDaysUpgrade`, `blnFree`, `blnDefaultPlan`, `intPrio`) VALUES (1, 1, 'Free', '3 users + 0 guests\r\nBest for small, personal projects', '<ul><li>1 project</li><li>3 users</li><li>60 task limit</li></ul>', 'Try free', '', '', 0, 3, 0, 0, 1, 0, 1);
INSERT INTO `plans` (`intPlanID`, `intPlanGroupID`, `strPlanName`, `strShortDescription`, `strDescription`, `strButtonName`, `strBookingLink`, `strRedirectPath`, `blnRecommended`, `intMaxUsers`, `intNumTestDays`, `blnTestDaysUpgrade`, `blnFree`, `blnDefaultPlan`, `intPrio`) VALUES (2, 1, 'Standard', 'Up to 10 users\r\nFor teams that need planning and collaboration features.', '<p><strong>Try free for 30 days. Cancel anytime.</strong></p><ul><li>Unlimited projects</li><li>Unlimited tasks</li><li>Add users as needed</li><li>Collaboration and planning features</li></ul>', 'Try standard', '', '', 1, 10, 30, 0, 0, 0, 2);
INSERT INTO `plans` (`intPlanID`, `intPlanGroupID`, `strPlanName`, `strShortDescription`, `strDescription`, `strButtonName`, `strBookingLink`, `strRedirectPath`, `blnRecommended`, `intMaxUsers`, `intNumTestDays`, `blnTestDaysUpgrade`, `blnFree`, `blnDefaultPlan`, `intPrio`) VALUES (3, 1, 'Advanced', 'Up to 30 users\r\nFor teams that need planning and collaboration, + tracking workloads by hours, and advanced project reporting. ', '<p><strong>Including all from Basic plan and:</strong></p><ul><li>Advanced reporting</li><li>Track workloads by hours</li></ul><ul></ul>', 'Try advanced', '', '', 0, 30, 30, 0, 0, 0, 3);
INSERT INTO `plans` (`intPlanID`, `intPlanGroupID`, `strPlanName`, `strShortDescription`, `strDescription`, `strButtonName`, `strBookingLink`, `strRedirectPath`, `blnRecommended`, `intMaxUsers`, `intNumTestDays`, `blnTestDaysUpgrade`, `blnFree`, `blnDefaultPlan`, `intPrio`) VALUES (4, 1, 'Enterprise', 'Bis business for large companies.\r\nUp to 500 users or more - pleas ask for offer', '<ul><li>Unlimited projects</li><li>Unlimited tasks</li><li>Add users as needed no limits</li><li>and much more<br></li></ul>', 'Contact', 'contact/enterprise', '', 0, 0, 30, 0, 0, 0, 4);

-- plans_trans
INSERT INTO `plans_trans` (`intPlanID`, `intLanguageID`, `strPlanName`, `strShortDescription`, `strDescription`, `strButtonName`, `strBookingLink`) VALUES (1, 2, 'Easy', '3 Benutzer + 0 Gäste\r\nAm besten für kleine, persönliche Projekte', '<ul><li>1 Projekt</li><li>3 Benutzer<br></li><li>Limit von 60 Aufgaben<br></li></ul>', 'Kostenlos testen', NULL);
INSERT INTO `plans_trans` (`intPlanID`, `intLanguageID`, `strPlanName`, `strShortDescription`, `strDescription`, `strButtonName`, `strBookingLink`) VALUES (2, 2, 'Standard', 'Bis zu 10 Benutzer \r\nFür Teams, die Funktionen zur Planung und Zusammenarbeit benötigen.', '<p><strong>Testen Sie kostenlos für 30 Tage. Jederzeit kündbar.</strong></p><ul><li>Unbegrenzte Projekte</li><li>Unbegrenzte Aufgaben</li><li>Benutzer nach Bedarf hinzufügen</li><li>Funktionen für Zusammenarbeit und Planung<br></li></ul>', 'Standard testen', NULL);
INSERT INTO `plans_trans` (`intPlanID`, `intLanguageID`, `strPlanName`, `strShortDescription`, `strDescription`, `strButtonName`, `strBookingLink`) VALUES (3, 2, 'Advanced', 'Bis zu 30 Benutzer\r\nFür Teams, die Planung und Zusammenarbeit benötigen, + Verfolgung des Arbeitsaufwands nach Stunden und erweiterte Projektberichte.', '<p>Alles aus Basic und:</p><ul><li>Erweitertes Reporting</li><li>Arbeitsauslastung nach Stunden<br></li></ul>', 'Advanced testen', NULL);
INSERT INTO `plans_trans` (`intPlanID`, `intLanguageID`, `strPlanName`, `strShortDescription`, `strDescription`, `strButtonName`, `strBookingLink`) VALUES (4, 2, 'Enterprise', 'Großes Geschäft für große Unternehmen.\r\nBis zu 500 Benutzer oder mehr - bitte fragen Sie nach einem Angebot', '<ul><li>Unlimitiert Projekte<br></li><li>Unlimitiert Aufgaben</li><li>Hinzufügen von Benutzern ohne Einschränkung<br></li><li>und vieles mehr<br></li></ul>', 'Kontakt', NULL);

-- plan_features
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (1, 'Planning', '', 1, '', 1);
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (2, 'Beautiful gantt charts', 'A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart.', 0, '', 2);
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (3, 'Tasks', 'The quick, brown fox jumps over a lazy dog. DJs flock by when MTV ax quiz prog. Junk MTV quiz graced by fox whelps. Bawds jog, flick quartz, vex nymphs.', 0, '', 3);
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (4, 'Users', 'Waltz, bad nymph, for quick jigs vex! Fox nymphs grab quick-jived waltz. Brick quiz whangs jumpy veldt fox. Bright vixens jump; dozy fowl quack.', 0, '', 4);
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (5, 'Dependencies', 'Quick wafting zephyrs vex bold Jim. Quick zephyrs blow, vexing daft Jim.', 0, '', 5);
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (6, 'Management', '', 1, '', 6);
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (7, 'Your team can update their progress', 'Sex-charged fop blew my junk TV quiz. How quickly daft jumping zebras vex. Two driven jocks help fax my big quiz. Quick, Baz, get my woven flax jodhpurs!', 0, '', 7);
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (8, 'Daily email reminders', '\"Now fax quiz Jack!\" my brave ghost pled. Five quacking zephyrs jolt my wax bed. Flummoxed by job, kvetching W. zaps Iraq. Cozy sphinx waves quart jug of bad milk.', 0, '', 8);
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (9, 'Simple task list views', 'A very bad quack might jinx zippy fowls. Few quips galvanized the mock jury box. Quick brown dogs jump over the lazy fox.', 0, '', 9);
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (10, 'Time Tracking', '', 1, '', 10);
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (11, 'Manual time entry', 'The jay, pig, fox, zebra, and my wolves quack! Blowzy red vixens fight for a quick jump.', 0, '', 11);
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (12, 'Reporting', 'Joaquin Phoenix was gazed by MTV for luck. A wizard’s job is to vex chumps quickly in fog. Watch \"Jeopardy!\", Alex Trebeks fun TV quiz game.', 0, '', 12);
INSERT INTO `plan_features` (`intPlanFeatureID`, `strFeatureName`, `strDescription`, `blnCategory`, `strVariable`, `intPrio`) VALUES (13, 'Early detection of hours going over budget', 'Woven silk pyjamas exchanged for blue quartz. Brawny gods just ', 0, '', 13);

-- plan_features_trans
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (1, 2, 'Planen', NULL);
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (2, 2, 'Schöne Gantt Charts', 'Eine wunderbare Gelassenheit hat von meiner ganzen Seele Besitz ergriffen, wie diese süßen Frühlingsmorgen, die ich mit ganzem Herzen genieße.');
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (3, 2, 'Aufgaben', 'Der schnelle, braune Fuchs springt über den faulen Hund. DJs strömen vorbei, wenn MTV ax quiz prog. Schrott-MTV-Quiz wird von Fuchs-Welpen beehrt. Bawds joggen, flicken Quarz, vex Nymphen.');
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (5, 2, 'Abhängigkeiten', 'Schnell wehende Zephiren ärgern den kühnen Jim. Schnell wehender Zephir, ärgert den dummen Jim.');
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (6, 2, 'Management', '');
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (7, 2, 'Dein Team kann Fortschritte aktualisieren', 'Sexgeladener Fop hat mein Junk-TV-Quiz vermasselt. Wie schnell verrückte springende Zebras nerven. Zwei getriebene Jocks helfen, mein großes Quiz zu faxen. Schnell, Baz, hol meine gewebte Leinen-Reithose!');
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (8, 2, 'Tägliche E-Mail Erinnerungen', '\"Jetzt Fax-Quiz Jack!\", rief mein tapferer Geist. Fünf quakende Zephiren rütteln an meinem Wachsbett. Verwirrt von der Arbeit, kvetching W. zappt Irak. Gemütliche Sphinx winkt mit einem Krug voll schlechter Milch.');
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (9, 2, 'Einfache Aufgabenlistenansichten', 'Ein sehr schlechter Quacksalber könnte flinke Hühner verhexen. Ein paar Witzeleien brachten die Jury zum Lachen. Schnelle braune Hunde springen über den faulen Fuchs.');
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (10, 2, 'Zeiterfassung', NULL);
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (11, 2, 'Manuelle Zeiterfassung', 'Der Eichelhäher, das Schwein, der Fuchs, das Zebra und meine Wölfe quaken! Aufgeblasene rote Füchse kämpfen um einen schnellen Sprung.');
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (12, 2, 'Berichte erstellen', 'Joaquin Phoenix wurde von MTV als Glücksbringer angesehen. Die Aufgabe eines Zauberers ist es, Dummköpfe schnell im Nebel zu verwirren. Sieh dir \"Jeopardy!\" an, das lustige TV-Quizspiel von Alex Trebek.');
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (13, 2, 'Frühzeitige Erkennung von Stunden, die das Budget überschreiten', 'Pyjama aus gewebter Seide gegen blauen Quarz getauscht. Brawny Götter nur ');
INSERT INTO `plan_features_trans` (`intPlanFeatureID`, `intLanguageID`, `strFeatureName`, `strDescription`) VALUES (4, 2, 'Benutzer', 'Walzer, schlechte Nymphe, für schnelle Jigs vex! Fuchsnymphen schnappen sich den schnell gesprungenen Walzer. Brick Quiz whangs jumpy veldt fox. Helle Füchse springen; dösende Hühner quaken.');

-- plans_plan_features
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (1, 1, 2, 0, '1');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (2, 1, 3, 0, '60');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (3, 1, 4, 0, '3');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (4, 1, 5, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (5, 1, 7, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (6, 1, 8, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (7, 1, 9, 0, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (8, 1, 11, 0, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (9, 1, 12, 0, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (10, 1, 13, 0, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (11, 2, 2, 0, 'Unlimited');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (12, 2, 3, 0, 'Unlimited');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (13, 2, 4, 0, '10');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (14, 2, 5, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (15, 2, 7, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (16, 2, 8, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (17, 2, 9, 0, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (18, 2, 11, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (19, 2, 12, 0, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (20, 2, 13, 0, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (21, 3, 2, 0, 'Unlimited');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (22, 3, 3, 0, 'Unlimited');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (23, 3, 4, 0, '30');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (24, 3, 5, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (25, 3, 7, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (26, 3, 8, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (27, 3, 9, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (28, 3, 11, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (29, 3, 12, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (30, 3, 13, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (31, 4, 2, 0, 'Unlimited');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (32, 4, 3, 0, 'Unlimited');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (33, 4, 4, 0, 'Unlimited');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (34, 4, 5, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (35, 4, 7, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (36, 4, 8, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (37, 4, 9, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (38, 4, 11, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (39, 4, 12, 1, '');
INSERT INTO `plans_plan_features` (`intPlansPlanFeatID`, `intPlanID`, `intPlanFeatureID`, `blnCheckmark`, `strValue`) VALUES (40, 4, 13, 1, '');

-- plans_plan_features_trans
INSERT INTO `plans_plan_features_trans` (`intPlansPlanFeatID`, `intLanguageID`, `strValue`) VALUES (11, 2, 'Unlimitiert');
INSERT INTO `plans_plan_features_trans` (`intPlansPlanFeatID`, `intLanguageID`, `strValue`) VALUES (12, 2, 'Unlimitiert');
INSERT INTO `plans_plan_features_trans` (`intPlansPlanFeatID`, `intLanguageID`, `strValue`) VALUES (21, 2, 'Unlimitiert');
INSERT INTO `plans_plan_features_trans` (`intPlansPlanFeatID`, `intLanguageID`, `strValue`) VALUES (22, 2, 'Unlimitiert');
INSERT INTO `plans_plan_features_trans` (`intPlansPlanFeatID`, `intLanguageID`, `strValue`) VALUES (31, 2, 'Unlimitiert');
INSERT INTO `plans_plan_features_trans` (`intPlansPlanFeatID`, `intLanguageID`, `strValue`) VALUES (32, 2, 'Unlimitiert');
INSERT INTO `plans_plan_features_trans` (`intPlansPlanFeatID`, `intLanguageID`, `strValue`) VALUES (33, 2, 'Unlimitiert');

-- plan_prices: USD and EUR without VAT, CHF net plus 8.1% Swiss VAT (VAT type 1, shows VAT lines on invoices).
-- Enterprise is "on request".
INSERT INTO `plan_prices` (`intPlanID`, `intCurrencyID`, `decPriceMonthly`, `decPriceYearly`, `decVat`, `blnIsNet`, `intVatType`, `blnOnRequest`)
SELECT p.intPlanID, c.intCurrencyID, p.monthly, p.yearly, IF(c.strCurrencyISO = 'CHF', 8.10, 0.00), IF(c.strCurrencyISO = 'CHF', 1, 0), IF(c.strCurrencyISO = 'CHF', 1, 3), p.onRequest
FROM (
    SELECT 1 AS intPlanID, 0.00 AS monthly, 0.00 AS yearly, 0 AS onRequest
    UNION ALL SELECT 2, 89.00, 800.00, 0
    UNION ALL SELECT 3, 129.00, 1100.00, 0
    UNION ALL SELECT 4, 250.00, 2500.00, 1
) AS p
CROSS JOIN currencies c
WHERE c.strCurrencyISO IN ('USD', 'EUR', 'CHF');
