component extends="tests.support.integration_spec" {

    /*
        Scheduler jobs through the real booking code: book.cfc (checkBooking,
        updateBooking) and cancel.cfc (cancel, revoke, delete). No booking row is
        written by hand here - this proves that the callers trigger the reconciliation
        after they saved the booking.

        The bookingData struct is what plans.cfc / modules.cfc hand to checkBooking;
        it is built here with fixed prices so no price tables are needed. No invoice
        is created (makeInvoice false).
    */

    function run() {

        var modules = new backend.core.com.modules();

        describe("Scheduler jobs through the booking code", () => {

            beforeEach(() => {
                param name="session.sysadmin" default=false;

                variables.customerID = variables.fixtures.createCustomer();
                variables.moduleA = variables.fixtures.createModule("Flow A");
                variables.moduleB = variables.fixtures.createModule("Flow B");
                variables.taskA = variables.fixtures.createScheduletask(variables.moduleA);
                variables.taskB = variables.fixtures.createScheduletask(variables.moduleB);
            });

            it("adds the jobs when a module is booked with test days", () => {
                var result = bookModule(variables.moduleA, "monthly", { testDays: 14 });

                expect(bookingOf(variables.moduleA).strStatus).toBe("test", result.message ?: "");
                expect(jobTasks()).toBe([variables.taskA]);
            });

            it("adds the jobs when a free module is booked", () => {
                bookModule(variables.moduleA, "monthly", { itsFree: true });

                expect(bookingOf(variables.moduleA).strStatus).toBe("free");
                expect(jobTasks()).toBe([variables.taskA]);
            });

            it("adds the jobs when a paid module is booked", () => {
                bookModule(variables.moduleA, "monthly");

                expect(bookingOf(variables.moduleA).strStatus).toBe("active");
                expect(jobTasks()).toBe([variables.taskA]);
            });

            it("keeps the jobs when the cycle changes from yearly to monthly (waiting booking, ##655-1)", () => {
                bookModule(variables.moduleA, "yearly");
                expect(jobTasks()).toBe([variables.taskA]);

                bookModule(variables.moduleA, "monthly");

                var statuses = valueList(queryExecute(
                    "SELECT strStatus FROM bookings WHERE intCustomerID = :customerID AND intModuleID = :moduleID ORDER BY dteStartDate",
                    { customerID: { type: "numeric", value: variables.customerID }, moduleID: { type: "numeric", value: variables.moduleA } },
                    { datasource: application.datasource }
                ).strStatus);
                expect(statuses).toBe("active,waiting");
                expect(jobTasks()).toBe([variables.taskA], "The waiting booking stopped the running one");
            });

            it("adds the jobs of the modules included in a booked plan (##655-3)", () => {
                var planID = variables.fixtures.createPlan([variables.moduleA, variables.moduleB]);

                bookPlan(planID, [variables.moduleA, variables.moduleB], { testDays: 14 });

                expect(jobTasks()).toBe([variables.taskA, variables.taskB]);
            });

            it("keeps the jobs when the customer cancels - until the end date (##655-2)", () => {
                bookModule(variables.moduleA, "monthly");

                var result = new backend.core.com.cancel(variables.customerID, variables.moduleA, "module").cancel();

                expect(result.success).toBeTrue(result.message);
                expect(bookingOf(variables.moduleA).strStatus).toBe("canceled");
                expect(jobTasks()).toBe([variables.taskA]);
            });

            it("keeps the jobs when a cancellation is revoked", () => {
                bookModule(variables.moduleA, "monthly");
                var cancel = new backend.core.com.cancel(variables.customerID, variables.moduleA, "module");
                cancel.cancel();

                cancel.revoke();

                expect(bookingOf(variables.moduleA).strStatus).toBe("active");
                expect(jobTasks()).toBe([variables.taskA]);
            });

            it("removes the jobs when the sysadmin withdraws the module", () => {
                bookModule(variables.moduleA, "monthly");
                bookModule(variables.moduleB, "monthly");

                new backend.core.com.cancel(variables.customerID, variables.moduleA, "module").delete(bookingOf(variables.moduleA).intBookingID, variables.moduleA, variables.customerID);

                expect(jobTasks()).toBe([variables.taskB]);
            });

            it("removes the jobs when updateBooking ends the booking", () => {
                bookModule(variables.moduleA, "monthly");
                var yesterday = dateFormat(dateAdd("d", -1, now()), "yyyy-mm-dd");

                new backend.core.com.book().updateBooking({
                    bookingID: bookingOf(variables.moduleA).intBookingID,
                    dateStart: dateFormat(dateAdd("m", -1, now()), "yyyy-mm-dd"),
                    dateEnd: yesterday,
                    status: "expired"
                });

                expect(jobTasks()).toBeEmpty();
            });

            it("adds the jobs again when updateBooking extends an expired test phase", () => {
                bookModule(variables.moduleA, "monthly", { testDays: 14 });
                var booking = bookingOf(variables.moduleA);
                var book = new backend.core.com.book();
                book.updateBooking({ bookingID: booking.intBookingID, dateStart: dateFormat(dateAdd("d", -30, now()), "yyyy-mm-dd"), dateEnd: dateFormat(dateAdd("d", -1, now()), "yyyy-mm-dd"), status: "expired" });
                expect(jobTasks()).toBeEmpty();

                book.updateBooking({ bookingID: booking.intBookingID, dateEnd: dateFormat(dateAdd("d", 14, now()), "yyyy-mm-dd"), status: "test" });

                expect(jobTasks()).toBe([variables.taskA]);
            });

        });

    }

    // What modules.cfc hands to checkBooking for a module, with fixed prices
    private struct function moduleData(required numeric moduleID, struct overrides = {}) {
        var data = {
            moduleID: arguments.moduleID,
            name: "TestBox Flow Module",
            shortDescription: "",
            vat: 0,
            vatType: 1,
            isNet: true,
            currency: "USD",
            testDays: 0,
            testDaysUpgrade: 0,
            itsFree: false,
            priceMonthly: 10,
            priceYearly: 100,
            priceOnetime: 0,
            durationDays: 0,
            redirectPath: ""
        };
        structAppend(data, arguments.overrides, true);
        return data;
    }

    private struct function bookModule(required numeric moduleID, required string recurring, struct overrides = {}) {
        return new backend.core.com.book("module", "en").checkBooking(
            customerID = variables.customerID,
            bookingData = moduleData(arguments.moduleID, arguments.overrides),
            recurring = arguments.recurring,
            makeBooking = true,
            makeInvoice = false,
            chargeInvoice = false
        );
    }

    private struct function bookPlan(required numeric planID, required array includedModuleIDs, struct overrides = {}) {
        var data = moduleData(0, arguments.overrides);
        structDelete(data, "moduleID");
        data.planID = arguments.planID;
        data.planName = "TestBox Flow Plan";
        data.maxUsers = 0;
        data.modulesIncluded = arguments.includedModuleIDs.map((id) => { return { moduleID: id }; });

        return new backend.core.com.book("plan", "en").checkBooking(
            customerID = variables.customerID,
            bookingData = data,
            recurring = "monthly",
            makeBooking = true,
            makeInvoice = false,
            chargeInvoice = false
        );
    }

    private query function bookingOf(required numeric moduleID) {
        return queryExecute(
            "SELECT intBookingID, strStatus, dteStartDate, dteEndDate FROM bookings WHERE intCustomerID = :customerID AND intModuleID = :moduleID ORDER BY dteStartDate LIMIT 1",
            { customerID: { type: "numeric", value: variables.customerID }, moduleID: { type: "numeric", value: arguments.moduleID } },
            { datasource: application.datasource }
        );
    }

    private array function jobTasks() {
        var rows = queryExecute(
            "SELECT intScheduletaskID FROM scheduler_jobs WHERE intCustomerID = :customerID ORDER BY intScheduletaskID",
            { customerID: { type: "numeric", value: variables.customerID } },
            { datasource: application.datasource }
        );
        return listToArray(valueList(rows.intScheduletaskID)).map((id) => val(id));
    }

}
