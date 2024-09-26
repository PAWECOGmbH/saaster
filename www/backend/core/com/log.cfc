component displayname="log" {

    // Logging function
    public void function logWrite(required string type, required string level, required string message, boolean sendMail, datetime date) {

        // Check system admin time zone and create corresponding time instance
        local.getSysadmin = new backend.core.com.sysadmin().getSysAdminData();
        if(local.getSysadmin.timezoneID neq "") {
            local.getTime = new backend.core.com.time(1);
        } else {
            local.getTime = new backend.core.com.time();
        }

        // Generate timestamp based on the sysadmin time zone
        local.timeStamp = (structKeyExists(arguments, "date") and isDate(arguments.date)) ? arguments.date : local.getTime.utc2local(now());

        // Use today's date based on the user time zone if no date is specified
        local.currentDate = len(trim(arguments.date)) ? dateFormat(arguments.date, "yyyy-mm-dd") : dateFormat(now(), "yyyy-mm-dd");
        local.rootPath = expandPath("/");
        local.logPath = "#local.rootPath#logs/#arguments.type#/#dateFormat(local.currentDate, 'yyyy-mm')#/#dateFormat(local.currentDate, 'dd')#";
        local.logFile = "#local.logPath#/#arguments.level#.log";

        // Create directory structure if it does not exist
        lock name="createDirectoryLock" type="exclusive" timeout="5" {
            if (!directoryExists(local.logPath)) {
                directoryCreate(local.logPath, true);
            }
        }

        // Prepare log message
        local.logEntry = "#local.timeStamp# #arguments.message#";

        // If the log level is 'error', add Lucee call stack information
        if (arguments.level == "error") {
            local.callerInfo = callStackGet("string", 1, 1);
            if (len(trim(local.callerInfo))) {
                local.logEntry &= " Caller: " & local.callerInfo;
            }
        }

        local.logEntry &= Chr(13) & Chr(10); // Add line break

        // Attach message to the log file
        fileAppend(local.logFile, local.logEntry);

        // Send log by e-mail, if desired
        if (structKeyExists(arguments, "sendMail") and arguments.sendMail) {
            cfmail(subject="#ucase(arguments.level)# in #application.projectName#", to="#application.errorMail#", from="#application.fromEmail#" ) {
                writeOutput("#local.logEntry#");
            }
        }

    }


    // Get logfiles directly from the log directory
    public query function getLogs(string type = "", string date = "", string level = "") {

        // Init
        local.logPath = expandPath("/logs");
        local.filterDate = "";
        local.filterLevel = "";

        // Create base path based on the type, if specified
        if (len(trim(arguments.type))) {
            local.logPath &= "/#arguments.type#";
        }

        // Add date to filter
        if (len(trim(arguments.date))) {
            local.filterDate = dateFormat(arguments.date, "yyyy-mm-dd");
        }

        // Add level to filter
        if (len(trim(arguments.level))) {
            local.filterLevel = arguments.level & ".log";
        }

        // Temporary variables to avoid the closure scope problems
        var tempFilterDate = local.filterDate;
        var tempFilterLevel = local.filterLevel;

        // List log files with a closure that captures the necessary local variables
        local.qLogfiles = directoryList(
            path=local.logPath,
            type="file",
            recurse=true,
            listInfo="query",
            filter=function(path) {
                // Use of temporary variables within the closure
                return filterTheList(path=path, dateFilter=tempFilterDate, levelFilter=tempFilterLevel);
            },
            sort="dateLastModified desc"
        );

        return local.qLogfiles;

    }



    // Universal filter function with extended filter options
    public boolean function filterTheList(required string path, string dateFilter = "", string levelFilter = "") {

        // Initialise variables for filter results
        local.dateMatch = false;
        local.levelMatch = false;

        // Filter date if a date filter has been specified
        if (len(trim(arguments.dateFilter))) {
            local.path = replace(arguments.path, "\", "/", "all");
            local.pathSegments = listToArray(local.path, "/");
            local.dateSegment = local.pathSegments[arrayLen(local.pathSegments)-2] & "-" & local.pathSegments[arrayLen(local.pathSegments)-1];
            local.dateMatch = (local.dateSegment == arguments.dateFilter);
        } else {
            // No date filter specified, therefore the date is considered to match
            local.dateMatch = true;
        }

        // Filter file names if a file name filter has been specified
        if (len(trim(arguments.levelFilter))) {

            // Extract the file name from the path
            local.fileName = listLast(path, "/");

            // Check whether the file name matches the filter criteria
            local.levelMatch = findNoCase(arguments.levelFilter, local.fileName);

        } else {

            // No file name filter specified, therefore the name is considered to match
            local.levelMatch = true;

        }


        // Determine whether the path matches the filter criteria
        return local.dateMatch AND local.levelMatch;
    }



    // Get logfile details
    public array function getLogDetail(required string filepath) {

        local.logLines = [];

        // Check whether the file exists
        if (fileExists(arguments.filepath)) {

            // Open file for reading
            local.fileObj = fileOpen(arguments.filepath, "read");

            // Read through the file line by line
            while (!fileIsEOF(local.fileObj)) {
                local.line = fileReadLine(local.fileObj);
                arrayAppend(local.logLines, trim(local.line)); // Add read line to array
            }

            // Close file
            fileClose(local.fileObj);

        } else {

            // Add error message if the file does not exist
            arrayAppend(local.logLines, "The specified file does not exist.");

        }

        return local.logLines;

    }


    // Delete logfile and even the directory
    public struct function deleteLogfile(required string file) {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        // Check whether the file exists
        if (fileExists(arguments.file)) {

            // Delete the file
            try {

                fileDelete(arguments.file);

                // Determine the path to the directory of the deleted file
                local.directory = getDirectoryFromPath(arguments.file);

                // Retrieve list of all files in the directory
                local.filesInDirectory = directoryList(local.directory, false, "name");

                // Delete directory if it does not contain any other files
                if (!ArrayLen(local.filesInDirectory)) {
                    directoryDelete(local.directory);
                }

                // Success message, file and directory deleted if necessary
                local.argsReturnValue['message'] = "The file and, if applicable, the empty directory have been successfully deleted.";
                local.argsReturnValue['success'] = true;


            } catch (any e) {

                // Error message if deletion fails
                local.argsReturnValue['message'] = "Error while deleting the file or directory: " & e.message;

            }

        } else {

            // Message if the file does not exist
            local.argsReturnValue['message'] = "The specified file does not exist.";

        }

        return local.argsReturnValue;

    }


    // Get all log types filtered by getLogs()
    public array function getLogTypes() {

        // Get all logs
        local.logs = getLogs();

        // Init
        local.typeArray = [];

        // Loop through the query object
        loop query=local.logs {

            // For Windows environment we need to replace the "\". Then we replace /logs/ to ~
            local.dirName = local.logs.directory.replace("\", "/", "all").replace("/logs/", "~", "one");

            // Remove the first part until ~
            local.firstPart = listLast(local.dirName, "~");

            // Use the part before the first /
            local.type = listFirst(local.firstPart, "/");

            // Prevent duplicates by checking whether the type already exists in the array
            if (!arrayContains(local.typeArray, local.type)) {
                arrayAppend(local.typeArray, local.type);
            }

        }

        return local.typeArray;

    }


    // Delete logfiles older than 30 days
    public void function deleteOldLogfiles() {

        local.logPath = expandPath("/logs");
        local.thirtyDaysAgo = dateAdd("d", -30, now());

        // List all log files and directories recursively
        local.allFilesAndDirs = directoryList(path=local.logPath, recurse=true, listInfo="query", sort="dateLastModified desc");

        // Iterate over the results and delete files older than 30 days
        for (local.currentRow=1; local.currentRow <= local.allFilesAndDirs.recordCount; local.currentRow++) {
            local.currentPath = local.allFilesAndDirs.directory[local.currentRow] & "/" & local.allFilesAndDirs.name[local.currentRow];
            local.lastModified = local.allFilesAndDirs.dateLastModified[local.currentRow];

            // Check whether the current element is a file and is older than 30 days
            if (local.allFilesAndDirs.type[local.currentRow] == "file" && local.lastModified < local.thirtyDaysAgo) {
                fileDelete(local.currentPath);
            }

        }

        // Iterate again to delete empty directories
        for (local.currentRow=local.allFilesAndDirs.recordCount; local.currentRow >= 1; local.currentRow--) {
            if (local.allFilesAndDirs.type[local.currentRow] == "dir") {
                local.currentDir = local.allFilesAndDirs.directory[local.currentRow] & "/" & local.allFilesAndDirs.name[local.currentRow];
                local.dirContent = directoryList(local.currentDir, false, "array");

                // If the directory is empty, delete it
                if (arrayLen(local.dirContent) == 0) {
                    directoryDelete(local.currentDir);
                }
            }
        }


    }




}



