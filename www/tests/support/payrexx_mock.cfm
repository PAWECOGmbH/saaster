<cfsetting showdebugoutput="false">
<cfscript>
/*
    Local stand-in for the Payrexx API, used by specs/integration/payrexx_call_spec.cfc.

    payrexx.cfc builds its URLs as <payrexxAPIurl><object>/<id>/?instance=...
    Lucee only supports path info for the root index.cfm, so the object and id
    cannot arrive as a path here. The spec therefore sets payrexxAPIurl to
    ".../tests/support/payrexx_mock.cfm?route=/" - the call then looks like

        payrexx_mock.cfm?route=/Transaction/40964971/?instance=regression&referenceId=...

    and url.route ends up as "/Transaction/40964971/?instance=regression".
    Everything behind the second "?" belongs to the real query string and is
    split off again below, so the spec sees exactly what Payrexx would see.

    The mock echoes what it received (method, path, query, body, whether the
    API key header was correct), so a spec can check the exact request format.
    A few special object names provoke the error cases.

    It never talks to the real Payrexx. It only lives inside the test
    application, which refuses to start outside of development.
*/
expectedApiKey = "test-key";

route = structKeyExists(url, "route") ? url.route : "";
query = duplicate(url);
structDelete(query, "route");

if (find("?", route)) {
    for (pair in listToArray(listRest(route, "?"), "&")) {
        query[urlDecode(listFirst(pair, "="))] = listLen(pair, "=") gt 1 ? urlDecode(listRest(pair, "=")) : "";
    }
    route = listFirst(route, "?");
}

requestData   = getHTTPRequestData();
authenticated = structKeyExists(requestData.headers, "X-API-KEY") and requestData.headers["X-API-KEY"] eq expectedApiKey;

if (requestData.method eq "DELETE" and not authenticated) {
    // Matches the observed behaviour of the legacy Payrexx API v1.0: URL signatures
    // do not authenticate DELETE requests, only the X-API-KEY header does.
    cfheader(statuscode = 403, statustext = "Forbidden");
    cfcontent(type = "application/json", reset = true);
    writeOutput(serializeJSON({ "status": "error", "message": "An error occurred: The API secret is not correct." }));
} else if (findNoCase("/Redirect/", route)) {
    cfheader(statuscode = 302, statustext = "Found");
    cfheader(name = "Location", value = "http://127.0.0.1/tests/support/payrexx_mock.cfm?route=/Transaction/40964971/");
} else if (findNoCase("/ServerError/", route)) {
    cfheader(statuscode = 500, statustext = "Internal Server Error");
    cfcontent(type = "text/html", reset = true);
    writeOutput("Internal Server Error");
} else if (findNoCase("/JsonError/", route)) {
    cfheader(statuscode = 500, statustext = "Internal Server Error");
    cfcontent(type = "application/json", reset = true);
    writeOutput(serializeJSON({ "status": "error", "message": "Test server error" }));
} else {
    cfcontent(type = "application/json", reset = true);
    writeOutput(serializeJSON({
        "status": "success",
        "data": {
            "authenticated": authenticated,
            "method": requestData.method,
            "path": route,
            "query": query,
            "body": toString(requestData.content)
        }
    }));
}
</cfscript>
