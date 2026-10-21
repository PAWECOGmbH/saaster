component extends="tests.support.integration_spec" {

    /*
        Scheduler jobs - issue #655 and the job table (migration V23).

        modules.cfc decides which jobs exist (reconciliation against the bookings),
        scheduler.cfc hands them to the workers (tasks.cfm).

        Regressions of the shard tables:
          1. A waiting booking (cycle change) removed the customer from all tables,
             although the current booking kept running.
          2. Canceling stopped the tasks at once, the access lasts until the end date.
          3. Modules included in a plan were never repaired, and the modules of an old
             plan were never removed after a plan change.
          4. The update of an existing entry hit the wrong table.
          5. getModuleStatus took the "first" booking without ORDER BY - a waiting
             booking could become the current one.
    */

    function run() {

        var modules = new backend.core.com.modules();
        var scheduler = new backend.core.com.scheduler();

        describe("Scheduler", () => {

            beforeEach(() => {
                variables.created = { modules: [], planGroups: [] };
                variables.today = dateFormat(now(), "yyyy-mm-dd");

                variables.customerID = variables.fixtures.createCustomer();
                variables.moduleA = createModule("A");
                variables.moduleB = createModule("B");
                variables.taskA = createTask(variables.moduleA);
                variables.taskB = createTask(variables.moduleB);
            });

            afterEach(() => {
                // Bookings, jobs and scheduletasks go with the modules and plans (ON DELETE CASCADE)
                for (var moduleID in variables.created.modules) {
                    queryExecute("DELETE FROM modules WHERE intModuleID = :id", { id: { type: "numeric", value: moduleID } }, { datasource: application.datasource });
                }
                for (var groupID in variables.created.planGroups) {
                    queryExecute("DELETE FROM plan_groups WHERE intPlanGroupID = :id", { id: { type: "numeric", value: groupID } }, { datasource: application.datasource });
                }
            });

            describe("Which jobs a customer gets", () => {

                it("adds the jobs of a module booked for today", () => {
                    bookModule(variables.moduleA, "active", -10, 20);

                    modules.syncCustomerScheduler(variables.customerID);

                    expect(jobTasks()).toBe([variables.taskA]);
                });

                it("adds the jobs of a free module without dates", () => {
                    bookModule(variables.moduleA, "free", "", "");

                    modules.syncCustomerScheduler(variables.customerID);

                    expect(jobTasks()).toBe([variables.taskA]);
                });

                it("keeps the jobs when a waiting booking for the next period is added (##655-1)", () => {
                    bookModule(variables.moduleA, "active", -10, 20);
                    modules.syncCustomerScheduler(variables.customerID);

                    bookModule(variables.moduleA, "waiting", 21, 385);
                    modules.distributeScheduler(moduleID = variables.moduleA, customerID = variables.customerID, status = "waiting");

                    expect(jobTasks()).toBe([variables.taskA]);
                });

                it("keeps the jobs of a canceled module until its end date (##655-2)", () => {
                    var bookingID = bookModule(variables.moduleA, "active", -10, 20);
                    modules.syncCustomerScheduler(variables.customerID);

                    setBooking(bookingID, "canceled", -10, 20);
                    modules.distributeScheduler(moduleID = variables.moduleA, customerID = variables.customerID, status = "canceled");
                    expect(jobTasks()).toBe([variables.taskA], "Stopped at once although the module is usable until its end date");

                    setBooking(bookingID, "canceled", -40, -1);
                    modules.syncCustomerScheduler(variables.customerID);
                    expect(jobTasks()).toBeEmpty("Still running after the end date");
                });

                it("removes the jobs of an expired booking", () => {
                    var bookingID = bookModule(variables.moduleA, "active", -10, 20);
                    modules.syncCustomerScheduler(variables.customerID);

                    setBooking(bookingID, "expired", -40, -1);
                    modules.syncCustomerScheduler(variables.customerID);

                    expect(jobTasks()).toBeEmpty();
                });

                it("does not start the jobs of a booking that begins later", () => {
                    bookModule(variables.moduleA, "active", 5, 35);

                    modules.syncCustomerScheduler(variables.customerID);

                    expect(jobTasks()).toBeEmpty();
                });

                it("adds the jobs of the modules included in the booked plan (##655-3)", () => {
                    var planID = createPlan([variables.moduleA, variables.moduleB]);
                    bookPlan(planID, "active", -10, 20);

                    modules.syncCustomerScheduler(variables.customerID);

                    expect(jobTasks()).toBe([variables.taskA, variables.taskB]);
                });

                it("removes the jobs of modules the new plan does not include (##655-3)", () => {
                    var oldPlan = createPlan([variables.moduleA, variables.moduleB]);
                    var newPlan = createPlan([variables.moduleB]);
                    var bookingID = bookPlan(oldPlan, "active", -10, 20);
                    modules.syncCustomerScheduler(variables.customerID);

                    // Plan change: the booking now points to the new plan
                    queryExecute("UPDATE bookings SET intPlanID = :planID WHERE intBookingID = :id", { planID: { type: "numeric", value: newPlan }, id: { type: "numeric", value: bookingID } }, { datasource: application.datasource });
                    modules.distributeScheduler(moduleID = variables.moduleB, customerID = variables.customerID, status = "active");

                    expect(jobTasks()).toBe([variables.taskB]);
                });

                it("keeps next and last run when it reconciles again, and never duplicates a job (##655-4)", () => {
                    bookModule(variables.moduleA, "active", -10, 20);
                    modules.syncCustomerScheduler(variables.customerID);
                    queryExecute(
                        "UPDATE scheduler_jobs SET dtmNextRun = '2030-01-01 10:00:00', dtmLastRun = '2026-01-01 10:00:00' WHERE intCustomerID = :customerID",
                        { customerID: { type: "numeric", value: variables.customerID } },
                        { datasource: application.datasource }
                    );

                    var second = modules.syncCustomerScheduler(variables.customerID);
                    modules.syncCustomerScheduler(variables.customerID);

                    var job = jobs();
                    expect(job.recordCount).toBe(1);
                    expect(dateTimeFormat(job.dtmNextRun, "yyyy-mm-dd HH:nn")).toBe("2030-01-01 10:00");
                    expect(dateTimeFormat(job.dtmLastRun, "yyyy-mm-dd HH:nn")).toBe("2026-01-01 10:00");
                    expect(second.added + second.removed).toBe(0);
                });

                it("repairs missing and left-over jobs of all customers", () => {
                    bookModule(variables.moduleA, "active", -10, 20);
                    var otherCustomer = variables.fixtures.createCustomer();
                    // A left-over job: the other customer has no booking at all
                    queryExecute(
                        "INSERT INTO scheduler_jobs (intScheduletaskID, intCustomerID, dtmNextRun) VALUES (:taskID, :customerID, NOW())",
                        { taskID: { type: "numeric", value: variables.taskB }, customerID: { type: "numeric", value: otherCustomer } },
                        { datasource: application.datasource }
                    );

                    modules.syncAllSchedulers();

                    expect(jobTasks()).toBe([variables.taskA]);
                    expect(jobTasks(otherCustomer)).toBeEmpty();
                });

                it("answers shouldRunScheduler with the same rule", () => {
                    bookModule(variables.moduleA, "active", -10, 20);

                    expect(modules.shouldRunScheduler(variables.customerID, variables.moduleA)).toBeTrue();
                    expect(modules.shouldRunScheduler(variables.customerID, variables.moduleB)).toBeFalse();
                });

                it("recalculates the next runs when a scheduletask was edited", () => {
                    bookModule(variables.moduleA, "active", -10, 20);
                    modules.syncCustomerScheduler(variables.customerID);
                    queryExecute("UPDATE scheduler_jobs SET dtmNextRun = '2030-01-01 10:00:00' WHERE intCustomerID = :customerID", { customerID: { type: "numeric", value: variables.customerID } }, { datasource: application.datasource });

                    modules.distributeScheduler(moduleID = variables.moduleA, customerID = 0, status = "active");

                    expect(jobs().dtmNextRun).toBeLT(createDateTime(2030, 1, 1, 0, 0, 0));
                });

            });

            describe("getModuleStatus", () => {

                it("takes the current booking, not a waiting one entered earlier (##655-5)", () => {
                    bookModule(variables.moduleA, "waiting", 21, 385);
                    bookModule(variables.moduleA, "active", -10, 20);

                    var status = modules.getModuleStatus(variables.customerID, variables.moduleA);

                    expect(status.status).toBe("active");
                    expect(status.nextModule.status).toBe("waiting");
                });

            });

            describe("Workers (scheduler.cfc)", () => {

                it("claim a due job, move its next run forward and lock it", () => {
                    var jobID = createJob(variables.taskA, -5);

                    var job = claimOwn();

                    expect(job.jobID ?: 0).toBe(jobID);
                    var row = jobs();
                    expect(row.dtmNextRun).toBeGT(now());
                    expect(row.strLockToken).toBe(job.token);
                    expect(row.dtmLockedUntil).toBeGT(now());
                });

                it("do not claim a job that is not due, locked, or whose scheduletask is inactive", () => {
                    createJob(variables.taskA, 30);
                    var lockedJob = createJob(variables.taskB, -5);
                    queryExecute("UPDATE scheduler_jobs SET dtmLockedUntil = DATE_ADD(NOW(), INTERVAL 30 MINUTE) WHERE intJobID = :id", { id: { type: "numeric", value: lockedJob } }, { datasource: application.datasource });

                    var otherCustomer = variables.fixtures.createCustomer();
                    var inactiveTask = createTask(variables.moduleA, false);
                    createJob(inactiveTask, -5, otherCustomer);

                    expect(claimOwn()).toBeEmpty();
                });

                it("finish a job: write the last run and the duration, release the lock", () => {
                    createJob(variables.taskA, -5);
                    var job = claimOwn();

                    expect(scheduler.finishJob(job, true, 12)).toBeTrue();

                    var row = jobs();
                    expect(row.dtmLastRun).toBeGT(dateAdd("n", -1, now()));
                    expect(row.intDuringSeconds).toBe(12);
                    expect(row.strLockToken).toBe("");
                    expect(row.dtmLockedUntil).toBe("");
                });

                it("keep the last run of a failed job", () => {
                    createJob(variables.taskA, -5);
                    var job = claimOwn();

                    scheduler.finishJob(job, false, 3);

                    expect(jobs().dtmLastRun).toBe("");
                });

                it("do not finish a job another run has taken over", () => {
                    createJob(variables.taskA, -5);
                    var job = claimOwn();
                    queryExecute("UPDATE scheduler_jobs SET strLockToken = 'someone-else' WHERE intJobID = :id", { id: { type: "numeric", value: job.jobID } }, { datasource: application.datasource });

                    expect(scheduler.finishJob(job, true, 1)).toBeFalse();
                    expect(jobs().strLockToken).toBe("someone-else");
                });

                it("never hand the same job to two parallel workers", () => {
                    var expected = [];
                    for (var i = 1; i lte 12; i++) {
                        var customer = variables.fixtures.createCustomer();
                        arrayAppend(expected, createJob(variables.taskA, -5, customer));
                    }

                    // Four workers at the same time (parallel each runs every closure in its own thread)
                    var perWorker = [[], [], [], []];
                    [1, 2, 3, 4].each((worker) => {
                        var workerScheduler = new backend.core.com.scheduler();
                        var claimedJob = workerScheduler.claimNextJob(5);
                        while (!structIsEmpty(claimedJob)) {
                            arrayAppend(perWorker[worker], claimedJob.jobID);
                            claimedJob = workerScheduler.claimNextJob(5);
                        }
                    }, true, 4);

                    var claimed = [];
                    for (var list in perWorker) {
                        claimed.append(list, true);
                    }
                    claimed.sort("numeric");
                    expected.sort("numeric");
                    expect(claimed).toBe(expected, "Every job exactly once");
                });

            });

        });

    }

    private numeric function createModule(required string name) {
        queryExecute(
            "INSERT INTO modules (strModuleName, blnActive, blnBookable, intNumTestDays, intPrio) VALUES (:name, 1, 1, 0, 999)",
            { name: { type: "varchar", value: "TestBox Scheduler Module " & arguments.name } },
            { datasource: application.datasource, result: "local.result" }
        );
        arrayAppend(variables.created.modules, local.result.generatedKey);
        return local.result.generatedKey;
    }

    private numeric function createTask(required numeric moduleID, boolean active = true) {
        queryExecute(
            "INSERT INTO scheduletasks (strName, intModuleID, dtmStartTime, strPath, intIterationMinutes, blnActive) VALUES ('TestBox Task', :moduleID, '2026-01-01 00:00:00', '/tests/testbox-task.cfm', 5, :active)",
            { moduleID: { type: "numeric", value: arguments.moduleID }, active: { type: "bit", value: arguments.active } },
            { datasource: application.datasource, result: "local.result" }
        );
        return local.result.generatedKey;
    }

    private numeric function createPlan(required array moduleIDs) {
        queryExecute(
            "INSERT INTO plan_groups (strGroupName, intPrio) VALUES ('TestBox Scheduler Group', 999)",
            {},
            { datasource: application.datasource, result: "local.group" }
        );
        arrayAppend(variables.created.planGroups, local.group.generatedKey);

        queryExecute(
            "INSERT INTO plans (intPlanGroupID, strPlanName, intPrio) VALUES (:groupID, 'TestBox Scheduler Plan', 999)",
            { groupID: { type: "numeric", value: local.group.generatedKey } },
            { datasource: application.datasource, result: "local.plan" }
        );

        for (var moduleID in arguments.moduleIDs) {
            queryExecute(
                "INSERT INTO plans_modules (intPlanID, intModuleID) VALUES (:planID, :moduleID)",
                { planID: { type: "numeric", value: local.plan.generatedKey }, moduleID: { type: "numeric", value: moduleID } },
                { datasource: application.datasource }
            );
        }
        return local.plan.generatedKey;
    }

    // Start and end as day offsets from today, or "" for no date
    private numeric function bookModule(required numeric moduleID, required string status, required any startOffset, required any endOffset) {
        return variables.fixtures.createBooking(
            customerID = variables.customerID,
            moduleID = arguments.moduleID,
            startDate = dayFromToday(arguments.startOffset),
            endDate = dayFromToday(arguments.endOffset),
            status = arguments.status
        );
    }

    private numeric function bookPlan(required numeric planID, required string status, required any startOffset, required any endOffset) {
        return variables.fixtures.createBooking(
            customerID = variables.customerID,
            planID = arguments.planID,
            startDate = dayFromToday(arguments.startOffset),
            endDate = dayFromToday(arguments.endOffset),
            status = arguments.status
        );
    }

    private void function setBooking(required numeric bookingID, required string status, required numeric startOffset, required numeric endOffset) {
        queryExecute(
            "UPDATE bookings SET strStatus = :status, dteStartDate = :startDate, dteEndDate = :endDate WHERE intBookingID = :id",
            {
                status: { type: "varchar", value: arguments.status },
                startDate: { type: "date", value: dayFromToday(arguments.startOffset) },
                endDate: { type: "date", value: dayFromToday(arguments.endOffset) },
                id: { type: "numeric", value: arguments.bookingID }
            },
            { datasource: application.datasource }
        );
    }

    private string function dayFromToday(required any offset) {
        return isNumeric(arguments.offset) ? dateFormat(dateAdd("d", arguments.offset, now()), "yyyy-mm-dd") : "";
    }

    // A job with its next run in minutes from now (negative = due)
    private numeric function createJob(required numeric taskID, required numeric nextRunMinutes, numeric customerID = variables.customerID) {
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

    // Claims the next due job; the test database holds only the jobs of this spec
    private struct function claimOwn() {
        return new backend.core.com.scheduler().claimNextJob(5);
    }

    private query function jobs(numeric customerID = variables.customerID) {
        return queryExecute(
            "SELECT * FROM scheduler_jobs WHERE intCustomerID = :customerID ORDER BY intScheduletaskID",
            { customerID: { type: "numeric", value: arguments.customerID } },
            { datasource: application.datasource }
        );
    }

    private array function jobTasks(numeric customerID = variables.customerID) {
        return listToArray(valueList(jobs(arguments.customerID).intScheduletaskID)).map((id) => val(id));
    }

}
