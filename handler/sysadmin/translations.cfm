
<cfscript>

qAllLanguages = application.objGlobal.getAllLanguages();


if (structKeyExists(form, "new_variable")) {

    param name="form.variable" default="";

    qCheckDouble = queryExecute(
        options = {datasource = application.datasource},
        params = {
            variable: {type: "varchar", value: form.variable}
        },
        sql = "
            SELECT strVariable
            FROM custom_translations
            WHERE strVariable = :variable
        "
    )

    if (qCheckDouble.recordCount) {

        getAlert('This variable is already in use!', 'danger');
        location url="#application.mainURL#/sysadmin/translations" addtoken="false";

    } else {

        savecontent variable="mySQL" {

            writeOutput("INSERT INTO custom_translations (strVariable");

            loop query = qAllLanguages {
                writeOutput(",strString#qAllLanguages.strLanguageISO#");
            }

            writeOutput(") VALUES ('#form.variable#'");

            loop query = qAllLanguages {
                writeOutput(",'#evaluate('form.text_#qAllLanguages.strLanguageISO#')#'");
            }

            writeOutput(")");

        }

        cfquery( datasource=application.datasource ) {
            writeOutput(mySQL);
        }

    }

    getAlert('Variable added successfully.', 'success');
    session.search = form.variable;
    location url="#application.mainURL#/sysadmin/translations" addtoken="false";

}


if (structKeyExists(url, "delete_trans")) {

    if (isNumeric(url.delete_trans)) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                transID: {type: "numeric", value: url.delete_trans}
            },
            sql = "
                DELETE FROM custom_translations WHERE intCustTransID = :transID
            "
        )

        getAlert('Translation deleted', 'success');
        structDelete(session, "search");
        location url="#application.mainURL#/sysadmin/translations" addtoken="false";

    }

}



if (structKeyExists(form, "edit_variable")) {

    if (isNumeric(form.edit_variable)) {

        savecontent variable="mySQL" {

            writeOutput("UPDATE custom_translations SET intCustTransID = intCustTransID ");

            loop query = qAllLanguages {
                writeOutput(", strString#qAllLanguages.strLanguageISO# = '#evaluate('form.text_#qAllLanguages.strLanguageISO#')#' ");
            }
            writeOutput("WHERE intCustTransID = #form.edit_variable#");
        }

        cfquery( datasource=application.datasource ) {
            writeOutput(mySQL);
        }

        getAlert('Translation saved!', 'success');
        location url="#application.mainURL#/sysadmin/translations" addtoken="false";
    }

}


if (structKeyExists(form, "edit_syst_variable")) {

    if (isNumeric(form.edit_syst_variable)) {

        savecontent variable="mySQL" {

            writeOutput("UPDATE system_translations SET intSystTransID = intSystTransID ");

            loop query = qAllLanguages {
                writeOutput(", strString#qAllLanguages.strLanguageISO# = '#evaluate('form.text_#qAllLanguages.strLanguageISO#')#' ");
            }
            writeOutput("WHERE intSystTransID = #form.edit_syst_variable#");
        }

        cfquery( datasource=application.datasource ) {
            writeOutput(mySQL);
        }

        getAlert('Translation saved!', 'success');
        location url="#application.mainURL#/sysadmin/translations?tr=system" addtoken="false";
    }

}



</cfscript>