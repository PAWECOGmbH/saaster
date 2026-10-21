<cfscript>

// Worker for the module scheduletasks. Lucee calls this file every 2 minutes, once per
// worker (task=01..20 - the same URLs as before the job table).
//
// Flow of one worker run:
//   1. Claim the worker slot in schedulecontrol with a unique run token (lease). This
//      limits the scheduler to one run per worker, however long the jobs take.
//   2. Claim the next due job in scheduler_jobs (scheduler.cfc::claimNextJob). The
//      workers share one table; SKIP LOCKED gives every job to exactly one worker.
//   3. Include the task file, finish the job, take the next one - until no job is due
//      or the run reaches half of its lease.
//   4. Release the worker slot, but only if this run still owns the lease.
//
// Lucee cannot reliably stop a request that runs into the request timeout, so a run
// may outlive its lease as a zombie. The lease plus the job lock make sure that a
// takeover never runs the same job twice and that a zombie cannot release the slot
// of the run that replaced it.

objLogs = application.objLog;
objScheduler = new backend.core.com.scheduler();

// Minutes a run may hold its worker slot before another run is allowed to take it over.
// Must be longer than the longest legitimate job. Configurable in config.cfm.
param name="variables.scheduleLeaseMinutes" default=60;

// Number of workers that take jobs. Calls with a higher task number exit at once, so the
// Lucee tasks do not have to be removed when the number is lowered. Configurable in config.cfm.
param name="variables.scheduleWorkers" default=20;

param name="url.task" default="01";
if (!isNumeric(url.task) or val(url.task) lt 1 or val(url.task) gt 20) {
    // Make log
    objLogs.logWrite("scheduletask", "warning", "Invalid url.task value: #url.task#");
    abort;
}
url.task = numberFormat(val(url.task), "00");

// Security (password from config.cfm)
param name="url.pass" default="";
if (url.pass eq variables.schedulePassword) {

    if (val(url.task) gt val(variables.scheduleWorkers)) {
        abort;
    }

    // Claim the worker slot
    workerClaim = application.objSysadmin.claimScheduleControl(url.task, variables.scheduleLeaseMinutes);

    if (workerClaim.claimed) {

        runToken = workerClaim.runToken;
        workerStartTickCount = getTickCount();

        if (workerClaim.takenOver) {

            // The previous run held the slot longer than the lease. It was either killed or is still
            // running as a zombie. Make log and send an email, the job lock protects against double execution.
            staleMinutes = isDate(workerClaim.staleSince) ? dateDiff("n", workerClaim.staleSince, now()) : "unknown";
            objLogs.logWrite("scheduletask", "warning", "The scheduler #url.task# held its lease for #staleMinutes# minutes (lease: #variables.scheduleLeaseMinutes# minutes). The lease has been taken over by a new run.", true);

        }

        // Stop taking new jobs after half of the lease, so a run never outlives its lease by taking more work
        claimUntilTickCount = workerStartTickCount + (variables.scheduleLeaseMinutes * 60000 / 2);

        while (getTickCount() lt claimUntilTickCount) {

            job = objScheduler.claimNextJob(variables.scheduleLeaseMinutes);

            if (structIsEmpty(job)) {
                break;
            }

            // Variables may be needed in the included file
            customerID = job.customerID;
            moduleID = job.moduleID;
            lastRun = job.lastRun;

            // Reset per job, so a failed job never reports the duration of the previous one
            elapsedSeconds = 0;
            lastRunSuccessful = true;

            if (!len(trim(job.path))) {

                lastRunSuccessful = false;

                // Make log
                objLogs.logWrite("scheduletask", "warning", "Empty path in schedule task [ModuleID: #job.moduleID#, ScheduletaskID: #job.scheduletaskID#]", false);

            } else if (fileExists(expandPath("\#job.path#"))) {

                // Add the start tick count at the beginning of the task
                startTickCount = getTickCount();

                try {

                    // Include the given file
                    include template="\#job.path#";

                } catch(any e) {

                    lastRunSuccessful = false;

                    // Make log
                    objLogs.logWrite("scheduletask", "error", "Something went wrong in schedule task [File: #job.path#, CustomerID: #job.customerID#, Error: #e.message#]", false);

                    // Send email to the developer with the error dump
                    cfmail(subject="Error in included scheduletask file", to="#application.errorMail#", from="#application.fromEmail#" type="html" ) {
                        dump(e);
                    }

                }

                // Duration in seconds
                elapsedSeconds = round((getTickCount() - startTickCount) / 1000);

                // A task that runs longer than its own interval holds a worker for too long. Make log.
                if (job.iterationMinutes gt 0 and elapsedSeconds gt job.iterationMinutes * 60) {
                    objLogs.logWrite("scheduletask", "warning", "Schedule task ran longer than its interval [File: #job.path#, CustomerID: #job.customerID#, Duration: #elapsedSeconds# s, Interval: #job.iterationMinutes# min]", false);
                }

            } else {

                lastRunSuccessful = false;

                // Make log
                objLogs.logWrite("scheduletask", "error", "File not found [File: #job.path#, ScheduletaskID: #job.scheduletaskID#]", true);

            }

            // Write last run, next run and duration, release the job
            if (!objScheduler.finishJob(job, lastRunSuccessful, elapsedSeconds)) {

                // Make log
                objLogs.logWrite("scheduletask", "warning", "Schedule task finished after its lock expired, another run took it over [File: #job.path#, CustomerID: #job.customerID#, Duration: #elapsedSeconds# s]", false);

            }

        }

        // Release the worker slot, only if this run still owns the lease
        released = application.objSysadmin.releaseScheduleControl(url.task, runToken);

        if (!released) {

            // Make log
            workerElapsedSeconds = round((getTickCount() - workerStartTickCount) / 1000);
            objLogs.logWrite("scheduletask", "warning", "The scheduler #url.task# finished after #workerElapsedSeconds# s but had lost its lease to a newer run. The slot has not been released by this run.", false);

        }

    } else {

        // The slot is held by another run that is still within its lease. Do not start again.
        objLogs.logWrite("scheduletask", "warning", "The scheduler #url.task# is still running. The scheduler has not been started again.");

    }

} else {

    // Make log
    objLogs.logWrite("scheduletask", "warning", "Someone tried to call the scheduler (task_#url.task#.cfm) manually with wrong password. Password was: #url.pass#");

}

</cfscript>
