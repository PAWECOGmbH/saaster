<!--- This file will be included while users login --->

<cfscript>

    // If a worker with goupID 2 gets a default plan with ID 1, we need to change it
    // If the current customer exists in the worker_profile table, it must be 2
    if (structKeyExists(session, "user_id")) {

        if (session.currentPlan.planID gt 0) {

            objProfile = new backend.myapp.com.profile();
            objProfile.workerAdjustment(session.user_id, session.currentPlan);

            // Set plans and modules as well as the custom settings into a session
            application.objCustomer.setProductSessions(session.customer_id, session.lng);

        }

    }

</cfscript>