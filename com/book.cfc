
component displayname="book" output="false" {

    // Create and encrypt booking link
    public string function createBookingLink(required numeric planID, required numeric lngID, required numeric currencyID, string plan) {

        local.argsJason = {};
        local.argsJason['planID'] = arguments.planID;
        local.argsJason['lngID'] = arguments.lngID;
        local.argsJason['currencyID'] = arguments.currencyID;
        if (structKeyExists(arguments, "plan")) {
            local.argsJason['plan'] = arguments.plan;
        } else {
            local.argsJason['plan'] = "m";
        }

        local.urlEncoded = URLEncodedFormat(serializeJSON(local.argsJason));
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

            if (structKeyExists(arguments, "itsTest") and arguments.itsTest) {
                local.testTillDate = dateAdd("d", local.thisPlan.testDays, local.startDate);
                local.tillDate = "";
            } else if (local.thisPlan.itsFree) {
                local.testTillDate = "";
                local.tillDate = "";
            } else {
                local.testTillDate = "";
                if (structKeyExists(arguments, "plan") and arguments.plan eq "y") {
                    // Yearly subscription
                    local.tillDate = dateAdd("yyyy", 1, local.startDate);
                } else {
                    // Monthly subscription
                    local.tillDate = dateAdd("m", 1, local.startDate);
                }
            }

            try {

                queryExecute (
                    options = {datasource = application.datasource, result = "newID"},
                    params = {
                        customerID: {type: "numeric", value: arguments.customerID},
                        planID: {type: "numeric", value: local.thisPlan.planID},
                        dateStart: {type: "date", value: local.startDate},
                        dateEnd: {type: "date", value: local.tillDate},
                        dateTestEnd: {type: "date", value: local.testTillDate},
                        paused: {type: "boolean", value: 0}
                    },
                    sql = "
                        INSERT INTO customer_plans (intCustomerID, intPlanID, dtmStartDate, dtmEndDate, dtmEndTestDate, blnPaused)
                        VALUES (:customerID, :planID, :dateStart, :dateEnd, :dateTestEnd, :paused)
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