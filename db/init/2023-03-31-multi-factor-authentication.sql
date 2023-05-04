ALTER TABLE users
ADD COLUMN intMfaCode INTEGER(11),
ADD COLUMN dtmMfaDateTime datetime DEFAULT NULL,
ADD COLUMN blnMfa TINYINT(1) NOT NULL DEFAULT 0;

INSERT INTO system_translations (strVariable, strStringDE, strStringEN)
VALUES ('txtSubjectMFA', 'Ihr Code für die Mehrfaktor-Authentifizierung', 'Your multi factor authentication code'),
('txtMfaCode', 'Nachfolgend finden Sie den Code für die Multi-Faktor-Authentifizierung', 'Below is your multi factor authentication code'),
('txtThreeTimeTry', 'Sie haben insgesamt drei Versuche, sich mit diesem Code anzumelden.', 'You have a total of three attempts to log in with this code.'),
('txtCodeValidity', 'Dieser Code ist nur für eine Stunde g&uuml;ltig.', 'This code is valid for one hour only.'),
('titMfa', 'Multi-Faktor-Authentisierung.', 'Multi-factor authentication.'),
('txtMfaLable', 'Multi-Faktor-Authentifizierung Code.', 'Multi factor authentication Code.'),
('txtResendMfa', 'Erneut senden', 'Resend'),
('txtErrorMfaCode', 'Ihr Code ist nicht korrekt, bitte versuchen Sie es erneut.', 'Your code is incorrect, please try again.'),
('txtResendDone', 'Der Code wurde gesendet.', 'The code has been sent');

INSERT INTO system_mappings (strMapping, strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysadmin)
VALUES ('mfa', 'frontend/mfa.cfm', 0, 0, 0);