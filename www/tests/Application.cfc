component output="false" hint="Separate application for TestBox runs: own application scope, own database." {

    variables.testsRoot = getDirectoryFromPath(getCurrentTemplatePath());
    variables.webRoot   = variables.testsRoot & "../";

    this.mappings["/tests"]   = variables.testsRoot;
    this.mappings["/testbox"] = variables.testsRoot & "vendor/testbox";
    this.mappings["/webroot"] = variables.webRoot;

    /*
        This folder lives inside the webroot. Everyone who deploys www/ - including
        everyone who forks Saaster - ships it to their server. A test run creates
        and deletes data, so it must not even start outside of development.

        Saaster has no environment variable for this, but config.cfm knows the
        environment. The check runs first, before anything else is loaded.
    */
    include template="../config.cfm";

    if (not structKeyExists(variables, "environment") or lCase(trim(variables.environment)) neq "dev") {
        throw(
            type    = "Saaster.Tests.NotDevelopment",
            message = "The test application only runs in the development environment (config.cfm: variables.environment = ""dev"")."
        );
    }

    variables.testSettingsLoader = new tests.support.test_settings();
    variables.testSettings       = variables.testSettingsLoader.load();
    variables.testDatasource     = variables.testSettingsLoader.buildDatasourceDefinition(variables.testSettings);

    // Own name = own application scope. The running app under / is not touched,
    // even if specs replace objects in the application scope.
    this.name               = "saaster-tests-" & variables.testSettings.database;
    this.sessionManagement  = true;
    this.clientManagement   = false;
    this.applicationTimeout = createTimeSpan(0, 0, 30, 0);
    this.sessionTimeout     = createTimeSpan(0, 0, 30, 0);
    this.charset.web        = "utf-8";
    this.charset.resource   = "utf-8";
    this.timezone           = "UTC+00:00"; // Same as the real Application.cfc
    this.javaSettings       = { loadPaths: [variables.webRoot & "assets/java"], reloadOnChange: false };

    /*
        The datasource is defined on application level and overrides entries with
        the same name from the Lucee admin - but only inside this test application.

        It is deliberately registered twice: under its own name, and under the name
        from config.cfm (variables.datasource). The real onApplicationStart below
        sets application.datasource from config.cfm and queries the database right
        away (languages, system settings). If that name pointed to the real
        datasource, those queries would hit the development database. This way,
        every name the app knows points to the test database.
    */
    this.datasources = {};
    this.datasources[variables.testSettings.datasourceName] = variables.testDatasource;
    this.datasources[variables.datasource] = variables.testDatasource;
    this.defaultDatasource = variables.testSettings.datasourceName;

    /*
        The Saaster components are not injectable services: they rely on
        application.datasource, application.objGlobal and other values set during
        the application start. A rebuilt bootstrap would drift apart with every
        change to the real Application.cfc.

        So the real start is called here. "application" is the scope of THIS test
        application, the assignments end up in it - just with the datasources from above.
    */
    public boolean function onApplicationStart() {
        var appBootstrap = createObject("component", "webroot.Application");
        appBootstrap.onApplicationStart();

        application.datasource   = variables.testSettings.datasourceName;
        application.testSettings = duplicate(variables.testSettings);

        return true;
    }

    public void function onSessionStart() {
        // Sets session.lng and session.usersIP exactly like the real application.
        createObject("component", "webroot.Application").onSessionStart();
    }

    public boolean function onRequestStart(required string targetPage) {
        setting showdebugoutput = false;
        request.testSettings = duplicate(variables.testSettings);

        // Components are cached in the application scope. Without a restart, a run
        // would test the old version of a changed .cfc and stay green anyway.
        if (structKeyExists(url, "reinit")) {
            applicationStop();
            location(url = cgi.script_name & "?" & reReplaceNoCase(cgi.query_string, "&?reinit=[^&]*", "", "all"), addToken = false);
        }

        return true;
    }

}
