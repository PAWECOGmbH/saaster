
<cfscript>

// This file is called by the scheduler

//================== Existing tasks ================
//
//  - Renewing plans
//  - Renewing modules
//  - Delete after cancellation
//  - Downgrade plans on waiting list
//  - Checking open invoices (overdue)
//

setting requesttimeout = 1000;

// Security
param name="url.pass" default="";
if (url.pass eq variables.schedulePassword) {

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
            WHERE

            /* Expired */
            (DATE(dteEndDate) <= DATE(:utcDate) AND (strRecurring = 'monthly' OR strRecurring = 'yearly')) OR

            /* Canceled */
            (DATE(dteEndDate) <= DATE(:utcDate) AND (strStatus = 'canceled')) OR

            /* Waiting for downgrade */
            (DATE(dteStartDate) <= DATE(:utcDate) AND (strStatus = 'waiting'))

            ORDER BY strStatus DESC


        "
    )


    if (qRenewBookings.recordCount) {

        objInvoice = new com.invoices();
        objPrices = new com.prices();
        objBook = new com.book();

        loop query=qRenewBookings {

            // We need to process the waiting plans first (downgrade)
            if (qRenewBookings.strStatus eq "waiting") {

                // DELETE the old plan
                qOldPlan = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        customerID: {type: "numeric", value: qRenewBookings.intCustomerID}
                    },
                    sql = "
                        DELETE FROM bookings
                        WHERE intCustomerID = :customerID
                        AND intPlanID > 0
                        AND strStatus != 'waiting'
                    "
                )

                // Change the waiting plan to active
                updateStruct = structNew();
                updateStruct['bookingID'] = qRenewBookings.intBookingID;
                updateStruct['planID'] = qRenewBookings.intPlanID;
                updateStruct['dateStart'] = qRenewBookings.dteStartDate;
                updateStruct['dateEnd'] = qRenewBookings.dteEndDate;
                updateStruct['recurring'] = qRenewBookings.strRecurring;
                updateStruct['status'] = "active";

                updateBooking = objBook.updateBooking(updateStruct);




            // Renew plans or modules
            } else if ((qRenewBookings.strRecurring eq "monthly" or qRenewBookings.strRecurring eq "yearly") and qRenewBookings.strStatus eq "active") {

                // Get invoice data of the last invoice
                invoiceArray = objInvoice.getInvoices(qRenewBookings.intCustomerID,1,1).arrayInvoices;
                lastInvoice = arrayLast(invoiceArray);
                language = lastInvoice.invoiceLanguage;
                currencyID = objPrices.getCurrency(lastInvoice.invoiceCurrency).id;
                getTime = new com.time(qRenewBookings.intCustomerID);
                if (!len(trim(language))) {
                    language = getDefaultLanguage().iso;
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


                // Process plans
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
                        abort;

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
                        abort;

                    }


                    // Charge the amount now (Payrexx)
                    chargeNow = objInvoice.payInvoice(invoiceID);
                    if (!chargeNow.success) {

                        objInvoice.deleteInvoice(invoiceID);

                        // todo: make log and error mail
                        dump(chargeNow);
                        abort;

                    }


                    // Update booking table
                    updateStruct = structNew();
                    updateStruct['bookingID'] = qRenewBookings.intBookingID;
                    updateStruct['planID'] = qRenewBookings.intPlanID;
                    updateStruct['dateStart'] = startDate;
                    updateStruct['dateEnd'] = endDate;
                    updateStruct['recurring'] = qRenewBookings.strRecurring;
                    updateStruct['status'] = qRenewBookings.strStatus;

                    updateBooking = objBook.updateBooking(updateStruct);



                // Process modules
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
                        abort;

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
                        abort;

                    }


                    // Charge the amount now (Payrexx)
                    chargeNow = objInvoice.payInvoice(invoiceID);
                    if (!chargeNow.success) {

                        objInvoice.deleteInvoice(invoiceID);

                        // todo: make log and error mail
                        dump(chargeNow);
                        abort;

                    }


                    // Update booking table
                    updateStruct = structNew();
                    updateStruct['bookingID'] = qRenewBookings.intBookingID;
                    updateStruct['dateStart'] = startDate;
                    updateStruct['dateEnd'] = endDate;
                    updateStruct['recurring'] = qRenewBookings.strRecurring;
                    updateStruct['status'] = qRenewBookings.strStatus;

                    updateBooking = objBook.updateBooking(updateStruct);


                }



            // Cancel a plan or module
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

        writeOutput('No entries found!');

    }



} else {

    location url="#application.mainURL#" addtoken="false";

}


</cfscript>