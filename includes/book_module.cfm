<cfscript>

    objModules = new com.modules();
    objBook = new com.book();
    objInvoice = new com.invoices();

    // decoding base64 value
    moduleStruct = objBook.decryptBookingLink(url.module);

    dump(moduleStruct);


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

    // As we have all the infos, save it into variables
    variables.moduleID = moduleStruct.moduleID;
    variables.lngID = moduleStruct.lngID;
    variables.currencyID = moduleStruct.currencyID;
    variables.recurring = moduleStruct.recurring;

    // Get more module infos of the module to be booked
    moduleDetails = objModules.getModuleData(variables.moduleID, variables.lngID, variables.currencyID);

    // Is it a free module?
    if (moduleDetails.price_yearly eq 0 and moduleDetails.price_monthly eq 0 and moduleDetails.price_onetime eq 0) {

        // Activate the free module

        insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=moduleDetails, itsTest=false, recurring=variables.recurring);

        if (insertBooking.success) {

            <!--- Save module array into a session --->
            session.currentModules = objModules.getBookedModules(session.customer_id);
            location url="#application.mainURL#/dashboard" addtoken=false;

        }

    }

    dump(moduleDetails);

    // loop over booked modules


    // Did the customer already book this module?
    if (structKeyExists(moduleDetails, "moduleID") and moduleDetails.moduleID gt 0) {

        // Is it the same module?
        if (moduleDetails.moduleID eq moduleDetails.moduleID) {



            // If the plan has been expired, renew
            if (moduleDetails.status eq "expired") {

                // Do nothing and let the customer book... down to the next step

            } else {

                // Back to dashboard
                location url="#application.mainURL#/dashboard" addtoken=false;
            }


        }

    }


    // Do we have to provide any test days?
    if (isNumeric(moduleDetails.testDays) and moduleDetails.testDays gt 0) {

        // The customer can only test modules that he has not already tested.
        qTestedModules = queryExecute (
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: session.customer_id},
                moduleID: {type: "numeric", value: variables.moduleID}
            },
            sql = "
                SELECT intModuleID
                FROM customer_bookings
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
                location url="#application.mainURL#/dashboard" addtoken=false;

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

                // Make a book for the plan
                insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=moduleDetails, itsTest=false, recurring=variables.recurring);

                // get current module from array
                moduleArray = objModules.getCurrentModules(session.customer_id, session.lng);
                if (isArray(moduleArray) and arrayLen(moduleArray)) {
                    moduleID = variables.moduleID;
                    moduleStruct = ArrayFilter(moduleArray, function(p) {
                        moduleID = p.moduleID eq moduleID;
                    })
                    return moduleStruct[1];
                } else {
                    return moduleStruct;
                }

                dump(moduleStruct);
                abort;

                if (insertBooking.success) {

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
                        location url="#application.mainURL#/dashboard" addtoken=false;
                    }

                    // Insert a position
                    posInfo = structNew();
                    posInfo['invoiceID'] = invoiceID;
                    posInfo['append'] = false;

                    positionArray = arrayNew(1);

                    position = structNew();
                    position[1]['title'] = moduleDetails.name & ' ' & lsDateFormat(newPlan.startDate) & ' - ' & lsDateFormat(newPlan.endDate);
                    position[1]['description'] = moduleDetails.shortDescription;
                    position[1]['quantity'] = 1;
                    position[1]['discountPercent'] = 0;
                    position[1]['vat'] = moduleDetails.vat;
                    if (newPlan.recurring eq 'monthly') {
                        position[1]['unit'] = getTrans('TitMonth', session.lng);
                        position[1]['price'] = moduleDetails.priceMonthly;
                        priceAfterVAT = moduleDetails.priceMonthlyAfterVAT;
                    } else {
                        position[1]['unit'] = getTrans('TitYear', session.lng);
                        position[1]['price'] = moduleDetails.priceYearly;
                        priceAfterVAT = moduleDetails.priceYearlyAfterVAT;
                    }
                    arrayAppend(positionArray, position[1]);
                    posInfo['positions'] = positionArray;

                    insPositions = objInvoice.insertInvoicePositions(posInfo);

                    if (!insPositions.success) {
                        objInvoice.deleteInvoice(invoiceID);
                        getAlert(insPositions.message, 'danger');
                        location url="#application.mainURL#/dashboard" addtoken=false;
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
                        // If everything went well, save plan into the session
                        session.currentPlan = newPlan;
                    }

                    location url="#application.mainURL#/dashboard" addtoken=false;




                } else {

                    getAlert(insertBooking.message, 'danger');
                    location url="#application.mainURL#/plans" addtoken=false;

                }


            case "failed":

                param name="url.message" default="Error during the payment process!";
                getAlert(url.message, 'danger');
                location url="#application.mainURL#/plans" addtoken=false;


            case "cancel":
                // Send the user back to the plans
                location url="#application.mainURL#/plans" addtoken=false;

        }



    }
</cfscript>

<cfoutput>
<a href="#application.mainURL#/book?plan=#url.plan#&psp_response=success">OK, done!</a>
</cfoutput>