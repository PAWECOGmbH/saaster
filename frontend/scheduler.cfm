
<cfscript>

// This file is called by the scheduler

//================== Existing tasks ================
//
//  - Renewing plans
//  - Renewing modules
//  - Delete after cancellation
//  - Checking open invoices (overdue)
//

setting requesttimeout = 1000;


// Security
param name="url.pass" default="";
if (url.pass eq variables.schedulePassword) {

    utcDate = dateFormat(now(), "yyyy-mm-dd");
    objInvoice = new com.invoices();
    objPrices = new com.prices();
    objPayrexx = new com.payrexx();

    qRenewBookings = queryExecute(
        options = {datasource = application.datasource},
        params = {
            utcDate: {type: "date", value: utcDate}
        },
        sql = "
            SELECT *
            FROM customer_bookings
            WHERE (DATE(dteEndDate) <= DATE(:utcDate) OR DATE(dteEndTestDate) <= DATE(:utcDate))
            AND (strRecurring = 'monthly' OR strRecurring = 'yearly' OR strRecurring = 'canceled')
        "
    )

    loop query=qRenewBookings {

        // Renew plans
        if (qRenewBookings.strRecurring eq "monthly" or qRenewBookings.strRecurring eq "yearly") {

            // Get time
            getTime = new com.time(qRenewBookings.intCustomerID);

            // Get customers language and currencyID from last invoice
            invoiceArray = objInvoice.getInvoices(qRenewBookings.intCustomerID,1,1).arrayInvoices;
            lastInvoice = arrayLast(invoiceArray);
            language = lastInvoice.invoiceLanguage;
            currencyID = objPrices.getCurrency(lastInvoice.invoiceCurrency).id;
            if (!len(trim(language))) {
                language = getDefaultLanguage().iso;
            }
            if (!isNumeric(currencyID)) {
                currencyID = 0;
            }

            startDate = qRenewBookings.dteEndDate;
            if (qRenewBookings.strRecurring eq "monthly") {
                endDate = dateAdd("m", 1, startDate);
            } else if (qRenewBookings.strRecurring eq "yearly") {
                endDate = dateAdd("yyyy", 1, startDate);
            }

            // Process plans
            if (qRenewBookings.intPlanID gt 0) {

                objPlans = new com.plans(language=language, currencyID=currencyID);
                planData = objPlans.getPlanDetail(qRenewBookings.intPlanID);


                // Make invoice struct
                invoiceStruct = structNew();
                invoiceStruct['customerBookingID'] = qRenewBookings.intBookingID;
                invoiceStruct['customerID'] = qRenewBookings.intCustomerID;
                invoiceStruct['title'] = getTrans('titRenewal') & " " & planData.planName;
                invoiceStruct['currency'] = lastInvoice.invoiceCurrency;
                invoiceStruct['isNet'] = planData.isNet;
                invoiceStruct['vatType'] = planData.vatType;
                invoiceStruct['paymentStatusID'] = 2;
                invoiceStruct['language'] = language;
                invoiceStruct['invoiceDate'] = getTime.utc2local(utcDate=now());
                invoiceStruct['dueDate'] = getTime.utc2local(utcDate=now());


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
                position[1]['title'] = planData.planName & ' ' & lsDateFormat(getTime.utc2local(utcDate=startDate)) & ' - ' & lsDateFormat(getTime.utc2local(utcDate=endDate)) & ' (' & getTrans('titRenewal') & ')';
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

                    // todo: make log and error mail
                    dump(chargeNow);
                    abort;

                }

                // If we are in dev mode, call the JSON data from the given server
                if (application.environment eq "dev") {
                    include template="/frontend/payrexx_webhook.cfm";
                }

                // Get the webhook data
                getWebhook = objPayrexx.getWebhook(qRenewBookings.intCustomerID, 'confirmed');
                if (!getWebhook.recordCount) {

                    // todo: make log and error mail
                    dump(getWebhook);
                    abort;

                }

                // Insert payment
                payment = structNew();
                payment['invoiceID'] = invoiceID;
                payment['customerID'] = qRenewBookings.intCustomerID;
                payment['date'] = now();
                payment['amount'] = objInvoice.getInvoiceData(invoiceID).total;
                payment['type'] = getWebhook.strPaymentBrand;
                payment['payrexxID'] = getWebhook.intPayrexxID;

                insPayment = objInvoice.insertPayment(payment);

                if (!insPayment.success) {

                    // todo: make log and error mail
                    dump(insPayment);
                    abort;

                }


                // Update booking table
                updateStruct = structNew();
                updateStruct['customerID'] = qRenewBookings.intCustomerID;
                updateStruct['planID'] = qRenewBookings.intPlanID;
                updateStruct['dateStart'] = startDate;
                updateStruct['dateEnd'] = endDate;
                updateStruct['recurring'] = qRenewBookings.strRecurring;
                updateStruct['newPlanID'] = qRenewBookings.intPlanID;

                updateBooking = objPlans.updateCurrentPlan(updateStruct);

                if (!updateBooking.success) {

                    // todo: make log and error mail
                    dump(updateBooking);


                }




            // Process modules
            } else if (qRenewBookings.intModuleID gt 0) {

                objModules = new com.modules(language=language, currencyID=currencyID);
                moduleData = objModules.getModuleData(qRenewBookings.intModuleID);

                // Make invoice struct
                invoiceStruct = structNew();
                invoiceStruct['customerBookingID'] = qRenewBookings.intBookingID;
                invoiceStruct['customerID'] = qRenewBookings.intCustomerID;
                invoiceStruct['title'] = getTrans('titRenewal') & " " & moduleData.name;
                invoiceStruct['currency'] = lastInvoice.invoiceCurrency;
                invoiceStruct['isNet'] = moduleData.isNet;
                invoiceStruct['vatType'] = moduleData.vat_type;
                invoiceStruct['paymentStatusID'] = 2;
                invoiceStruct['language'] = language;
                invoiceStruct['invoiceDate'] = getTime.utc2local(utcDate=now());
                invoiceStruct['dueDate'] = getTime.utc2local(utcDate=now());

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
                position[1]['title'] = moduleData.name & ' ' & lsDateFormat(getTime.utc2local(utcDate=startDate)) & ' - ' & lsDateFormat(getTime.utc2local(utcDate=endDate)) & ' (' & getTrans('titRenewal') & ')';
                position[1]['description'] = moduleData.short_description;
                position[1]['quantity'] = 1;
                position[1]['discountPercent'] = 0;
                position[1]['vat'] = moduleData.vat;
                if (qRenewBookings.strRecurring eq 'monthly') {
                    position[1]['unit'] = getTrans('TitMonth', language);
                    position[1]['price'] = moduleData.price_monthly;
                    priceAfterVAT = moduleData.priceMonthlyAfterVAT;
                } else {
                    position[1]['unit'] = getTrans('TitYear', language);
                    position[1]['price'] = moduleData.price_yearly;
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

                    // todo: make log and error mail
                    dump(chargeNow);
                    abort;

                }

                // If we are in dev mode, call the JSON data from the given server
                if (application.environment eq "dev") {
                    include template="/frontend/payrexx_webhook.cfm";
                }

                // Get the webhook data
                getWebhook = objPayrexx.getWebhook(qRenewBookings.intCustomerID, 'confirmed');
                if (!getWebhook.recordCount) {

                    // todo: make log and error mail
                    dump(getWebhook);
                    abort;

                }

                // Insert payment
                payment = structNew();
                payment['invoiceID'] = invoiceID;
                payment['customerID'] = qRenewBookings.intCustomerID;
                payment['date'] = now();
                payment['amount'] = objInvoice.getInvoiceData(invoiceID).total;
                payment['type'] = getWebhook.strPaymentBrand;
                payment['payrexxID'] = getWebhook.intPayrexxID;

                insPayment = objInvoice.insertPayment(payment);

                if (!insPayment.success) {

                    // todo: make log and error mail
                    dump(insPayment);
                    abort;

                }


                // Update booking table
                updateStruct = structNew();
                updateStruct['customerID'] = qRenewBookings.intCustomerID;
                updateStruct['moduleID'] = qRenewBookings.intModuleID;
                updateStruct['dateStart'] = startDate;
                updateStruct['dateEnd'] = endDate;
                updateStruct['recurring'] = qRenewBookings.strRecurring;
                updateStruct['newPlanID'] = qRenewBookings.intModuleID;

                updateBooking = objModules.updateCurrentModule(updateStruct);

                if (!updateBooking.success) {

                    // todo: make log and error mail
                    dump(updateBooking);


                }



            }


        // Cancel a plan
        } else if (qRenewBookings.strRecurring eq "canceled") {


            if (qRenewBookings.intModuleID gt 0) {

                queryExecute (
                    options = {datasource = application.datasource},
                    params = {
                        customerID: {type: "numeric", value: qRenewBookings.intCustomerID},
                        moduleID: {type: "numeric", value: qRenewBookings.intModuleID},
                        dateStart: {type: "datetime", value: qRenewBookings.dteStartDate},
                        dateEnd: {type: "datetime", value: qRenewBookings.dteEndDate},
                        recurring: {type: "varchar", value: qRenewBookings.strRecurring}
                    },
                    sql = "

                        DELETE FROM customer_bookings
                        WHERE intCustomerID = :customerID
                        AND intModuleID = :moduleID;

                        INSERT INTO customer_bookings_history (intCustomerID, intModuleID, dteStartDate, dteEndDate, strRecurring)
                        VALUES (:customerID, :moduleID, :dateStart, :dateEnd, :recurring)

                    "
                )

            } else if (qRenewBookings.intPlanID gt 0) {

                queryExecute (
                    options = {datasource = application.datasource},
                    params = {
                        customerID: {type: "numeric", value: qRenewBookings.intCustomerID},
                        planID: {type: "numeric", value: qRenewBookings.intPlanID},
                        dateStart: {type: "datetime", value: qRenewBookings.dteStartDate},
                        dateEnd: {type: "datetime", value: qRenewBookings.dteEndDate},
                        recurring: {type: "varchar", value: qRenewBookings.strRecurring}
                    },
                    sql = "

                        DELETE FROM customer_bookings
                        WHERE intCustomerID = :customerID
                        AND intPlanID = :planID

                    "
                )

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



} else {

    location url="#application.mainURL#" addtoken="false";

}


</cfscript>