
<cfscript>

// This file gets executed from the scheduler every 2 minutes, once per shard (task=01..20).
//
// Flow of one shard run:
//   1. Claim the shard in schedulecontrol with a unique run token (lease).
//   2. Select all due rows of the shard table scheduler_NN.
//   3. For every row: claim the row (advance dtmNextRun), include the task file,
//      then write the final dtmLastRun / dtmNextRun / intDuringSeconds.
//   4. Release the shard, but only if this run still owns the lease.
//
// Lucee cannot reliably stop a request that runs into the request timeout, so a
// shard run may outlive its lease as a zombie. The lease plus the per-row claim
// make sure that a takeover never executes the same row twice and that a zombie
// cannot release the shard of the run that replaced it.

objLogs = application.objLog;
objTime = new backend.core.com.time(1);

// Minutes a run may hold a shard before another run is allowed to take it over.
// Must be longer than the longest legitimate shard run. Configurable in config.cfm.
param name="variables.scheduleLeaseMinutes" default=60;

param name="url.task" default="01";
if (!isNumeric(url.task) or val(url.task) lt 1 or val(url.task) gt 20) {
    // Make log
    objLogs.logWrite("scheduletask", "warning", "Invalid url.task value: #url.task#");
    abort;
}
url.task = numberFormat(val(url.task), "00");
taskTable = "scheduler_" & url.task;

