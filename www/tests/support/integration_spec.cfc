component extends="testbox.system.BaseSpec" hint="Base for specs that run against the test database." {

    /*
        Takes three things off every integration spec:

          - the assurance that the test database is really underneath
          - variables.fixtures to create customers and users
          - the cleanup afterwards, even if a spec dies halfway

        Specs extending this component must NOT define beforeAll/afterAll
        themselves - they would hide these two and leave their data behind.
        Per-spec setup belongs into beforeEach/afterEach inside the describe blocks.
    */

    function beforeAll() {
        // Second safety net next to the check in tests/Application.cfc: whoever
        // starts this component by hand inside the real application must not
        // create data in the development database by accident.
        if (not structKeyExists(request, "testSettings")
            or not structKeyExists(application, "datasource")
            or application.datasource neq request.testSettings.datasourceName) {
            throw(
                type    = "Saaster.Tests.WrongDatasource",
                message = "Integration specs only run against the test database."
            );
        }

        variables.fixtures = new tests.support.fixtures();
        variables.fixtures.removeOrphans();

        prepareSession();
    }

    function afterAll() {
        logout();
        restoreLogs();

        if (structKeyExists(variables, "fixtures")) {
            variables.fixtures.cleanup();
        }
    }

    /*
        Replaces application.objLog with a recorder (support/log_recorder.cfc):
        no log files, no log mails, and the calls can be checked. The real logger
        comes back with restoreLogs() - afterAll does that in any case.
    */
    function recordLogs() {
        if (not structKeyExists(variables, "originalLog")) {
            variables.originalLog = application.objLog;
        }

        variables.logRecorder = new tests.support.log_recorder();
        application.objLog = variables.logRecorder;

        return variables.logRecorder;
    }

    function restoreLogs() {
        if (structKeyExists(variables, "originalLog")) {
            application.objLog = variables.originalLog;
            structDelete(variables, "originalLog");
        }
    }

    // Even a visitor who is not logged in has a language in Saaster.
    private function prepareSession() {
        session.lng = "en";
    }

    /*
        Many components read the logged-in user from the session instead of
        taking it as an argument. This sets up the same session keys the login
        handler (frontend/core/handler/register.cfm) sets.
    */
    function loginAs(required struct user) {
        session.user_id    = arguments.user.userID;
        session.customer_id = arguments.user.customerID;
        session.user_name  = arguments.user.firstName & " " & arguments.user.lastName;
        session.user_email = arguments.user.email;
        session.lng        = arguments.user.language;
        session.admin      = arguments.user.admin;
        session.superadmin = arguments.user.superAdmin;
        session.sysadmin   = arguments.user.sysAdmin;

        return session;
    }

    function logout() {
        for (var key in ["user_id", "customer_id", "user_name", "user_email", "admin", "superadmin", "sysadmin"]) {
            structDelete(session, key);
        }
    }

}
