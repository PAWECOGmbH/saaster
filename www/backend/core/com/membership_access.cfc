component output="false" hint="Membership activation, session context and request authorization." {

    public struct function organizationForCustomer(required numeric customerID) {
        local.q = queryExecute(
            options = {datasource: application.datasource},
            params = {id: {type: "integer", value: arguments.customerID}},
            sql = "SELECT organization.intCustomerID, organization.strCompanyName, organization.strContactPerson, organization.blnActive, access.intOrganizationID AS activated
                FROM customers customer INNER JOIN customers organization ON organization.intCustomerID =
                    CASE WHEN customer.intCustParentID = 0 THEN customer.intCustomerID ELSE customer.intCustParentID END
                LEFT JOIN organization_access access ON access.intOrganizationID = organization.intCustomerID
                WHERE customer.intCustomerID = :id AND organization.intCustParentID = 0"
        );
        return {id: val(local.q.intCustomerID), name: len(trim(local.q.strCompanyName)) ? local.q.strCompanyName : local.q.strContactPerson, enabled: val(local.q.activated) gt 0, active: val(local.q.blnActive) eq 1};
    }

    public struct function organizationForUser(required numeric userID) {
        local.q = queryExecute(
            options = {datasource: application.datasource},
            params = {id: {type: "integer", value: arguments.userID}},
            sql = "SELECT intCustomerID FROM users WHERE intUserID = :id"
        );
        return organizationForCustomer(val(local.q.intCustomerID));
    }

    public query function tenants(required numeric userID) {
        return queryExecute(
            options = {datasource: application.datasource},
            params = {userID: {type: "integer", value: arguments.userID}},
            sql = "SELECT DISTINCT customer.*, IF(preference.intDefaultCustomerID = customer.intCustomerID, 1, 0) AS blnStandard,
                    IF(membership.strRoleKey IN ('organization.owner', 'organization.admin'), 'tenant.admin', assignment.strRoleKey) AS tenantRole,
                    IF(membership.strRoleKey IN ('organization.owner', 'organization.admin'), 1, 0) AS blnSuperAdmin,
                    IF(membership.strRoleKey IN ('organization.owner', 'organization.admin') OR assignment.strRoleKey = 'tenant.admin', 1, 0) AS blnAdmin
                FROM organization_memberships membership INNER JOIN users ON users.intUserID = membership.intUserID
                INNER JOIN customers organization ON organization.intCustomerID = membership.intOrganizationID
                INNER JOIN customers customer ON customer.intCustomerID = organization.intCustomerID OR customer.intCustParentID = organization.intCustomerID
                LEFT JOIN tenant_memberships assignment ON assignment.intOrgMembershipID = membership.intOrgMembershipID
                    AND assignment.intCustomerID = customer.intCustomerID AND assignment.strStatus = 'active'
                LEFT JOIN membership_preferences preference ON preference.intUserID = users.intUserID
                INNER JOIN access_role_permissions grants ON grants.strRoleKey = membership.strRoleKey OR grants.strRoleKey = assignment.strRoleKey
                WHERE users.intUserID = :userID AND users.blnActive = 1 AND membership.strStatus = 'active'
                    AND organization.intCustParentID = 0 AND organization.blnActive = 1 AND customer.blnActive = 1
                    AND grants.strPermissionKey = 'tenant.view'
                ORDER BY blnStandard DESC, customer.intCustomerID"
        );
    }

    public struct function context(required numeric userID, numeric customerID = 0, boolean allowFallback = true) {
        local.organization = organizationForUser(arguments.userID);
        local.result = {enabled: local.organization.enabled, allowed: false, organizationID: local.organization.id, customerID: 0};
        if (not local.result.enabled) {
            return local.result;
        }
        local.tenants = tenants(arguments.userID);
        if (not local.tenants.recordCount) {
            return local.result;
        }
        if (arguments.customerID gt 0 and listFind(valueList(local.tenants.intCustomerID), arguments.customerID)) {
            local.result.customerID = arguments.customerID;
        } else if (arguments.allowFallback) {
            local.result.customerID = local.tenants.intCustomerID[1];
        } else {
            return local.result;
        }
        local.user = queryExecute(
            options = {datasource: application.datasource},
            params = {id: {type: "integer", value: arguments.userID}},
            sql = "SELECT users.strFirstName, users.strLastName, users.strEmail, users.strLanguage, users.blnSysAdmin, membership.strRoleKey
                FROM users INNER JOIN organization_memberships membership ON membership.intUserID = users.intUserID WHERE users.intUserID = :id"
        );
        local.result.allowed = true;
        local.result.role = local.user.strRoleKey;
        local.result.admin = application.objAuthorization.canInTenant(arguments.userID, local.result.customerID, "tenant.settings.manage");
        local.result.superadmin = application.objAuthorization.canInTenant(arguments.userID, local.result.customerID, "tenant.billing.manage");
        local.result.sysadmin = local.user.blnSysAdmin eq 1;
        local.result.name = local.user.strFirstName & " " & local.user.strLastName;
        local.result.email = local.user.strEmail;
        local.result.language = local.user.strLanguage;
        return local.result;
    }

    // Existing sessions may not silently continue a mutation in a different tenant
    // after losing access. Login/MFA may select a new permitted default explicitly.
    public boolean function refreshSession(boolean allowFallback = false) {
        if (not structKeyExists(session, "user_id")) {
            return true;
        }
        local.context = context(session.user_id, session.customer_id ?: 0, arguments.allowFallback);
        if ((session.membership_access ?: false) and not local.context.enabled) {
            loop list="user_id,customer_id,admin,superadmin,sysadmin,membership_access,organization_id,user_name,user_email" index="local.key" {
                structDelete(session, local.key);
            }
            return false;
        }
        if (not local.context.enabled) {
            structDelete(session, "membership_access");
            structDelete(session, "organization_id");
            return true;
        }
        if (not local.context.allowed) {
            loop list="user_id,customer_id,admin,superadmin,sysadmin,membership_access,organization_id" index="local.key" {
                structDelete(session, local.key);
            }
            return false;
        }
        session.membership_access = true;
        session.organization_id = local.context.organizationID;
        session.customer_id = local.context.customerID;
        session.admin = local.context.admin;
        session.superadmin = local.context.superadmin;
        session.sysadmin = local.context.sysadmin and not (session.supportLogin ?: false);
        session.user_name = local.context.name;
        session.user_email = local.context.email;
        return true;
    }

    public struct function managementData(required numeric userID, required numeric customerID) {
        local.org = organizationForCustomer(arguments.customerID);
        if ((local.org.enabled and not canManage(arguments.userID, arguments.customerID))
            or (not local.org.enabled and not canSetup(arguments.userID, local.org.id))) {
            throw(type = "Saaster.Membership.Forbidden", message = "Member administration is not allowed.");
        }
        local.params = {organizationID: {type: "integer", value: local.org.id}, customerID: {type: "integer", value: arguments.customerID}};
        local.manageOrganization = local.org.enabled and application.objAuthorization.canInOrganization(arguments.userID, local.org.id, "organization.members.manage");
        local.members = queryExecute(
            options = {datasource: application.datasource}, params = local.params,
            sql = "SELECT users.intUserID, users.strFirstName, users.strLastName, users.strEmail, users.blnActive, users.blnSysAdmin,
                    CASE WHEN COALESCE(users.strPasswordHash, '') = '' AND COALESCE(users.strPasswordSalt, '') = '' THEN 1 ELSE 0 END AS activationPending,
                    COALESCE(membership.strRoleKey, '') AS role, COALESCE(membership.strStatus, '') AS status
                FROM users INNER JOIN customers home ON home.intCustomerID = users.intCustomerID
                LEFT JOIN organization_memberships membership ON membership.intUserID = users.intUserID AND membership.intOrganizationID = :organizationID
                WHERE (home.intCustomerID = :organizationID OR home.intCustParentID = :organizationID)
                ORDER BY users.strLastName, users.strFirstName, users.intUserID"
        );
        // Tenant admins may assign existing organization members only, and only
        // see the assignments in their current tenant.
        if (local.org.enabled and not local.manageOrganization) {
            local.members = local.members.filter((member) => len(member.role) gt 0);
        }
        local.params.allTenants = {type: "boolean", value: not local.org.enabled or local.manageOrganization};
        local.tenants = queryExecute(
            options = {datasource: application.datasource}, params = local.params,
            sql = "SELECT intCustomerID, strCompanyName, blnActive FROM customers
                WHERE (intCustomerID = :organizationID OR intCustParentID = :organizationID)
                    AND (:allTenants = 1 OR intCustomerID = :customerID) ORDER BY intCustParentID, intCustomerID"
        );
        local.assignments = queryExecute(
            options = {datasource: application.datasource}, params = local.params,
            sql = "SELECT membership.intUserID, assignment.intCustomerID, assignment.strRoleKey, assignment.strStatus
                FROM tenant_memberships assignment INNER JOIN organization_memberships membership ON membership.intOrgMembershipID = assignment.intOrgMembershipID
                WHERE membership.intOrganizationID = :organizationID AND (:allTenants = 1 OR assignment.intCustomerID = :customerID)"
        );
        return {organization: local.org, members: local.members, tenants: local.tenants, assignments: local.assignments,
            manageOrganization: local.manageOrganization,
            owner: local.org.enabled and application.objAuthorization.canInOrganization(arguments.userID, local.org.id, "organization.ownership.transfer")};
    }

    public string function roleLabel(required string role) {
        local.labels = {"organization.owner": "txtMembershipOwner", "organization.admin": "txtMembershipOrgAdmin", "organization.member": "txtMembershipMember",
            "tenant.admin": "txtMembershipTenantAdmin", "tenant.editor": "txtMembershipEditor", "tenant.viewer": "txtMembershipViewer"};
        return local.labels[arguments.role] ?: "txtMembershipNoAccess";
    }

    public boolean function canManage(required numeric userID, required numeric customerID) {
        local.organization = organizationForCustomer(arguments.customerID);
        return application.objAuthorization.canInOrganization(arguments.userID, local.organization.id, "organization.members.manage")
            or application.objAuthorization.canInTenant(arguments.userID, arguments.customerID, "tenant.members.manage");
    }

    public boolean function canSetup(required numeric userID, required numeric organizationID) {
        local.q = queryExecute(
            options = {datasource: application.datasource},
            params = {userID: {type: "integer", value: arguments.userID}, organizationID: {type: "integer", value: arguments.organizationID}},
            sql = "SELECT users.intUserID FROM users INNER JOIN customers organization ON organization.intCustomerID = users.intCustomerID
                INNER JOIN customer_user assigned ON assigned.intUserID = users.intUserID AND assigned.intCustomerID = organization.intCustomerID
                WHERE users.intUserID = :userID AND organization.intCustomerID = :organizationID AND organization.intCustParentID = 0
                    AND users.blnActive = 1 AND organization.blnActive = 1 AND users.blnSuperAdmin = 1"
        );
        return local.q.recordCount gt 0;
    }

    public boolean function allowRequest(required numeric userID, required numeric customerID, required string path, required string method, struct submitted = {}, struct queryString = {}) {
        local.path = lCase(reReplace(arguments.path, "^/", ""));
        local.org = organizationForCustomer(arguments.customerID);
        if (listFindNoCase("backend/core/views/customer/memberships.cfm,backend/core/handler/memberships.cfm", local.path)) {
            return local.org.enabled ? canManage(arguments.userID, arguments.customerID) : canSetup(arguments.userID, local.org.id);
        }
        if (not local.org.enabled) {
            return true;
        }
        local.authorization = application.objAuthorization;
        if (find("/sysadmin/", local.path)) {
            return session.sysadmin ?: false;
        }
        if (local.path eq "frontend/core/handler/register.cfm") {
            return not structKeyExists(arguments.submitted, "fill_remaining_data")
                or local.authorization.canInTenant(arguments.userID, arguments.customerID, "tenant.settings.manage");
        }
        if (left(local.path, 8) neq "backend/") {
            return true;
        }
        if (listFindNoCase("backend/core/views/customer/user_new.cfm", local.path)) {
            return local.authorization.canInOrganization(arguments.userID, local.org.id, "organization.members.manage");
        }
        if (local.path eq "backend/core/handler/user.cfm") {
            if (structKeyExists(arguments.submitted, "user_new_btn")) {
                return local.authorization.canInOrganization(arguments.userID, local.org.id, "organization.members.manage");
            }
            if (structKeyExists(arguments.queryString, "delete") or structKeyExists(arguments.queryString, "invit")) {
                return false;
            }
            return (not structKeyExists(arguments.submitted, "userID") or arguments.submitted.userID eq arguments.userID)
                and (not structKeyExists(arguments.submitted, "customerID") or arguments.submitted.customerID eq arguments.customerID);
        }
        if (find("/customer/user_edit.cfm", local.path) or find("/customer/users.cfm", local.path)) {
            return canManage(arguments.userID, arguments.customerID);
        }
        if (local.path eq "backend/core/handler/customer.cfm") {
            if (structKeyExists(arguments.queryString, "sysadmin")) {
                return true; // The handler validates the saved support origin against the database.
            }
            if (structKeyExists(arguments.submitted, "new_tenant_btn") or structKeyExists(arguments.queryString, "delete") or structKeyExists(arguments.queryString, "change_tenant")) {
                return local.authorization.canInOrganization(arguments.userID, local.org.id, "organization.tenants.manage");
            }
            return local.authorization.canInTenant(arguments.userID, arguments.customerID, "tenant.settings.manage");
        }
        if (find("/customer/tenant", local.path)) {
            return local.authorization.canInOrganization(arguments.userID, local.org.id, "organization.tenants.manage");
        }
        if (find("/customer/company", local.path) or find("/customer/settings.cfm", local.path)) {
            return local.authorization.canInTenant(arguments.userID, arguments.customerID, "tenant.settings.manage");
        }
        if (find("/views/invoices/", local.path)) {
            return local.authorization.canInTenant(arguments.userID, arguments.customerID, "tenant.billing.view");
        }
        if (reFind("/(handler/(book[^/]*|cancel|payment|invoices)|views/customer/(plans|modules|payment))\.cfm$", local.path)) {
            // Organization deletion is a separate lifecycle operation; the legacy
            // cancel handler would orphan children and delete identities implicitly.
            if (structKeyExists(arguments.submitted, "delete")) {
                return false;
            }
            return local.authorization.canInTenant(arguments.userID, arguments.customerID, "tenant.billing.manage");
        }
        if (local.path eq "backend/core/handler/global.cfm" and structKeyExists(arguments.queryString, "switch")) {
            return isValid("integer", arguments.queryString.switch)
                and local.authorization.canInTenant(arguments.userID, arguments.queryString.switch, "tenant.view");
        }
        // Personal settings remain available to readers. Unclassified handlers and
        // extension pages require write access until their own read policy is defined.
        if (local.path eq "backend/core/handler/dashboard-settings.cfm") {
            return true;
        }
        if (find("/handler/", local.path) or arguments.method neq "GET" or not find("backend/core/", local.path)) {
            return local.authorization.canInTenant(arguments.userID, arguments.customerID, "tenant.content.write");
        }
        return local.authorization.canInTenant(arguments.userID, arguments.customerID, "tenant.view");
    }

}
