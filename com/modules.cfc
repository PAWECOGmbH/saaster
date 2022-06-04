component displayname="modules" output="false" {


    public any function init(numeric lngID, string language, numeric currencyID) {

        param name="variables.lngID" default=0;
        param name="variables.language" default="";
        param name="variables.currencyID" default=0;

        // Set variables by arguments
        if (structKeyExists(arguments, "lngID") and arguments.lngID gt 0) {
            variables.lngID = arguments.lngID;
            variables.language = application.objGlobal.getAnyLanguage(variables.lngID).iso;
        } else if (structKeyExists(arguments, "language")) {
            variables.language = arguments.language;
            variables.lngID = application.objGlobal.getAnyLanguage(variables.language).lngID;
        }
        if (structKeyExists(arguments, "currencyID") and arguments.currencyID gt 0) {
            variables.currencyID = arguments.currencyID;
        }

        // Set variables by default settings
        if (!len(variables.language)) {
            variables.language = application.objGlobal.getDefaultLanguage().iso;
        }
        if (variables.lngID eq 0) {
            variables.lngID = application.objGlobal.getDefaultLanguage().lngID;
        }
        if (variables.currencyID eq 0) {
            variables.currencyID = application.objGlobal.getDefaultCurrency().currencyID;
        }

        return this;

    }


    <!--- Get all modules --->
    public array function getAllModules(string except) {

        if (structKeyExists(arguments, "except") and listLen(arguments.except)) {
            local.exceptList = "AND intModuleID NOT IN (#arguments.except#)";
        } else {
            local.exceptList = "";
        }

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


    <!--- Get data of a module --->
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
                modules.blnBookable, modules.intPrio, modules.blnActive, modules.strSettingPath,
                currencies.strCurrencyISO, currencies.strCurrencySign,
                COALESCE(modules_prices.blnIsNet,0) as blnIsNet,
                COALESCE(modules_prices.decPriceMonthly,0) as decPriceMonthly,
                COALESCE(modules_prices.decPriceYearly,0) as decPriceYearly,
                COALESCE(modules_prices.decPriceOneTime,0) as decPriceOneTime,
                COALESCE(modules_prices.decVat,0) as decVat,
                COALESCE(modules_prices.intCurrencyID,0) as intCurrencyID,
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

                LEFT JOIN modules_prices ON 1=1
                AND modules.intModuleID = modules_prices.intModuleID

                LEFT JOIN currencies ON 1=1
                AND modules_prices.intCurrencyID = currencies.intCurrencyID
                AND currencies.intCurrencyID = :currencyID

                WHERE modules.intModuleID = :moduleID

            "
        )


        local.moduleStruct = structNew();

        if (local.qModule.recordCount) {

            local.moduleStruct['moduleID'] = local.qModule.intModuleID;
            local.moduleStruct['name'] = local.qModule.strModuleName;
            local.moduleStruct['short_description'] = local.qModule.strShortDescription;
            local.moduleStruct['description'] = local.qModule.strDescription;
            local.moduleStruct['table_prefix'] = local.qModule.strTabPrefix;
            local.moduleStruct['picture'] = local.qModule.strPicture;
            local.moduleStruct['bookable'] = local.qModule.blnBookable;
            local.moduleStruct['active'] = local.qModule.blnActive;
            local.moduleStruct['isNet'] = local.qModule.blnIsNet;
            local.moduleStruct['price_monthly'] = local.qModule.decPriceMonthly;
            local.moduleStruct['price_yearly'] = local.qModule.decPriceYearly;
            local.moduleStruct['price_onetime'] = local.qModule.decPriceOneTime;
            local.moduleStruct['vat'] = local.qModule.decVat;
            local.moduleStruct['vat_type'] = local.qModule.intVatType;
            local.moduleStruct['currencyID'] = local.qModule.intCurrencyID;
            local.moduleStruct['currency'] = local.qModule.strCurrencyISO;
            local.moduleStruct['settingPath'] = local.qModule.strSettingPath;
            local.moduleStruct['testDays'] = local.qModule.intNumTestDays;
            if (len(trim(local.qModule.strCurrencySign))) {
                local.moduleStruct['currencySign'] = local.qModule.strCurrencySign;
            } else {
                local.moduleStruct['currencySign'] = local.qModule.strCurrencyISO;
            }

            local.objPrices = new com.prices(
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
                "
            )

            local.planArray = arrayNew(1);

            if (local.qCheckPlans.recordCount) {

                local.planStruct = structNew();
                local.planStruct['planID'] = local.qCheckPlans.intPlanID;
                local.planStruct['name'] = local.qCheckPlans.strPlanName;
                arrayAppend(local.planArray, local.planStruct);

            }

            local.moduleStruct['includedInPlans'] = local.planArray;


            // Build the booking link

            // bookingLinkM: monthly
            // bookingLinkY: yearly
            // bookingLinkO: onetime
            // bookingLinkF: free

            local.objBook = new com.book();
            local.bookingStringM = local.objBook.init('module').createBookingLink(local.qModule.intModuleID, variables.lngID, variables.currencyID, "m", "module");
            local.moduleStruct['bookingLinkM'] = application.mainURL & "/book?module=" & local.bookingStringM;
            local.bookingStringY = local.objBook.init('module').createBookingLink(local.qModule.intModuleID, variables.lngID, variables.currencyID, "y", "module");
            local.moduleStruct['bookingLinkY'] = application.mainURL & "/book?module=" & local.bookingStringY;
            local.bookingStringO = local.objBook.init('module').createBookingLink(local.qModule.intModuleID, variables.lngID, variables.currencyID, "o", "module");
            local.moduleStruct['bookingLinkO'] = application.mainURL & "/book?module=" & local.bookingStringO;
            local.bookingStringF = local.objBook.init('module').createBookingLink(local.qModule.intModuleID, variables.lngID, variables.currencyID, "f", "module");
            local.moduleStruct['bookingLinkF'] = application.mainURL & "/book?module=" & local.bookingStringF;

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
                    customerID: {type: "numeric", value: arguments.customerID}
                },
                sql = "
                    SELECT intModuleID
                    FROM customer_bookings
                    WHERE intCustomerID = :customerID
                    AND intModuleID > 0
                "
            )

            if (local.qCurrentModules.recordCount) {

                loop query="local.qCurrentModules" {

                    local.moduleStruct = structNew();
                    local.moduleStruct['moduleID'] = local.qCurrentModules.intModuleID;
                    local.moduleStruct['moduleStatus'] = getModuleStatus(arguments.customerID, local.qCurrentModules.intModuleID);
                    local.moduleStruct['moduleData'] = getModuleData(local.qCurrentModules.intModuleID);
                    local.moduleStruct['includedInCurrentPlan'] = false;
                    arrayAppend(local.moduleArray, local.moduleStruct);

                }

            }


            // Append also all included modules of the booked plan
            local.objPlans = new com.plans(language=variables.language);
            local.bookedPlan = local.objPlans.getCurrentPlan(arguments.customerID);
            local.includedModules = local.objPlans.getModulesIncluded(local.bookedPlan.planID);

            if (isArray(local.includedModules.modulesIncluded) and arrayLen(local.includedModules.modulesIncluded)) {

                loop array=local.includedModules.modulesIncluded index="i" {

                    local.moduleStruct = structNew();
                    local.moduleStruct['moduleID'] = i.moduleID;
                    local.moduleStruct['moduleData'] = getModuleData(i.moduleID);
                    local.moduleStruct['includedInCurrentPlan'] = true;

                    local.statusStruct = structNew();
                    local.statusStruct['endDate'] = local.bookedPlan.endDate;
                    local.statusStruct['endTestDate'] = local.bookedPlan.endTestDate;
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
                    SELECT  intModuleID, blnPaused, strRecurring,
                            DATE_FORMAT(dtmStartDate, '%Y-%m-%d') as dtmStartDate,
                            DATE_FORMAT(dtmEndDate, '%Y-%m-%d') as dtmEndDate,
                            DATE_FORMAT(dtmEndTestDate, '%Y-%m-%d') as dtmEndTestDate
                    FROM customer_bookings
                    WHERE intModuleID = :moduleID
                    AND intCustomerID = :customerID
                "
            )

            if (local.qCurrentModules.recordCount) {

                local.moduleStruct['startDate'] = local.qCurrentModules.dtmStartDate;
                local.moduleStruct['endTestDate'] = local.qCurrentModules.dtmEndTestDate;
                local.moduleStruct['recurring'] = local.qCurrentModules.strRecurring;
                local.moduleStruct['endDate'] = "";

                // Is the plan paused?
                if (local.qCurrentModules.blnPaused eq 1) {

                    local.moduleStruct['status'] = 'paused';

                // Is a module or plan canceled?
                } else if (local.qCurrentModules.strRecurring eq "canceled") {

                    local.moduleStruct['status'] = 'canceled';

                } else {

                    // Is a test phase running?
                    if (isDate(local.qCurrentModules.dtmStartDate) and isDate(local.qCurrentModules.dtmEndTestDate)) {

                        // Is the test phase still valid? | YES
                        if (dateDiff("d", now(), local.qCurrentModules.dtmEndTestDate) gte 0) {

                            local.moduleStruct['endTestDate'] = local.qCurrentModules.dtmEndTestDate;
                            local.moduleStruct['status'] = 'test';

                        // NO
                        } else {

                            local.moduleStruct['endTestDate'] = local.qCurrentModules.dtmEndTestDate;
                            local.moduleStruct['status'] = 'expired';

                        }

                    } else {

                        // See if there is a free module running
                        if (!len(trim(local.qCurrentModules.dtmEndDate)) and !len(trim(local.qCurrentModules.dtmEndTestDate))) {

                            // Get module data
                            local.moduleData = getModuleData(arguments.moduleID);

                            if (local.moduleData.price_onetime gt 0) {
                                local.moduleStruct['status'] = 'onetime';
                            } else {
                                local.moduleStruct['status'] = 'free';
                            }

                        } else {

                            // Is a module running?
                            if (isDate(local.qCurrentModules.dtmEndDate)) {

                                local.moduleStruct['endDate'] = local.qCurrentModules.dtmEndDate;
                                local.moduleStruct['status'] = 'active';

                                // Still valid?
                                if (dateDiff("d", now(), local.qCurrentModules.dtmEndDate) lt 0) {

                                    local.moduleStruct['endDate'] = local.qCurrentModules.dtmEndDate;
                                    local.moduleStruct['status'] = 'expired';

                                }

                            }

                        }

                    }

                }

                local.objPlans = new com.plans(language=variables.language);
                structAppend(local.moduleStruct, local.objPlans.getPlanStatusAsText(local.moduleStruct));

            }

        }

        return local.moduleStruct;

    }


    // In this function we will delete all the users data out of a module (ex. after a cancellation)
    public void function deleteModuleData(required numeric customerID, required numeric moduleID) {

        // Make your queries!


    }




}