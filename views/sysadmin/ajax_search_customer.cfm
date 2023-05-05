<cfsetting showdebugoutput="no">
<cfscript>
    if (!structKeyExists(session, "sysadmin") or !session.sysadmin) {
        getAlert('alertSessionExpired', 'warning');
        location url="#application.mainURL#/login" addtoken="false";
    }
    setting showdebugoutput = false;
    param name="url.search" default="";

    objSysadmin = new com.sysadmin();
    qCustomer = objSysadmin.getCustomerAjax(url.search);

</cfscript>
<div class="mt-2">
    <cfoutput query="qCustomer">
        <div class="bg-azure-lt py-2 ps-2 mb-1 cursor-pointer">
            <a onclick="intoTf('#qCustomer.customerName#, #qCustomer.strZIP# #qCustomer.strCity#', #qCustomer.intCustomerID#), hideResult();">#qCustomer.customerName#, #qCustomer.strZIP# #qCustomer.strCity#</a>
        </div>
    </cfoutput>
</div>
