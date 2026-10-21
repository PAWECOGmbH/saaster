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
                modules.strRedirectPath, modules.intDurationDays,
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
            local.moduleStruct['durationDays'] = local.qModule.intDurationDays;
            local.moduleStruct['redirectPath'] = local.qModule.strRedirectPath;
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
                    ORDER BY dteStartDate, intBookingID
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


    /*
        Scheduler jobs (table scheduler_jobs, one row per scheduletask and customer).

        Whether a customer gets the scheduletasks of a module is read from the bookings,
        with the same rule as the access check in global.cfc::getSEF: the module is booked
        as "free", or today lies between start and end date of a booking - whatever the
        status. A canceled module therefore keeps its tasks until its end date, a waiting
        booking (cycle change) does not stop the current one. Modules included in a plan
        count through the plan booking.

        The functions reconcile instead of acting on a single status: they compute what
        should exist and add or remove jobs accordingly. Calling them again changes nothing.
    */


    // The scheduletasks a customer should have right now (query: intScheduletaskID, intModuleID, dtmStartTime, intIterationMinutes)
    public query function getDueScheduletasks(required numeric customerID) {

        return queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                today: {type: "date", value: dateFormat(now(), "yyyy-mm-dd")}
            },
            sql = "
                SELECT scheduletasks.intScheduletaskID, scheduletasks.intModuleID, scheduletasks.dtmStartTime, scheduletasks.intIterationMinutes
                FROM scheduletasks
                WHERE scheduletasks.intModuleID IN (
                    SELECT bookings.intModuleID
                    FROM bookings
                    WHERE bookings.intCustomerID = :customerID
                    AND bookings.intModuleID > 0
                    AND (
                        bookings.strStatus = 'free'
                        OR (DATE(bookings.dteStartDate) <= :today AND DATE(bookings.dteEndDate) >= :today)
                    )
                    UNION
                    SELECT plans_modules.intModuleID
                    FROM bookings
                    INNER JOIN plans_modules ON plans_modules.intPlanID = bookings.intPlanID
                    WHERE bookings.intCustomerID = :customerID
                    AND bookings.intPlanID > 0
                    AND (
                        bookings.strStatus = 'free'
                        OR (DATE(bookings.dteStartDate) <= :today AND DATE(bookings.dteEndDate) >= :today)
                    )
                )
                ORDER BY scheduletasks.intScheduletaskID
            "
        );

    }


    // Should the scheduletasks of this module run for this customer right now?
    public boolean function shouldRunScheduler(required numeric customerID, required numeric moduleID) {

        return listFind(valueList(getDueScheduletasks(arguments.customerID).intModuleID), arguments.moduleID) gt 0;

    }


    // Bring the jobs of one customer in line with the bookings. Returns { added, removed }.
    public struct function syncCustomerScheduler(required numeric customerID) {

        local.result = { "added": 0, "removed": 0 };

        if (arguments.customerID lte 0) {
            return local.result;
        }

        local.qDue = getDueScheduletasks(arguments.customerID);

        // Remove the jobs the customer should not have (any more)
        queryExecute(
            options = {datasource = application.datasource, result = "local.deleteResult"},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                dueIDs: {type: "numeric", value: local.qDue.recordCount ? valueList(local.qDue.intScheduletaskID) : 0, list: true}
            },
            sql = "
                DELETE FROM scheduler_jobs
                WHERE intCustomerID = :customerID
                AND intScheduletaskID NOT IN (:dueIDs)
            "
        );
        local.result.removed = local.deleteResult.recordCount;

        // Add the missing ones. Existing jobs keep their next and last run.
        loop query="local.qDue" {

            queryExecute(
                options = {datasource = application.datasource, result = "local.insertResult"},
                params = {
                    taskID: {type: "numeric", value: local.qDue.intScheduletaskID},
                    customerID: {type: "numeric", value: arguments.customerID},
                    nextRun: {type: "datetime", value: application.objSysadmin.calcNextRun(local.qDue.dtmStartTime, local.qDue.intIterationMinutes)}
                },
                sql = "
                    INSERT IGNORE INTO scheduler_jobs (intScheduletaskID, intCustomerID, dtmNextRun)
                    VALUES (:taskID, :customerID, :nextRun)
                "
            );
            local.result.added += local.insertResult.recordCount;

        }

        return local.result;

    }


    // Reconcile every customer who has a booking or a job (nightly repair and after new scheduletasks)
    public struct function syncAllSchedulers() {

        local.result = { "customers": 0, "added": 0, "removed": 0 };

        local.qCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT intCustomerID FROM bookings
                UNION
                SELECT intCustomerID FROM scheduler_jobs
            "
        );

        loop query="local.qCustomers" {
            local.sync = syncCustomerScheduler(local.qCustomers.intCustomerID);
            local.result.customers++;
            local.result.added += local.sync.added;
            local.result.removed += local.sync.removed;
        }

        return local.result;

    }


    // A scheduletask got a new start time or interval: recalculate the next run of all its jobs
    public void function rescheduleModuleTasks(required numeric moduleID) {

        local.qTasks = queryExecute(
            options = {datasource = application.datasource},
            params = {
                moduleID: {type: "numeric", value: arguments.moduleID}
            },
            sql = "
                SELECT intScheduletaskID, dtmStartTime, intIterationMinutes
                FROM scheduletasks
                WHERE intModuleID = :moduleID
            "
        );

        loop query="local.qTasks" {
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    taskID: {type: "numeric", value: local.qTasks.intScheduletaskID},
                    nextRun: {type: "datetime", value: application.objSysadmin.calcNextRun(local.qTasks.dtmStartTime, local.qTasks.intIterationMinutes)}
                },
                sql = "
                    UPDATE scheduler_jobs
                    SET dtmNextRun = :nextRun
                    WHERE intScheduletaskID = :taskID
                "
            );
        }

    }


    /*
        Kept for existing callers (core, myapp, modules). The status is no longer used:
        the jobs follow the bookings in the database, so the caller must have saved the
        booking change first - all callers do. With customerID 0 the module's tasks were
        edited and only the next runs are recalculated.
    */
    public boolean function distributeScheduler(required numeric moduleID, required numeric customerID, string status = "") {

        if (arguments.customerID gt 0) {
            syncCustomerScheduler(arguments.customerID);
        } else {
            rescheduleModuleTasks(arguments.moduleID);
        }

        return true;

    }


}