-- Recover payment methods that were permanently disabled after any failed charge.
UPDATE payrexx
SET blnFailed = 0
WHERE blnFailed = 1;

-- Missing transaction IDs must remain nullable so the unique index can coexist
-- with incomplete legacy webhook records.
UPDATE payrexx
SET intTransactionID = NULL
WHERE intTransactionID = 0;

-- Webhook retries used to create duplicate rows. Keep the oldest local ID so
-- existing payment references can be redirected before the duplicate is removed.
CREATE TEMPORARY TABLE payrexx_duplicate_map AS
SELECT duplicate.intPayrexxID AS duplicateID, canonical.intPayrexxID AS canonicalID
FROM payrexx duplicate
INNER JOIN (
    SELECT intTransactionID, MIN(intPayrexxID) AS intPayrexxID
    FROM payrexx
    WHERE intTransactionID IS NOT NULL
    GROUP BY intTransactionID
) canonical ON canonical.intTransactionID = duplicate.intTransactionID
WHERE duplicate.intPayrexxID <> canonical.intPayrexxID;

UPDATE payments
INNER JOIN payrexx_duplicate_map ON payrexx_duplicate_map.duplicateID = payments.intPayrexxID
SET payments.intPayrexxID = payrexx_duplicate_map.canonicalID;

DELETE payrexx
FROM payrexx
INNER JOIN payrexx_duplicate_map ON payrexx_duplicate_map.duplicateID = payrexx.intPayrexxID;

DROP TEMPORARY TABLE payrexx_duplicate_map;

ALTER TABLE payrexx
DROP INDEX `_intTransactionID`,
ADD UNIQUE INDEX `_intTransactionID` (`intTransactionID`);
