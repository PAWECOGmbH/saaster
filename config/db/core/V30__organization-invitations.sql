SET NAMES utf8mb4;

CREATE TABLE organization_invitations (
    intInvitationID INT NOT NULL AUTO_INCREMENT,
    intOrganizationID INT NOT NULL,
    intInvitedBy INT NULL,
    intTargetUserID INT NULL,
    strEmail VARCHAR(100) NOT NULL,
    strRoleKey VARCHAR(50) NOT NULL,
    strAssignments JSON NOT NULL,
    strLanguage VARCHAR(2) NOT NULL DEFAULT 'en',
    strTokenHash CHAR(64) NOT NULL,
    strStatus VARCHAR(20) NOT NULL DEFAULT 'pending',
    dtmCreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dtmExpiresAt DATETIME NOT NULL,
    dtmAcceptedAt DATETIME NULL,
    intAcceptedBy INT NULL,
    PRIMARY KEY (intInvitationID),
    UNIQUE KEY uq_invitation_token (strTokenHash),
    KEY ix_invitation_recipient (intOrganizationID, strEmail, strStatus),
    CONSTRAINT chk_invitation_status CHECK (strStatus IN ('pending', 'accepted', 'revoked', 'expired')),
    CONSTRAINT fk_invitation_organization FOREIGN KEY (intOrganizationID) REFERENCES customers (intCustomerID) ON DELETE CASCADE,
    CONSTRAINT fk_invitation_sender FOREIGN KEY (intInvitedBy) REFERENCES users (intUserID) ON DELETE SET NULL,
    CONSTRAINT fk_invitation_acceptor FOREIGN KEY (intAcceptedBy) REFERENCES users (intUserID) ON DELETE SET NULL,
    CONSTRAINT fk_invitation_role FOREIGN KEY (strRoleKey) REFERENCES access_roles (strRoleKey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Serialize identity creation for simultaneous invitation acceptances in different organizations.
CREATE TABLE identity_email_locks (
    strEmail VARCHAR(100) NOT NULL PRIMARY KEY
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO system_mappings (strMapping, strPath) VALUES
    ('organization-invitation', 'frontend/core/views/organization_invitation.cfm'),
    ('accept-organization-invitation', 'frontend/core/handler/organization_invitation.cfm');

INSERT IGNORE INTO system_translations (strVariable, strStringDE, strStringEN) VALUES
    ('msgMembershipContextChanged', 'Der Organisations- oder Mandantenkontext hat sich geändert. Laden Sie die Seite neu und prüfen Sie Ihre Eingaben.', 'The organization or tenant context has changed. Reload the page and review your input.'),
    ('titOrganizationInvitations', 'Einladungen', 'Invitations'),
    ('btnInviteMember', 'Mitglied einladen', 'Invite member'),
    ('btnAcceptInvitation', 'Einladung annehmen', 'Accept invitation'),
    ('btnRevokeInvitation', 'Einladung widerrufen', 'Revoke invitation'),
    ('btnResendInvitation', 'Erneut senden', 'Resend'),
    ('txtInvitation_pending', 'Ausstehend', 'Pending'),
    ('txtInvitation_accepted', 'Angenommen', 'Accepted'),
    ('txtInvitation_revoked', 'Widerrufen', 'Revoked'),
    ('txtInvitation_expired', 'Abgelaufen', 'Expired'),
    ('txtInvitationEmail', 'E-Mail-Adresse', 'Email address'),
    ('txtInvitationPassword', 'Passwort für Ihr neues Konto', 'Password for your new account'),
    ('txtInvitationName', 'Ihr Name', 'Your name'),
    ('txtInvitationLogin', 'Melden Sie sich mit dem eingeladenen Konto an, um diese Einladung anzunehmen.', 'Sign in with the invited account to accept this invitation.'),
    ('txtInvitationIntro', 'Sie wurden in die Organisation {organization} eingeladen. Erst mit Ihrer Annahme erhalten Sie die aufgeführten Zugriffe.', 'You have been invited to {organization}. The listed access is granted only after you accept.'),
    ('txtInvitationCreateInfo', 'Laden Sie neue oder bereits registrierte Personen ein. Der Link ist sieben Tage gültig. Die Einladung erteilt noch keinen Zugriff.', 'Invite new or already registered people. The link is valid for seven days. An invitation does not grant access.'),
    ('txtInvitationExpiry', 'Gültig bis', 'Valid until'),
    ('msgInvitationSent', 'Die Einladung wurde versendet.', 'The invitation has been sent.'),
    ('msgInvitationRevoked', 'Die Einladung wurde widerrufen.', 'The invitation has been revoked.'),
    ('msgInvitationAccepted', 'Die Einladung wurde angenommen. Sie können sich nun anmelden und die Organisation auswählen.', 'The invitation has been accepted. You can now sign in and select the organization.'),
    ('msgInvitationInvalid', 'Diese Einladung ist nicht gültig oder kann mit diesem Konto nicht angenommen werden. Prüfen Sie Ihr Konto oder lassen Sie eine neue Einladung senden.', 'This invitation is invalid or cannot be accepted with this account. Check your account or request a new invitation.'),
    ('txtInvitationMailSubject', 'Einladung zu {organization}', 'Invitation to {organization}');
