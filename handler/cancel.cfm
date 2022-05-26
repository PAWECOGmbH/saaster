
<cfscript>

<!--- Cancel plan or revoke cancellation --->
if (structKeyExists(url, "plan")) {

    if (isNumeric(url.plan) and url.plan gt 0) {

        // Revoke cancellation
        if (structKeyExists(url, "revoke")) {

            try {

                queryExecute (
                    options = {datasource = application.datasource},
                    params = {
                        customerID: {type: "numeric", value: session.customer_id},
                        planID: {type: "numeric", value: url.plan},
                        recurring: {type: "varchar", value: "active"}
                    },
                    sql = "

                        UPDATE customer_bookings
                        SET strRecurring = :recurring
                        WHERE intCustomerID = :customerID
                        AND intPlanID = :planID;

                        INSERT INTO customer_bookings_history (intCustomerID, intPlanID, strRecurring)
                        VALUES (:customerID, :planID, :recurring)

                    "
                )

                getAlert('msgRevokedSuccessful', 'success');

                <!--- Save current plan into a session --->
                checkPlan = new com.plans(language=session.lng).getCurrentPlan(session.customer_id);
                session.currentPlan = checkPlan;

            } catch (any) {

                getAlert('alertErrorOccured', 'danger');

            }

        } else {

            // Only a SuperAdmin can cancel a plan
            if (!session.superAdmin) {
                getAlert('msgNoAccess', 'danger');
                location url="#application.mainURL#/account-settings" addtoken="false";
            }

            try {

                queryExecute (
                    options = {datasource = application.datasource},
                    params = {
                        customerID: {type: "numeric", value: session.customer_id},
                        planID: {type: "numeric", value: url.plan},
                        recurring: {type: "varchar", value: "canceled"}
                    },
                    sql = "

                        UPDATE customer_bookings
                        SET strRecurring = :recurring
                        WHERE intCustomerID = :customerID
                        AND intPlanID = :planID;

                        INSERT INTO customer_bookings_history (intCustomerID, intPlanID, strRecurring)
                        VALUES (:customerID, :planID, :recurring)

                    "
                )

                getAlert('msgCanceledSuccessful', 'success');

                <!--- Save current plan into a session --->
                checkPlan = new com.plans(language=session.lng).getCurrentPlan(session.customer_id);
                session.currentPlan = checkPlan;

            } catch (any) {

                getAlert('alertErrorOccured', 'danger');

            }

        }


        location url="#application.mainURL#/account-settings" addtoken="false";

    }

}




<!--- Cancel module or revoke cancellation --->
if (structKeyExists(url, "module")) {

    if (isNumeric(url.module) and url.module gt 0) {

        // Revoke cancellation
        if (structKeyExists(url, "revoke")) {

            try {

                queryExecute (
                    options = {datasource = application.datasource},
                    params = {
                        customerID: {type: "numeric", value: session.customer_id},
                        moduleID: {type: "numeric", value: url.module},
                        recurring: {type: "varchar", value: "active"}
                    },
                    sql = "

                        UPDATE customer_bookings
                        SET strRecurring = :recurring
                        WHERE intCustomerID = :customerID
                        AND intModuleID = :moduleID;

                        INSERT INTO customer_bookings_history (intCustomerID, intModuleID, strRecurring)
                        VALUES (:customerID, :moduleID, :recurring)

                    "
                )

                getAlert('msgRevokedSuccessful', 'success');

                <!--- Save current module array into a session --->
                session.currentModules = new com.modules(language=session.lng).getBookedModules(session.customer_id);

            } catch (any) {

                getAlert('alertErrorOccured', 'danger');

            }

        } else {

            // Only a SuperAdmin can cancel a module
            if (!session.superAdmin) {
                getAlert('msgNoAccess', 'danger');
                location url="#application.mainURL#/account-settings/modules" addtoken="false";
            }

            try {

                objModules = new com.modules(language=session.lng);

                // Check if the expiration date has already been reached
                expirationDate = objModules.getModuleStatus(session.customer_id, url.module).endTestDate;
                if (!isDate(expirationDate)) {
                    expirationDate = objModules.getModuleStatus(session.customer_id, url.module).endDate;
                }

                // If the end date has been reached, delete the booking
                if (dateCompare(expirationDate, now()) lt 0) {


                    // We delete all the customers data using a function
                    deleteData = objModules.deleteModuleData(session.customer_id, url.module);


                    queryExecute (
                        options = {datasource = application.datasource},
                        params = {
                            customerID: {type: "numeric", value: session.customer_id},
                            moduleID: {type: "numeric", value: url.module},
                            recurring: {type: "varchar", value: "deleted"}
                        },
                        sql = "

                            DELETE FROM customer_bookings
                            WHERE intCustomerID = :customerID
                            AND intModuleID = :moduleID;

                            INSERT INTO customer_bookings_history (intCustomerID, intModuleID, strRecurring)
                            VALUES (:customerID, :moduleID, :recurring)

                        "
                    )

                } else {

                    queryExecute (
                        options = {datasource = application.datasource},
                        params = {
                            customerID: {type: "numeric", value: session.customer_id},
                            moduleID: {type: "numeric", value: url.module},
                            recurring: {type: "varchar", value: "canceled"}
                        },
                        sql = "

                            UPDATE customer_bookings
                            SET strRecurring = :recurring
                            WHERE intCustomerID = :customerID
                            AND intModuleID = :moduleID;

                            INSERT INTO customer_bookings_history (intCustomerID, intModuleID, strRecurring)
                            VALUES (:customerID, :moduleID, :recurring)

                        "
                    )

                }

                getAlert('msgCanceledSuccessful', 'success');

                <!--- Save current module array into a session --->
                session.currentModules = objModules.getBookedModules(session.customer_id);

            } catch (any) {

                getAlert('alertErrorOccured', 'danger');

            }

        }


        location url="#application.mainURL#/account-settings/modules" addtoken="false";

    }

}

</cfscript>