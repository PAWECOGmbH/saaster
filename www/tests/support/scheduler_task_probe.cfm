<cfscript>
/*
    Scheduletask used by the scheduler specs. It records what tasks.cfm hands to
    every task file: customerID, moduleID and lastRun.
*/
param name="request.schedulerProbe" default=[];
arrayAppend(request.schedulerProbe, { "customerID": customerID, "moduleID": moduleID, "lastRun": isDate(lastRun) ? dateTimeFormat(lastRun, "yyyy-mm-dd HH:nn:ss") : "" });
</cfscript>
