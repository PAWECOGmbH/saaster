component displayname="modules" output="false" {


    public any function init(numeric lngID, string language, numeric currencyID) {

        param name="variables.lngID" default=0;
        param name="variables.language" default="";
        param name="variables.currencyID" default=0;

        local.objCurrency = new backend.core.com.currency();

        // Set variables by arguments
        if (structKeyExists(arguments, "lngID") and arguments.lngID gt 0) {
            variables.lngID = arguments.lngID;
            variables.language = application.objLanguage.getAnyLanguage(variables.lngID).iso;
        } else if (structKeyExists(arguments, "language")) {
            variables.language = arguments.language;
            variables.lngID = application.objLanguage.getAnyLanguage(variables.language).lngID;
        }
        if (structKeyExists(arguments, "currencyID") and arguments.currencyID gt 0) {
            variables.currencyID = arguments.currencyID;
        }

        // Set variables by default settings
        if (!len(variables.language)) {
            variables.language = application.objLanguage.getDefaultLanguage().iso;
        }
        if (variables.lngID eq 0) {
            variables.lngID = application.objLanguage.getDefaultLanguage().lngID;
        }
        if (variables.currencyID eq 0) {
            variables.currencyID = local.objCurrency.getCurrency().id;
        }

        return this;

    }


    // Get all modules
    public array function getAllModules(string except) {

        local.exceptList = structKeyExists(arguments, "except") and listLen(arguments.except) ? "AND intModuleID NOT IN (#arguments.except#)" : "";

        local.qModule = queryExecute(
            options = {datasource = application.datasource},

            sql = "
                SELECT intModuleID
                FROM modules
                WHERE blnActive = 1
                #local.exceptList#
                ORDER BY intPrio
            "
        )

        local.moduleArray = arrayNew(1);
        local.moduleStruct = structNew();

        if (local.qModule.recordCount) {

            loop query= local.qModule {

                local.moduleStruct[local.qModule.currentRow] = getModuleData(local.qModule.intModuleID);
                arrayAppend(local.moduleArray, local.moduleStruct[local.qModule.currentRow]);

            }

        }

        return local.moduleArray;

    }


    // Get data of a module
    public struct function getModuleData(required numeric moduleID) {

        local.qModule = queryExecute(
            options = {datasource = application.datasource},
            params = {
                moduleID: {type: "numeric", value: arguments.moduleID},
                lngID: {type: "numeric", value: variables.lngID},
                currencyID: {type: "numeric", value: variables.currencyID}
            },
            sql = "
                SELECT modules.intModuleID, modules.strTabPrefix, modules.strPicture, modules.intNumTestDays,
                modules.blnBookable, modules.intPrio, modules.blnActive, modules.strSettingPath, modules.blnFree,
                currencies.strCurrencyISO, currencies.strCurrencySign, currencies.intCurrencyID,
                COALESCE(modules_prices.blnIsNet,0) as blnIsNet,
                COALESCE(modules_prices.decPriceMonthly,0) as decPriceMonthly,
                COALESCE(modules_prices.decPriceYearly,0) as decPriceYearly,
                COALESCE(modules_prices.decPriceOneTime,0) as decPriceOneTime,
                COALESCE(modules_prices.decVat,0) as decVat,
                COALESCE(modules_prices.intVatType,0) as intVatType,
                IF(
                    LENGTH(
                            (
                                SELECT strModuleName
                                FROM modules_trans
                                WHERE intModuleID = modules.intModuleID
                                AND intLanguageID = :lngID
                            )
                    ),
                    (
                        SELECT strModuleName
                        FROM modules_trans
                        WHERE intModuleID = modules.intModuleID
                        AND intLanguageID = :lngID
                    ),
                    modules.strModuleName
                ) as strModuleName,
                IF(
                    LENGTH(
                            (
                                SELECT strShortDescription
                                FROM modules_trans
                                WHERE intModuleID = modules.intModuleID
                                AND intLanguageID = :lngID
                            )
                    ),
                    (
                        SELECT strShortDescription
                        FROM modules_trans
                        WHERE intModuleID = modules.intModuleID
                        AND intLanguageID = :lngID
                    ),
                    modules.strShortDescription
                ) as strShortDescription,
                IF(
                    LENGTH(
                            (
                                SELECT strDescription
                                FROM modules_trans
                                WHERE intModuleID = modules.intModuleID
                                AND intLanguageID = :lngID
                            )
                    ),
                    (
                        SELECT strDescription
                        FROM modules_trans
                        WHERE intModuleID = modules.intModuleID
                        AND intLanguageID = :lngID
                    ),
                    modules.strDescription
                ) as strDescription

                FROM modules

                INNER JOIN modules_prices ON 1=1
                AND modules.intModuleID = modules_prices.intModuleID

                INNER JOIN currencies ON 1=1
                AND modules_prices.intCurrencyID = currencies.intCurrencyID
                AND modules_prices.intCurrencyID = :currencyID

                WHERE modules.intModuleID = :moduleID

            "
        )


        local.moduleStruct = structNew();

        if (local.qModule.recordCount) {

            local.moduleStruct['moduleID'] = local.qModule.intModuleID;
            local.moduleStruct['name'] = local.qModule.strModuleName;
            local.moduleStruct['shortdescription'] = local.qModule.strShortDescription;
            local.moduleStruct['description'] = local.qModule.strDescription;
            local.moduleStruct['table_prefix'] = local.qModule.strTabPrefix;
            local.moduleStruct['itsFree'] = local.qModule.blnFree;
            local.moduleStruct['picture'] = local.qModule.strPicture;
            local.moduleStruct['bookable'] = local.qModule.blnBookable;
            local.moduleStruct['active'] = local.qModule.blnActive;
            local.moduleStruct['isNet'] = local.qModule.blnIsNet;
            local.moduleStruct['priceMonthly'] = local.qModule.decPriceMonthly;
            local.moduleStruct['priceYearly'] = local.qModule.decPriceYearly;
            local.moduleStruct['priceOnetime'] = local.qModule.decPriceOneTime;
            local.moduleStruct['vat'] = local.qModule.decVat;
            local.moduleStruct['vatType'] = local.qModule.intVatType;
            local.moduleStruct['currencyID'] = local.qModule.intCurrencyID;
            local.moduleStruct['currency'] = local.qModule.strCurrencyISO;
            local.moduleStruct['settingPath'] = local.qModule.strSettingPath;
            local.moduleStruct['testDays'] = local.qModule.intNumTestDays;
            if (len(trim(local.qModule.strCurrencySign))) {
                local.moduleStruct['currencySign'] = local.qModule.strCurrencySign;
            } else {
                local.moduleStruct['currencySign'] = local.qModule.strCurrencyISO;
            }

            local.objPrices = new backend.core.com.prices(
                vat=local.qModule.decVat,
                vat_type=local.qModule.intVatType,
                isnet=local.qModule.blnIsNet,
                language=variables.language,
                currency=local.qModule.strCurrencyISO
            );

            local.moduleStruct['vat_text_monthly'] = local.objPrices.getPriceData(price=local.qModule.decPriceMonthly).vat_text;
            local.moduleStruct['vat_text_yearly'] = local.objPrices.getPriceData(price=local.qModule.decPriceYearly).vat_text;
            local.moduleStruct['vat_text_onetime'] = local.objPrices.getPriceData(price=local.qModule.decPriceOneTime).vat_text;
            local.moduleStruct['priceMonthlyAfterVAT'] = local.objPrices.getPriceData(price=local.qModule.decPriceMonthly).priceAfterVAT;
            local.moduleStruct['priceYearlyAfterVAT'] = local.objPrices.getPriceData(price=local.qModule.decPriceYearly).priceAfterVAT;
            local.moduleStruct['priceOneTimeAfterVAT'] = local.objPrices.getPriceData(price=local.qModule.decPriceOneTime).priceAfterVAT;

            // Is the module included in plans?
            local.qCheckPlans = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    moduleID: {type: "numeric", value: local.qModule.intModuleID},
                    lngID: {type: "numeric", value: variables.lngID},
                },
                sql = "
                    SELECT plans_modules.intPlanID,
                    (
                        IF
                            (
                                LENGTH(
                                    (
                                        SELECT strPlanName
                                        FROM plans_trans
                                        WHERE intPlanID = plans.intPlanID
                                        AND intLanguageID = :lngID
                                    )
                                ),
                                (
                                    SELECT strPlanName
                                    FROM plans_trans
                                    WHERE intPlanID = plans.intPlanID
                                    AND intLanguageID = :lngID
                                ),
                                plans.strPlanName
                            )
                    ) as strPlanName
                    FROM plans_modules INNER JOIN plans ON plans_modules.intPlanID = plans.intPlanID
                    WHERE plans_modules.intModuleID = :moduleID
                    ORDER BY plans.intPrio
                "
            )

            local.planArray = arrayNew(1);

            loop query="local.qCheckPlans" {

                local.planStruct = structNew();
                local.planStruct['planID'] = local.qCheckPlans.intPlanID;
                local.planStruct['name'] = local.qCheckPlans.strPlanName;
                arrayAppend(local.planArray, local.planStruct);

            }

            local.moduleStruct['includedInPlans'] = local.planArray;



            // Build the booking link
            // **********************

            // bookingLinkM: monthly
            // bookingLinkY: yearly
            // bookingLinkO: onetime

            local.objBook = new backend.core.com.book();
            local.bookingStringM = local.objBook.init('module').createBookingLink(local.qModule.intModuleID, variables.lngID, variables.currencyID, "monthly", "module");
            local.moduleStruct['bookingLinkM'] = application.mainURL & "/book?module=" & local.bookingStringM;
            local.bookingStringY = local.objBook.init('module').createBookingLink(local.qModule.intModuleID, variables.lngID, variables.currencyID, "yearly", "module");
            local.moduleStruct['bookingLinkY'] = application.mainURL & "/book?module=" & local.bookingStringY;
            local.bookingStringO = local.objBook.init('module').createBookingLink(local.qModule.intModuleID, variables.lngID, variables.currencyID, "onetime", "module");
            local.moduleStruct['bookingLinkO'] = application.mainURL & "/book?module=" & local.bookingStringO;

        }

        return local.moduleStruct;

    }




    public array function getBookedModules(required numeric customerID) {

        local.moduleArray = arrayNew(1);
        local.moduleList = "";

        if (arguments.customerID gt 0) {

            local.qCurrentModules = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID},
                    utcDate: {type: "date", value: dateFormat(now(), "yyyy-mm-dd")}
                },
                sql = "
                    SELECT intModuleID,
                    (
                        SELECT intInvoiceID
                        FROM invoices
                        WHERE intBookingID = bookings.intBookingID
                        ORDER BY intInvoiceID DESC
                        LIMIT 1
                    ) as invoiceID
                    FROM bookings
                    WHERE bookings.intCustomerID = :customerID
                    AND bookings.intModuleID > 0
                    AND ((DATE(bookings.dteStartDate) <= DATE(:utcDate)
                    AND DATE(bookings.dteEndDate) >= DATE(:utcDate))
                    OR bookings.strRecurring = 'test')
                    ORDER BY bookings.dteStartDate
                "
            )

            if (local.qCurrentModules.recordCount) {

                loop query="local.qCurrentModules" {

                    local.moduleStruct = structNew();
                    local.moduleStruct['moduleID'] = local.qCurrentModules.intModuleID;
                    local.moduleStruct['invoiceID'] = local.qCurrentModules.invoiceID;
                    local.moduleStruct['moduleStatus'] = getModuleStatus(arguments.customerID, local.qCurrentModules.intModuleID);
                    local.moduleStruct['moduleData'] = getModuleData(local.qCurrentModules.intModuleID);
                    local.moduleStruct['includedInCurrentPlan'] = false;
                    arrayAppend(local.moduleArray, local.moduleStruct);

                }

            }


            // Append also all included modules of the booked plan
            local.objPlans = new backend.core.com.plans(language=variables.language);
            local.bookedPlan = local.objPlans.getCurrentPlan(arguments.customerID);
            local.includedModules = local.objPlans.getModulesIncluded(local.bookedPlan.planID);

            if (isArray(local.includedModules.modulesIncluded) and arrayLen(local.includedModules.modulesIncluded)) {

                loop array=local.includedModules.modulesIncluded index="i" {

                    // Only insert module that are not already booked by the customer
                    local.qHasModule = queryExecute (
                        options = {datasource = application.datasource},
                        params = {
                            customerID: {type: "numeric", value: arguments.customerID},
                            moduleID: {type: "numeric", value: i.moduleID}
                        },
                        sql = "
                            SELECT intModuleID
                            FROM bookings
                            WHERE intCustomerID = :customerID
                            AND intModuleID = :moduleID
                            AND (strStatus = 'active'
                            OR strStatus = 'test')
                        "
                    )

                    if (!qHasModule.recordCount) {

                        local.moduleStruct = structNew();
                        local.moduleStruct['moduleID'] = i.moduleID;
                        local.moduleStruct['moduleData'] = getModuleData(i.moduleID);
                        local.moduleStruct['includedInCurrentPlan'] = true;

                        local.statusStruct = structNew();
                        local.statusStruct['endDate'] = local.bookedPlan.endDate;
                        local.statusStruct['recurring'] = local.bookedPlan.recurring;
                        local.statusStruct['startDate'] = local.bookedPlan.startDate;
                        local.statusStruct['status'] = local.bookedPlan.status;

                        local.statusText = local.objPlans.getPlanStatusAsText(local.bookedPlan);
                        local.statusStruct['statusText'] = local.statusText.statusText;
                        local.statusStruct['statusTitle'] = local.statusText.statusTitle;
                        local.statusStruct['fontColor'] = local.statusText.fontColor;

                        local.moduleStruct['moduleStatus'] = local.statusStruct;

                        arrayAppend(local.moduleArray, local.moduleStruct);

                    }

                }

            }

        }

        return local.moduleArray;

    }


    public struct function getModuleStatus(required numeric customerID, required numeric moduleID) {

        local.moduleStruct = structNew();

        if (arguments.customerID gt 0 and arguments.moduleID gt 0) {

            local.qCurrentModules = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID},
                    moduleID: {type: "numeric", value: arguments.moduleID}
                },
                sql = "
                    SELECT intBookingID, strRecurring, dteStartDate, dteEndDate, strStatus, intModuleID
                    FROM bookings
                    WHERE intModuleID = :moduleID
                    AND intCustomerID = :customerID
                "
            )


            // We must loop because there could be more than only one entry, but max. two (waiting)
            loop query=local.qCurrentModules {

                // The first entry is the current module
                if (local.qCurrentModules.currentrow eq 1) {

                    local.moduleStruct['bookingID'] = local.qCurrentModules.intBookingID;
                    local.moduleStruct['startDate'] = local.qCurrentModules.dteStartDate;
                    local.moduleStruct['endDate'] = local.qCurrentModules.dteEndDate;
                    local.moduleStruct['recurring'] = local.qCurrentModules.strRecurring;
                    local.moduleStruct['status'] = local.qCurrentModules.strStatus;

                    local.objPlans = new backend.core.com.plans(language=variables.language);
                    structAppend(local.moduleStruct, local.objPlans.getPlanStatusAsText(local.moduleStruct));

                }

                // If we get more than one entry, there must be another module after the expiration
                if (local.qCurrentModules.currentrow eq 2) {

                    local.nextModule = structNew();
                    local.nextModule['startDate'] = dateFormat(local.qCurrentModules.dteStartDate, 'yyyy-mm-dd');
                    local.nextModule['endDate'] = dateFormat(local.qCurrentModules.dteEndDate, 'yyyy-mm-dd');
                    local.nextModule['recurring'] = local.qCurrentModules.strRecurring;
                    local.nextModule['status'] = local.qCurrentModules.strStatus;
                    local.moduleStruct['nextModule'] = local.nextModule;

                }

            }

        }

        return local.moduleStruct;

    }


    // Distribute the booking of a module in the scheduler
    public boolean function distributeScheduler(required numeric moduleID, required numeric customerID, required string status) {

        // Initialise variables
        local.targetTable = "";
        local.schedulerID = 0;
        local.whatsToDo = "";

        // Act according the status
        if (arguments.status eq "test" or arguments.status eq "free" or arguments.status eq "active") {
            local.whatsToDo = "run";
        } else {
            local.whatsToDo = "stop";
        }

        // Get scheduletask data
        local.qGetScheduleTask = queryExecute (
            options = {datasource = application.datasource},
            params = {
                moduleID: {type: "numeric", value: arguments.moduleID}
            },
            sql = "
                SELECT intScheduletaskID, intIterationMinutes, dtmStartTime
                FROM scheduletasks
                WHERE intModuleID = :moduleID
            "
        )

        if (local.qGetScheduleTask.recordCount) {

            // If the customerID is gt 0, we need to delete or to add
            if (arguments.customerID gt 0) {

                loop query="local.qGetScheduleTask" {

                    // We need to delete the value
                    if (local.whatsToDo eq "stop") {

                        loop from="1" to="20" index="local.i" {

                            local.tableName = "scheduler_#numberFormat(local.i, '00')#"; // Generates table names such as scheduler_01, scheduler_02, etc.

                            queryExecute (
                                options = {datasource = application.datasource},
                                params = {
                                    schedID: {type: "numeric", value: local.qGetScheduleTask.intScheduletaskID},
                                    customerID: {type: "numeric", value: arguments.customerID}
                                },
                                sql = "
                                    DELETE FROM #local.tableName#
                                    WHERE intScheduletaskID = :schedID
                                    AND intCustomerID = :customerID
                                "
                            )

                        }

                    }

                    // We need to insert the value
                    if (local.whatsToDo eq "run") {

                        // Initialize variables to track the table with the fewest records
                        local.minRecords = 99999999;
                        local.targetTable;
                        local.sqlCount;

                        // Generate the SQL for counting entries in each table and combine them using UNION
                        loop from="1" to="20" index="local.i" {

                            local.tableName = "scheduler_#numberFormat(local.i, '00')#"; // Generates table names such as scheduler_01, scheduler_02, etc.

                            if (local.i gt 1) {
                                local.sqlCount &= " UNION ALL ";
                            }

                            local.sqlCount &= "SELECT '" & local.tableName & "' AS tableName, COUNT(*) AS thisCount FROM " & local.tableName;

                            // Execute the combined query
                            local.qCount = queryExecute(sql=local.sqlCount, options={datasource: application.datasource});

                            // Iterate over the results to find the table with the fewest entries
                            loop from="1" to="#local.qCount.recordCount#" index="local.j" {
                                if (local.j eq 1 or local.qCount.thisCount[local.j] < local.minRecords) {
                                    local.minRecords = local.qCount.thisCount[local.j];
                                    local.targetTable = local.qCount.tableName[local.j];
                                }
                            }

                        }

                        // Now we have found the table with the fewest entries, so we insert the data record there
                        if (len(trim(local.targetTable))) {

                            // Calculate next run
                            local.nextRun = application.objSysadmin.calcNextRun(local.qGetScheduleTask.dtmStartTime, local.qGetScheduleTask.intIterationMinutes);

                            queryExecute (
                                options = {datasource = application.datasource, result="checkInsert"},
                                params = {
                                    schedID: {type: "numeric", value: local.qGetScheduleTask.intScheduletaskID},
                                    customerID: {type: "numeric", value: arguments.customerID},
                                    nextRun: {type: "datetime", value: local.nextRun}
                                },
                                sql = "
                                    INSERT INTO #local.targetTable# (intScheduletaskID, intCustomerID, dtmLastRun, dtmNextRun)
                                    SELECT :schedID, :customerID, NULL, :nextRun
                                    FROM DUAL
                                    WHERE NOT EXISTS (
                                        SELECT 1
                                        FROM #local.targetTable#
                                        WHERE intScheduletaskID = :schedID AND intCustomerID = :customerID
                                    )
                                    LIMIT 1
                                "
                            )

                            // Maybe we have to update
                            if (!checkInsert.recordCount) {

                                queryExecute (
                                    options = {datasource = application.datasource},
                                    params = {
                                        schedID: {type: "numeric", value: local.qGetScheduleTask.intScheduletaskID},
                                        customerID: {type: "numeric", value: arguments.customerID},
                                        nextRun: {type: "datetime", value: local.nextRun}
                                    },
                                    sql = "
                                        UPDATE #local.targetTable#
                                        SET dtmNextRun = :nextRun
                                        WHERE intScheduletaskID = :schedID AND intCustomerID = :customerID
                                    "
                                )

                            }

                        }

                    }

                }



            // If the customerID is 0, we need to update
            } else {

                // Calculate next run
                local.nextRun = application.objSysadmin.calcNextRun(local.qGetScheduleTask.dtmStartTime, local.qGetScheduleTask.intIterationMinutes);

                loop from="1" to="20" index="local.i" {

                    local.tableName = "scheduler_#numberFormat(local.i, '00')#"; // Generates table names such as scheduler_01, scheduler_02, etc.

                    queryExecute (
                        options = {datasource = application.datasource},
                        params = {
                            schedID: {type: "numeric", value: local.qGetScheduleTask.intScheduletaskID},
                            moduleID: {type: "numeric", value: arguments.moduleID},
                            nextRun: {type: "datetime", value: local.nextRun}
                        },
                        sql = "
                            UPDATE #local.tableName# sch
                            INNER JOIN scheduletasks ON sch.intScheduletaskID = scheduletasks.intScheduletaskID
                            SET sch.dtmNextRun = :nextRun
                            WHERE scheduletasks.intModuleID = :moduleID
                        "
                    )

                }

            }

        }

        return true;

    }


}