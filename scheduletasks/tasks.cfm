
<cfscript>

// This file gets executed from the scheduler every 2 minutes

setting requesttimeout = 1000;

param name="url.task" default="01";
if (!isNumeric(url.task)) {
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
    );

    if (qRunning.recordCount) {

        // If seconds is in minus, the previous task is still running
        if (qRunning.seconds gt 0) {

            // Update schedulecontrol
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

                // Make loop over all the tasks
                loop query="qGetTasks" {

                    if (len(trim(qGetTasks.strPath))) {

                        // Variables may be needed in the included file
                        variables.customerID = qGetTasks.intCustomerID;
                        variables.moduleID = qGetTasks.intModuleID;

                        // Include the file
                        if (fileExists(qGetTasks.strPath)) {
                            include template="/#qGetTasks.strPath#";
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

                    }

                }

            } else {

                echo('There is nothing to do!');

            }

            // Update schedulecontrol
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

            echo('schedulecontrol updated!');

        } else {

            // If the difference is greater than 5 minutes, something went wrong -> correct it!
            if (dateDiff("n", qRunning.dtmStart, now()) gt 5 or dateDiff("n", qRunning.dtmStart, now()) eq 0) {

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

        echo('No tasks found!');

    }


} else {

    echo('Password missing!');

}

</cfscript>