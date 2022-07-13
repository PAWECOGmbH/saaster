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
                AND LENGTH(dteEndTestDate) > 0
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
    if (structKeyExists(url, "psp_response")) {

        thisResponse = url.psp_response;

        switch (thisResponse) {

            case "success":

                // Get the webhook data
                objPayrexx = new com.payrexx();

                // If we are in dev mode, get the JSON data from ftp server
                if (application.environment eq "dev") {
                    include template="/frontend/payrexx_webhook.cfm";
                }

                // Let's have a look if there is an entry of the webhook. If not, we loop a coulpe of times
                loop from="1" to="10" index="i" {
                    sleep(1000);
                    getWebhook = objPayrexx.getWebhook(session.customer_id, 'confirmed');
                    if (getWebhook.recordCount) {
                        break;
                    }
                }

                thisPaymentType = getWebhook.recordCount ? getWebhook.strPaymentBrand : "Online payment";
                payrexxID = getWebhook.recordCount ? getWebhook.intPayrexxID : 0;

                // Make a book for the module
                insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=moduleDetails, itsTest=false, recurring=variables.recurring);

                if (insertBooking.success) {

                    <!--- Get module status --->
                    moduleStatus = objModules.getModuleStatus(session.customer_id, moduleDetails.moduleID);
                    getTime = application.getTime;

                    // Make invoice struct
                    invoiceStruct = structNew();
                    invoiceStruct['customerBookingID'] = insertBooking.bookingID;
                    invoiceStruct['customerID'] = session.customer_id;
                    invoiceStruct['title'] = moduleDetails.name;
                    invoiceStruct['invoiceDate'] = now();
                    invoiceStruct['dueDate'] = now();
                    invoiceStruct['currency'] = moduleDetails.currency;
                    invoiceStruct['isNet'] = moduleDetails.isNet;
                    invoiceStruct['vatType'] = moduleDetails.vat_type;
                    invoiceStruct['paymentStatusID'] = 2;
                    invoiceStruct['language'] = session.lng;

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
                    if (moduleStatus.status eq "onetime") {
                        position[1]['title'] = moduleDetails.name;
                    } else {
                        position[1]['title'] = moduleDetails.name & ' ' & lsDateFormat(getTime.utc2local(utcDate=moduleStatus.startDate)) & ' - ' & lsDateFormat(getTime.utc2local(utcDate=moduleStatus.endDate));
                    }

                    position[1]['description'] = moduleDetails.short_description;
                    position[1]['quantity'] = 1;
                    position[1]['discountPercent'] = 0;
                    position[1]['vat'] = moduleDetails.vat;
                    if (moduleStatus.recurring eq 'monthly') {
                        position[1]['unit'] = getTrans('TitMonth', session.lng);
                        position[1]['price'] = moduleDetails.price_monthly;
                        priceAfterVAT = moduleDetails.priceMonthlyAfterVAT;
                    } else if (moduleStatus.recurring eq 'yearly') {
                        position[1]['unit'] = getTrans('TitYear', session.lng);
                        position[1]['price'] = moduleDetails.price_yearly;
                        priceAfterVAT = moduleDetails.priceYearlyAfterVAT;
                    } else {
                        position[1]['unit'] = getTrans('txtOneTime', session.lng);
                        position[1]['price'] = moduleDetails.price_onetime;
                        priceAfterVAT = moduleDetails.priceOnetimeAfterVAT;
                    }
                    arrayAppend(positionArray, position[1]);
                    posInfo['positions'] = positionArray;

                    insPositions = objInvoice.insertInvoicePositions(posInfo);

                    if (!insPositions.success) {
                        objInvoice.deleteInvoice(invoiceID);
                        getAlert(insPositions.message, 'danger');
                        location url="#application.mainURL#/account-settings/modules" addtoken=false;
                    }

                    // Insert payment
                    payment = structNew();
                    payment['invoiceID'] = invoiceID;
                    payment['customerID'] = session.customer_id;
                    payment['date'] = now();
                    payment['amount'] = priceAfterVAT;
                    payment['type'] = thisPaymentType;
                    payment['payrexxID'] = payrexxID;

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

                getAlert('Error during the payment process!', 'danger');
                location url="#application.mainURL#/account-settings/modules" addtoken=false;


            case "cancel":
                // Send the user back to the modules
                location url="#application.mainURL#/account-settings/modules" addtoken=false;

        }



    }

</cfscript>