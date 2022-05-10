component displayname="modules" output="false" {


    <!--- Get data of a module --->
    public struct function getModuleData(required numeric moduleID, string language) {

        if (structKeyExists(arguments, "moduleID") and arguments.moduleID gt 0) {

            if (structKeyExists(arguments, "language")) {
                local.qLanguage = queryExecute (
                    options = {datasource = application.datasource},
                    params = {
                        language: {type: "varchar", value: arguments.language}
                    },
                    sql = "
                        SELECT intLanguageID, strLanguageISO
                        FROM languages
                        WHERE strLanguageISO = :language
                    "
                )
                if (local.qLanguage.recordCount) {
                    local.lngID = local.qLanguage.intLanguageID;
                    local.language = local.qLanguage.strLanguageISO;
                } else {
                    local.lngID = application.objGlobal.getDefaultLanguage().lngID;
                    local.language = application.objGlobal.getDefaultLanguage().iso;
                }
            } else {
                local.lngID = application.objGlobal.getDefaultLanguage().lngID;
                local.language = application.objGlobal.getDefaultLanguage().iso;
            }

            qModule = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    moduleID: {type: "numeric", value: arguments.moduleID},
                    lngID: {type: "numeric", value: local.lngID}
                },
                sql = "
                    SELECT modules.strTabPrefix, modules.strPicture, modules.blnBookable, modules.intPrio, modules.blnActive,
                    currencies.strCurrencyISO, currencies.strCurrencySign,
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

                    LEFT JOIN currencies ON 1=1
				    AND modules_prices.intCurrencyID = currencies.intCurrencyID

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
                local.moduleStruct['vat_type'] = qModule.intVatType;
                local.moduleStruct['currencyID'] = qModule.intCurrencyID;
                if (len(trim(qModule.strCurrencySign))) {
                    local.moduleStruct['currencySign'] = qModule.strCurrencySign;
                } else {
                    local.moduleStruct['currencySign'] = qModule.strCurrencyISO;
                }
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

        local.modalArray = arrayNew(1);

        loop query="qModule" {

            local.moduleStruct = structNew();
            local.moduleStruct = getModuleData(local.qModule.intModuleID, local.lngID);
            arrayAppend(local.modalArray, local.moduleStruct);

        }


        return local.modalArray;



    }





}