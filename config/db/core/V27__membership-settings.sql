SET NAMES utf8mb4;

-- Activation is explicit per organization. A removed membership must never fall
-- back to legacy permissions, so activation is stored independently of members.
CREATE TABLE IF NOT EXISTS organization_access (
    intOrganizationID INT NOT NULL,
    intActivatedBy INT NULL,
    dtmActivatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (intOrganizationID),
    CONSTRAINT fk_organization_access_customer FOREIGN KEY (intOrganizationID)
        REFERENCES customers (intCustomerID) ON DELETE CASCADE,
    CONSTRAINT fk_organization_access_actor FOREIGN KEY (intActivatedBy)
        REFERENCES users (intUserID) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS membership_preferences (
    intUserID INT NOT NULL,
    intDefaultCustomerID INT NULL,
    PRIMARY KEY (intUserID),
    CONSTRAINT fk_membership_preference_user FOREIGN KEY (intUserID)
        REFERENCES users (intUserID) ON DELETE CASCADE,
    CONSTRAINT fk_membership_preference_customer FOREIGN KEY (intDefaultCustomerID)
        REFERENCES customers (intCustomerID) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO system_mappings (strMapping, strPath) VALUES
    ('account-settings/memberships', 'backend/core/views/customer/memberships.cfm'),
    ('memberships', 'backend/core/handler/memberships.cfm');

INSERT IGNORE INTO system_translations (strVariable, strStringDE, strStringEN) VALUES
    ('txtMembershipIssue_invalid_parent', 'Ein Mandant ist keiner gültigen Hauptorganisation zugeordnet.', 'A tenant is not assigned to a valid main organization.'),
    ('txtMembershipIssue_incomplete_assignment', 'Eine Benutzer- oder Mandantenzuordnung ist unvollständig.', 'A user or tenant assignment is incomplete.'),
    ('txtMembershipIssue_cross_organization_assignment', 'Ein Benutzer ist einer fremden Organisation zugeordnet.', 'A user is assigned to an unrelated organization.'),
    ('txtMembershipIssue_duplicate_assignment', 'Eine Mandantenzuordnung ist mehrfach vorhanden.', 'A tenant assignment exists more than once.'),
    ('txtMembershipIssue_invalid_default_count', 'Für einen Benutzer muss genau ein Standardmandant festgelegt sein.', 'A user must have exactly one default tenant.'),
    ('txtMembershipIssue_inactive_default_tenant', 'Der Standardmandant eines aktiven Benutzers ist deaktiviert.', 'An active user has a disabled default tenant.'),
    ('txtMembershipIssue_owner_selection_required', 'Wählen Sie einen Eigentümer und aktualisieren Sie die Vorschau.', 'Select an owner and update the preview.'),
    ('txtMembershipIssue_invalid_owner_selection', 'Der gewählte Benutzer kann nicht Eigentümer werden.', 'The selected user is not eligible to become the owner.'),
    ('txtMembershipIssue_invalid_organization', 'Die Hauptorganisation ist ungültig.', 'The main organization is invalid.'),
    ('txtMembershipInactiveAccount', 'Benutzerkonto deaktiviert', 'User account disabled'),
    ('txtMembershipPreview', 'Vorschau aktualisieren', 'Update preview'),
    ('titMemberships', 'Mitglieder und Rollen', 'Members and roles'),
    ('txtMembershipsDescription', 'Mitglieder, Organisationsrollen und Zugriffe auf Mandanten verwalten.', 'Manage members, organization roles and tenant access.'),
    ('txtMembershipSetup', 'Organisationsrollen einrichten', 'Set up organization roles'),
    ('txtMembershipSetupInfo', 'Prüfen Sie die vorgeschlagenen Rollen und wählen Sie einen Eigentümer. Anschliessend gelten diese Rollen für alle Mitglieder dieser Organisation.', 'Review the proposed roles and select an owner. These roles will then apply to all members of this organization.'),
    ('txtMembershipOwner', 'Eigentümer', 'Owner'),
    ('txtMembershipOrgAdmin', 'Organisationsadmin', 'Organization admin'),
    ('txtMembershipMember', 'Mitglied', 'Member'),
    ('txtMembershipTenantAdmin', 'Mandantenadmin', 'Tenant admin'),
    ('txtMembershipEditor', 'Bearbeiter', 'Editor'),
    ('txtMembershipViewer', 'Leser', 'Viewer'),
    ('txtMembershipSuspended', 'Gesperrt', 'Suspended'),
    ('txtMembershipActive', 'Aktiv', 'Active'),
    ('txtMembershipNoAccess', 'Kein Zugriff', 'No access'),
    ('txtMembershipOrganizationRole', 'Organisationsrolle', 'Organization role'),
    ('txtMembershipTenantAccess', 'Mandantenzugriff', 'Tenant access'),
    ('txtMembershipInherited', 'Zugriff durch Organisationsrolle', 'Access inherited from organization role'),
    ('txtMembershipSave', 'Rolle speichern', 'Save role'),
    ('txtMembershipRemove', 'Mitgliedschaft entfernen', 'Remove membership'),
    ('txtMembershipRemoveConfirm', 'Mitgliedschaft und zugehörige Mandantenzugriffe entfernen?', 'Remove this membership and its tenant access?'),
    ('txtMembershipTransfer', 'Eigentümerschaft übertragen', 'Transfer ownership'),
    ('txtMembershipTransferConfirm', 'Eigentümerschaft übertragen? Sie bleiben Organisationsadmin.', 'Transfer ownership? You will remain an organization admin.'),
    ('txtMembershipActivate', 'Rollen übernehmen und aktivieren', 'Apply and activate roles'),
    ('txtMembershipReview', 'Eingeschränkte SuperAdmins werden zu Mandantenadmins. Der gewählte Eigentümer erhält Zugriff auf die gesamte Organisation.', 'Scoped superadmins become tenant admins. The selected owner receives access to the entire organization.'),
    ('txtMembershipApprove', 'Ich habe die vorgeschlagenen Rollen und Zugriffe geprüft.', 'I have reviewed the proposed roles and access.'),
    ('txtMembershipIssues', 'Die folgenden Zuordnungen müssen vor der Einrichtung korrigiert werden.', 'Correct the following assignments before setting up organization roles.'),
    ('msgMembershipSaved', 'Mitgliedschaft gespeichert.', 'Membership saved.'),
    ('msgMembershipActivated', 'Organisationsrollen sind jetzt aktiv.', 'Organization roles are now active.'),
    ('msgMembershipDenied', 'Diese Änderung ist nicht erlaubt. Prüfen Sie die Rolle, den Status und die Organisationszuordnung.', 'This change is not allowed. Check the role, status and organization membership.'),
    ('msgMembershipLastOwner', 'Der letzte aktive Eigentümer kann nicht entfernt, gesperrt oder herabgestuft werden.', 'The last active owner cannot be removed, suspended or demoted.'),
    ('msgMembershipSetupFailed', 'Die Rollen konnten nicht übernommen werden. Prüfen Sie die Vorschau erneut.', 'The roles could not be applied. Review the preview again.'),
    ('txtMembershipRestore', 'Mitgliedschaft wiederherstellen', 'Restore membership'),
    ('txtMembershipRemoved', 'Ohne Mitgliedschaft', 'No membership'),
    ('txtMembershipPlatform', 'Plattformadministrator', 'Platform administrator'),
    ('txtMembershipYourRole', 'Ihre Rolle', 'Your role'),
    ('txtMembershipReadOnly', 'Lesezugriff', 'Read-only access');

INSERT IGNORE INTO system_translations (strVariable, strStringDE, strStringEN) VALUES
    ('txtMembershipSaveAll', 'Änderungen speichern', 'Save changes'),
    ('txtMembershipOrganization', 'Organisation', 'Organization'),
    ('txtMembershipMoreActions', 'Weitere Aktionen', 'More actions'),
    ('txtMembershipCancel', 'Abbrechen', 'Cancel'),
    ('txtMembershipRemoveOrganization', 'Aus Organisation entfernen', 'Remove from organization'),
    ('txtMembershipRemoveDetails', '{member} verliert den Zugriff auf die Organisation «{organization}» und alle zugehörigen Mandanten. Das Benutzerkonto bleibt bestehen.', '{member} will lose access to the organization “{organization}” and all its tenants. The user account will be kept.'),
    ('txtMembershipTransferOrganization', 'Eigentümer der Organisation ändern', 'Change organization owner'),
    ('txtMembershipTransferDetails', '{member} wird Eigentümer der Organisation «{organization}» und erhält Zugriff auf alle zugehörigen Mandanten. Sie wechseln zur Rolle Organisationsadmin.', '{member} will become owner of the organization “{organization}” with access to all its tenants. Your role will change to organization admin.'),
    ('txtMembershipSeparateAction', 'Ungespeicherte Änderungen im Bearbeitungsdialog werden dabei nicht übernommen.', 'Unsaved changes in the edit dialog will not be applied.');

-- Correct the earlier draft wording when reapplied, preserving customized translations.
UPDATE system_translations
SET strStringDE = 'Wählen Sie einen Eigentümer und aktualisieren Sie die Vorschau.'
WHERE strVariable = 'txtMembershipIssue_owner_selection_required'
    AND BINARY strStringDE = BINARY 'Wähle einen Eigentümer und aktualisiere die Vorschau.';

UPDATE system_translations
SET strStringDE = 'Prüfen Sie die vorgeschlagenen Rollen und wählen Sie einen Eigentümer. Anschliessend gelten diese Rollen für alle Mitglieder dieser Organisation.'
WHERE strVariable = 'txtMembershipSetupInfo'
    AND BINARY strStringDE = BINARY 'Prüfe die vorgeschlagenen Rollen und wähle einen Eigentümer. Anschliessend gelten diese Rollen für alle Mitglieder dieser Organisation.';

UPDATE system_translations
SET strStringDE = 'Eigentümerschaft übertragen? Sie bleiben Organisationsadmin.'
WHERE strVariable = 'txtMembershipTransferConfirm'
    AND BINARY strStringDE = BINARY 'Eigentümerschaft übertragen? Du bleibst Organisationsadmin.';

UPDATE system_translations
SET strStringDE = 'Diese Änderung ist nicht erlaubt. Prüfen Sie die Rolle, den Status und die Organisationszuordnung.'
WHERE strVariable = 'msgMembershipDenied'
    AND BINARY strStringDE = BINARY 'Diese Änderung ist nicht erlaubt. Prüfe die Rolle, den Status und die Organisationszuordnung.';

UPDATE system_translations
SET strStringDE = 'Die Rollen konnten nicht übernommen werden. Prüfen Sie die Vorschau erneut.'
WHERE strVariable = 'msgMembershipSetupFailed'
    AND BINARY strStringDE = BINARY 'Die Rollen konnten nicht übernommen werden. Prüfe die Vorschau erneut.';

UPDATE system_translations
SET strStringDE = 'Ihre Rolle'
WHERE strVariable = 'txtMembershipYourRole'
    AND BINARY strStringDE = BINARY 'Deine Rolle';
