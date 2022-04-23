
component displayname="plans" output="false" {

    public array function getPlans(string language, numeric groupID, numeric currencyID) {

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

        if (structKeyExists(arguments, "groupID") and arguments.groupID gt 0) {
            local.groupID = arguments.groupID;
        } else {
            local.qDefPlanGroup = queryExecute (
                options = {datasource = application.datasource},
                sql = "
                    SELECT intPlanGroupID
                    FROM plan_groups
                    ORDER BY intPrio
                    LIMIT 1
                "
            )
            if (local.qDefPlanGroup.recordCount) {
                local.groupID = local.qDefPlanGroup.intPlanGroupID;
            } else {
                local.groupID = 0;
            }
        }
        if (structKeyExists(arguments, "currencyID") and arguments.currencyID gt 0) {
            local.currencyID = arguments.currencyID;
        } else {
            local.qDefCurrency = queryExecute (
                options = {datasource = application.datasource},
                sql = "
                    SELECT intCurrencyID
                    FROM currencies
                    WHERE blnDefault = 1
                "
            )
            if (local.qDefCurrency.recordCount) {
                local.currencyID = local.qDefCurrency.intCurrencyID;
            } else {
                local.currencyID = 0;
            }
        }

        // Get plans
        local.getPlan = queryExecute (
            options = {datasource = application.datasource},
            params = {
                languageID: {type: "numeric", value: local.lngID},
                currencyID: {type: "numeric", value: local.currencyID}
            },
            sql = "
                SELECT
                plans.intPlanID, plans.intPlanGroupID, plans.blnFree,
                plan_prices.intCurrencyID,
                COALESCE(blnRecommended,0) as blnRecommended,
                COALESCE(intMaxUsers,0) as intMaxUsers,
                COALESCE(intNumTestDays,0) as intNumTestDays,
                COALESCE(decPriceMonthly,0) as decPriceMonthly,
                COALESCE(decPriceYearly,0) as decPriceYearly,
                COALESCE(blnOnRequest,0) as blnOnRequest,
                COALESCE(decVat,0) as decVat,
                COALESCE(blnIsNet,0) as blnIsNet,
                COALESCE(intVatType,0) as intVatType,
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
                ) as strBookingLink,
                (
                    IF
                        (
                            LENGTH(
                                (
                                    SELECT strCurrencyISO
                                    FROM currencies
                                    WHERE intCurrencyID = plan_prices.intCurrencyID
                                )
                            ),
                            (
                                SELECT strCurrencyISO
                                FROM currencies
                                WHERE intCurrencyID = plan_prices.intCurrencyID
                            ),
                            (
                                SELECT strCurrencyISO
                                FROM currencies
                                WHERE intCurrencyID = :currencyID
                            )
                        )
                ) as strCurrencyISO


                FROM plan_groups

                LEFT JOIN plans ON 1=1
                AND plan_groups.intPlanGroupID = plans.intPlanGroupID

                LEFT JOIN plan_prices ON 1=1
                AND plans.intPlanID = plan_prices.intPlanID
                AND plan_prices.intCurrencyID = :currencyID

                WHERE !ISNULL(plans.intPlanID)

                ORDER BY plans.intPrio

            "
        )

        local.arrPlan = arrayNew(1);

        if (local.getPlan.recordCount) {

            cfloop( query = local.getPlan ) {

                local.structPlan = structNew();

                local.structPlan['planID'] = getPlan.intPlanID;
                local.structPlan['planGroupID'] = getPlan.intPlanGroupID;
                local.structPlan['currencyID'] = getPlan.intCurrencyID;
                local.structPlan['itsFree'] = getPlan.blnFree;
                local.structPlan['groupName'] = '';
                local.structPlan['planName'] = '';
                local.structPlan['shortDescription'] = '';
                local.structPlan['description'] = '';
                local.structPlan['buttonName'] = '';
                local.structPlan['bookingLink'] = '';
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

                // Building the booking link
                if (!len(trim(local.getPlan.strBookingLink))) {
                    objBook = new com.book();
                    bookingStringM = objBook.createBookingLink(getPlan.intPlanID, local.lngID, local.currencyID, "m");
                    local.structPlan['bookingLinkM'] = application.mainURL & "/book?plan=" & bookingStringM;
                    bookingStringY = objBook.createBookingLink(getPlan.intPlanID, local.lngID, local.currencyID, "y");
                    local.structPlan['bookingLinkY'] = application.mainURL & "/book?plan=" & bookingStringY;
                }

                arrayAppend(local.arrPlan, local.structPlan);

            }

        } else {

            local.structPlan = structNew();

            local.structPlan['planID'] = 0;
            local.structPlan['planGroupID'] = 0;
            local.structPlan['currencyID'] = 0;
            local.structPlan['itsFree'] = 0;
            local.structPlan['groupName'] = 'Group name';
            local.structPlan['planName'] = 'Plan name';
            local.structPlan['shortDescription'] = 'Short description';
            local.structPlan['description'] = 'Description and feature list';
            local.structPlan['buttonName'] = 'Button name';
            local.structPlan['bookingLinkM'] = '##?';
            local.structPlan['bookingLinkY'] = '##?';
            local.structPlan['recommended'] = 0;
            local.structPlan['maxUsers'] = 0;
            local.structPlan['testDays'] = 0;
            local.structPlan['priceMonthly'] = 0;
            local.structPlan['priceYearly'] = 0;
            local.structPlan['onRequest'] = 0;
            local.structPlan['vat'] = 0;
            local.structPlan['isNet'] = 1;
            local.structPlan['vatType'] = 1;
            local.structPlan['currency'] = 'USD';

            arrayAppend(local.arrPlan, local.structPlan);

        }

        return local.arrPlan;

    }


    public array function getPlanFeatures(string language) {

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
                local.lngID = 0;
            }
        } else {
            local.lngID = application.objGlobal.getDefaultLanguage().lngID;
        }

        local.arrFeatures = arrayNew(1);

        local.qPlanFeatures = queryExecute (
            options = {datasource = application.datasource},
            params = {
                languageID: {type: "numeric", value: local.lngID}
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



    public struct function getFeatureValue(required numeric planID, required numeric planFeatureID, string language) {

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
                local.lngID = 0;
            }
        } else {
            local.lngID = application.objGlobal.getDefaultLanguage().lngID;
        }

        local.qFeatValue = queryExecute (
            options = {datasource = application.datasource},
            params = {
                planID: {type: "numeric", value: arguments.planID},
                planFeatureID: {type: "numeric", value: arguments.planFeatureID},
                languageID: {type: "numeric", value: local.lngID}
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



    public struct function getCurrentPlan(required numeric customerID, string language) {

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

        planStruct = structNew();
        planStruct['planID'] = 0;
        planStruct['planName'] = "";
        planStruct['status'] = '';
        planStruct['maxUsers'] = 1;
        planStruct['startDate'] = "";
        planStruct['endDate'] = "";
        planStruct['endTestDate'] = "";
        planStruct['modulesIncluded'] = "";

        if (structKeyExists(arguments, "customerID") and arguments.customerID gt 0) {

            local.qCurrentPlan = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID}
                },
                sql = "
                    SELECT  customer_plans.intPlanID, customer_plans.dtmStartDate, customer_plans.dtmEndDate,
                            customer_plans.blnPaused, customer_plans.dtmEndTestDate,
                            plans.strPlanName, plans.intMaxUsers, plans.blnFree
                    FROM customer_plans
                    INNER JOIN plans ON customer_plans.intPlanID = plans.intPlanID
                    WHERE customer_plans.intCustomerID = :customerID
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



    public any function getPlanDetail(required numeric planID, string language, numeric currencyID) {

        planArray = getPlans(language=arguments.language, currencyID=arguments.currencyID);

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









}