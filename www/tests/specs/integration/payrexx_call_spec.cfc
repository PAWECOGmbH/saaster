component extends="tests.support.integration_spec" {

    /*
        payrexx.cfc::callPayrexx - the request format towards Payrexx.

        Regression: removing a payment method sends an HTTP DELETE. The legacy
        Payrexx API v1.0 does not accept the URL signature for DELETE, only the
        X-API-KEY header. GET and POST must keep their signature as before.

        All calls go to support/payrexx_mock.cfm inside this test application,
        never to the real Payrexx - even though config.cfm of a dev setup may
        hold real credentials. Each spec checks that before calling.

        Moved here from the former tests/payment-regression runner.
    */

    // Inside the Lucee container NGINX listens on port 80, independent of the
    // port published to the host (LUCEE_PORT). Why the URL ends with "?route=/"
    // is explained at the top of support/payrexx_mock.cfm.
    variables.mockUrl = "http://127.0.0.1/tests/support/payrexx_mock.cfm?route=/";
    variables.transactionID = 40964971;

    private any function payrexxWithKey(required string apiKey) {
        application.payrexxStruct = {
            payrexxAPIurl: variables.mockUrl,
            payrexxAPIinstance: "regression",
            payrexxAPIkey: arguments.apiKey
        };

        return new backend.core.com.payrexx();
    }

    function run() {

        describe("callPayrexx", () => {

            beforeEach(() => {
                variables.logs = recordLogs();
                variables.originalPayrexxStruct = duplicate(application.payrexxStruct);
                variables.payrexx = payrexxWithKey("test-key");

                // Emergency brake: never send a request anywhere but to the mock.
                expect(application.payrexxStruct.payrexxAPIurl).toBe(variables.mockUrl);
            });

            afterEach(() => {
                application.payrexxStruct = variables.originalPayrexxStruct;
                restoreLogs();
            });

            describe("DELETE", () => {

                it("uses the HTTP method DELETE", () => {
                    var response = variables.payrexx.callPayrexx({}, "DEL", "Transaction", variables.transactionID);

                    expect(response.status).toBe("success");
                    expect(response.data.method).toBe("DELETE");
                });

                it("targets the selected transaction", () => {
                    var response = variables.payrexx.callPayrexx({}, "DEL", "Transaction", variables.transactionID);

                    expect(response.data.path).toInclude("/Transaction/#variables.transactionID#/");
                });

                it("sends the instance but no URL signature", () => {
                    var response = variables.payrexx.callPayrexx({}, "DEL", "Transaction", variables.transactionID);

                    expect(response.data.query.instance).toBe("regression");
                    expect(response.data.query).notToHaveKey("ApiSignature");
                });

                it("authenticates via the X-API-KEY header without a body", () => {
                    var response = variables.payrexx.callPayrexx({}, "DEL", "Transaction", variables.transactionID);

                    expect(response.data.authenticated).toBeTrue();
                    expect(len(response.data.body)).toBe(0);
                });

                it("keeps payload values intact through URL encoding", () => {
                    var payload = { referenceId: "reference with spaces & symbols" };
                    var response = variables.payrexx.callPayrexx(payload, "DEL", "Transaction", variables.transactionID);

                    expect(response.data.query.referenceId).toBe(payload.referenceId);
                });

                it("uses header authentication also with a payload", () => {
                    var response = variables.payrexx.callPayrexx({ referenceId: "abc" }, "DEL", "Transaction", variables.transactionID);

                    expect(response.data.authenticated).toBeTrue();
                    expect(response.data.query).notToHaveKey("ApiSignature");
                });

                it("reports a wrong API key as an authentication failure, not as an unknown outcome", () => {
                    var response = payrexxWithKey("wrong-test-key").callPayrexx({}, "DEL", "Transaction", variables.transactionID);

                    expect(response.status).toBe("error");
                    expect(response.httpStatus).toBe(403);
                    expect(response.requestOutcomeUnknown).toBeFalse();
                });

                it("does not follow redirects", () => {
                    var response = variables.payrexx.callPayrexx({}, "DEL", "Redirect", variables.transactionID);

                    expect(response.status).toBe("error");
                    expect(response.httpStatus).toBe(302);
                });

                it("treats an HTML HTTP 500 as an error with unknown outcome", () => {
                    var response = variables.payrexx.callPayrexx({}, "DEL", "ServerError", variables.transactionID);

                    expect(response.status).toBe("error");
                    expect(response.httpStatus).toBe(500);
                    expect(response.requestOutcomeUnknown).toBeTrue();
                });

                it("treats a JSON HTTP 500 as an error with unknown outcome", () => {
                    var response = variables.payrexx.callPayrexx({}, "DEL", "JsonError", variables.transactionID);

                    expect(response.status).toBe("error");
                    expect(response.httpStatus).toBe(500);
                    expect(response.requestOutcomeUnknown).toBeTrue();
                });

            });

            describe("POST and GET (unchanged formats)", () => {

                it("POST sends the signature in the body, not in the URL", () => {
                    var response = variables.payrexx.callPayrexx({ referenceId: "abc" }, "POST", "Transaction", variables.transactionID);

                    expect(response.data.method).toBe("POST");
                    expect(response.data.query).notToHaveKey("ApiSignature");
                    expect(response.data.body).toInclude("ApiSignature=");
                });

                it("GET sends the signature in the URL", () => {
                    var response = variables.payrexx.callPayrexx({}, "GET", "Transaction", variables.transactionID);

                    expect(response.data.method).toBe("GET");
                    expect(response.data.query).toHaveKey("ApiSignature");
                });

            });

        });

    }

}
