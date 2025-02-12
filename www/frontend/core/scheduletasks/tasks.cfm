
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
            SELECT dtmStart, dtmEnd, blnIsRunning
            FROM schedulecontrol
            WHERE strTaskName = 'task_#url.task#'
        "
    )

    if (qRunning.recordCount) {

        // Check if the scheduler is running
        if (qRunning.blnIsRunning eq 0) {

            // Update schedulecontrol
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    utcDate: {type: "datetime", value: now()}
                },
                sql = "
                    UPDATE schedulecontrol
                    SET dtmStart = :utcDate,
                        blnIsRunning = 1
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
                        scheduler_#url.task#.dtmLastRun,
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

                                // Make start log
                                objLogs.logWrite(type="scheduletask", level="info", message="Start running file #qGetTasks.strPath#", sendMail=false, date=baseTime);

                                // Include the given file
                                include template="\#qGetTasks.strPath#";

                                // Calculate the elapsed milliseconds since the task was started
                                elapsedMilliseconds = getTickCount() - startTickCount;

                                // Conversion to seconds
                                elapsedSeconds = round(elapsedMilliseconds / 1000);

                                // Adjust current time
                                currentTime = dateAdd("s", elapsedSeconds, baseTime);


                                // Make end log
                                objLogs.logWrite(type="scheduletask", level="info", message="Stop running file #qGetTasks.strPath#", sendMail=false, date=currentTime);


                            } catch(any e) {

                                lastRunSuccessful = false;

                                // Stop schedulecontrol
                                application.objSysadmin.stopScheduleControl(url.task);

                                // Decativate the schedule task
                                application.objSysadmin.deactivateTask(qGetTasks.intScheduletaskID);

                                // Make log
                                objLogs.logWrite("scheduletask", "error", "Something went wrong in schedule task, the task has been deactivated [File: #qGetTasks.strPath#, Error: #e.message#]", true, baseTime);

                            }


                        } else {

                            lastRunSuccessful = false;

                            // Decativate the schedule task
                            application.objSysadmin.deactivateTask(qGetTasks.intScheduletaskID);

                            // Make log
                            objLogs.logWrite("scheduletask", "error", "File not found, the schedule task has been deactivated [File: #qGetTasks.strPath#]", true, baseTime);

                        }

                        // Only update the lastRun if the task was successful
                        if (lastRunSuccessful) {
                            lastRun = now();
                        }

                        // Calculate next run
                        nextRun = application.objSysadmin.calcNextRun(qGetTasks.dtmStartTime, qGetTasks.intIterationMinutes);

                        // Update scheduler
                        queryExecute(
                            options = {datasource = application.datasource},
                            params = {
                                scheduleID: {type: "numeric", value: qGetTasks.intScheduletaskID},
                                utcDate: {type: "datetime", value: isDate(lastRun) ? lastRun : nullValue()},
                                nextRun: {type: "datetime", value: nextRun},
                                elapsedSeconds: {type: "numeric", value: elapsedSeconds}
                            },
                            sql = "
                                UPDATE scheduler_#url.task#
                                SET dtmLastRun = :utcDate,
                                    dtmNextRun = :nextRun,
                                    intDuringSeconds = :elapsedSeconds
                                WHERE intScheduleTaskID = :scheduleID
                            "
                        )

                        // If the elapsedSeconds was longer than 3 minutes, make log and send an email
                        if (elapsedSeconds gt 180) {

                            // Make log
                            objLogs.logWrite("scheduletask", "warning", "The task #qGetTasks.strPath# took longer than 3 minutes to run. It took #elapsedSeconds# seconds.", true, currentTime);

                        }



                    } else {

                        // Decativate the schedule task
                        application.objSysadmin.deactivateTask(qGetTasks.intScheduletaskID);

                        // Make log
                        objLogs.logWrite(type="scheduletask", level="warning", message="Empty path in schedule task. The schedule task has been deactivated [ModuleID: #qGetTasks.intModuleID#]", sendMail=false, date=baseTime);

                    }

                }

            }


            // Stop schedulecontrol (running = 0)
            application.objSysadmin.stopScheduleControl(url.task);


        } else {

            // It could be, that the scheduler is still running, because the last run has stopped because of an error or something else
            // Lets check if the scheduler is running for more than 10 minutes
            if (dateDiff("n", qRunning.dtmStart, now()) gt 10) {

                // Stop schedulecontrol (running = 0)
                application.objSysadmin.stopScheduleControl(url.task);

                // Make log
                objLogs.logWrite("scheduletask", "warning", "The scheduler #url.task# was running for more than 10 minutes. The scheduler has been stopped.");


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