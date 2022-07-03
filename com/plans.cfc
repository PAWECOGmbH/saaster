
component displayname="plans" output="false" {

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


    // Prepare for group id according ip or customer account
    public struct function prepareForGroupID(numeric customerID, string ipAddress) {

        local.prepareStruct = structNew();
        local.thisCountryID = 0;
        local.thisGroupID = 0;
        local.thisCurrencyID = 0;

        // do we have a session?
        if (structKeyExists(arguments, "customerID") and arguments.customerID gt 0) {

            // Get the country of the customer, if exists
            local.getCustomerData = application.objCustomer.getCustomerData(arguments.customerID);
            if (local.getCustomerData.recordCount and local.getCustomerData.intCountryID gt 0) {
                local.thisCountryID = local.getCustomerData.intCountryID;
            }

        }

        // If countryID is still 0, then get over ip
        if (local.thisCountryID eq 0) {

            if (structKeyExists(arguments, "ipAddress") and len(trim(arguments.ipAddress))) {

                // What is the country according to the IP address? (Yes, the user may have a VPN, but we'll ignore that for now)
                local.countryStruct = application.objGlobal.getCountryFromIP(arguments.ipAddress);

                if (local.countryStruct.success) {
                    if (local.countryStruct.countryID gt 0) {
                        local.thisCountryID = local.countryStruct.countryID;
                    }
                }

            }

        }

        local.qCheckGroup = queryExecute (
            options = {datasource = application.datasource},
            params = {
                countryID: {type: "numeric", value: local.thisCountryID}
            },
            sql = "
                SELECT intPlanGroupID
                FROM plan_groups
                WHERE intCountryID = :countryID
            "
        )
        if (local.qCheckGroup.recordCount) {
            local.thisGroupID = local.qCheckGroup.intPlanGroupID;
        }

        // We didn't find a group corresponding to the country, so we need to get group without country
        if (local.thisGroupID eq 0) {

            local.qDefPlanGroup = queryExecute (
                options = {datasource = application.datasource},
                sql = "
                    SELECT intPlanGroupID
                    FROM plan_groups
                    WHERE intCountryID IS NULL
                    ORDER BY intPrio
                    LIMIT 1
                "
            )

            if (local.qDefPlanGroup.recordCount) {
                local.thisGroupID = local.qDefPlanGroup.intPlanGroupID;
            } else {
                local.thisGroupID = 0;
            }

        }

        // get the currency of the country
        if (local.thisCountryID gt 0) {
            local.currID = application.objGlobal.getCurrencyOfCountry(local.thisCountryID).currencyID;
            if (local.currID gt 0) {
                local.thisCurrencyID = local.currID;
            } else {
                local.thisCurrencyID = application.objGlobal.getDefaultCurrency().currencyID;
            }
        }

        local.prepareStruct['countryID'] = local.thisCountryID;
        local.prepareStruct['groupID'] = local.thisGroupID;
        local.prepareStruct['defaultCurrencyID'] = local.thisCurrencyID;

        return local.prepareStruct;

    }


    // Get plans using the groupID
    public array function getPlans(required numeric planGroupID) {

        local.getPlan = queryExecute (
            options = {datasource = application.datasource},
            params = {
                languageID: {type: "numeric", value: variables.lngID},
                currencyID: {type: "numeric", value: variables.currencyID}
            },
            sql = "
                SELECT
                plans.intPlanID, plans.intPlanGroupID, plans.blnFree,
                currencies.strCurrencyISO, currencies.strCurrencySign,
                plan_prices.intCurrencyID,
                COALESCE(plans.blnRecommended,0) as blnRecommended,
                COALESCE(plans.intMaxUsers,0) as intMaxUsers,
                COALESCE(plans.intNumTestDays,0) as intNumTestDays,
                COALESCE(plan_prices.decPriceMonthly,0) as decPriceMonthly,
                COALESCE(plan_prices.decPriceYearly,0) as decPriceYearly,
                COALESCE(plan_prices.blnOnRequest,0) as blnOnRequest,
                COALESCE(plan_prices.decVat,0) as decVat,
                COALESCE(plan_prices.blnIsNet,0) as blnIsNet,
                COALESCE(plan_prices.intVatType,0) as intVatType,
                (
                    IF
                        (
                            LENGTH(
                                (
                                    SELECT strGroupName
                                    FROM plan_groups_trans
                                    WHERE intPlanGroupID = plan_groups.intPlanGroupID
                                    AND intLanguageID = :languageID
                                )
                            ),
                            (
                                SELECT strGroupName
                                FROM plan_groups_trans
                                WHERE intPlanGroupID = plan_groups.intPlanGroupID
                                AND intLanguageID = :languageID
                            ),
                            plan_groups.strGroupName
                        )
                ) as strGroupName,
                (
                    IF
                        (
                            LENGTH(
                                (
                                    SELECT strPlanName
                                    FROM plans_trans
                                    WHERE intPlanID = plans.intPlanID
                                    AND intLanguageID = :languageID
                                )
                            ),
                            (
                                SELECT strPlanName
                                FROM plans_trans
                                WHERE intPlanID = plans.intPlanID
                                AND intLanguageID = :languageID
                            ),
                            plans.strPlanName
                        )
                ) as strPlanName,
                (
                    IF
                        (
                            LENGTH(
                                (
                                    SELECT strShortDescription
                                    FROM plans_trans
                                    WHERE intPlanID = plans.intPlanID
                                    AND intLanguageID = :languageID
                                )
                            ),
                            (
                                SELECT strShortDescription
                                FROM plans_trans
                                WHERE intPlanID = plans.intPlanID
                                AND intLanguageID = :languageID
                            ),
                            plans.strShortDescription
                        )
                ) as strShortDescription,
                (
                    IF
                        (
                            LENGTH(
                                (
                                    SELECT strDescription
                                    FROM plans_trans
                                    WHERE intPlanID = plans.intPlanID
                                    AND intLanguageID = :languageID
                                )
                            ),
                            (
                                SELECT strDescription
                                FROM plans_trans
                                WHERE intPlanID = plans.intPlanID
                                AND intLanguageID = :languageID
                            ),
                            plans.strDescription
                        )
                ) as strDescription,
                (
                    IF
                        (
                            LENGTH(
                                (
                                    SELECT strButtonName
                                    FROM plans_trans
                                    WHERE intPlanID = plans.intPlanID
                                    AND intLanguageID = :languageID
                                )
                            ),
                            (
                                SELECT strButtonName
                                FROM plans_trans
                                WHERE intPlanID = plans.intPlanID
                                AND intLanguageID = :languageID
                            ),
                            plans.strButtonName
                        )
                ) as strButtonName,
                (
                    IF
                        (
                            LENGTH(
                                (
                                    SELECT strBookingLink
                                    FROM plans_trans
                                    WHERE intPlanID = plans.intPlanID
                                    AND intLanguageID = :languageID
                                )
                            ),
                            (
                                SELECT strBookingLink
                                FROM plans_trans
                                WHERE intPlanID = plans.intPlanID
                                AND intLanguageID = :languageID
                            ),
                            plans.strBookingLink
                        )
                ) as strBookingLink

                FROM plan_groups

                LEFT JOIN plans ON 1=1
                AND plan_groups.intPlanGroupID = plans.intPlanGroupID

                LEFT JOIN plan_prices ON 1=1
                AND plans.intPlanID = plan_prices.intPlanID
                AND plan_prices.intCurrencyID = :currencyID

                LEFT JOIN currencies ON 1=1
                AND plan_prices.intCurrencyID = currencies.intCurrencyID

                WHERE !ISNULL(plans.intPlanID)

                ORDER BY plans.intPrio

            "
        )

        local.arrPlan = arrayNew(1);

        if (local.getPlan.recordCount) {

            cfloop( query = local.getPlan ) {

                local.structPlan = structNew();

                local.structPlan['planID'] = local.getPlan.intPlanID;
                local.structPlan['planGroupID'] = local.getPlan.intPlanGroupID;
                local.structPlan['currencyID'] = local.getPlan.intCurrencyID;
                local.structPlan['itsFree'] = local.getPlan.blnFree;
                local.structPlan['groupName'] = '';
                local.structPlan['planName'] = '';
                local.structPlan['shortDescription'] = '';
                local.structPlan['description'] = '';
                local.structPlan['buttonName'] = '';
                local.structPlan['bookingLinkM'] = '';
                local.structPlan['bookingLinkY'] = '';
                local.structPlan['bookingLinkF'] = '';
                local.structPlan['recommended'] = 0;
                local.structPlan['maxUsers'] = 0;
                local.structPlan['testDays'] = 0;
                local.structPlan['priceMonthly'] = 0;
                local.structPlan['priceYearly'] = 0;
                local.structPlan['onRequest'] = 0;
                local.structPlan['vat'] = 0;
                local.structPlan['isNet'] = 1;
                local.structPlan['vatType'] = 1;
                local.structPlan['currency'] = '';
                local.structPlan['currencySign'] = '';

                if (len(trim(local.getPlan.strGroupName))) {
                    local.structPlan['groupName'] = local.getPlan.strGroupName;
                }
                if (len(trim(local.getPlan.strPlanName))) {
                    local.structPlan['planName'] = local.getPlan.strPlanName;
                }
                if (len(trim(local.getPlan.strShortDescription))) {
                    local.structPlan['shortDescription'] = local.getPlan.strShortDescription;
                }
                if (len(trim(local.getPlan.strDescription))) {
                    local.structPlan['description'] = local.getPlan.strDescription;
                }
                if (len(trim(local.getPlan.strButtonName))) {
                    local.structPlan['buttonName'] = local.getPlan.strButtonName;
                }
                if (len(trim(local.getPlan.strBookingLink))) {
                    local.structPlan['bookingLinkM'] = local.getPlan.strBookingLink;
                    local.structPlan['bookingLinkY'] = local.getPlan.strBookingLink;
                    local.structPlan['bookingLinkF'] = local.getPlan.strBookingLink;
                }
                if (isBoolean(local.getPlan.blnRecommended)) {
                    local.structPlan['recommended'] = local.getPlan.blnRecommended;
                }
                if (isNumeric(local.getPlan.intMaxUsers)) {
                    local.structPlan['maxUsers'] = local.getPlan.intMaxUsers;
                }
                if (isNumeric(local.getPlan.intNumTestDays)) {
                    local.structPlan['testDays'] = local.getPlan.intNumTestDays;
                }
                if (isNumeric(local.getPlan.decPriceMonthly)) {
                    local.structPlan['priceMonthly'] = local.getPlan.decPriceMonthly;
                }
                if (isNumeric(local.getPlan.decPriceYearly)) {
                    local.structPlan['priceYearly'] = local.getPlan.decPriceYearly;
                }
                if (isBoolean(local.getPlan.blnOnRequest)) {
                    local.structPlan['onRequest'] = local.getPlan.blnOnRequest;
                }
                if (isNumeric(local.getPlan.decVat)) {
                    local.structPlan['vat'] = local.getPlan.decVat;
                }
                if (isBoolean(local.getPlan.blnIsNet)) {
                    local.structPlan['isNet'] = local.getPlan.blnIsNet;
                }
                if (isNumeric(local.getPlan.decVat)) {
                    local.structPlan['vatType'] = local.getPlan.intVatType;
                }
                if (isBoolean(local.getPlan.blnRecommended)) {
                    local.structPlan['currency'] = local.getPlan.strCurrencyISO;
                }
                if (len(trim(local.getPlan.strCurrencySign))) {
                    local.structPlan['currencySign'] = local.getPlan.strCurrencySign;
                } else {
                    local.structPlan['currencySign'] = local.getPlan.strCurrencyISO;
                }

                // Get all the included modules of the current plan
                structAppend(local.structPlan, getModulesIncluded(local.getPlan.intPlanID));


                local.objPrices = new com.prices(
                    vat=local.getPlan.decVat,
                    vat_type=local.getPlan.intVatType,
                    isnet=local.getPlan.blnIsNet,
                    language=variables.language,
                    currency=local.getPlan.strCurrencyISO
                );

                local.structPlan['vat_text_monthly'] = local.objPrices.getPriceData(price=local.getPlan.decPriceMonthly).vat_text;
                local.structPlan['vat_text_yearly'] = local.objPrices.getPriceData(price=local.getPlan.decPriceYearly).vat_text;
                local.structPlan['priceMonthlyAfterVAT'] = local.objPrices.getPriceData(price=local.getPlan.decPriceMonthly).priceAfterVAT;
                local.structPlan['priceYearlyAfterVAT'] = local.objPrices.getPriceData(price=local.getPlan.decPriceYearly).priceAfterVAT;

                // Build the booking link

                // bookingLinkM: monthly
                // bookingLinkY: yearly
                // bookingLinkF: free

                if (!len(trim(local.getPlan.strBookingLink))) {

                    local.objBook = new com.book();
                    local.bookingStringM = local.objBook.init('plan').createBookingLink(getPlan.intPlanID, variables.lngID, variables.currencyID, "monthly", "plan");
                    local.structPlan['bookingLinkM'] = application.mainURL & "/book?plan=" & local.bookingStringM;
                    local.bookingStringY = local.objBook.init('plan').createBookingLink(getPlan.intPlanID, variables.lngID, variables.currencyID, "yearly", "plan");
                    local.structPlan['bookingLinkY'] = application.mainURL & "/book?plan=" & local.bookingStringY;
                    local.bookingStringF = local.objBook.init('plan').createBookingLink(getPlan.intPlanID, variables.lngID, variables.currencyID, "free", "plan");
                    local.structPlan['bookingLinkF'] = application.mainURL & "/book?plan=" & local.bookingStringF;

                }

                arrayAppend(local.arrPlan, local.structPlan);

            }

        }

        return local.arrPlan;

    }


    public array function getPlanFeatures() {

        local.arrFeatures = arrayNew(1);

        local.qPlanFeatures = queryExecute (
            options = {datasource = application.datasource},
            params = {
                languageID: {type: "numeric", value: variables.lngID}
            },
            sql = "
                SELECT intPlanFeatureID, blnCategory,
                (
                    IF
                        (
                            LENGTH(
                                (
                                    SELECT strFeatureName
                                    FROM plan_features_trans
                                    WHERE intPlanFeatureID = plan_features.intPlanFeatureID
                                    AND intLanguageID = :languageID
                                )
                            ),
                            (
                                SELECT strFeatureName
                                FROM plan_features_trans
                                WHERE intPlanFeatureID = plan_features.intPlanFeatureID
                                AND intLanguageID = :languageID
                            ),
                            plan_features.strFeatureName
                        )
                ) as strFeatureName,
                (
                    IF
                        (
                            LENGTH(
                                (
                                    SELECT strDescription
                                    FROM plan_features_trans
                                    WHERE intPlanFeatureID = plan_features.intPlanFeatureID
                                    AND intLanguageID = :languageID
                                )
                            ),
                            (
                                SELECT strDescription
                                FROM plan_features_trans
                                WHERE intPlanFeatureID = plan_features.intPlanFeatureID
                                AND intLanguageID = :languageID
                            ),
                            plan_features.strDescription
                        )
                ) as strDescription
                FROM plan_features
                ORDER BY intPrio
            "
        )

        if (local.qPlanFeatures.recordCount) {

            cfloop( query = local.qPlanFeatures ) {

                local.structFeat = structNew();

                local.structFeat['id'] = local.qPlanFeatures.intPlanFeatureID;
                local.structFeat['name'] = '';
                local.structFeat['description'] = '';
                local.structFeat['category'] = 0;

                if (len(trim(local.qPlanFeatures.strFeatureName))) {
                    local.structFeat['name'] = local.qPlanFeatures.strFeatureName;
                }
                if (len(trim(local.qPlanFeatures.strDescription))) {
                    local.structFeat['description'] = local.qPlanFeatures.strDescription;
                }
                if (isBoolean(local.qPlanFeatures.blnCategory)) {
                    local.structFeat['category'] = local.qPlanFeatures.blnCategory;
                }

                arrayAppend(local.arrFeatures, local.structFeat);


            }

        }

        return local.arrFeatures;


    }



    public struct function getFeatureValue(required numeric planID, required numeric planFeatureID) {

        local.qFeatValue = queryExecute (
            options = {datasource = application.datasource},
            params = {
                planID: {type: "numeric", value: arguments.planID},
                planFeatureID: {type: "numeric", value: arguments.planFeatureID},
                languageID: {type: "numeric", value: variables.lngID}
            },
            sql = "
                SELECT blnCheckmark,
                (
                    IF
                        (
                            LENGTH(
                                (
                                    SELECT strValue
                                    FROM plans_plan_features_trans
                                    WHERE intPlansPlanFeatID = plans_plan_features.intPlansPlanFeatID
                                    AND intLanguageID = :languageID
                                )
                            ),
                            (
                                SELECT strValue
                                FROM plans_plan_features_trans
                                WHERE intPlansPlanFeatID = plans_plan_features.intPlansPlanFeatID
                                AND intLanguageID = :languageID
                            ),
                            plans_plan_features.strValue
                        )
                ) as strValue
                FROM plans_plan_features
                WHERE intPlanID = :planID
                AND intPlanFeatureID = :planFeatureID

            "
        )

        local.structFeatVal = structNew();
        local.structFeatVal['value'] = '';
        local.structFeatVal['checkmark'] = 0;

        if (local.qFeatValue.recordCount) {
            local.structFeatVal['value'] = local.qFeatValue.strValue;
            local.structFeatVal['checkmark'] = local.qFeatValue.blnCheckmark;

        }

        return local.structFeatVal;

    }



    public struct function getCurrentPlan(required numeric customerID) {

        local.planStruct = structNew();
        local.planStruct['planID'] = 0;
        local.planStruct['planName'] = "";
        local.planStruct['status'] = '';
        local.planStruct['maxUsers'] = 1;
        local.planStruct['startDate'] = "";
        local.planStruct['endDate'] = "";
        local.planStruct['endTestDate'] = "";
        local.planStruct['modulesIncluded'] = "";
        local.planStruct['recurring'] = "";
        local.planStruct['priceMonthly'] = 0;

        if (structKeyExists(arguments, "customerID") and arguments.customerID gt 0) {

            local.qCurrentPlan = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID},
                    languageID: {type: "numeric", value: variables.lngID},
                    currency: {type: "numeric", value: application.objGlobal.getDefaultCurrency().currencyID}
                },
                sql = "
                    SELECT  customer_bookings.intPlanID, customer_bookings.dtmStartDate, customer_bookings.dtmEndDate,
                            customer_bookings.blnPaused, customer_bookings.dtmEndTestDate, customer_bookings.strRecurring,
                            plans.intMaxUsers, plans.blnFree,
                            (
                                IF
                                    (
                                        LENGTH(
                                            (
                                                SELECT strPlanName
                                                FROM plans_trans
                                                WHERE intPlanID = plans.intPlanID
                                                AND intLanguageID = :languageID
                                            )
                                        ),
                                        (
                                            SELECT strPlanName
                                            FROM plans_trans
                                            WHERE intPlanID = plans.intPlanID
                                            AND intLanguageID = :languageID
                                        ),
                                        plans.strPlanName
                                    )
                            ) as strPlanName,
                            (
                                SELECT decPriceMonthly
                                FROM plan_prices
                                WHERE intPlanID = plans.intPlanID
                                AND intCurrencyID = :currency
                            ) as decPriceMonthly
                    FROM customer_bookings
                    INNER JOIN plans ON customer_bookings.intPlanID = plans.intPlanID
                    WHERE customer_bookings.intCustomerID = :customerID
                "
            )


            if (local.qCurrentPlan.recordCount) {

                local.planStruct['planID'] = local.qCurrentPlan.intPlanID;
                local.planStruct['planName'] = local.qCurrentPlan.strPlanName;
                local.planStruct['maxUsers'] = local.qCurrentPlan.intMaxUsers;
                local.planStruct['startDate'] = local.qCurrentPlan.dtmStartDate;
                local.planStruct['recurring'] = local.qCurrentPlan.strRecurring;
                local.planStruct['priceMonthly'] = local.qCurrentPlan.decPriceMonthly;

                // Is already a plan defined?
                if (local.qCurrentPlan.intPlanID gt 0) {

                    // Is the plan paused?
                    if (local.qCurrentPlan.blnPaused eq 1) {

                        local.planStruct['status'] = 'paused';

                    // Is the plan canceled?
                    } else if (local.qCurrentPlan.strRecurring eq "canceled") {

                        if (isDate(local.qCurrentPlan.dtmEndDate)) {
                            local.planStruct['endDate'] = local.qCurrentPlan.dtmEndDate;
                        } else {
                            local.planStruct['endTestDate'] = local.qCurrentPlan.dtmEndTestDate;
                        }
                        local.planStruct['status'] = 'canceled';

                    } else {

                        // Is a test phase running?
                        if (isDate(local.qCurrentPlan.dtmStartDate) and isDate(local.qCurrentPlan.dtmEndTestDate)) {

                            // Is the test phase still valid? | YES
                            if (dateDiff("d", now(), local.qCurrentPlan.dtmEndTestDate) gte 0) {

                                local.planStruct['endTestDate'] = local.qCurrentPlan.dtmEndTestDate;
                                local.planStruct['status'] = 'test';

                            // NO
                            } else {

                                local.planStruct['endTestDate'] = local.qCurrentPlan.dtmEndTestDate;
                                local.planStruct['status'] = 'expired';

                            }

                        } else {

                            // See if there is a free plan running
                            if (local.qCurrentPlan.blnFree) {

                                local.planStruct['status'] = 'free';
                                local.planStruct['endDate'] = "";

                            } else {

                                // Is a plan running?
                                if (isDate(local.qCurrentPlan.dtmEndDate)) {

                                    local.planStruct['endDate'] = local.qCurrentPlan.dtmEndDate;
                                    local.planStruct['status'] = 'active';

                                    // Still valid?
                                    if (dateDiff("d", now(), local.qCurrentPlan.dtmEndDate) lt 0) {

                                        local.planStruct['endDate'] = local.qCurrentPlan.dtmEndDate;
                                        local.planStruct['status'] = 'expired';

                                    }

                                }

                            }

                        }

                    }

                }

                // Get all the included modules of the current plan
                structAppend(local.planStruct, getModulesIncluded(local.qCurrentPlan.intPlanID));

            }

        }

        return local.planStruct;

    }



    public struct function getModulesIncluded(required numeric planID) {

        local.modulesStruct = structNew();
        local.modulesArray = arrayNew(1);
        local.moduleList = "";

        local.modulesStruct['modulesIncluded'] = local.modulesArray;

        if (isNumeric(arguments.planID) and arguments.planID gt 0) {

            local.qLinkedModules = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    planID: {type: "numeric", value: arguments.planID},
                    languageID: {type: "numeric", value: variables.lngID}
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

                cfloop( query="local.qLinkedModules" ) {

                    local.includedModules = structNew();
                    local.includedModules['moduleID'] = local.qLinkedModules.intModuleID;
                    local.includedModules['name'] = local.qLinkedModules.strModuleName;
                    arrayAppend(local.modulesArray, local.includedModules);

                    local.moduleList = listAppend(local.moduleList, local.qLinkedModules.intModuleID);

                }

                local.modulesStruct['modulesIncluded'] = local.modulesArray;

            }

        }

        return local.modulesStruct;

    }



    public any function getPlanDetail(required numeric planID) {

        // Get groupID of the plan first
        local.qGroup = queryExecute (
            options = {datasource = application.datasource},
            params = {
                planID: {type: "numeric", value: arguments.planID}
            },
            sql = "
                SELECT intPlanGroupID
                FROM plans
                WHERE intPlanID = :planID
            "
        )

        if (local.qGroup.recordCount) {
            local.groupID = local.qGroup.intPlanGroupID;
        } else {
            local.groupID = 0;
        }

        planArray = getPlans(local.groupID);
        planStruct = structNew();

        if (isArray(planArray)) {
            planID = arguments.planID;
            planStruct = ArrayFilter(planArray, function(p) {
                return p.planID eq planID;
            })
            return planStruct[1];
        } else {
            return planStruct;
        }


    }


    public struct function getPlanStatusAsText(required struct thisPlan) {

        local.planStatus = structNew();

        if (isStruct(arguments.thisPlan)) {

            if (structKeyExists(arguments.thisPlan, "status")) {

                switch(arguments.thisPlan.status) {

                    case "active":
                        local.planStatus['statusTitle'] = application.objGlobal.getTrans('titActive');
                        local.planStatus['statusText'] = application.objGlobal.getTrans('txtRenewPlanOn');
                        local.planStatus['fontColor'] = "green";
                        break;

                    case "free":
                        local.planStatus['statusTitle'] = application.objGlobal.getTrans('titActive');
                        local.planStatus['statusText'] = application.objGlobal.getTrans('txtFreeForever');
                        local.planStatus['fontColor'] = "green";
                        break;

                    case "expired":
                        local.planStatus['statusTitle'] = application.objGlobal.getTrans('txtExpired');
                        if (isDate(arguments.thisPlan.endTestDate)) {
                            local.planStatus['statusText'] = application.objGlobal.getTrans('txtTestTimeExpired');
                        } else {
                            local.planStatus['statusText'] = application.objGlobal.getTrans('txtPlanExpired');
                        }
                        local.planStatus['fontColor'] = "red";
                        break;

                    case "test":
                        local.planStatus['statusTitle'] = application.objGlobal.getTrans('txtTest');
                        local.planStatus['statusText'] = application.objGlobal.getTrans('txtTestUntil');
                        local.planStatus['fontColor'] = "blue";
                        break;

                    case "canceled":
                        local.planStatus['statusTitle'] = application.objGlobal.getTrans('txtCanceled');
                        local.planStatus['statusText'] = application.objGlobal.getTrans('txtSubscriptionCanceled');
                        local.planStatus['fontColor'] = "orange";
                        break;

                    case "onetime":
                        local.planStatus['statusTitle'] = application.objGlobal.getTrans('titActive');
                        local.planStatus['statusText'] = application.objGlobal.getTrans('txtOneTimePayment');
                        local.planStatus['fontColor'] = "green";
                        break;

                    default:
                        local.planStatus['statusTitle'] = "";
                        local.planStatus['statusText'] = "";
                        local.planStatus['fontColor'] = "";

                }

            }

        }

        return local.planStatus;

    }


    public struct function calculateUpgrade(required numeric customerID, required numeric newPlanID, required string recurring) {

        // Get the already paid amount
        local.qPaidAmount = queryExecute (
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT  customer_bookings.intPlanID, customer_bookings.dtmStartDate, customer_bookings.dtmEndDate,
                        customer_bookings.strRecurring, customer_bookings.intPlanID,
                        invoices.decSubTotalPrice, invoices.intVatType, invoices.strCurrency
                FROM customer_bookings
                INNER JOIN invoices ON 1=1
                AND customer_bookings.intCustomerBookingID = invoices.intCustomerBookingID
                AND customer_bookings.intCustomerID = :customerID
                AND invoices.intPaymentStatusID = 3
            "
        )

        local.upgradeStruct = structNew();
        local.paidAmount = 0;

        if (local.qPaidAmount.recordCount) {

            // The amount the customer has paid
            local.paidAmount = local.qPaidAmount.decSubTotalPrice;

            // Check whether its a yearly or monthly subscription
            local.recurring = local.qPaidAmount.strRecurring;

            // How many days has the current subscription?
            if (arguments.recurring eq "yearly") {
                local.subscriptionDays = daysInYear(local.qPaidAmount.dtmStartDate);
            } else {
                local.subscriptionDays = daysInMonth(local.qPaidAmount.dtmStartDate);
            }

            // How many days has the current subscription been running?
            local.daysRunning = dateDiff("d", local.qPaidAmount.dtmStartDate, now());

            // Calculate the day price of the current subscription
            local.dayPrice = numberFormat(local.paidAmount/local.subscriptionDays, "__.__");

            // The price to be charged for the old subscription
            local.priceToChargeOld = local.daysRunning * local.dayPrice;


            // Get the data of the new plan ////////////////////
            local.planData = getPlanDetail(arguments.newPlanID);

            // Get the price of the new plan
            if (arguments.recurring eq "yearly") {
                local.newPrice = local.planData.priceYearly;
            } else {
                local.newPrice = local.planData.priceMonthly;
            }

            // Calculate the day price of the new plan
            local.dayPriceNew = numberFormat(local.newPrice/local.subscriptionDays, "__.__");

            // How many days till the end of the period?
            local.daysTillEnd = local.subscriptionDays - dateFormat(now(), "d");

            // The price to be charged for the new subscription (now)
            local.priceToChargeNew = local.daysTillEnd * local.dayPriceNew;

            // Old and new together less amount already paid
            local.priceToChargeTotal = local.priceToChargeOld + local.priceToChargeNew - local.paidAmount;

            local.upgradeStruct['oldPlanID'] = local.qPaidAmount.intPlanID;
            local.upgradeStruct['newPlanID'] = arguments.newPlanID;
            local.upgradeStruct['paidAmount'] = local.paidAmount;
            local.upgradeStruct['toPayNow'] = local.priceToChargeTotal;
            local.upgradeStruct['currency'] = local.qPaidAmount.strCurrency;
            local.upgradeStruct['recurring'] = arguments.recurring;


        }


        return local.upgradeStruct;


    }


}