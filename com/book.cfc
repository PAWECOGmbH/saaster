
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
            local.argsJSon['recurring'] = "m";
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

        local.startDate = now();
        local.bookingData = arguments.bookingData;

        if (isStruct(local.bookingData)) {

            local.tillDate = "";
            local.testTillDate = "";
            local.recurring = "";

            if (variables.type eq "module") {
                local.thisID = local.bookingData.moduleID;
                local.column = "intModuleID";
            } else {
                local.thisID = local.bookingData.planID;
                local.column = "intPlanID";
            }

            if (structKeyExists(arguments, "itsTest") and arguments.itsTest) {

                local.testTillDate = dateAdd("d", local.bookingData.testDays, local.startDate);

            } else {

                if (structKeyExists(arguments, "recurring") and arguments.recurring eq "y") {

                    // Yearly subscription
                    local.tillDate = dateAdd("yyyy", 1, local.startDate);
                    local.recurring = "yearly";

                } else if (structKeyExists(arguments, "recurring") and arguments.recurring eq "m") {

                    // Monthly subscription
                    local.tillDate = dateAdd("m", 1, local.startDate);
                    local.recurring = "monthly";

                } else {

                    // Its a module with fix price
                    local.tillDate = "";
                    local.recurring = "onetime";

                }
            }

            try {

                queryExecute (
                    options = {datasource = application.datasource},
                    params = {
                        customerID: {type: "numeric", value: arguments.customerID},
                        thisID: {type: "numeric", value: local.thisID},
                        dateStart: {type: "date", value: local.startDate},
                        dateEnd: {type: "date", value: local.tillDate},
                        dateTestEnd: {type: "date", value: local.testTillDate},
                        paused: {type: "boolean", value: 0},
                        recurring: {type: "varchar", value: local.recurring}
                    },
                    sql = "
                        INSERT INTO customer_bookings (intCustomerID, #local.column#, dtmStartDate, dtmEndDate, dtmEndTestDate, blnPaused, strRecurring)
                        SELECT * FROM
                        (
                            SELECT  :customerID as customerID, :thisID as thisID, :dateStart as dateStart,
                                    :dateEnd as dateEnd, :dateTestEnd as dateTestEnd, :paused as paused, :recurring as recurring
                        ) AS tmp
                        WHERE NOT EXISTS
                        (
                            SELECT intCustomerID
                            FROM customer_bookings
                            WHERE intCustomerID = :customerID
                            AND #local.column# = :thisID
                            AND dtmStartDate = :dateStart
                        )
                        LIMIT 1
                    "
                )

            } catch (e any) {

                argsReturnValue['message'] = e.messsage;
                return argsReturnValue;

            }

        }

        argsReturnValue['message'] = "OK";
        argsReturnValue['success'] = true;
        return argsReturnValue;


    }






}