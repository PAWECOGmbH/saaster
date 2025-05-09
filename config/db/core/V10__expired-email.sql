SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES
('titTestPhaseExpired', 'Ihre Testphase ist abgelaufen', 'Your test phase has expired'),
('msgModuleExpiredPurchase', 'Ihr Modul <b>@modulname@</b> ist leider abgelaufen. Bitte erwerben Sie es jetzt, um weiterzuarbeiten. Vielen Dank!', 'Your <b>@modulname@</b> module has unfortunately expired. Please purchase it now to continue working. Thank you!'),
('msgPlanExpiredPurchase', 'Ihr Plan <b>@modulname@</b> ist leider abgelaufen. Bitte erwerben Sie ihn jetzt, um weiterzuarbeiten. Vielen Dank!', 'Your <b>@planname@</b> plan has unfortunately expired. Please purchase it now to continue working. Thank you!')
;

SET FOREIGN_KEY_CHECKS = 1;