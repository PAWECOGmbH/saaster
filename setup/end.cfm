<cfscript>

if (structKeyExists(form, "currencyID")) {

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            currID: {type: "numeric", value: form.currencyID},
        },
        sql = "
            UPDATE currencies SET blnDefault = 0, blnActive = 0;
            UPDATE currencies SET blnDefault = 1, blnActive = 1 WHERE intCurrencyID = :currID;
        "
    )

    qThisLng = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT strLanguageISO
            FROM languages
            WHERE blnDefault = 1
        "
    )

    // set the new language session
    session.lng = qThisLng.strLanguageISO;


    getAlert('Setup done! Please register now with a sysadmin e-mail address.');
    location url="#application.mainURL#/register?reinit=3" addtoken="false";


} else {

    location url="step3.cfm" addtoken="false";

}

</cfscript>