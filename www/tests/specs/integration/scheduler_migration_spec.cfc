component extends="tests.support.integration_spec" {

    /*
        Migration V23 (config/db/core/V23__scheduler-jobs.sql) - the update of
        installations that still have their jobs in the shard tables scheduler_01..20.

        The spec fills the old tables the way a running installation does, including
        a pair that the bugs of #655 left in two tables, and runs the statements of the
        migration file again. The file is safe to run twice: CREATE TABLE IF NOT EXISTS
        and INSERT IGNORE keep the jobs that exist already.
    */

    // compose-dev.yml mounts config/db read-only at /var/saaster/db
    variables.migrationFile = "/var/saaster/db/core/V23__scheduler-jobs.sql";

    function run() {

        // Skipped without the mount of config/db (compose-dev.yml), e.g. in a stack set up before it existed
        describe(title = "Migration V23: shard tables to scheduler_jobs", skip = !fileExists(variables.migrationFile), body = () => {

            beforeEach(() => {
                variables.moduleID = variables.fixtures.createModule("Migration");
                variables.taskID = variables.fixtures.createScheduletask(variables.moduleID);
                variables.customerA = variables.fixtures.createCustomer();
                variables.customerB = variables.fixtures.createCustomer();
                variables.customerC = variables.fixtures.createCustomer();
            });

            it("copies the entries of all shard tables", () => {
                insertShard("05", variables.customerB, "2026-10-22 00:00:00", "", 0);
                insertShard("20", variables.customerC, "2026-10-23 00:00:00", "2026-10-01 08:00:00", 4);

                runMigration();

                expect(job(variables.customerB).dtmNextRun).toBe(createDateTime(2026, 10, 22, 0, 0, 0));
                expect(job(variables.customerC).dtmLastRun).toBe(createDateTime(2026, 10, 1, 8, 0, 0));
                expect(job(variables.customerC).intDuringSeconds).toBe(4);
            });

            it("merges a pair found in two shard tables into one job", () => {
                insertShard("03", variables.customerA, "2026-10-21 12:00:00", "2026-10-01 10:00:00", 3);
                insertShard("11", variables.customerA, "2026-10-21 09:00:00", "2026-10-20 10:00:00", 7);

                runMigration();

                var merged = job(variables.customerA);
                expect(merged.recordCount).toBe(1);
                expect(merged.dtmNextRun).toBe(createDateTime(2026, 10, 21, 9, 0, 0), "The earliest next run, so nothing is skipped");
                expect(merged.dtmLastRun).toBe(createDateTime(2026, 10, 20, 10, 0, 0), "The latest last run");
            });

            it("keeps a job that exists already and can run twice", () => {
                queryExecute(
                    "INSERT INTO scheduler_jobs (intScheduletaskID, intCustomerID, dtmNextRun) VALUES (:taskID, :customerID, '2030-01-01 00:00:00')",
                    { taskID: { type: "numeric", value: variables.taskID }, customerID: { type: "numeric", value: variables.customerA } },
                    { datasource: application.datasource }
                );
                insertShard("07", variables.customerA, "2026-10-21 09:00:00", "", 0);

                runMigration();
                runMigration();

                var kept = job(variables.customerA);
                expect(kept.recordCount).toBe(1);
                expect(kept.dtmNextRun).toBe(createDateTime(2030, 1, 1, 0, 0, 0));
            });

            it("leaves the shard tables in place", () => {
                insertShard("09", variables.customerB, "2026-10-22 00:00:00", "", 0);

                runMigration();

                var left = queryExecute(
                    "SELECT COUNT(*) AS cnt FROM scheduler_09 WHERE intCustomerID = :customerID",
                    { customerID: { type: "numeric", value: variables.customerB } },
                    { datasource: application.datasource }
                );
                expect(left.cnt).toBe(1);
            });

        });

    }

    // Runs every statement of the migration file (comments removed, split at the semicolons)
    private void function runMigration() {
        var source = fileRead(variables.migrationFile, "utf-8");
        var lines = listToArray(replace(source, chr(13), "", "all"), chr(10), true).filter((line) => !reFind("^\s*--", line));
        var statements = listToArray(arrayToList(lines, chr(10)), ";").filter((statement) => len(trim(statement)));

        expect(statements).toHaveLength(2, "The migration has changed - check this spec");

        for (var statement in statements) {
            queryExecute(statement, {}, { datasource: application.datasource });
        }
    }

    private void function insertShard(required string shard, required numeric customerID, required string nextRun, required string lastRun, required numeric seconds) {
        queryExecute(
            "INSERT INTO scheduler_#arguments.shard# (intScheduletaskID, intCustomerID, dtmNextRun, dtmLastRun, intDuringSeconds) VALUES (:taskID, :customerID, :nextRun, :lastRun, :seconds)",
            {
                taskID: { type: "numeric", value: variables.taskID },
                customerID: { type: "numeric", value: arguments.customerID },
                nextRun: { type: "datetime", value: arguments.nextRun },
                lastRun: { type: "datetime", value: isDate(arguments.lastRun) ? arguments.lastRun : now(), null: !isDate(arguments.lastRun) },
                seconds: { type: "numeric", value: arguments.seconds }
            },
            { datasource: application.datasource }
        );
    }

    private query function job(required numeric customerID) {
        return queryExecute(
            "SELECT * FROM scheduler_jobs WHERE intScheduletaskID = :taskID AND intCustomerID = :customerID",
            { taskID: { type: "numeric", value: variables.taskID }, customerID: { type: "numeric", value: arguments.customerID } },
            { datasource: application.datasource }
        );
    }

}
