
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

                    // Its a plan/module with fix price
                    local.tillDate = "";
                    local.recurring = "onetime";

                }
            }

            if (variables.type eq "module") {
                local.thisID = local.bookingData.moduleID;
                local.column = "intModuleID";
                local.queryStatement = "AND intModuleID = #local.thisID#";
            } else {
                local.thisID = local.bookingData.planID;
                local.column = "intPlanID";
                local.queryStatement = "AND intPlanID > 0";
            }

            local.qCheckBookings = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID}
                },
                sql = "
                    SELECT intCustomerBookingID, intPlanID
                    FROM customer_bookings
                    WHERE intCustomerID = :customerID
                    #local.queryStatement#
                "
            )

            if (local.qCheckBookings.recordCount) {

                try {

                    if (variables.type eq "module") {

                        queryExecute (
                            options = {datasource = application.datasource},
                            params = {
                                customerID: {type: "numeric", value: arguments.customerID},
                                thisID: {type: "numeric", value: local.thisID},
                                dateStart: {type: "datetime", value: local.startDate},
                                dateEnd: {type: "datetime", value: local.tillDate},
                                dateTestEnd: {type: "datetime", value: local.testTillDate},
                                paused: {type: "boolean", value: 0},
                                recurring: {type: "varchar", value: local.recurring}
                            },
                            sql = "

                                UPDATE customer_bookings
                                SET dtmStartDate = :dateStart,
                                    dtmEndDate = :dateEnd,
                                    dtmEndTestDate = :dateTestEnd,
                                    strRecurring = :recurring
                                WHERE intCustomerID = :customerID
                                AND intModuleID = :thisID;

                                INSERT INTO customer_bookings_history (intCustomerID, intModuleID, dtmStartDate, dtmEndDate, dtmEndTestDate, blnPaused, strRecurring)
                                VALUES (:customerID, :thisID, :dateStart, :dateEnd, :dateTestEnd, :paused, :recurring)

                            "
                        )

                    } else {

                        queryExecute (
                            options = {datasource = application.datasource},
                            params = {
                                customerID: {type: "numeric", value: arguments.customerID},
                                thisID: {type: "numeric", value: local.thisID},
                                dateStart: {type: "datetime", value: local.startDate},
                                dateEnd: {type: "datetime", value: local.tillDate},
                                dateTestEnd: {type: "datetime", value: local.testTillDate},
                                paused: {type: "boolean", value: 0},
                                recurring: {type: "varchar", value: local.recurring}
                            },
                            sql = "

                                UPDATE customer_bookings
                                SET intPlanID = :thisID,
                                    dtmStartDate = :dateStart,
                                    dtmEndDate = :dateEnd,
                                    dtmEndTestDate = :dateTestEnd,
                                    strRecurring = :recurring
                                WHERE intCustomerID = :customerID
                                AND intModuleID IS NULL;

                                INSERT INTO customer_bookings_history (intCustomerID, intPlanID, dtmStartDate, dtmEndDate, dtmEndTestDate, blnPaused, strRecurring)
                                VALUES (:customerID, :thisID, :dateStart, :dateEnd, :dateTestEnd, :paused, :recurring)

                            "
                        )

                    }

                } catch (e any) {

                    argsReturnValue['message'] = e.messsage;
                    return argsReturnValue;

                }

            } else {

                try {

                    queryExecute (
                        options = {datasource = application.datasource},
                        params = {
                            customerID: {type: "numeric", value: arguments.customerID},
                            thisID: {type: "numeric", value: local.thisID},
                            dateStart: {type: "datetime", value: local.startDate},
                            dateEnd: {type: "datetime", value: local.tillDate},
                            dateTestEnd: {type: "datetime", value: local.testTillDate},
                            paused: {type: "boolean", value: 0},
                            recurring: {type: "varchar", value: local.recurring}
                        },
                        sql = "

                            INSERT INTO customer_bookings (intCustomerID, #local.column#, dtmStartDate, dtmEndDate, dtmEndTestDate, blnPaused, strRecurring)
                            VALUES (:customerID, :thisID, :dateStart, :dateEnd, :dateTestEnd, :paused, :recurring);

                            INSERT INTO customer_bookings_history (intCustomerID, #local.column#, dtmStartDate, dtmEndDate, dtmEndTestDate, blnPaused, strRecurring)
                            VALUES (:customerID, :thisID, :dateStart, :dateEnd, :dateTestEnd, :paused, :recurring)

                        "
                    )

                } catch (e any) {

                    argsReturnValue['message'] = e.messsage;
                    return argsReturnValue;

                }

            }

        }

        argsReturnValue['message'] = "OK";
        argsReturnValue['success'] = true;
        return argsReturnValue;


    }






}