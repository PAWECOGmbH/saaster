component output="false" hint="Shared email lock for registration and invitation acceptance. Call inside a transaction." {
    public void function lockEmail(required string email) {
        local.params = {email: {type: "varchar", value: lCase(trim(arguments.email))}};
        queryExecute(options = {datasource: application.datasource}, params = local.params,
            sql = "INSERT IGNORE INTO identity_email_locks (strEmail) VALUES (:email)");
        queryExecute(options = {datasource: application.datasource}, params = local.params,
            sql = "SELECT strEmail FROM identity_email_locks WHERE strEmail = :email FOR UPDATE");
    }
    public void function requireUnusedEmail(required string email) {
        lockEmail(arguments.email);
        local.users = queryExecute(options = {datasource: application.datasource}, params = {email: {type: "varchar", value: lCase(trim(arguments.email))}},
            sql = "SELECT intUserID FROM users WHERE strEmail = :email FOR UPDATE");
        if (local.users.recordCount) {
            throw(type="Saaster.Identity.EmailExists", message="An identity with this email already exists.");
        }
    }
}
