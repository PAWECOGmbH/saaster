component displayname="coreutility" output="false" {

    /**
     * Prepares session data for the registration form and initializes default values if needed.
     */
    public struct function getRegisterSessionData() {

        sessionData = structNew();

        // Check if the user is logged in and set step defaults
        sessionData.userLoggedIn = structKeyExists(session, "user_id") and session.user_id gt 0;
        sessionData.step = session.step ?: 1;
        sessionData.first_name = session.first_name ?: "";
        sessionData.name = session.name ?: "";
        sessionData.company = session.company ?: "";
        sessionData.email = session.email ?: "";

        // Redirect logged-in users without a defined step to the dashboard
        if (sessionData.userLoggedIn and !structKeyExists(sessionData, "step")) {
            location url="#application.mainURL#/dashboard" addtoken="false";
        }

        return sessionData;
    }


    /**
     * Retrieves additional registration data (countries and time zones) for step 3.
     */
    public struct function getAdditionalRegisterData() {

        local.additionalData = structNew();

        // Fetch data only if step 3 is active
        if (sessionData.step eq 3) {
            local.additionalData.qCountries = application.objGlobal.getCountry(language=session.lng);
            local.additionalData.timeZones = new backend.core.com.time().getTimezones();
        }

        return local.additionalData;
    }


    /**
     * Returns the reCAPTCHA script if the Site Key is set.
     */
    public string function getRecaptchaScript(reCAPTCHA_site_key) {
        if (len(trim(arguments.reCAPTCHA_site_key))) {
            return '<script src="https://www.google.com/recaptcha/api.js"></script>' &
                   '<script>function onSubmit(token) { document.getElementById("submit_form").submit(); }</script>';
        }
        return "";
    }


    /**
     * Handles logout action and returns an alert message if user is logging out
     */
    public void function handleLogout() {
        if (structKeyExists(url, "logout")) {
            session.alert = application.objGlobal.getAlert('alertLoggedOut', 'info');
        }
        return;
    }

    /**
     * Checks if a user is logged in and redirects them to the dashboard if so.
     */
    public void function redirectIfLoggedIn() {
        if (structKeyExists(session, "user_id") and session.user_id gt 0) {
            structDelete(session, "alert");
            location url="#application.mainURL#/dashboard" addtoken="false";
        }
    }

    /**
     * Returns sysadmin data for branding purposes
     */
    public struct function getSysadminData() {
        return new backend.core.com.sysadmin().getSysAdminData();
    }

    /**
     * Handles UUID and MFA checks, returning an alert message if applicable
     */
    public struct function handleUUIDandMFA() {

        local.result = { uuid: "", alertMessage: "" };

        // Check if the URL contains a UUID
        if (structKeyExists(url, 'uuid')) {
            local.result.uuid = url.uuid;

            // Check if the MFA check count is 3 or more, and set an alert if so
            if (structKeyExists(session, "mfaCheckCount") and session.mfaCheckCount gte 3) {
                local.result.alertMessage = application.objGlobal.getAlert(application.objLanguage.getTrans('txtThreeTimeTry'), 'warning');
            }
        }

        return local.result;
    }

    /**
     * Returns an array with plan details
     */
    public array function retrievePlans() {

        // Initialize variables
        local.fixedGroupID = (structKeyExists(url, "g") and isNumeric(url.g) and url.g gt 0) ? url.g : 0;
        local.ipAddress = structKeyExists(session, "usersIP") ? session.usersIP : variables.usersIP;
        local.customerID = (structKeyExists(session, "customer_id") and isNumeric(session.customer_id) and session.customer_id gt 0) ? session.customer_id : 0;
        local.objPlans = new backend.core.com.plans(language=session.lng);

        // Retrieve the groupID
        local.groupID = local.objPlans.prepareForGroupID(local.customerID, local.ipAddress, local.fixedGroupID).groupID;

        // Get the plans array using the groupID
        local.arrayPlans = local.objPlans.getPlans(local.groupID);

        // Append dynamic values with <span> elements for monthly/yearly toggle functionality
        if (arrayLen(local.arrayPlans)) {

            for (var i = 1; i <= arrayLen(local.arrayPlans); i++) {

                // Create the dynamic price HTML string with monthly and yearly spans
                local.dynPrice =
                    '<span class="price_box monthly">' & local.arrayPlans[i].priceMonthly & '</span>' &
                    '<span class="price_box yearly" style="display: none;">' & local.arrayPlans[i].priceYearly & '</span>';
                local.arrayPlans[i]['dynPrice'] = local.dynPrice;

                // Create the dynamic VAT HTML string with monthly and yearly spans
                local.dynVAT =
                    '<span class="price_box monthly">' & local.arrayPlans[i].vat_text_monthly & '</span>' &
                    '<span class="price_box yearly" style="display: none;">' & local.arrayPlans[i].vat_text_yearly & '</span>';
                local.arrayPlans[i]['dynVAT'] = local.dynVAT;

                // Create the dynamic cycling text A
                local.dynBillingCycleTextA =
                    '<span class="price_box monthly">' & lCase(application.objLanguage.getTrans('txtMonthly')) & '</span>' &
                    '<span class="price_box yearly" style="display: none;">' & lCase(application.objLanguage.getTrans('txtYearly')) & '</span>';
                local.arrayPlans[i]['dynBillingCycleTextA'] = local.dynBillingCycleTextA;

                // Create the dynamic cycling text B
                local.dynBillingCycleTextB =
                    '<span class="price_box monthly">' & lCase(application.objLanguage.getTrans('TitMonth')) & '</span>' &
                    '<span class="price_box yearly" style="display: none;">' & lCase(application.objLanguage.getTrans('TitYear')) & '</span>';
                local.arrayPlans[i]['dynBillingCycleTextB'] = local.dynBillingCycleTextB;


                // Create the dynamic booking link and button text
                local.dynBookingLinkM;
                local.dynBookingLinkY;
                local.dynBookingButtonText = application.objLanguage.getTrans('btnActivate');

                // If there is a user session
                if (structKeyExists(session, "customer_id") and session.customer_id gt 0) {

                    // Do not create a booking link for sysadmins
                    if (session.sysAdmin) {

                        local.dynBookingLink;
                        local.dynBookingButtonText = "{SYSADMIN}";

                    } else {

                        // Only super admins can book plans
                        if (session.superAdmin) {

                            // If there is already a plan, send the user to the plan edit page
                            if (structKeyExists(session.currentPlan, "planID") and session.currentPlan.planID gt 0) {

                                local.dynBookingLinkM = application.mainURL & "/account-settings/plans";
                                local.dynBookingLinkY = local.dynBookingLinkM;

                            // There is no booked plan yet
                            } else {

                                // If its a free plan
                                if (local.arrayPlans[i].itsFree eq 1) {

                                    local.dynBookingLinkM = local.arrayPlans[i].bookingLinkO;
                                    local.dynBookingLinkY = local.dynBookingLinkM;

                                // Its a paid plan
                                } else {

                                    // Check if the user has already added a payment method or the plan has any test days
                                    local.getWebhook = new backend.core.com.payrexx().getWebhook(session.customer_id, 'authorized');
                                    if (local.getWebhook.recordCount or local.arrayPlans[i].testDays gt 0) {

                                        local.dynBookingLinkM = local.arrayPlans[i].bookingLinkM;
                                        local.dynBookingLinkY = local.arrayPlans[i].bookingLinkY;

                                    // Send the user to the payment page in order to add a payment method
                                    } else {

                                        local.dynBookingLinkM = application.mainURL & "/account-settings/payment";
                                        local.dynBookingLinkY = local.dynBookingLinkM;

                                    }

                                }

                            }


                        // If its not a super admin, send the user to the dashboard
                        } else {

                            local.dynBookingLinkM = application.mainURL & "/dashboard";
                            local.dynBookingLinkY = local.dynBookingLinkM;

                        }

                    }


                // There is no user session, so send to the registration form
                } else {

                    // Build the booking link for free plans
                    if (local.arrayPlans[i].itsFree eq 1) {

                        local.dynBookingLinkM = urlEncodedFormat(replace(replace(local.arrayPlans[i].bookingLinkO, application.mainURL, "", "one"), "/", "", "one"));
                        local.dynBookingLinkY = dynBookingLinkM;

                    // Build the booking link for paid plans
                    } else {

                        local.dynBookingLinkM = urlEncodedFormat(replace(replace(local.arrayPlans[i].bookingLinkM, application.mainURL, "", "one"), "/", "", "one"));
                        local.dynBookingLinkY = urlEncodedFormat(replace(replace(local.arrayPlans[i].bookingLinkY, application.mainURL, "", "one"), "/", "", "one"));

                    }

                    if (len(trim(local.arrayPlans[i].buttonName))) {
                        local.dynBookingButtonText = local.arrayPlans[i].buttonName;
                    }

                }

                local.arrayPlans[i]['dynBookingLinkM'] = local.dynBookingLinkM;
                local.arrayPlans[i]['dynBookingLinkY'] = local.dynBookingLinkY;
                local.arrayPlans[i]['dynBookingButtonText'] = local.dynBookingButtonText;

            }
        }

        return local.arrayPlans;

    }


}