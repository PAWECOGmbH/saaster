component output="false" hint="Organization and tenant permissions, independent of legacy session role flags." {

    // Identity must come from the authenticated session, never from submitted user IDs.
    // Query current membership state on every call so revocations take effect immediately.
    public boolean function canInOrganization(required numeric userID, required numeric organizationID, required string permission) {
        local.permissions = getOrganizationPermissions(arguments.userID, arguments.organizationID);
        return listFindNoCase(valueList(local.permissions.strPermissionKey), arguments.permission) gt 0;
    }

    public boolean function canInTenant(required numeric userID, required numeric customerID, required string permission) {
        local.permissions = getTenantPermissions(arguments.userID, arguments.customerID);
        return listFindNoCase(valueList(local.permissions.strPermissionKey), arguments.permission) gt 0;
    }

    // Only a root customer is an organization. Children and malformed hierarchies
    // cannot be used as organization contexts, even if a membership row exists.
    private query function coreOrganizationPermissions(required numeric userID, required numeric organizationID) {
        return queryExecute(
            options = {datasource: application.datasource},
            params = {
                userID: {type: "integer", value: arguments.userID},
                organizationID: {type: "integer", value: arguments.organizationID}
            },
            sql = "
                SELECT permissions.strPermissionKey
                FROM organization_memberships membership
                INNER JOIN users ON users.intUserID = membership.intUserID
                INNER JOIN customers organization ON organization.intCustomerID = membership.intOrganizationID
                INNER JOIN access_roles role ON role.strRoleKey = membership.strRoleKey AND role.strScope = 'organization'
                INNER JOIN access_role_permissions grants ON grants.strRoleKey = role.strRoleKey
                INNER JOIN access_permissions permissions ON permissions.strPermissionKey = grants.strPermissionKey
                WHERE membership.intUserID = :userID
                    AND membership.intOrganizationID = :organizationID
                    AND membership.strStatus = 'active'
                    AND users.blnActive = 1
                    AND organization.blnActive = 1
                    AND organization.intCustParentID = 0
                    AND permissions.strScope = 'organization'
                ORDER BY permissions.strPermissionKey
            "
        );
    }

    // The root can also hold business data and is a valid tenant context.
    // Organization-wide grants are inherited; regular members need an explicit
    // active assignment to this exact customer. Assignments outside the family
    // and grandchildren are rejected even if inconsistent rows were imported.
    private query function coreTenantPermissions(required numeric userID, required numeric customerID) {
        return queryExecute(
            options = {datasource: application.datasource},
            params = {
                userID: {type: "integer", value: arguments.userID},
                customerID: {type: "integer", value: arguments.customerID}
            },
            sql = "
                SELECT DISTINCT permissions.strPermissionKey
                FROM customers tenant
                INNER JOIN customers organization ON organization.intCustomerID =
                    CASE WHEN tenant.intCustParentID = 0 THEN tenant.intCustomerID ELSE tenant.intCustParentID END
                INNER JOIN organization_memberships membership ON membership.intOrganizationID = organization.intCustomerID
                INNER JOIN users ON users.intUserID = membership.intUserID
                INNER JOIN access_roles organizationRole
                    ON organizationRole.strRoleKey = membership.strRoleKey AND organizationRole.strScope = 'organization'
                LEFT JOIN tenant_memberships assignment
                    ON assignment.intOrgMembershipID = membership.intOrgMembershipID
                    AND assignment.intCustomerID = tenant.intCustomerID AND assignment.strStatus = 'active'
                LEFT JOIN access_roles tenantRole ON tenantRole.strRoleKey = assignment.strRoleKey AND tenantRole.strScope = 'tenant'
                INNER JOIN access_role_permissions grants
                    ON grants.strRoleKey = organizationRole.strRoleKey OR grants.strRoleKey = tenantRole.strRoleKey
                INNER JOIN access_permissions permissions ON permissions.strPermissionKey = grants.strPermissionKey
                WHERE membership.intUserID = :userID
                    AND tenant.intCustomerID = :customerID
                    AND membership.strStatus = 'active'
                    AND users.blnActive = 1
                    AND organization.blnActive = 1
                    AND organization.intCustParentID = 0
                    AND tenant.blnActive = 1
                    AND permissions.strScope = 'tenant'
                ORDER BY permissions.strPermissionKey
            "
        );
    }

    public query function getOrganizationPermissions(required numeric userID, required numeric organizationID) {
        local.permissions = coreOrganizationPermissions(arguments.userID, arguments.organizationID);
        local.roles = queryExecute(
            options = {datasource: application.datasource},
            params = {userID: {type: "integer", value: arguments.userID}, organizationID: {type: "integer", value: arguments.organizationID}},
            sql = "SELECT membership.strRoleKey FROM organization_memberships membership
                INNER JOIN users ON users.intUserID = membership.intUserID
                INNER JOIN customers organization ON organization.intCustomerID = membership.intOrganizationID
                WHERE membership.intUserID = :userID AND membership.intOrganizationID = :organizationID
                    AND membership.strStatus = 'active' AND users.blnActive = 1
                    AND organization.blnActive = 1 AND organization.intCustParentID = 0"
        );
        return appendExtensionPermissions(local.permissions, "organization", valueArray(local.roles.strRoleKey));
    }

    public query function getTenantPermissions(required numeric userID, required numeric customerID) {
        local.permissions = coreTenantPermissions(arguments.userID, arguments.customerID);
        // Extension grants never create access to a tenant by themselves.
        if (not listFindNoCase(valueList(local.permissions.strPermissionKey), "tenant.view")) {
            return local.permissions;
        }
        local.roles = queryExecute(
            options = {datasource: application.datasource},
            params = {userID: {type: "integer", value: arguments.userID}, customerID: {type: "integer", value: arguments.customerID}},
            sql = "SELECT membership.strRoleKey AS organizationRole, assignment.strRoleKey AS tenantRole
                FROM customers customer
                INNER JOIN organization_memberships membership ON membership.intOrganizationID =
                    CASE WHEN customer.intCustParentID = 0 THEN customer.intCustomerID ELSE customer.intCustParentID END
                LEFT JOIN tenant_memberships assignment ON assignment.intOrgMembershipID = membership.intOrgMembershipID
                    AND assignment.intCustomerID = customer.intCustomerID AND assignment.strStatus = 'active'
                WHERE membership.intUserID = :userID AND customer.intCustomerID = :customerID AND membership.strStatus = 'active'"
        );
        local.roleKeys = valueArray(local.roles.organizationRole);
        arrayAppend(local.roleKeys, valueArray(local.roles.tenantRole), true);
        return appendExtensionPermissions(local.permissions, "tenant", local.roleKeys);
    }

    private query function appendExtensionPermissions(required query permissions, required string scope, required array roles) {
        loop array=application.objAccessRegistry.granted(arguments.scope, arguments.roles) item="local.key" {
            if (not listFindNoCase(valueList(arguments.permissions.strPermissionKey), local.key)) {
                queryAddRow(arguments.permissions, {strPermissionKey: local.key});
            }
        }
        return arguments.permissions;
    }

}
