
component displayname="prices" output="false" {

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

                // get currency by id
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

                // get currency by iso or name
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

            // get the default currency
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

        }

        return local.currStruct;

    }



    public struct function getPriceData(numeric price, numeric vat, numeric vat_type, boolean isNet, string language, string currency) {

        local.price = 0;
        local.vat = 0;
        local.vat_type = application.objGlobal.getSetting(0, 'settingStandardVatType');
        local.isNet = application.objGlobal.getSetting(0, 'settingInvoiceNet');
        local.language = application.objGlobal.getDefaultLanguage().iso;
        local.currency = getCurrency().iso;

        if (structKeyExists(arguments, "language")) {
            local.language = arguments.language;
        }
        if (structKeyExists(arguments, "price") and arguments.price gt 0) {
            local.price = arguments.price;
        }
        if (structKeyExists(arguments, "vat") and arguments.vat gt 0) {
            local.vat = arguments.vat;
        }
        if (structKeyExists(arguments, "vat_type")) {
            local.vat_type = arguments.vat_type;
        }
        if (structKeyExists(arguments, "isNet")) {
            local.isNet = arguments.isNet;
        }
        if (structKeyExists(arguments, "currency")) {
            local.currency = arguments.currency;
        }

        local.priceData = structNew();
        local.priceData['price'] = local.price;
        local.priceData['vat'] = local.vat;
        local.priceData['vat_type'] = local.vat_type;
        local.priceData['isNet'] = local.isNet;
        local.priceData['currency'] = local.currency;

        <!--- Calc prices --->
        local.objInvoice = new com.invoices();

        local.vat_amount = local.objInvoice.calcVat(local.price, local.isNet, local.vat);
        local.subtotal_price = local.price;

        <!--- Add up subtotal and vat --->
        if (local.isNet eq 1) {
            local.total_price = local.subtotal_price + local.vat_amount;
        } else {
            local.total_price = local.subtotal_price;
        }

        <!--- Define vat text and sum --->
        if (local.isNet eq 1) {
            if (local.vat_type eq 1) {
                local.priceData['vat_text']  = application.objGlobal.getTrans('txtPlusVat', local.language) & ' ' & local.vat & '%: ' & local.currency & ' ' & lsNumberFormat(local.vat_amount, '__,___.__');
            } else if (local.vat_type eq 3) {
                local.total_price = local.subtotal_price;
                local.priceData['vat_text']  = "";
            } else {
                local.total_price = local.subtotal_price;
                local.priceData['vat_text']  = application.objGlobal.getTrans('txtTotalExcl', local.language);
            }
        } else {
            if (local.vat_type eq 1) {
                local.priceData['vat_text']  = application.objGlobal.getTrans('txtVatIncluded', local.language) & ' ' & local.vat & '%' & ': ' & local.currency & ' ' & lsNumberFormat(local.vat_amount, '__,___.__');
            } else if (local.vat_type eq 3) {
                local.total_price = local.subtotal_price;
                local.priceData['vat_text']  = "";
            } else {
                local.total_price = local.subtotal_price;
                local.priceData['vat_text']  = application.objGlobal.getTrans('txtTotalExcl', local.language);
            }
        }

        <!--- Round total according customers setting --->
        local.total_price = objInvoice.roundAmount(local.total_price, application.objGlobal.getSetting(0, 'settingRoundFactor'));

        local.priceData['priceAfterVAT'] = local.total_price;

        return local.priceData;


    }

}