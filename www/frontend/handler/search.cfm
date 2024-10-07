
<cfscript>

    if (structKeyExists(form, "searchDataJob") or structKeyExists(form, "searchDataSpec")) {

        formStruct = structNew();
        loop list=form.fieldnames index="i" {
            formStruct["#i#"] = form[i];
        }

        session.searchData = formStruct;

        if (structKeyExists(form, "searchDataJob")) {
            location url="#application.mainURL#/stelle-suchen" addtoken="false";
        }

        if (structKeyExists(form, "searchDataSpec")) {
            location url="#application.mainURL#/fachkraefte-suchen" addtoken="false";
        }

    }

    location url="#application.mainURL#" addtoken="false";

</cfscript>