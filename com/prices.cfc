
component displayname="prices" output="false" {

    public any function init(numeric vat, numeric vat_type, numeric isnet, string language, string currency) {

        variables.vat = 0;
        variables.vat_type = application.objGlobal.getSetting('settingStandardVatType');
        variables.isnet = application.objGlobal.getSetting('settingInvoiceNet');
        variables.language = application.objGlobal.getDefaultLanguage().iso;
        variables.currency = getCurrency().iso;

        if (structKeyExists(arguments, "vat")) {
            variables.vat = arguments.vat;
        }
        if (structKeyExists(arguments, "vat_type")) {
            variables.vat_type = arguments.vat_type;
        }
        if (structKeyExists(arguments, "isnet")) {
            variables.isnet = arguments.isnet;
        }
        if (structKeyExists(arguments, "language")) {
            variables.language = arguments.language;
        }
        if (structKeyExists(arguments, "currency")) {
            variables.currency = arguments.currency;
        }

        return this;

    }



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



    public struct function getPriceData(required numeric price) {

        local.priceData = structNew();
        local.priceData['price'] = arguments.price;
        local.priceData['vat'] = variables.vat;
        local.priceData['vat_type'] = variables.vat_type;
        local.priceData['isNet'] = variables.isNet;
        local.priceData['currency'] = variables.currency;

        <!--- Calc prices --->
        local.objInvoice = new com.invoices();

        local.vat_amount = local.objInvoice.calcVat(arguments.price, variables.isNet, variables.vat);
        local.subtotal_price = arguments.price;

        <!--- Add up subtotal and vat --->
        if (variables.isNet eq 1) {
            local.total_price = local.subtotal_price + local.vat_amount;
        } else {
            local.total_price = local.subtotal_price;
        }

        <!--- Define vat text and sum --->
        if (variables.isNet eq 1) {
            if (variables.vat_type eq 1) {
                local.priceData['vat_text']  = application.objGlobal.getTrans('txtPlusVat', variables.language) & ' ' & variables.vat & '%: ' & variables.currency & ' ' & lsNumberFormat(local.vat_amount);
            } else if (variables.vat_type eq 3) {
                local.total_price = local.subtotal_price;
                local.priceData['vat_text']  = "";
            } else {
                local.total_price = local.subtotal_price;
                local.priceData['vat_text']  = application.objGlobal.getTrans('txtTotalExcl', variables.language);
            }
        } else {
            if (variables.vat_type eq 1) {
                local.priceData['vat_text']  = application.objGlobal.getTrans('txtVatIncluded', variables.language) & ' ' & variables.vat & '%' & ': ' & variables.currency & ' ' & lsNumberFormat(local.vat_amount);
            } else if (variables.vat_type eq 3) {
                local.total_price = local.subtotal_price;
                local.priceData['vat_text']  = "";
            } else {
                local.total_price = local.subtotal_price;
                local.priceData['vat_text']  = application.objGlobal.getTrans('txtTotalExcl', variables.language);
            }
        }

        <!--- Round total according customers setting --->
        local.total_price = objInvoice.roundAmount(local.total_price, application.objGlobal.getSetting('settingRoundFactor'));

        local.priceData['priceAfterVAT'] = local.total_price;

        return local.priceData;


    }

}