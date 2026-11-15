SET NAMES utf8mb4;

ALTER TABLE payrexx
    ADD COLUMN strCardExpiry CHAR(5) NULL DEFAULT NULL,
    ADD COLUMN dtmExpiryCheckedAt DATETIME NULL DEFAULT NULL;

CREATE TABLE card_expiry_reminders (
    intCardExpiryReminderID BIGINT NOT NULL AUTO_INCREMENT,
    intPayrexxID INT NOT NULL,
    strCardExpiry CHAR(5) NOT NULL,
    strStage VARCHAR(5) NOT NULL,
    strClaimToken CHAR(36) NOT NULL,
    dtmClaimedAt DATETIME NOT NULL,
    dtmSentAt DATETIME NULL,
    PRIMARY KEY (intCardExpiryReminderID),
    UNIQUE KEY uq_card_expiry_notice (intPayrexxID, strCardExpiry, strStage),
    CONSTRAINT fk_card_expiry_payment FOREIGN KEY (intPayrexxID)
        REFERENCES payrexx (intPayrexxID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO system_translations (strVariable, strStringDE, strStringEN) VALUES
    ('subjectCardExpiryMonth', 'Ihre hinterlegte Karte läuft bald ab', 'Your saved card expires soon'),
    ('subjectCardExpiryWeek', 'Ihre hinterlegte Karte läuft in wenigen Tagen ab', 'Your saved card expires in a few days'),
    ('msgCardExpiryMonth', 'Ihre für wiederkehrende Zahlungen hinterlegte Standardkarte läuft Ende {expiry} ab. Bitte hinterlegen Sie rechtzeitig eine neue Zahlungsart, damit Ihr Abonnement weiterlaufen kann.', 'Your default card for recurring payments expires at the end of {expiry}. Please add a new payment method in time so your subscription can continue.'),
    ('msgCardExpiryWeek', 'Ihre für wiederkehrende Zahlungen hinterlegte Standardkarte läuft Ende {expiry} ab. Bitte hinterlegen Sie jetzt eine neue Zahlungsart, damit Ihr Abonnement weiterlaufen kann.', 'Your default card for recurring payments expires at the end of {expiry}. Please add a new payment method now so your subscription can continue.'),
    ('btnUpdatePaymentMethod', 'Zahlungsart aktualisieren', 'Update payment method');
