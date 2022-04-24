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





    } else {



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

    }



    // Do we have to provide any test days?
    if (isNumeric(planDetails.testDays) and planDetails.testDays gt 0) {

        // The customer only gets test days if he has not already had any.
        getsTestDays = true;

        if (isDate(currentPlan.endTestDate) and currentPlan.planID gt 0) {
            getsTestDays = false;
        }

        if (getsTestDays) {

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
                    local.invoiceStruct = structNew();
                    local.invoiceStruct['customerID'] = session.customer_id;
                    local.invoiceStruct['title'] = planDetails.planName;
                    local.invoiceStruct['invoiceDate'] = now();
                    local.invoiceStruct['currency'] = planDetails.currency;
                    local.invoiceStruct['isNet'] = planDetails.isNet;
                    local.invoiceStruct['vatType'] = planDetails.vatType;
                    local.invoiceStruct['paymentStatusID'] = 2;

                    // Make invoice and get invoice id
                    local.newInvoice = objInvoice.createInvoice(local.invoiceStruct);
                    if (local.newInvoice.success) {
                        local.invoiceID = local.newInvoice.newInvoiceID;
                    } else {
                        getAlert(insertBooking.message, 'danger');
                        location url="#application.mainURL#/dashboard" addtoken=false;
                    }

                    // Insert a position
                    local.posInfo = structNew();
                    local.posInfo['invoiceID'] = local.invoiceID;
                    local.posInfo['append'] = false;

                    local.positionArray = arrayNew(1);

                    local.position = structNew();
                    local.position[1]['title'] = planDetails.planName & ' ' & lsDateFormat(newPlan.startDate) & ' - ' & lsDateFormat(newPlan.endDate);
                    local.position[1]['description'] = planDetails.shortDescription;
                    local.position[1]['quantity'] = 1;
                    local.position[1]['discountPercent'] = 0;
                    local.position[1]['vat'] = planDetails.vat;
                    if (newPlan.recurring eq 'monthly') {
                        local.position[1]['unit'] = getTrans('TitMonth', session.lng);
                        local.thisPrice = planDetails.priceMonthly;
                        local.position[1]['price'] = local.thisPrice;
                    } else {
                        local.position[1]['unit'] = getTrans('TitYear', session.lng);
                        local.thisPrice = planDetails.priceYearly;
                        local.position[1]['price'] = local.thisPrice;
                    }
                    arrayAppend(local.positionArray, local.position[1]);
                    local.posInfo['positions'] = local.positionArray;

                    local.insPositions = objInvoice.insertInvoicePositions(local.posInfo);

                    if (!local.insPositions.success) {
                        objInvoice.deleteInvoice(local.invoiceID);
                        getAlert(insPositions.message, 'danger');
                        location url="#application.mainURL#/dashboard" addtoken=false;
                    }

                    // Insert payment
                    local.payment = structNew();
                    local.payment['invoiceID'] = local.invoiceID;
                    local.payment['date'] = now();
                    local.payment['amount'] = local.thisPrice;
                    local.payment['type'] = thisPaymentType;

                    local.insPayment = objInvoice.insertPayment(local.payment);

                    if (!local.insPayment.success) {
                        objInvoice.deleteInvoice(local.invoiceID);
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