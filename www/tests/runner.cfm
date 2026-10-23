<cfsetting showdebugoutput="false">
<cfsetting requesttimeout="1800">

<!---
    UI and HTTP interface for TestBox runs.

    Opened in the browser without parameters, the page shows the UI: pick
    directories or single specs, run them, see the failed expectations in plain text.

    As soon as reporter=... is passed - this is how bin/run_tests.sh calls it -
    the file behaves like the classic TestBox runner and only returns the output
    of the chosen reporter.

    Parameters:
      reporter        json | mintext | text | simple | junit ...
      directory       comma list of directories, default unit + integration
      bundles         comma list of single specs, wins over directory
      recurse         include subdirectories (default true)
      labels          only specs with these labels
      excludes        skip specs with these labels
      dryRun          only returns the list of specs found, as JSON
      gui             1 forces the UI, mode=api forces the opposite
--->

<cfparam name="url.reporter" default="simple">
<cfparam name="url.directory" default="tests.specs.unit,tests.specs.integration">
<cfparam name="url.bundles" default="">
<cfparam name="url.recurse" default="true" type="boolean">
<cfparam name="url.labels" default="">
<cfparam name="url.excludes" default="">
<cfparam name="url.bundlesPattern" default="*.cfc">
<cfparam name="url.dryRun" default="false" type="boolean">
<cfparam name="url.mode" default="">
<cfparam name="url.gui" default="">

<cfscript>
queryStringValue  = structKeyExists(cgi, "query_string") ? cgi.query_string : "";
hasReporterParam  = reFindNoCase("(^|&)reporter=", queryStringValue) gt 0;
hasDirectoryParam = reFindNoCase("(^|&)directory=", queryStringValue) gt 0;
hasBundlesParam   = reFindNoCase("(^|&)bundles=", queryStringValue) gt 0;
guiForced         = listFindNoCase("1,true,yes,on", trim(url.gui & "")) gt 0;
apiForced         = lCase(trim(url.mode)) eq "api";

// The UI is the default in the browser. Everything that names a reporter or
// explicitly asks for the interface gets raw output.
useGui = guiForced or (not hasReporterParam and not url.dryRun and not apiForced);

if (len(trim(url.bundles))) {
    url.directory = "";
}

if (not directoryExists(expandPath("/testbox/system"))) {
    cfheader(statuscode = 503, statustext = "Service Unavailable");
    cfcontent(type = "text/plain; charset=utf-8", reset = true);
    writeOutput("TestBox is not installed yet." & chr(10)
        & "Run once: bash www/tests/bin/install_test_dependencies.sh");
    abort;
}

