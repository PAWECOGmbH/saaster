<cfscript>

    objBook = new com.book('plan');

    // decoding base64 value
    planStruct = objBook.decryptBookingLink(url.plan);

    failed = false;

    // Check whether we have all the needed information
    if (!structKeyExists(planStruct, "planID")) {
        failed = true;
    }
    if (!structKeyExists(planStruct, "lngID")) {
        failed = true;
    }
    if (!structKeyExists(planStruct, "currencyID")) {
        failed = true;
    }
    if (!structKeyExists(planStruct, "recurring")) {
        failed = true;
    }

    if (failed) {
        getAlert('alertErrorOccured', 'danger');
        location url="#application.mainURL#/plans" addtoken="false";
    }

    objPlans = new com.plans(lngID=planStruct.lngID, currencyID=planStruct.currencyID);
    objInvoice = new com.invoices();
    objPayrexx = new com.payrexx();

    // As we have all the infos, save it into variables
    variables.planID = planStruct.planID;
    variables.lngID = planStruct.lngID;
    variables.currencyID = planStruct.currencyID;
    variables.recurring = planStruct.recurring;

    // Get more plan infos
    planDetails = objPlans.getPlanDetail(variables.planID);

    // Check customers current plan (if exists)
    currentPlan = objPlans.getCurrentPlan(session.customer_id);


    // Is the call coming from our PSP?
    if (structKeyExists(url, "psp_response")) {

        thisResponse = url.psp_response;

        switch (thisResponse) {

            case "success":

                // If we are in dev mode, call the JSON data from the given server
                if (application.environment eq "dev") {
                    include template="/frontend/payrexx_webhook.cfm";
                }

                // Get the webhook data
                getWebhook = objPayrexx.getWebhook(session.customer_id, 'authorized');

                // If there is no data from the webhook, send the customer back and try again
                if (!getWebhook.recordCount) {
                    getAlert('alertErrorOccured', 'warning');
                    location url="#application.mainURL#/account-settings" addtoken=false;
                }

                thisPaymentType = getWebhook.strPaymentBrand;
                payrexxID = getWebhook.intPayrexxID;

                // Make a book for the plan
                insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=planDetails, itsTest=false, recurring=variables.recurring);

                if (insertBooking.success) {

                    newPlan = objPlans.getCurrentPlan(session.customer_id);
                    getTime = application.getTime;

                    // Make invoice struct
                    invoiceStruct = structNew();
                    invoiceStruct['customerBookingID'] = insertBooking.bookingID;
                    invoiceStruct['customerID'] = session.customer_id;
                    invoiceStruct['title'] = planDetails.planName;
                    invoiceStruct['currency'] = planDetails.currency;
                    invoiceStruct['isNet'] = planDetails.isNet;
                    invoiceStruct['vatType'] = planDetails.vatType;
                    invoiceStruct['paymentStatusID'] = 2;
                    invoiceStruct['language'] = session.lng;
                    invoiceStruct['invoiceDate'] = getTime.utc2local(utcDate=now());
                    invoiceStruct['dueDate'] = getTime.utc2local(utcDate=now());

                    // Make invoice and get invoice id
                    newInvoice = objInvoice.createInvoice(invoiceStruct);

                    if (newInvoice.success) {
                        invoiceID = newInvoice.newInvoiceID;
                    } else {
                        getAlert(newInvoice.message, 'danger');
                        location url="#application.mainURL#/account-settings" addtoken=false;
                    }

                    // Insert a position
                    posInfo = structNew();
                    posInfo['invoiceID'] = invoiceID;
                    posInfo['append'] = false;

                    positionArray = arrayNew(1);

                    position = structNew();
                    position[1]['title'] = planDetails.planName & ' ' & lsDateFormat(getTime.utc2local(utcDate=newPlan.startDate)) & ' - ' & lsDateFormat(getTime.utc2local(utcDate=newPlan.endDate));
                    position[1]['description'] = planDetails.shortDescription;
                    position[1]['quantity'] = 1;
                    position[1]['discountPercent'] = 0;
                    position[1]['vat'] = planDetails.vat;
                    if (newPlan.recurring eq 'monthly') {
                        position[1]['unit'] = getTrans('TitMonth', session.lng);
                        position[1]['price'] = planDetails.priceMonthly;
                        priceAfterVAT = planDetails.priceMonthlyAfterVAT;
                    } else {
                        position[1]['unit'] = getTrans('TitYear', session.lng);
                        position[1]['price'] = planDetails.priceYearly;
                        priceAfterVAT = planDetails.priceYearlyAfterVAT;
                    }
                    arrayAppend(positionArray, position[1]);
                    posInfo['positions'] = positionArray;

                    insPositions = objInvoice.insertInvoicePositions(posInfo);

                    if (!insPositions.success) {
                        objInvoice.deleteInvoice(invoiceID);
                        getAlert(insPositions.message, 'danger');
                        location url="#application.mainURL#/account-settings" addtoken=false;
                    }

                    // Charge the amount now (Payrexx)
                    chargeNow = objInvoice.payInvoice(invoiceID);
                    if (!chargeNow.success) {
                        getAlert(chargeNow.message, 'danger');
                        location url="#application.mainURL#/account-settings" addtoken=false;
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
                        getAlert(insPayment.message, 'danger');
                        location url="#application.mainURL#/account-settings" addtoken=false;
                    }


                    // Save plan into the session
                    session.currentPlan = newPlan;

                    <!--- Save the included modules into the module session --->
                    checkModules = new com.modules(language=getAnyLanguage(variables.lngID).iso).getBookedModules(session.customer_id);
                    session.currentModules = checkModules;

                    getAlert('msgThanksForPurchaseFindInvoice');
                    location url="#application.mainURL#/dashboard" addtoken=false;



                } else {

                    getAlert(insertBooking.message, 'danger');
                    location url="#application.mainURL#/plans" addtoken=false;

                }


            case "failed":

                getAlert('alertErrorOccured', 'warning');
                location url="#application.mainURL#/plans" addtoken=false;


            case "cancel":

                // Send the user back to the plans
                location url="#application.mainURL#/plans" addtoken=false;


        }



    // Booking process
    } else {


        //dump(currentPlan);
        //dump(planStruct);
        //dump(planDetails);

        makeBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=planDetails, recurring=variables.recurring);

        dump(makeBooking);

        abort;



        // Is there already a plan?
        if (structKeyExists(currentPlan, "planID") and currentPlan.planID gt 0) {

            // Same plan
            if (currentPlan.planID eq planStruct.planID) {

                // Same recurring type
                if (currentPlan.recurring eq planStruct.recurring) {

                    location url="#application.mainURL#/account-settings" addtoken=false;

                // Other recurring type
                } else {

                    // From yearly to monthly
                    if (currentPlan.recurring eq "yearly" and planStruct.recurring eq "monthly") {

                        // Add entry to the table with one month runtime (append) and change the recurring type
                        insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=planDetails, itsTest=false, recurring=variables.recurring);


                    }

                    // From monthly to yearly




                    // From test to monthly/yearly


                    // From monthly/yearly/test to free







                }

            }


            // Downgrade



            // Upgrade




        }


        abort;






        // Is it a free plan?
        if (planDetails.itsFree) {

            // Book the free plan

            insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=planDetails, itsTest=false, recurring=variables.recurring);

            if (insertBooking.success) {

                <!--- Save the new plan into a session --->
                newPlan = objPlans.getCurrentPlan(session.customer_id);
                session.currentPlan = newPlan;

                <!--- Save the included modules into the module session --->
                checkModules = new com.modules(language=getAnyLanguage(variables.lngID).iso).getBookedModules(session.customer_id);
                session.currentModules = checkModules;

                getAlert('msgPlanActivated');

            } else {

                getAlert(insertBooking.message, 'danger');

            }

            location url="#application.mainURL#/account-settings" addtoken=false;

        }









        /* upgrading = false;


        // Is there already a plan?
        if (structKeyExists(currentPlan, "planID") and currentPlan.planID gt 0 and currentPlan.status neq "expired" and currentPlan.status neq "test") {

            // Is it the same plan?
            if (currentPlan.planID eq planDetails.planID or currentPlan.status eq "free") {

                // If the plan has been expired, renew
                if (currentPlan.status eq "expired" or currentPlan.status eq "free") {

                    // Do nothing and let the customer book... down to the next step

                } else {

                    // Back to dashboard
                    getAlert('msgPlanActivated');
                    location url="#application.mainURL#/account-settings" addtoken=false;

                }


            } else {

                // The customer wants to make an up- or downgrade

                // Upgrade
                if (currentPlan.priceMonthly lt planDetails.priceMonthly) {

                    // Calculate the amount to be charged right now
                    recalcStruct = objPlans.calculateUpgrade(session.customer_id, planDetails.planID, variables.recurring);

                    // Update booking table
                    updateStruct = structNew();
                    updateStruct['customerID'] = session.customer_id;
                    updateStruct['planID'] = currentPlan.planID;
                    updateStruct['dateStart'] = now();
                    updateStruct['dateEnd'] = currentPlan.endDate;
                    updateStruct['recurring'] = variables.recurring;
                    updateStruct['newPlanID'] = planDetails.planID;

                    updateBooking = objPlans.updateCurrentPlan(updateStruct);

                    if (updateBooking.success) {
                        customerBookingID = updateBooking.customerBookingID
                    } else {
                        getAlert(updateBooking.message, 'danger');
                        location url="#application.mainURL#/account-settings" addtoken=false;
                    }


                    // Make invoice struct
                    invoiceStruct = structNew();
                    invoiceStruct['customerBookingID'] = customerBookingID;
                    invoiceStruct['customerID'] = session.customer_id;
                    invoiceStruct['title'] = getTrans('titUpgrade') & " " & planDetails.planName;
                    invoiceStruct['currency'] = planDetails.currency;
                    invoiceStruct['isNet'] = planDetails.isNet;
                    invoiceStruct['vatType'] = planDetails.vatType;
                    invoiceStruct['paymentStatusID'] = 2;
                    invoiceStruct['language'] = session.lng;
                    invoiceStruct['invoiceDate'] = getTime.utc2local(utcDate=now());
                    invoiceStruct['dueDate'] = getTime.utc2local(utcDate=now());

                    // Make invoice and get invoice id
                    newInvoice = objInvoice.createInvoice(invoiceStruct);

                    if (newInvoice.success) {
                        invoiceID = newInvoice.newInvoiceID;
                    } else {
                        getAlert(newInvoice.message, 'danger');
                        location url="#application.mainURL#/account-settings" addtoken=false;
                    }

                    // Insert a position
                    posInfo = structNew();
                    posInfo['invoiceID'] = invoiceID;
                    posInfo['append'] = false;

                    positionArray = arrayNew(1);

                    getTime = application.getTime;

                    // Main position
                    position = structNew();
                    position[1]['title'] = planDetails.planName & ' ' & lsDateFormat(getTime.utc2local(utcDate=now())) & ' - ' & lsDateFormat(getTime.utc2local(utcDate=currentPlan.endDate)) & ' (' & getTrans('titUpgrade') & ')';
                    position[1]['description'] = planDetails.shortDescription;
                    position[1]['quantity'] = 1;
                    position[1]['discountPercent'] = 0;
                    position[1]['vat'] = planDetails.vat;
                    position[1]['price'] = recalcStruct.toPayNow;
                    arrayAppend(positionArray, position[1]);
                    posInfo['positions'] = positionArray;

                    insPositions = objInvoice.insertInvoicePositions(posInfo);

                    if (!insPositions.success) {
                        objInvoice.deleteInvoice(invoiceID);
                        getAlert(insPositions.message, 'danger');
                        location url="#application.mainURL#/account-settings" addtoken=false;
                    }

                    // Charge the amount now (Payrexx)
                    chargeNow = objInvoice.payInvoice(invoiceID);
                    if (!chargeNow.success) {
                        getAlert(chargeNow.message, 'danger');
                        location url="#application.mainURL#/account-settings" addtoken=false;
                    }

                    // If we are in dev mode, call the JSON data from the given server
                    if (application.environment eq "dev") {
                        include template="/frontend/payrexx_webhook.cfm";
                    }

                    // Get the webhook data
                    getWebhook = objPayrexx.getWebhook(session.customer_id, 'confirmed');
                    if (!getWebhook.recordCount) {
                        getAlert('alertErrorOccured', 'warning');
                        location url="#application.mainURL#/account-settings" addtoken=false;
                    }


                    // Insert payment
                    payment = structNew();
                    payment['invoiceID'] = invoiceID;
                    payment['customerID'] = session.customer_id;
                    payment['date'] = now();
                    payment['amount'] = objInvoice.getInvoiceData(invoiceID).total;
                    payment['type'] = getWebhook.strPaymentBrand;
                    payment['payrexxID'] = getWebhook.intPayrexxID;

                    insPayment = objInvoice.insertPayment(payment);

                    if (!insPayment.success) {
                        getAlert(insPayment.message, 'danger');
                        location url="#application.mainURL#/account-settings" addtoken=false;
                    }

                    <!--- Save the new plan into a session --->
                    session.currentPlan = objPlans.getCurrentPlan(session.customer_id);

                    <!--- Save the included modules into the module session --->
                    checkModules = new com.modules(language=getAnyLanguage(variables.lngID).iso).getBookedModules(session.customer_id);
                    session.currentModules = checkModules;

                    getAlert('msgThanksForPurchaseFindInvoice');
                    location url="#application.mainURL#/dashboard" addtoken=false;

                    upgrading = true;


                // Downgrade or same price
                } else {

                    insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=planDetails, itsTest=false, recurring=variables.recurring);

                    if (insertBooking.success) {

                        <!--- Save the new plan into a session --->
                        session.currentPlan = objPlans.getCurrentPlan(session.customer_id);

                        <!--- Save the included modules into the module session --->
                        checkModules = new com.modules(language=getAnyLanguage(variables.lngID).iso).getBookedModules(session.customer_id);
                        session.currentModules = checkModules;

                        getAlert('msgPlanActivated');
                        location url="#application.mainURL#/account-settings" addtoken=false;

                    }


                }


            }


        } */





        // Do we have to provide any test days?
        if (isNumeric(planDetails.testDays) and planDetails.testDays gt 0 and !upgrading) {

            // The customer can only test plans that he has not already tested.
            qTestedPlans = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: session.customer_id},
                    planID: {type: "numeric", value: variables.planID}
                },
                sql = "
                    SELECT intPlanID
                    FROM customer_bookings_history
                    WHERE intCustomerID = :customerID
                    AND intPlanID = :planID
                    AND LENGTH(dteEndTestDate) > 0
                "
            )

            if (!qTestedPlans.recordCount) {

                // Book the plan and let the customer test
                insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=planDetails, itsTest=true, recurring=variables.recurring);

                if (insertBooking.success) {

                    <!--- Save the new plan into a session --->
                    session.currentPlan = objPlans.getCurrentPlan(session.customer_id);

                    <!--- Save the modules into the module session --->
                    checkModules = new com.modules(language=getAnyLanguage(variables.lngID).iso).getBookedModules(session.customer_id);
                    session.currentModules = checkModules;

                    getAlert('msgPlanActivated');
                    location url="#application.mainURL#/account-settings" addtoken=false;

                }

            }

        }


    }


</cfscript>