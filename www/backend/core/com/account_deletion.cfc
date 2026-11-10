component output="false" {

    // Only processes a previously authorized, durable deletion request.
    // Keep one database lock across cleanup so parallel retries cannot execute the same hook.
    public struct function process(required numeric rootCustomerID) {
        local.lifecycle = new backend.core.com.account_lifecycle();
        transaction {
            local.target = local.lifecycle.lockDeletionTarget(arguments.rootCustomerID);
            local.requests = queryExecute(
                options={datasource: application.datasource},
                params={root: {type: "integer", value: arguments.rootCustomerID}},
                sql="SELECT * FROM account_deletions WHERE intRootCustomerID = :root
                    ORDER BY (intCustomerID = intRootCustomerID), intCustomerID FOR UPDATE"
            );
            if (!local.requests.recordCount) return {success: false, reason: "missing"};
            local.pending = false;
            loop query=local.requests { if (local.requests.strStatus neq "completed") local.pending = true; }
            if (!local.pending) return {success: true, reason: "completed"};
            // Refuse obsolete batch requests and recheck children before any cleanup.
            if (local.requests.recordCount neq 1 or local.requests.intCustomerID neq arguments.rootCustomerID) return {success:false, reason:"scope"};
            if (!local.target.success) return local.target;
            local.finalizing = false;
            local.ids = valueList(local.requests.intCustomerID);
            local.params = {ids: {type: "integer", value: local.ids, list: true}, root: {type: "integer", value: arguments.rootCustomerID}};
            local.operations = queryExecute(options={datasource: application.datasource}, params=local.params,
                sql="SELECT strToken FROM account_operations WHERE intCustomerID IN (:ids)");
            local.jobs = queryExecute(options={datasource: application.datasource}, params=local.params,
                sql="SELECT intJobID FROM scheduler_jobs WHERE intCustomerID IN (:ids) AND strLockToken IS NOT NULL");
            if (local.operations.recordCount or local.jobs.recordCount) {
                queryExecute(options={datasource: application.datasource}, params=local.params,
                    sql="UPDATE account_deletions SET strStatus = 'waiting', strLastError = 'operations'
                        WHERE intRootCustomerID = :root AND strStatus <> 'completed'");
                return {success: false, reason: "operations"};
            }
            try {
                local.hooks = cleanupHooks();
                // Preserve all accounting documents before any module or file cleanup.
                local.invoices = queryExecute(options={datasource: application.datasource}, params=local.params,
                    sql="SELECT intInvoiceID FROM invoices WHERE intCustomerID IN (:ids)
                        AND (intPaymentStatusID <> 1 OR blnDocumentIssued = 1) ORDER BY intInvoiceID");
                loop query=local.invoices { new backend.core.com.invoice_documents().capture(local.invoices.intInvoiceID, "legacy"); }
                loop query=local.requests {
                    if (local.requests.strStatus eq "completed") continue;
                    local.customerID = local.requests.intCustomerID;
                    // Hooks run even for inactive/unbooked modules: old bookings may already be gone.
                    loop array=local.hooks item="local.hook" {
                        if (!stepDone(local.customerID, local.hook.key)) {
                            local.result = createObject("component", local.hook.component).deleteCustomer(local.customerID);
                            if (!isStruct(local.result) or !(local.result.success ?: false)) {
                                throw(type="AccountDeletion.Module", message="Module cleanup failed: " & local.hook.key);
                            }
                            completeStep(local.customerID, local.hook.key);
                        }
                    }
                    revokePaymentMethods(local.customerID);
                    removeLogo(local.customerID);
                }
                // Keep identities that still belong to another organization or tenant.
                local.users = queryExecute(options={datasource: application.datasource}, params=local.params,
                    sql="SELECT u.intUserID, u.strPhoto FROM users u
                        WHERE (u.intCustomerID IN (:ids) OR (u.intCustomerID IS NULL AND EXISTS
                            (SELECT 1 FROM organization_memberships m WHERE m.intUserID = u.intUserID AND m.intOrganizationID IN (:ids))))
                        AND u.blnSysAdmin = 0
                        AND NOT EXISTS (SELECT 1 FROM organization_memberships m WHERE m.intUserID = u.intUserID AND m.intOrganizationID NOT IN (:ids))
                        AND NOT EXISTS (SELECT 1 FROM customer_user c WHERE c.intUserID = u.intUserID AND c.intCustomerID NOT IN (:ids))");
                loop query=local.users { removeImage("users", local.users.strPhoto); }
                transaction action="setsavepoint" savepoint="accountFinalization";
                local.finalizing = true;
                loop query=local.requests {
                    if (local.requests.strStatus eq "completed") continue;
                    new backend.core.com.invoice_documents().retainForDeletion(local.requests.intCustomerID);
                    queryExecute(options={datasource: application.datasource}, params={id:{type:"integer",value:local.requests.intCustomerID}},
                        sql="DELETE FROM customers WHERE intCustomerID = :id");
                }
                loop query=local.users {
                    queryExecute(options={datasource: application.datasource}, params={id:{type:"integer",value:local.users.intUserID}},
                        sql="DELETE FROM users WHERE intUserID = :id");
                }
                queryExecute(options={datasource: application.datasource}, params=local.params,
                    sql="UPDATE account_deletions SET strStatus = 'completed', strLastError = '', dtmCompletedAt = COALESCE(dtmCompletedAt, UTC_TIMESTAMP()) WHERE intRootCustomerID = :root");
                return {success: true, reason: "completed"};
            } catch (any e) {
                if (local.finalizing) transaction action="rollback" savepoint="accountFinalization";
                // Completed hooks remain recorded; partial hooks must be safe to retry.
                queryExecute(options={datasource: application.datasource}, params=local.params,
                    sql="UPDATE account_deletions SET strStatus = 'failed', strLastError = 'cleanup'
                        WHERE intRootCustomerID = :root AND strStatus <> 'completed'");
                application.objLog.logWrite("system", "error", "Account deletion cleanup failed [CustomerID: #arguments.rootCustomerID#]: #e.message#");
                return {success: false, reason: "cleanup"};
            }
        }
    }

    private array function cleanupHooks() {
        local.hooks = [{key: "myapp", component: "backend.myapp.deletion"}];
        if (!fileExists(expandPath("/backend/myapp/deletion.cfc"))) throw(type="AccountDeletion.Hook", message="Missing project deletion hook.");
        local.modules = directoryList(expandPath("/backend/modules"), false, "name");
        local.registered = queryExecute(options={datasource: application.datasource},
            sql="SELECT strSettingPath FROM modules WHERE strSettingPath LIKE 'backend/modules/%' OR strSettingPath LIKE '/backend/modules/%'");
        loop query=local.registered {
            local.path = reReplace(local.registered.strSettingPath, "^/", "");
            local.name = listGetAt(local.path, 3, "/");
            if (!reFind("^[a-zA-Z0-9_]+$", local.name) or !fileExists(expandPath("/backend/modules/" & local.name & "/deletion.cfc"))) {
                throw(type="AccountDeletion.Hook", message="Missing registered module deletion hook: " & local.name);
            }
            if (!arrayFindNoCase(local.modules, local.name)) arrayAppend(local.modules, local.name);
        }
        loop array=local.modules item="local.module" {
            if (!directoryExists(expandPath("/backend/modules/" & local.module))) continue;
            // Empty local placeholder folders do not contain an installed module.
            if (!arrayLen(directoryList(expandPath("/backend/modules/" & local.module), true, "path", "*.cf*"))) continue;
            if (!reFind("^[a-zA-Z0-9_]+$", local.module) or !fileExists(expandPath("/backend/modules/" & local.module & "/deletion.cfc"))) {
                throw(type="AccountDeletion.Hook", message="Missing module deletion hook: " & local.module);
            }
            arrayAppend(local.hooks, {key: "module:" & local.module, component: "backend.modules." & local.module & ".deletion"});
        }
        return local.hooks;
    }

    private void function revokePaymentMethods(required numeric customerID) {
        local.methods = queryExecute(options={datasource: application.datasource}, params={id:{type:"integer",value:arguments.customerID}},
            sql="SELECT DISTINCT intTransactionID FROM payrexx WHERE intCustomerID = :id AND strStatus = 'authorized' AND intTransactionID > 0");
        loop query=local.methods {
            local.step = "payrexx:" & local.methods.intTransactionID;
            if (stepDone(arguments.customerID, local.step)) continue;
            local.result = new backend.core.com.payrexx().callPayrexx({}, "DEL", "Transaction", local.methods.intTransactionID);
            // A retry after a successful external delete may find the token already absent.
            if ((local.result.status ?: "") neq "success" and val(local.result.httpStatus ?: 0) neq 404) {
                throw(type="AccountDeletion.Payment", message="Payment token revocation failed.");
            }
            completeStep(arguments.customerID, local.step);
        }
    }

    private void function removeLogo(required numeric customerID) {
        local.customer = queryExecute(options={datasource: application.datasource}, params={id:{type:"integer",value:arguments.customerID}},
            sql="SELECT strLogo FROM customers WHERE intCustomerID = :id");
        if (local.customer.recordCount) removeImage("logos", local.customer.strLogo);
    }

    private void function removeImage(required string folder, required string name) {
        if (!len(trim(arguments.name))) return;
        if (!listFind("logos,users", arguments.folder) or reFind("[/\\\\]", arguments.name) or arguments.name eq "..") {
            throw(type="AccountDeletion.File", message="Invalid account image path.");
        }
        local.path = expandPath("/userdata/images/" & arguments.folder & "/" & arguments.name);
        if (fileExists(local.path)) fileDelete(local.path);
    }

    private boolean function stepDone(required numeric customerID, required string step) {
        return queryExecute(options={datasource: application.datasource}, params={id:{type:"integer",value:arguments.customerID},step:{type:"varchar",value:arguments.step}},
            sql="SELECT strStep FROM account_deletion_steps WHERE intCustomerID = :id AND strStep = :step").recordCount gt 0;
    }

    private void function completeStep(required numeric customerID, required string step) {
        queryExecute(options={datasource: application.datasource}, params={id:{type:"integer",value:arguments.customerID},step:{type:"varchar",value:arguments.step}},
            sql="INSERT IGNORE INTO account_deletion_steps (intCustomerID, strStep) VALUES (:id, :step)");
    }
}
