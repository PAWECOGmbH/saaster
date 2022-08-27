
component displayname="cancel" output="false" {


    public any function init(required numeric customerID, required numeric thisID, required string what) {

        variables.customerID = arguments.customerID;
        variables.thisID = arguments.thisID;
        variables.what = arguments.what;

        if (variables.what eq "plan") {
            variables.sqlField = "intPlanID";
        } else {
            variables.sqlField = "intModuleID";
        }

        // Security
        local.qCheck = queryExecute(
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: variables.customerID},
                thisID: {type: "numeric", value: variables.thisID}
            },
            sql = "
                SELECT intCustomerID
                FROM bookings
                WHERE intCustomerID = :customerID
                AND #variables.sqlField# = :thisID
            "
        )

        if (local.qCheck.recordCount or session.sysadmin) {
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

            // Cancellation at expiry date
            queryExecute (
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: variables.customerID},
                    status: {type: "varchar", value: "canceled"},
                    thisID: {type: "numeric", value: variables.thisID}
                },
                sql = "
                    UPDATE bookings
                    SET strStatus = :status
                    WHERE intCustomerID = :customerID
                    AND #variables.sqlField# = :thisID
                "
            )


            // Delete plans/modules in the future
            queryExecute (
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: variables.customerID},
                    dateNow: {type: "date", value: dateFormat(now(), "yyyy-mm-dd")},
                    thisID: {type: "numeric", value: variables.thisID}
                },
                sql = "
                    DELETE FROM bookings
                    WHERE intCustomerID = :customerID
                    AND dteStartDate > :dateNow
                    AND
                    IF (
                        '#variables.what#' = 'plan',
                        intPlanID > 0 AND strStatus = 'waiting',
                        #variables.sqlField# = :thisID
                    )
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
                    customerID: {type: "numeric", value: variables.customerID},
                    thisID: {type: "numeric", value: variables.thisID}
                },
                sql = "

                    UPDATE bookings
                    SET strStatus =
                    IF(
                        strRecurring = 'test',
                        'test',
                        'active'
                    )
                    WHERE intCustomerID = :customerID
                    AND #variables.sqlField# = :thisID

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