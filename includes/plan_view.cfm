
<cfset getStatus = objPlans.getPlanStatusAsText(session.currentPlan)>

<cfoutput>

<dl class="row p-2">

    <dt class="col-5">#getTrans('titYourCurrentPlan')#:</dt>
    <dd class="col-7">#session.currentPlan.planName#</dd>

    <dt class="col-5">#getTrans('txtPlanStatus')#:</dt>
    <dd class="col-7 text-#getStatus.fontColor#">#getStatus.statusTitle#</dd>

    <cfif session.currentPlan.recurring neq "onetime" and session.currentPlan.status eq "active">

        <dt class="col-5">#getTrans('titCycle')#:</dt>
        <dd class="col-7">
            <cfif session.currentPlan.recurring eq "monthly">
                #getTrans('txtMonthly')#
            <cfelse>
                #getTrans('txtYearly')#
            </cfif>
        </dd>

    </cfif>

    <dt class="col-5">#getTrans('txtBookedOn')#:</dt>
    <dd class="col-7">#lsDateFormat(application.getTime.utc2local(utcDate=session.currentPlan.startDate))#</dd>

    <cfif structKeyExists(session.currentPlan, "nextPlan") and !structIsEmpty(session.currentPlan.nextPlan)>

        <dt class="col-5 mt-3">#getTrans('txtNewPlanName')#:</dt>
        <dd class="col-7 mt-3">#session.currentPlan.nextPlan.planName#</dd>

        <cfif session.currentPlan.nextPlan.recurring neq "onetime">

            <dt class="col-5">#getTrans('titCycle')#:</dt>
            <dd class="col-7">
                <cfif session.currentPlan.nextPlan.recurring eq "monthly">
                    #getTrans('txtMonthly')#
                <cfelse>
                    #getTrans('txtYearly')#
                </cfif>
            </dd>

        </cfif>

        <dt class="col-5">#getTrans('txtActivationOn')#:</dt>
        <dd class="col-7">#lsDateFormat(application.getTime.utc2local(utcDate=session.currentPlan.nextPlan.startDate))#</dd>

    <cfelse>

        <cfif session.currentPlan.status eq "active" and  session.currentPlan.recurring neq "onetime">

            <dt class="col-5">#getTrans('txtRenewPlanOn')#:</dt>
            <dd class="col-7">#lsDateFormat(application.getTime.utc2local(utcDate=session.currentPlan.endDate))#</dd>

        <cfelseif session.currentPlan.status eq "canceled">

            <cfif session.currentPlan.recurring neq "onetime">
                <dt class="col-5">#getTrans('txtExpiryDate')#:</dt>
                <dd class="col-7">#lsDateFormat(application.getTime.utc2local(utcDate=session.currentPlan.endDate))#</dd>
            </cfif>
            <dt class="col-5">#getTrans('txtInformation')#:</dt>
            <dd class="col-7">#getStatus.statusText#</dd>

        <cfelseif session.currentPlan.status eq "test">

            <dt class="col-5">#getTrans('txtExpiryDate')#:</dt>
            <dd class="col-7">#lsDateFormat(application.getTime.utc2local(utcDate=session.currentPlan.endDate))#</dd>
            <dt class="col-5">#getTrans('txtInformation')#:</dt>
            <dd class="col-7">#getStatus.statusText#</dd>

        <cfelseif session.currentPlan.status eq "expired">

            <dt class="col-5">#getTrans('txtExpiryDate')#:</dt>
            <cfif isDate(session.currentPlan.endDate)>
                <dd class="col-7">#lsDateFormat(application.getTime.utc2local(utcDate=session.currentPlan.endDate))#</dd>
            <cfelse>
                <dd class="col-7">#lsDateFormat(application.getTime.utc2local(utcDate=session.currentPlan.endDate))#</dd>
            </cfif>

        </cfif>

    </cfif>

</dl>

</cfoutput>