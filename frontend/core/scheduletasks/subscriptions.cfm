
<cfscript>

// This file is called by the scheduler (recommended: 2h cycle)

//================== Existing tasks ================
//
//  - Downgrade plans on waiting list
//  - Renewing plans
//  - Renewing modules
//  - Delete after cancellation
//  - Set status for expired plans
//  - Check open invoices (overdue)
//  - Delete logfiles older than 30 days
//

setting requesttimeout = 1000;

// Security (password from config.cfm)
param name="url.pass" default="";
if (url.pass eq variables.schedulePassword) {

    objInvoice = new backend.core.com.invoices();
    objPrices = new backend.core.com.prices();
    objCurrency = new backend.core.com.currency();
    objBook = new backend.core.com.book();
    objModules = new backend.core.com.modules();
    objPlans = new backend.core.com.plans();
    objLogs = application.objLog;


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

    loop query=qWaiting {

        // Plans to delete
        qPlans = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: qWaiting.intCustomerID},
                utcDate: {type: "date", value: dateFormat(now(), "yyyy-mm-dd")}
            },
            sql = "
                SELECT intBookingID, intCustomerID, strStatus, intPlanID
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

            // Make log
            objLogs.logWrite("scheduletask", "info", "Plan changed (waiting) and predecessor deleted [PlanID: #qPlans.intPlanID#, CustomerID: #qWaiting.intCustomerID#]");

            // Are there any modules included?
            bookingData = objPlans.getCurrentPlan(qPlans.intCustomerID);
            if (structKeyExists(bookingData, "modulesIncluded")) {
                if (isArray(bookingData.modulesIncluded) and arrayLen(bookingData.modulesIncluded)) {
                    loop array=bookingData.modulesIncluded index="a" {
                        objModules.distributeScheduler(moduleID=a.moduleID, customerID=qWaiting.intCustomerID, status=qPlans.strStatus);
                    }
                }
            }

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
                SELECT intBookingID, intCustomerID, intModuleID
                FROM bookings
                WHERE intCustomerID = :customerID
                AND intModuleID = :moduleID
                AND dteEndDate <= DATE(:utcDate)
            "
        )

        loop query=qModules {

            // Delete booking
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

            // Make log
            objLogs.logWrite("scheduletask", "info", "Module changed (waiting) and predecessor deleted [ModuleID: #qModules.intModuleID#, CustomerID: #qWaiting.intCustomerID#]");

            // Update scheduletasks
            objModules.distributeScheduler(moduleID=qModules.intModuleID, customerID=qWaiting.intCustomerID, status='canceled');

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

        // Make log for plan
        if (qWaiting.intPlanID gt 0) {
            objLogs.logWrite("scheduletask", "info", "Waiting plan activated [PlanID: #qWaiting.intPlanID#, CustomerID: #qWaiting.intCustomerID#]");
        }

        // Make log for module
        if (qWaiting.intModuleID gt 0) {
            objLogs.logWrite("scheduletask", "info", "Waiting module activated [ModuleID: #qWaiting.intModuleID#, CustomerID: #qWaiting.intCustomerID#]");
        }

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

    loop query=qRenewBookings {

        // Renew plans or modules
        if ((qRenewBookings.strRecurring eq "monthly" or qRenewBookings.strRecurring eq "yearly") and
            (qRenewBookings.strStatus eq "active" or
            qRenewBookings.strStatus eq "expired")) {

            // Get invoice data of the last invoice
            invoiceArray = objInvoice.getInvoices(qRenewBookings.intCustomerID).arrayInvoices;
            if (!arrayIsEmpty(invoiceArray)) {
                lastInvoice = arrayLast(invoiceArray);
                language = lastInvoice.invoiceLanguage;
                currencyID = objCurrency.getCurrency(lastInvoice.invoiceCurrency).id;
                currency = lastInvoice.invoiceCurrency;
            } else {
                language = application.objLanguage.getDefaultLanguage().iso;
                currencyID = objCurrency.getCurrency().id;
                currency = objCurrency.getCurrency().iso;
            }
            getTime = new backend.core.com.time(qRenewBookings.intCustomerID);
            startDate = dateFormat(now(), "yyyy-mm-dd");
            if (qRenewBookings.strRecurring eq "monthly") {
                endDate = dateFormat(dateAdd("m", 1, startDate), "yyyy-mm-dd");
            } else if (qRenewBookings.strRecurring eq "yearly") {
                endDate = dateFormat(dateAdd("yyyy", 1, startDate), "yyyy-mm-dd");
            }


            // Processing plans ################################################
            if (qRenewBookings.intPlanID gt 0) {

                objPlans = new backend.core.com.plans(language=language, currencyID=currencyID);
                planData = objPlans.getPlanDetail(qRenewBookings.intPlanID);

                // Make invoice struct
                invoiceStruct = structNew();
                invoiceStruct['bookingID'] = qRenewBookings.intBookingID;
                invoiceStruct['customerID'] = qRenewBookings.intCustomerID;
                invoiceStruct['title'] = getTrans('titRenewal', language) & " " & planData.planName;
                invoiceStruct['currency'] = currency;
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

                    // Make log
                    objLogs.logWrite("scheduletask", "info", "Invoice for plan renewal created [InvoiceID: #invoiceID#, Title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#]");

                } else {

                    // Make log and send error mail
                    objLogs.logWrite("scheduletask", "error", "Could not create invoice [Title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#], Error message: #newInvoice.message#", true);
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

                if (insPositions.success) {

                    // Make log
                    objLogs.logWrite("scheduletask", "info", "Position for plan invoice created [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#]");

                } else {

                    objInvoice.deleteInvoice(invoiceID);

                    // Make log and send error mail
                    objLogs.logWrite("scheduletask", "error", "Could not insert the invoice position for plans: invoice deleted [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#], Error message: #insPositions.message#", true);
                    break;

                }


                // Try to charge the amount now (Payrexx)
                chargeNow = objInvoice.payInvoice(invoiceID);

                // If not successful
                if (!chargeNow.success) {

                    // Make log and send error mail
                    objLogs.logWrite("scheduletask", "error", "Could not charge via Payrexx, trying to send the invoice by email [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#], Error message: #chargeNow.message#", true);

                    // Notify the customer (account notification)
                    notiStruct = {};
                    notiStruct['customerID'] = qRenewBookings.intCustomerID;
                    notiStruct['userID'] = 0;
                    notiStruct['title_var'] = "titCouldNotCharge";
                    notiStruct['descr_var'] = "msgCouldNotCharge";
                    notiStruct['link'] = application.mainURL & "/account-settings/invoice/" & invoiceID;
                    notiStruct['linktext_var'] = "txtPayInvoice";
                    application.objNotifications.insertNotification(notiStruct);

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

                        // Make log and send error mail
                        objLogs.logWrite("scheduletask", "error", "Could not send the invoice by email [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#], Error message: #sendInvoice.message#", true);

                    } else {

                        // Make log
                        objLogs.logWrite("scheduletask", "info", "Invoice successfully sent by email [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#]");

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

                    // Send receipt by email
                    sendInvoice = objInvoice.sendInvoice(invoiceID);
                    if (!sendInvoice.success) {

                        // Make log and send error mail
                        objLogs.logWrite("scheduletask", "error", "Could not send the receipt by email [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#], Error message: #sendInvoice.message#", true);

                    } else {

                        // Make log
                        objLogs.logWrite("scheduletask", "info", "Receipt successfully sent by email [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#]");

                    }

                }




            // Processing modules ################################################
            } else if (qRenewBookings.intModuleID gt 0) {

                objModuless = new backend.core.com.modules(language=language, currencyID=currencyID);
                moduleData = objModuless.getModuleData(qRenewBookings.intModuleID);

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

                    // Make log
                    objLogs.logWrite("scheduletask", "info", "Invoice for module renewal created [InvoiceID: #invoiceID#, Title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#]");

                } else {

                    // Make log and send error mail
                    objLogs.logWrite("scheduletask", "error", "Could not create invoice [Title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#], Error message: #newInvoice.message#", true);
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

                if (insPositions.success) {

                    // Make log
                    objLogs.logWrite("scheduletask", "info", "Position for module invoice created [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#]");

                } else {

                    objInvoice.deleteInvoice(invoiceID);

                    // Make log and send error mail
                    objLogs.logWrite("scheduletask", "error", "Could not insert the invoice position for modules: invoice deleted [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#], Error message: #insPositions.message#", true);
                    break;

                }


                // Try to charge the amount now (Payrexx)
                chargeNow = objInvoice.payInvoice(invoiceID);

                if (!chargeNow.success) {

                    // Make log and send error mail
                    objLogs.logWrite("scheduletask", "error", "Could not charge via Payrexx, trying to send the invoice by email [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#], Error message: #chargeNow.message#", true);

                    // Notify the customer (account notification)
                    notiStruct = {};
                    notiStruct['customerID'] = qRenewBookings.intCustomerID;
                    notiStruct['userID'] = 0;
                    notiStruct['title_var'] = "titCouldNotCharge";
                    notiStruct['descr_var'] = "msgCouldNotCharge";
                    notiStruct['link'] = application.mainURL & "/account-settings/invoice/" & invoiceID;
                    notiStruct['linktext_var'] = "txtPayInvoice";
                    application.objNotifications.insertNotification(notiStruct);

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

                        // Make log and send error mail
                        objLogs.logWrite("scheduletask", "error", "Could not send the invoice by email [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#], Error message: #sendInvoice.message#", true);

                    } else {

                        // Make log
                        objLogs.logWrite("scheduletask", "info", "Payment successfully completed [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#]");

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

                    // Update scheduletasks
                    objModules.distributeScheduler(moduleID=qRenewBookings.intModuleID, customerID=qRenewBookings.intCustomerID, status=qRenewBookings.strStatus);

                    // Send receipt by email
                    sendInvoice = objInvoice.sendInvoice(invoiceID);
                    if (!sendInvoice.success) {

                        // Make log and send error mail
                        objLogs.logWrite("scheduletask", "error", "Could not send the receipt by email [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#], Error message: #sendInvoice.message#", true);

                    } else {

                        // Make log
                        objLogs.logWrite("scheduletask", "info", "The receipt was sent by email successfully [InvoiceID: #invoiceID#, Invoice title: #invoiceStruct['title']#, CustomerID: #qRenewBookings.intCustomerID#]");

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

            // Make log
            objLogs.logWrite("scheduletask", "info", "A plan or module has been deleted after cancellation [CustomerID: #qRenewBookings.intCustomerID#]");

            // Update scheduletasks
            if (qRenewBookings.intModuleID gt 0) {
                objModules.distributeScheduler(moduleID=qRenewBookings.intModuleID, customerID=qRenewBookings.intCustomerID, status='canceled');
            } else if (qRenewBookings.intPlanID gt 0) {
                // Are there any modules included?
                bookingData = objPlans.getCurrentPlan(qRenewBookings.intCustomerID);
                if (structKeyExists(bookingData, "modulesIncluded")) {
                    if (isArray(bookingData.modulesIncluded) and arrayLen(bookingData.modulesIncluded)) {
                        loop array=bookingData.modulesIncluded index="a" {
                            objModules.distributeScheduler(moduleID=a.moduleID, customerID=qRenewBookings.intCustomerID, status='canceled');
                        }
                    }
                }
            }


        // Set expired plans or modules to "expired"
        } else if (dateFormat(qRenewBookings.dteEndDate, "yyyy-mm-dd") lt dateFormat(now(), "yyyy-mm-dd")) {

            // Update booking table
            updateStruct = structNew();
            updateStruct['bookingID'] = qRenewBookings.intBookingID;
            updateStruct['status'] = "expired";

            updateBooking = objBook.updateBooking(updateStruct);

            // Make log
            objLogs.logWrite("scheduletask", "info", "A plan or module has been set to expired [BookingID: CustomerID: #qRenewBookings.intBookingID#, #qRenewBookings.intCustomerID#]");

            // Update scheduletasks
            if (qRenewBookings.intModuleID gt 0) {
                objModules.distributeScheduler(moduleID=qRenewBookings.intModuleID, customerID=qRenewBookings.intCustomerID, status='expired');
            }

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


    // Delete logfiles older than 30 days or empty folders
    objLogs.deleteOldLogfiles();



} else {

    // Make log
    application.objLog.logWrite("scheduletask", "warning", "Someone tried to call the scheduler (subscriptions.cfm) manually with wrong password. Passwort was: #url.pass#");

    location url="#application.mainURL#" addtoken="false";

}


</cfscript>