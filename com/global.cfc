component displayname="globalFunctions" {

    <!--- SEF building --->
    public struct function getSEF(string sef_string) {

        local.returnStruct = structNew();
        local.returnStruct['thisPath'] = "";
        local.returnStruct['thisID'] = 0;
        local.returnStruct['onlyAdmin'] = false;
        local.returnStruct['onlySuperAdmin'] = false;
        local.returnStruct['onlySysAdmin'] = false;
        local.returnStruct['noaccess'] = false;

        if (len(trim(arguments.sef_string))) {

            local.sefString = arguments.sef_string;

            <!--- If the last part of the sef string is a number, remove it --->
            if (isNumeric(listLast(local.sefString, "/"))) {
                local.thisID = listLast(local.sefString, "/");
                local.returnStruct['thisID'] = thisID;
                local.sefString = replace(local.sefString, "/#local.thisID#", "", "one");
            }

            <!--- look for db entry --->
            local.qCheckSEF = queryExecute(

                options = {datasource = application.datasource},
                params = {
                    strMapping: {type: "nvarchar", value: local.sefString}
                },
                sql = "
                    SELECT strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin
                    FROM system_mappings
                    WHERE strMapping = :strMapping
                    UNION
                    SELECT strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin
                    FROM custom_mappings
                    WHERE strMapping = :strMapping
                    LIMIT 1
                "
            )

            if (local.qCheckSEF.recordCount) {
                local.returnStruct['thisPath'] = local.qCheckSEF.strPath;
                local.returnStruct['onlyAdmin'] = trueFalseFormat(local.qCheckSEF.blnOnlyAdmin);
                local.returnStruct['onlySuperAdmin'] = trueFalseFormat(local.qCheckSEF.blnOnlySuperAdmin);
                local.returnStruct['onlySysAdmin'] = trueFalseFormat(local.qCheckSEF.blnOnlySysAdmin);
            }

        } else {

            <!--- Check if someone is trying to access a cfm file manually --->
            local.thisPath = replace(replace(cgi.request_url, application.mainURL, ""), "/", "", "one");

            <!--- look for db entry --->
            local.qCheckSEF = queryExecute(

                options = {datasource = application.datasource},
                params = {
                    thisPath: {type: "nvarchar", value: local.thisPath}
                },
                sql = "
                    SELECT strPath
                    FROM system_mappings
                    WHERE strPath = :thisPath
                    UNION
                    SELECT strPath
                    FROM custom_mappings
                    WHERE strPath = :thisPath
                    LIMIT 1
                "
            )

            if (local.qCheckSEF.recordCount) {
                local.returnStruct['thisPath'] = local.thisPath;
                local.returnStruct['noaccess'] = true;
            } else {
                local.returnStruct['thisPath'] = "frontend/start.cfm";
            }



        }

        return local.returnStruct;

    }


    <!--- Initialising the language variables --->
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


    <!--- Translations --->
    public string function getTrans(required string stringToTrans, string thisLanguage) {

        local.translatedString = "--undefined--";

        if (structKeyExists(arguments, "thisLanguage") and len(trim(arguments.thisLanguage))) {
            local.thisLang = arguments.thisLanguage;
        } else if (structKeyExists(session, "lng")) {
            local.thisLang = session.lng;
        } else {
            local.thisLang = application.getLanguage.iso;
        }

        if (structKeyExists(application.langStruct, local.thisLang)) {
            local.searchString = structFindKey(application.langStruct[#local.thisLang#], arguments.stringToTrans, "one");
        } else {
            local.searchString = structFindKey(application.langStruct.en, arguments.stringToTrans, "one");
        }

        if (isArray(local.searchString) and arrayLen(local.searchString) gte 1) {
            local.translatedString = local.searchString[1].value;
        }

        return local.translatedString;


    }


    <!--- Initialising the system setting variables --->
    public struct function initSystemSettings() {

        local.settingStruct = structNew();

        local.qSettings = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT strSettingVariable, strDefaultValue
                FROM system_settings
            "
        )

        loop query="local.qSettings" {
            local.settingStruct[local.qSettings.strSettingVariable] = local.qSettings.strDefaultValue;
        }

        return local.settingStruct;

    }


    <!--- Get the custom setting variables --->
    public struct function getCustomSettings(required numeric customerID) {

        local.settingStruct = structNew();

        local.qSettings = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT customer_custom_settings.strSettingValue, custom_settings.strSettingVariable
                FROM customer_custom_settings
                INNER JOIN custom_settings ON customer_custom_settings.intCustomSettingID = custom_settings.intCustomSettingID
                WHERE customer_custom_settings.intCustomerID = :customerID
            "
        )

        loop query="local.qSettings" {
            local.settingStruct[local.qSettings.strSettingVariable] = local.qSettings.strSettingValue;
        }

        return local.settingStruct;

    }


    <!--- Get setting (system settings as well as custom settings) --->
    public string function getSetting(required string settingVariable, numeric customerID) {

        if (structKeyExists(arguments, "customerID") and isNumeric(arguments.customerID)) {

            if (structKeyExists(session, "customSettings") and structKeyExists(session.customSettings, arguments.settingVariable)) {
                local.valueString = structFindKey(session.customSettings, arguments.settingVariable, "one");
            } else {
                local.valueString = "";
            }

        } else {

            if (structKeyExists(application.systemSettingStruct, arguments.settingVariable)) {
                local.valueString = structFindKey(application.systemSettingStruct, arguments.settingVariable, "one");
            } else {
                local.valueString = "";
            }

        }

        if (isArray(local.valueString) and arrayLen(local.valueString) gte 1) {
            local.valueString = local.valueString[1].value;
        }

        return local.valueString;

    }


    <!--- Get the default language as struct --->
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

    //Get language from iso or id
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


    <!--- Create a uuid without dash, all lowercase and two ids combined  --->
    public string function getUUID() {
        return lcase(replace(createUUID(), "-", "", "all")) & lcase(replace(createUUID(), "-", "", "all"));
    }


    <!--- Alerts in diffrent colors (returns a session) --->
    public string function getAlert(required string alertVariable, string alertType) {

        param name="arguments.alertType" default="success";
        param name="session.alert" default="";


        if (len(trim(arguments.alertVariable))) {

            <!--- Text to translate --->
            local.thismessage = getTrans(arguments.alertVariable);

            <!--- If there is no variable in the db, it must be an system error message --->
            if (local.thismessage eq "--undefined--") {
                local.thismessage = arguments.alertVariable;
            }

            switch(arguments.alertType) {
                case "info": local.thisIcon = "fa-regular fa-bell"; break;
                case "warning": local.thisIcon = "fa-solid fa-triangle-exclamation"; break;
                case "danger": local.thisIcon = "fa-regular fa-face-frown"; break;
                default: local.thisIcon = "fa-solid fa-check";
            }

            cfsavecontent ( variable="local.alertHTML" ) {
                echo("
                    <div class='alert alert-important alert-#arguments.alertType# alert-dismissible' role='alert'>
                        <div class='d-flex'>
                            <div style='margin-right: 10px;'><i class='#local.thisIcon#' aria-hidden='true'></i></div>
                            <div>#local.thismessage#</div>
                        </div>
                        <a class='btn-close btn-close-white' data-bs-dismiss='alert' aria-label='close'></a>
                    </div>
                ")
            }

            session.alert = local.alertHTML;

            return session.alert;

        } else {

            return "";

        }

    }


    <!--- Hashing and salting passwords --->
    public struct function generateHash(required string thisString) {

        local.returnStruct = structNew();

        local.returnStruct['thisSalt'] = hash(generateSecretKey('AES'),'SHA-512');
        local.returnStruct['thisHash'] = hash(arguments.thisString & local.returnStruct.thisSalt,'SHA-512');

        return local.returnStruct;

    }


    <!--- Email validating --->
    public boolean function checkEmail(thisEmail) {

        local.response = true;

        if (not len(trim(arguments.thisEmail))) {
            local.response = false;
        }

        local.mailValid = reMatch("(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)", trim(arguments.thisEmail));

        if (not arrayLen(local.mailValid)) {
            local.response = false;
        }

        return local.response;

    }


    <!--- Get all countries or a country by id --->
    public query function getCountry(numeric countryID, string language) {

        param name="arguments.language" default=getDefaultLanguage().iso;

        qLngID = queryExecute(
            options = {datasource = application.datasource},
            params = {
                lang: {type: "varchar", value: arguments.language}
            },
            sql = "
                SELECT intLanguageID
                FROM languages
                WHERE strLanguageISO = :lang
            "
        )

        if (structKeyExists(arguments, "countryID") and arguments.countryID gt 0) {

            local.qCountry = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    countryID: {type: "numeric", value: arguments.countryID},
                    lngID: {type: "numeric", value: qLngID.intLanguageID}
                },
                sql = "
                    SELECT intCountryID, strLocale, intLanguageID, blnDefault, intPrio, intTimezoneID, strCurrency,
                    IF(
                        LENGTH(
                            (
                                SELECT strCountryName
                                FROM countries_trans
                                WHERE intCountryID = countries.intCountryID
                                AND intLanguageID = :lngID
                            )
                        ),
                        (
                            SELECT strCountryName
                            FROM countries_trans
                            WHERE intCountryID = countries.intCountryID
                            AND intLanguageID = :lngID
                        ),
                        countries.strCountryName
                    ) as strCountryName
                    FROM countries
                    WHERE blnActive = 1 AND intCountryID = :countryID
                    ORDER BY intPrio
                "
            )

        } else {

            local.qCountry = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    lngID: {type: "numeric", value: qLngID.intLanguageID}
                },
                sql = "
                    SELECT intCountryID, strLocale, intLanguageID, blnDefault, intPrio, intTimezoneID, strCurrency,
                    IF(
                        LENGTH(
                            (
                                SELECT strCountryName
                                FROM countries_trans
                                WHERE intCountryID = countries.intCountryID
                                AND intLanguageID = :lngID
                            )
                        ),
                        (
                            SELECT strCountryName
                            FROM countries_trans
                            WHERE intCountryID = countries.intCountryID
                            AND intLanguageID = :lngID
                        ),
                        countries.strCountryName
                    ) as strCountryName
                    FROM countries
                    WHERE blnActive = 1
                    ORDER BY intPrio
                "
            )

        }

        return local.qCountry;

    }


    // Build the needed lists for the upload form
    public struct function buildAllowedFileLists(required array imageFileTypes) {
        local.allowedFileTypesList;
        local.acceptFileTypesList;

        cfloop(array=arguments.imageFileTypes item="i" index="index") {
            if (index lt ArrayLen(arguments.imageFileTypes))
            {
                local.acceptFileTypesList =  local.acceptFileTypesList & '"' & i & '"' & ", ";
                local.allowedFileTypesList =  local.allowedFileTypesList & "." & i & ", ";
            }else {
                local.acceptFileTypesList =  local.acceptFileTypesList & '"' & i & '"';
                local.allowedFileTypesList =  local.allowedFileTypesList & "." & i;
            }
        }

        local.output = {
            "allowedFileTypesList": local.allowedFileTypesList,
            "acceptFileTypesList": local.acceptFileTypesList
        }

        return local.output
    }


    <!--- Uploading a file such as a pdf or an image --->
    public struct function uploadFile(required struct uploadArgs, required array allowedFileTypes) {

        local.allowedFileTypesList;
        local.acceptFileTypesList;

        cfloop(array=arguments.allowedFileTypes item="i" index="index") {
            local.allowedFileTypesList = local.allowedFileTypesList & i & ",";
        }

        <!--- Default variables --->
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;
        local.argsReturnValue['fileName'] = "";

        if (isStruct(arguments.uploadArgs)) {


            <!--- Set a default for all possible arguments --->
            if (structKeyExists(arguments.uploadArgs, "filePath") and len(trim(arguments.uploadArgs.filePath))) {
                local.filePath = trim(arguments.uploadArgs.filePath);
            } else {
                local.filePath = expandPath('/userdata');
            }
            if (structKeyExists(arguments.uploadArgs, "maxSize") and len(trim(arguments.uploadArgs.maxSize))) {
                local.maxSize = trim(arguments.uploadArgs.maxSize);
            } else {
                local.maxSize = '';
            }
            if (structKeyExists(arguments.uploadArgs, "maxWidth") and len(trim(arguments.uploadArgs.maxWidth))) {
                local.maxWidth = trim(arguments.uploadArgs.maxWidth);
            } else {
                local.maxWidth = '';
            }
            if (structKeyExists(arguments.uploadArgs, "maxHeight") and len(trim(arguments.uploadArgs.maxHeight))) {
                local.maxHeight = trim(arguments.uploadArgs.maxHeight);
            } else {
                local.maxHeight = '';
            }
            if (structKeyExists(arguments.uploadArgs, "makeUnique") and isBoolean(arguments.uploadArgs.makeUnique)) {
                local.makeUnique = arguments.uploadArgs.makeUnique;
            } else {
                local.makeUnique = true;
            }
            if (structKeyExists(arguments.uploadArgs, "fileName") and len(trim(arguments.uploadArgs.fileName))) {
                local.fileName = trim(arguments.uploadArgs.fileName);
            } else {
                local.fileName = '';
            }
            if (structKeyExists(arguments.uploadArgs, "fileNameOrig") and len(trim(arguments.uploadArgs.fileNameOrig))) {
                local.fileNameOrig = trim(arguments.uploadArgs.fileNameOrig);
            } else {
                local.fileNameOrig = '';
            }

            <!--- Is there a file to upload? --->
            if (!len(trim(local.fileNameOrig))) {
                local.argsReturnValue['message'] = 'Where is the file?';
                return local.argsReturnValue;
            }

            <!--- Is the given path valid or do we have to create it? --->
            if (!directoryExists(local.filePath)) {

                try {
                    directoryCreate(local.filePath);
                } catch (e) {
                    local.argsReturnValue['message'] = e.message;
                    return local.argsReturnValue;
                }
            }

            <!--- Overwrite or not? --->
            if (local.makeUnique) {
                local.nameConflict = "makeunique";
            } else {
                local.nameConflict = "overwrite";
            }

            <!--- Upload the file now --->
            try {
                uploadTheFile = FileUpload(
                    fileField = arguments.uploadArgs.fileNameOrig,
                    destination = arguments.uploadArgs.filepath,
                    nameConflict = local.nameConflict/* ,
                    accept = local.acceptFileTypesList */
                );
                // Second check of uploaded file. Mimetype could be spoofed.
                if (not listFindNoCase(local.allowedFileTypesList, uploadTheFile.serverFileExt)) {
                    local.argsReturnValue['message'] = 'msgFileUploadError';
                    return local.argsReturnValue;
                }
            } catch (any e) {
                local.argsReturnValue['message'] = e.message;
                return local.argsReturnValue;
            }

            local.fileSizeInKB = uploadTheFile.filesize/1000;
            local.uploadedFileNameOrig = uploadTheFile.serverfile;
            local.uploadedFilePathOrig = uploadTheFile.serverdirectory & '\' & local.uploadedFileNameOrig;

            <!--- File too large? If yes, delete it and send message --->
            if (len(trim(local.maxSize)) and local.maxSize lt local.fileSizeInKB) {

                FileDelete(local.uploadedFilePathOrig);
                local.argsReturnValue['message'] = 'msgFileTooLarge';
                return local.argsReturnValue;

            }

            <!--- Do we have to rename the file? If not, we will beautify it by ourself --->
            if (len(trim(local.fileName))) {

                local.newFileName = local.fileName  & '.' & uploadTheFile.serverfileext;
                local.newFilePath = uploadTheFile.serverdirectory & '\' & local.newFileName;
                cffile(action="rename", source=local.uploadedFilePathOrig, destination=local.newFilePath);
                local.argsReturnValue['fileName'] = local.newFileName;

            } else {

                <!--- Beautify the file name (using sql function) --->
                getBeautyName = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        stringToChange: {type = "nvarchar", value = uploadTheFile.serverfilename}
                    },
                    sql = "
                        SELECT beautify(:stringToChange) as newName;
                    "
                )

                local.newFileName = getBeautyName.newName  & '.' & uploadTheFile.serverfileext;
                local.newFilePath = uploadTheFile.serverdirectory & '\' & local.newFileName;
                try {
                cffile(action="rename", source=local.uploadedFilePathOrig, destination=local.newFilePath);
                } catch (any e){

                }
                local.argsReturnValue['fileName'] = local.newFileName;

            }

            <!--- If image, do we have to resize it? --->
            if (IsImageFile(local.newFilePath)) {

                if (len(trim(local.maxWidth)) or len(trim(local.maxHeight))) {

                    <!--- Reading the image size --->
                    cfimage(action="info", source=local.newFilePath, structname="imageInfo");

                    local.imageWidth = imageInfo.width;
                    local.imageHeight = imageInfo.height;

                    local.newImageWidth = '';
                    local.newImageHeight = '';

                    <!--- Do we have to resize the image width? --->
                    if (isNumeric(local.maxWidth) and local.maxWidth gt 0) {

                        if (local.imageWidth gt local.maxWidth) {
                            local.newImageWidth = local.maxWidth;
                        }
                    }

                    <!--- Do we have to resize the image height? --->
                    if (isNumeric(local.maxHeight) and local.maxHeight gt 0) {

                        if (local.imageHeight gt local.maxHeight) {
                            local.newImageHeight = local.maxHeight;
                        }
                    }

                    <!--- Resize the image --->
                    if (isNumeric(local.newImageWidth) or isNumeric(local.newImageHeight)) {

                        cfimage(action="resize", source=local.newFilePath, overwrite="true", height=local.newImageHeight, width=local.newImageWidth, name="myNewFile");
                        cfimage(action="write", source=myNewFile, destination=local.newFilePath, overwrite="true");

                    }

                }

            }

            local.argsReturnValue['success'] = true;
            return local.argsReturnValue;


        } else {

            local.argsReturnValue['message'] = 'The given value is not of type struct!';
            return local.argsReturnValue;

        }

    }


    <!--- Delete a file --->
    public struct function deleteFile(required string path) {

        <!--- Default variables --->
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (len(trim(arguments.path))) {
            if (FileExists(arguments.path)) {
                FileDelete(arguments.path);
            } else {
                local.argsReturnValue['message'] = "no file found";
            }
        } else {
            local.argsReturnValue['message'] = "File path missing";
        }

        return local.argsReturnValue;

    }



    <!--- Check whether the user is in the range of the current tenant.
        doingUserID: The users id which is doing things like deleting or editing.
        customerID: The customerID from whom something must be done
    --->
    public boolean function checkTenantRange(required numeric doingUserID, required numeric customerID) {

        local.isAllowed = false;

        local.qRange = queryExecute(
            options = {datasource = application.datasource},
            params = {
                doingUserID: {type: "numeric", value: arguments.doingUserID},
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT intCustomerID
                FROM customer_user
                WHERE intCustomerID = :customerID
                AND intUserID = :doingUserID
            "
        )

        if (local.qRange.recordCount) {
            local.isAllowed = true;
        }


        return local.isAllowed;

    }


    public string function cleanUpText(required string inputText, numeric maxLenght) {

        local.changedText = rereplace(arguments.inputText, "<|>", "", "all");

        if (structKeyExists(arguments, "maxLenght")) {
            local.changedText = left(local.changedText, arguments.maxLenght);
        }

        return trim(local.changedText);

    }


    // Get the primary key (name) of a table
    public string function getPrimaryKey(required string thisTableName) {

        local.qPrimary = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisTableName: {type: "varchar", value: arguments.thisTableName}
            },
            sql = "
                SELECT COLUMN_NAME
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = (SELECT DATABASE())
                AND TABLE_NAME = :thisTableName
                AND COLUMN_KEY = 'PRI';
            "
        )

        return local.qPrimary.COLUMN_NAME;

    }


    // Recalc prio in table
    public void function recalcPrio(required string tableName, required numeric newPrio, required numeric thisPrimID, string sqlWhereString) {

        param name="arguments.sqlWhereString" default="";

        if (len(trim(arguments.sqlWhereString))) {
            local.sqlWhereString = arguments.sqlWhereString;
            if (left(local.sqlWhereString, 3) neq "AND") {
                local.sqlWhereString = "AND " & arguments.sqlWhereString;

            }
        } else {
            local.sqlWhereString = "";
        }


        local.qLastPrio = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisPrimID: {type: "numeric", value: arguments.thisPrimID}
            },
            sql = "
                SELECT intPrio
                FROM #arguments.tableName#
                WHERE #getPrimaryKey(arguments.tableName)# = :thisPrimID
            "
        )

        if (local.qLastPrio.recordCount) {

            if (arguments.newPrio neq local.qLastPrio.intPrio) {

                if (arguments.newPrio gt local.qLastPrio.intPrio) {

                    queryExecute(
                        options = {datasource = application.datasource, result="check"},
                        params = {
                            newPrio: {type: "numeric", value: arguments.newPrio},
                            oldPrio: {type: "numeric", value: local.qLastPrio.intPrio}
                        },
                        sql = "
                            UPDATE #arguments.tableName#
                            SET intPrio = intPrio-1
                            WHERE intPrio <= :newPrio AND intPrio >= :oldPrio #local.sqlWhereString#
                        "
                    )

                } else {

                    queryExecute(
                        options = {datasource = application.datasource, result="check"},
                        params = {
                            newPrio: {type: "numeric", value: arguments.newPrio},
                            oldPrio: {type: "numeric", value: local.qLastPrio.intPrio}
                        },
                        sql = "
                            UPDATE #arguments.tableName#
                            SET intPrio = intPrio+1
                            WHERE intPrio >= :newPrio AND intPrio <= :oldPrio #local.sqlWhereString#
                        "
                    )

                }

                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        newPrio: {type: "numeric", value: arguments.newPrio},
                        thisPrimID: {type: "numeric", value: arguments.thisPrimID}
                    },
                    sql = "
                        UPDATE #arguments.tableName#
                        SET intPrio = :newPrio
                        WHERE #getPrimaryKey(arguments.tableName)# = :thisPrimID
                    "
                )

            }


        }


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


    // Get the default currency
    public struct function getDefaultCurrency() {

        local.currStruct = {};

        local.qDefCurrency = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM currencies
                WHERE blnDefault = 1
            "
        )
        if (local.qDefCurrency.recordCount) {

            local.currStruct['currencyID'] = local.qDefCurrency.intCurrencyID;
            local.currStruct['iso'] = local.qDefCurrency.strCurrencyISO;
            local.currStruct['currency_en'] = local.qDefCurrency.strCurrencyEN;
            local.currStruct['currency'] = local.qDefCurrency.strCurrency;
            local.currStruct['prio'] = local.qDefCurrency.intPrio;

        } else {

            local.currStruct['currencyID'] = 0;
            local.currStruct['iso'] = '';
            local.currStruct['currency_en'] = '';
            local.currStruct['currency'] = '';
            local.currStruct['prio'] = 0;

        }


        return local.currStruct;


    }


    // Get all active currencies
    public array function getActiveCurrencies() {

        local.qCurrencies = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM currencies
                WHERE blnActive = 1
                ORDER BY intPrio
            "
        )

        local.currArray = arrayNew(1);
        local.currStruct = structNew();

        if (local.qCurrencies.recordCount) {

            loop query= local.qCurrencies {

                local.currStruct[local.qCurrencies.currentRow]['currencyID'] = local.qCurrencies.intCurrencyID;
                local.currStruct[local.qCurrencies.currentRow]['iso'] = local.qCurrencies.strCurrencyISO;
                local.currStruct[local.qCurrencies.currentRow]['currency_en'] = local.qCurrencies.strCurrencyEN;
                local.currStruct[local.qCurrencies.currentRow]['currency'] = local.qCurrencies.strCurrency;
                local.currStruct[local.qCurrencies.currentRow]['prio'] = local.qCurrencies.intPrio;
                arrayAppend(local.currArray, local.currStruct[local.qCurrencies.currentRow]);

            }

        }

        return local.currArray;

    }


    // Get currency of a given country
    public struct function getCurrencyOfCountry(required any country) {

        local.currencyStruct = structNew();

        if (isNumeric(arguments.country)) {

            local.qCurrOfCountry = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    countryID: {type: "numeric", value: arguments.country}
                },
                sql = "
                    SELECT intCurrencyID, strCurrencyISO
                    FROM currencies
                    WHERE blnActive = 1
                    AND strCurrencyISO =
                    (
                        SELECT strCurrency
                        FROM countries
                        WHERE intCountryID = :countryID
                    )
                "
            )

        } else {

            local.qCurrOfCountry = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    country: {type: "varchar", value: arguments.country}
                },
                sql = "
                    SELECT intCurrencyID, strCurrencyISO
                    FROM currencies
                    WHERE blnActive = 1
                    AND strCurrencyISO =
                    (
                        SELECT strCurrency
                        FROM countries
                        WHERE strISO1 = :country
                        OR strISO2 = :country
                        OR strLocale = :country
                        LIMIT 1
                    )
                "
            )
        }

        if (local.qCurrOfCountry.recordCount) {

            local.currencyStruct['currencyID'] = local.qCurrOfCountry.intCurrencyID;
            local.currencyStruct['currency'] = local.qCurrOfCountry.strCurrencyISO;

        } else {

            local.currencyStruct['currencyID'] = 0;
            local.currencyStruct['currency'] = "";

        }

        return local.currencyStruct;

    }




    // Get the country from IP address (Yes, the user may have a VPN, but we'll ignore that for now)
    public struct function getCountryFromIP(required string ip) {

        local.countryStruct = structNew();
        local.countryStruct['country'] = "";
        local.countryStruct['countryID'] = "0";
        local.countryStruct['countryCode'] = "";
        local.countryStruct['success'] = false;

        local.jsonQuery = '[{"query": "#arguments.ip#", "fields": "country,countryCode"}]';

        if (len(trim(arguments.ip))) {

            // We are using the free api service from ip-api.com
            http url="http://ip-api.com/batch" method="post" result="local.theCountry" {
                httpparam type="body" value="#local.jsonQuery#";
            }

            if (local.theCountry.status_text eq "OK") {

                local.fileContent = deserializeJSON(local.theCountry.fileContent);

                if (isArray(local.fileContent)) {

                    local.thisStruct = local.fileContent[1];
                    local.countryStruct['country'] = local.thisStruct.country;
                    local.countryStruct['countryCode'] = local.thisStruct.countryCode;
                    local.countryStruct['success'] = true;

                    // get the countryID, if exists
                    local.qCountry = queryExecute (
                        options = {datasource = application.datasource},
                        params = {
                            iso: {type: "varchar", value: local.thisStruct.countryCode}
                        },
                        sql = "
                            SELECT intCountryID
                            FROM countries
                            WHERE blnActive = 1
                            AND strISO1 = :iso
                        "
                    )

                    if (local.qCountry.recordCount) {
                        local.countryStruct['countryID'] = local.qCountry.intCountryID;
                    }


                }

            }

        }

        return local.countryStruct;


    }

}
