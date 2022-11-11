<cfsetting requestTimeOut="1000">

<cfscript>
    switch(url.do) {
        case "trans":
            param name="form.apiKey" default=0;
            param name="form.lng" default=0;
            param name="form.apiType" default=0;
            param name="form.lngID" default=0;

            // Translate
            if (form.apiKey neq 0 and form.lng neq 0) {
                try {
                    // Set "Pro" or "Free" API-URL
                    deepLPro = "https://api.deepl.com/v2/translate?auth_key=";
                    deepLFree = "https://api-free.deepl.com/v2/translate?auth_key=";

                    if(form.apiType eq 0){
                        deeplURL = deepLFree;
                    }else{
                        deeplURL = deepLPro;
                    }

                    // Test if key is valid
                    deeplTest = deeplURL & form.apiKey;
                    deeplTest = deeplTest & "&text=test";
                    deeplTest = deeplTest & "&source_lang=en" & "&target_lang=" & form.lng;
                    cfhttp( url=deeplTest, resolveurl=true, method="get", timeout="30");

                    // Test if language is supported
                    lngSupported = cfhttp.filecontent;
                    lngSupported = findNoCase("target_lang", lngSupported, 0);

                    // If the provided API key is not valid, redirect back to translate page
                    if(cfhttp.status_code eq 403){
                        getAlert('The provided API key is not valid!', 'warning');
                        location url="step2b.cfm?newlng=#form.lngID#" addtoken="false";
                    }

                    if(lngSupported gt 0){
                        getAlert('The requested language is not supported by DeepL!', 'warning');
                        location url="step2b.cfm?newlng=#form.lngID#" addtoken="false";
                    }

                    gettext = queryExecute(
                        options = {datasource = application.datasource},
                        sql = "
                            SELECT strStringEN, strVariable
                            FROM system_translations
                        "
                    )

                    loop query = gettext {
                        deepl = deeplURL & form.apiKey;
                        deepl = deepl & "&text=" & urlencodedformat(gettext.strStringEN);
                        deepl = deepl & "&source_lang=en" & "&target_lang=" & form.lng;

                        cfhttp( url=deepl, resolveurl=true, method="get", timeout="30" );
                        deepl_answer = deserializeJSON(cfhttp.FileContent);

                        if(structKeyExists(deepl_answer, "translations")) {
                            translatedText = deepl_answer.translations[1].text;
                            queryExecute(
                                options = {datasource = application.datasource},
                                params = {
                                    transText: {type: "varchar", value: translatedText},
                                    changedText: {type: "varchar", value: strVariable}
                                },
                                sql = "
                                    UPDATE system_translations
                                    SET strString#form.lng# = :transText
                                    WHERE strVariable = :changedText
                                "
                            )
                        }
                    }

                    getAlert('The translation finished successfully!');
                    location url="step2b.cfm?newlng=#form.lngID#" addtoken="false";

                } catch(any e){

                    getAlert('Something went wrong...', 'danger');
                    location url="step2b.cfm?newlng=#form.lngID#" addtoken="false";
                }
            }

        case "save":
            strVariable = form.fieldToEdit;
            textTrans = form.text;

            try {
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        textTrans: {type: "nvarchar", value: textTrans},
                        textVar: {type: "varchar", value: strVariable}
                    },
                    sql = "
                        UPDATE system_translations
                        SET strString#form.lng# = :textTrans
                        WHERE strVariable = :textVar
                    "
                );

                getAlert('Successfully saved!');
                location url="step2b.cfm?newlng=#form.lngID####form.anchor#" addtoken="false";

            } catch(any e){

                getAlert('Something went wrong...', 'danger');
                location url="step2b.cfm?newlng=#form.lngID####form.anchor#" addtoken="false";
            }
    }
</cfscript>