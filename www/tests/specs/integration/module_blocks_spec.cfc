component extends="tests.support.integration_spec" {
    function run() {
        describe("Customer module blocks", () => {
            beforeEach(() => {
                logout();
                recordLogs();
                variables.customer = variables.fixtures.createCustomer();
                variables.admin = variables.fixtures.createUser(customerID=variables.customer, sysAdmin=true);
                variables.member = variables.fixtures.createUser(customerID=variables.customer, superAdmin=true);
                variables.module = variables.fixtures.createModule();
                variables.task = variables.fixtures.createScheduletask(moduleID=variables.module);
                variables.booking = variables.fixtures.createBooking(customerID=variables.customer, moduleID=variables.module, status="active",
                    startDate=dateFormat(now(),"yyyy-mm-dd"), endDate=dateFormat(dateAdd("d",2,now()),"yyyy-mm-dd"));
                application.objModules.syncCustomerScheduler(variables.customer);
                loginAs(variables.admin);
            });

            it("blocks access without changing bookings, invoices, prices or job history", () => {
                local.before = bookingSnapshot();
                local.jobSnapshot = jobs();
                setBlock(true);
                expect(application.objModuleBlocks.isBlocked(variables.customer, variables.module)).toBeTrue();
                expect(application.objRequestAccess.moduleAccess(variables.module)).toBeFalse();
                expect(application.objModules.shouldRunScheduler(variables.customer, variables.module)).toBeFalse();
                expect(bookingSnapshot()).toBe(local.before);
                expect(jobs().intJobID).toBe(local.jobSnapshot.intJobID);
                expect(jobs().dtmNextRun).toBe(local.jobSnapshot.dtmNextRun);
                setBlock(false);
                expect(application.objRequestAccess.moduleAccess(variables.module)).toBeTrue();
                expect(jobs().intJobID).toBe(local.jobSnapshot.intJobID);
                expect(bookingSnapshot()).toBe(local.before);
            });

            it("also blocks plan-included modules and does not let new bookings clear the block", () => {
                queryExecute(options={datasource:application.datasource}, params={id:{type:"integer",value:variables.booking}},
                    sql="DELETE FROM bookings WHERE intBookingID = :id");
                local.plan = variables.fixtures.createPlan([variables.module]);
                variables.fixtures.createBooking(customerID=variables.customer, planID=local.plan, status="free");
                setBlock(true);
                variables.fixtures.createBooking(customerID=variables.customer, moduleID=variables.module, status="free");
                application.objModules.syncAllSchedulers();
                expect(application.objRequestAccess.moduleAccess(variables.module)).toBeFalse();
                expect(application.objModules.shouldRunScheduler(variables.customer, variables.module)).toBeFalse();
                setBlock(false);
                expect(application.objRequestAccess.moduleAccess(variables.module)).toBeTrue();
            });

            it("cannot be changed by organization admins, support sessions or a stale platform flag", () => {
                loginAs(variables.member);
                expect(() => application.objModuleBlocks.setBlocked(variables.member.userID, variables.customer, variables.module, true)).toThrow("Saaster.ModuleBlock.Denied");
                loginAs(variables.admin);
                session.supportLogin = true;
                expect(() => setBlock(true)).toThrow("Saaster.ModuleBlock.Denied");
                structDelete(session,"supportLogin");
                expect(() => application.objModuleBlocks.setBlocked(variables.member.userID, variables.customer, variables.module, true)).toThrow("Saaster.ModuleBlock.Denied");
                queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:variables.admin.userID}},sql="UPDATE users SET blnSysAdmin = 0 WHERE intUserID = :id");
                expect(() => setBlock(true)).toThrow("Saaster.ModuleBlock.Denied");
            });

            it("requires a real customer, module and direct or plan booking", () => {
                expect(() => application.objModuleBlocks.setBlocked(variables.admin.userID, 0, variables.module, true)).toThrow("Saaster.ModuleBlock.Invalid");
                variables.unbooked = variables.fixtures.createModule();
                expect(() => application.objModuleBlocks.setBlocked(variables.admin.userID, variables.customer, variables.unbooked, true)).toThrow("Saaster.ModuleBlock.Invalid");
                expect(application.objModuleBlocks.forCustomer(variables.customer).recordCount).toBe(0);
            });

            it("is idempotent and remains scoped to the exact customer and module", () => {
                local.other = variables.fixtures.createCustomer(parentID=variables.customer);
                local.otherModule = variables.fixtures.createModule();
                setBlock(true); setBlock(true);
                expect(application.objModuleBlocks.forCustomer(variables.customer).recordCount).toBe(1);
                expect(application.objModuleBlocks.isBlocked(local.other, variables.module)).toBeFalse();
                expect(application.objModuleBlocks.isBlocked(variables.customer, local.otherModule)).toBeFalse();
                setBlock(false); setBlock(false);
                expect(application.objModuleBlocks.forCustomer(variables.customer).recordCount).toBe(0);
            });

            it("keeps blocked jobs unclaimable even after reconciliation", () => {
                queryExecute(options={datasource:application.datasource},params={customer:{type:"integer",value:variables.customer}},
                    sql="UPDATE scheduler_jobs SET dtmNextRun = '2000-01-01' WHERE intCustomerID = :customer");
                setBlock(true);
                application.objModules.syncCustomerScheduler(variables.customer);
                expect(jobs().recordCount).toBe(1);
                expect(new backend.core.com.scheduler().claimNextJob(5)).toBeEmpty();
                setBlock(false);
                expect(new backend.core.com.scheduler().claimNextJob(5).customerID).toBe(variables.customer);
            });

            it("allows a running job to finish while the block prevents later claims", () => {
                queryExecute(options={datasource:application.datasource},params={customer:{type:"integer",value:variables.customer}},
                    sql="UPDATE scheduler_jobs SET dtmNextRun = '2000-01-01' WHERE intCustomerID = :customer");
                local.scheduler = new backend.core.com.scheduler();
                local.job = local.scheduler.claimNextJob(5);
                setBlock(true);
                expect(local.scheduler.finishJob(local.job,true,1)).toBeTrue();
                expect(isDate(jobs().dtmLastRun)).toBeTrue();
                expect(local.scheduler.claimNextJob(5)).toBeEmpty();
            });

            it("does not restore expired access or extend the period when unblocked", () => {
                setBlock(true);
                queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:variables.booking},ends:{type:"date",value:dateAdd("d",-1,now())}},
                    sql="UPDATE bookings SET dteEndDate = :ends WHERE intBookingID = :id");
                local.before = bookingSnapshot();
                setBlock(false);
                loginAs(variables.member);
                expect(application.objRequestAccess.moduleAccess(variables.module)).toBeFalse();
                expect(jobs().recordCount).toBe(0);
                expect(bookingSnapshot()).toBe(local.before);
            });

            it("blocks unmapped module files as well as mapped myapp actions", () => {
                queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:variables.module}},
                    sql="UPDATE modules SET strTabPrefix = 'testbox_blocked' WHERE intModuleID = :id");
                setBlock(true);
                expect(application.objModuleBlocks.pathBlocked(variables.customer,"/backend/modules/testbox_blocked/handler/action.cfm")).toBeTrue();
                expect(application.objModuleBlocks.pathBlocked(variables.customer,"backend/modules/another/action.cfm")).toBeFalse();
                expect(application.objModuleBlocks.pathBlocked(variables.customer,"backend/core/views/customer/modules.cfm")).toBeFalse();
            });
        });
    }

    private void function setBlock(required boolean blocked) {
        application.objModuleBlocks.setBlocked(variables.admin.userID, variables.customer, variables.module, arguments.blocked);
    }

    private query function jobs() {
        return queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:variables.customer}},sql="SELECT * FROM scheduler_jobs WHERE intCustomerID = :id");
    }

    private string function bookingSnapshot() {
        return serializeJSON(queryExecute(options={datasource:application.datasource},params={id:{type:"integer",value:variables.customer}},sql="SELECT * FROM bookings WHERE intCustomerID = :id ORDER BY intBookingID"));
    }
}
