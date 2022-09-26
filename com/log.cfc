component displayname="log" {

    // Logging function
    public function writeLog(required string name, required numeric severity, required string message, required boolean sendMail) {
            
        local.severityTypes = ["INFORMATION", "WARNING", "ERROR", "FATAL"];

        if (arguments.severity lte 4 and arguments.severity gte 1) {
            local.logMsg = dateTimeFormat(now(), "long") & " - " & local.severityTypes[arguments.severity] & ": " & arguments.name & " - " &  arguments.message & Chr(13) & Chr(10);
            fileAppend("../logs/#lCase(local.severityTypes[arguments.severity])#.log", local.logMsg)
            if (sendMail){
                cfmail(subject="#local.severityTypes[arguments.severity]#", to="#application.errorMail#", from="#application.toEmail#" ) {
                    writeOutput("<h3>#local.severityTypes[arguments.severity]# - #arguments.name#</h3><p>#dateTimeFormat(now(), "long")#</p><hr>#arguments.message#");
                }
            }
        }
    }
    
}