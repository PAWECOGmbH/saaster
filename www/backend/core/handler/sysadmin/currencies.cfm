
<cfscript>

    if (structKeyExists(form, "edit_currency")) {

        if (isNumeric(form.edit_currency)) {

            if (structKeyExists(form, "default")) {
                queryExecute(
                    options = {datasource = application.datasource},
                    sql = "
                        UPDATE currencies
                        SET blnDefault = 0
                    "
                )
                itsDefault = 1;
            } else {
                itsDefault = 0;
            }
            if (structKeyExists(form, "active")) {
                active = 1;
            } else {
                active = 0;
            }


            qOldPrio = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    thisID: {type: "numeric", value: form.edit_currency}
                },
                sql = "
                    SELECT intPrio
                    FROM currencies
                    WHERE intCurrencyID = :thisID
                "
            )

            param name="form.lng_en" default="";
            param name="form.lng_own" default="";
            param name="form.iso" default="";
            param name="form.sign" default="";

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    lng_en: {type: "nvarchar", value: left(form.lng_en, 20)},
                    lng_own: {type: "nvarchar", value: left(form.lng_own, 20)},
                    iso: {type: "varchar", value: left(form.iso, 3)},
                    sign: {type: "varchar", value: left(form.sign, 3)},
                    thisID: {type: "numeric", value: form.edit_currency},
                    active: {type: "boolean", value: active},
                    default: {type: "boolean", value: itsDefault}
                },
                sql = "
                    UPDATE currencies
                    SET strCurrencyISO = :iso,
                        strCurrencyEN = :lng_en,
                        strCurrency = :lng_own,
                        strCurrencySign = :sign,
                        blnActive = :active,
                        blnDefault = :default
                    WHERE intCurrencyID = :thisID
                "
            )

            getAlert('Changes saved!', 'success');
            location url="#application.mainURL#/sysadmin/currencies" addtoken="false";

        }

    }

    if (structKeyExists(form, "new_currency")) {

        param name="form.lng_en" default="";
        param name="form.lng_own" default="";
        param name="form.iso" default="";
        param name="form.sign" default="";

        if (structKeyExists(form, "active")) {
            active = 1;
        } else {
            active = 0;
        }

        qNewPrio = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT MAX(intPrio)+1 as newPrio
                FROM currencies
            "
        )

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                lng_en: {type: "nvarchar", value: left(form.lng_en, 20)},
                lng_own: {type: "nvarchar", value: left(form.lng_own, 20)},
                iso: {type: "varchar", value: left(form.iso, 3)},
                sign: {type: "varchar", value: left(form.sign, 3)},
                active: {type: "boolean", value: active},
                newPrio: {type: "numeric", value: qNewPrio.newPrio}
            },
            sql = "
                INSERT INTO currencies (strCurrencyISO, strCurrencyEN, strCurrency, strCurrencySign, intPrio, blnDefault, blnActive)
                VALUES (:iso, :lng_en, :lng_own, :sign, :newPrio, 0, :active)
            "
        )

        getAlert('New currency saved!', 'success');
        location url="#application.mainURL#/sysadmin/currencies" addtoken="false";

    }


    if (structKeyExists(url, "delete_currency")) {

        if (isNumeric(url.delete_currency)) {

            qCurrencies = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    thisID: {type: "numeric", value: url.delete_currency}
                },
                sql = "
                    SELECT strCurrencyISO, intPrio
                    FROM currencies
                    WHERE intCurrencyID = :thisID
                "
            )

            try {

                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        thisID: {type: "numeric", value: url.delete_currency},
                        currPrio: {type: "numeric", value: qCurrencies.intPrio}
                    },
                    sql = "
                        DELETE FROM currencies WHERE intCurrencyID = :thisID;
                        UPDATE currencies SET intPrio = intPrio-1 WHERE intPrio > :currPrio
                    "
                )

                getAlert('Currency deleted successfully!', 'success');


            } catch (any e) {

                getAlert(e.message, 'danger');

            }

            location url="#application.mainURL#/sysadmin/currencies" addtoken="false";


        }

    }

</cfscript>