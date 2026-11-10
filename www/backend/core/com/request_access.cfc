component output="false" {

    // Resolve direct templates through the same canonical mapping as routed requests.
    public struct function resolve(required string targetPage, required string sefString, required string method) {
        local.result = {content: application.objGlobal.getSEF(arguments.sefString), decision: {access: true}};
        local.path = lCase(reReplace(replace(arguments.targetPage, chr(92), "/", "all"), "^/", ""));
        if (not reFind("^(backend/(myapp/|modules/|core/handler/|core/views/sysadmin/)|frontend/core/handler/)", local.path)) {
            return local.result;
        }
        local.mapping = queryExecute(
            options = {datasource: application.datasource},
            params = {path: {type: "varchar", value: local.path}},
            sql = "SELECT strMapping FROM system_mappings WHERE strPath = :path
                UNION SELECT strMapping FROM custom_mappings WHERE strPath = :path"
        );
        if (application.objAccessRegistry.policy(local.path, arguments.method).registered) {
            if (local.mapping.recordCount neq 1) {
                local.result.decision = {access: false, reason: "directMapping", statusCode: 403, statusText: "Forbidden"};
                return local.result;
            }
            local.result.content = application.objGlobal.getSEF(local.mapping.strMapping);
        } else if (local.mapping.recordCount) {
            local.result.decision = {access: false, reason: "directMapping", statusCode: 403, statusText: "Forbidden"};
            return local.result;
        }
        local.result.content.thisPath = local.path;
        local.result.content.onlySysAdmin = local.result.content.onlySysAdmin or find("/sysadmin/", local.path) gt 0;
        return local.result;
    }

    // Run before changing language or rendering anything, while the session lock is held.
    public struct function checkContext(required struct content, required string method, struct submitted = {}, struct queryString = {}, struct headers = {}) {
        local.decision = checkMembership(arguments.content, arguments.method, arguments.submitted, arguments.queryString);
        if (not local.decision.access) {
            return local.decision;
        }
        if ((session.membership_identity ?: (session.membership_access ?: false))
            and left(arguments.content.thisPath, 8) eq "backend/"
            and (not listFindNoCase("GET,HEAD,OPTIONS", arguments.method)
                or application.objGlobal.csrfRequired(arguments.content.thisPath, arguments.method, structKeyArray(arguments.queryString)))) {
            local.token = arguments.submitted.context_token ?: (arguments.queryString.context_token ?: (arguments.headers["X-Saaster-Context"] ?: ""));
            if (not application.objGlobal.contextVerify(local.token)) {
                return {access: false, reason: "context", statusCode: 409, statusText: "Conflict", messageKey: "msgMembershipContextChanged"};
            }
        }
        return {access: true};
    }

    // A side-effect-free permission check for UI actions; it never requires a submitted token.
    // Pass trusted route metadata from getSEF(), plus the intended HTTP method/action keys.
    public boolean function canAccess(required struct content, string method = "GET", struct submitted = {}, struct queryString = {}) {
        return checkMembership(arguments.content, arguments.method, arguments.submitted, arguments.queryString).access
            and checkPage(arguments.content, arguments.method, arguments.queryString).access;
    }

    private struct function checkMembership(required struct content, required string method, required struct submitted, required struct queryString) {
        if (left(arguments.content.thisPath, 8) eq "backend/" and structKeyExists(session, "customer_id") and new backend.core.com.account_lifecycle().isDeleting(session.customer_id)) {
            return {access: false, reason: "accountDeletion", statusCode: 403, statusText: "Forbidden", messageKey: "msgAccountDeletionPending"};
        }
        if (structKeyExists(session, "customer_id") and application.objModuleBlocks.pathBlocked(session.customer_id, arguments.content.thisPath)) {
            return {access: false, reason: "moduleBlocked", statusCode: 403, statusText: "Forbidden", messageKey: "msgModuleBlocked"};
        }
        if (structKeyExists(session, "user_id") and structKeyExists(session, "customer_id")
            and not application.objMembershipAccess.allowRequest(session.user_id, session.customer_id,
                arguments.content.thisPath, arguments.method, arguments.submitted, arguments.queryString)) {
            return {access: false, reason: "membership", statusCode: 403, statusText: "Forbidden", messageKey: "msgNoAccess"};
        }
        return {access: true};
    }

    // Return a response description. The dispatcher alone emits alerts, redirects and HTTP errors.
    public struct function checkPage(required struct content, required string method, struct queryString = {}) {
        if (structKeyExists(session, "customer_id")) {
            if (not arguments.content.access) {
                return {access: false, reason: "mapping", redirect: "/dashboard"};
            }
            local.explicitPolicy = (session.membership_access ?: false)
                and application.objAccessRegistry.policy(arguments.content.thisPath, arguments.method).registered;
            if ((structKeyExists(session, "admin") and not session.admin and arguments.content.onlyAdmin and not local.explicitPolicy)
                or (structKeyExists(session, "superadmin") and not session.superadmin and arguments.content.onlySuperAdmin and not local.explicitPolicy)
                or (structKeyExists(session, "sysadmin") and not session.sysadmin and arguments.content.onlySysAdmin)) {
                return {access: false, reason: "role", redirect: "/dashboard", alertKey: "msgNoAccess", alertType: "danger"};
            }
        } else {
            // Keep the existing anonymous invoice-print and plan-registration entry points.
            if (listFirst(arguments.content.thisPath, "/") eq "backend" and not structKeyExists(session, "user_id")) {
                if (structKeyExists(arguments.queryString, "pdf")) {
                    return {access: false, reason: "invoicePrint", redirect: "/backend/core/views/invoices/print.cfm?pdf=" & arguments.queryString.pdf};
                }
                if (structKeyExists(arguments.queryString, "plan")) {
                    return {access: false, reason: "registration", redirect: "/register?redirect=book?plan=" & arguments.queryString.plan};
                }
                return {access: false, reason: "login", redirect: "/login", alertKey: "alertSessionExpired", alertType: "warning"};
            }
            if (not arguments.content.access) {
                return {access: false, reason: "mapping", redirect: ""};
            }
        }
        return {access: true};
    }

    public struct function checkCsrf(required struct content, required string method, struct queryString = {}, struct headers = {}) {
        if (application.objGlobal.csrfRequired(arguments.content.thisPath, arguments.method, structKeyArray(arguments.queryString))
            and not application.objGlobal.csrfVerify()) {
            if ((arguments.headers["X-Requested-With"] ?: "") eq "XMLHttpRequest") {
                return {access: false, reason: "csrf", statusCode: 403, statusText: "Forbidden", message: "Invalid CSRF token"};
            }
            return {access: false, reason: "csrf", redirect: structKeyExists(session, "user_id") ? "/dashboard" : "/login",
                alertKey: "msgCsrfInvalid", alertType: "danger"};
        }
        return {access: true};
    }

    // Product entitlement stays independent of role permissions, including canceled bookings
    // whose paid period has not ended. Preserve the existing platform-admin exception.
    public boolean function moduleAccess(required numeric moduleID) {
        if (arguments.moduleID lte 0 or not structKeyExists(session, "customer_id") or session.customer_id lte 0) {
            return true;
        }
        if (application.objModuleBlocks.isBlocked(session.customer_id, arguments.moduleID)) {
            return false;
        }
        if (session.sysadmin ?: false) {
            return true;
        }
        local.bookings = application.objModules.getModuleAccessBookings(session.customer_id, arguments.moduleID);
        loop query=local.bookings {
            if (bookingAccess({status: local.bookings.status, startDate: local.bookings.startDate, endDate: local.bookings.endDate})) {
                return true;
            }
        }
        return false;
    }

    public boolean function bookingAccess(required struct status, date at = now()) {
        if (not structKeyExists(arguments.status, "status")) {
            return false;
        }
        if (arguments.status.status eq "free") {
            return true;
        }
        return structKeyExists(arguments.status, "startDate") and structKeyExists(arguments.status, "endDate")
            and isDate(arguments.status.startDate) and isDate(arguments.status.endDate)
            and dateFormat(arguments.status.startDate, "yyyy-mm-dd") lte dateFormat(arguments.at, "yyyy-mm-dd")
            and dateFormat(arguments.status.endDate, "yyyy-mm-dd") gte dateFormat(arguments.at, "yyyy-mm-dd");
    }
}
