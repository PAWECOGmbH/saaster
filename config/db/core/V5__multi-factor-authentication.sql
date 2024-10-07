SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE users
ADD COLUMN intMfaCode INTEGER(11),
ADD COLUMN dtmMfaDateTime datetime DEFAULT NULL,
ADD COLUMN blnMfa TINYINT(1) NOT NULL DEFAULT 0;

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysadmin)
VALUES ('mfa', 'frontend/mfa.cfm', 0, 0, 0);

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtSubjectMFA', 'Ihr Code für die Zwei-Faktor-Authentifizierung', 'Your multi-factor authentication code'),
('txtMfaCode', 'Nachfolgend finden Sie den Code für die Zwei-Faktor-Authentifizierung', 'Below is your multi-factor authentication code'),
('txtThreeTimeTry', 'Sie haben insgesamt drei Versuche, sich mit diesem Code anzumelden.', 'You have a total of three attempts to log in with this code.'),
('txtCodeValidity', 'Dieser Code ist nur für eine Stunde gültig.', 'This code is valid for one hour only.'),
('titMfa', 'Zwei-Faktor-Authentifizierung', 'Multi-factor authentication'),
('txtMfaLable', 'Zwei-Faktor-Authentifizierungs-Code', 'Multi-factor authentication code'),
('txtResendMfa', 'Code erneut senden', 'Resend code'),
('txtErrorMfaCode', 'Ihr Code ist nicht korrekt, bitte versuchen Sie es erneut!', 'Your code is incorrect, please try again!'),
('txtResendDone', 'Der Code wurde gesendet.', 'The code has been sent.'),
('txtmfaLead', 'Bitte geben Sie den per E-Mail erhaltenen Code ins Feld ein:', 'Please enter the code received by email into the field:');

SET FOREIGN_KEY_CHECKS = 1;