
<cfscript>

// This file is called by the scheduler (recommended: 4h cycle)

//================== Existing tasks ================
//
//  - Downgrade plans on waiting list
//  - Renewing plans
//  - Renewing modules
//  - Delete after cancellation
//  - Set status for expired plans
//  - Check open invoices (overdue)
//

setting requesttimeout = 1000;

// Security (password from config.cfm)
param name="url.pass" default="";
if (url.pass eq variables.schedulePassword) {

    objInvoice = new com.invoices();
    objPrices = new com.prices();
    objBook = new com.book();


    // First round: look for "waiting" plans or modules
    // ################################################

    qWaiting = queryExecute(
        options = {datasource = application.datasource},
        params = {
            utcDate: {type: "date", value: dateFormat(now(), "yyyy-mm-dd")}
        },
        sql = "
            SELECT  intBookingID, intCustomerID, intPlanID, intModuleID, strRecurring, strStatus,
                    DATE_FORMAT(dteStartDate, '%Y-%m-%e') as dteStartDate,
                    DATE_FORMAT(dteEndDate, '%Y-%m-%e') as dteEndDate
            FROM bookings
            WHERE (DATE(dteStartDate) <= DATE(:utcDate) AND (strStatus = 'waiting'))
        "
    )


    dump(qWaiting);
    //abort;

    loop query=qWaiting {

        // Plans to delete
        qPlans = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: qWaiting.intCustomerID},
                utcDate: {type: "date", value: dateFormat(now(), "yyyy-mm-dd")}
            },
            sql = "
                SELECT intBookingID
                FROM bookings
                WHERE intCustomerID = :customerID
                AND intPlanID > 0
                AND dteEndDate <= DATE(:utcDate)
            "
        )
        loop query=qPlans {
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    bookingID: {type: "numeric", value: qPlans.intBookingID}
                },
                sql = "
                    DELETE FROM bookings
                    WHERE intBookingID = :bookingID
                "
            )
        }

        // Modules to delete
        qModules = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: qWaiting.intCustomerID},
                moduleID: {type: "numeric", value: qWaiting.intModuleID},
                utcDate: {type: "date", value: dateFormat(now(), "yyyy-mm-dd")}
            },
            sql = "
                SELECT intBookingID
                FROM bookings
                WHERE intCustomerID = :customerID
                AND intModuleID = :moduleID
                AND dteEndDate <= DATE(:utcDate)
            "
        )
        loop query=qModules {
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    bookingID: {type: "numeric", value: qModules.intBookingID}
                },
                sql = "
                    DELETE FROM bookings
                    WHERE intBookingID = :bookingID
                "
            )
        }



        // Change the waiting product to 'active'
        updateStruct = structNew();
        updateStruct['bookingID'] = qWaiting.intBookingID;
        updateStruct['planID'] = qWaiting.intPlanID;
        updateStruct['moduleID'] = qWaiting.intModuleID;
        updateStruct['dateStart'] = qWaiting.dteStartDate;
        updateStruct['dateEnd'] = qWaiting.dteEndDate;
        updateStruct['recurring'] = qWaiting.strRecurring;
        updateStruct['status'] = "active";

        updateBooking = objBook.updateBooking(updateStruct);


    }



    // Second round: expired plans and modules
    // ########################################

    qRenewBookings = queryExecute(
        options = {datasource = application.datasource},
        params = {
            utcDate: {type: "date", value: dateFormat(now(), "yyyy-mm-dd")}
        },
        sql = "

            SELECT  intBookingID, intCustomerID, intPlanID, intModuleID, strRecurring, strStatus,
                    DATE_FORMAT(dteStartDate, '%Y-%m-%e') as dteStartDate,
                    DATE_FORMAT(dteEndDate, '%Y-%m-%e') as dteEndDate
            FROM bookings
            WHERE DATE(dteEndDate) < DATE(:utcDate)
            AND strStatus != 'payment'

        "
    )

    dump(qRenewBookings);
    //abort;


    loop query=qRenewBookings {

        // Renew plans or modules
        if ((qRenewBookings.strRecurring eq "monthly" or qRenewBookings.strRecurring eq "yearly") and
            (qRenewBookings.strStatus eq "active" or
            qRenewBookings.strStatus eq "expired")) {

            // Get invoice data of the last invoice
            invoiceArray = objInvoice.getInvoices(qRenewBookings.intCustomerID).arrayInvoices;
            lastInvoice = arrayLast(invoiceArray);
            language = lastInvoice.invoiceLanguage;
            currencyID = objPrices.getCurrency(lastInvoice.invoiceCurrency).id;
            getTime = new com.time(qRenewBookings.intCustomerID);
            if (!len(trim(language))) {
                language = application.objGlobal.getDefaultLanguage().iso;
            }
            if (!isNumeric(currencyID)) {
                currencyID = objPrices.getCurrency().id;
            }
            startDate = dateFormat(now(), "yyyy-mm-dd");
            if (qRenewBookings.strRecurring eq "monthly") {
                endDate = dateFormat(dateAdd("m", 1, startDate), "yyyy-mm-dd");
            } else if (qRenewBookings.strRecurring eq "yearly") {
                endDate = dateFormat(dateAdd("yyyy", 1, startDate), "yyyy-mm-dd");
            }


            // Processing plans ################################################
            if (qRenewBookings.intPlanID gt 0) {

                objPlans = new com.plans(language=language, currencyID=currencyID);
                planData = objPlans.getPlanDetail(qRenewBookings.intPlanID);

                // Make invoice struct
                invoiceStruct = structNew();
                invoiceStruct['bookingID'] = qRenewBookings.intBookingID;
                invoiceStruct['customerID'] = qRenewBookings.intCustomerID;
                invoiceStruct['title'] = getTrans('titRenewal', language) & " " & planData.planName;
                invoiceStruct['currency'] = lastInvoice.invoiceCurrency;
                invoiceStruct['isNet'] = planData.isNet;
                invoiceStruct['vatType'] = planData.vatType;
                invoiceStruct['paymentStatusID'] = 2;
                invoiceStruct['language'] = language;
                invoiceStruct['invoiceDate'] = now();
                invoiceStruct['dueDate'] = now();

                // Make invoice and get invoice id
                newInvoice = objInvoice.createInvoice(invoiceStruct);

                if (newInvoice.success) {
                    invoiceID = newInvoice.newInvoiceID;
                } else {

                    // todo: make log and error mail
                    dump(newInvoice);
                    break;

                }

                // Insert a position
                posInfo = structNew();
                posInfo['invoiceID'] = invoiceID;
                posInfo['append'] = false;

                positionArray = arrayNew(1);

                position = structNew();
                position[1]['title'] = planData.planName & ' ' & lsDateFormat(getTime.utc2local(utcDate=startDate)) & ' - ' & lsDateFormat(getTime.utc2local(utcDate=endDate)) & ' (' & getTrans('titRenewal', language) & ')';
                position[1]['description'] = planData.shortDescription;
                position[1]['quantity'] = 1;
                position[1]['discountPercent'] = 0;
                position[1]['vat'] = planData.vat;
                if (qRenewBookings.strRecurring eq 'monthly') {
                    position[1]['unit'] = getTrans('TitMonth', language);
                    position[1]['price'] = planData.priceMonthly;
                    priceAfterVAT = planData.priceMonthlyAfterVAT;
                } else {
                    position[1]['unit'] = getTrans('TitYear', language);
                    position[1]['price'] = planData.priceYearly;
                    priceAfterVAT = planData.priceYearlyAfterVAT;
                }
                arrayAppend(positionArray, position[1]);
                posInfo['positions'] = positionArray;

                insPositions = objInvoice.insertInvoicePositions(posInfo);

                if (!insPositions.success) {

                    objInvoice.deleteInvoice(invoiceID);

                    // todo: make log and error mail
                    dump(insPositions);
                    break;

                }


                // Try to charge the amount now (Payrexx)
                chargeNow = objInvoice.payInvoice(invoiceID);

                if (!chargeNow.success) {

                    // todo: make log, mail and notification

                    // Change the status to 'payment'
                    updateStruct = structNew();
                    updateStruct['bookingID'] = qRenewBookings.intBookingID;
                    updateStruct['planID'] = qRenewBookings.intPlanID;
                    updateStruct['dateStart'] = startDate;
                    updateStruct['dateEnd'] = endDate;
                    updateStruct['recurring'] = qRenewBookings.strRecurring;
                    updateStruct['status'] = "payment";

                    updateBooking = objBook.updateBooking(updateStruct);

                    // Send invoice by email
                    sendInvoice = objInvoice.sendPaymentRequest(invoiceID);
                    if (!sendInvoice.success) {

                        // todo: make log and error mail
                        dump(sendInvoice);
                        break;

                    }


                } else {

                    // Update booking table
                    updateStruct = structNew();
                    updateStruct['bookingID'] = qRenewBookings.intBookingID;
                    updateStruct['planID'] = qRenewBookings.intPlanID;
                    updateStruct['dateStart'] = startDate;
                    updateStruct['dateEnd'] = endDate;
                    updateStruct['recurring'] = qRenewBookings.strRecurring;
                    updateStruct['status'] = qRenewBookings.strStatus;

                    updateBooking = objBook.updateBooking(updateStruct);

                    // Send invoice by email
                    sendInvoice = objInvoice.sendInvoice(invoiceID);
                    if (!sendInvoice.success) {

                        // todo: make log and error mail
                        dump(sendInvoice);
                        break;

                    }

                }




            // Processing modules ################################################
            } else if (qRenewBookings.intModuleID gt 0) {

                objModules = new com.modules(language=language, currencyID=currencyID);
                moduleData = objModules.getModuleData(qRenewBookings.intModuleID);

                // Make invoice struct
                invoiceStruct = structNew();
                invoiceStruct['bookingID'] = qRenewBookings.intBookingID;
                invoiceStruct['customerID'] = qRenewBookings.intCustomerID;
                invoiceStruct['title'] = getTrans('titRenewal') & " " & moduleData.name;
                invoiceStruct['currency'] = lastInvoice.invoiceCurrency;
                invoiceStruct['isNet'] = moduleData.isNet;
                invoiceStruct['vatType'] = moduleData.vatType;
                invoiceStruct['paymentStatusID'] = 2;
                invoiceStruct['language'] = language;
                invoiceStruct['invoiceDate'] = now();
                invoiceStruct['dueDate'] = now();

                // Make invoice and get invoice id
                newInvoice = objInvoice.createInvoice(invoiceStruct);

                if (newInvoice.success) {
                    invoiceID = newInvoice.newInvoiceID;
                } else {

                    // todo: make log and error mail
                    dump(newInvoice);
                    break;

                }

                // Insert a position
                posInfo = structNew();
                posInfo['invoiceID'] = invoiceID;
                posInfo['append'] = false;

                positionArray = arrayNew(1);

                position = structNew();
                position[1]['title'] = moduleData.name & ' ' & lsDateFormat(getTime.utc2local(utcDate=startDate)) & ' - ' & lsDateFormat(getTime.utc2local(utcDate=endDate)) & ' (' & getTrans('titRenewal', language) & ')';
                position[1]['description'] = moduleData.shortdescription;
                position[1]['quantity'] = 1;
                position[1]['discountPercent'] = 0;
                position[1]['vat'] = moduleData.vat;
                if (qRenewBookings.strRecurring eq 'monthly') {
                    position[1]['unit'] = getTrans('TitMonth', language);
                    position[1]['price'] = moduleData.priceMonthly;
                    priceAfterVAT = moduleData.priceMonthlyAfterVAT;
                } else {
                    position[1]['unit'] = getTrans('TitYear', language);
                    position[1]['price'] = moduleData.priceYearly;
                    priceAfterVAT = moduleData.priceYearlyAfterVAT;
                }
                arrayAppend(positionArray, position[1]);
                posInfo['positions'] = positionArray;

                insPositions = objInvoice.insertInvoicePositions(posInfo);

                if (!insPositions.success) {

                    objInvoice.deleteInvoice(invoiceID);

                    // todo: make log and error mail
                    dump(insPositions);
                    break;

                }


                // Try to charge the amount now (Payrexx)
                chargeNow = objInvoice.payInvoice(invoiceID);

                if (!chargeNow.success) {

                    objInvoice.deleteInvoice(invoiceID);

                    // todo: make log, mail and notification

                    // Change the status to 'payment'
                    updateStruct = structNew();
                    updateStruct['bookingID'] = qRenewBookings.intBookingID;
                    updateStruct['dateStart'] = startDate;
                    updateStruct['dateEnd'] = endDate;
                    updateStruct['recurring'] = qRenewBookings.strRecurring;
                    updateStruct['status'] = "payment";

                    updateBooking = objBook.updateBooking(updateStruct);

                    // Send invoice by email
                    sendInvoice = objInvoice.sendPaymentRequest(invoiceID);
                    if (!sendInvoice.success) {

                        // todo: make log and error mail
                        dump(sendInvoice);
                        break;

                    }


                } else {


                    // Update booking table
                    updateStruct = structNew();
                    updateStruct['bookingID'] = qRenewBookings.intBookingID;
                    updateStruct['dateStart'] = startDate;
                    updateStruct['dateEnd'] = endDate;
                    updateStruct['recurring'] = qRenewBookings.strRecurring;
                    updateStruct['status'] = qRenewBookings.strStatus;

                    updateBooking = objBook.updateBooking(updateStruct);

                    // Send invoice by email
                    sendInvoice = objInvoice.sendInvoice(invoiceID);
                    if (!sendInvoice.success) {

                        // todo: make log and error mail
                        dump(sendInvoice);
                        break;

                    }

                }


            }



        // Delete a plan or module that has been canceled
        } else if (qRenewBookings.strStatus eq "canceled") {

            queryExecute (
                options = {datasource = application.datasource},
                params = {
                    bookingID: {type: "numeric", value: qRenewBookings.intBookingID}
                },
                sql = "
                    DELETE FROM bookings
                    WHERE intBookingID = :bookingID
                    AND strStatus = 'canceled'
                "
            )



        // Set expired plans or modules to "expired"
        } else if (dateFormat(qRenewBookings.dteEndDate, "yyyy-mm-dd") lt dateFormat(now(), "yyyy-mm-dd")) {

            // Update booking table
            updateStruct = structNew();
            updateStruct['bookingID'] = qRenewBookings.intBookingID;
            updateStruct['status'] = "expired";

            updateBooking = objBook.updateBooking(updateStruct);

        }

    }


    // Check open invoices and change status
    queryExecute (
        options = {datasource = application.datasource},
        params = {
            dateToday: {type: "datetime", value: now()}
        },
        sql = "
            UPDATE invoices
            SET intPaymentStatusID = 6
            WHERE intPaymentStatusID = 2
            AND DATE(:dateToday) < DATE(:dateToday)
        "
    )



} else {

    location url="#application.mainURL#" addtoken="false";

}


</cfscript>