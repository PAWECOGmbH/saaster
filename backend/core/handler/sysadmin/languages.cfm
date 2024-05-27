
<cfscript>


if (structKeyExists(form, "modal_lng")) {

    param name="form.field" default="";
    param name="form.id" default="";
    param name="form.referer" default="";
    param name="form.table" default="";
    param name="form.key" default="";

    field = form.field;
    thisID = form.id;
    referer = form.referer;
    table = form.table;
    key = form.key;

    /* if(referer eq "/sysadmin/mappings##frontend" and field neq "strhtmlcodes"){
        loop list=form.fieldnames index="i" {
            if (listFirst(i, "_") eq "text") {
                text_value = evaluate(i);
                text_value = application.objGlobal.cleanUpText(text_value);
                form[i] = text_value;
            }
        }
    } else if (referer eq "/sysadmin/mappings##frontend" and field eq "strhtmlcodes"){
        loop list=form.fieldnames index="i" {
            if (listFirst(i, "_") eq "text") {
                text_value = evaluate(i);
                text_value = toString(binaryDecode(text_value, "base64"));
                text_value = left(text_value, 3000);
                form[i] = text_value;
            }
        }
    } */

    try {

        loop list=form.fieldnames index="i" {

            if (listFirst(i, "_") eq "text") {

                thisLng = listLast(i, "_");
                text_value = evaluate(i);

                //Does the entry already exist?
                qCheck = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        thisLng: {type: "varchar", value: thisLng},
                        thisID: {type: "numeric", value: thisID}
                    },
                    sql = "
                        SELECT #key#
                        FROM #table#
                        WHERE #key# = :thisID
                        AND intLanguageID =
                        (
                            SELECT intLanguageID
                            FROM languages
                            WHERE strLanguageISO = :thisLng
                        )
                    "
                )

                if (qCheck.recordCount) {

                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            thisText: {type: "nvarchar", value: text_value},
                            thisLng: {type: "varchar", value: thisLng},
                            thisID: {type: "numeric", value: thisID}
                        },
                        sql = "
                            UPDATE #table#
                            SET #field# = :thisText
                            WHERE #key# = :thisID
                            AND intLanguageID =
                            (
                                SELECT intLanguageID
                                FROM languages
                                WHERE strLanguageISO = :thisLng
                            )
                        "
                    )

                } else {

                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            thisText: {type: "nvarchar", value: text_value},
                            thisLng: {type: "varchar", value: thisLng},
                            thisID: {type: "numeric", value: thisID}
                        },
                        sql = "
                            INSERT INTO #table# (#key#, intLanguageID, #field#)
                            VALUES
                            (
                                :thisID,
                                (
                                    SELECT intLanguageID
                                    FROM languages
                                    WHERE strLanguageISO = :thisLng
                                ),
                                :thisText
                            )
                        "
                    )

                }

            }

        }

        getAlert('Saved!');

    } catch (e) {

        getAlert(e.message, 'danger');

    }

    location url="#application.mainURL##referer#" addtoken="false";

}



if (structKeyExists(form, "edit_language")) {

    if (isNumeric(form.edit_language)) {

        qOldPrio = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisID: {type: "numeric", value: form.edit_language}
            },
            sql = "
                SELECT intPrio
                FROM languages
                WHERE intLanguageID = :thisID
            "
        )

        param name="form.lng_en" default="";
        param name="form.lng_own" default="";
        param name="form.iso" default="";

        chooseable = structKeyExists(form, "chooseable") ? 1 : 0;

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                lng_en: {type: "nvarchar", value: lng_en},
                lng_own: {type: "varchar", value: lng_own},
                iso: {type: "varchar", value: iso},
                chooseable: {type: "boolean", value: chooseable},
                thisID: {type: "numeric", value: form.edit_language}
            },
            sql = "
                UPDATE languages
                SET strLanguageISO = :iso,
                    strLanguageEN = :lng_en,
                    strLanguage = :lng_own,
                    blnChooseable = :chooseable
                WHERE intLanguageID = :thisID
            "
        )

        location url="#application.mainURL#/sysadmin/languages?reinit=1" addtoken="false";

    }

}


if (structKeyExists(form, "new_language")) {

    param name="form.lng_en" default="";
    param name="form.lng_own" default="";
    param name="form.iso" default="";

    chooseable = structKeyExists(form, "chooseable") ? 1 : 0;

    try {

        qNewPrio = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT MAX(intPrio)+1 as newPrio
                FROM languages
            "
        )

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                lng_en: {type: "varchar", value: left(form.lng_en, 20)},
                lng_own: {type: "varchar", value: left(form.lng_own, 20)},
                iso: {type: "varchar", value: left(form.iso, 2)},
                chooseable: {type: "boolean", value: chooseable},
                newPrio: {type: "numeric", value: qNewPrio.newPrio}
            },
            sql = "
                ALTER TABLE system_translations ADD COLUMN strString#ucase(form.iso)# longtext;
                ALTER TABLE custom_translations ADD COLUMN strString#ucase(form.iso)# longtext;
                INSERT INTO languages (strLanguageISO, strLanguageEN, strLanguage, intPrio, blnDefault, blnChooseable)
                VALUES (:iso, :lng_en, :lng_own, :newPrio, 0, :chooseable)
            "
        )

        getAlert('New language saved!', 'success');

    } catch (e) {

        getAlert(e.message, 'danger');

    }

    location url="#application.mainURL#/sysadmin/languages?reinit=1" addtoken="false";


}


if (structKeyExists(url, "delete_language")) {

    if (isNumeric(url.delete_language)) {

        qLanguage = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisID: {type: "numeric", value: url.delete_language}
            },
            sql = "
                SELECT strLanguageISO, intPrio
                FROM languages
                WHERE intLanguageID = :thisID
            "
        )

        try {

            queryExecute(
                options = {datasource = application.datasource},
                sql = "
                    ALTER TABLE system_translations DROP COLUMN strString#ucase(qLanguage.strLanguageISO)#;
                    ALTER TABLE custom_translations DROP COLUMN strString#ucase(qLanguage.strLanguageISO)#;
                "
            )

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    thisID: {type: "numeric", value: url.delete_language},
                    currPrio: {type: "numeric", value: qLanguage.intPrio}
                },
                sql = "
                    DELETE FROM languages WHERE intLanguageID = :thisID;
                    UPDATE languages SET intPrio = intPrio-1 WHERE intPrio > :currPrio
                "
            )

            // Set all customers who have the language that is being deleted, to the default language.
            getLngCount = application.objLanguage.getAllLanguages();
            if (getLngCount.recordCount eq 1) {
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        oldlng: {type: "varchar", value: qLanguage.strLanguageISO},
                        newlng: {type: "varchar", value: application.objLanguage.getDefaultLanguage().iso}
                    },
                    sql = "
                        UPDATE users
                        SET strLanguage = :newlng
                        WHERE strLanguage = :oldlng
                    "
                )
            }

            // If there is only one language, make sure that it's choosable
            getLngCount = application.objLanguage.getAllLanguages();
            if (getLngCount.recordCount eq 1) {
                queryExecute(
                    options = {datasource = application.datasource},
                    sql = "
                        UPDATE languages
                        SET blnChooseable = 1
                    "
                )
            }

            getAlert('Language deleted successfully!', 'success');


        } catch (any e) {

            getAlert(e.message, 'danger');

        }


        location url="#application.mainURL#/sysadmin/languages?reinit=1" addtoken="false";


    }

}




</cfscript>