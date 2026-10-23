component extends="testbox.system.BaseSpec" {

    /*
        The web server configuration (config/nginx/conf.d/base.conf, template:
        config/example.base.conf) - checked over HTTP against the nginx in front of
        Lucee: security headers on every kind of response, and no script execution
        below /userdata, where uploads are stored.

        Skipped when no nginx answers on 127.0.0.1 (e.g. another web server setup).
    */

    variables.baseUrl = "http://127.0.0.1";

    variables.headers = {
        "X-Frame-Options": "SAMEORIGIN",
        "Content-Security-Policy": "frame-ancestors 'self'",
        "X-Content-Type-Options": "nosniff",
        "Referrer-Policy": "strict-origin-when-cross-origin",
        "Permissions-Policy": "camera=(), microphone=(), geolocation=()"
    };

    function run() {

        var behindNginx = findNoCase("nginx", fetch("/assets/img/logo.png").header("Server")) gt 0;

        describe("nginx", () => {

            describe("Security headers", () => {

                var targets = {
                    "a static file": "/assets/img/logo.png",
                    "a CFML page": "/tests/healthcheck.cfm",
                    "a page that does not exist": "/testbox-does-not-exist-" & createUUID(),
                    "a blocked path": "/userdata/testbox-probe.cfm"
                };

                for (var label in targets) {
                    it(
                        title = "are sent with " & label,
                        skip  = not behindNginx,
                        data  = { path: targets[label] },
                        body  = (data) => {
                            var response = fetch(data.path);
                            for (var name in variables.headers) {
                                expect(response.header(name)).toBe(variables.headers[name], name & " on " & data.path);
                            }
                        }
                    );
                }

            });

            describe("Uploads folder", () => {

                var blocked = [
                    "/userdata/testbox-probe.cfm",
                    "/userdata/images/testbox-probe.cfc",
                    "/userdata/testbox-probe.CFM",
                    "/userdata/testbox-probe.cfml",
                    "/userdata/testbox-probe.jsp",
                    "/userdata/testbox-probe.cfm/path-info"
                ];

                for (var path in blocked) {
                    it(
                        title = "refuses to run " & path,
                        skip  = not behindNginx,
                        data  = { path: path },
                        body  = (data) => {
                            expect(fetch(data.path).status).toBe(403);
                        }
                    );
                }

            });

            it(
                title = "hides Application.cfc",
                skip  = not behindNginx,
                body  = () => {
                    expect([403, 404]).toInclude(fetch("/Application.cfc").status);
                }
            );

        });

    }

    private struct function fetch(required string path) {
        cfhttp(url = variables.baseUrl & arguments.path, method = "get", redirect = false, timeout = 10, result = "local.response");

        var responseHeaders = local.response.responseHeader;
        return {
            status: val(local.response.statusCode),
            header: (name) => structKeyExists(responseHeaders, name) ? (isArray(responseHeaders[name]) ? responseHeaders[name][1] : responseHeaders[name]) : ""
        };
    }

}
