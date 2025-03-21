
<cfscript>

// This file gets executed from the scheduler every 2 minutes

objLogs = application.objLog;
objTime = new backend.core.com.time(1);

param name="url.task" default="01";
if (!isNumeric(url.task)) {
    // Make log
    objLogs.logWrite("scheduletask", "warning", "Invalid url.task value: #url.task#");
    abort;
}

// Security (password from config.cfm)
param name="url.pass" default="";
if (url.pass eq variables.schedulePassword) {

    qRunning = queryExecute(
        options = {datasource = application.datasource},
        params = {
            taskName: {type: "string", value: "task_" & url.task}
        },
        sql = "
            SELECT dtmStart, dtmEnd, blnIsRunning
            FROM schedulecontrol
            WHERE strTaskName = :taskName
        "
    )

    if (qRunning.recordCount) {

        // Check if the scheduler is running
        if (qRunning.blnIsRunning eq 0) {

            // Update schedulecontrol
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    utcDate: {type: "datetime", value: now()},
                    taskName: {type: "string", value: "task_" & url.task}
                },
                sql = "
                    UPDATE schedulecontrol
                    SET dtmStart = :utcDate,
                        blnIsRunning = 1
                    WHERE strTaskName = :taskName
                "
            )

            // Get all tasks that have to be executed
            taskTable = "scheduler_" & urlEncodedFormat(url.task);
            qGetTasks = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    utcDate: {type: "datetime", value: now()}
                },
                sql = "
                    SELECT
                        #taskTable#.intScheduletaskID,
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

                    if (len(trim(qGetTasks.strPath))) {

                        // Variables may be needed in the included file
                        customerID = qGetTasks.intCustomerID;
                        moduleID = qGetTasks.intModuleID;
                        lastRun = qGetTasks.dtmLastRun;

                        param name="elapsedSeconds" default=0;
                        param name="currentTime" default=now();
                        lastRunSuccessful = true;

                        // Include the file
                        if (fileExists(expandPath("\#qGetTasks.strPath#"))) {

                            try {

                                // Add the start tick count at the beginning of the task
                                startTickCount = getTickCount();

                                // Include the given file
                                include template="\#qGetTasks.strPath#";

                                // Calculate the elapsed milliseconds since the task was started
                                elapsedMilliseconds = getTickCount() - startTickCount;

                                // Conversion to seconds
                                elapsedSeconds = round(elapsedMilliseconds / 1000);

                                // Adjust current time
                                currentTime = dateAdd("s", elapsedSeconds, baseTime);


                            }  catch(any e) {

                                lastRunSuccessful = false;

                                // Stop schedulecontrol
                                application.objSysadmin.stopScheduleControl(url.task);

                                // Deactivate the schedule task
                                application.objSysadmin.deactivateTask(qGetTasks.intScheduletaskID);

                                // Make log
                                objLogs.logWrite("scheduletask", "error", "Something went wrong in schedule task, the task has been deactivated [File: #qGetTasks.strPath#, Error: #e.message#]", false);

                                // Send email to the developer with the error dump
                                cfmail(subject="Error in included scheduletask file", to="#application.errorMail#", from="#application.fromEmail#" type="html" ) {
                                    dump(e);
                                }

                            }


                        } else {

                            lastRunSuccessful = false;

                            // Decativate the schedule task
                            application.objSysadmin.deactivateTask(qGetTasks.intScheduletaskID);

                            // Make log
                            objLogs.logWrite("scheduletask", "error", "File not found, the schedule task has been deactivated [File: #qGetTasks.strPath#]", true);

                        }

                        // Only update the lastRun if the task was successful
                        if (lastRunSuccessful) {
                            lastRun = now();
                        }

                        // Calculate next run
                        nextRun = application.objSysadmin.calcNextRun(qGetTasks.dtmStartTime, qGetTasks.intIterationMinutes);

                        // Update scheduler
                        sql_type_utcDate = isDate(lastRun) ? "datetime" : "null";
                        queryExecute(
                            options = {datasource = application.datasource},
                            params = {
                                scheduleID: {type: "numeric", value: qGetTasks.intScheduletaskID},
                                utcDate: {type: sql_type_utcDate, value: lastRun},
                                nextRun: {type: "datetime", value: nextRun},
                                elapsedSeconds: {type: "numeric", value: elapsedSeconds}
                            },
                            sql = "
                                UPDATE #taskTable#
                                SET dtmLastRun = :utcDate,
                                    dtmNextRun = :nextRun,
                                    intDuringSeconds = :elapsedSeconds
                                WHERE intScheduleTaskID = :scheduleID
                            "
                        )


                    } else {

                        // Decativate the schedule task
                        application.objSysadmin.deactivateTask(qGetTasks.intScheduletaskID);

                        // Make log
                        objLogs.logWrite("scheduletask", "warning", "Empty path in schedule task. The schedule task has been deactivated [ModuleID: #qGetTasks.intModuleID#]", false);

                    }

                }

            }


            // Stop schedulecontrol (running = 0)
            application.objSysadmin.stopScheduleControl(url.task);


        } else {

            // It could be that the scheduler has still the flag running true. Maybe the last run has stopped because of an error.
            // Check if the scheduler still has the flag running true after one hour. If yes, make a log and send an email
            if (dateDiff("n", qRunning.dtmStart, now()) gt 60) {

                // Make log
                objLogs.logWrite("scheduletask", "warning", "The scheduler #url.task# has still the flag running true after one hour. Please check the scheduler!", true);

            } else {

                // Make log
                objLogs.logWrite("scheduletask", "warning", "The scheduler #url.task# is still running. The scheduler has not been started again.");

            }

        }


    } else {

        // Make log
        objLogs.logWrite("scheduletask", "warning", "Someone tried to call the scheduler manually with wrong number. url.task was: #url.task#");

    }


} else {

    // Make log
    objLogs.logWrite("scheduletask", "warning", "Someone tried to call the scheduler (task_#url.task#.cfm) manually with wrong password. Password was: #url.pass#");

}


</cfscript>