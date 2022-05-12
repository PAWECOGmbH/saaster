component displayname="modules" output="false" {


    <!--- Get data of a module --->
    public struct function getModuleData(required numeric moduleID, numeric lngID, numeric currencyID) {

        if (structKeyExists(arguments, "moduleID") and arguments.moduleID gt 0) {

            if (structKeyExists(arguments, "lngID") and arguments.lngID gt 0) {
                local.lngID = arguments.lngID;
                local.language = application.objGlobal.getAnyLanguage(local.lngID).iso;
            } else {
                local.lngID = application.objGlobal.getDefaultLanguage().lngID;
                local.language = application.objGlobal.getDefaultLanguage().iso;
            }
            if (structKeyExists(arguments, "currencyID") and arguments.currencyID gt 0) {
                local.currencyID = arguments.currencyID;
            } else {
                local.currencyID = application.objGlobal.getDefaultCurrency().currencyID;
            }

            local.qModule = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    moduleID: {type: "numeric", value: arguments.moduleID},
                    lngID: {type: "numeric", value: local.lngID},
                    currencyID: {type: "numeric", value: local.currencyID}
                },
                sql = "
                    SELECT modules.intModuleID, modules.strTabPrefix, modules.strPicture,
                    modules.blnBookable, modules.intPrio, modules.blnActive,
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

                    INNER JOIN currencies ON 1=1
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
                if (len(trim(local.qModule.strCurrencySign))) {
                    local.moduleStruct['currencySign'] = local.qModule.strCurrencySign;
                } else {
                    local.moduleStruct['currencySign'] = local.qModule.strCurrencyISO;
                }
            }

            local.objPrices = new com.prices();

            local.moduleStruct['vat_text_monthly'] = local.objPrices.getPriceData
                (
                    price=local.qModule.decPriceMonthly,
                    vat=local.qModule.decVat,
                    vat_type=local.qModule.intVatType,
                    isnet=local.qModule.blnIsNet,
                    language=local.language,
                    currency=local.qModule.strCurrencyISO
                ).vat_text;

            local.moduleStruct['vat_text_yearly'] = local.objPrices.getPriceData
                (
                    price=local.qModule.decPriceYearly,
                    vat=local.qModule.decVat,
                    vat_type=local.qModule.intVatType,
                    isnet=local.qModule.blnIsNet,
                    language=local.language,
                    currency=local.qModule.strCurrencyISO
                ).vat_text;

            local.moduleStruct['vat_text_onetime'] = local.objPrices.getPriceData
                (
                    price=local.qModule.decPriceOneTime,
                    vat=local.qModule.decVat,
                    vat_type=local.qModule.intVatType,
                    isnet=local.qModule.blnIsNet,
                    language=local.language,
                    currency=local.qModule.strCurrencyISO
                ).vat_text;

            local.moduleStruct['priceMonthlyAfterVAT'] = local.objPrices.getPriceData
                (
                    price=local.qModule.decPriceMonthly,
                    vat=local.qModule.decVat,
                    vat_type=local.qModule.intVatType,
                    isnet=local.qModule.blnIsNet,
                    language=local.language,
                    currency=local.qModule.strCurrencyISO
                ).priceAfterVAT;

            local.moduleStruct['priceYearlyAfterVAT'] = local.objPrices.getPriceData
                (
                    price=local.qModule.decPriceYearly,
                    vat=local.qModule.decVat,
                    vat_type=local.qModule.intVatType,
                    isnet=local.qModule.blnIsNet,
                    language=local.language,
                    currency=local.qModule.strCurrencyISO
                ).priceAfterVAT;

            local.moduleStruct['priceOneTimeAfterVAT'] = local.objPrices.getPriceData
                (
                    price=local.qModule.decPriceOneTime,
                    vat=local.qModule.decVat,
                    vat_type=local.qModule.intVatType,
                    isnet=local.qModule.blnIsNet,
                    language=local.language,
                    currency=local.qModule.strCurrencyISO
                ).priceAfterVAT;


            // Building the booking link
            if (local.qModule.decPriceMonthly gt 0 or local.qModule.decPriceOneTime gt 0) {
                local.objBook = new com.book();
                local.bookingStringM = local.objBook.createBookingLink(local.qModule.intModuleID, local.lngID, local.currencyID, "m", "module");
                local.moduleStruct['bookingLinkM'] = application.mainURL & "/book?module=" & local.bookingStringM;
                local.bookingStringY = local.objBook.createBookingLink(local.qModule.intModuleID, local.lngID, local.currencyID, "y", "module");
                local.moduleStruct['bookingLinkY'] = application.mainURL & "/book?module=" & local.bookingStringY;
                local.bookingString = local.objBook.createBookingLink(local.qModule.intModuleID, local.lngID, local.currencyID, "", "module");
                local.moduleStruct['bookingLink'] = application.mainURL & "/book?module=" & local.bookingString;
            }


            return local.moduleStruct;


        }

    }


    <!--- Get all active modules --->
    public array function getAllModules(numeric lngID, numeric currencyID) {

        if (structKeyExists(arguments, "lngID") and arguments.lngID gt 0) {
            local.lngID = arguments.lngID;
        } else {
            local.lngID = application.objGlobal.getDefaultLanguage().lngID;
        }
        if (structKeyExists(arguments, "currencyID") and arguments.currencyID gt 0) {
            local.currencyID = arguments.currencyID;
        } else {
            local.currencyID = application.objGlobal.getDefaultCurrency().currencyID;
        }

        local.qModule = queryExecute(
            options = {datasource = application.datasource},
            params = {
                lngID: {type: "numeric", value: local.lngID},
                currID: {type: "numeric", value: local.currencyID}
            },
            sql = "
                SELECT intModuleID
                FROM modules
                ORDER BY intPrio
            "
        )

        local.moduleArray = arrayNew(1);
        local.moduleStruct = structNew();

        if (local.qModule.recordCount) {

            loop query= local.qModule {

                local.moduleStruct[local.qModule.currentRow] = getModuleData(local.qModule.intModuleID, local.lngID);
                arrayAppend(local.moduleArray, local.moduleStruct[local.qModule.currentRow]);

            }

        }

        return local.moduleArray;

    }



    public struct function getCurrentModules(required numeric customerID, string language) {

        if (arguments.customerID gt 0) {

            if (structKeyExists(arguments, "language")) {
                local.qLanguage = queryExecute (
                    options = {datasource = application.datasource},
                    params = {
                        language: {type: "varchar", value: arguments.language}
                    },
                    sql = "
                        SELECT intLanguageID
                        FROM languages
                        WHERE strLanguageISO = :language
                    "
                )
                if (local.qLanguage.recordCount) {
                    local.lngID = local.qLanguage.intLanguageID;
                } else {
                    local.lngID = application.objGlobal.getDefaultLanguage().lngID;
                }
            } else {
                local.lngID = application.objGlobal.getDefaultLanguage().lngID;
            }

            local.moduleArray = arrayNew(1);
            local.moduleStruct = structNew();

            local.qCurrentModules = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID}
                },
                sql = "
                    SELECT  customer_booking.intModuleID, customer_booking.dtmStartDate, customer_booking.dtmEndDate,
                            customer_booking.blnPaused, customer_booking.dtmEndTestDate, customer_booking.strRecurring,
                            modules.strModuleName, modules.blnFree
                    FROM customer_booking
                    INNER JOIN modules ON customer_booking.intPlanID = modules.intPlanID
                    WHERE customer_booking.intCustomerID = :customerID
                    ORDER BY intCustomerPlanID DESC
                    LIMIT 1
                "
            )

            if (local.qCurrentPlan.recordCount) {

                // Get all the linked modules of the current plan
                local.qLinkedModules = queryExecute (
                    options = {datasource = application.datasource},
                    params = {
                        planID: {type: "numeric", value: local.qCurrentPlan.intPlanID},
                        languageID: {type: "numeric", value: local.lngID}
                    },
                    sql = "
                        SELECT plans_modules.intModuleID,
                        (
                            IF
                                (
                                    LENGTH(
                                        (
                                            SELECT strModuleName
                                            FROM modules_trans
                                            WHERE intModuleID = plans_modules.intModuleID
                                            AND intLanguageID = :languageID
                                        )
                                    ),
                                    (
                                        SELECT strModuleName
                                        FROM modules_trans
                                        WHERE intModuleID = plans_modules.intModuleID
                                        AND intLanguageID = :languageID
                                    ),
                                    modules.strModuleName
                                )
                        ) as strModuleName
                        FROM plans_modules
                        INNER JOIN modules ON plans_modules.intModuleID = modules.intModuleID
                        WHERE plans_modules.intPlanID = :planID
                        AND modules.blnActive = 1
                    "
                )

                if (local.qLinkedModules.recordCount) {
                    modulesArray = arrayNew(1);
                    cfloop( query="local.qLinkedModules" ) {
                        linkedModules = structNew();
                        linkedModules['moduleID'] = local.qLinkedModules.intModuleID;
                        linkedModules['name'] = local.qLinkedModules.strModuleName;
                        arrayAppend(modulesArray, linkedModules);
                    }
                    planStruct['modulesIncluded'] = modulesArray;

                }

                planStruct['planID'] = local.qCurrentPlan.intPlanID;
                planStruct['planName'] = local.qCurrentPlan.strPlanName;
                planStruct['maxUsers'] = local.qCurrentPlan.intMaxUsers;
                planStruct['startDate'] = local.qCurrentPlan.dtmStartDate;
                planStruct['recurring'] = local.qCurrentPlan.strRecurring;

                // Is already a plan defined?
                if (local.qCurrentPlan.intPlanID gt 0) {

                    // Is the plan paused?
                    if (local.qCurrentPlan.blnPaused eq 1) {

                        planStruct['status'] = 'paused';

                    } else {

                        // Is a test phase running?
                        if (isDate(local.qCurrentPlan.dtmStartDate) and isDate(local.qCurrentPlan.dtmEndTestDate)) {

                            // Is the test phase still valid? | YES
                            if (dateDiff("d", now(), local.qCurrentPlan.dtmEndTestDate) gte 0) {

                                planStruct['endTestDate'] = local.qCurrentPlan.dtmEndTestDate;
                                planStruct['status'] = 'test';

                            // NO
                            } else {

                                planStruct['endTestDate'] = local.qCurrentPlan.dtmEndTestDate;
                                planStruct['status'] = 'expired';

                            }

                        } else {

                            // See if there is a free plan running
                            if (local.qCurrentPlan.blnFree) {

                                planStruct['status'] = 'free';
                                planStruct['endDate'] = "";

                            } else {

                                // Is a plan running?
                                if (isDate(local.qCurrentPlan.dtmEndDate)) {

                                    planStruct['endDate'] = local.qCurrentPlan.dtmEndDate;
                                    planStruct['status'] = 'active';

                                    // Still valid?
                                    if (dateDiff("d", local.qCurrentPlan.dtmStartDate, local.qCurrentPlan.dtmEndDate) lt 0) {

                                        planStruct['endDate'] = local.qCurrentPlan.dtmEndDate;
                                        planStruct['status'] = 'expired';

                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

        return planStruct;

    }



}