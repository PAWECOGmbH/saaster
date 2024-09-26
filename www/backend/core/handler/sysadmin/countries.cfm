<cfscript>


if (structKeyExists(form, "edit_country")) {

    if (isNumeric(form.edit_country)) {

        param name="form.country" default="";
        param name="form.languageID" default="";
        param name="form.locale" default="";
        param name="form.iso1" default="";
        param name="form.iso2" default="";
        param name="form.currency" default="";
        param name="form.region" default="";
        param name="form.subregion" default="";
        param name="form.timezone" default="";
        param name="form.flag" default="";
        param name="form.prio" default="1";

        if (structKeyExists(form, "default")) {
            queryExecute(
                options = {datasource = application.datasource},
                sql = "
                    UPDATE countries
                    SET blnDefault = 0
                "
            )
            itsDefault = 1;
        } else {
            itsDefault = 0;
        }

        //Set priority
        application.objGlobal.recalcPrio('countries', form.prio, form.edit_country, 'blnActive = 1');

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                country: {type: "nvarchar", value: form.country},
                languageID: {type: "numeric", value: form.languageID},
                locale: {type: "varchar", value: form.locale},
                iso1: {type: "varchar", value: form.iso1},
                iso2: {type: "varchar", value: form.iso2},
                currency: {type: "varchar", value: form.currency},
                region: {type: "nvarchar", value: form.region},
                subregion: {type: "nvarchar", value: form.subregion},
                timezoneID: {type: "numeric", value: form.timezoneID},
                flag: {type: "varchar", value: form.flag},
                default: {type: "boolean", value: itsDefault},
                thisID: {type: "numeric", value: form.edit_country}
            },
            sql = "
                UPDATE countries
                SET strCountryName = :country,
                    intLanguageID = :languageID,
                    strLocale = :locale,
                    strISO1 = :iso1,
                    strISO2 = :iso2,
                    strCurrency = :currency,
                    strRegion = :region,
                    strSubRegion = :subregion,
                    intTimezoneID = :timezoneID,
                    strFlagSVG = :flag,
                    blnDefault = :default
                WHERE intCountryID = :thisID
            "
        )

        getAlert('Country saved!');
        location url="#application.mainURL#/sysadmin/countries" addtoken="false";


    }

}


if (structKeyExists(url, "remove_country")) {

    if (isNumeric(url.remove_country)) {

        qCountry = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisID: {type: "numeric", value: url.remove_country}
            },
            sql = "
                SELECT intPrio
                FROM countries
                WHERE intCountryID = :thisID
            "
        )

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisID: {type: "numeric", value: url.remove_country},
                currPrio: {type: "numeric", value: qCountry.intPrio}
            },
            sql = "
                UPDATE countries SET blnActive = 0 WHERE intCountryID = :thisID;
                UPDATE countries SET intPrio = intPrio-1 WHERE intPrio > :currPrio AND blnActive = 1
            "
        )

        getAlert('Country removed.');
        location url="#application.mainURL#/sysadmin/countries" addtoken="false";

    }

}


if (structKeyExists(form, "new_country")) {

    param name="form.country" default="";
    param name="form.languageID" default="";
    param name="form.locale" default="";
    param name="form.iso1" default="";
    param name="form.iso2" default="";
    param name="form.currency" default="";
    param name="form.region" default="";
    param name="form.subregion" default="";
    param name="form.timezone" default="";
    param name="form.flag" default="";

    if (structKeyExists(form, "default")) {
        queryExecute(
            options = {datasource = application.datasource},
            sql = "
                UPDATE countries
                SET blnDefault = 0
            "
        )
        itsDefault = 1;
    } else {
        itsDefault = 0;
    }

    qNewPrio = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT COALESCE(MAX(intPrio), 0)+1 as newPrio
            FROM countries
            WHERE blnActive = 1
        "
    )

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            country: {type: "nvarchar", value: form.country},
            languageID: {type: "numeric", value: form.languageID},
            locale: {type: "varchar", value: form.locale},
            iso1: {type: "varchar", value: form.iso1},
            iso2: {type: "varchar", value: form.iso2},
            currency: {type: "varchar", value: form.currency},
            region: {type: "nvarchar", value: form.region},
            subregion: {type: "nvarchar", value: form.subregion},
            timezoneID: {type: "numeric", value: form.timezoneID},
            flag: {type: "varchar", value: form.flag},
            default: {type: "boolean", value: itsDefault},
            active: {type: "boolean", value: 1},
            newPrio: {type: "numeric", value: qNewPrio.newPrio}
        },
        sql = "
            INSERT INTO countries (strCountryName, intLanguageID, strLocale, strISO1, strISO2, strCurrency, strRegion, strSubRegion,
                intTimezoneID, strFlagSVG, blnActive, blnDefault, intPrio)
            VALUES (:country, :languageID, :locale, :iso1, :iso2, :currency, :region, :subregion,
                :timezoneID, :flag, :active, :default, :newPrio)
        "
    )

    getAlert('New country saved!');
    session.c_search = form.country;
    location url="#application.mainURL#/sysadmin/countries" addtoken="false";

}



if (structKeyExists(url, "delete_country")) {

    if (isNumeric(url.delete_country)) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisID: {type: "numeric", value: url.delete_country}
            },
            sql = "
                DELETE FROM countries WHERE intCountryID = :thisID;
            "
        )

        getAlert('Country deleted successfully!', 'success');
        location url="#application.mainURL#/sysadmin/countries/import" addtoken="false";

    }

}


if (structKeyExists(form, "import_country")) {

    if (!structKeyExists(form, "country_id")) {
        getAlert('Please choose at least one country!', 'warning');
        location url="#application.mainURL#/sysadmin/countries/import" addtoken="false";
    }

    qNexPrio = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT COALESCE(MAX(intPrio),0)+1 as nextPrio
            FROM countries
            WHERE blnActive = 1
        "
    )

    updateList = "";
    nextPrio = qNexPrio.nextPrio;
    loop list=form.country_id index="i" {
        updateList = listAppend(updateList, "UPDATE countries SET blnActive = 1, intPrio = #nextPrio# WHERE intCountryID = #i#", ";");
        nextPrio = nextPrio+1;
    }

    cfquery( datasource=application.datasource ) {
        writeOutput(updateList);
    }

    getAlert('Your countries have been imported!')
    location url="#application.mainURL#/sysadmin/countries" addtoken="false";

}


if (structKeyExists(form, "new_module")) {

    qNexPrio = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT COALESCE(MAX(intPrio),0)+1 as nextPrio
            FROM modules
        "
    )

    param name="form.module_name" default="";

    try {

        queryExecute(
            options = {datasource = application.datasource, result="newID"},
            params = {
                module_name: {type: "nvarchar", value: form.module_name},
                active: {type: "boolean", value: 0},
                bookable: {type: "boolean", value: 0},
                nextPrio: {type: "numeric", value: qNexPrio.nextPrio}
            },
            sql = "
                INSERT INTO modules (strModuleName, blnActive, blnBookable, intPrio)
                VALUES (:module_name, :active, :bookable, :nextPrio)
            "
        )

        newModuleID = newID.generatedkey;

        getAlert('Module saved. Please complete your data now.');
        location url="#application.mainURL#/sysadmin/modules/edit/#newModuleID#" addtoken="false";

    } catch (any e) {

        getAlert(e.message, 'danger');
        location url="#application.mainURL#/sysadmin/modules" addtoken="false";

    }

}

</cfscript>