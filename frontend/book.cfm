<cfscript>

    // This file is used in order to book plans or modules.
    // It handles the call to the payment service provider as well as the response.
    // The call only works with the corresponding JSON string that is Base64 formatted (url.plan).

    objPlans = new com.plans();
    objBook = new com.book();
    objInvoice = new com.invoices();

    thisPaymentType = "Credit card";

    if (!structKeyExists(url, "plan")) {
        location url="#application.mainURL#/plans" addtoken=false;
    }

    // The user must already be logged in
    if (!structKeyExists(session, "customer_id")) {
        location url="#application.mainURL#/login" addtoken=false;
    }

    failed = false;

    // decoding base64 value
    planStruct = objBook.decryptBookingLink(url.plan);


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
    if (!structKeyExists(planStruct, "plan")) {
        failed = true;
    }

    if (failed) {
        getAlert('alertErrorOccured', 'danger');
        location url="#application.mainURL#/plans" addtoken="false";
    }

    // As we have all the infos, save it into variables
    variables.planID = planStruct.planID;
    variables.lngID = planStruct.lngID;
    variables.currencyID = planStruct.currencyID;
    variables.plan = planStruct.plan;

    // and getting more plan infos
    lngIso = getAnyLanguage(variables.lngID).iso;
    planDetails = objPlans.getPlanDetail(variables.planID, lngIso, variables.currencyID);


    // Check customers current plan (if exists)
    currentPlan = objPlans.getCurrentPlan(session.customer_id, session.lng);

    // Is it a free plan?
    if (planDetails.itsFree) {

        // Book the free plan

        insertBooking = objBook.makeBooking(customerID=session.customer_id, planData=planDetails, itsTest=false, plan=variables.plan);

        if (insertBooking.success) {

            <!--- Save the new plan into a session --->
            newPlan = objPlans.getCurrentPlan(session.customer_id, session.lng);
            session.currentPlan = newPlan;
            location url="#application.mainURL#/dashboard" addtoken=false;

        }

    }




    // Is there already a plan?
    if (structKeyExists(currentPlan, "planID") and currentPlan.planID gt 0) {

        // If its the same plan, send to the dashboard
        if (currentPlan.planID eq planDetails.planID) {

            location url="#application.mainURL#/dashboard" addtoken=false;

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
                FROM customer_plans
                WHERE intCustomerID = :customerID
                AND intPlanID = :planID
                AND LENGTH(dtmEndTestDate) > 0
            "
        )

        if (!qTestedPlans.recordCount) {

            // Book the plan and let the customer test
            insertBooking = objBook.makeBooking(customerID=session.customer_id, planData=planDetails, itsTest=true, plan=variables.plan);

            if (insertBooking.success) {

                <!--- Save the new plan into a session --->
                newPlan = objPlans.getCurrentPlan(session.customer_id, session.lng);
                session.currentPlan = newPlan;
                location url="#application.mainURL#/dashboard" addtoken=false;

            }

        }

    }



    // Is the call coming from payment service provider (PSP)?
    // Please make sure you provide the url variables "psp_response" and "message" with the corresponding values
    // Response values for "psp_response" can be: succcess, failed or cancel (required)
    // Response values for "message" you can use for any messages (optional)
    if (structKeyExists(url, "psp_response")) {

        thisResponse = url.psp_response;
        param name="url.message" default="";
        if (len(trim(url.message))) {
            thisMessage = url.message;
        } else {
           thisMessage = "";
        }

        switch (thisResponse) {

            case "success":

                // Make a book for the plan
                insertBooking = objBook.makeBooking(customerID=session.customer_id, planData=planDetails, itsTest=false, plan=variables.plan);

                if (insertBooking.success) {

                    <!--- Save the new plan into a session --->
                    newPlan = objPlans.getCurrentPlan(session.customer_id, session.lng);

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
                        getAlert(insertBooking.message, 'danger');
                        location url="#application.mainURL#/dashboard" addtoken=false;
                    }

                    // Insert a position
                    posInfo = structNew();
                    posInfo['invoiceID'] = invoiceID;
                    posInfo['append'] = false;

                    positionArray = arrayNew(1);

                    position = structNew();
                    position[1]['title'] = planDetails.planName & ' ' & lsDateFormat(newPlan.startDate) & ' - ' & lsDateFormat(newPlan.endDate);
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
                        location url="#application.mainURL#/dashboard" addtoken=false;
                    }

                    // Insert payment
                    payment = structNew();
                    payment['invoiceID'] = invoiceID;
                    payment['date'] = now();
                    payment['amount'] = priceAfterVAT;
                    payment['type'] = thisPaymentType;

                    insPayment = objInvoice.insertPayment(payment);

                    if (!insPayment.success) {
                        objInvoice.deleteInvoice(invoiceID);
                        getAlert(insPositions.message, 'danger');
                    } else {
                        // If everything went well, save plan into the session
                        session.currentPlan = newPlan;
                    }

                    location url="#application.mainURL#/dashboard" addtoken=false;




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


<!--- Include the payment services --->
<cfinclude template="payment.cfm">