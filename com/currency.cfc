
component displayname="currency" output="false" {

    // Get a structure of data of a currency
    public struct function getCurrency(any currency) {

        local.currStruct = structNew();
        local.currStruct['id'] = 0;
        local.currStruct['currency'] = "";
        local.currStruct['currency_en'] = "";
        local.currStruct['iso'] = "";
        local.currStruct['sign'] = "";
        local.currStruct['default'] = 0;
        local.currStruct['active'] = 0;

        if (structKeyExists(arguments, "currency")) {

            if (isNumeric(arguments.currency)) {

                // Get currency by id
                local.qCurrency = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        currencyID: {type: "numeric", value: arguments.currency}
                    },
                    sql = "
                        SELECT *
                        FROM currencies
                        WHERE intCurrencyID = :currencyID
                    "
                )

            } else {

                // Get currency by iso or name
                local.qCurrency = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        currency: {type: "varchar", value: arguments.currency}
                    },
                    sql = "
                        SELECT *
                        FROM currencies
                        WHERE   strCurrencyISO = :currency OR
                                strCurrencyEN = :currency OR
                                strCurrency = :currency OR
                                strCurrencySign = :currency
                    "
                )

            }


        } else {

            // Get the default currency
            local.qCurrency = queryExecute(
                options = {datasource = application.datasource},
                sql = "
                    SELECT *
                    FROM currencies
                    WHERE blnDefault = 1
                "
            )

        }

        if (local.qCurrency.recordCount) {

            local.currStruct['id'] = local.qCurrency.intCurrencyID;
            local.currStruct['currency'] = local.qCurrency.strCurrency;
            local.currStruct['currency_en'] = local.qCurrency.strCurrencyEN;
            local.currStruct['iso'] = local.qCurrency.strCurrencyISO;
            local.currStruct['sign'] = local.qCurrency.strCurrencySign;
            local.currStruct['default'] = local.qCurrency.blnDefault;
            local.currStruct['active'] = local.qCurrency.blnActive;
            local.currStruct['prio'] = local.qCurrency.intPrio;

        }

        return local.currStruct;

    }


    // Get all active currencies
    public array function getActiveCurrencies() {

        local.qCurrencies = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM currencies
                WHERE blnActive = 1
                ORDER BY intPrio
            "
        )

        local.currArray = arrayNew(1);
        local.currStruct = structNew();

        if (local.qCurrencies.recordCount) {

            loop query= local.qCurrencies {

                local.currStruct[local.qCurrencies.currentRow]['currencyID'] = local.qCurrencies.intCurrencyID;
                local.currStruct[local.qCurrencies.currentRow]['iso'] = local.qCurrencies.strCurrencyISO;
                local.currStruct[local.qCurrencies.currentRow]['currency_en'] = local.qCurrencies.strCurrencyEN;
                local.currStruct[local.qCurrencies.currentRow]['currency'] = local.qCurrencies.strCurrency;
                local.currStruct[local.qCurrencies.currentRow]['prio'] = local.qCurrencies.intPrio;
                arrayAppend(local.currArray, local.currStruct[local.qCurrencies.currentRow]);

            }

        }

        return local.currArray;

    }


    // Get currency of a given country
    public struct function getCurrencyOfCountry(required any country) {

        local.currencyStruct = structNew();

        if (isNumeric(arguments.country)) {

            local.qCurrOfCountry = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    countryID: {type: "numeric", value: arguments.country}
                },
                sql = "
                    SELECT intCurrencyID, strCurrencyISO
                    FROM currencies
                    WHERE blnActive = 1
                    AND strCurrencyISO =
                    (
                        SELECT strCurrency
                        FROM countries
                        WHERE intCountryID = :countryID
                    )
                "
            )

        } else {

            local.qCurrOfCountry = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    country: {type: "varchar", value: arguments.country}
                },
                sql = "
                    SELECT intCurrencyID, strCurrencyISO
                    FROM currencies
                    WHERE blnActive = 1
                    AND strCurrencyISO =
                    (
                        SELECT strCurrency
                        FROM countries
                        WHERE strISO1 = :country
                        OR strISO2 = :country
                        OR strLocale = :country
                        LIMIT 1
                    )
                "
            )
        }

        if (local.qCurrOfCountry.recordCount) {

            local.currencyStruct['currencyID'] = local.qCurrOfCountry.intCurrencyID;
            local.currencyStruct['currency'] = local.qCurrOfCountry.strCurrencyISO;

        } else {

            local.currencyStruct['currencyID'] = 0;
            local.currencyStruct['currency'] = "";

        }

        return local.currencyStruct;

    }

}