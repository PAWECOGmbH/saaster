component extends="tests.support.integration_spec" {
    function run() {
        describe("Module access through direct and plan bookings", () => {
            beforeEach(() => {
                logout();
                variables.customer = variables.fixtures.createCustomer();
                variables.user = variables.fixtures.createUser(customerID=variables.customer);
                loginAs(variables.user);
                variables.moduleA = variables.fixtures.createModule();
                variables.moduleB = variables.fixtures.createModule();
                variables.fixtures.createScheduletask(moduleID=variables.moduleA);
                variables.fixtures.createScheduletask(moduleID=variables.moduleB);
                variables.plan = variables.fixtures.createPlan([variables.moduleA]);
            });

            it("grants an included module without a direct booking and denies unrelated modules", () => {
                bookPlan("active", -1, 1);
                expectAccess(variables.moduleA, true);
                expectAccess(variables.moduleB, false);
            });

            it("grants free plan bookings without dates, but not unbooked free catalog plans", () => {
                queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:variables.plan}},
                    sql="UPDATE plans SET blnFree = 1 WHERE intPlanID = :id");
                expectAccess(variables.moduleA, false);
                variables.fixtures.createBooking(customerID=variables.customer, planID=variables.plan, status="free");
                expectAccess(variables.moduleA, true);
            });

            it("requires valid dates for non-free plans", () => {
                local.booking = variables.fixtures.createBooking(customerID=variables.customer, planID=variables.plan, status="active");
                expectAccess(variables.moduleA, false);
                changeBooking(local.booking, "active", 1, 2);
                expectAccess(variables.moduleA, false);
                changeBooking(local.booking, "active", -2, -1);
                expectAccess(variables.moduleA, false);
            });

            it("preserves inclusive end dates and cancellation access until the period ends", () => {
                local.booking = bookPlan("test", 0, 0);
                expectAccess(variables.moduleA, true);
                changeBooking(local.booking, "canceled", -1, 0);
                expectAccess(variables.moduleA, true);
                changeBooking(local.booking, "canceled", -2, -1);
                expectAccess(variables.moduleA, false);
            });

            it("does not let expired or future plans override the current plan's modules", () => {
                bookPlan("canceled", -10, -1);
                bookPlan("waiting", 2, 20);
                local.current = variables.fixtures.createPlan([variables.moduleB]);
                variables.fixtures.createBooking(customerID=variables.customer, planID=local.current, status="active",
                    startDate=bookingDate(-1), endDate=bookingDate(1));
                expectAccess(variables.moduleA, false);
                expectAccess(variables.moduleB, true);
            });

            it("accepts either booking source without stale direct bookings masking an active plan", () => {
                local.old = variables.fixtures.createBooking(customerID=variables.customer, moduleID=variables.moduleA, status="canceled",
                    startDate=bookingDate(-10), endDate=bookingDate(-2));
                local.planBooking = bookPlan("active", -1, 1);
                expectAccess(variables.moduleA, true);
                changeBooking(local.planBooking, "canceled", -2, -1);
                expectAccess(variables.moduleA, false);
                variables.fixtures.createBooking(customerID=variables.customer, moduleID=variables.moduleA, status="active",
                    startDate=bookingDate(0), endDate=bookingDate(1));
                expectAccess(variables.moduleA, true);
            });

            it("scopes plan entitlement to the exact customer rather than its parent or another organization", () => {
                bookPlan("active", -1, 1);
                local.tenant = variables.fixtures.createCustomer(parentID=variables.customer);
                local.other = variables.fixtures.createCustomer();
                session.customer_id = local.tenant;
                expectAccess(variables.moduleA, false);
                session.customer_id = local.other;
                expectAccess(variables.moduleA, false);
                session.customer_id = variables.customer;
                expectAccess(variables.moduleA, true);
            });

            it("rechecks included-module assignments and removed bookings without cached grants", () => {
                local.booking = bookPlan("active", -1, 1);
                expectAccess(variables.moduleA, true);
                queryExecute(options={datasource:application.datasource}, params={plan:{type:"integer",value:variables.plan}},
                    sql="DELETE FROM plans_modules WHERE intPlanID = :plan");
                expectAccess(variables.moduleA, false);
                queryExecute(options={datasource:application.datasource}, params={plan:{type:"integer",value:variables.plan}, module:{type:"integer",value:variables.moduleA}},
                    sql="INSERT INTO plans_modules (intPlanID, intModuleID) VALUES (:plan, :module)");
                expectAccess(variables.moduleA, true);
                queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:local.booking}},
                    sql="DELETE FROM bookings WHERE intBookingID = :id");
                expectAccess(variables.moduleA, false);
            });
        });
    }

    private string function bookingDate(required numeric offset) {
        return dateFormat(dateAdd("d", arguments.offset, now()), "yyyy-mm-dd");
    }

    private numeric function bookPlan(required string status, required numeric start, required numeric end) {
        return variables.fixtures.createBooking(customerID=variables.customer, planID=variables.plan, status=arguments.status,
            startDate=bookingDate(arguments.start), endDate=bookingDate(arguments.end));
    }

    private void function changeBooking(required numeric id, required string status, required numeric start, required numeric end) {
        queryExecute(
            options = {datasource: application.datasource},
            params = {id:{type:"integer",value:arguments.id}, status:{type:"varchar",value:arguments.status},
                start:{type:"date",value:bookingDate(arguments.start)}, end:{type:"date",value:bookingDate(arguments.end)}},
            sql = "UPDATE bookings SET strStatus = :status, dteStartDate = :start, dteEndDate = :end WHERE intBookingID = :id"
        );
    }

    private void function expectAccess(required numeric moduleID, required boolean allowed) {
        expect(application.objRequestAccess.moduleAccess(arguments.moduleID)).toBe(arguments.allowed);
        expect(application.objModules.shouldRunScheduler(session.customer_id, arguments.moduleID)).toBe(arguments.allowed,
            "Browser access and scheduler eligibility must agree for the same customer's bookings");
    }
}
