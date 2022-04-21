<cfscript>

    objPlans = new com.plans();
    objBook = new com.book();


    // This file is used in order to book plans or modules.
    // It handles the call to the payment service provider as well as the response.
    // The call only works with the corresponding JSON string that is Base64 formatted (url.plan).

    if (!structKeyExists(url, "plan")) {
        location url="#application.mainURL#/plans" addtoken=false;
    }

    // The user must already be logged in
    if (!structKeyExists(session, "customer_id")) {
        location url="#application.mainURL#/login" addtoken=false;
    }

    failed = false;

    // decoding base64 value
    changeToString = toString(toBinary(url.plan));
    planStruct = deserializeJSON(URLDecode(changeToString));

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

    // As we have all the infos, save it into variables
    variables.planID = planStruct.planID;
    variables.lngID = planStruct.lngID;
    variables.currencyID = planStruct.currencyID;

    // and getting more plan infos
    lngIso = getAnyLanguage(variables.lngID).iso;
    planDetails = objPlans.getPlanDetail(variables.planID, lngIso, variables.currencyID);

    // Check customers current plan (if exists)
    currentPlan = objPlans.getCurrentPlan(session.customer_id);

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

            insertBooking = objBook.makeBooking(customerID=session.customer_id, planData=planDetails, itsTest=false, yearly=false);

            if (insertBooking.success) {

                <!--- Save the new plan into a session --->
                newPlan = objPlans.getCurrentPlan(session.customer_id);
                session.currentPlan = newPlan;
                location url="#application.mainURL#/dashboard" addtoken=false;

            }

        }

    }


    dump(planDetails);
    dump(currentPlan);



    // Do we have to provide any test days?
    if (isNumeric(planDetails.testDays) and planDetails.testDays gt 0) {

        // The customer only gets test days if he has not already had any.
        getsTestDays = true;
        if (!isDate(currentPlan.endTestDate) and currentPlan.planID gt 0) {
            getsTestDays = false;
        }

        if (getsTestDays) {

            // Book the plan and let the customer test

            insertBooking = objBook.makeBooking(session.customer_id, planDetails, true);

            if (insertBooking.success) {

                <!--- Save the new plan into a session --->
                newPlan = objPlans.getCurrentPlan(session.customer_id);
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
                insertBooking = objBook.makeBooking(session.customer_id, planDetails);

                if (insertBooking.success) {

                    <!--- Save the new plan into a session --->
                    newPlan = objPlans.getCurrentPlan(session.customer_id);
                    session.currentPlan = newPlan;
                    location url="#application.mainURL#/dashboard" addtoken=false;

                } else {

                    getAlert(insertBooking.message, 'danger');
                    location url="#application.mainURL#/dashboard" addtoken=false;

                }




                // If the payment is successful, make an invoice, save the plan to the struct and send the user to the dashboard
                // doing stuff




            case "failed":

                // doing stuff


            case "cancel":
                // Send the user back to the plans
                location url="#application.mainURL#/plans" addtoken=false;

        }



    }
</cfscript>


<!--- Include the payment services --->
<cfinclude template="payment.cfm">