component name="mockdata-functions" {

    public function createCustomers(required numeric amount) {

        customer = new MockData().mock(
            $num = arguments.amount,
            company_name = "words",
            address = "words",
            addr_number = "string-numeric:2",
            zip = "string-numeric:5",
            city = "words",
            email = "email",
            countryID = "num:1:250"
        )

        loop array=customer index="customer" {

            local.isAdmin = 1;
            local.isSuperAdmin = 1;

            users = new MockData().mock(
                $num = 3,
                first_name = "fname",
                last_name = "lname",
                email = "email",
                emailAppendix = "string-numeric:4"
            )

            local.companyname = left(uCase( customer.company_name), 1) & right(lCase(customer.company_name), len(customer.company_name)-1) & "Ltd.";
            local.contactname = users[1].first_name & " " & users[1].last_name;
            local.addr = left(uCase( customer.address), 1) & right(lCase(customer.address), len(customer.address)-1) & " Street " & customer.addr_number;
            local.thisCity = left(uCase( customer.city), 1) & right(lCase(customer.city), len(customer.city)-1);
            local.hash = "ECB04C0076C620BA8DF6A0E6F042CA3B3BF9690B54BCC1655A820A189F0DB8DA5204005638723051A6BDBE372A7A83DFF9A82716576350A7700B628AA8B6A4F2";
            local.salt = "B11E536520093328FA2D05E105AA99F4B3A0790E5095286A94B2893084B570A0BE2BFF5856AC0A990FD53FC045B6844DC51CB37B7FA7CC9E9FF9E49D51B37770";

            queryExecute(
                options = {datasource = application.datasource, result="neueID"},
                params = {
                    dateNow: {type: "datetime", value: now()}
                },
                sql = "
                    INSERT INTO customers (intCustParentID, dtmInsertDate, dtmMutDate, blnActive, strCompanyName, intCountryID, strContactPerson, strEmail, strAddress, strZIP, strCity)
                    VALUES (0, :dateNow, :dateNow, 1, '#companyname#', 0#customer.countryID#, '#contactname#', '#customer.email#', '#addr#', '#customer.zip#', '#thisCity#')
                "
            )

            local.thisRow = 0;
            loop array=users index="usr" {

                local.leftEmail = listFirst(usr.email, "@");
                local.rightEmail = listLast(usr.email, "@");
                local.replaceEmail = leftEmail & usr.emailAppendix;
                local.thisEmail = replaceEmail & "@" & rightEmail;

                local.thisRow++;

                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        dateNow: {type: "datetime", value: now()}
                    },
                    sql = "
                        INSERT INTO users (intCustomerID, dtmInsertDate, dtmMutDate, strFirstName, strLastName, strEmail, strPasswordHash, strPasswordSalt, blnActive, blnAdmin, blnSuperAdmin, blnSysAdmin)
                        VALUES (#neueID.generatedkey#, :dateNow, :dateNow, '#usr.first_name#', '#usr.last_name#', '#thisEmail#', '#hash#', '#salt#', 1, #isAdmin#, #isSuperAdmin#, 0)
                    "
                )

                local.isSuperAdmin = 0;
                if (thisRow eq 2) {
                    local.isAdmin = 0;
                }

            }

        }

        return true;

    }


    public function createInvoices(required numeric amount, numeric customer) {

        objInvoice = new backend.core.com.invoices();
        invoiceData = structNew();
        setting = application.objSettings;

        local.objCurrency = new backend.core.com.currency();

        qCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(DISTINCT intCustomerID) as totalCustomers
                FROM customers
            "
        )

        if(structKeyExists(arguments, "customer") and arguments.customer neq 0){
            local.customer_id = arguments.customer
        } else{
            local.customer_id = qCustomers.totalCustomers;
        }

        invoice = new MockData().mock(
            $num = arguments.amount,
            title = "words",
            price = "num:1:10000",
            status = "num:1:6",
            desc = "baconlorem",
            discount = "num:1:50",
            cust_ID = "num:1:#local.customer_id#"
        );

        loop array=invoice index="invoice" {
            invoiceData['customerID'] = invoice.cust_ID;
            invoiceData['prefix'] = setting.getSetting('settingInvoicePrefix');
            invoiceData['title'] = invoice.title;
            invoiceData['currency'] = local.objCurrency.getCurrency().iso;
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

        return true;
    }

}