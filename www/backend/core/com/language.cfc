
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
            local.thisLang = application.objLanguage.getDefaultLanguage().iso;
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
    public string function toLocale(required string language) {

        // normalize
        var l = lcase(trim(arguments.language ?: ""));

        if (!len(l)) {
            return "english (united states)";
        }

        // Accept-Language uses hyphen, switch uses underscore
        l = replace(l, "-", "_", "all");

        // Handle display-name variants that slip through
        if (l eq "spanish (mexican)") {
            return "spanish (mexico)";
        }

        switch (l) {
            case "nl_be": return "dutch (belgium)";
            case "nl_nl":
            case "nl_nk": return "dutch (netherlands)";

            case "en_au": return "english (australia)";
            case "en_ca": return "english (canada)";
            case "en_gb": return "english (united kingdom)";
            case "en_nz": return "english (new zealand)";
            case "en":
            case "en_us": return "english (united states)";

            case "fr_be": return "french (belgium)";
            case "fr_ca": return "french (canada)";
            case "fr":    return "french (france)";
            case "fr_ch": return "french (switzerland)";

            case "de_at": return "german (austria)";
            case "de_de":
            case "de":    return "german (germany)";
            case "de_ch": return "german (switzerland)";

            case "it_it": return "italian (italy)";
            case "it_ch": return "italian (switzerland)";

            case "no_no": return "norwegian (norway)";
            case "no_no@nynorsk": return "norwegian (norway, nynorsk)";

            case "pl_pl": return "polish (poland)";

            case "pt_br": return "portuguese (brazil)";
            case "pt_pt": return "portuguese (portugal)";

            case "es_mx": return "spanish (mexico)";
            case "es_es": return "spanish (spain)";
            case "es_ar": return "spanish (argentina)";
            case "es_cl": return "spanish (chile)";
            case "es_co": return "spanish (colombia)";
            case "es":    return "spanish (spain)";

            case "ru":
            case "ru_ru": return "russian (russia)";

            case "sv_se": return "swedish (sweden)";
            case "ja_jp": return "japanese (japan)";
            case "ko_kr": return "korean (south korea)";
            case "zh":    return "chinese (china)";
            case "zh_hk": return "chinese (hong kong sar china)";
            case "zh_tw": return "chinese (taiwan)";

            default: return "english (united states)";
        }
    }

}

