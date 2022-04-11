
component displayname="plans" {

    public array function getPlans(string language, numeric groupID, numeric countryID, numeric currencyID) {

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
        if (structKeyExists(arguments, "groupID")) {
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
        if (structKeyExists(arguments, "currencyID")) {
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
                COALESCE(blnRecommended,0) as blnRecommended,
                COALESCE(intMaxUsers,0) as intMaxUsers,
                COALESCE(intNumTestDays,0) as intNumTestDays,
                COALESCE(decPriceMonthly,0) as decPriceMonthly,
                COALESCE(decPriceYearly,0) as decPriceYearly,
                COALESCE(blnOnRequest,0) as blnOnRequest,
                COALESCE(decVat,0) as decVat,
                COALESCE(blnIsNet,0) as blnIsNet,
                COALESCE(intVatType,0) as intVatType,
                COALESCE(intCountryID,0) as intCountryID,
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
                    local.structPlan['bookingLink'] = local.getPlan.strBookingLink;
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

                arrayAppend(local.arrPlan, local.structPlan);

            }

        } else {

            local.structPlan = structNew();

            local.structPlan['groupName'] = 'Group name';
            local.structPlan['planName'] = 'Plan name';
            local.structPlan['shortDescription'] = 'Short description';
            local.structPlan['description'] = 'Description and feature list';
            local.structPlan['buttonName'] = 'Button name';
            local.structPlan['bookingLink'] = '##?';
            local.structPlan['recommended'] = 0;
            local.structPlan['maxUsers'] = 0;
            local.structPlan['testDays'] = 0;
            local.structPlan['priceMonthly'] = 0;
            local.structPlan['priceYearly'] = 0;
            local.structPlan['onRequest'] = 0;
            local.structPlan['vat'] = 0;
            local.structPlan['isNet'] = 1;
            local.structPlan['vatType'] = 1;
            local.structPlan['currency'] = 'CHF';

            arrayAppend(local.arrPlan, local.structPlan);

        }

        return local.arrPlan;

    }

}