<cfscript>

if (structKeyExists(form, "currencyID")) {

    // take over default values
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


    getAlert('Setup done! Please register now with a sysadmin e-mail address.');
    location url="#application.mainURL#/register?reinit=3" addtoken="false";


} else {

    location url="step4.cfm" addtoken="false";

}

</cfscript>