// Turns the file path into the component path TestBox expects:
// /var/www/tests/specs/unit/global_spec.cfc -> tests.specs.unit.global_spec
function toDottedPath(required string absolutePath, required string testsRootPath) {
    var relativePath = replaceNoCase(
        replace(arguments.absolutePath, "\", "/", "all"),
        replace(arguments.testsRootPath, "\", "/", "all") & "/",
        "",
        "one"
    );

    relativePath = reReplace(relativePath, "\.cfc$", "", "one");

    return "tests." & replace(relativePath, "/", ".", "all");
}

function listSelected(required string rawValue) {
    var selectedValues = [];

    for (var entry in listToArray(arguments.rawValue)) {
        entry = trim(entry);

        if (len(entry)) {
            arrayAppend(selectedValues, entry);
        }
    }

    return selectedValues;
}

selectedBundles     = listSelected(url.bundles);
selectedDirectories = listSelected(url.directory);

if (useGui) {
    testsRootPath = reReplace(expandPath("/tests"), "[\\/]+$", "");
    specRootPath  = expandPath("/tests/specs");

    availableBundles     = [];
    availableDirectories = [];
    knownDirectories     = {};

    for (specFilePath in (directoryExists(specRootPath) ? directoryList(specRootPath, true, "path", "*.cfc") : [])) {
        bundleName = toDottedPath(specFilePath, testsRootPath);
        arrayAppend(availableBundles, bundleName);

        // Every level above the spec is a selectable directory, but only from
        // "tests.specs.x" on - "tests" or "tests.specs" would just be noise.
        directorySegments = listToArray(listDeleteAt(bundleName, listLen(bundleName, "."), "."), ".");
        directoryPrefix   = "";

        for (segment in directorySegments) {
            directoryPrefix = len(directoryPrefix) ? directoryPrefix & "." & segment : segment;

            if (listLen(directoryPrefix, ".") gte 3 and not structKeyExists(knownDirectories, directoryPrefix)) {
                knownDirectories[directoryPrefix] = true;
                arrayAppend(availableDirectories, directoryPrefix);
            }
        }
    }

    arraySort(availableBundles, "textnocase");
    arraySort(availableDirectories, "textnocase");

    guiData = {
        "runnerPath": cgi.script_name,
        "availableBundles": availableBundles,
        "availableDirectories": availableDirectories,
        "defaultBundles": hasBundlesParam ? selectedBundles : [],
        "defaultDirectories": hasDirectoryParam ? selectedDirectories : availableDirectories,
        "defaultSelectionMode": arrayLen(selectedBundles) ? "bundles" : "directory",
        "defaultRecurse": url.recurse,
        "defaultLabels": url.labels,
        "defaultExcludes": url.excludes
    };
}
</cfscript>

<cfif useGui>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Saaster Test Runner</title>
    <style><cfinclude template="runner.css"></style>
</head>
<body>
<div class="page">

    <section class="card">
        <h1>Saaster Test Runner</h1>
        <p class="subtle">
            Runs against the test database, never against the development database.
            From the shell: <code>bash www/tests/bin/run_tests.sh</code>
        </p>
    </section>

    <section class="card">
        <h2>Test environment</h2>
        <div class="environment-grid">
            <div class="environment-item">
                <div class="label">Database</div>
                <div id="envDatabase" class="value">...</div>
            </div>
            <div class="environment-item">
                <div class="label">Datasource</div>
                <div id="envDatasource" class="value">...</div>
            </div>
            <div class="environment-item">
                <div class="label">Migrations (core / myapp)</div>
                <div id="envMigrations" class="value">...</div>
            </div>
            <div class="environment-item">
                <div class="label">Loaded objects</div>
                <div id="envObjects" class="value">...</div>
            </div>
        </div>
        <p class="help-text">
            New migrations from <code>config/db</code>: <code>bash www/tests/bin/migrate_test_db.sh</code>.
            Rebuild from scratch: <code>bash www/tests/bin/prepare_test_db.sh</code>.
            After changing a component, reload the test application with <code>?reinit=1</code>.
        </p>
    </section>

    <section class="card">
        <h2>Selection</h2>
        <div class="form-grid">
            <div>
                <label for="selectionMode">Selection mode</label>
                <select id="selectionMode">
                    <option value="directory">Directory</option>
                    <option value="bundles">Single specs</option>
                </select>
                <p class="help-text">
                    <code>Directory</code> runs whole folders,
                    <code>Single specs</code> only the selected files.
                </p>
            </div>
            <div>
                <label for="labelsInput">Labels (optional)</label>
                <input id="labelsInput" type="text" placeholder="smoke,slow">
                <p class="help-text">
                    Comma list. Only specs carrying at least one of these labels run.
                </p>
            </div>
            <div>
                <label for="excludesInput">Excludes (optional)</label>
                <input id="excludesInput" type="text" placeholder="slow,flaky">
                <p class="help-text">
                    Comma list. Specs with these labels are skipped.
                </p>
            </div>
        </div>

        <div class="selection-panel">
            <div id="directoryPanel">
                <label for="directorySelect">Directories (multiple selection possible)</label>
                <select id="directorySelect" multiple></select>
            </div>
            <div id="bundlePanel" class="hidden">
                <label for="bundleSelect">Specs (multiple selection possible)</label>
                <select id="bundleSelect" multiple></select>
            </div>
            <div class="row-actions">
                <button id="runButton" class="btn btn-primary" type="button">Run selection</button>
                <button id="clearButton" class="btn btn-secondary" type="button">Clear selection</button>
                <label style="margin:0;font-weight:400;">
                    <input id="recurseCheckbox" type="checkbox" checked>
                    Include subdirectories
                </label>
                <span id="statusPill" class="status-pill status-idle">Ready</span>
                <span id="currentTarget" class="subtle">Current: nothing</span>
            </div>
        </div>
    </section>

    <section class="card">
        <h2>Summary</h2>
        <div class="summary-grid">
            <div class="summary-item">
                <div class="label">Specs</div>
                <div id="summarySpecs" class="value">0</div>
            </div>
            <div class="summary-item">
                <div class="label">Passed</div>
                <div id="summaryPass" class="value text-pass">0</div>
            </div>
            <div class="summary-item">
                <div class="label">Failed</div>
                <div id="summaryFail" class="value text-fail">0</div>
            </div>
            <div class="summary-item">
                <div class="label">Errors</div>
                <div id="summaryError" class="value text-fail">0</div>
            </div>
            <div class="summary-item">
                <div class="label">Skipped</div>
                <div id="summarySkipped" class="value">0</div>
            </div>
            <div class="summary-item">
                <div class="label">Duration (ms)</div>
                <div id="summaryDuration" class="value">0</div>
            </div>
        </div>
    </section>

    <section class="card">
        <h2>Specs</h2>
        <table>
            <thead>
                <tr>
                    <th>Status</th>
                    <th>Spec</th>
                    <th class="numeric">Specs</th>
                    <th class="numeric">Passed</th>
                    <th class="numeric">Failed</th>
                    <th class="numeric">Errors</th>
                    <th class="numeric">Duration</th>
                </tr>
            </thead>
            <tbody id="bundleTableBody">
                <tr><td colspan="7" class="subtle">No run started yet.</td></tr>
            </tbody>
        </table>
    </section>

    <section class="card">
        <h2>Raw data</h2>
        <pre id="rawOutput">{}</pre>
    </section>

</div>

<script>
    window.testRunnerInitialData = JSON.parse("<cfoutput>#encodeForJavaScript(serializeJSON(guiData))#</cfoutput>" || "{}");
</script>
<script><cfinclude template="runner.js"></script>
</body>
</html>
<cfabort>
</cfif>

<cfscript>
hasSelection = arrayLen(selectedBundles) gt 0 or arrayLen(selectedDirectories) gt 0;

if (not hasSelection) {
    cfcontent(type = "application/json; charset=utf-8", reset = true);
    writeOutput(serializeJSON({
        "totalSpecs": 0,
        "totalPass": 0,
        "totalFail": 0,
        "totalError": 1,
        "totalDuration": 0,
        "bundleStats": [],
        "errors": [{ "message": "Neither a directory nor a spec was selected." }]
    }));
    abort;
}

testRunner = new testbox.system.TestBox(
    labels         = url.labels,
    excludes       = url.excludes,
    bundlesPattern = url.bundlesPattern
);

if (arrayLen(selectedBundles)) {
    testRunner.addBundles(arrayToList(selectedBundles));
}

for (directoryName in selectedDirectories) {
    testRunner.addDirectories(directoryName, url.recurse);
}

// The dry run only collects which specs belong to the selection. The UI needs
// this to start the specs one by one and show the progress while they run.
if (url.dryRun) {
    cfcontent(type = "application/json; charset=utf-8", reset = true);
    writeOutput(serializeJSON(testRunner.dryRun()));
    abort;
}

runnerOutput = testRunner.run(reporter = url.reporter);

switch (lCase(url.reporter)) {
    case "json":
        cfcontent(type = "application/json; charset=utf-8", reset = true);
        break;
    case "junit":
    case "xml":
        cfcontent(type = "application/xml; charset=utf-8", reset = true);
        break;
    case "text":
    case "mintext":
    case "min":
        cfcontent(type = "text/plain; charset=utf-8", reset = true);
        break;
}

writeOutput(runnerOutput);
</cfscript>
