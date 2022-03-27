component displayname="modules" output="false" {

    <!--- Pause or reactivate module --->
    public boolean function pauseModule(required numeric customerID, required numeric moduleID, required boolean active) {

        queryExecute(
            options = {datasource=application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                moduleID: {type: "numeric", value: arguments.moduleID},
                active = {type: "boolean", value: arguments.active}
            },
            sql = "
                UPDATE customer_modules
                SET blnPaused = :active
                WHERE intCustomerID = :customerID
                AND intModuleID = :moduleID
            "
        )

        return arguments.active;

    }


    <!--- Get data of a module --->
    public struct function getModuleData(required numeric moduleID, numeric lngID) {

        if (structKeyExists(arguments, "moduleID") and arguments.moduleID gt 0) {

            if (structKeyExists(arguments, "lngID") and arguments.lngID gt 0) {
                local.lngID = arguments.lngID;
            } else {
                local.lngID = application.objGlobal.getDefaultLanguage().lngID;
            }

            qModule = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    moduleID: {type: "numeric", value: arguments.moduleID},
                    lngID: {type: "numeric", value: local.lngID}
                },
                sql = "
                    SELECT modules.strTabPrefix, modules.strPicture, modules.blnBookable, modules.intPrio, modules.blnActive,
                    COALESCE(modules_prices.blnIsNet,0) as blnIsNet,
                    COALESCE(modules_prices.decPriceMonthly,0) as decPriceMonthly,
                    COALESCE(modules_prices.decPriceYearly,0) as decPriceYearly,
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
                    WHERE modules.intModuleID = :lngID
                "
            )

            local.moduleStruct = structNew();
            if (qModule.recordCount) {

                local.moduleStruct['name'] = qModule.strModuleName;
                local.moduleStruct['short_description'] = qModule.strShortDescription;
                local.moduleStruct['description'] = qModule.strDescription;
                local.moduleStruct['table_prefix'] = qModule.strTabPrefix;
                local.moduleStruct['picture'] = qModule.strPicture;
                local.moduleStruct['bookable'] = qModule.blnBookable;
                local.moduleStruct['active'] = qModule.blnActive;
                local.moduleStruct['isNet'] = qModule.blnIsNet;
                local.moduleStruct['price_monthly'] = qModule.decPriceMonthly;
                local.moduleStruct['price_yearly'] = qModule.decPriceYearly;
                local.moduleStruct['vat'] = qModule.decVat;
                local.moduleStruct['currencyID'] = qModule.intCurrencyID;
                local.moduleStruct['vat_type'] = qModule.intVatType;
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

        qModule = queryExecute(
            options = {datasource = application.datasource},
            params = {
                lngID: {type: "numeric", value: local.lngID},
                currID: {type: "numeric", value: local.currencyID}
            },
            sql = "
                SELECT modules.intModuleID, modules.strTabPrefix, modules.strPicture, modules.blnBookable, modules.intPrio,
                COALESCE(modules_prices.blnIsNet,0) as blnIsNet,
                COALESCE(modules_prices.decPriceMonthly,0) as decPriceMonthly,
                COALESCE(modules_prices.decPriceYearly,0) as decPriceYearly,
                COALESCE(modules_prices.decVat,0) as decVat,
                COALESCE(modules_prices.intCurrencyID,0) as intCurrencyID,
                COALESCE(modules_prices.intVatType,0) as intVatType,
                currencies.strCurrencyISO,
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
                AND modules_prices.intCurrencyID = :currID

                LEFT JOIN currencies ON 1=1
				AND modules_prices.intCurrencyID = currencies.intCurrencyID

                ORDER BY intPrio
            "
        )

        local.modalArray = arrayNew(1);

        loop query="qModule" {

            local.moduleStruct = structNew();

            local.moduleStruct['moduleID'] = qModule.intModuleID;
            local.moduleStruct['name'] = qModule.strModuleName;
            local.moduleStruct['short_description'] = qModule.strShortDescription;
            local.moduleStruct['description'] = qModule.strDescription;
            local.moduleStruct['table_prefix'] = qModule.strTabPrefix;
            local.moduleStruct['picture'] = qModule.strPicture;
            local.moduleStruct['bookable'] = qModule.blnBookable;
            local.moduleStruct['isNet'] = qModule.blnIsNet;
            local.moduleStruct['price_monthly'] = qModule.decPriceMonthly;
            local.moduleStruct['price_yearly'] = qModule.decPriceYearly;
            local.moduleStruct['vat'] = qModule.decVat;
            local.moduleStruct['currencyID'] = qModule.intCurrencyID;
            local.moduleStruct['vat_type'] = qModule.intVatType;
            local.moduleStruct['currency'] = qModule.strCurrencyISO;

            arrayAppend(local.modalArray, local.moduleStruct);

        }


        return local.modalArray;



    }





}