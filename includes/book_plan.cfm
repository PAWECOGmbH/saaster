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
        location url="#application.mainURL#/account-settings" addtoken="false";
    }

    objPlans = new com.plans(lngID=planStruct.lngID, currencyID=planStruct.currencyID);
    objPayrexx = new com.payrexx();
    getAnyLanguage = application.objGlobal.getAnyLanguage;

    // As we have all the infos, save it into variables
    planID = planStruct.planID;
    lngID = planStruct.lngID;
    currencyID = planStruct.currencyID;
    recurring = planStruct.recurring;

    // Get more plan infos
    planDetails = objPlans.getPlanDetail(planID);

    // First, get the booking details without a real booking
    checkBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=planDetails, recurring=recurring, makeBooking=false, chargeInvoice=false);

    // If the amount to pay is less or equal zero, book right now and save the plan into the session
    if (structKeyExists(checkBooking, "amountToPay") and checkBooking.amountToPay lte 0) {

        makeBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=planDetails, recurring=recurring, makeBooking=true, chargeInvoice=false);

        if (makeBooking.success) {

            // Set plans and modules as well as the custom settings into a session
            application.objCustomer.setProductSessions(session.customer_id, getAnyLanguage(lngID).iso);

            getAlert('msgPlanActivated');
            location url="#application.mainURL#/account-settings" addtoken=false;

        } else {

            getAlert(makeBooking.message, 'danger');
            location url="#application.mainURL#/account-settings" addtoken=false;

        }

    }


    // Let's save the booking now and charge the amount ('makeInvoice' also charges the customers credit card)
    makeBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=planDetails, recurring=recurring, makeBooking=true, makeInvoice=true, chargeInvoice=true);

    if (makeBooking.success) {

        // Set plans and modules as well as the custom settings into a session
        application.objCustomer.setProductSessions(session.customer_id, getAnyLanguage(lngID).iso);

        getAlert('msgThanksForPurchaseFindInvoice');
        location url="#application.mainURL#/account-settings" addtoken=false;

    } else {

        // If the amount couldn't be charged we have to send the customer back to the payment page
        if (makeBooking.message eq "cannotcharge") {
            getAlert('msgCannotCharge', 'warning');
            location url="#application.mainURL#/account-settings/payment" addtoken=false;
        } else {
            getAlert(makeBooking.message, 'danger');
            location url="#application.mainURL#/account-settings" addtoken=false;
        }

    }

</cfscript>