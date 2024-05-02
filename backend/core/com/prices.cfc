
component displayname="prices" output="false" {

    public any function init(numeric vat, numeric vat_type, numeric isnet, string language, string currency) {

        variables.vat = 0;
        variables.vat_type = application.objSettings.getSetting('settingStandardVatType');
        variables.isnet = application.objSettings.getSetting('settingInvoiceNet');
        variables.language = application.objLanguage.getDefaultLanguage().iso;
        variables.currency = new backend.core.com.currency().getCurrency().iso;

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



    public struct function getPriceData(required numeric price) {

        local.priceData = structNew();
        local.priceData['price'] = arguments.price;
        local.priceData['vat'] = variables.vat;
        local.priceData['vat_type'] = variables.vat_type;
        local.priceData['isNet'] = variables.isNet;
        local.priceData['currency'] = variables.currency;

        // Calc prices
        local.objInvoice = new backend.core.com.invoices();

        local.vat_amount = local.objInvoice.calcVat(arguments.price, variables.isNet, variables.vat);
        local.subtotal_price = arguments.price;

        // Add up subtotal and vat
        if (variables.isNet eq 1) {
            local.total_price = local.subtotal_price + local.vat_amount;
        } else {
            local.total_price = local.subtotal_price;
        }

        // Define vat text and sum
        if (variables.isNet eq 1) {
            if (variables.vat_type eq 1) {
                local.priceData['vat_text']  = application.objLanguage.getTrans('txtPlusVat', variables.language) & ' ' & variables.vat & '%: ' & variables.currency & ' ' & lsCurrencyFormat(local.vat_amount, "none");
            } else if (variables.vat_type eq 3) {
                local.total_price = local.subtotal_price;
                local.priceData['vat_text']  = "";
            } else {
                local.total_price = local.subtotal_price;
                local.priceData['vat_text']  = application.objLanguage.getTrans('txtTotalExcl', variables.language);
            }
        } else {
            if (variables.vat_type eq 1) {
                local.priceData['vat_text']  = application.objLanguage.getTrans('txtVatIncluded', variables.language) & ' ' & variables.vat & '%' & ': ' & variables.currency & ' ' & lsCurrencyFormat(local.vat_amount, "none");
            } else if (variables.vat_type eq 3) {
                local.total_price = local.subtotal_price;
                local.priceData['vat_text']  = "";
            } else {
                local.total_price = local.subtotal_price;
                local.priceData['vat_text']  = application.objLanguage.getTrans('txtTotalExcl', variables.language);
            }
        }

        // Round total according customers setting
        local.total_price = objInvoice.roundAmount(local.total_price, application.objSettings.getSetting('settingRoundFactor'));

        local.priceData['priceAfterVAT'] = local.total_price;

        return local.priceData;


    }

}