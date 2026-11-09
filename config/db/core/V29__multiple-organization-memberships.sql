SET NAMES utf8mb4;

-- A login is an identity, not an organization's disposable child record.
ALTER TABLE users DROP FOREIGN KEY frn_user_customer;
ALTER TABLE users MODIFY intCustomerID INT NULL;
ALTER TABLE users ADD CONSTRAINT frn_user_customer FOREIGN KEY (intCustomerID)
    REFERENCES customers (intCustomerID) ON DELETE SET NULL ON UPDATE NO ACTION;

-- Keep an explicit marker after the last membership is removed. Never fall back
-- to legacy grants merely because no membership remains.
CREATE TABLE membership_identities (
    intUserID INT NOT NULL,
    PRIMARY KEY (intUserID),
    CONSTRAINT fk_membership_identity_user FOREIGN KEY (intUserID)
        REFERENCES users (intUserID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO membership_identities (intUserID)
SELECT users.intUserID FROM users
INNER JOIN customers home ON home.intCustomerID = users.intCustomerID
INNER JOIN organization_access activated ON activated.intOrganizationID =
    CASE WHEN home.intCustParentID = 0 THEN home.intCustomerID ELSE home.intCustParentID END;

ALTER TABLE organization_memberships
    ADD UNIQUE KEY uq_organization_membership_pair (intUserID, intOrganizationID),
    DROP INDEX uq_organization_membership_user;
