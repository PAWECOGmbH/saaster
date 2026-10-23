component displayname="scheduler" output="false" {

    /*
        Job queue of the module scheduletasks (table scheduler_jobs).

        frontend/core/scheduletasks/tasks.cfm runs as a worker: it claims the next due
        job, runs it, finishes it and takes the next one. Several workers run side by
        side (the Lucee tasks tasks.cfm?task=01..NN) and share the load by themselves:
        SELECT ... FOR UPDATE SKIP LOCKED hands every job to exactly one worker, and a
        worker never waits for a job another worker is holding.

        Which jobs exist is decided in modules.cfc (syncCustomerScheduler).
    */


    /*
        Claim the next due job. Returns an empty struct if there is none.

        The claim moves dtmNextRun to the next interval and locks the job with a token
        until lockedUntil. A job that is still running (or whose worker died) is not
        handed out again before the lock expires, even if its next interval has come.
    */
    public struct function claimNextJob(required numeric lockMinutes) {

        local.job = {};
        local.now = now();
        local.token = createUUID();

        transaction {

            local.qJob = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    utcDate: {type: "datetime", value: local.now}
                },
                sql = "
                    SELECT
                        scheduler_jobs.intJobID,
                        scheduler_jobs.intCustomerID,
                        scheduler_jobs.dtmNextRun,
                        scheduler_jobs.dtmLastRun,
                        scheduletasks.intScheduletaskID,
                        scheduletasks.strPath,
                        scheduletasks.intModuleID,
                        scheduletasks.intIterationMinutes,
                        scheduletasks.dtmStartTime
                    FROM scheduler_jobs
                    INNER JOIN scheduletasks
                    ON scheduler_jobs.intScheduletaskID = scheduletasks.intScheduletaskID
                    AND scheduletasks.blnActive = 1
                    WHERE (scheduler_jobs.dtmNextRun IS NULL OR scheduler_jobs.dtmNextRun < :utcDate)
                    AND (scheduler_jobs.dtmLockedUntil IS NULL OR scheduler_jobs.dtmLockedUntil < :utcDate)
                    ORDER BY scheduler_jobs.dtmNextRun
                    LIMIT 1
                    FOR UPDATE OF scheduler_jobs SKIP LOCKED
                "
            );

            if (local.qJob.recordCount) {

                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        jobID: {type: "numeric", value: local.qJob.intJobID},
                        token: {type: "varchar", value: local.token},
                        lockedUntil: {type: "datetime", value: dateAdd("n", arguments.lockMinutes, local.now)},
                        nextRun: {type: "datetime", value: application.objSysadmin.calcNextRun(local.qJob.dtmStartTime, local.qJob.intIterationMinutes)}
                    },
                    sql = "
                        UPDATE scheduler_jobs
                        SET strLockToken = :token,
                            dtmLockedUntil = :lockedUntil,
                            dtmNextRun = :nextRun
                        WHERE intJobID = :jobID
                    "
                );

                local.job = {
                    "jobID": local.qJob.intJobID,
                    "token": local.token,
                    "customerID": local.qJob.intCustomerID,
                    "moduleID": local.qJob.intModuleID,
                    "scheduletaskID": local.qJob.intScheduletaskID,
                    "path": local.qJob.strPath,
                    "lastRun": local.qJob.dtmLastRun,
                    "nextRun": local.qJob.dtmNextRun,
                    "startTime": local.qJob.dtmStartTime,
                    "iterationMinutes": local.qJob.intIterationMinutes
                };

            }

        }

        return local.job;

    }


    /*
        Finish a claimed job: write the last run (only after a successful run), the next
        run and the duration, and release the lock. Only the worker holding the token can
        do this - if the lock expired and another worker took the job meanwhile, nothing
        is written and false is returned.
    */
    public boolean function finishJob(required struct job, required boolean successful, required numeric elapsedSeconds) {

        local.lastRun = arguments.successful ? now() : arguments.job.lastRun;

        queryExecute(
            options = {datasource = application.datasource, result = "local.finishResult"},
            params = {
                jobID: {type: "numeric", value: arguments.job.jobID},
                token: {type: "varchar", value: arguments.job.token},
                lastRun: {type: "datetime", value: local.lastRun, null: !isDate(local.lastRun)},
                nextRun: {type: "datetime", value: application.objSysadmin.calcNextRun(arguments.job.startTime, arguments.job.iterationMinutes)},
                elapsedSeconds: {type: "numeric", value: min(max(arguments.elapsedSeconds, 0), 32767)}
            },
            sql = "
                UPDATE scheduler_jobs
                SET dtmLastRun = :lastRun,
                    dtmNextRun = :nextRun,
                    intDuringSeconds = :elapsedSeconds,
                    strLockToken = NULL,
                    dtmLockedUntil = NULL
                WHERE intJobID = :jobID
                AND strLockToken = :token
            "
        );

        return local.finishResult.recordCount eq 1;

    }

}
