<cfsetting showdebugoutput="false" />
<!---
    Checks in one call whether the test application is ready: own datasource
    reachable, migrations applied, Saaster bootstrap completed.
--->
<cfscript>
response = {
    "datasource": request.testSettings.datasourceName,
    "database": request.testSettings.database,
    "applicationDatasource": application.datasource,
    "objectsLoaded": arrayLen(structKeyArray(application).filter((key) => left(key, 3) eq "obj")),
    "migrations": {},
    "ok": false
};

try {
    // Proves that the connection really points to the test database, not just a datasource with the right name.
    response["connectedDatabase"] = queryExecute("SELECT DATABASE() AS db", {}, { datasource: application.datasource }).db;

    for (folder in ["core", "myapp"]) {
        try {
            response.migrations[folder] = queryExecute(
                "SELECT COUNT(*) AS cnt FROM flyway_#folder# WHERE success = 1", {}, { datasource: application.datasource }
            ).cnt;
        } catch (any e) {
            response.migrations[folder] = 0;
        }
    }

    response["ok"] = response.connectedDatabase eq request.testSettings.database
        and response.migrations.core gt 0
        and response.objectsLoaded gt 0;
} catch (any e) {
    response["error"] = e.message;
}

cfcontent(type="application/json; charset=utf-8", reset=true);
writeOutput(serializeJSON(response));
</cfscript>
