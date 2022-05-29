<cfscript>

    objBook = new com.book('module');

    // decoding base64 value
    moduleStruct = objBook.decryptBookingLink(url.module);

    failed = false;

    // Check whether we have all the needed information
    if (!structKeyExists(moduleStruct, "moduleID")) {
        failed = true;
    }
    if (!structKeyExists(moduleStruct, "lngID")) {
        failed = true;
    }
    if (!structKeyExists(moduleStruct, "currencyID")) {
        failed = true;
    }
    if (!structKeyExists(moduleStruct, "recurring")) {
        failed = true;
    }

    if (failed) {
        getAlert('alertErrorOccured', 'danger');
        location url="#application.mainURL#/account-settings/modules" addtoken="false";
    }

    objModules = new com.modules(lngID=moduleStruct.lngID, currencyID=moduleStruct.currencyID);
    objInvoice = new com.invoices();

    // As we have all the infos, save it into variables
    variables.moduleID = moduleStruct.moduleID;
    variables.lngID = moduleStruct.lngID;
    variables.currencyID = moduleStruct.currencyID;
    variables.recurring = moduleStruct.recurring;

    // Get more module infos of the module to be booked
    moduleDetails = objModules.getModuleData(variables.moduleID);

    // Is it a free module?
    if (moduleDetails.price_yearly eq 0 and moduleDetails.price_monthly eq 0 and moduleDetails.price_onetime eq 0) {

        // Activate the free module
        insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=moduleDetails, itsTest=false, recurring=variables.recurring);

        if (insertBooking.success) {

            <!--- Save module array into a session --->
            session.currentModules = objModules.getBookedModules(session.customer_id);
            getAlert('msgModuleActivated');
            location url="#application.mainURL#/account-settings/modules" addtoken=false;

        }

    }


    // Do we have to provide any test days?
    if (isNumeric(moduleDetails.testDays) and moduleDetails.testDays gt 0) {

        // The customer can only test modules that he has not already tested
        qTestedModules = queryExecute (
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: session.customer_id},
                moduleID: {type: "numeric", value: variables.moduleID}
            },
            sql = "
                SELECT intModuleID
                FROM customer_bookings_history
                WHERE intCustomerID = :customerID
                AND intModuleID = :moduleID
                AND LENGTH(dtmEndTestDate) > 0
            "
        )

        if (!qTestedModules.recordCount) {

            // Book the module and let the customer test
            insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=moduleDetails, itsTest=true, recurring=variables.recurring);

            if (insertBooking.success) {

                <!--- Save module array into a session --->
                session.currentModules = objModules.getBookedModules(session.customer_id);
                getAlert('msgModuleActivated');
                location url="#application.mainURL#/account-settings/modules" addtoken=false;

            }

        }

    }


    // Is the call coming from payment service provider (PSP)?
    // Please make sure you provide the url variables "psp_response" and "message" with the corresponding values:
    // Response values for "psp_response" can be: succcess, failed or cancel (required)
    // Response values for "message" you can use for any messages (optional)
    if (structKeyExists(url, "psp_response")) {

        thisResponse = url.psp_response;
        param name="url.message" default="";
        if (len(trim(url.message))) {
            thisMessage = url.message;
        } else {
            thisMessage = "";
        }

        switch (thisResponse) {

            case "success":

                // Make a book for the module
                insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=moduleDetails, itsTest=false, recurring=variables.recurring);

                if (insertBooking.success) {

                    <!--- Get module status --->
                    moduleStatus = objModules.getModuleStatus(session.customer_id, moduleDetails.moduleID);

                    // Make invoice struct
                    invoiceStruct = structNew();
                    invoiceStruct['customerID'] = session.customer_id;
                    invoiceStruct['title'] = moduleDetails.name;
                    invoiceStruct['invoiceDate'] = now();
                    invoiceStruct['dueDate'] = now();
                    invoiceStruct['currency'] = moduleDetails.currency;
                    invoiceStruct['isNet'] = moduleDetails.isNet;
                    invoiceStruct['vatType'] = moduleDetails.vat_type;
                    invoiceStruct['paymentStatusID'] = 2;

                    // Make invoice and get invoice id
                    newInvoice = objInvoice.createInvoice(invoiceStruct);

                    if (newInvoice.success) {
                        invoiceID = newInvoice.newInvoiceID;
                    } else {
                        getAlert(newInvoice.message, 'danger');
                        location url="#application.mainURL#/account-settings/modules" addtoken=false;
                    }

                    // Insert a position
                    posInfo = structNew();
                    posInfo['invoiceID'] = invoiceID;
                    posInfo['append'] = false;

                    positionArray = arrayNew(1);

                    position = structNew();
                    position[1]['title'] = moduleDetails.name & ' ' & lsDateFormat(moduleStatus.startDate) & ' - ' & lsDateFormat(moduleStatus.endDate);
                    position[1]['description'] = moduleDetails.short_description;
                    position[1]['quantity'] = 1;
                    position[1]['discountPercent'] = 0;
                    position[1]['vat'] = moduleDetails.vat;
                    if (moduleStatus.recurring eq 'monthly') {
                        position[1]['unit'] = getTrans('TitMonth', session.lng);
                        position[1]['price'] = moduleDetails.price_monthly;
                        priceAfterVAT = moduleDetails.priceMonthlyAfterVAT;
                    } else {
                        position[1]['unit'] = getTrans('TitYear', session.lng);
                        position[1]['price'] = moduleDetails.price_yearly;
                        priceAfterVAT = moduleDetails.priceYearlyAfterVAT;
                    }
                    arrayAppend(positionArray, position[1]);
                    posInfo['positions'] = positionArray;

                    insPositions = objInvoice.insertInvoicePositions(posInfo);

                    if (!insPositions.success) {
                        objInvoice.deleteInvoice(invoiceID);
                        getAlert(insPositions.message, 'danger');
                        location url="#application.mainURL#/account-settings/modules" addtoken=false;
                    }

                    // This is the variable for the payment type and can be overwritten by the PSP.
                    param name="thisPaymentType" default="Credit card";

                    // Insert payment
                    payment = structNew();
                    payment['invoiceID'] = invoiceID;
                    payment['date'] = now();
                    payment['amount'] = priceAfterVAT;
                    payment['type'] = thisPaymentType;

                    insPayment = objInvoice.insertPayment(payment);

                    if (!insPayment.success) {
                        objInvoice.deleteInvoice(invoiceID);
                        getAlert(insPayment.message, 'danger');
                    } else {
                        // If everything went well, save current modules into a session
                        getAlert('msgThanksForPurchaseFindInvoice');
                        session.currentModules = objModules.getBookedModules(session.customer_id);

                    }

                    location url="#application.mainURL#/account-settings/modules" addtoken=false;




                } else {

                    getAlert(insertBooking.message, 'danger');
                    location url="#application.mainURL#/account-settings/modules" addtoken=false;

                }


            case "failed":

                param name="url.message" default="Error during the payment process!";
                getAlert(url.message, 'danger');
                location url="#application.mainURL#/account-settings/modules" addtoken=false;


            case "cancel":
                // Send the user back to the plans
                location url="#application.mainURL#/account-settings/modules" addtoken=false;

        }



    }
</cfscript>

<cfoutput>
<a href="#application.mainURL#/book?module=#url.module#&psp_response=success">OK, done!</a>
</cfoutput>