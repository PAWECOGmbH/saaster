component output="false" {
    public query function forCustomer(required numeric customerID) {
        return queryExecute(options={datasource:application.datasource}, params={customer:{type:"integer",value:arguments.customerID}},
            sql="SELECT intModuleID, intActorUserID, dtmBlockedAt FROM customer_module_blocks WHERE intCustomerID = :customer");
    }

    public boolean function isBlocked(required numeric customerID, required numeric moduleID) {
        local.q = queryExecute(options={datasource:application.datasource},
            params={customer:{type:"integer",value:arguments.customerID}, module:{type:"integer",value:arguments.moduleID}},
            sql="SELECT 1 FROM customer_module_blocks WHERE intCustomerID = :customer AND intModuleID = :module");
        return local.q.recordCount gt 0;
    }

    // Include unmapped files inside a module directory, so a direct handler URL cannot bypass a block.
    public boolean function pathBlocked(required numeric customerID, required string path) {
        local.path = lCase(reReplace(replace(arguments.path, chr(92), "/", "all"), "^/+", ""));
        local.prefix = reFind("^backend/modules/[^/]+/", local.path) ? listGetAt(local.path, 3, "/") : "";
        local.q = queryExecute(options={datasource:application.datasource},
            params={customer:{type:"integer",value:arguments.customerID}, path:{type:"varchar",value:local.path}, prefix:{type:"varchar",value:local.prefix}},
            sql="SELECT 1 FROM customer_module_blocks blocked
                INNER JOIN modules ON modules.intModuleID = blocked.intModuleID
                WHERE blocked.intCustomerID = :customer AND (
                    (:prefix <> '' AND modules.strTabPrefix = :prefix)
                    OR EXISTS (SELECT 1 FROM custom_mappings mapping WHERE mapping.intModuleID = blocked.intModuleID AND mapping.strPath = :path)
                ) LIMIT 1");
        return local.q.recordCount gt 0;
    }

    public void function setBlocked(required numeric actorUserID, required numeric customerID, required numeric moduleID, required boolean blocked) {
        if (not (session.sysadmin ?: false) or (session.supportLogin ?: false) or (session.user_id ?: 0) neq arguments.actorUserID) {
            throw(type="Saaster.ModuleBlock.Denied", message="Platform administrator required.");
        }
        transaction {
            local.actor = queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:arguments.actorUserID}},
                sql="SELECT intUserID FROM users WHERE intUserID = :id AND blnActive = 1 AND blnSysAdmin = 1 FOR SHARE");
            if (not local.actor.recordCount) { throw(type="Saaster.ModuleBlock.Denied", message="Platform administrator required."); }
            local.customer = queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:arguments.customerID}},
                sql="SELECT intCustomerID FROM customers WHERE intCustomerID = :id FOR UPDATE");
            local.module = queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:arguments.moduleID}},
                sql="SELECT intModuleID FROM modules WHERE intModuleID = :id FOR SHARE");
            if (not local.customer.recordCount or not local.module.recordCount
                or (arguments.blocked and not application.objModules.getModuleAccessBookings(arguments.customerID, arguments.moduleID).recordCount)) {
                throw(type="Saaster.ModuleBlock.Invalid", message="Customer and module booking required.");
            }
            local.params = {customer:{type:"integer",value:arguments.customerID}, module:{type:"integer",value:arguments.moduleID}};
            if (arguments.blocked) {
                local.params.actor = {type:"integer",value:arguments.actorUserID};
                queryExecute(options={datasource:application.datasource}, params=local.params,
                    sql="INSERT IGNORE INTO customer_module_blocks (intCustomerID, intModuleID, intActorUserID) VALUES (:customer, :module, :actor)");
            } else {
                queryExecute(options={datasource:application.datasource}, params=local.params,
                    sql="DELETE FROM customer_module_blocks WHERE intCustomerID = :customer AND intModuleID = :module");
            }
            application.objModules.syncCustomerScheduler(arguments.customerID);
        }
        application.objLog.logWrite("system", "info", "Module access #arguments.blocked ? 'blocked' : 'unblocked'# [Actor: #arguments.actorUserID#, Customer: #arguments.customerID#, Module: #arguments.moduleID#]", false);
    }
}
