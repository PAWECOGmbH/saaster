<cfscript>

    objBook = new com.book('plan', session.lng);

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
    objPayrexx = new com.payrexx();

    // As we have all the infos, save it into variables
    variables.planID = planStruct.planID;
    variables.lngID = planStruct.lngID;
    variables.currencyID = planStruct.currencyID;
    variables.recurring = planStruct.recurring;

    // Get more plan infos
    planDetails = objPlans.getPlanDetail(variables.planID);

    // First, get the booking details without a real booking
    checkBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=planDetails, recurring=variables.recurring, makeBooking=false);

    // If the amount to pay is less or equal zero, book right now and save the plan into the session
    if (structKeyExists(checkBooking, "amountToPay") and checkBooking.amountToPay lte 0) {

        makeBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=planDetails, recurring=variables.recurring, makeBooking=true);

        if (makeBooking.success) {

            <!--- Save the new plan into a session --->
            newPlan = objPlans.getCurrentPlan(session.customer_id);
            session.currentPlan = newPlan;

            <!--- Save the included modules into the module session --->
            checkModules = new com.modules(language=getAnyLanguage(variables.lngID).iso).getBookedModules(session.customer_id);
            session.currentModules = checkModules;

            getAlert('msgPlanActivated');
            location url="#application.mainURL#/dashboard" addtoken=false;

        } else {

            getAlert(makeBooking.message, 'danger');
            location url="#application.mainURL#/dashboard" addtoken=false;

        }

    }


    //
    makeBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=planDetails, recurring=variables.recurring, makeBooking=true, makeInvoice=true);

    if (makeBooking.success) {



    }

    dump(checkBooking);



    abort;



    // Is the call coming from Payrexx?
    if (structKeyExists(url, "psp_response")) {

        thisResponse = url.psp_response;

        switch (thisResponse) {

            case "success":

                // Get the webhook data
                getWebhook = objPayrexx.getWebhook(session.customer_id, 'authorized');

                thisPaymentType = getWebhook.strPaymentBrand;
                payrexxID = getWebhook.intPayrexxID;

                // Book the plan now
                makeBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=planDetails, recurring=variables.recurring, makeBooking=true, makeInvoice=true);

                if (makeBooking.success) {

                    // Update payment table
                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            invoiceID: {type: "numeric", value: makeBooking.invoiceID},
                            customerID: {type: "numeric", value: session.customer_id},
                            type: {type: "varchar", value: thisPaymentType},
                            payrexxID: {type: "numeric", value: payrexxID}
                        },
                        sql = "
                            UPDATE payments
                            SET strPaymentType = :type,
                                intPayrexxID = :payrexxID
                            WHERE intInvoiceID = :invoiceID
                            AND intCustomerID = :payrexxID
                        "
                    )


                    <!--- Save the new plan into a session --->
                    session.currentPlan = objPlans.getCurrentPlan(session.customer_id);

                    <!--- Save the included modules into the module session --->
                    checkModules = new com.modules(language=getAnyLanguage(variables.lngID).iso).getBookedModules(session.customer_id);
                    session.currentModules = checkModules;

                    getAlert('msgThanksForPurchaseFindInvoice');
                    location url="#application.mainURL#/accuunt-settings" addtoken=false;

                } else {

                    getAlert(makeBooking.message, 'danger');
                    location url="#application.mainURL#/accuunt-settings" addtoken=false;

                }


            case "failed":

                getAlert('alertErrorOccured', 'warning');
                location url="#application.mainURL#/plans" addtoken=false;


            case "cancel":

                location url="#application.mainURL#/plans" addtoken=false;


        }



    // Booking process
    } else {




        // Is it the first plan?
        if (checkBooking.amountToPay)

        // If the amount to pay is less or equal zero, book right now and save the plan into the session
        if (structKeyExists(checkBooking, "amountToPay") and checkBooking.amountToPay lte 0) {

            makeBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=planDetails, recurring=variables.recurring, makeBooking=true);

            if (makeBooking.success) {

                <!--- Save the new plan into a session --->
                newPlan = objPlans.getCurrentPlan(session.customer_id);
                session.currentPlan = newPlan;

                <!--- Save the included modules into the module session --->
                checkModules = new com.modules(language=getAnyLanguage(variables.lngID).iso).getBookedModules(session.customer_id);
                session.currentModules = checkModules;

                getAlert('msgPlanActivated');
                location url="#application.mainURL#/dashboard" addtoken=false;

            } else {

                getAlert(makeBooking.message);
                location url="#application.mainURL#/dashboard" addtoken=false;

            }


        // Let the customer pay
        } else {

            // Set some variables for payment process
            recurring = variables.recurring;
            thisStruct = planDetails;


        }



        dump(checkBooking);
        abort;















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



    }


</cfscript>