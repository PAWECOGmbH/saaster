
<cfscript>

// This file gets executed from the scheduler every 2 minutes

setting requesttimeout = 1000;
objLogs = application.objLog;
objTime = new backend.core.com.time(1);

param name="url.task" default="01";
if (!isNumeric(url.task)) {
    // Make log
    objLogs.logWrite("scheduletask", "warning", "Someone tried to call the scheduler task_xx manually and did not send the url.task as numeric. The value for url.task was: #url.task#");
    abort;
}

// Security (password from config.cfm)
param name="url.pass" default="";
if (url.pass eq variables.schedulePassword) {

    qRunning = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT TIMESTAMPDIFF(SECOND, dtmStart, dtmEnd) as seconds, dtmStart, dtmEnd
            FROM schedulecontrol
            WHERE strTaskName = 'task_#url.task#'
        "
    )

    if (qRunning.recordCount) {

        // If seconds are in minus, the previous task is still running
        if (qRunning.seconds gt 0) {

            // Update schedulecontrol: set starttime to now
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    utcDate: {type: "datetime", value: now()}
                },
                sql = "
                    UPDATE schedulecontrol
                    SET dtmStart = :utcDate
                    WHERE strTaskName = 'task_#url.task#'
                "
            )

            // Get all tasks that have to be executed
            qGetTasks = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    utcDate: {type: "datetime", value: now()}
                },
                sql = "
                    SELECT
                        scheduler_#url.task#.intScheduletaskID,
                        scheduler_#url.task#.intCustomerID,
                        scheduler_#url.task#.dtmNextRun,
                        scheduletasks.strPath,
                        scheduletasks.intModuleID,
                        scheduletasks.intIterationMinutes,
                        scheduletasks.dtmStartTime
                    FROM scheduler_#url.task#
                    INNER JOIN scheduletasks
                    ON scheduler_#url.task#.intScheduletaskID = scheduletasks.intScheduletaskID
                    AND scheduletasks.blnActive = 1
                    AND scheduler_#url.task#.dtmNextRun < :utcDate
                "
            )

            if (qGetTasks.recordCount) {

                // Start time for log entries, based on dtmNextRun
                local.baseTime = objTime.utc2local(qGetTasks.dtmNextRun);

                // Make loop over all the tasks
                loop query="qGetTasks" {

                    if (len(trim(qGetTasks.strPath))) {

                        // Variables may be needed in the included file
                        variables.customerID = qGetTasks.intCustomerID;
                        variables.moduleID = qGetTasks.intModuleID;

                        // Include the file
                        if (fileExists(expandPath("\#qGetTasks.strPath#"))) {

                            try {

                                // Add the start tick count at the beginning of the task
                                local.startTickCount = getTickCount();

                                // Make start log
                                objLogs.logWrite(type="scheduletask", level="info", message="Start running file #qGetTasks.strPath#", sendMail=false, date=local.baseTime);

                                // Include the given file
                                include template="\#qGetTasks.strPath#";

                                // Calculate the elapsed milliseconds since the task was started
                                local.elapsedMilliseconds = getTickCount() - local.startTickCount;

                                // Conversion to seconds
                                local.elapsedSeconds = local.elapsedMilliseconds / 1000;

                                // Adjust current time
                                local.currentTime = dateAdd("s", local.elapsedSeconds, local.baseTime);


                                // Make end log
                                objLogs.logWrite(type="scheduletask", level="info", message="Stop running file #qGetTasks.strPath#", sendMail=false, date=local.currentTime);


                            } catch(any e) {

                                // Decativate the schedule task
                                application.objSysadmin.deactivateTask(qGetTasks.intScheduletaskID);

                                // Make log
                                objLogs.logWrite("scheduletask", "error", "Something went wrong in schedule task, the task has been deactivated [File: #qGetTasks.strPath#, Error: #e.message#]", true, local.baseTime);

                            }


                        } else {

                            // Decativate the schedule task
                            application.objSysadmin.deactivateTask(qGetTasks.intScheduletaskID);

                            // Make log
                            objLogs.logWrite("scheduletask", "error", "File not found, the schedule task has been deactivated [File: #qGetTasks.strPath#]", true, local.baseTime);

                        }

                        // Calculate next run
                        nextRun = application.objSysadmin.calcNextRun(qGetTasks.dtmStartTime, qGetTasks.intIterationMinutes);

                        // Update scheduler
                        queryExecute(
                            options = {datasource = application.datasource},
                            params = {
                                scheduleID: {type: "numeric", value: qGetTasks.intScheduletaskID},
                                utcDate: {type: "datetime", value: now()},
                                nextRun: {type: "datetime", value: nextRun}
                            },
                            sql = "
                                UPDATE scheduler_#url.task#
                                SET dtmLastRun = :utcDate,
                                    dtmNextRun = :nextRun
                                WHERE intScheduleTaskID = :scheduleID
                            "
                        )

                    } else {

                        // Decativate the schedule task
                        application.objSysadmin.deactivateTask(qGetTasks.intScheduletaskID);

                        // Make log
                        objLogs.logWrite(type="scheduletask", level="warning", message="Empty path in schedule task. The schedule task has been deactivated [ModuleID: #qGetTasks.intModuleID#]", sendMail=false, date=local.baseTime);

                    }

                }

            }


            // Update schedulecontrol: set end time to now plus one second
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    utcDate: {type: "datetime", value: now()}
                },
                sql = "
                    UPDATE schedulecontrol
                    SET dtmEnd = DATE_ADD(:utcDate, INTERVAL 1 SECOND)
                    WHERE strTaskName = 'task_#url.task#'
                "
            )


        } else {

            // If the difference is greater than 15 minutes, something went wrong -> correct it!
            if (dateDiff("n", qRunning.dtmStart, now()) gt 15 or dateDiff("n", qRunning.dtmStart, now()) eq 0) {

                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        utcDate: {type: "datetime", value: now()}
                    },
                    sql = "
                        UPDATE schedulecontrol
                        SET dtmStart = :utcDate,
                            dtmEnd = DATE_ADD(:utcDate, INTERVAL 1 SECOND)
                        WHERE strTaskName = 'task_#url.task#'
                    "
                )

            }

        }


    } else {

        // Make log
        objLogs.logWrite("scheduletask", "warning", "Someone tried to call the scheduler manually with wrong number. url.task was: #url.task#");

    }


} else {

    // Make log
    objLogs.logWrite("scheduletask", "warning", "Someone tried to call the scheduler (task_#url.task#.cfm) manually with wrong password. Passwort was: #url.pass#");

}

</cfscript>