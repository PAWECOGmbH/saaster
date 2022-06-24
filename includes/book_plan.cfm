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

    // As we have all the infos, save it into variables
    variables.planID = planStruct.planID;
    variables.lngID = planStruct.lngID;
    variables.currencyID = planStruct.currencyID;
    variables.recurring = planStruct.recurring;

    // Get more plan infos
    planDetails = objPlans.getPlanDetail(variables.planID);

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
            location url="#application.mainURL#/account-settings" addtoken=false;

        }

    }

    // Check customers current plan (if exists)
    currentPlan = objPlans.getCurrentPlan(session.customer_id);

    // Is there already a plan?
    if (structKeyExists(currentPlan, "planID") and currentPlan.planID gt 0) {

        // Is it the same plan?
        if (currentPlan.planID eq planDetails.planID) {

            // If the plan has been expired, renew
            if (currentPlan.status eq "expired") {

                // Do nothing and let the customer book... down to the next step

            } else {

                // Back to dashboard
                getAlert('msgPlanActivated');
                location url="#application.mainURL#/account-settings" addtoken=false;

            }


        } else {

            // The customer wants to make an up- or downgrade
            // Todo: recalculate the fee

            // .... then go down to the next step

        }




    }




    // Do we have to provide any test days?
    if (isNumeric(planDetails.testDays) and planDetails.testDays gt 0) {

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
                AND LENGTH(dtmEndTestDate) > 0
            "
        )

        if (!qTestedPlans.recordCount) {

            // Book the plan and let the customer test
            insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=planDetails, itsTest=true, recurring=variables.recurring);

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


    // Is the call coming from payment service provider (PSP)?
    if (structKeyExists(url, "psp_response")) {

        thisResponse = url.psp_response;
        thisUUID = url.uuid;

        switch (thisResponse) {

            case "success":

                // Get the webhook data
                objPayrexx = new com.payrexx();

                // If we are in dev mode, get the JSON data from ftp server
                if (application.environment eq "dev") {
                    include template="/frontend/payrexx_webhook.cfm";
                }

                // Let's have a look if there is an entry of the webhook. If not, we loop a coulpe of times
                loop from="1" to="10" index="i" {
                    sleep(1000);
                    getWebhook = objPayrexx.getWebhook(session.customer_id, thisUUID, 'confirmed');
                    if (getWebhook.recordCount) {
                        break;
                    }
                }

                thisPaymentType = getWebhook.recordCount ? getWebhook.strPaymentBrand : "Online payment";
                payrexxID = getWebhook.recordCount ? getWebhook.intPayrexxID : 0;

                // Make a book for the plan
                insertBooking = objBook.makeBooking(customerID=session.customer_id, bookingData=planDetails, itsTest=false, recurring=variables.recurring);

                if (insertBooking.success) {

                    <!--- Save the new plan into a variable --->
                    newPlan = objPlans.getCurrentPlan(session.customer_id);
                    getTime = application.getTime;

                    // Make invoice struct
                    invoiceStruct = structNew();
                    invoiceStruct['customerID'] = session.customer_id;
                    invoiceStruct['title'] = planDetails.planName;
                    invoiceStruct['invoiceDate'] = now();
                    invoiceStruct['dueDate'] = now();
                    invoiceStruct['currency'] = planDetails.currency;
                    invoiceStruct['isNet'] = planDetails.isNet;
                    invoiceStruct['vatType'] = planDetails.vatType;
                    invoiceStruct['paymentStatusID'] = 2;

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
                        objInvoice.deleteInvoice(invoiceID);
                        getAlert(insPayment.message, 'danger');
                    } else {
                        // If everything went well, save plan into the session
                        getAlert('msgThanksForPurchaseFindInvoice');
                        session.currentPlan = newPlan;
                        <!--- Save the included modules into the module session --->
                        checkModules = new com.modules(language=getAnyLanguage(variables.lngID).iso).getBookedModules(session.customer_id);
                        session.currentModules = checkModules;
                    }

                    location url="#application.mainURL#/account-settings" addtoken=false;



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

<!--- <cfoutput>
<a href="#application.mainURL#/book?plan=#url.plan#&psp_response=success">OK, done!</a>
</cfoutput> --->