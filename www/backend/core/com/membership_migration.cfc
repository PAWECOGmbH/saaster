component output="false" hint="Legacy membership audit, preview and explicit transactional activation." {

    // Called only by the authenticated setup handler. Rebuild the preview under
    // locks; never import a role list supplied by the browser.
    public void function activate(required numeric actorUserID, required numeric organizationID, required numeric ownerUserID, required boolean reviewed) {
        if (not arguments.reviewed) {
            throw(type = "Saaster.Membership.ReviewRequired", message = "Review the proposed roles before activation.");
        }
        transaction isolation="read_committed" {
            local.params = {organizationID: {type: "integer", value: arguments.organizationID}};
            local.root = queryExecute(
                options = {datasource: application.datasource}, params = local.params,
                sql = "SELECT intCustomerID FROM customers WHERE intCustomerID = :organizationID AND intCustParentID = 0 AND blnActive = 1 FOR UPDATE"
            );
            if (not local.root.recordCount or not application.objMembershipAccess.canSetup(arguments.actorUserID, arguments.organizationID)) {
                throw(type = "Saaster.Membership.Forbidden", message = "Organization setup requires its active legacy administrator.");
            }
            local.activated = queryExecute(
                options = {datasource: application.datasource}, params = local.params,
                sql = "SELECT intOrganizationID FROM organization_access WHERE intOrganizationID = :organizationID"
            );
            if (local.activated.recordCount) {
                return;
            }
            local.existing = queryExecute(
                options = {datasource: application.datasource}, params = local.params,
                sql = "SELECT intOrgMembershipID FROM organization_memberships WHERE intOrganizationID = :organizationID FOR UPDATE"
            );
            if (local.existing.recordCount) {
                throw(type = "Saaster.Membership.ExistingMemberships", message = "Existing prepared memberships must be reviewed before activation.");
            }
            queryExecute(
                options = {datasource: application.datasource}, params = local.params,
                sql = "SELECT intCustomerID FROM customers WHERE intCustParentID = :organizationID FOR UPDATE"
            );
            queryExecute(
                options = {datasource: application.datasource}, params = local.params,
                sql = "SELECT users.intUserID FROM users INNER JOIN customers home ON home.intCustomerID = users.intCustomerID
                    WHERE home.intCustomerID = :organizationID OR home.intCustParentID = :organizationID FOR UPDATE"
            );
            queryExecute(
                options = {datasource: application.datasource}, params = local.params,
                sql = "SELECT assigned.intCustUserID FROM customer_user assigned INNER JOIN users ON users.intUserID = assigned.intUserID
                    INNER JOIN customers home ON home.intCustomerID = users.intCustomerID
                    WHERE home.intCustomerID = :organizationID OR home.intCustParentID = :organizationID FOR UPDATE"
            );
            if (not application.objMembershipAccess.canSetup(arguments.actorUserID, arguments.organizationID)) {
                throw(type = "Saaster.Membership.Forbidden", message = "The setup administrator is no longer authorized.");
            }
            local.preview = preview(arguments.organizationID, arguments.ownerUserID);
            loop array=local.preview.issues item="local.issue" {
                if (not listFind("scoped_superadmin,owner_access_expansion", local.issue.issueCode)) {
                    throw(type = "Saaster.Membership.MigrationBlocked", message = "Resolve the legacy assignment issues before activation.");
                }
            }
            local.ids = {};
            loop array=local.preview.members item="local.member" {
                queryExecute(
                    options = {datasource: application.datasource, result: "local.inserted"},
                    params = {
                        organizationID: local.params.organizationID, userID: {type: "integer", value: local.member.userID},
                        role: {type: "varchar", value: local.member.role}, status: {type: "varchar", value: local.member.status}
                    },
                    sql = "INSERT INTO organization_memberships (intOrganizationID, intUserID, strRoleKey, strStatus) VALUES (:organizationID, :userID, :role, :status)"
                );
                local.ids[toString(local.member.userID)] = local.inserted.generatedKey;
                queryExecute(
                    options = {datasource: application.datasource},
                    params = {userID: {type: "integer", value: local.member.userID}, customerID: {type: "integer", value: local.member.defaultCustomerID}},
                    sql = "INSERT INTO membership_preferences (intUserID, intDefaultCustomerID) VALUES (:userID, :customerID)"
                );
                // Identity belongs to the root. Deleting a child must not cascade
                // to accounts that still have access to the root or a sibling.
                queryExecute(
                    options = {datasource: application.datasource},
                    params = {organizationID: local.params.organizationID, userID: {type: "integer", value: local.member.userID}},
                    sql = "UPDATE users SET intCustomerID = :organizationID WHERE intUserID = :userID"
                );
            }
            queryExecute(
                options = {datasource: application.datasource}, params = local.params,
                sql = "INSERT IGNORE INTO membership_identities (intUserID)
                    SELECT intUserID FROM organization_memberships WHERE intOrganizationID = :organizationID"
            );
            loop array=local.preview.assignments item="local.assignment" {
                queryExecute(
                    options = {datasource: application.datasource},
                    params = {
                        membershipID: {type: "integer", value: local.ids[toString(local.assignment.userID)]},
                        customerID: {type: "integer", value: local.assignment.customerID}, role: {type: "varchar", value: local.assignment.role}
                    },
                    sql = "INSERT INTO tenant_memberships (intOrgMembershipID, intCustomerID, strRoleKey) VALUES (:membershipID, :customerID, :role)"
                );
            }
            queryExecute(
                options = {datasource: application.datasource},
                params = {organizationID: local.params.organizationID, actorID: {type: "integer", value: arguments.actorUserID}},
                sql = "INSERT INTO organization_access (intOrganizationID, intActivatedBy) VALUES (:organizationID, :actorID)"
            );
        }
    }

    // This also works before V26: only legacy tables are read. No identity,
    // membership, default tenant or owner is changed by the audit or preview.
    public query function audit(numeric organizationID = 0) {
        return queryExecute(
            options = {datasource: application.datasource},
            params = {organizationID: {type: "integer", value: arguments.organizationID}},
            sql = "
                SELECT issues.* FROM (
                    SELECT 'invalid_parent' AS issueCode, 'error' AS severity, 0 AS userID,
                        child.intCustomerID AS customerID, COALESCE(parent.intCustParentID, 0) AS organizationID,
                        child.intCustParentID AS otherOrganizationID, 1 AS occurrences
                    FROM customers child LEFT JOIN customers parent ON parent.intCustomerID = child.intCustParentID
                    WHERE child.intCustParentID <> 0 AND (parent.intCustomerID IS NULL OR parent.intCustParentID <> 0)

                    UNION ALL
                    SELECT 'incomplete_assignment', 'error', COALESCE(cu.intUserID, 0), COALESCE(cu.intCustomerID, 0),
                        COALESCE(CASE WHEN home.intCustParentID = 0 THEN home.intCustomerID ELSE home.intCustParentID END, 0),
                        COALESCE(CASE WHEN customer.intCustParentID = 0 THEN customer.intCustomerID ELSE customer.intCustParentID END, 0), 1
                    FROM customer_user cu LEFT JOIN customers customer ON customer.intCustomerID = cu.intCustomerID
                    LEFT JOIN users ON users.intUserID = cu.intUserID
                    LEFT JOIN customers home ON home.intCustomerID = users.intCustomerID
                    WHERE cu.intUserID IS NULL OR cu.intCustomerID IS NULL

                    UNION ALL
                    SELECT 'cross_organization_assignment', 'error', users.intUserID, assigned.intCustomerID,
                        CASE WHEN home.intCustParentID = 0 THEN home.intCustomerID ELSE home.intCustParentID END,
                        CASE WHEN assigned.intCustParentID = 0 THEN assigned.intCustomerID ELSE assigned.intCustParentID END, 1
                    FROM customer_user cu INNER JOIN users ON users.intUserID = cu.intUserID
                    INNER JOIN customers home ON home.intCustomerID = users.intCustomerID
                    INNER JOIN customers assigned ON assigned.intCustomerID = cu.intCustomerID
                    WHERE (CASE WHEN home.intCustParentID = 0 THEN home.intCustomerID ELSE home.intCustParentID END)
                        <> (CASE WHEN assigned.intCustParentID = 0 THEN assigned.intCustomerID ELSE assigned.intCustParentID END)

                    UNION ALL
                    SELECT 'duplicate_assignment', 'error', cu.intUserID, cu.intCustomerID,
                        CASE WHEN customer.intCustParentID = 0 THEN customer.intCustomerID ELSE customer.intCustParentID END, 0, COUNT(*)
                    FROM customer_user cu INNER JOIN customers customer ON customer.intCustomerID = cu.intCustomerID
                    GROUP BY cu.intUserID, cu.intCustomerID, customer.intCustomerID, customer.intCustParentID HAVING COUNT(*) > 1

                    UNION ALL
                    SELECT 'invalid_default_count', 'error', users.intUserID, home.intCustomerID,
                        CASE WHEN home.intCustParentID = 0 THEN home.intCustomerID ELSE home.intCustParentID END, 0,
                        SUM(CASE WHEN cu.blnStandard = 1 THEN 1 ELSE 0 END)
                    FROM users INNER JOIN customers home ON home.intCustomerID = users.intCustomerID
                    LEFT JOIN customer_user cu ON cu.intUserID = users.intUserID
                    GROUP BY users.intUserID, home.intCustomerID, home.intCustParentID
                    HAVING SUM(CASE WHEN cu.blnStandard = 1 THEN 1 ELSE 0 END) <> 1

                    UNION ALL
                    SELECT 'inactive_default_tenant', 'review', users.intUserID, assigned.intCustomerID,
                        CASE WHEN home.intCustParentID = 0 THEN home.intCustomerID ELSE home.intCustParentID END,
                        CASE WHEN assigned.intCustParentID = 0 THEN assigned.intCustomerID ELSE assigned.intCustParentID END, 1
                    FROM customer_user cu INNER JOIN users ON users.intUserID = cu.intUserID
                    INNER JOIN customers home ON home.intCustomerID = users.intCustomerID
                    INNER JOIN customers assigned ON assigned.intCustomerID = cu.intCustomerID
                    INNER JOIN customers organization ON organization.intCustomerID =
                        CASE WHEN home.intCustParentID = 0 THEN home.intCustomerID ELSE home.intCustParentID END
                    WHERE cu.blnStandard = 1 AND assigned.blnActive = 0 AND users.blnActive = 1
                        AND organization.intCustParentID = 0 AND organization.blnActive = 1
                ) issues
                WHERE :organizationID = 0 OR issues.organizationID = :organizationID OR issues.otherOrganizationID = :organizationID
                ORDER BY issues.issueCode, issues.userID, issues.customerID
            "
        );
    }

    public struct function preview(required numeric organizationID, numeric ownerUserID = 0) {
        local.result = {
            organizationID: arguments.organizationID, ownerUserID: arguments.ownerUserID,
            ownerCandidates: [], suggestedOwnerUserID: 0, members: [], assignments: [], issues: [], ready: false
        };
        local.organization = queryExecute(
            options = {datasource: application.datasource},
            params = {id: {type: "integer", value: arguments.organizationID}},
            sql = "SELECT intCustomerID, blnActive FROM customers WHERE intCustomerID = :id AND intCustParentID = 0"
        );
        if (not local.organization.recordCount) {
            local.result.issues.append({issueCode: "invalid_organization", severity: "error", userID: 0, customerID: arguments.organizationID});
            return local.result;
        }
        local.result.organizationActive = local.organization.blnActive eq 1;

        local.audit = audit(arguments.organizationID);
        loop query="local.audit" {
            local.result.issues.append({
                issueCode: local.audit.issueCode, severity: local.audit.severity,
                userID: local.audit.userID, customerID: local.audit.customerID
            });
        }

        local.customers = queryExecute(
            options = {datasource: application.datasource},
            params = {id: {type: "integer", value: arguments.organizationID}},
            sql = "SELECT intCustomerID FROM customers WHERE intCustomerID = :id OR intCustParentID = :id ORDER BY intCustomerID"
        );
        local.users = queryExecute(
            options = {datasource: application.datasource},
            params = {id: {type: "integer", value: arguments.organizationID}},
            sql = "SELECT users.intUserID, users.intCustomerID, users.blnActive, users.blnAdmin, users.blnSuperAdmin, users.blnSysAdmin
                FROM users INNER JOIN customers home ON home.intCustomerID = users.intCustomerID
                WHERE home.intCustomerID = :id OR home.intCustParentID = :id ORDER BY users.intUserID"
        );
        local.links = queryExecute(
            options = {datasource: application.datasource},
            params = {id: {type: "integer", value: arguments.organizationID}},
            sql = "SELECT cu.intUserID, cu.intCustomerID, cu.blnStandard FROM customer_user cu
                INNER JOIN users ON users.intUserID = cu.intUserID
                INNER JOIN customers home ON home.intCustomerID = users.intCustomerID
                WHERE home.intCustomerID = :id OR home.intCustParentID = :id ORDER BY cu.intUserID, cu.intCustomerID, cu.intCustUserID"
        );

        loop query="local.users" {
            local.userID = local.users.intUserID;
            local.assigned = {};
            local.defaultCustomerID = 0;
            local.tenantRole = (local.users.blnAdmin or local.users.blnSuperAdmin or local.users.blnSysAdmin) ? "tenant.admin" : "tenant.editor";
            loop query="local.links" {
                if (local.links.intUserID neq local.userID) {
                    continue;
                }
                if (local.links.blnStandard) {
                    local.defaultCustomerID = local.links.intCustomerID;
                }
                // Invalid and duplicate links are reported, never silently imported.
                if (not listFind(valueList(local.customers.intCustomerID), local.links.intCustomerID)
                    or structKeyExists(local.assigned, toString(local.links.intCustomerID))) {
                    continue;
                }
                local.assigned[toString(local.links.intCustomerID)] = true;
                local.result.assignments.append({userID: local.userID, customerID: local.links.intCustomerID, role: local.tenantRole, status: "active"});
            }

            local.role = "organization.member";
            // Only a superadmin with explicit access to the entire family is an
            // admin candidate. A tenant-scoped superadmin must not gain new tenants.
            if (local.users.blnSuperAdmin and structCount(local.assigned) eq local.customers.recordCount) {
                local.role = "organization.admin";
            } else if (local.users.blnSuperAdmin) {
                local.result.issues.append({issueCode: "scoped_superadmin", severity: "review", userID: local.userID, customerID: local.users.intCustomerID});
            }
            if (local.users.intCustomerID eq arguments.organizationID and local.users.blnSuperAdmin and local.users.blnActive
                and structKeyExists(local.assigned, toString(arguments.organizationID))) {
                local.result.ownerCandidates.append(local.userID);
            }
            if (local.userID eq arguments.ownerUserID) {
                local.role = "organization.owner";
                if (structCount(local.assigned) neq local.customers.recordCount) {
                    local.result.issues.append({issueCode: "owner_access_expansion", severity: "review", userID: local.userID, customerID: arguments.organizationID});
                }
            }
            local.result.members.append({
                userID: local.userID, role: local.role,
                status: local.users.blnActive ? "active" : "suspended",
                defaultCustomerID: local.defaultCustomerID, platformAdmin: local.users.blnSysAdmin eq 1
            });
        }

        if (arrayLen(local.result.ownerCandidates) eq 1) {
            local.result.suggestedOwnerUserID = local.result.ownerCandidates[1];
        }
        if (arguments.ownerUserID eq 0) {
            local.result.issues.append({issueCode: "owner_selection_required", severity: "review", userID: 0, customerID: arguments.organizationID});
        } else if (not arrayFind(local.result.ownerCandidates, arguments.ownerUserID)) {
            local.result.issues.append({issueCode: "invalid_owner_selection", severity: "error", userID: arguments.ownerUserID, customerID: arguments.organizationID});
        }
        local.result.ready = arrayLen(local.result.issues) eq 0;
        return local.result;
    }

}
