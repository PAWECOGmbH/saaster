
component displayname="book" output="false" {

    // Create and encrypt booking link
    public string function createBookingLink(required numeric thisID, required numeric lngID, required numeric currencyID, string plan, string type) {

        param name="arguments.type" default="plan";

        local.argsJSon = {};
        if(arguments.type eq "module") {
            local.argsJSon['moduleID'] = arguments.thisID;
        } else {
            local.argsJSon['planID'] = arguments.thisID;
        }
        local.argsJSon['lngID'] = arguments.lngID;
        local.argsJSon['currencyID'] = arguments.currencyID;
        if (structKeyExists(arguments, "plan")) {
            local.argsJSon['plan'] = arguments.plan;
        } else {
            local.argsJSon['plan'] = "m";
        }

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
    public struct function makeBooking(required numeric customerID, required struct planData, boolean itsTest, string plan) {

        variables.argsReturnValue = structNew();
        variables.argsReturnValue['message'] = "";
        variables.argsReturnValue['success'] = false;

        local.startDate = now();
        local.thisPlan = arguments.planData;

        if (isStruct(local.thisPlan)) {

            local.tillDate = "";
            local.testTillDate = "";
            local.recurring = "";

            if (structKeyExists(arguments, "itsTest") and arguments.itsTest) {

                local.testTillDate = dateAdd("d", local.thisPlan.testDays, local.startDate);

            } else {

                if (structKeyExists(arguments, "plan") and arguments.plan eq "y") {

                    // Yearly subscription
                    local.tillDate = dateAdd("yyyy", 1, local.startDate);
                    local.recurring = "yearly";

                } else if (structKeyExists(arguments, "plan") and arguments.plan eq "m") {

                    // Monthly subscription
                    local.tillDate = dateAdd("m", 1, local.startDate);
                    local.recurring = "monthly";

                } else {

                    // Its a module with fix price
                    local.tillDate = "";
                    local.recurring = "";

                }
            }

            try {

                queryExecute (
                    options = {datasource = application.datasource, result = "newID"},
                    params = {
                        customerID: {type: "numeric", value: arguments.customerID},
                        planID: {type: "numeric", value: local.thisPlan.planID},
                        moduleID: {type: "numeric", value: local.thisPlan.moduleID},
                        dateStart: {type: "date", value: local.startDate},
                        dateEnd: {type: "date", value: local.tillDate},
                        dateTestEnd: {type: "date", value: local.testTillDate},
                        paused: {type: "boolean", value: 0},
                        recurring: {type: "varchar", value: local.recurring}
                    },
                    sql = "
                        INSERT INTO customer_bookings (intCustomerID, intPlanID, intModuleID, dtmStartDate, dtmEndDate, dtmEndTestDate, blnPaused, strRecurring)
                        VALUES (:customerID, :planID, :moduleID, :dateStart, :dateEnd, :dateTestEnd, :paused, :recurring)
                    "
                )

                argsReturnValue['newID'] = newID.generatedKey;

            } catch (any e) {

                argsReturnValue['message'] = e.messsage;
                return argsReturnValue;

            }

        }

        argsReturnValue['message'] = "OK";
        argsReturnValue['success'] = true;
        return argsReturnValue;


    }






}