component extends="testbox.system.BaseSpec" {

    /*
        global.cfc - the CSRF building blocks: the rule which requests need a
        token (csrfRequired, used by Application.cfc for every request), the token
        helpers used in forms and links, and the verification.

        The X-CSRF-Token request header path of csrfVerify() is not covered here:
        a spec cannot set headers on the running request. backend.js sends it for
        every non-GET AJAX call.
    */

    // In BDD specs, lifecycle hooks per spec go inside describe() - a component-level
    // afterEach() is not called. Without this, a token from one spec leaks into the next.
    private void function clearTokens() {
        structDelete(form, "csrf_token");
        structDelete(url, "csrf_token");
    }

    function run() {

        describe("csrfRequired", () => {

            it("requires a token for every POST to a core handler", () => {
                expect(application.objGlobal.csrfRequired("backend/core/handler/user.cfm", "POST", [])).toBeTrue();
                expect(application.objGlobal.csrfRequired("frontend/core/handler/register.cfm", "POST", [])).toBeTrue();
                expect(application.objGlobal.csrfRequired("backend/core/handler/sysadmin/plans.cfm", "post", [])).toBeTrue();
            });

            it("accepts the path with a leading slash", () => {
                expect(application.objGlobal.csrfRequired("/backend/core/handler/user.cfm", "POST", [])).toBeTrue();
            });

            it("does not require a token for a POST to a view (search and filter forms)", () => {
                expect(application.objGlobal.csrfRequired("backend/core/views/sysadmin/customers.cfm", "POST", [])).toBeFalse();
            });

            it("does not require a token for templates outside the core handlers", () => {
                expect(application.objGlobal.csrfRequired("backend/myapp/handler/something.cfm", "POST", [])).toBeFalse();
                expect(application.objGlobal.csrfRequired("frontend/default_theme/templates/home.cfm", "POST", [])).toBeFalse();
            });

            it("does not require a token for a plain GET to a handler", () => {
                expect(application.objGlobal.csrfRequired("backend/core/handler/user.cfm", "GET", [])).toBeFalse();
                expect(application.objGlobal.csrfRequired("backend/core/handler/user.cfm", "GET", ["page", "l"])).toBeFalse();
            });

            it("requires a token for state-changing GET keys", () => {
                for (var key in ["delete", "delete_plan", "del_photo", "del_logo", "remove_country", "revoke", "noti_del", "invit"]) {
                    expect(application.objGlobal.csrfRequired("backend/core/handler/user.cfm", "GET", [key])).toBeTrue("GET key [#key#] must require a token");
                }
            });

            it("requires a token for the GET keys listed per handler", () => {
                var cases = {
                    "backend/core/handler/payment.cfm": ["del", "default"],
                    "backend/core/handler/sysadmin/invoices.cfm": ["status", "email", "open"],
                    "backend/core/handler/sysadmin/logs.cfm": ["logfile"],
                    "backend/core/handler/sysadmin/plans.cfm": ["booking"],
                    "backend/core/handler/sysadmin/modules.cfm": ["booking"]
                };

                for (var path in cases) {
                    for (var key in cases[path]) {
                        expect(application.objGlobal.csrfRequired(path, "GET", [key])).toBeTrue("GET key [#key#] on [#path#] must require a token");
                        expect(application.objGlobal.csrfRequired("/" & path, "GET", [key])).toBeTrue("Leading slash: GET key [#key#] on [#path#]");
                    }
                }
            });

            it("keeps the per-handler keys limited to their handler", () => {
                for (var key in ["status", "email", "open", "default", "del", "logfile", "booking"]) {
                    expect(application.objGlobal.csrfRequired("backend/core/handler/user.cfm", "GET", [key])).toBeFalse("GET key [#key#] must not be protected on an unrelated handler");
                }
            });

            it("leaves the documented entry points of protected handlers open", () => {
                // Payrexx checkout and return links cannot carry a token.
                expect(application.objGlobal.csrfRequired("backend/core/handler/payment.cfm", "GET", ["add"])).toBeFalse();
                expect(application.objGlobal.csrfRequired("backend/core/handler/payment.cfm", "GET", ["pay", "other", "psp_response"])).toBeFalse();
            });

            it("requires a token for every request to the cancel handler", () => {
                expect(application.objGlobal.csrfRequired("backend/core/handler/cancel.cfm", "GET", ["plan"])).toBeTrue();
                expect(application.objGlobal.csrfRequired("backend/core/handler/cancel.cfm", "GET", [])).toBeTrue();
            });

        });

        describe("token helpers", () => {

            it("csrfToken returns a token that stays the same within the session", () => {
                var token = application.objGlobal.csrfToken();

                expect(len(token)).toBeGT(0);
                expect(application.objGlobal.csrfToken()).toBe(token);
            });

            it("csrfField renders a hidden input named csrf_token with the session token", () => {
                var field = application.objGlobal.csrfField();

                expect(field).toInclude('type="hidden"');
                expect(field).toInclude('name="csrf_token"');
                expect(field).toInclude('value="' & application.objGlobal.csrfToken() & '"');
            });

            it("csrfParam renders the url parameter with the session token", () => {
                expect(application.objGlobal.csrfParam()).toBe("csrf_token=" & application.objGlobal.csrfToken());
            });

        });

        describe("csrfVerify", () => {

            beforeEach(() => clearTokens());
            afterEach(() => clearTokens());

            it("accepts the session token from a form field", () => {
                form.csrf_token = application.objGlobal.csrfToken();

                expect(application.objGlobal.csrfVerify()).toBeTrue();
            });

            it("accepts the session token from a url parameter", () => {
                url.csrf_token = application.objGlobal.csrfToken();

                expect(application.objGlobal.csrfVerify()).toBeTrue();
            });

            it("rejects a wrong token", () => {
                form.csrf_token = "not-the-session-token";

                expect(application.objGlobal.csrfVerify()).toBeFalse();
            });

            it("rejects a request without any token", () => {
                expect(application.objGlobal.csrfVerify()).toBeFalse();
            });

            /*
                Lucee 6.0 answers CSRFVerifyToken("") with true. csrfVerify must
                therefore never pass an empty or blank token on - this spec guards that.
            */
            it("rejects an empty token", () => {
                form.csrf_token = "   ";

                expect(application.objGlobal.csrfVerify()).toBeFalse();
            });

        });

    }

}
