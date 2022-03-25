<cfscript>

if (structKeyExists(form, "currencyID")) {

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            currID: {type: "numeric", value: form.currencyID}
        },
        sql = "
            UPDATE setup_saaster
            SET intDefaultCurrencyID = :currID
        "
    )

    qSetup = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT *
            FROM setup_saaster
        "
    )

    // take over default values
    queryExecute(
        options = {datasource = application.datasource},
        params = {
            countryID: {type: "numeric", value: qSetup.intDefaultCountryID},
            langID: {type: "numeric", value: qSetup.intDefaultLanguageID},
            currID: {type: "numeric", value: qSetup.intDefaultCurrencyID},
        },
        sql = "
            UPDATE countries SET blnDefault = 0;
            UPDATE countries SET blnDefault = 1 WHERE intCountryID = :countryID;

            UPDATE languages SET blnDefault = 0;
            UPDATE languages SET blnDefault = 1, blnChooseable = 1 WHERE intLanguageID = :langID;

            UPDATE currencies SET blnDefault = 0, blnActive = 0;
            UPDATE currencies SET blnDefault = 1, blnActive = 1 WHERE intCurrencyID = :currID;
        "
    )
    if (listLen(qSetup.strCountryList)) {
        thisPrio = 1;
        loop list=qSetup.strCountryList index="i" {
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    countryID: {type: "numeric", value: i},
                    thisPrio: {type: "numeric", value: thisPrio}
                },
                sql = "
                    UPDATE countries
                    SET blnActive = 1,
                        intPrio = :thisPrio
                    WHERE intCountryID = :countryID
                "
            )
            thisPrio++;
        }
    }

    // Set default language
    session.lng = application.objGlobal.getDefaultLanguage().iso;

    queryExecute(
        options = {datasource = application.datasource},
        sql = "
            UPDATE setup_saaster
            SET blnFinished = 1;
        "
    )

    getAlert('Setup done! Please register now with a sysadmin e-mail address.');
    location url="#application.mainURL#/register?reinit=3" addtoken="false";


} else {

    location url="step4.cfm" addtoken="false";

}

</cfscript>