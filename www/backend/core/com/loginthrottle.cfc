component displayname="loginthrottle" output="false" {

    /*
        Slows down password guessing on the login.

        Failed attempts are counted per e-mail address and per client IP within a
        time window. When a counter reaches its limit, that address or IP is blocked
        for a while - the login is then refused before the password is even checked.
        A successful login resets the counter of the address (not of the IP, otherwise
        an attacker could reset it by logging into an own account in between).

        The per-address limit protects a single account against a distributed attack,
        the per-IP limit protects all accounts against one source trying many addresses.
        Data lives in the table login_throttle (migration V21); e-mail addresses are
        only stored as a hash.
    */

    variables.settings = {
        windowMinutes: 15,
        blockMinutes: 15,
        maxFailuresPerEmail: 5,
        maxFailuresPerIP: 20
    };

    public any function init(struct settings = {}) {
        structAppend(variables.settings, arguments.settings, true);
        return this;
    }

    // Is the login currently blocked for this address or this IP?
    public boolean function isBlocked(required string email, required string ip) {
        local.qBlocked = queryExecute(
            options = {datasource = application.datasource},
            params = {
                keys: {type: "varchar", value: arrayToList(throttleKeys(arguments.email, arguments.ip)), list: true}
            },
            sql = "
                SELECT COUNT(*) AS cnt
                FROM login_throttle
                WHERE strThrottleKey IN (:keys)
                AND dtmBlockedUntil > UTC_TIMESTAMP()
            "
        );

        return local.qBlocked.cnt gt 0;
    }

    // Counts a failed login for the address and the IP, and blocks them once a limit is reached.
    public void function registerFailure(required string email, required string ip) {
        registerFailureForKey(emailKey(arguments.email), variables.settings.maxFailuresPerEmail);

        if (len(trim(arguments.ip))) {
            registerFailureForKey(ipKey(arguments.ip), variables.settings.maxFailuresPerIP);
        }
    }

    // A successful login clears the counter of the address.
    public void function reset(required string email) {
        queryExecute(
            options = {datasource = application.datasource},
            params = {
                throttleKey: {type: "varchar", value: emailKey(arguments.email)}
            },
            sql = "DELETE FROM login_throttle WHERE strThrottleKey = :throttleKey"
        );
    }

    /*
        The address of the visitor. NGINX in front of Lucee sets X-Real-IP from the
        real connection (it overwrites whatever a client sends), so it is trustworthy
        here - unlike X-Forwarded-For, which a client can prefill.
    */
    public string function clientIP() {
        local.headers = getHTTPRequestData(false).headers;

        if (structKeyExists(local.headers, "X-Real-IP") and len(trim(local.headers["X-Real-IP"]))) {
            return trim(local.headers["X-Real-IP"]);
        }

        return cgi.remote_addr;
    }

    public string function emailKey(required string email) {
        return "email:" & lCase(hash(lCase(trim(arguments.email)), "SHA-256"));
    }

    public string function ipKey(required string ip) {
        return "ip:" & trim(arguments.ip);
    }


    private array function throttleKeys(required string email, required string ip) {
        local.keys = [emailKey(arguments.email)];

        if (len(trim(arguments.ip))) {
            arrayAppend(local.keys, ipKey(arguments.ip));
        }

        return local.keys;
    }

    private void function registerFailureForKey(required string throttleKey, required numeric maxFailures) {

        // Count the failure. An old window (first failure older than windowMinutes) starts over.
        queryExecute(
            options = {datasource = application.datasource},
            params = {
                throttleKey: {type: "varchar", value: arguments.throttleKey},
                windowMinutes: {type: "numeric", value: variables.settings.windowMinutes}
            },
            sql = "
                INSERT INTO login_throttle (strThrottleKey, intFailures, dtmFirstFailure)
                VALUES (:throttleKey, 1, UTC_TIMESTAMP())
                ON DUPLICATE KEY UPDATE
                    intFailures = IF(dtmFirstFailure < UTC_TIMESTAMP() - INTERVAL :windowMinutes MINUTE, 1, intFailures + 1),
                    dtmBlockedUntil = IF(dtmFirstFailure < UTC_TIMESTAMP() - INTERVAL :windowMinutes MINUTE, NULL, dtmBlockedUntil),
                    dtmFirstFailure = IF(dtmFirstFailure < UTC_TIMESTAMP() - INTERVAL :windowMinutes MINUTE, UTC_TIMESTAMP(), dtmFirstFailure)
            "
        );

        // Block once the limit is reached
        queryExecute(
            options = {datasource = application.datasource},
            params = {
                throttleKey: {type: "varchar", value: arguments.throttleKey},
                maxFailures: {type: "numeric", value: arguments.maxFailures},
                blockMinutes: {type: "numeric", value: variables.settings.blockMinutes}
            },
            sql = "
                UPDATE login_throttle
                SET dtmBlockedUntil = UTC_TIMESTAMP() + INTERVAL :blockMinutes MINUTE
                WHERE strThrottleKey = :throttleKey
                AND intFailures >= :maxFailures
                AND (dtmBlockedUntil IS NULL OR dtmBlockedUntil < UTC_TIMESTAMP())
            "
        );
    }

}
