
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
    public struct function makeBooking(required numeric customerID, required struct bookingData, boolean itsTest, string recurring) {

        variables.argsReturnValue = structNew();
        variables.argsReturnValue['message'] = "";
        variables.argsReturnValue['success'] = false;

        // UTC date of today
        local.startDate = dateFormat(now(), "yyyy/mm/dd");

        // Data of the plan/module to be booked
        local.bookingData = arguments.bookingData;

        // Data of the modules the customer already has
        if (variables.type eq "module") {

            local.objModules = new com.modules(currencyID=local.bookingData.currencyID);
            local.currentData = local.objModules.getBookedModules(arguments.customerID);
            local.moduleID = local.bookingData.moduleID;
            local.planID = "";


        // Data of the plan the customer already has
        } else {

            local.objPlans = new com.plans(currencyID=local.bookingData.currencyID);
            local.currentData = local.objPlans.getCurrentPlan(arguments.customerID);
            local.planID = local.bookingData.planID;
            local.moduleID = "";

        }

        dump(local.currentData);
        dump(local.bookingData);
        //abort;



        if (isStruct(local.bookingData)) {

            local.tillDate = "";
            local.testTillDate = "";
            local.recurring = "";


            // Does the customer already have a plan?










            if (structKeyExists(arguments, "itsTest") and arguments.itsTest) {

                local.testTillDate = dateAdd("d", local.bookingData.testDays, local.startDate);

            } else {

                if (structKeyExists(arguments, "recurring") and arguments.recurring eq "yearly") {

                    // Yearly subscription
                    local.tillDate = dateAdd("yyyy", 1, local.startDate);
                    local.tillDate = dateAdd("d", -1, local.tillDate);
                    local.recurring = "yearly";

                } else if (structKeyExists(arguments, "recurring") and arguments.recurring eq "monthly") {

                    // Monthly subscription
                    local.tillDate = dateAdd("m", 1, local.startDate);
                    local.tillDate = dateAdd("d", -1, local.tillDate);
                    local.recurring = "monthly";

                } else {

                    // Its a plan/module with fix price
                    local.tillDate = "";
                    local.recurring = "onetime";

                }
            }



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

            } catch (any e) {

                argsReturnValue['message'] = e.message;
                return argsReturnValue;

            }


        }

        argsReturnValue['message'] = "OK";
        argsReturnValue['success'] = true;
        return argsReturnValue;


    }






}