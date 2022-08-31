
<!--- <cfset currentPlanID = session.currentPlan />

<cfdump var="#currentPlanID#">
<cfabort> --->


<h2>Check Plan Feature Values</h2>

Beautiful gantt charts, Advanced<br>
<cfset test1 = application.objGlobal.getSetting(settingVariable = "testvar", planID = 3) />
<code>
    test1 = application.objGlobal.getSetting(settingVariable = "testvar", planID = 3)
</code>
<p><cfoutput>
    test1 = #test1#
</cfoutput>
</p>

Tasks, Standard<br>
<cfset test2 = application.objGlobal.getSetting(settingVariable = "taskvariable", planID = 2) />
<code>
    test2 = application.objGlobal.getSetting(settingVariable = "taskvariable", planID = 2)
</code>
<p><cfoutput>
    test2 = #test2#
</cfoutput>
</p>

Daily email reminders, Enterprise<br>
<cfset test3 = application.objGlobal.getSetting(settingVariable = "reminders", planID = 4) />
<code>
    test3 = application.objGlobal.getSetting(settingVariable = "reminders", planID = 4)
</code>
<p><cfoutput>
    test3 = #test3#
</cfoutput>
</p>

Users, Advanced<br>
<cfset test4 = application.objGlobal.getSetting(settingVariable = "bbb", planID = 3) />
<code>
    test4 = application.objGlobal.getSetting(settingVariable = "bbb", planID = 3)
</code>
<p><cfoutput>
    test4 = #test4#
</cfoutput>
</p>