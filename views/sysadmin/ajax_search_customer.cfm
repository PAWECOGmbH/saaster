<cfsetting showdebugoutput="no">
<cfscript>
    if (!structKeyExists(session, "sysadmin") or !session.sysadmin) {
        getAlert('alertSessionExpired', 'warning');
        location url="#application.mainURL#/login" addtoken="false";
    }
    setting showdebugoutput = false;
    param name="url.search" default="";
    qCustomer = queryExecute (
        options = {datasource = application.datasource},
        sql = "
            SELECT intCustomerID, strZIP, strCity,
                IF(
                    LENGTH(customers.strCompanyName),
                    customers.strCompanyName,
                    customers.strContactPerson
                ) as customerName
            FROM customers
            WHERE blnActive = 1
            AND (
                strCompanyName LIKE '%#url.search#%' OR
                strContactPerson LIKE '%#url.search#%' OR
                strZIP LIKE '%#url.search#%' OR
                strCity LIKE '%#url.search#%'
            )
            ORDER BY strCompanyName
            LIMIT 10
        "
    )
</cfscript>
<div class="mt-2">
    <cfoutput query="qCustomer">
        <div class="bg-azure-lt py-2 ps-2 mb-1 cursor-pointer">
            <a onclick="intoTf('#qCustomer.customerName#, #qCustomer.strZIP# #qCustomer.strCity#', #qCustomer.intCustomerID#), hideResult();">#qCustomer.customerName#, #qCustomer.strZIP# #qCustomer.strCity#</a>
        </div>
    </cfoutput>
</div>
