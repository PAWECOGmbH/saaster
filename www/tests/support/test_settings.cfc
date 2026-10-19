component output="false" hint="Reads the local test configuration and builds the datasource definition from it." {

    /*
        The Lucee container does not get the database credentials as environment
        variables - it only knows the datasource configured in the Lucee admin,
        and that one points to the development database. Tests must never use it,
        so they need a source of their own.

        bin/write_test_config.sh writes the values from the project .env into
        config/testing.json. That file is git-ignored and read here.
    */

    public struct function load() {
        var configFile = expandPath("/tests/config/testing.json");

        if (not fileExists(configFile)) {
            throw(
                type    = "Saaster.Tests.MissingConfiguration",
                message = "www/tests/config/testing.json is missing.",
                detail  = "Run 'bash www/tests/bin/prepare_test_db.sh' once."
            );
        }

        var settings = deserializeJSON(fileRead(configFile, "utf-8"));

        for (var requiredKey in ["datasourceName", "database", "host", "port", "user", "password"]) {
            if (not structKeyExists(settings, requiredKey)) {
                throw(
                    type    = "Saaster.Tests.MissingConfiguration",
                    message = "The key '#requiredKey#' is missing in testing.json."
                );
            }
        }

        guardTestDatabaseName(settings.database);

        return settings;
    }

    /*
        The emergency brake. A typo in testing.json would otherwise be enough for
        specs that create and delete data to run against the development
        database. Without "test" in its name, the test application refuses to start.
    */
    public void function guardTestDatabaseName(required string database) {
        if (not findNoCase("test", arguments.database)) {
            throw(
                type    = "Saaster.Tests.UnsafeDatabase",
                message = "The test database '#arguments.database#' does not contain 'test' in its name.",
                detail  = "The test application refuses any other database."
            );
        }
    }

    public struct function buildDatasourceDefinition(required struct settings) {
        return {
            class: "com.mysql.cj.jdbc.Driver",
            bundleName: "com.mysql.cj",
            bundleVersion: "8.4.0",
            connectionString: "jdbc:mysql://" & arguments.settings.host & ":" & arguments.settings.port
                & "/" & arguments.settings.database
                & "?characterEncoding=UTF-8&serverTimezone=UTC&allowPublicKeyRetrieval=true&useSSL=false",
            username: arguments.settings.user,
            password: arguments.settings.password
        };
    }

}
