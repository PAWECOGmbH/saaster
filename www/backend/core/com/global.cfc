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

        if (len(trim(arguments.sef_string))) {

            local.sefString = arguments.sef_string;

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
                    SELECT strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin
                    FROM system_mappings
                    WHERE strMapping = :strMapping
                    UNION
                    SELECT strPath, blnOnlyAdmin, blnOnlySuperAdmin, blnOnlySysAdmin
                    FROM custom_mappings
                    WHERE strMapping = :strMapping
                    UNION
                    SELECT strPath, 0, 0, 0
                    FROM frontend_mappings
                    WHERE strMapping = :strMapping
                    UNION
                    SELECT
                    (
                        SELECT strPath
                        FROM frontend_mappings
                        WHERE intFrontendMappingsID = frontend_mappings_trans.intFrontendMappingsID
                    ) as strPath, 0, 0, 0
                    FROM frontend_mappings_trans
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


    // Check whether the user is in the range of the current tenant.
    // doingUserID: The users id which is doing things like deleting or editing.
    // customerID: The customerID from whom something must be done
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

}
