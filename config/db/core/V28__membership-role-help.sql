SET NAMES utf8mb4;

-- Explain the built-in roles without overwriting customized translations.
INSERT IGNORE INTO system_translations (strVariable, strStringDE, strStringEN) VALUES
    ('titMembershipRoleHelp', 'Rollen und Berechtigungen', 'Roles and permissions'),
    ('txtMembershipRoleHelpIntro', 'Organisationsrollen gelten für die gesamte Organisation. Mandantenrollen gelten nur für den jeweils zugewiesenen Mandanten.', 'Organization roles apply to the entire organization. Tenant roles apply only to the tenant they are assigned to.'),
    ('txtMembershipRoleHelpRole', 'Rolle', 'Role'),
    ('txtMembershipRoleHelpPermissions', 'Berechtigungen', 'Permissions'),
    ('txtMembershipRoleHelp_organization', 'Organisationsrollen', 'Organization roles'),
    ('txtMembershipRoleHelp_tenant', 'Mandantenrollen', 'Tenant roles'),
    ('txtMembershipRoleHelp_organization_owner', 'Verwaltet die Organisation und alle zugehörigen Mandanten, einschliesslich Einstellungen und Abrechnung. Kann Organisationsadmins und Eigentümer bestimmen sowie die Eigentümerschaft übertragen.', 'Manages the organization and all its tenants, including settings and billing. Can appoint organization admins and owners and transfer ownership.'),
    ('txtMembershipRoleHelp_organization_admin', 'Verwaltet die Organisation, Mandanten, normale Mitglieder, Einstellungen und Abrechnung. Kann keine Eigentümer oder anderen Organisationsadmins verwalten.', 'Manages the organization, tenants, regular members, settings and billing. Cannot manage owners or other organization admins.'),
    ('txtMembershipRoleHelp_organization_member', 'Hat keinen automatischen Mandantenzugriff. Die Berechtigungen werden für jeden Mandanten separat über eine Mandantenrolle vergeben.', 'Has no automatic tenant access. Permissions are assigned separately for each tenant through a tenant role.'),
    ('txtMembershipRoleHelp_tenant_admin', 'Verwaltet Inhalte, Einstellungen, Abrechnung und die Zugriffe bestehender Organisationsmitglieder im zugewiesenen Mandanten. Kann keine neuen Benutzer anlegen.', 'Manages content, settings, billing and access for existing organization members in the assigned tenant. Cannot create new users.'),
    ('txtMembershipRoleHelp_tenant_editor', 'Kann Inhalte im zugewiesenen Mandanten ansehen und bearbeiten. Keine Benutzerverwaltung, Mandanteneinstellungen oder Abrechnung.', 'Can view and edit content in the assigned tenant. No user management, tenant settings or billing access.'),
    ('txtMembershipRoleHelp_tenant_viewer', 'Kann freigegebene Inhalte im zugewiesenen Mandanten ansehen. Keine Bearbeitung, Benutzerverwaltung, Mandanteneinstellungen oder Abrechnung.', 'Can view available content in the assigned tenant. No editing, user management, tenant settings or billing access.'),
    ('txtMembershipRoleHelpInherited', 'Eigentümer und Organisationsadmins haben automatisch Zugriff auf alle Mandanten. Einzelne Mandantenrollen schränken diesen Zugriff nicht ein.', 'Owners and organization admins automatically have access to all tenants. Individual tenant roles do not restrict this access.'),
    ('txtMembershipRoleHelpPlatform', 'Plattformadministratoren verwalten das Gesamtsystem. Diese Berechtigung kann hier nicht vergeben werden.', 'Platform administrators manage the overall system. This permission cannot be assigned here.');
