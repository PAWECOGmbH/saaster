<cfsetting showdebugoutput="false">
<cfscript>
/*
    Runs the real worker (frontend/core/scheduletasks/tasks.cfm) inside the test
    application, i.e. against the test database. Used by specs/integration/scheduler_worker_spec.cfc.

    The worker reads its settings from the variables scope (config.cfm in the real
    application); they are set here from the URL. application.objLog is replaced by
    the log recorder for the duration of the run, so nothing lands in the log files.

    Answer: { ran: [what the probe tasks received], logs: [recorded log calls] }.
    If the worker aborts (invalid task number, worker above the limit), the answer
    stays empty - the spec then checks the database only.

    It only lives inside the test application, which refuses to start outside of
    development.
*/
variables.schedulePassword = "testbox-scheduler-probe";
variables.scheduleLeaseMinutes = structKeyExists(url, "lease") ? val(url.lease) : 60;
variables.scheduleWorkers = structKeyExists(url, "workers") ? val(url.workers) : 20;
url.pass = structKeyExists(url, "wrongPass") ? "wrong" : variables.schedulePassword;

request.schedulerProbe = [];
originalLog = application.objLog;
recorder = new tests.support.log_recorder();
application.objLog = recorder;

try {
    include template="/frontend/core/scheduletasks/tasks.cfm";
} finally {
    application.objLog = originalLog;
}

content type="application/json" reset="true";
writeOutput(serializeJSON({ "ran": request.schedulerProbe, "logs": recorder.getCalls() }));
</cfscript>
