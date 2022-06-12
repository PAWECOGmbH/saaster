
<cfscript>
customer = new MockData().mock(
    $num = 10,
    company_name = "words",
    address = "words",
    addr_number = "string-numeric:2",
    zip = "string-numeric:5",
    city = "words",
    email = "email",
    countryID = "num:1:250"
);
</cfscript>

<cfloop array="#customer#" index="customer">

    <cfset isAdmin = 1>
    <cfset isSuperAdmin = 1>

    <cfscript>
    users = new MockData().mock(
        $num = 3,
        first_name = "fname",
        last_name = "lname",
        email = "email",
        emailAppendix = "string-numeric:4"
    );
    </cfscript>

    <cfset companyname = "#Left( UCase( "#customer.company_name#" ), 1 )##Right( LCase( "#customer.company_name#" ), Len("#customer.company_name#" ) - 1 )# Ltd.">
    <cfset contactname = users[1].first_name & " " & users[1].last_name>
    <cfset addr = "#Left( UCase( "#customer.address#" ), 1 )##Right( LCase( "#customer.address#" ), Len("#customer.address#" ) - 1 )# Street #customer.addr_number#">
    <cfset thisCity = "#Left( UCase( "#customer.city#" ), 1 )##Right( LCase( "#customer.city#" ), Len("#customer.city#" ) - 1 )#">
    <cfset hash = "ECB04C0076C620BA8DF6A0E6F042CA3B3BF9690B54BCC1655A820A189F0DB8DA5204005638723051A6BDBE372A7A83DFF9A82716576350A7700B628AA8B6A4F2">
    <cfset salt = "B11E536520093328FA2D05E105AA99F4B3A0790E5095286A94B2893084B570A0BE2BFF5856AC0A990FD53FC045B6844DC51CB37B7FA7CC9E9FF9E49D51B37770">


    <cfquery datasource="#application.datasource#" result="neueID">
        INSERT INTO customers (intCustParentID, dtmInsertDate, dtmMutDate, blnActive, strCompanyName, intCountryID, strContactPerson, strEmail, strAddress, strZIP, strCity)
        VALUES (0, UTC_TIMESTAMP(), UTC_TIMESTAMP(), 1, '#companyname#', 0#customer.countryID#, '#contactname#', '#customer.email#', '#addr#', '#customer.zip#', '#thisCity#')
    </cfquery>

    <cfset thisRow = 0>
    <cfloop array="#users#" index="usr">

        <cfset leftEmail = listFirst(usr.email, "@")>
        <cfset rightEmail = listLast(usr.email, "@")>
        <cfset replaceEmail = leftEmail & usr.emailAppendix>
        <cfset thisEmail = replaceEmail & "@" & rightEmail>

        <cfset thisRow++>

        <cfquery datasource="#application.datasource#">
            INSERT INTO users (intCustomerID, dtmInsertDate, dtmMutDate, strFirstName, strLastName, strEmail, strPasswordHash, strPasswordSalt, blnActive, blnAdmin, blnSuperAdmin, blnSysAdmin)
            VALUES (#neueID.generatedkey#, UTC_TIMESTAMP(), UTC_TIMESTAMP(), '#usr.first_name#', '#usr.last_name#', '#thisEmail#', '#hash#', '#salt#', 1, #isAdmin#, #isSuperAdmin#, 0)
        </cfquery>

        <cfset isSuperAdmin = 0>
        <cfif thisRow eq 2>
            <cfset isAdmin = 0>
        </cfif>

    </cfloop>

</cfloop>



<!--- <cfdump  var="#user#"> --->