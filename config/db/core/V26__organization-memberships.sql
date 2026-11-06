SET NAMES utf8mb4;

-- Additive foundation only. Legacy users/customer_user remain authoritative until
-- the audited backfill and the login/handler cutover are implemented together.
-- Re-running this migration preserves memberships and existing role definitions.

CREATE TABLE IF NOT EXISTS access_roles (
    strRoleKey VARCHAR(50) NOT NULL,
    strScope VARCHAR(20) NOT NULL,
    PRIMARY KEY (strRoleKey),
    UNIQUE KEY uq_access_role_scope (strRoleKey, strScope),
    CONSTRAINT chk_access_role_scope CHECK (strScope IN ('organization', 'tenant'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS access_permissions (
    strPermissionKey VARCHAR(80) NOT NULL,
    strScope VARCHAR(20) NOT NULL,
    PRIMARY KEY (strPermissionKey),
    CONSTRAINT chk_access_permission_scope CHECK (strScope IN ('organization', 'tenant'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS access_role_permissions (
    strRoleKey VARCHAR(50) NOT NULL,
    strPermissionKey VARCHAR(80) NOT NULL,
    PRIMARY KEY (strRoleKey, strPermissionKey),
    CONSTRAINT fk_access_grant_role FOREIGN KEY (strRoleKey)
        REFERENCES access_roles (strRoleKey) ON DELETE CASCADE,
    CONSTRAINT fk_access_grant_permission FOREIGN KEY (strPermissionKey)
        REFERENCES access_permissions (strPermissionKey) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS organization_memberships (
    intOrgMembershipID INT NOT NULL AUTO_INCREMENT,
    intOrganizationID INT NOT NULL,
    intUserID INT NOT NULL,
    strRoleKey VARCHAR(50) NOT NULL DEFAULT 'organization.member',
    strRoleScope VARCHAR(20) NOT NULL DEFAULT 'organization',
    strStatus VARCHAR(20) NOT NULL DEFAULT 'active',
    dtmCreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dtmUpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (intOrgMembershipID),
    UNIQUE KEY uq_organization_membership_user (intUserID),
    KEY ix_organization_membership_customer (intOrganizationID),
    CONSTRAINT chk_organization_membership_scope CHECK (strRoleScope = 'organization'),
    CONSTRAINT chk_organization_membership_status CHECK (strStatus IN ('active', 'suspended')),
    CONSTRAINT fk_organization_membership_customer FOREIGN KEY (intOrganizationID)
        REFERENCES customers (intCustomerID) ON DELETE CASCADE,
    CONSTRAINT fk_organization_membership_user FOREIGN KEY (intUserID)
        REFERENCES users (intUserID) ON DELETE CASCADE,
    CONSTRAINT fk_organization_membership_role FOREIGN KEY (strRoleKey, strRoleScope)
        REFERENCES access_roles (strRoleKey, strScope)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tenant_memberships (
    intTenantMembershipID INT NOT NULL AUTO_INCREMENT,
    intOrgMembershipID INT NOT NULL,
    intCustomerID INT NOT NULL,
    strRoleKey VARCHAR(50) NOT NULL DEFAULT 'tenant.viewer',
    strRoleScope VARCHAR(20) NOT NULL DEFAULT 'tenant',
    strStatus VARCHAR(20) NOT NULL DEFAULT 'active',
    dtmCreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dtmUpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (intTenantMembershipID),
    UNIQUE KEY uq_tenant_membership (intOrgMembershipID, intCustomerID),
    KEY ix_tenant_membership_customer (intCustomerID),
    CONSTRAINT chk_tenant_membership_scope CHECK (strRoleScope = 'tenant'),
    CONSTRAINT chk_tenant_membership_status CHECK (strStatus IN ('active', 'suspended')),
    CONSTRAINT fk_tenant_membership_organization FOREIGN KEY (intOrgMembershipID)
        REFERENCES organization_memberships (intOrgMembershipID) ON DELETE CASCADE,
    CONSTRAINT fk_tenant_membership_customer FOREIGN KEY (intCustomerID)
        REFERENCES customers (intCustomerID) ON DELETE CASCADE,
    CONSTRAINT fk_tenant_membership_role FOREIGN KEY (strRoleKey, strRoleScope)
        REFERENCES access_roles (strRoleKey, strScope)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO access_roles (strRoleKey, strScope) VALUES
    ('organization.owner', 'organization'),
    ('organization.admin', 'organization'),
    ('organization.member', 'organization'),
    ('tenant.admin', 'tenant'),
    ('tenant.editor', 'tenant'),
    ('tenant.viewer', 'tenant');

INSERT IGNORE INTO access_permissions (strPermissionKey, strScope) VALUES
    ('organization.view', 'organization'),
    ('organization.members.manage', 'organization'),
    ('organization.tenants.manage', 'organization'),
    ('organization.settings.manage', 'organization'),
    ('organization.ownership.transfer', 'organization'),
    ('organization.delete', 'organization'),
    ('tenant.view', 'tenant'),
    ('tenant.content.read', 'tenant'),
    ('tenant.content.write', 'tenant'),
    ('tenant.members.manage', 'tenant'),
    ('tenant.settings.manage', 'tenant'),
    ('tenant.billing.view', 'tenant'),
    ('tenant.billing.manage', 'tenant');

-- Explicit grants: future permissions must never be inherited through a wildcard.
INSERT IGNORE INTO access_role_permissions (strRoleKey, strPermissionKey) VALUES
    ('organization.owner', 'organization.view'),
    ('organization.owner', 'organization.members.manage'),
    ('organization.owner', 'organization.tenants.manage'),
    ('organization.owner', 'organization.settings.manage'),
    ('organization.owner', 'organization.ownership.transfer'),
    ('organization.owner', 'organization.delete'),
    ('organization.owner', 'tenant.view'),
    ('organization.owner', 'tenant.content.read'),
    ('organization.owner', 'tenant.content.write'),
    ('organization.owner', 'tenant.members.manage'),
    ('organization.owner', 'tenant.settings.manage'),
    ('organization.owner', 'tenant.billing.view'),
    ('organization.owner', 'tenant.billing.manage'),
    ('organization.admin', 'organization.view'),
    ('organization.admin', 'organization.members.manage'),
    ('organization.admin', 'organization.tenants.manage'),
    ('organization.admin', 'organization.settings.manage'),
    ('organization.admin', 'tenant.view'),
    ('organization.admin', 'tenant.content.read'),
    ('organization.admin', 'tenant.content.write'),
    ('organization.admin', 'tenant.members.manage'),
    ('organization.admin', 'tenant.settings.manage'),
    ('organization.admin', 'tenant.billing.view'),
    ('organization.admin', 'tenant.billing.manage'),
    ('organization.member', 'organization.view'),
    ('tenant.admin', 'tenant.view'),
    ('tenant.admin', 'tenant.content.read'),
    ('tenant.admin', 'tenant.content.write'),
    ('tenant.admin', 'tenant.members.manage'),
    ('tenant.admin', 'tenant.settings.manage'),
    ('tenant.admin', 'tenant.billing.view'),
    ('tenant.admin', 'tenant.billing.manage'),
    ('tenant.editor', 'tenant.view'),
    ('tenant.editor', 'tenant.content.read'),
    ('tenant.editor', 'tenant.content.write'),
    ('tenant.viewer', 'tenant.view'),
    ('tenant.viewer', 'tenant.content.read');
