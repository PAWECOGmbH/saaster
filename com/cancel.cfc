
component displayname="cancel" output="false" {


    public any function init(required numeric customerID, required numeric thisID, required string what) {

        variables.customerID = arguments.customerID;
        variables.thisID = arguments.thisID;
        variables.what = arguments.what;

        if (variables.what eq "plan") {
            variables.sql_query = "AND intPlanID = " & variables.thisID;
        } else {
            variables.sql_query = "AND intModuleID = " & variables.thisID;
        }

        // Security
        local.qCheck = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: variables.customerID}
            },
            sql = "
                SELECT intCustomerID
                FROM bookings
                WHERE intCustomerID = :customerID
                #variables.sql_query#
            "
        )

        if (local.qCheck.recordCount) {
            variables.isAllowed = true;
        } else {
            variables.isAllowed = false;
        }

        return this;

    }


    // Cancel plan or module
    public struct function cancel() {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (variables.isAllowed) {

            // Cancel plan
            queryExecute (
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: variables.customerID},
                    status: {type: "varchar", value: "canceled"},
                    dateNow: {type: "date", value: dateFormat(now(), "yyyy-mm-dd")}
                },
                sql = "

                    UPDATE bookings
                    SET strStatus = :status
                    WHERE intCustomerID = :customerID
                    #variables.sql_query#;

                    /* Delete plans in the future */
                    DELETE FROM bookings
                    WHERE intCustomerID = :customerID
                    AND dteStartDate > :dateNow


                "
            )

            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;


        } else {

            local.argsReturnValue['message'] = application.objGlobal.getTrans('msgNoAccess');

        }


        return local.argsReturnValue;


    }


    // Revoke cancellation
    public struct function revoke() {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (variables.isAllowed) {

            queryExecute (
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: variables.customerID}
                },
                sql = "

                    UPDATE bookings
                    SET strStatus =
                    IF(
                        LENGTH(strRecurring),
                        'active',
                        'test'
                    )
                    WHERE intCustomerID = :customerID
                    #variables.sql_query#

                "
            )

            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        } else {

            local.argsReturnValue['message'] = application.objGlobal.getTrans('msgNoAccess');

        }

        return local.argsReturnValue;


    }


}