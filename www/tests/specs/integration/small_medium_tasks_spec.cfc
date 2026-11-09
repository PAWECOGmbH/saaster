component extends="tests.support.integration_spec" {

    function run() {
        describe("Localized frontend links", () => {
            it("uses a translated mapping, falls back to the default and follows a language change", () => {
                local.slug = "testbox-" & lCase(createUUID());
                local.path = "templates/" & local.slug & ".cfm";
                transaction {
                    try {
                        queryExecute(
                            options={datasource=application.datasource, result="local.inserted"},
                            params={slug:{type:"varchar",value:local.slug},path:{type:"varchar",value:local.path}},
                            sql="INSERT INTO frontend_mappings (strMapping, strPath) VALUES (:slug, :path)"
                        );
                        queryExecute(
                            options={datasource=application.datasource},
                            params={id:{type:"integer",value:local.inserted.generatedKey},slug:{type:"varchar",value:"de/" & local.slug}},
                            sql="INSERT INTO frontend_mappings_trans (intFrontendMappingsID, strMapping, intLanguageID)
                                SELECT :id, :slug, intLanguageID FROM languages WHERE strLanguageISO = 'de'"
                        );
                        structDelete(request, "frontendSlugs");
                        expect(application.objGlobal.getLink(local.path, "de")).toBe(application.mainURL & "/de/" & local.slug);
                        expect(application.objGlobal.getLink(local.path, "en")).toBe(application.mainURL & "/" & local.slug);
                        expect(application.objGlobal.getLink(local.path, "de")).toBe(application.mainURL & "/de/" & local.slug);
                    } finally {
                        transaction action="rollback";
                        structDelete(request, "frontendSlugs");
                    }
                }
            });
        });

        describe("Invoice period dates", () => {
            it("uses the document language while leaving the viewer's locale unchanged", () => {
                local.originalLocale = getLocale();
                try {
                    setLocale("english (united states)");
                    local.viewerLocale = getLocale();
                    local.invoices = new backend.core.com.invoices();
                    local.value = createDate(2026, 11, 6);
                    expect(local.invoices.formatDocumentDate(local.value, "de")).toBe("06.11.2026");
                    expect(local.invoices.formatDocumentDate(local.value, "en")).toBe("Nov 6, 2026");
                    expect(getLocale()).toBe(local.viewerLocale);
                } finally {
                    setLocale(local.originalLocale);
                }
            });
        });

        describe("Search across retained log files", () => {
            beforeEach(() => {
                variables.logType = "testbox_" & replace(createUUID(), "-", "", "all");
                variables.logRoot = expandPath("/logs/" & variables.logType);
                directoryCreate(variables.logRoot & "/2026-10/01", true);
                directoryCreate(variables.logRoot & "/2026-11/06", true);
                fileWrite(variables.logRoot & "/2026-10/01/info.log", "Old customer Invoice 123" & chr(10));
                fileWrite(variables.logRoot & "/2026-11/06/error.log", "Failed INVOICE 123 [literal.*]" & chr(10));
                fileWrite(variables.logRoot & "/2026-11/06/info.log", "Other customer");
            });
            afterEach(() => {
                directoryDelete(variables.logRoot, true);
            });
            it("finds case-insensitive literal matches across dates and combines the filters", () => {
                local.logs = new backend.core.com.log();
                expect(local.logs.getLogs(type=variables.logType, search="invoice 123").recordCount).toBe(2);
                expect(local.logs.getLogs(type=variables.logType, search="invoice 123", date="2026-11-06").recordCount).toBe(1);
                expect(local.logs.getLogs(type=variables.logType, search="invoice 123", level="info").recordCount).toBe(1);
                expect(local.logs.getLogs(type=variables.logType, search="literal.*").recordCount).toBe(1);
                expect(local.logs.getLogs(type=variables.logType, search="not present").recordCount).toBe(0);
                expect(local.logs.getLogs(type=variables.logType & "_missing").recordCount).toBe(0);
                expect(() => local.logs.getLogs(type="../config")).toThrow();
            });
        });

        describe("Annual plan price display", () => {
            it("changes only the displayed monthly equivalent and labels yearly billing", () => {
                local.planID = variables.fixtures.createPlan();
                local.currencyID = new backend.core.com.currency().getCurrency().id;
                queryExecute(
                    options={datasource=application.datasource},
                    params={plan:{type:"integer",value:local.planID},currency:{type:"integer",value:local.currencyID}},
                    sql="INSERT INTO plan_prices (intPlanID, intCurrencyID, decPriceMonthly, decPriceYearly, decVat)
                        VALUES (:plan, :currency, 15, 120, 0)"
                );
                local.original = { setting:application.objSettings.getSetting("settingYearlyPricePerMonth"),
                    group:url.g ?: "", customer:session.customer_id ?: 0 };
                try {
                    url.g = queryExecute(options={datasource=application.datasource},
                        params={id:{type:"integer",value:local.planID}},
                        sql="SELECT intPlanGroupID FROM plans WHERE intPlanID = :id").intPlanGroupID;
                    session.customer_id = 0;
                    application.systemSettingStruct.settingYearlyPricePerMonth = "0";
                    local.annual = application.objCoreUtil.retrievePlans()[1];
                    application.systemSettingStruct.settingYearlyPricePerMonth = "1";
                    local.monthly = application.objCoreUtil.retrievePlans()[1];
                    expect(local.annual.dynPrice).toInclude('>120</span>');
                    expect(local.monthly.dynPrice).toInclude('>10.00</span>');
                    expect(local.monthly.priceYearly).toBe(120);
                    expect(local.monthly.priceMonthly).toBe(15);
                    expect(local.monthly.dynBillingNotice).toInclude(application.objLanguage.getTrans("txtBilledYearly"));
                    expect(new backend.core.com.book().decryptBookingLink(listLast(local.monthly.bookingLinkY, "=")).recurring).toBe("yearly");
                } finally {
                    application.systemSettingStruct.settingYearlyPricePerMonth = local.original.setting;
                    session.customer_id = local.original.customer;
                    if (len(local.original.group)) url.g = local.original.group; else structDelete(url, "g");
                }
            });
        });

        describe("Customer tabs", () => {
            beforeEach(() => {
                variables.customerID = variables.fixtures.createCustomer(companyName="Lazy tab customer");
                variables.admin = variables.fixtures.createUser(customerID=variables.customerID, sysAdmin=true, superAdmin=true);
                variables.reader = variables.fixtures.createUser(customerID=variables.customerID);
                variables.fixtures.createModule("Lazy module");
                variables.fixtures.createPlan();
            });
            it("renders the initial customer view with placeholders for expensive tabs", () => {
                local.response = renderCustomer("page", variables.admin.userID);
                expect(local.response.statusCode).toInclude("200");
                expect(local.response.fileContent).toInclude('data-customer-tab="invoices"');
                expect(local.response.fileContent).toInclude('data-customer-tab="plans"');
                expect(local.response.fileContent).toInclude('data-customer-tab="modules"');
                expect(local.response.fileContent).notToInclude("Lazy module");
            });
            it("loads each tab for a sysadmin and rejects a regular user", () => {
                loop list="invoices,plans,modules" item="local.tab" {
                    local.response = renderCustomer("tab", variables.admin.userID, local.tab);
                    expect(local.response.statusCode).toInclude("200", local.response.fileContent);
                    expect(local.response.fileContent).notToInclude("lucee.runtime");
                }
                expect(renderCustomer("tab", variables.reader.userID, "invoices").statusCode).toInclude("403");
                expect(renderCustomer("tab", variables.admin.userID, "../../config").statusCode).toInclude("400");
            });
        });
    }

    private struct function renderCustomer(required string view, required numeric userID, string tab="") {
        cfhttp(url="http://127.0.0.1/tests/support/customer_tab_probe.cfm?view=" & arguments.view
            & "&userID=" & arguments.userID & "&customerID=" & variables.customerID
            & "&tab=" & urlEncodedFormat(arguments.tab), method="get", timeout=30, result="local.response");
        return local.response;
    }
}
