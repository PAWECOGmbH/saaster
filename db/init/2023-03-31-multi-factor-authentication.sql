ALTER TABLE users
ADD COLUMN intMfaCode INTEGER(11),
ADD COLUMN dtmMfaDateTime datetime DEFAULT NULL,
ADD COLUMN blnMfa TINYINT(1) NOT NULL DEFAULT 0;

INSERT INTO `system_translations` VALUES (318,"txtSubjectMFA", "Your Multi factor authentication Code", "Ihre Multi factor authentication Code");
INSERT INTO `system_translations` VALUES (319,"txtMfaCode", "Here is your multi factor authentication code below", "Unten ist Ihre multi factor authentication Code");
INSERT INTO `system_translations` VALUES (320,"txtThreeTimeTry", "You have 3 tries to login to your dashboard", "Sie haben insgesamt drei Versuche, um sich mit diesem Code einzuloggen.");
INSERT INTO `system_translations` VALUES (321,"txtCodeValidity", "This code is only valid for one hour.", "Dieser Code ist nur eine Stunde lang g&uuml;ltig.");
INSERT INTO `system_translations` VALUES (322,"titMfa", "Multi factor authentication.", "Multi-Faktor-Authentifizierung.");
INSERT INTO `system_translations` VALUES (323,"txtMfaLable", "Multi factor authentication Code.", "Multi Faktor Authentifizierung Code.");
INSERT INTO `system_translations` VALUES (324,"txtResendMfa", "Resend Code.", "Erneut senden");
INSERT INTO `system_translations` VALUES (325,"txtErrorMfaCode", "Incorrect Code, please try again.", "Ihr Code ist nicht korrekt, bitte erneut versuchen");
INSERT INTO `system_translations` VALUES (326,"txtResendDone", "Resended Mfa Code.", "Der Code wurde erneut gesendet");

INSERT INTO `system_mappings` VALUES (78, 'mfa', 'frontend/mfa.cfm', 0, 0, 0);