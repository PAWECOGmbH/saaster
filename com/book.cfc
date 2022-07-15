
component displayname="book" output="false" {

    public any function init(string type) {

        param name="arguments.type" default="plan";
        variables.type = arguments.type;

        return this;

    }


    // Create and encrypt booking link
    public string function createBookingLink(required numeric thisID, required numeric lngID, required numeric currencyID, string recurring) {

        local.argsJSon = {};
        if(variables.type eq "module") {
            local.argsJSon['moduleID'] = arguments.thisID;
        } else {
            local.argsJSon['planID'] = arguments.thisID;
        }
        if (structKeyExists(arguments, "recurring")) {
            local.argsJSon['recurring'] = arguments.recurring;
        } else {
            local.argsJSon['recurring'] = "monthly";
        }
        local.argsJSon['lngID'] = arguments.lngID;
        local.argsJSon['currencyID'] = arguments.currencyID;
        local.urlEncoded = URLEncodedFormat(serializeJSON(local.argsJSon));
        local.base64Link = toBase64(local.urlEncoded);

        return local.base64Link;

    }


    // Decrypt booking link
    public struct function decryptBookingLink(required string bookingLink) {

        local.toDecrypt = toString(toBinary(arguments.bookingLink));
        local.structFromString = DeserializeJSON(URLDecode(local.toDecrypt));

        return local.structFromString;

    }


    // Make a booking
    public struct function makeBooking(required numeric customerID, required struct bookingData, required string recurring) {

        variables.argsReturnValue = structNew();
        variables.argsReturnValue['message'] = "";
        variables.argsReturnValue['success'] = false;

        local.planID = "";
        local.moduleID = "";

        // Data of the plan/module to be booked
        local.bookingData = arguments.bookingData;
        dump(local.bookingData);

        // Get the currency of the plan
        if (isNumeric(local.bookingData.currencyID) and local.bookingData.currencyID) {
            local.currencyID = local.bookingData.currencyID;
        } else {
            local.currencyID = 0;
        }

        local.startDate = "";
        local.tillDate = "";
        local.testTillDate = "";
        local.recurring = "";
        local.hadTest = false;

        // Plan
        if (variables.type eq "plan") {

            // New plan ID
            local.planID = local.bookingData.planID;

            // Data of the plan the customer already has
            local.objPlans = new com.plans(currencyID=local.currencyID);
            local.currentPlan = local.objPlans.getCurrentPlan(arguments.customerID);

            dump(local.currentPlan);
            //abort;


            // Set the start date (first booking)
            if (local.currentPlan.planID eq 0) {

                local.startDate = dateFormat(now(), "yyyy-mm-dd");

            // Set the start date (followed booking)
            } else {

                if (isDate(local.currentPlan.endTestDate)) {
                    local.startDate = dateFormat(dateAdd("d", 1, local.currentPlan.endTestDate), "yyyy-mm-dd");
                    local.hadTest = true;
                } else {
                    local.startDate = dateFormat(dateAdd("d", 1, local.currentPlan.endDate), "yyyy-mm-dd");
                }

            }

            // Free plan
            if (local.bookingData.itsFree eq 1) {

                local.recurring = "onetime";

            }

            // Test days
            if (local.bookingData.testDays gt 0 and !local.hadTest) {

                local.testTillDate = dateFormat(dateAdd("d", local.bookingData.testDays, local.startDate), "yyyy-mm-dd");

            // Live plan
            } else {

                if (arguments.recurring eq "yearly") {

                    // Yearly subscription
                    local.tillDate = dateAdd("yyyy", 1, local.startDate);
                    local.tillDate = dateFormat(dateAdd("d", -1, local.tillDate), "yyyy-mm-dd");
                    local.recurring = "yearly";

                } else {

                    // Monthly subscription
                    local.tillDate = dateAdd("m", 1, local.startDate);
                    local.tillDate = dateFormat(dateAdd("d", -1, local.tillDate), "yyyy-mm-dd");
                    local.recurring = "monthly";

                }

            }





            dump(local.startDate);
            dump(local.tillDate);
            dump(local.testTillDate);
            dump(local.recurring);
            dump(local.hadTest);








        // Data of the modules the customer already has
        } else {

            local.objModules = new com.modules(currencyID=local.currencyID);
            local.currentData = local.objModules.getBookedModules(arguments.customerID);
            local.moduleID = local.bookingData.moduleID;
            local.planID = "";

        }



        // Insert booking
        try {

            queryExecute (
                options = {datasource = application.datasource, result = "qNewID"},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID},
                    planID: {type: "numeric", value: local.planID},
                    moduleID: {type: "numeric", value: local.moduleID},
                    dateStart: {type: "date", value: local.startDate},
                    dateEnd: {type: "date", value: local.tillDate},
                    dateTestEnd: {type: "date", value: local.testTillDate},
                    recurring: {type: "varchar", value: local.recurring}
                },
                sql = "

                    INSERT INTO customer_bookings (intCustomerID, intPlanID, intModuleID, dteStartDate, dteEndDate, dteEndTestDate, strRecurring)
                    VALUES (:customerID, :planID, :moduleID, :dateStart, :dateEnd, :dateTestEnd, :recurring)

                "
            )

            argsReturnValue['bookingID'] = qNewID.generated_key;
            argsReturnValue['message'] = "OK";
            argsReturnValue['success'] = true;


        } catch (any e) {

            argsReturnValue['message'] = e.message;

        }

        return argsReturnValue;


    }







}