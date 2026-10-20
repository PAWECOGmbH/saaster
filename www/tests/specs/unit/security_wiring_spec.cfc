component extends="testbox.system.BaseSpec" {

    /*
        Security calls in the handlers - read from the source, nothing is executed.

        Most of the security rules have their own behaviour specs (csrf_spec,
        user_roles_spec, login_throttle_spec, token_expiry_spec, ...). Those prove the
        rules work; this spec proves the handlers still call them, in the branch where
        they belong and in the right order. Removing one of these calls during a
        refactoring would otherwise go unnoticed.
    */

    function run() {

        var scanner = new tests.support.security_scanner();

        describe("Application.cfc", () => {

            var source = scanner.readSource("Application.cfc");

            it("checks the CSRF token for every request the rule covers", () => {
                expect(source).toInclude("application.objGlobal.csrfRequired(");
                expect(source).toInclude("application.objGlobal.csrfVerify()");
                expect(find("csrfRequired(", source)).toBeLT(find("csrfVerify()", source));
            });

            it("sets httpOnly, SameSite and secure on the session cookie", () => {
                var cookieBlock = mid(source, find("this.sessionCookie", source), 300);
                expect(reFindNoCase("httpOnly\s*:\s*true", cookieBlock)).toBeGT(0);
                expect(reFindNoCase("sameSite\s*:\s*""lax""", cookieBlock)).toBeGT(0);
                expect(reFindNoCase("secure\s*:[^}]*https://", cookieBlock)).toBeGT(0, "secure must follow the https main URL");
            });

        });

        describe("Login (frontend/core/handler/register.cfm)", () => {

            var login = scanner.branchBody("frontend/core/handler/register.cfm", "form", "login_btn");

            it("refuses blocked addresses and IPs before the password is checked", () => {
                expect(find("isBlocked(", login)).toBeGT(0);
                expect(find("isBlocked(", login)).toBeLT(find("checkLogin(", login));
            });

            it("rotates the session ID and resets the throttle after a correct login", () => {
                expect(find("sessionRotate()", login)).toBeGT(find("loginCorrect", login));
                expect(login).toInclude("loginThrottle.reset(");
            });

            it("counts failed logins", () => {
                expect(login).toInclude("loginThrottle.registerFailure(");
            });

            it("rotates the session ID after the second factor", () => {
                expect(scanner.branchBody("frontend/core/handler/register.cfm", "form", "mfa_btn")).toInclude("sessionRotate()");
            });

        });

        describe("Links with tokens (frontend/core/handler/register.cfm)", () => {

            it("accepts registration and invitation links only while they are valid", () => {
                var body = scanner.branchBody("frontend/core/handler/register.cfm", "url", "u");
                expect(body).toInclude("objRegister.getValidOptin(url.u)");
                expect(body).toInclude("getUserByValidToken(url.u, ""invitation"")");
            });

            it("accepts a password reset link only while it is valid", () => {
                expect(scanner.branchBody("frontend/core/handler/register.cfm", "url", "p")).toInclude("getUserByValidToken(url.p, ""reset"")");
            });

            it("checks the reset token again when the new password is saved", () => {
                expect(scanner.branchBody("frontend/core/handler/register.cfm", "form", "reset_pw_btn_2")).toInclude("""reset"").recordCount");
            });

        });

        describe("Password policy", () => {

            var branches = [
                { file: "frontend/core/handler/register.cfm", scope: "form", key: "create_account" },
                { file: "frontend/core/handler/register.cfm", scope: "form", key: "reset_pw_btn_2" },
                { file: "backend/core/handler/user.cfm", scope: "form", key: "change_pw_btn" },
                { file: "backend/core/handler/sysadmin/customers.cfm", scope: "form", key: "add_customer" }
            ];

            for (var branch in branches) {
                it(
                    title = "is checked in " & branch.file & " (" & branch.key & ")",
                    data  = branch,
                    body  = (data) => {
                        var body = scanner.branchBody(data.file, data.scope, data.key);
                        expect(body).toInclude("isValidPassword(form.password)");
                        var hashedAt = find("hashPassword(", body);
                        if (hashedAt) {
                            expect(find("isValidPassword(", body)).toBeLT(hashedAt, "The policy must be checked before the password is hashed");
                        }
                    }
                );
            }

        });

        describe("User roles (backend/core/handler/user.cfm)", () => {

            it("checks canEditUser and allowedRoles when a user is edited", () => {
                var body = scanner.branchBody("backend/core/handler/user.cfm", "form", "edit_profile_btn");
                expect(body).toInclude("objUser.canEditUser(");
                expect(body).toInclude("objUser.allowedRoles(");
            });

            it("checks canCreateUser and allowedRoles when a user is created", () => {
                var body = scanner.branchBody("backend/core/handler/user.cfm", "form", "user_new_btn");
                expect(body).toInclude("objUser.canCreateUser(");
                expect(body).toInclude("objUser.allowedRoles(");
            });

        });

        describe("Support login", () => {

            it("remembers the sysadmin and rotates the session ID when logging in as a customer", () => {
                var body = scanner.branchBody("backend/core/handler/sysadmin/customers.cfm", "url", "logincustomer");
                expect(body).toInclude("sessionRotate()");
                expect(body).toInclude("session.supportOriginUserID = session.user_id");
            });

            it("returns only to the remembered, still active sysadmin", () => {
                var body = scanner.branchBody("backend/core/handler/customer.cfm", "url", "sysadmin");
                expect(body).toInclude("session.supportOriginUserID");
                expect(reFindNoCase("blnSysAdmin\s*=\s*1", body)).toBeGT(0);
                expect(reFindNoCase("blnActive\s*=\s*1", body)).toBeGT(0);
                expect(body).toInclude("sessionRotate()");
                expect(body).toInclude("structDelete(session, ""supportOriginUserID"")");
            });

        });

        describe("Drag-and-drop sorting (backend/core/handler/ajax_sort.cfm)", () => {

            var source = scanner.readSource("backend/core/handler/ajax_sort.cfm");
            var firstQuery = find("queryExecute", source);

            it("is reserved for sysadmins, checked before any query", () => {
                var check = find("session.sysadmin", source);
                expect(check).toBeGT(0);
                expect(check).toBeLT(firstQuery);
            });

            it("needs a POST with a valid CSRF token, checked before any query", () => {
                var check = find("csrfVerify()", source);
                expect(check).toBeGT(0);
                expect(check).toBeLT(firstQuery);
                expect(source).toInclude("cgi.request_method neq ""POST""");
            });

            it("takes no table or SQL fragment from the URL", () => {
                expect(source).notToInclude("url.extend");
            });

        });

        describe("Sysadmin input that ends up in SQL", () => {

            it("casts the invoice status filter to a whole number", () => {
                var source = scanner.readSource("backend/core/views/sysadmin/invoices.cfm");
                expect(source).toInclude("session.status = isValid(""integer"", form.status) ? int(form.status) : 0;");
            });

            it("validates the language codes of the translation tool", () => {
                var source = scanner.readSource("backend/core/handler/sysadmin/translations.cfm");
                expect(source).toInclude("[A-Za-z]{2}$"", form.fromLang");
                expect(source).toInclude("[A-Za-z]{2}$"", form.toLang");
            });

            it("checks table and column names of the translation modal against the schema", () => {
                expect(scanner.readSource("backend/core/handler/sysadmin/languages.cfm")).toInclude("isKnownColumn(");
            });

            it("keeps only whole numbers of the tenant list in updateUser()", () => {
                expect(scanner.readSource("backend/core/com/user.cfc")).toInclude("filter((tenant) => isValid(""integer"", trim(tenant)))");
            });

        });

        describe("Full-text searches", () => {

            it("pass the search through fullTextSearch() in every function with MATCH ... AGAINST", () => {
                var missing = [];

                for (var file in scanner.filesBelow(["backend/core/com", "frontend/core/com", "api"]).filter((f) => right(f, 4) eq ".cfc")) {
                    var functions = listToArray(reReplace(scanner.readSource(file), "\bfunction\s+", chr(30), "all"), chr(30), true);
                    for (var index = 2; index lte arrayLen(functions); index++) {
                        if (reFindNoCase("AGAINST\s*\(\s*:", functions[index]) and not find("fullTextSearch(arguments.search)", functions[index])) {
                            arrayAppend(missing, file & ": " & listFirst(functions[index], "("));
                        }
                    }
                }

                if (arrayLen(missing)) {
                    fail("Full-text searches without fullTextSearch():" & chr(10) & arrayToList(missing, chr(10)));
                }
            });

        });

        describe("User data in mails", () => {

            it("encodes the name in the registration mail", () => {
                var body = scanner.branchBody("frontend/core/handler/register.cfm", "form", "register_btn");
                expect(body).toInclude("encodeForHTML(form.first_name)");
                expect(body).toInclude("encodeForHTML(form.name)");
            });

            it("encodes the name in the password reset mail", () => {
                var body = scanner.branchBody("frontend/core/handler/register.cfm", "form", "reset_pw_btn_1");
                expect(body).toInclude("encodeForHTML(qCheckUser.strFirstName)");
                expect(body).toInclude("encodeForHTML(qCheckUser.strLastName)");
            });

        });

    }

}
