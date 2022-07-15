
<cfset getStatus = objPlan.getPlanStatusAsText(session.currentPlan)>

<cfoutput>

<dl class="row">

    <dt class="col-4">#getTrans('titYourPlan')#:</dt>
    <dd class="col-8">#session.currentPlan.planName#</dd>

    <dt class="col-4">#getTrans('txtPlanStatus')#:</dt>
    <dd class="col-8 text-#getStatus.fontColor#">#getStatus.statusTitle#</dd>

    <dt class="col-4">#getTrans('txtBookedOn')#:</dt>
    <dd class="col-8">#lsDateFormat(getTime.utc2local(utcDate=session.currentPlan.startDate))#</dd>

    <cfif session.currentPlan.status eq "active">

        <dt class="col-4">#getTrans('txtRenewPlanOn')#:</dt>
        <dd class="col-8">#lsDateFormat(getTime.utc2local(utcDate=session.currentPlan.endDate))#</dd>

    <cfelseif session.currentPlan.status eq "canceled">

        <dt class="col-4">#getTrans('txtExpiryDate')#:</dt>
        <cfif isDate(session.currentPlan.endDate)>
            <dd class="col-8">#lsDateFormat(getTime.utc2local(utcDate=session.currentPlan.endDate))#</dd>
        <cfelse>
            <dd class="col-8">#lsDateFormat(getTime.utc2local(utcDate=session.currentPlan.endTestDate))#</dd>
        </cfif>
        <dt class="col-4">#getTrans('txtInformation')#:</dt>
        <dd class="col-8">#getStatus.statusText#</dd>

    <cfelseif session.currentPlan.status eq "test">

        <dt class="col-4">#getTrans('txtExpiryDate')#:</dt>
        <dd class="col-8">#lsDateFormat(getTime.utc2local(utcDate=session.currentPlan.endTestDate))#</dd>
        <dt class="col-4">#getTrans('txtInformation')#:</dt>
        <dd class="col-8">#getStatus.statusText#</dd>

    </cfif>

</dl>

</cfoutput>