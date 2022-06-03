
component displayname="cancel" output="false" {


    public any function init(required numeric customerID, required numeric thisID, required string what, string language) {

        variables.customerID = arguments.customerID;
        variables.thisID = arguments.thisID;
        variables.what = arguments.what;

        if (structKeyExists(arguments, "language")) {
            variables.language = arguments.language;
        } else {
            variables.language = application.objGlobal.getDefaultLanguage().iso;
        }

        variables.objPlans = new com.plans(language=variables.language);
        variables.objModules = new com.modules(language=variables.language);

        if (variables.what eq "plan") {
            variables.thisField = "intPlanID";
        } else {
            variables.thisField = "intModuleID";
            variables.includedModules = "";
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
                FROM customer_bookings
                WHERE intCustomerID = :customerID
                AND #variables.thisField# = :thisID
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
                    thisID: {type: "numeric", value: variables.thisID},
                    recurring: {type: "varchar", value: "canceled"}
                },
                sql = "

                    UPDATE customer_bookings
                    SET strRecurring = :recurring
                    WHERE intCustomerID = :customerID
                    AND #variables.thisField# = :thisID;

                    INSERT INTO customer_bookings_history (intCustomerID, #variables.thisField#, strRecurring)
                    VALUES (:customerID, :thisID, :recurring)

                "
            )

            <!--- Save current plan into a session --->
            session.currentPlan = variables.objPlans.getCurrentPlan(variables.customerID);

            <!--- Save current module array into a session --->
            session.currentModules = variables.objModules.getBookedModules(variables.customerID);

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
                    thisID: {type: "numeric", value: variables.thisID},
                    recurring: {type: "varchar", value: "active"}
                },
                sql = "

                    UPDATE customer_bookings
                    SET strRecurring = :recurring
                    WHERE intCustomerID = :customerID
                    AND #variables.thisField# = :thisID;

                    INSERT INTO customer_bookings_history (intCustomerID, #variables.thisField#, strRecurring)
                    VALUES (:customerID, :thisID, :recurring)

                "
            )

            <!--- Save current plan into a session --->
            session.currentPlan = variables.objPlans.getCurrentPlan(variables.customerID);

            <!--- Save current module array into a session --->
            session.currentModules = variables.objModules.getBookedModules(variables.customerID);

            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        } else {

            local.argsReturnValue['message'] = application.objGlobal.getTrans('msgNoAccess');

        }

        return local.argsReturnValue;


    }


}