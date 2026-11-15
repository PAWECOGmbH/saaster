component output="false" {

    public boolean function isDeleting(required numeric customerID) {
        return queryExecute(
            options={datasource: application.datasource},
            params={id: {type: "integer", value: arguments.customerID}},
            sql="SELECT intCustomerID FROM account_deletions WHERE intCustomerID = :id"
        ).recordCount gt 0;
    }

    // The customer row serializes admission of new work with the deletion request.
    public boolean function lockActiveCustomer(required numeric customerID) {
        local.customer = queryExecute(
            options={datasource: application.datasource},
            params={id: {type: "integer", value: arguments.customerID}},
            sql="SELECT intCustomerID FROM customers WHERE intCustomerID = :id FOR UPDATE"
        );
        return local.customer.recordCount gt 0 and !isDeleting(arguments.customerID);
    }

    // Call inside the deletion transaction. Tenant creation locks this same parent row.
    public struct function lockDeletionTarget(required numeric customerID) {
        local.target = queryExecute(options={datasource: application.datasource},
            params={id:{type:"integer",value:arguments.customerID}},
            sql="SELECT intCustomerID FROM customers WHERE intCustomerID = :id FOR UPDATE");
        if (!local.target.recordCount) return {success:false, reason:"missing"};
        local.children = queryExecute(options={datasource: application.datasource},
            params={id:{type:"integer",value:arguments.customerID}},
            sql="SELECT intCustomerID FROM customers WHERE intCustParentID = :id FOR UPDATE");
        if (local.children.recordCount) return {success:false, reason:"tenants"};
        return {success:true};
    }

    public string function beginOperation(required numeric customerID, required string kind, numeric invoiceID = 0) {
        if (!listFind("charge,booking,renewal,job,request", arguments.kind)) {
            throw(type="AccountLifecycle.InvalidOperation", message="Invalid account operation.");
        }
        transaction {
            if (!lockActiveCustomer(arguments.customerID)) return "";
            if (arguments.kind eq "charge" and queryExecute(
                options={datasource: application.datasource},
                params={id: {type: "integer", value: arguments.customerID}},
                sql="SELECT strToken FROM account_operations WHERE intCustomerID = :id AND strKind = 'charge' LIMIT 1"
            ).recordCount) return "";
            local.token = createUUID();
            queryExecute(
                options={datasource: application.datasource},
                params={id: {type: "integer", value: arguments.customerID}, token: {type: "varchar", value: local.token}, kind: {type: "varchar", value: arguments.kind}, invoice: {type: "integer", value: arguments.invoiceID, null: arguments.invoiceID lte 0}},
                sql="INSERT INTO account_operations (strToken, intCustomerID, strKind, intInvoiceID) VALUES (:token, :id, :kind, :invoice)"
            );
            return local.token;
        }
    }

    public void function finishOperation(required string token, boolean uncertain = false) {
        if (!len(arguments.token)) return;
        if (arguments.uncertain) {
            queryExecute(
                options={datasource: application.datasource},
                params={token: {type: "varchar", value: arguments.token}},
                sql="UPDATE account_operations SET strStatus = 'uncertain' WHERE strToken = :token"
            );
        } else {
            queryExecute(
                options={datasource: application.datasource},
                params={token: {type: "varchar", value: arguments.token}},
                sql="DELETE FROM account_operations WHERE strToken = :token"
            );
        }
    }

    public boolean function hasOperations(required numeric customerID) {
        return queryExecute(
            options={datasource: application.datasource},
            params={id: {type: "integer", value: arguments.customerID}},
            sql="SELECT strToken FROM account_operations WHERE intCustomerID = :id LIMIT 1"
        ).recordCount gt 0;
    }

    // Caller has verified the password of this exact authenticated actor.
    public boolean function canDelete(required numeric actorID, required numeric customerID) {
        if (session.supportLogin ?: false) return false;
        local.actor = queryExecute(
            options={datasource: application.datasource},
            params={actor: {type: "integer", value: arguments.actorID}, customer: {type: "integer", value: arguments.customerID}},
            sql="SELECT u.blnSysAdmin, u.blnSuperAdmin, u.intCustomerID, c.intCustParentID,
                    m.strRoleKey, m.strStatus, a.intOrganizationID
                FROM users u INNER JOIN customers c ON c.intCustomerID = :customer
                LEFT JOIN organization_access a ON a.intOrganizationID = CASE WHEN c.intCustParentID = 0 THEN c.intCustomerID ELSE c.intCustParentID END
                LEFT JOIN organization_memberships m ON m.intOrganizationID = a.intOrganizationID AND m.intUserID = u.intUserID
                WHERE u.intUserID = :actor AND u.blnActive = 1"
        );
        if (!local.actor.recordCount) return false;
        if (local.actor.blnSysAdmin) return true;
        if (val(local.actor.intOrganizationID)) return local.actor.strRoleKey eq "organization.owner" and local.actor.strStatus eq "active";
        return local.actor.blnSuperAdmin and (local.actor.intCustomerID eq arguments.customerID
            or (local.actor.intCustParentID gt 0 and local.actor.intCustomerID eq local.actor.intCustParentID));
    }

    public struct function deletionState(required numeric customerID) {
        local.params = {id:{type:"integer",value:arguments.customerID}};
        local.children = queryExecute(options={datasource:application.datasource}, params=local.params,
            sql="SELECT COUNT(*) AS cnt FROM customers WHERE intCustParentID = :id");
        local.protected = queryExecute(options={datasource:application.datasource}, params=local.params,
            sql="SELECT intUserID FROM users WHERE intCustomerID = :id AND blnSysAdmin = 1 LIMIT 1");
        local.request = queryExecute(options={datasource:application.datasource}, params=local.params,
            sql="SELECT strStatus, strLastError FROM account_deletions WHERE intCustomerID = :id");
        return {children:val(local.children.cnt), protected:local.protected.recordCount gt 0,
            pending:local.request.recordCount gt 0, status:local.request.strStatus ?: "", error:local.request.strLastError ?: ""};
    }

    // actorID must come from the session. Request routing enforces CSRF and context tokens.
    public struct function submitDeletion(required numeric actorID, required numeric customerID, required string password) {
        local.actor = queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:arguments.actorID}},
            sql="SELECT strEmail FROM users WHERE intUserID = :id AND blnActive = 1");
        if (!local.actor.recordCount or !canDelete(arguments.actorID, arguments.customerID)) return {success:false, accepted:false, reason:"permission"};
        local.throttle = new backend.core.com.loginthrottle();
        local.ip = local.throttle.clientIP();
        if (local.throttle.isBlocked(local.actor.strEmail, local.ip)) return {success:false, accepted:false, reason:"identity"};
        local.result = requestDeletion(argumentCollection=arguments);
        if (!local.result.success) {
            if (local.result.reason eq "identity") local.throttle.registerFailure(local.actor.strEmail, local.ip);
            local.result.accepted = false;
            return local.result;
        }
        local.throttle.reset(local.actor.strEmail);
        // The confirming request itself must not hold up its own account cleanup.
        if (len(request.accountOperation ?: "")) {
            queryExecute(options={datasource:application.datasource},
                params={id:{type:"integer",value:arguments.customerID},token:{type:"varchar",value:request.accountOperation}},
                sql="DELETE FROM account_operations WHERE intCustomerID = :id AND strToken = :token AND strKind = 'request'");
        }
        try {
            local.result = new backend.core.com.account_deletion().process(arguments.customerID);
        } catch (any e) {
            // The request has already committed, even if a cleanup lock or dependency fails.
            application.objLog.logWrite("system", "error", "Account deletion could not run [CustomerID: #arguments.customerID#]: #e.message#");
            local.result = {success:false, reason:"cleanup"};
        }
        local.result.accepted = true;
        return local.result;
    }

    public boolean function confirmIdentity(required numeric actorID, required string password) {
        local.user = queryExecute(
            options={datasource: application.datasource},
            params={id: {type: "integer", value: arguments.actorID}},
            sql="SELECT strPasswordHash, strPasswordSalt FROM users WHERE intUserID = :id AND blnActive = 1"
        );
        return local.user.recordCount gt 0 and application.objGlobal.verifyPassword(arguments.password, local.user.strPasswordHash, local.user.strPasswordSalt).valid;
    }

    // Starting is durable. Cleanup failures must never resume billing or customer access.
    public struct function requestDeletion(required numeric actorID, required numeric customerID, required string password) {
        if (!confirmIdentity(arguments.actorID, arguments.password)) return {success: false, reason: "identity"};
        transaction {
            local.target = lockDeletionTarget(arguments.customerID);
            if (!canDelete(arguments.actorID, arguments.customerID)) return {success:false, reason:"permission"};
            if (!local.target.success) return local.target;
            // Each request deletes one account only, including for platform administrators.
            local.ids = [arguments.customerID];
            local.params = {ids: {type: "integer", value: arrayToList(local.ids), list: true}, root: {type: "integer", value: arguments.customerID}, actor: {type: "integer", value: arguments.actorID}};
            // Never remove the platform operator/issuer.
            local.protected = queryExecute(options={datasource: application.datasource}, params=local.params,
                sql="SELECT intUserID FROM users WHERE intCustomerID IN (:ids) AND blnSysAdmin = 1");
            if (local.protected.recordCount) return {success:false, reason:"protected"};
            local.conflicts = queryExecute(options={datasource: application.datasource}, params=local.params,
                sql="SELECT intCustomerID FROM account_deletions WHERE intCustomerID IN (:ids) AND intRootCustomerID <> :root");
            if (local.conflicts.recordCount) return {success: false, reason: "conflict"};
            queryExecute(options={datasource: application.datasource}, params=local.params,
                sql="INSERT IGNORE INTO account_deletions (intCustomerID, intRootCustomerID, intActorUserID)
                    SELECT intCustomerID, :root, :actor FROM customers WHERE intCustomerID IN (:ids)");
            queryExecute(options={datasource: application.datasource}, params=local.params,
                sql="UPDATE customers SET blnActive = 0 WHERE intCustomerID IN (:ids)");
            queryExecute(options={datasource: application.datasource}, params=local.params,
                sql="UPDATE bookings SET strStatus = 'canceled', dteEndDate = LEAST(COALESCE(dteEndDate, UTC_DATE()), DATE_SUB(UTC_DATE(), INTERVAL 1 DAY))
                    WHERE intCustomerID IN (:ids)");
            return {success: true, reason: "requested", customerIDs: local.ids};
        }
    }
}