// Security (password from config.cfm)
param name="url.pass" default="";
if (url.pass eq variables.schedulePassword) {

    // Claim the shard
    shardClaim = application.objSysadmin.claimScheduleControl(url.task, variables.scheduleLeaseMinutes);

    if (shardClaim.claimed) {

        runToken = shardClaim.runToken;
        shardStartTickCount = getTickCount();

        if (shardClaim.takenOver) {

            // The previous run held the shard longer than the lease. It was either killed or is still
            // running as a zombie. Make log and send an email, the per-row claim protects against double execution.
            staleMinutes = isDate(shardClaim.staleSince) ? dateDiff("n", shardClaim.staleSince, now()) : "unknown";
            objLogs.logWrite("scheduletask", "warning", "The scheduler #url.task# held its lease for #staleMinutes# minutes (lease: #variables.scheduleLeaseMinutes# minutes). The lease has been taken over by a new run.", true);

        }

        // Get all tasks that have to be executed
        qGetTasks = queryExecute(
            options = {datasource = application.datasource},
            params = {
                utcDate: {type: "datetime", value: now()}
            },
            sql = "
                SELECT
                    #taskTable#.intSchedulerID,
                    #taskTable#.intCustomerID,
                    #taskTable#.dtmNextRun,
                    #taskTable#.dtmLastRun,
                    scheduletasks.strPath,
                    scheduletasks.intModuleID,
                    scheduletasks.intIterationMinutes,
                    scheduletasks.dtmStartTime
                FROM #taskTable#
                INNER JOIN scheduletasks
                ON #taskTable#.intScheduletaskID = scheduletasks.intScheduletaskID
                AND scheduletasks.blnActive = 1
                AND #taskTable#.dtmNextRun < :utcDate
                ORDER BY #taskTable#.dtmNextRun
            "
        )

        if (qGetTasks.recordCount) {

            // Start time for log entries, based on dtmNextRun
            baseTime = objTime.utc2local(qGetTasks.dtmNextRun);

            // Make loop over all the tasks
            loop query="qGetTasks" {

                if (!len(trim(qGetTasks.strPath))) {

                    // Make log
                    objLogs.logWrite("scheduletask", "warning", "Empty path in schedule task. The schedule task has been deactivated [ModuleID: #qGetTasks.intModuleID#]", false);
                    continue;

                }

                // Variables may be needed in the included file
                customerID = qGetTasks.intCustomerID;
                moduleID = qGetTasks.intModuleID;
                lastRun = qGetTasks.dtmLastRun;

                // Reset per task, so a failed task never reports the duration of the previous one
                elapsedSeconds = 0;
                currentTime = now();
                lastRunSuccessful = true;

                // Claim the row: advance dtmNextRun to the next interval BEFORE the task runs.
                // The WHERE on the value we read makes this an optimistic lock. If another run
                // (e.g. a zombie of the previous lease) already claimed the row, skip it.
                // Should this run die inside the task, the row simply becomes due again at the next interval.
                provisionalNextRun = application.objSysadmin.calcNextRun(qGetTasks.dtmStartTime, qGetTasks.intIterationMinutes);
                queryExecute(
                    options = {datasource = application.datasource, result = "rowClaim"},
                    params = {
                        scheduleID: {type: "numeric", value: qGetTasks.intSchedulerID},
                        readNextRun: {type: "datetime", value: qGetTasks.dtmNextRun},
                        nextRun: {type: "datetime", value: provisionalNextRun}
                    },
                    sql = "
                        UPDATE #taskTable#
                        SET dtmNextRun = :nextRun
                        WHERE intSchedulerID = :scheduleID
                        AND dtmNextRun = :readNextRun
                    "
                )

                if (rowClaim.recordCount neq 1) {

                    // Make log
                    objLogs.logWrite("scheduletask", "info", "Schedule task skipped, it was already claimed by another run of scheduler #url.task# [File: #qGetTasks.strPath#, CustomerID: #customerID#]");
                    continue;

                }

                // Include the file
                if (fileExists(expandPath("\#qGetTasks.strPath#"))) {

                    // Add the start tick count at the beginning of the task
                    startTickCount = getTickCount();

                    try {

                        // Include the given file
                        include template="\#qGetTasks.strPath#";

                    } catch(any e) {

                        lastRunSuccessful = false;

                        // Make log
                        objLogs.logWrite("scheduletask", "error", "Something went wrong in schedule task [File: #qGetTasks.strPath#, CustomerID: #customerID#, Error: #e.message#]", false);

                        // Send email to the developer with the error dump
                        cfmail(subject="Error in included scheduletask file", to="#application.errorMail#", from="#application.fromEmail#" type="html" ) {
                            dump(e);
                        }

                    }

                    // Calculate the elapsed milliseconds since the task was started
                    elapsedMilliseconds = getTickCount() - startTickCount;

                    // Conversion to seconds
                    elapsedSeconds = round(elapsedMilliseconds / 1000);

                    // Adjust current time
                    currentTime = dateAdd("s", elapsedSeconds, baseTime);

                    // A task that runs longer than its own interval is the reason for overrunning shards. Make log.
                    if (qGetTasks.intIterationMinutes gt 0 and elapsedSeconds gt qGetTasks.intIterationMinutes * 60) {
                        objLogs.logWrite("scheduletask", "warning", "Schedule task ran longer than its interval [File: #qGetTasks.strPath#, CustomerID: #customerID#, Duration: #elapsedSeconds# s, Interval: #qGetTasks.intIterationMinutes# min]", false);
                    }

                } else {

                    lastRunSuccessful = false;

                    // Make log
                    objLogs.logWrite("scheduletask", "error", "File not found, the schedule task has been deactivated [File: #qGetTasks.strPath#]", true);

                }

                // Only update the lastRun if the task was successful
                if (lastRunSuccessful) {
                    lastRun = now();
                }

                // Calculate the final next run. After a long task this skips the intervals that were missed
                // while the task was running, instead of running the task again immediately.
                nextRun = application.objSysadmin.calcNextRun(qGetTasks.dtmStartTime, qGetTasks.intIterationMinutes);

                // Update scheduler (intDuringSeconds is a smallint)
                sql_type_utcDate = isDate(lastRun) ? "datetime" : "null";
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        scheduleID: {type: "numeric", value: qGetTasks.intSchedulerID},
                        utcDate: {type: sql_type_utcDate, value: lastRun},
                        nextRun: {type: "datetime", value: nextRun},
                        elapsedSeconds: {type: "numeric", value: min(elapsedSeconds, 32767)}
                    },
                    sql = "
                        UPDATE #taskTable#
                        SET dtmLastRun = :utcDate,
                            dtmNextRun = :nextRun,
                            intDuringSeconds = :elapsedSeconds
                        WHERE intSchedulerID = :scheduleID
                    "
                )

            }

        }

        // Release the shard, only if this run still owns the lease
        released = application.objSysadmin.releaseScheduleControl(url.task, runToken);

        if (!released) {

            // Make log
            shardElapsedSeconds = round((getTickCount() - shardStartTickCount) / 1000);
            objLogs.logWrite("scheduletask", "warning", "The scheduler #url.task# finished after #shardElapsedSeconds# s but had lost its lease to a newer run. The shard has not been released by this run.", false);

        }

    } else {

        // The shard is held by another run that is still within its lease. Do not start again.
        objLogs.logWrite("scheduletask", "warning", "The scheduler #url.task# is still running. The scheduler has not been started again.");

    }

} else {

    // Make log
    objLogs.logWrite("scheduletask", "warning", "Someone tried to call the scheduler (task_#url.task#.cfm) manually with wrong password. Password was: #url.pass#");

}


</cfscript>
