<cfscript>

    objBook = new backend.core.com.book('plan', session.lng);

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
        logWrite("system", "error", "Booking a plan failed, data in moduleStruct missing [CustomerID: #session.customer_ID#, UserID: #session.user_ID#, PlanID: #planID#]");
        location url="#application.mainURL#/account-settings" addtoken="false";

    }

    objPlans = new backend.core.com.plans(lngID=planStruct.lngID, currencyID=planStruct.currencyID);
    objPayrexx = new backend.core.com.payrexx();
    getAnyLanguage = application.objLanguage.getAnyLanguage;

    // As we have all the infos, save it into variables
    planID = planStruct.planID;
    lngID = planStruct.lngID;
    currencyID = planStruct.currencyID;
    recurring = planStruct.recurring;

    // Get more plan infos
    planDetails = objPlans.getPlanDetail(planID);

    // First, get the booking details without a real booking
    checkBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=planDetails, recurring=recurring, makeBooking=false, chargeInvoice=false);

    local.payrexxFirst = false;

    // If the amount to pay is less or equal zero, book right now and save the plan into the session
    if (structKeyExists(checkBooking, "amountToPay") and checkBooking.amountToPay lte 0) {

        makeBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=planDetails, recurring=recurring, makeBooking=true, chargeInvoice=false);

        if (makeBooking.success) {

            // Set plans and modules as well as the custom settings into a session
            application.objCustomer.setProductSessions(session.customer_id, getAnyLanguage(lngID).iso);

            getAlert('msgPlanActivated');
            logWrite("user", "info", "A plan has been activated [CustomerID: #session.customer_ID#, UserID: #session.user_ID#, PlanID: #planID#]");
            location url="#application.mainURL#/account-settings" addtoken=false;

        } else {

            getAlert(makeBooking.message, 'danger');
            logWrite("system", "error", "Could not book a plan [CustomerID: #session.customer_ID#, UserID: #session.user_ID#, PlanID: #planID#, Error: #makeBooking.message#]");
            location url="#application.mainURL#/account-settings" addtoken=false;

        }


    } else {

        // If its the first login, the user hasn't a payment method, send to Payrexx first
        if (structKeyExists(session, "redirect") and findNoCase("plan=", session.redirect)) {

            location url="#application.mainURL#/payment-settings?add=#session.customer_id#" addtoken=false;

        }


    }

    // Let's save the booking now and charge the amount ('makeInvoice' also charges the customers credit card)
    makeBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=planDetails, recurring=recurring, makeBooking=true, makeInvoice=true, chargeInvoice=true);

    if (makeBooking.success) {

        // Set plans and modules as well as the custom settings into a session
        application.objCustomer.setProductSessions(session.customer_id, getAnyLanguage(lngID).iso);

        getAlert('msgThanksForPurchaseFindInvoice');
        logWrite("user", "info", "A booked plan has been paid [CustomerID: #session.customer_ID#, UserID: #session.user_ID#, PlanID: #planID#]");
        location url="#application.mainURL#/account-settings" addtoken=false;

    } else {

        // If the amount couldn't be charged we have to send the customer back to the payment page
        if (makeBooking.message eq "cannotcharge") {
            getAlert('msgCannotCharge', 'warning');
            logWrite("system", "warning", "Could not charge payment [CustomerID: #session.customer_ID#, UserID: #session.user_ID#, PlanID: #planID#]");
            location url="#application.mainURL#/account-settings/payment" addtoken=false;
        } else {
            getAlert(makeBooking.message, 'danger');
            logWrite("system", "error", "Could not charge payment [CustomerID: #session.customer_ID#, UserID: #session.user_ID#, PlanID: #planID#, Error: #makeBooking.message#]");
            location url="#application.mainURL#/account-settings" addtoken=false;
        }

    }


</cfscript>