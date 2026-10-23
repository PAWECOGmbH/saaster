<cfscript>
// Scheduletask used by the scheduler specs: always fails.
throw(type = "Saaster.Tests.SchedulerProbe", message = "Probe task failed on purpose");
</cfscript>
