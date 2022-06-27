
<cfscript>

param name="url.type" default="" type="string";
param name="url.amount" default="10" type="numeric";

if(url.type eq "customer"){
    customer = new MockData().mock(
        $num = url.amount,
        company_name = "words",
        address = "words",
        addr_number = "string-numeric:2",
        zip = "string-numeric:5",
        city = "words",
        email = "email",
        countryID = "num:1:250"
    );

    for ( customer in customer ) {
        isAdmin = 1;
        isSuperAdmin = 1;
    
        users = new MockData().mock(
            $num = 3,
            first_name = "fname",
            last_name = "lname",
            email = "email",
            emailAppendix = "string-numeric:4"
        );

        companyname = "#Left( UCase( "#customer.company_name#" ), 1 )##Right( LCase( "#customer.company_name#" ), Len("#customer.company_name#" ) - 1 )# Ltd.";
        contactname = users[1].first_name & " " & users[1].last_name;

        addr = "#Left( UCase( "#customer.address#" ), 1 )##Right( LCase( "#customer.address#" ), Len("#customer.address#" ) - 1 )# Street #customer.addr_number#";
        thisCity = "#Left( UCase( "#customer.city#" ), 1 )##Right( LCase( "#customer.city#" ), Len("#customer.city#" ) - 1 )#";

        hash = "ECB04C0076C620BA8DF6A0E6F042CA3B3BF9690B54BCC1655A820A189F0DB8DA5204005638723051A6BDBE372A7A83DFF9A82716576350A7700B628AA8B6A4F2";
        salt = "B11E536520093328FA2D05E105AA99F4B3A0790E5095286A94B2893084B570A0BE2BFF5856AC0A990FD53FC045B6844DC51CB37B7FA7CC9E9FF9E49D51B37770";

        cfquery( datasource=application.datasource, result="neueID" ) {
            writeOutput("
                INSERT INTO customers (intCustParentID, dtmInsertDate, dtmMutDate, blnActive, strCompanyName, intCountryID, strContactPerson, strEmail, strAddress, strZIP, strCity)
                VALUES (0, UTC_TIMESTAMP(), UTC_TIMESTAMP(), 1, '#companyname#', 0#customer.countryID#, '#contactname#', '#customer.email#', '#addr#', '#customer.zip#', '#thisCity#')
            ");
        }

        thisRow = 0;
        for ( usr in users ) {
            leftEmail = listFirst(usr.email, "@");
            rightEmail = listLast(usr.email, "@");
            replaceEmail = leftEmail & usr.emailAppendix;
            thisEmail = replaceEmail & "@" & rightEmail;
            thisRow++;
            cfquery( datasource=application.datasource ) {
                writeOutput("
                    INSERT INTO users (intCustomerID, dtmInsertDate, dtmMutDate, strFirstName, strLastName, strEmail, strPasswordHash, strPasswordSalt, blnActive, blnAdmin, blnSuperAdmin, blnSysAdmin)
                    VALUES (#neueID.generatedkey#, UTC_TIMESTAMP(), UTC_TIMESTAMP(), '#usr.first_name#', '#usr.last_name#', '#thisEmail#', '#hash#', '#salt#', 1, #isAdmin#, #isSuperAdmin#, 0)
                ");
            }

            isSuperAdmin = 0;

            if ( thisRow == 2 ) {
                isAdmin = 0;
            }
        }
    }

}else if(url.type eq "invoice"){
    qCustomers = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT COUNT(DISTINCT intCustomerID) as totalCustomers
            FROM customers
        "
    )

    if(structKeyExists(url, "cust_id")){
        customer_id = url.cust_id
    } else{
        customer_id = qCustomers.totalCustomers;
    }

    invoice = new MockData().mock(
        $num = url.amount,
        title = "words",
        price = "num:1:10000",
        status = "num:1:6",
        desc = "baconlorem",
        discount = "num:1:50",
        cust_ID = "num:1:#customer_id#"
    );
    
    for ( invoice in invoice ) {
        objInvoice = new com.invoices();
        invoiceData = structNew();
        setting = application.objGlobal;

        invoiceData['customerID'] = invoice.cust_ID;
        invoiceData['prefix'] = setting.getSetting('settingInvoicePrefix');
        invoiceData['title'] = invoice.title;
        invoiceData['currency'] = setting.getDefaultCurrency().iso;
        invoiceData['isNet'] = setting.getSetting('settingInvoiceNet');
        invoiceData['vatType'] = setting.getSetting('settingStandardVatType');
        invoiceData['paymentStatusID'] = invoice.status;
        invoiceData['price'] = invoice.price;

        if (!len(trim(invoiceData.currency))) {
            invoiceData.currency = "USD";
        }
        if (!isNumeric(invoiceData.isNet)) {
            invoiceData.isNet = 1;
        }
        if (!isNumeric(invoiceData.vatType)) {
            invoiceData.vatType = 1;
        }

        createInvoice = objInvoice.createInvoice(invoiceData);

        posInfo = structNew();
        posInfo['invoiceID'] = createInvoice.newInvoiceID;
        posInfo['append'] = true;

        positionArray = arrayNew(1);
        position = structNew();

        position[1]['title'] = invoice.title;
        position[1]['description'] = invoice.desc;
        position[1]['price'] = invoice.price;
        position[1]['quantity'] = 1;
        position[1]['unit'] = "";
        position[1]['discountPercent'] = invoice.discount;
        position[1]['vat'] = 1;
        arrayAppend(positionArray, position[1]);

        posInfo['positions'] = positionArray;

        insPosition = objInvoice.insertInvoicePositions(posInfo);
    }
}else{
    dump("Please provide a type!");
    abort;
}
</cfscript>

<!--- <cfdump  var="#user#"> --->