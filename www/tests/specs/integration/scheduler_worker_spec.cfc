component extends="tests.support.integration_spec" {

    /*
        The worker frontend/core/scheduletasks/tasks.cfm - real runs through
        support/scheduler_worker_probe.cfm against the test database.

        Checks what a task file receives, what is written back after a successful,
        failed or missing task, and the protection of the worker: password, worker
        limit, a slot held by another run, a stale lease and the time budget.
    */

    variables.probeUrl = "http://127.0.0.1/tests/support/scheduler_worker_probe.cfm";

    function run() {

        describe("Scheduler worker (tasks.cfm)", () => {

            beforeEach(() => {
                resetWorkerSlots();
                variables.customerID = variables.fixtures.createCustomer();
                variables.moduleID = variables.fixtures.createModule("Worker");
                variables.taskID = variables.fixtures.createScheduletask(variables.moduleID);
            });

            afterEach(() => {
                resetWorkerSlots();
                // Jobs a test left due must not run in the next test
                queryExecute(
                    "DELETE scheduler_jobs FROM scheduler_jobs INNER JOIN scheduletasks ON scheduletasks.intScheduletaskID = scheduler_jobs.intScheduletaskID WHERE scheduletasks.intModuleID = :moduleID",
                    { moduleID: { type: "numeric", value: variables.moduleID } },
                    { datasource: application.datasource }
                );
            });

            it("runs a due job and hands customerID, moduleID and lastRun to the task", () => {
                var jobID = createJob(variables.taskID, variables.customerID, -5);

                var answer = runWorker("01");

                expect(answer.ran).toHaveLength(1);
                expect(answer.ran[1].customerID).toBe(variables.customerID);
                expect(answer.ran[1].moduleID).toBe(variables.moduleID);
                expect(answer.ran[1].lastRun).toBe("");

                var job = getJob(jobID);
                expect(job.dtmLastRun).toBeGT(dateAdd("n", -1, now()));
                expect(job.dtmNextRun).toBeGT(now());
                expect(job.strLockToken).toBe("");
                expect(job.dtmLockedUntil).toBe("");
            });

            it("hands the previous last run to the task", () => {
                var jobID = createJob(variables.taskID, variables.customerID, -5);
                queryExecute("UPDATE scheduler_jobs SET dtmLastRun = '2026-03-04 05:06:07' WHERE intJobID = :id", { id: { type: "numeric", value: jobID } }, { datasource: application.datasource });

                var answer = runWorker("01");

                expect(answer.ran[1].lastRun).toBe("2026-03-04 05:06:07");
            });

            it("runs the due jobs of several customers once each in one run", () => {
                var expected = [];
                for (var i = 1; i lte 5; i++) {
                    var customer = variables.fixtures.createCustomer();
                    createJob(variables.taskID, customer, -5);
                    arrayAppend(expected, customer);
                }

                var answer = runWorker("01");

                var ran = answer.ran.map((entry) => entry.customerID);
                ran.sort("numeric");
                expect(ran).toBe(expected);
            });

            it("lets any worker number take the jobs", () => {
                createJob(variables.taskID, variables.customerID, -5);

                expect(runWorker("13").ran).toHaveLength(1);
            });

            it("keeps the last run of a failed task, moves the next run and logs the error", () => {
                var failingTask = variables.fixtures.createScheduletask(variables.moduleID, true, "/tests/support/scheduler_task_fail.cfm");
                var jobID = createJob(failingTask, variables.customerID, -5);

                var answer = runWorker("01");

                var job = getJob(jobID);
                expect(job.dtmLastRun).toBe("");
                expect(job.dtmNextRun).toBeGT(now());
                expect(job.strLockToken).toBe("");
                expect(hasLog(answer, "error", "Probe task failed on purpose")).toBeTrue();
            });

            it("releases a job whose file does not exist and logs it", () => {
                var missingTask = variables.fixtures.createScheduletask(variables.moduleID, true, "/tests/support/testbox-missing-task.cfm");
                var jobID = createJob(missingTask, variables.customerID, -5);

                var answer = runWorker("01");

                var job = getJob(jobID);
                expect(job.dtmLastRun).toBe("");
                expect(job.strLockToken).toBe("");
                expect(hasLog(answer, "error", "File not found")).toBeTrue();
            });

            it("does not run a job that is not due or whose scheduletask is inactive", () => {
                createJob(variables.taskID, variables.customerID, 30);
                var inactiveTask = variables.fixtures.createScheduletask(variables.moduleID, false);
                createJob(inactiveTask, variables.customerID, -5);

                expect(runWorker("01").ran).toBeEmpty();
            });

            it("does nothing with a wrong password", () => {
                var jobID = createJob(variables.taskID, variables.customerID, -5);

                var answer = runWorker("01", "&wrongPass=1");

                expect(answer.ran).toBeEmpty();
                expect(getJob(jobID).dtmLastRun).toBe("");
                expect(hasLog(answer, "warning", "wrong password")).toBeTrue();
            });

            it("exits at once when the worker number is above scheduleWorkers", () => {
                var jobID = createJob(variables.taskID, variables.customerID, -5);

                runWorker("06", "&workers=5");

                var job = getJob(jobID);
                expect(job.dtmLastRun).toBe("");
                expect(job.dtmNextRun).toBeLT(now(), "The job must still be due");
            });

            it("does not start while the worker slot is held by another run", () => {
                var jobID = createJob(variables.taskID, variables.customerID, -5);
                setWorkerSlot("02", dateAdd("n", -1, now()));

                var answer = runWorker("02");

                expect(answer.ran).toBeEmpty();
                expect(getJob(jobID).dtmLastRun).toBe("");
                expect(hasLog(answer, "warning", "is still running")).toBeTrue();
            });

            it("takes over a slot whose lease expired and logs it", () => {
                createJob(variables.taskID, variables.customerID, -5);
                setWorkerSlot("02", dateAdd("n", -120, now()));

                var answer = runWorker("02");

                expect(answer.ran).toHaveLength(1);
                expect(hasLog(answer, "warning", "has been taken over")).toBeTrue();
            });

            it("releases its worker slot after the run", () => {
                runWorker("03");

                var slot = queryExecute("SELECT blnIsRunning, strRunToken FROM schedulecontrol WHERE strTaskName = 'task_03'", {}, { datasource: application.datasource });
                expect(slot.blnIsRunning).toBe(0);
                expect(slot.strRunToken).toBe("");
            });

            it("stops taking jobs once half of the lease is used up", () => {
                var jobID = createJob(variables.taskID, variables.customerID, -5);

                // Lease 0: the time budget is used up before the first job
                expect(runWorker("01", "&lease=0").ran).toBeEmpty();
                expect(getJob(jobID).dtmLastRun).toBe("");
            });

        });

    }

    private struct function runWorker(required string task, string extra = "") {
        cfhttp(url = variables.probeUrl & "?task=" & arguments.task & arguments.extra, method = "get", timeout = 60, result = "local.response");

        if (!len(trim(local.response.fileContent))) {
            // The worker aborted (worker limit) - there is no answer, only the database tells
            return { "ran": [], "logs": [] };
        }
        if (!isJSON(local.response.fileContent)) {
            fail("No JSON from the worker probe (" & local.response.statusCode & "): " & left(local.response.fileContent, 500));
        }
        return deserializeJSON(local.response.fileContent);
    }

    private boolean function hasLog(required struct answer, required string level, required string text) {
        return arrayLen(arguments.answer.logs.filter((entry) => entry.level eq level and findNoCase(text, entry.message))) gt 0;
    }

    private numeric function createJob(required numeric taskID, required numeric customerID, required numeric nextRunMinutes) {
        queryExecute(
            "INSERT INTO scheduler_jobs (intScheduletaskID, intCustomerID, dtmNextRun) VALUES (:taskID, :customerID, :nextRun)",
            {
                taskID: { type: "numeric", value: arguments.taskID },
                customerID: { type: "numeric", value: arguments.customerID },
                nextRun: { type: "datetime", value: dateAdd("n", arguments.nextRunMinutes, now()) }
            },
            { datasource: application.datasource, result: "local.result" }
        );
        return local.result.generatedKey;
    }

    private query function getJob(required numeric jobID) {
        return queryExecute("SELECT * FROM scheduler_jobs WHERE intJobID = :id", { id: { type: "numeric", value: arguments.jobID } }, { datasource: application.datasource });
    }

    private void function setWorkerSlot(required string task, required date startedAt) {
        queryExecute(
            "UPDATE schedulecontrol SET blnIsRunning = 1, strRunToken = 'testbox-other-run', dtmStart = :startedAt WHERE strTaskName = :taskName",
            { startedAt: { type: "datetime", value: arguments.startedAt }, taskName: { type: "varchar", value: "task_" & arguments.task } },
            { datasource: application.datasource }
        );
    }

    private void function resetWorkerSlots() {
        queryExecute("UPDATE schedulecontrol SET blnIsRunning = 0, strRunToken = NULL", {}, { datasource: application.datasource });
    }

}
