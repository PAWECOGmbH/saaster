component displayname="log" {

    // Logging function
    public void function writeLog(required string name, required numeric severity, required string message, required boolean sendMail) {
            
        local.severityTypes = ["INFORMATION", "WARNING", "ERROR", "FATAL"];
        local.getSysadmin = new com.sysadmin().getSysAdminData();

        if(local.getSysadmin.timezoneID neq ""){
            local.getTime = new com.time(1);
        }else {
            local.getTime = new com.time();
        }
        
        local.curTime = local.getTime.utc2local(now());

        if (arguments.severity lte 4 and arguments.severity gte 1) {
            local.logMsg = local.curTime & " - " & local.severityTypes[arguments.severity] & ": " & arguments.name & " - " &  arguments.message & Chr(13) & Chr(10);
            fileAppend("../logs/#lCase(local.severityTypes[arguments.severity])#.log", local.logMsg)
            if (sendMail){
                cfmail(subject="#local.severityTypes[arguments.severity]#", to="#application.errorMail#", from="#application.toEmail#" ) {
                    writeOutput("<h3>#local.severityTypes[arguments.severity]# - #arguments.name#</h3><p>#local.curTime#</p><hr>#arguments.message#");
                }
            }
        }
    }
    
}