component displayname="globalFunctions" output="false" {

    // SEF building
    public struct function getSEF(string sef_string) {

        local.returnStruct = structNew();
        local.returnStruct['thisPath'] = "";
        local.returnStruct['thisID'] = 0;
        local.returnStruct['onlyAdmin'] = false;
        local.returnStruct['onlySuperAdmin'] = false;
        local.returnStruct['onlySysAdmin'] = false;
        local.returnStruct['noaccess'] = false;
        local.returnStruct['navSlugs'] = {};
        local.returnStruct['langSlugs'] = {};

        // Language prefix detection runs first so navSlugs is built with the correct language
        if (len(trim(arguments.sef_string))) {
            local.sefString = arguments.sef_string;
            local.firstSegment = listFirst(local.sefString, '/');
            if (len(local.firstSegment) eq 2 and structKeyExists(session, 'lng') and local.firstSegment neq session.lng) {
                local.qLngPrefix = queryExecute(
                    options = {datasource = application.datasource},
                    params = { iso: {type: "varchar", value: local.firstSegment} },
                    sql = "SELECT COUNT(*) as cnt FROM languages WHERE strLanguageISO = :iso"
                );
                if (local.qLngPrefix.cnt gt 0) {
                    session.lng = lCase(local.firstSegment);
                    application.langStruct = application.objLanguage.initLanguages();
                    if (structKeyExists(session, "customer_id")) {
                        application.objCustomer.setProductSessions(session.customer_id, session.lng);
                    }
                }
            }
        }

        // Build language-aware slug lookup — runs on every request with the now-correct session.lng
        local.qNavSlugs = queryExecute(
            options = {datasource = application.datasource},
            params = { iso: {type: "varchar", value: session.lng} },
            sql = "
                SELECT fm.strPath,
                       COALESCE(NULLIF(fmt.strMapping, ''), fm.strMapping) AS slug
                FROM frontend_mappings fm
                LEFT JOIN frontend_mappings_trans fmt
                    ON fmt.intFrontendMappingsID = fm.intFrontendMappingsID
                    AND fmt.intLanguageID = (SELECT intLanguageID FROM languages WHERE strLanguageISO = :iso)
            "
        );
        loop query = local.qNavSlugs {
            local.returnStruct['navSlugs'][local.qNavSlugs.strPath] = local.qNavSlugs.slug;
        }

        if (len(trim(arguments.sef_string))) {

            // local.sefString already set above during language detection

            // If the last part of the sef string is a number, remove it
            if (isNumeric(listLast(local.sefString, "/"))) {
                local.thisID = listLast(local.sefString, "/");
                local.returnStruct['thisID'] = thisID;
                local.sefString = replace(local.sefString, "/#local.thisID#", "", "one");
            }

            // look for db entry
            local.qCheckSEF = queryExecute(

                options = {datasource = application.datasource},
                params = {
                    strMapping: {type: "nvarchar", value: local.sefString}
                },
                sql = "
                    SELECT strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin, 0 as itsFrontend, 0 as intModuleID, 0 as intFrontendMappingsID
                    FROM system_mappings
                    WHERE strMapping = :strMapping
                    UNION
                    SELECT strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin, 0 as itsFrontend, intModuleID, 0 as intFrontendMappingsID
                    FROM custom_mappings
                    WHERE strMapping = :strMapping
                    UNION
                    SELECT strPath, 0, 0, 0, 1 as itsFrontend, 0 as intModuleID, intFrontendMappingsID
                    FROM frontend_mappings
                    WHERE strMapping = :strMapping
                    UNION
                    SELECT
                    (
                        SELECT strPath
                        FROM frontend_mappings
                        WHERE intFrontendMappingsID = frontend_mappings_trans.intFrontendMappingsID
                    ) as strPath, 0, 0, 0, 1 as itsFrontend, 0 as intModuleID, intFrontendMappingsID
                    FROM frontend_mappings_trans
                    WHERE strMapping = :strMapping
                    LIMIT 1
                "
            )

            if (local.qCheckSEF.recordCount) {

                // Check if the path is coming from a module
                if (local.qCheckSEF.intModuleID gt 0 and structKeyExists(session, "customer_id") and session.customer_id gt 0) {

                    // We have to check if the module is active for the current customer
                    local.moduleStatus = application.objModules.getModuleStatus(session.customer_id, local.qCheckSEF.intModuleID);

                    // Overwrite the flag 'noaccess' generally to true (if its not a SysAdmin)
                    if (!session.sysadmin) {
                        local.returnStruct['noaccess'] = true;
                    }

                    // If the module is active, we can set 'noaccess' to false.
                    // Access is granted for any booking still within its
                    // start/end window, regardless of strStatus - a canceled
                    // booking ('test' or 'active' status flipped to
                    // 'canceled') still keeps access until dteEndDate, it
                    // just won't renew. Checking the status label alone
                    // (the old 'free'/'test'/'active' allowlist) incorrectly
                    // cut off access the instant a customer canceled, even
                    // though the account settings page told them access
                    // continues until the end date.
                    if (isStruct(local.moduleStatus) and !structIsEmpty(local.moduleStatus)) {
                        if (structKeyExists(local.moduleStatus, "status")) {
                            if (local.moduleStatus.status eq "free") {
                                local.returnStruct['noaccess'] = false;
                            } else if (
                                structKeyExists(local.moduleStatus, "startDate") and structKeyExists(local.moduleStatus, "endDate")
                                and isDate(local.moduleStatus.startDate) and isDate(local.moduleStatus.endDate)
                                and dateFormat(local.moduleStatus.startDate, "yyyy-mm-dd") lte dateFormat(now(), "yyyy-mm-dd")
                                and dateFormat(local.moduleStatus.endDate, "yyyy-mm-dd") gte dateFormat(now(), "yyyy-mm-dd")
                            ) {
                                local.returnStruct['noaccess'] = false;
                            }
                        }
                    }

                }

                if (local.qCheckSEF.itsFrontend) {

                    local.returnStruct['thisPath'] = "frontend/" & application.activeTheme & "/" & local.qCheckSEF.strPath;

                    // Remove all url variables and append each as a struct value to the struct
                    if (find("?", local.returnStruct['thisPath'])) {

                        // Split path and query string
                        local.pathParts = listToArray(local.returnStruct['thisPath'], "?");
                        local.returnStruct['thisPath'] = local.pathParts[1];
                        local.returnStruct['urlVariables'] = {};

                        if (arrayLen(local.pathParts) > 1) {
                            local.queryString = local.pathParts[2];
                            local.pairs = listToArray(local.queryString, "&");
                            for (local.i = 1; local.i <= arrayLen(local.pairs); local.i++) {
                                local.pair = local.pairs[local.i];
                                local.eqPos = find("=", local.pair);
                                if (local.eqPos) {
                                    local.key = left(local.pair, local.eqPos - 1);
                                    local.value = mid(local.pair, local.eqPos + 1, len(local.pair) - local.eqPos);
                                    local.returnStruct['urlVariables'][local.key] = local.value;
                                }
                            }
                        }
                    }

                } else {
                    local.returnStruct['thisPath'] = local.qCheckSEF.strPath;
                }
                local.returnStruct['onlyAdmin'] = trueFalseFormat(local.qCheckSEF.blnOnlyAdmin);
                local.returnStruct['onlySuperAdmin'] = trueFalseFormat(local.qCheckSEF.blnOnlySuperAdmin);
                local.returnStruct['onlySysAdmin'] = trueFalseFormat(local.qCheckSEF.blnOnlySysAdmin);

                // Build language switcher slugs for the current page
                if (local.qCheckSEF.intFrontendMappingsID gt 0) {
                    local.qLangSlugs = queryExecute(
                        options = {datasource = application.datasource},
                        params = { id: {type: "numeric", value: local.qCheckSEF.intFrontendMappingsID} },
                        sql = "
                            SELECT l.strLanguageISO, fmt.strMapping AS slug
                            FROM frontend_mappings_trans fmt
                            INNER JOIN languages l ON l.intLanguageID = fmt.intLanguageID
                            WHERE fmt.intFrontendMappingsID = :id
                              AND fmt.strMapping IS NOT NULL AND fmt.strMapping != ''
                              AND l.blnChooseable = 1
                            UNION
                            SELECT SUBSTRING_INDEX(fm.strMapping, '/', 1) AS strLanguageISO,
                                   fm.strMapping AS slug
                            FROM frontend_mappings fm
                            INNER JOIN languages l ON l.strLanguageISO = SUBSTRING_INDEX(fm.strMapping, '/', 1)
                            WHERE fm.intFrontendMappingsID = :id
                              AND LOCATE('/', fm.strMapping) > 0
                              AND CHAR_LENGTH(SUBSTRING_INDEX(fm.strMapping, '/', 1)) = 2
                              AND l.blnChooseable = 1
                        "
                    );
                    loop query = local.qLangSlugs {
                        local.returnStruct['langSlugs'][lCase(local.qLangSlugs.strLanguageISO)] = local.qLangSlugs.slug;
                    }
                }

            } else if (!find('/', local.sefString) and len(local.sefString) eq 2) {

                // Bare 2-char language code (e.g. /en, /de) — treat as language-prefixed home page
                local.qHomeLang = queryExecute(
                    options = {datasource = application.datasource},
                    params = { iso: {type: "varchar", value: local.sefString} },
                    sql = "SELECT strLanguageISO FROM languages WHERE strLanguageISO = :iso AND blnChooseable = 1 LIMIT 1"
                );
                if (local.qHomeLang.recordCount) {
                    local.qChooseableLangs = queryExecute(
                        options = {datasource = application.datasource},
                        sql = "SELECT strLanguageISO FROM languages WHERE blnChooseable = 1"
                    );
                    loop query=local.qChooseableLangs {
                        local.returnStruct['langSlugs'][lCase(local.qChooseableLangs.strLanguageISO)] = lCase(local.qChooseableLangs.strLanguageISO);
                    }
                }

            } else if (!find('/', local.sefString) and len(local.sefString) gt 2) {

                // No match for a bare slug — look for its canonical language-prefixed version (301 redirect target)
                local.qCanonical = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        slug: {type: "varchar", value: local.sefString},
                        lng:  {type: "varchar", value: session.lng}
                    },
                    sql = "
                        SELECT strMapping
                        FROM frontend_mappings
                        WHERE SUBSTRING_INDEX(strMapping, '/', -1) = :slug
                          AND LOCATE('/', strMapping) > 0
                        ORDER BY (SUBSTRING_INDEX(strMapping, '/', 1) = :lng) DESC
                        LIMIT 1
                    "
                );
                if (local.qCanonical.recordCount) {
                    local.returnStruct['redirect301'] = local.qCanonical.strMapping;
                }

            }

        } else {

            // Check if someone is trying to access a cfm file manually
            local.thisPath = replace(replace(cgi.request_url, application.mainURL, ""), "/", "", "one");

            // look for db entry
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
                    UNION
                    SELECT strPath
                    FROM frontend_mappings
                    WHERE strMapping = :thisPath
                    LIMIT 1
                "
            )

            // If we find an entry, the .cfm file may not be called directly
            if (local.qCheckSEF.recordCount) {
                local.returnStruct['thisPath'] = local.thisPath;
                local.returnStruct['noaccess'] = true;
            }

            // Check whether someone is trying to call a file in the sysadmin folder without a sysadmin session
            if (find("/sysadmin/", local.thisPath) and (!structKeyExists(session, "sysadmin") or !session.sysadmin)) {
                local.returnStruct['onlySysAdmin'] = true;
            }


        }

        return local.returnStruct;

    }


    // Create a uuid without dash, all lowercase and two ids combined
    public string function getUUID() {
        return lcase(replace(createUUID(), "-", "", "all")) & lcase(replace(createUUID(), "-", "", "all"));
    }


    // Alerts in diffrent colors (returns a session)
    public string function getAlert(required string alertVariable, string alertType) {

        param name="arguments.alertType" default="success";
        param name="session.alert" default="";


        if (len(trim(arguments.alertVariable))) {

            // Text to translate
            local.thismessage = application.objLanguage.getTrans(arguments.alertVariable);

            // If there is no variable in the db, it must be an system error message
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


    // Hashing and salting passwords
    public struct function generateHash(required string thisString) {

        local.returnStruct = structNew();

        local.returnStruct['thisSalt'] = hash(generateSecretKey('AES'),'SHA-512');
        local.returnStruct['thisHash'] = hash(arguments.thisString & local.returnStruct.thisSalt,'SHA-512');

        return local.returnStruct;

    }


    // Email validating
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


    // Get all countries or a country by id
    public query function getCountry(numeric countryID, string language) {

        param name="arguments.language" default=application.objLanguage.getDefaultLanguage().iso;

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
                    SELECT intCountryID, strLocale, intLanguageID, blnDefault, intPrio, intTimezoneID, strCurrency, strISO1,
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
                    SELECT intCountryID, strLocale, intLanguageID, blnDefault, intPrio, intTimezoneID, strCurrency, strISO1,
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


    // Beauify string (ex. for url or file names)
    public string function beautifyString(required string stringToChange) {

        // Beautify the string using an sql function
        local.qBeautify = queryExecute(
            options = {datasource = application.datasource},
            params = {
                stringToChange: {type = "nvarchar", value = arguments.stringToChange}
            },
            sql = "
                SELECT beautify(:stringToChange) as changedString;
            "
        )

        return local.qBeautify.changedString;

    }


    // Uploading a file such as a pdf or an image
    public struct function uploadFile(required struct uploadArgs, required array allowedFileTypes) {

        local.allowedFileTypesList;
        local.acceptFileTypesList;

        cfloop(array=arguments.allowedFileTypes item="i" index="index") {
            local.allowedFileTypesList = local.allowedFileTypesList & i & ",";
        }

        // Default variables
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;
        local.argsReturnValue['fileName'] = "";

        if (isStruct(arguments.uploadArgs)) {

            local.filePath = expandPath('/userdata');
            local.maxSize = '';
            local.maxWidth = '';
            local.maxHeight = '';
            local.makeUnique = true;
            local.fileName = '';
            local.fileNameOrig = '';
            local.isImage = false;

            // Set a default for all possible arguments
            if (structKeyExists(arguments.uploadArgs, "filePath") and len(trim(arguments.uploadArgs.filePath))) {
                local.filePath = trim(arguments.uploadArgs.filePath);
            }
            if (structKeyExists(arguments.uploadArgs, "maxSize") and len(trim(arguments.uploadArgs.maxSize))) {
                local.maxSize = trim(arguments.uploadArgs.maxSize);
            }
            if (structKeyExists(arguments.uploadArgs, "maxWidth") and len(trim(arguments.uploadArgs.maxWidth))) {
                local.maxWidth = trim(arguments.uploadArgs.maxWidth);
            }
            if (structKeyExists(arguments.uploadArgs, "maxHeight") and len(trim(arguments.uploadArgs.maxHeight))) {
                local.maxHeight = trim(arguments.uploadArgs.maxHeight);
            }
            if (structKeyExists(arguments.uploadArgs, "makeUnique") and isBoolean(arguments.uploadArgs.makeUnique)) {
                local.makeUnique = arguments.uploadArgs.makeUnique;
            }
            if (structKeyExists(arguments.uploadArgs, "fileName") and len(trim(arguments.uploadArgs.fileName))) {
                local.fileName = trim(arguments.uploadArgs.fileName);
            }
            if (structKeyExists(arguments.uploadArgs, "fileNameOrig") and len(trim(arguments.uploadArgs.fileNameOrig))) {
                local.fileNameOrig = trim(arguments.uploadArgs.fileNameOrig);
            }

            // Is there a file to upload?
            if (!len(trim(local.fileNameOrig))) {
                local.argsReturnValue['message'] = 'Where is the file?';
                return local.argsReturnValue;
            }

            // Is the given path valid or do we have to create it?
            if (!directoryExists(local.filePath)) {

                try {
                    directoryCreate(local.filePath);
                } catch (e) {
                    local.argsReturnValue['message'] = e.message;
                    return local.argsReturnValue;
                }
            }

            // Overwrite or not?
            if (local.makeUnique) {
                local.nameConflict = "makeunique";
            } else {
                local.nameConflict = "overwrite";
            }

            // Upload the file now
            try {
                local.uploadedFile = fileUpload(
                    fileField = local.fileNameOrig,
                    destination = local.filePath,
                    nameConflict = local.nameConflict
                )
            } catch (e) {
                local.argsReturnValue['message'] = e.message;
                return local.argsReturnValue;
            }

            // Create a uuid in order to handle the file
            local.fileUUID = createUUID() & "." & local.uploadedFile.serverFileExt;

            // Get the file name
            local.originalFileName = local.uploadedFile.clientfilename;

            // Get the file name with extension
            local.originalFileNameExt = local.uploadedFile.serverfile;

            // Get the path of the file
            local.originalFilePath = local.uploadedFile.serverdirectory;

            // Get the file extension
            local.originalFileExt = local.uploadedFile.serverFileExt;

            // Get file path and name with extension
            local.originalFile = local.originalFilePath & "/" & local.originalFileNameExt;

            // Get the size of the file
            local.fileSizeInKB = local.uploadedFile.filesize/1000;

            // Is it an image?
            if (IsImageFile(local.originalFile)) {
                local.isImage = true;
            }

            // Security (only file ext. configured in config.cfm)
            if (not listFindNoCase(local.allowedFileTypesList, local.originalFileExt)) {
                if (fileExists(local.originalFile)) {
                    FileDelete(local.originalFile);
                }
                local.argsReturnValue['message'] = 'msgFileExtForbidden';
                return local.argsReturnValue;
            }

            // File too large? If yes, delete it and send message
            if (len(trim(local.maxSize)) and local.maxSize lt local.fileSizeInKB) {
                if (fileExists(local.originalFile)) {
                    FileDelete(local.originalFile);
                }
                local.argsReturnValue['message'] = 'msgFileTooLarge';
                return local.argsReturnValue;
            }

            // If fileName is defined, the developer is responsible for the correct file name
            if (len(trim(local.fileName))) {

                // Add the path to the new file name
                local.newFilePath = local.originalFilePath & "/" & local.fileName & "." & local.originalFileExt;

                // Rename the file now
                cffile(action="rename", source=local.originalFile, destination=local.newFilePath);

                // New file name
                local.newFileName = local.fileName & "." & local.originalFileExt;


            // Otherwise we will change the filename using a beautifier
            } else {

                // Rename the file into the uuid
                cffile(action="rename", source=local.originalFile, destination=local.originalFilePath & "/" & local.fileUUID);

                // We beautify the file name so that all systems can read it
                local.beautifiedString = beautifyString(local.originalFileName);

                // New file name
                local.newFileName = local.beautifiedString & "." & local.originalFileExt;

                // Add the path to the new file name
                local.newFilePath = local.originalFilePath & "/" & local.newFileName;

                // Does the file exist already?
                if (fileExists(local.newFilePath)) {

                    // Only execute if the developer has set makeunique to true
                    if (local.makeUnique) {

                        // Set a short unique uuid
                        local.shortUUID = left(getUUID(), 10);

                        local.newFilePath = local.originalFilePath & "/" & local.beautifiedString & "-" & local.shortUUID & "." & local.originalFileExt;

                        // New file name
                        local.newFileName = local.beautifiedString & "-" & local.shortUUID & "." & local.originalFileExt;

                    }

                }

                // As Windows locks files for a short time after the first rename, we have to wait until they have been released
                if (checkFileExists(local.originalFilePath & "/" & local.fileUUID)) {

                    // Rename the file into the cleaned string
                    cffile(action="rename", source=local.originalFilePath & "/" & local.fileUUID, destination=local.newFilePath);

                }


            }

            // Return the file name
            local.argsReturnValue['fileName'] = local.newFileName;


            // If image, do we have to resize it?
            if (local.isImage) {

                if (len(trim(local.maxWidth)) or len(trim(local.maxHeight))) {

                    // Reading the image size
                    cfimage(action="info", source=local.newFilePath, structname="imageInfo");

                    local.imageWidth = imageInfo.width;
                    local.imageHeight = imageInfo.height;

                    local.newImageWidth = '';
                    local.newImageHeight = '';

                    // Do we have to resize the image width?
                    if (isNumeric(local.maxWidth) and local.maxWidth gt 0) {

                        if (local.imageWidth gt local.maxWidth) {
                            local.newImageWidth = local.maxWidth;
                        }
                    }

                    // Do we have to resize the image height?
                    if (isNumeric(local.maxHeight) and local.maxHeight gt 0) {

                        if (local.imageHeight gt local.maxHeight) {
                            local.newImageHeight = local.maxHeight;
                        }
                    }

                    // Resize the image
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


    // Check if a file exists
    private boolean function checkFileExists(required string filePath) {

        loop from=1 to=100000 index="local.i" {
            if (fileExists(arguments.filePath)) {
                return true;
            }
        }

        return false;

    }


    // Delete a file
    public struct function deleteFile(required string path) {

        // Default variables
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


    // Check whether the user is in the range of the current tenant
    public boolean function checkTenantRange(required numeric userID, required numeric customerID) {

        local.isAllowed = false;

        local.qRange = queryExecute(
            options = {datasource = application.datasource},
            params = {
                userID: {type: "numeric", value: arguments.userID},
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT intCustomerID
                FROM customer_user
                WHERE intCustomerID = :customerID
                AND intUserID = :userID
            "
        )

        if (local.qRange.recordCount) {
            local.isAllowed = true;
        }


        return local.isAllowed;

    }


    // Clean up text (length, special chars)
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


    // Get all login includes which we include when the user logs in
    public array function getLoginIncludes(required numeric customerID) {

        local.includeArray = arrayNew(1);

        // Get the include in myApp
        local.fileToInclude = "/backend/myapp/" & "/login_include.cfm";

        // Does the file exist?
        if (fileExists(expandPath(local.fileToInclude))) {
            arrayAppend(local.includeArray, local.fileToInclude);
        }

        local.objModules = new backend.core.com.modules();

        // Includes for modules
        loop array=local.objModules.getBookedModules(arguments.customerID) index="i" {

            if (structKeyExists(i.moduleData, "table_prefix")) {

                local.fileToInclude = "/backend/modules/" & i.moduleData.table_prefix & "/login_include.cfm";

                // Does the file exist?
                if (fileExists(expandPath(local.fileToInclude))) {
                    arrayAppend(local.includeArray, local.fileToInclude);
                }

            }

        }

        return local.includeArray;

    }

    // Get MIME types from file extensions
    public array function getMimeTypes(required array extensions) {

        // Extended MIME type list, covers many common file types
        local.mimeMap = {

            // Images
            "jpeg": "image/jpeg",
            "jpg": "image/jpeg",
            "png": "image/png",
            "gif": "image/gif",
            "bmp": "image/bmp",
            "webp": "image/webp",
            "svg": "image/svg+xml",
            "ico": "image/x-icon",
            "tiff": "image/tiff",
            "jfif": "image/jpeg",

            // Documents
            "pdf": "application/pdf",
            "zip": "application/zip",
            "rar": "application/x-rar-compressed",
            "7z": "application/x-7z-compressed",
            "tar": "application/x-tar",
            "gz": "application/gzip",
            "doc": "application/msword",
            "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "ppt": "application/vnd.ms-powerpoint",
            "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
            "xls": "application/vnd.ms-excel",
            "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "csv": "text/csv",
            "txt": "text/plain",
            "rtf": "application/rtf",
            "odt": "application/vnd.oasis.opendocument.text",
            "ods": "application/vnd.oasis.opendocument.spreadsheet",
            "odp": "application/vnd.oasis.opendocument.presentation",
            "json": "application/json",
            "xml": "application/xml",
            "html": "text/html",
            "htm": "text/html",
            "md": "text/markdown",
            "yaml": "text/yaml",
            "yml": "text/yaml",

            // Audio
            "mp3": "audio/mpeg",
            "wav": "audio/wav",
            "ogg": "audio/ogg",
            "flac": "audio/flac",
            "aac": "audio/aac",
            "m4a": "audio/mp4",
            "wma": "audio/x-ms-wma",

            // Video
            "mp4": "video/mp4",
            "mov": "video/quicktime",
            "avi": "video/x-msvideo",
            "wmv": "video/x-ms-wmv",
            "mkv": "video/x-matroska",
            "webm": "video/webm",
            "flv": "video/x-flv",
            "3gp": "video/3gpp",
            "mpeg": "video/mpeg",

            // Other common types
            "apk": "application/vnd.android.package-archive",
            "dmg": "application/x-apple-diskimage",
            "iso": "application/x-iso9660-image",
            "psd": "image/vnd.adobe.photoshop",
            "ai": "application/postscript",
            "eps": "application/postscript",
            "ttf": "font/ttf",
            "otf": "font/otf",
            "woff": "font/woff",
            "woff2": "font/woff2",
            "eot": "application/vnd.ms-fontobject"
        };

        local.mimeTypes = [];

        for (local.ext in arguments.extensions) {
            if (structKeyExists(local.mimeMap, local.ext)) {
                arrayAppend(local.mimeTypes, local.mimeMap[local.ext]);
            }
        }

        return local.mimeTypes;

    }

}
