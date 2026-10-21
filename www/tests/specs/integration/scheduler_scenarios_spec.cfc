component extends="tests.support.integration_spec" {

    /*
        Scheduler jobs for a realistic mix of customers.

        Four modules (M1 with two scheduletasks, M2, M3 with an inactive task, M4
        without tasks) and two plans (P1 includes M2 and M3, P2 includes M4). Every
        scenario below is one customer with its bookings and, where the shard tables
        used to leave something behind, a wrong job from before. After one
        syncAllSchedulers() every customer must have exactly the expected jobs.

        Days are offsets from today; "" means no date.
    */

    variables.scenarios = [
        { key: "active",         title: "an active module booking",                      bookings: [{ ref: "M1", status: "active",   from: -10, to: 20 }],                                             stale: [],      expected: ["T1a", "T1b"] },
        { key: "trial",          title: "a module in its test phase",                    bookings: [{ ref: "M1", status: "test",     from: -2,  to: 12, recurring: "test" }],                          stale: [],      expected: ["T1a", "T1b"] },
        { key: "free",           title: "a free module without dates",                   bookings: [{ ref: "M2", status: "free",     from: "",  to: "", recurring: "onetime" }],                    stale: [],      expected: ["T2"] },
        { key: "canceledValid",  title: "a canceled module within its term",             bookings: [{ ref: "M1", status: "canceled", from: -10, to: 5 }],                                              stale: [],      expected: ["T1a", "T1b"] },
        { key: "canceledEnded",  title: "a canceled module after its term",              bookings: [{ ref: "M1", status: "canceled", from: -40, to: -1 }],                                             stale: ["T1a"], expected: [] },
        { key: "expired",        title: "an expired module",                             bookings: [{ ref: "M1", status: "expired",  from: -40, to: -1 }],                                             stale: ["T1b"], expected: [] },
        { key: "payment",        title: "a module with pending payment within its term", bookings: [{ ref: "M2", status: "payment",  from: -1,  to: 29 }],                                             stale: [],      expected: ["T2"] },
        { key: "waiting",        title: "an active module plus a waiting next period",   bookings: [{ ref: "M1", status: "active",   from: -10, to: 20 }, { ref: "M1", status: "waiting", from: 21, to: 385 }], stale: [], expected: ["T1a", "T1b"] },
        { key: "future",         title: "only a booking that starts later",              bookings: [{ ref: "M1", status: "waiting",  from: 5,   to: 35 }],                                              stale: [],      expected: [] },
        { key: "plan",           title: "a plan with included modules",                  bookings: [{ ref: "P1", status: "active",   from: -10, to: 20 }],                                             stale: [],      expected: ["T2", "T3"] },
        { key: "planAndModule",  title: "a plan plus a module it already includes",      bookings: [{ ref: "P1", status: "active",   from: -10, to: 20 }, { ref: "M2", status: "active", from: -5, to: 25 }], stale: ["T2"], expected: ["T2", "T3"] },
        { key: "planNoTasks",    title: "a plan whose modules have no scheduletasks",    bookings: [{ ref: "P2", status: "active",   from: -10, to: 20 }],                                             stale: [],      expected: [] },
        { key: "planExpired",    title: "an expired plan",                               bookings: [{ ref: "P1", status: "expired",  from: -40, to: -1 }],                                             stale: ["T3"],  expected: [] },
        { key: "freePlan",       title: "a free plan",                                   bookings: [{ ref: "P1", status: "free",     from: "",  to: "", recurring: "onetime" }],                    stale: [],      expected: ["T2", "T3"] },
        { key: "nothing",        title: "no booking at all",                             bookings: [],                                                                                                 stale: ["T1a", "T2"], expected: [] },
        { key: "several",        title: "several modules",                               bookings: [{ ref: "M1", status: "active",   from: -10, to: 20 }, { ref: "M2", status: "free", from: "", to: "", recurring: "onetime" }], stale: [], expected: ["T1a", "T1b", "T2"] }
    ];

    function run() {

        var modules = new backend.core.com.modules();

        describe("Scheduler jobs for a mix of customers", () => {

            // Set up once for all checks of this suite; the fixtures remove it after the spec
            beforeEach(() => {
                if (!structKeyExists(variables, "world")) {
                    variables.world = buildWorld();
                    variables.firstSync = modules.syncAllSchedulers();
                }
            });

            for (var scenario in variables.scenarios) {
                it(
                    title = "gives the right jobs to a customer with " & scenario.title,
                    data  = { scenario: scenario },
                    body  = (data) => {
                        var customerID = variables.world.customers[data.scenario.key];
                        expect(jobNames(customerID)).toBe(data.scenario.expected);
                    }
                );
            }

            it("changes nothing when it reconciles again", () => {
                var changes = 0;
                for (var key in variables.world.customers) {
                    var sync = modules.syncCustomerScheduler(variables.world.customers[key]);
                    changes += sync.added + sync.removed;
                }
                expect(changes).toBe(0);
            });

            it("never stores a job twice", () => {
                var duplicates = queryExecute(
                    "SELECT intScheduletaskID, intCustomerID, COUNT(*) AS cnt FROM scheduler_jobs GROUP BY intScheduletaskID, intCustomerID HAVING COUNT(*) > 1",
                    {},
                    { datasource: application.datasource }
                );
                expect(duplicates.recordCount).toBe(0);
            });

            it("removes the jobs of a deleted customer", () => {
                var customerID = variables.fixtures.createCustomer();
                variables.fixtures.createBooking(customerID = customerID, moduleID = variables.world.modules.M1, startDate = dayFromToday(-1), endDate = dayFromToday(30), status = "active");
                modules.syncCustomerScheduler(customerID);
                expect(jobNames(customerID)).toBe(["T1a", "T1b"]);

                queryExecute("DELETE FROM customers WHERE intCustomerID = :id", { id: { type: "numeric", value: customerID } }, { datasource: application.datasource });

                expect(jobNames(customerID)).toBeEmpty();
            });

            it("removes the jobs of a deleted scheduletask", () => {
                var extraTask = variables.fixtures.createScheduletask(variables.world.modules.M2);
                modules.syncAllSchedulers();
                var count = () => queryExecute("SELECT COUNT(*) AS cnt FROM scheduler_jobs WHERE intScheduletaskID = :id", { id: { type: "numeric", value: extraTask } }, { datasource: application.datasource }).cnt;
                expect(count()).toBeGT(0);

                queryExecute("DELETE FROM scheduletasks WHERE intScheduletaskID = :id", { id: { type: "numeric", value: extraTask } }, { datasource: application.datasource });

                expect(count()).toBe(0);
            });

        });

    }

    private struct function buildWorld() {
        var world = { modules: {}, tasks: {}, plans: {}, customers: {} };

        world.modules.M1 = variables.fixtures.createModule("Scenario M1");
        world.modules.M2 = variables.fixtures.createModule("Scenario M2");
        world.modules.M3 = variables.fixtures.createModule("Scenario M3");
        world.modules.M4 = variables.fixtures.createModule("Scenario M4");

        world.tasks.T1a = variables.fixtures.createScheduletask(world.modules.M1);
        world.tasks.T1b = variables.fixtures.createScheduletask(world.modules.M1);
        world.tasks.T2 = variables.fixtures.createScheduletask(world.modules.M2);
        world.tasks.T3 = variables.fixtures.createScheduletask(world.modules.M3, false);

        world.plans.P1 = variables.fixtures.createPlan([world.modules.M2, world.modules.M3]);
        world.plans.P2 = variables.fixtures.createPlan([world.modules.M4]);

        for (var scenario in variables.scenarios) {
            var customerID = variables.fixtures.createCustomer(companyName = "Scenario " & scenario.key);
            world.customers[scenario.key] = customerID;

            for (var booking in scenario.bookings) {
                var isPlan = left(booking.ref, 1) eq "P";
                variables.fixtures.createBooking(
                    customerID = customerID,
                    planID = isPlan ? world.plans[booking.ref] : "",
                    moduleID = isPlan ? "" : world.modules[booking.ref],
                    startDate = dayFromToday(booking.from),
                    endDate = dayFromToday(booking.to),
                    recurring = booking.recurring ?: "monthly",
                    status = booking.status
                );
            }

            // Wrong jobs from before (what the shard tables used to leave behind)
            for (var taskName in scenario.stale) {
                queryExecute(
                    "INSERT INTO scheduler_jobs (intScheduletaskID, intCustomerID, dtmNextRun) VALUES (:taskID, :customerID, NOW())",
                    { taskID: { type: "numeric", value: world.tasks[taskName] }, customerID: { type: "numeric", value: customerID } },
                    { datasource: application.datasource }
                );
            }
        }

        // Task IDs back to their names, for readable failures
        world.taskNames = {};
        for (var name in world.tasks) {
            world.taskNames[world.tasks[name]] = name;
        }

        return world;
    }

    // The names (T1a, T1b, T2, T3) of the jobs a customer has, sorted
    private array function jobNames(required numeric customerID) {
        var rows = queryExecute(
            "SELECT intScheduletaskID FROM scheduler_jobs WHERE intCustomerID = :customerID",
            { customerID: { type: "numeric", value: arguments.customerID } },
            { datasource: application.datasource }
        );
        var names = listToArray(valueList(rows.intScheduletaskID)).map((id) => variables.world.taskNames[id] ?: "unknown task " & id);
        names.sort("textnocase");
        return names;
    }

    private string function dayFromToday(required any offset) {
        return isNumeric(arguments.offset) ? dateFormat(dateAdd("d", arguments.offset, now()), "yyyy-mm-dd") : "";
    }

}
