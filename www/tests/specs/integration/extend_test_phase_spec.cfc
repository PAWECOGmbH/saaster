component extends="tests.support.integration_spec" {

    /*
        Extending an expired test phase - issue #624.

        Before: once the test phase of a module had expired, the sysadmin could not give it
        more time - the module had to be withdrawn and booked again. Editing the period of an
        expired plan test kept the status "expired".

        Now the period handlers ask book.cfc::statusAfterPeriodChange: an expired test phase
        that gets an end date of today or later runs again as test phase. Paid bookings keep
        their status.
    */

    function run() {

        var book = new backend.core.com.book();

        describe("Extending an expired test phase", () => {

            beforeEach(() => {
                variables.customerID = variables.fixtures.createCustomer();
                variables.moduleID = variables.fixtures.createModule("Test phase");
                variables.taskID = variables.fixtures.createScheduletask(variables.moduleID);
            });

            describe("statusAfterPeriodChange", () => {

                it("runs an expired test phase again as test phase", () => {
                    var bookingID = bookModule("test", "expired", -20, -1);

                    expect(book.statusAfterPeriodChange(bookingID, variables.customerID, dayFromToday(14))).toBe("test");
                    expect(book.statusAfterPeriodChange(bookingID, variables.customerID, dayFromToday(0))).toBe("test", "Until today counts");
                });

                it("keeps the status for an end date in the past", () => {
                    var bookingID = bookModule("test", "expired", -20, -1);

                    expect(book.statusAfterPeriodChange(bookingID, variables.customerID, dayFromToday(-1))).toBe("");
                    expect(book.statusAfterPeriodChange(bookingID, variables.customerID, "")).toBe("");
                });

                it("keeps the status of paid and running bookings", () => {
                    expect(book.statusAfterPeriodChange(bookModule("monthly", "expired", -40, -10), variables.customerID, dayFromToday(14))).toBe("", "An expired paid booking is renewed by an invoice");
                    expect(book.statusAfterPeriodChange(bookModule("test", "test", -5, 5), variables.customerID, dayFromToday(14))).toBe("");
                    expect(book.statusAfterPeriodChange(bookModule("monthly", "active", -5, 25), variables.customerID, dayFromToday(60))).toBe("");
                });

                it("ignores a booking of another customer", () => {
                    var bookingID = bookModule("test", "expired", -20, -1);
                    var otherCustomer = variables.fixtures.createCustomer();

                    expect(book.statusAfterPeriodChange(bookingID, otherCustomer, dayFromToday(14))).toBe("");
                });

            });

            describe("Saving the new period", () => {

                it("gives the customer the module and its scheduletasks back", () => {
                    var bookingID = bookModule("test", "expired", -20, -1);
                    var modules = new backend.core.com.modules();
                    modules.syncCustomerScheduler(variables.customerID);
                    expect(jobCount()).toBe(0, "No jobs while the test phase is expired");

                    // What the period handler does
                    var bookingStruct = { bookingID: bookingID, dateStart: dayFromToday(-20), dateEnd: dayFromToday(14) };
                    var newStatus = book.statusAfterPeriodChange(bookingID, variables.customerID, bookingStruct.dateEnd);
                    if (len(newStatus)) {
                        bookingStruct['status'] = newStatus;
                    }
                    book.updateBooking(bookingStruct);

                    var status = modules.getModuleStatus(variables.customerID, variables.moduleID);
                    expect(status.status).toBe("test");
                    expect(dateFormat(status.endDate, "yyyy-mm-dd")).toBe(dayFromToday(14));
                    expect(modules.shouldRunScheduler(variables.customerID, variables.moduleID)).toBeTrue();
                    expect(jobCount()).toBe(1, "updateBooking reconciles the scheduler");
                });

            });

            describe("Wiring (source)", () => {

                var scanner = new tests.support.security_scanner();

                it("lets both period handlers apply the rule before saving", () => {
                    for (var file in ["backend/core/handler/sysadmin/modules.cfm", "backend/core/handler/sysadmin/plans.cfm"]) {
                        var source = scanner.readSource(file);
                        var rule = find("statusAfterPeriodChange(url.b, url.c,", source);
                        expect(rule).toBeGT(0, file);
                        expect(rule).toBeLT(find("objBookPeriod.updateBooking(bookingStruct)", source), file & ": the status must be set before saving");
                    }
                });

                it("offers the sysadmin to extend an expired module test phase", () => {
                    var source = scanner.readSource("backend/core/views/sysadmin/customers_details.cfm");
                    var offer = find("Extend the test phase", source);
                    expect(offer).toBeGT(0);
                    expect(mid(source, offer - 700, 700)).toInclude("moduleStatus.status eq ""expired"" and (moduleStatus.recurring ?: """") eq ""test""");
                });

            });

        });

    }

    private numeric function bookModule(required string recurring, required string status, required numeric fromDay, required numeric toDay) {
        return variables.fixtures.createBooking(
            customerID = variables.customerID,
            moduleID = variables.moduleID,
            startDate = dayFromToday(arguments.fromDay),
            endDate = dayFromToday(arguments.toDay),
            recurring = arguments.recurring,
            status = arguments.status
        );
    }

    private numeric function jobCount() {
        return queryExecute(
            "SELECT COUNT(*) AS cnt FROM scheduler_jobs WHERE intCustomerID = :customerID AND intScheduletaskID = :taskID",
            { customerID: { type: "numeric", value: variables.customerID }, taskID: { type: "numeric", value: variables.taskID } },
            { datasource: application.datasource }
        ).cnt;
    }

    private string function dayFromToday(required numeric offset) {
        return dateFormat(dateAdd("d", arguments.offset, now()), "yyyy-mm-dd");
    }

}
