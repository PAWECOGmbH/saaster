
component displayname="language" output="false" {


    // Initialising the language variables
    public struct function initLanguages() {

        // Get all languages in the database
        local.qLanguages = getAllLanguages();

        loop query="local.qLanguages" {

            local.langIso = local.qLanguages.strLanguageISO
            local.language[local.langIso] = structNew();

            // Get translations of the language
            local.qTranslations = queryExecute(
                options = {datasource = application.datasource},
                sql = "
                    SELECT strVariable, strString#local.langIso#
                    FROM system_translations
                    UNION
                    SELECT strVariable, strString#local.langIso#
                    FROM custom_translations
                "
            )

            local.translations = structNew();
            loop query="local.qTranslations" {
                local.translations[qTranslations.strVariable] = qTranslations['strString' & local.langIso];
            }

            local.language[local.langIso] = local.translations;

        }


        return local.language;


    }


    // Get all languages
    public query function getAllLanguages(string whereFilter) {

        param name="arguments.whereFilter" default="";

        local.qAllLanguages = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM languages
                #arguments.whereFilter#
                ORDER BY intPrio
            "
        )

        return local.qAllLanguages;

    }


    // Translations
    public string function getTrans(required string stringToTrans, string thisLanguage) {

        local.translatedString = "--undefined--";

        if (structKeyExists(arguments, "thisLanguage") and len(trim(arguments.thisLanguage))) {
            local.thisLang = arguments.thisLanguage;
        } else if (structKeyExists(session, "lng")) {
            local.thisLang = session.lng;
        } else {
            local.thisLang = getDefaultLanguage().iso;
        }

        local.searchString = structFindKey(application.langStruct[#local.thisLang#], arguments.stringToTrans, "one");

        if (isArray(local.searchString) and !arrayIsEmpty(local.searchString)) {
            local.translatedString = local.searchString[1].value;
        }

        return local.translatedString;


    }


    // Get the language of the browser and return language and code
    public struct function getBrowserLng(required string browserInfo) {

        local.browserData = structNew();

        local.firstString = listFirst(arguments.browserInfo, ";");
        local.checkLeft = listFirst(firstString, ",");
        if (find("-", local.checkLeft)) {
            local.lng_code = listFirst(local.firstString, ",");
        } else {
            local.lng_code = listLast(local.firstString, ",");
        }
        local.client_lang = replace(listfirst(lng_code), "-", "_", "ALL");
        local.lng = left(local.lng_code, 2);

        local.browserData['code'] = local.client_lang;
        local.browserData['lng'] = local.lng;

        return local.browserData;

    }


    // Get the default language as struct
    public struct function getDefaultLanguage() {

        local.defaultLanguage = structNew();
        local.defaultLanguage['lngID'] = "1";
        local.defaultLanguage['iso'] = "en";
        local.defaultLanguage['lngEN'] = "English";
        local.defaultLanguage['language'] = "English";

        qDefLng = queryExecute(

            options = {datasource = application.datasource},
            sql = "
                SELECT intLanguageID, strLanguageISO, strLanguageEN, strLanguage
                FROM languages
                WHERE blnDefault = 1
            "
        )

        if (qDefLng.recordCount) {

            local.defaultLanguage['lngID'] = qDefLng.intLanguageID;
            local.defaultLanguage['iso'] = qDefLng.strLanguageISO;
            local.defaultLanguage['lngEN'] = qDefLng.strLanguageEN;
            local.defaultLanguage['language'] = qDefLng.strLanguage;

        }

        return local.defaultLanguage;

    }


    // Get language from iso or id
    public struct function getAnyLanguage(any reqLng) {

        if (structKeyExists(arguments, "reqLng")) {

            if ( isNumeric(arguments.reqLng) ) {

                local.qGetLanguage = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        lngID: {type: "numeric", value: arguments.reqLng}
                    },
                    sql = "
                        SELECT intLanguageID, strLanguageISO, strLanguageEN, strLanguage
                        FROM languages
                        WHERE intLanguageID = :lngID
                    "
                )

            } else {

                local.qGetLanguage = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        lngIso: {type: "varchar", value: arguments.reqLng}
                    },
                    sql = "
                        SELECT intLanguageID, strLanguageISO, strLanguageEN, strLanguage
                        FROM languages
                        WHERE strLanguageISO = :lngIso
                    "
                )

            }

            if (qGetLanguage.recordCount) {

                local.language['lngID'] = local.qGetLanguage.intLanguageID;
                local.language['iso'] = local.qGetLanguage.strLanguageISO;
                local.language['lngEN'] = local.qGetLanguage.strLanguageEN;
                local.language['language'] = local.qGetLanguage.strLanguage;

                return local.language;

            }


        }

        return getDefaultLanguage();

    }



    // Convert the language code of the browser into the locale of CF
    public string function toLocale(string language) {

        if (structKeyExists(arguments, "language")) {

            switch(arguments.language) {

                case "nl_BE":
                    local.locale = "Dutch (Belgian)";
                    break;

                case value="nl_NK":
                    local.locale = "Dutch (Standard)";
                    break;

                case value="en_AU":
                    local.locale = "English (Australian)";
                    break;

                case value="en_CA":
                    local.locale = "English (Canadian)";
                    break;

                case value="en_GB":
                    local.locale = "English (UK)";
                    break;

                case value="en_NZ":
                    local.locale = "English (New Zealand)";
                    break;

                case value="en":
                    local.locale = "English (US)";
                    break;

                case value="en_US":
                    local.locale = "English (US)";
                    break;

                case value="fr_BE":
                    local.locale = "French (Belgian)";
                    break;

                case value="fr_CA":
                    local.locale = "French (Canadian)";
                    break;

                case value="fr":
                    local.locale = "French (Standard)";
                    break;

                case value="fr_CH":
                    local.locale = "French (Swiss)";
                    break;

                case value="de_AT":
                    local.locale = "German (Austrian)";
                    break;

                case value="de_DE":
                    local.locale = "German (Germany)";
                    break;

                case value="de":
                    local.locale = "German (Standard)";
                    break;

                case value="de_CH":
                    local.locale = "German (Swiss)";
                    break;

                case value="it_IT":
                    local.locale = "Italian (Standard)";
                    break;

                case value="it_CH":
                    local.locale = "Italian (Swiss)";
                    break;

                case value="no_NO":
                    local.locale = "Norwegian (Bokmal)";
                    break;

                case value="no_NO@nynorsk":
                    local.locale = "Norwegian (Nynorsk)";
                    break;

                case value="pl_PL":
                    local.locale = "Polish (Poland)";
                    break;

                case value="pt_BR":
                    local.locale = "Portuguese (Brazilian)";
                    break;

                case value="pt_PT":
                    local.locale = "Portuguese (Standard)";
                    break;

                case value="es_MX":
                    local.locale = "Spanish (Mexican)";
                    break;

                case value="es_ES":
                    local.locale = "Spanish (Standard)";
                    break;

                case value="ru":
                    local.locale = "ru_RU";
                    break;

                case value="ru_RU":
                    local.locale = "ru_RU";
                    break;

                case value="sv_SE":
                    local.locale = "Swedish";
                    break;

                case value="ja_JP":
                    local.locale = "Japanese";
                    break;

                case value="ko_KR":
                    local.locale = "Korean";
                    break;

                case value="zh":
                    local.locale = "Chinese (China)";
                    break;

                case value="zh_HK":
                    local.locale = "Chinese (Hong Kong)";
                    break;

                case value="zh_TW":
                    local.locale = "Chinese (Taiwan)";
                    break;

                default:
                   local.locale = "English (US)";
                   break;
            }


        } else {

            local.locale = "English (US)";

        }

        return local.locale;

    }

}

