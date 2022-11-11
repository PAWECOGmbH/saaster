<cfscript>

    objBook = new com.book('module', session.lng);

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
    moduleID = moduleStruct.moduleID;
    lngID = moduleStruct.lngID;
    currencyID = moduleStruct.currencyID;
    recurring = moduleStruct.recurring;

    // Get more module infos of the module to be booked
    moduleDetails = objModules.getModuleData(moduleID);

    // First, get the booking details without a real booking
    checkBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=moduleDetails, recurring=recurring, makeBooking=false);


    // If the amount to pay is less or equal zero, book right now and save the plan into the session
    if (structKeyExists(checkBooking, "amountToPay") and checkBooking.amountToPay lte 0) {

        makeBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=moduleDetails, recurring=recurring, makeBooking=true);

        if (makeBooking.success) {

            // Save module array into a session
            session.currentModules = objModules.getBookedModules(session.customer_id);
            getAlert('msgModuleActivated');
            location url="#application.mainURL#/account-settings/modules" addtoken=false;

        } else {

            getAlert(makeBooking.message, 'danger');
            location url="#application.mainURL#/account-settings/modules" addtoken=false;

        }


    }


    // Let's save the booking now and charge the amount ('makeInvoice' also charges the customers credit card)
    makeBooking = objBook.checkBooking(customerID=session.customer_id, bookingData=moduleDetails, recurring=recurring, makeBooking=true, makeInvoice=true, chargeInvoice=true);

    if (makeBooking.success) {

        // Save module array into a session
        session.currentModules = objModules.getBookedModules(session.customer_id);

        getAlert('msgThanksForPurchaseFindInvoice');
        location url="#application.mainURL#/account-settings/modules" addtoken=false;

    } else {

        // If the amount couldn't be charged we have to send the customer back to the payment page
        if (makeBooking.message eq "cannotcharge") {
            getAlert('msgCannotCharge', 'warning');
            location url="#application.mainURL#/account-settings/payment" addtoken=false;
        } else {
            getAlert(makeBooking.message, 'danger');
            location url="#application.mainURL#/account-settings/modules" addtoken=false;
        }

    }

</cfscript>