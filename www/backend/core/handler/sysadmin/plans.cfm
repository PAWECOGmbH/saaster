<cfscript>

if (structKeyExists(form, "new_group")) {

    qNexPrio = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT COALESCE(MAX(intPrio),0)+1 as nextPrio
            FROM plan_groups
        "
    )

    param name="form.group_name" default="";
    param name="form.countryID" default="";

    try {

        dbType = len(form.countryID) ? "numeric" : "varchar";

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                group_name: {type: "nvarchar", value: form.group_name},
                cID: {type: #dbType#, value: form.countryID},
                nextPrio: {type: "numeric", value: qNexPrio.nextPrio}
            },
            sql = "
                INSERT INTO plan_groups (strGroupName, intCountryID, intPrio)
                VALUES (:group_name, COALESCE(NULLIF(:cID, ''), NULL), :nextPrio)
            "
        )

        getAlert('Group saved. Please add your plan now.');

    } catch (any e) {

        getAlert(e.message, 'danger');

    }

    location url="#application.mainURL#/sysadmin/plangroups" addtoken="false";

}


if (structKeyExists(form, "edit_plangroup")) {

    if (isNumeric(form.edit_plangroup)) {

        param name="form.group_name" default="";
        param name="form.countryID" default="";

        dbType = len(form.countryID) ? "numeric" : "varchar";

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                group_name: {type: "nvarchar", value: form.group_name},
                cID: {type: #dbType#, value: form.countryID},
                plangroupID: {type: "numeric", value: form.edit_plangroup}
            },
            sql = "
                UPDATE plan_groups
                SET strGroupName = :group_name,
                    intCountryID = COALESCE(NULLIF(:cID, ''), NULL)
                WHERE intPlanGroupID = :plangroupID
            "
        )

        getAlert('Group saved.');
        location url="#application.mainURL#/sysadmin/plangroups" addtoken="false";

    }

}


if (structKeyExists(url, "delete_group")) {

    if (isNumeric(url.delete_group)) {

        qPlanGroup = queryExecute(
            options = {datasource = application.datasource},
            params = {
                plangroupID: {type: "numeric", value: url.delete_group}
            },
            sql = "
                SELECT intPrio
                FROM plan_groups
                WHERE intPlanGroupID = :plangroupID
            "
        )

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    plangroupID: {type: "numeric", value: url.delete_group},
                    currPrio: {type: "numeric", value: qPlanGroup.intPrio}
                },
                sql = "
                    DELETE FROM plan_groups WHERE intPlanGroupID = :plangroupID;
                    UPDATE plan_groups SET intPrio = intPrio-1 WHERE intPrio > :currPrio
                "
            )

            getAlert('Plan group deleted successfully!', 'success');


        } catch (any e) {

            getAlert(e.message, 'danger');

        }

        location url="#application.mainURL#/sysadmin/plangroups" addtoken="false";


    }

}




if (structKeyExists(form, "new_plan")) {

    param name="form.groupID" default="0";
    param name="form.plan_name" default="";

    qNexPrio = queryExecute(
        options = {datasource = application.datasource},
        params = {
            groupID: {type: "numeric", value: form.groupID}
        },
        sql = "
            SELECT COALESCE(MAX(intPrio),0)+1 as nextPrio
            FROM plans
            WHERE intPlanGroupID = :groupID
        "
    )

    try {

        queryExecute(
            options = {datasource = application.datasource, result="newID"},
            params = {
                plan_name: {type: "nvarchar", value: form.plan_name},
                groupID: {type: "numeric", value: form.groupID},
                nextPrio: {type: "numeric", value: qNexPrio.nextPrio}
            },
            sql = "
                INSERT INTO plans (intPlanGroupID, strPlanName, intPrio)
                VALUES (:groupID, :plan_name, :nextPrio)
            "
        )

        newID = newID.generatedkey;

        getAlert('Plan saved. Please configure your plan now.');
        location url="#application.mainURL#/sysadmin/plan/edit/#newID#" addtoken="false";


    } catch (any e) {

        getAlert(e.message, 'danger');
        location url="#application.mainURL#/sysadmin/plans" addtoken="false";

    }

}



if (structKeyExists(form, "edit_plan")) {

    if (isNumeric(form.edit_plan)) {

        param name="form.groupID" default="0";
        param name="form.plan_name" default="";
        param name="form.short_desc" default="";
        param name="form.button_name" default="";
        param name="form.booking_link" default="";
        param name="form.test_days" default="0";
        param name="form.max_users" default="0";
        param name="form.desc" default="";

        groupID = form.groupID;
        plan_name = form.plan_name;
        short_desc = form.short_desc;
        button_name = form.button_name;
        booking_link = form.booking_link;
        test_days = form.test_days;
        max_users = form.max_users;
        desc = form.desc;

        recommended = structKeyExists(form, "recommended") ? 1 : 0;

        if (structKeyExists(form, "free")) {

            free = 1;
            test_days = 0;

            // Set all prices to 0
            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    planID: {type: "numeric", value: form.edit_plan}
                },
                sql = "
                    UPDATE plan_prices
                    SET decPriceMonthly = 0,
                        decPriceYearly = 0,
                        decVat = 0,
                        intVatType = 1,
                        blnIsNet = 1,
                        blnOnRequest = 0
                    WHERE intPlanID = :planID
                "
            )

        } else {
            free = 0;
        }

        queryExecute(
            options = {datasource = application.datasource, result="newID"},
            params = {
                groupID: {type: "numeric", value: groupID},
                plan_name: {type: "nvarchar", value: plan_name},
                short_desc: {type: "nvarchar", value: short_desc},
                description: {type: "nvarchar", value: desc},
                button_name: {type: "nvarchar", value: button_name},
                booking_link: {type: "nvarchar", value: booking_link},
                recommended: {type: "boolean", value: recommended},
                free: {type: "boolean", value: free},
                test_days: {type: "numeric", value: test_days},
                max_users: {type: "numeric", value: max_users},
                planID: {type: "numeric", value: form.edit_plan}
            },
            sql = "
                UPDATE plans
                SET intPlanGroupID = :groupID,
                    strPlanName = :plan_name,
                    strShortDescription = :short_desc,
                    strDescription = :description,
                    strButtonName = :button_name,
                    strBookingLink = :booking_link,
                    intNumTestDays = :test_days,
                    blnRecommended = :recommended,
                    blnFree = :free,
                    intMaxUsers = :max_users
                WHERE intPlanID = :planID
            "
        )

        getAlert('Plan saved!');
        location url="#application.mainURL#/sysadmin/plan/edit/#form.edit_plan#?tab=details" addtoken="false";

    }

}


if (structKeyExists(url, "delete_plan")) {

    if (isNumeric(url.delete_plan)) {

        qPlan = queryExecute(
            options = {datasource = application.datasource},
            params = {
                planID: {type: "numeric", value: url.delete_plan}
            },
            sql = "
                SELECT intPrio, intPlanGroupID
                FROM plans
                WHERE intPlanID = :planID
            "
        )

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    planID: {type: "numeric", value: url.delete_plan},
                    plangroupID: {type: "numeric", value: qPlan.intPlanGroupID},
                    currPrio: {type: "numeric", value: qPlan.intPrio}
                },
                sql = "
                    DELETE FROM plans WHERE intPlanID = :planID;
                    UPDATE plans SET intPrio = intPrio-1 WHERE intPrio > :currPrio AND intPlanGroupID = :plangroupID
                "
            )

            getAlert('Plan deleted successfully!', 'success');


        } catch (any e) {

            getAlert(e.message, 'danger');

        }

        location url="#application.mainURL#/sysadmin/plans" addtoken="false";


    }

}

// Set plan as default
if (structKeyExists(url, "default")) {

    setDefault = structKeyExists(form, "default") ? 1 : 0;

    queryExecute(
        options = {datasource = application.datasource},
        params = {
            planID: {type: "numeric", value: form.planID},
            groupID: {type: "numeric", value: form.groupID},
            default: {type: "boolean", value: setDefault}
        },
        sql = "

            UPDATE plans
            SET blnDefaultPlan = 0
            WHERE intPlanGroupID = :groupID;

            UPDATE plans
            SET blnDefaultPlan = :default
            WHERE intPlanGroupID = :groupID
            AND intPlanID = :planID;

        "
    )

    location url="#application.mainURL#/sysadmin/plans" addtoken="false";

}


if (structKeyExists(form, "edit_prices")) {

    if (isNumeric(form.edit_prices)) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                planID: {type: "numeric", value: form.edit_prices}
            },
            sql = "
                UPDATE plan_prices
                SET blnIsNet = 0,
                    blnOnRequest = 0
                WHERE intPlanID = :planID
            "
        )

        cfloop( list = form.fieldnames, index = "f" ) {

            thisCurrencyID = listLast(f, "_");
            thisField = listFirst(f, "_");

            if (thisField eq "pricemonthly" or thisField eq "priceyearly") {

                // Look if we find an entry in the table
                qCheckPrice = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        planID: {type: "numeric", value: form.edit_prices},
                        thisCurrencyID: {type: "numeric", value: thisCurrencyID}
                    },
                    sql = "
                        SELECT intCurrencyID
                        FROM plan_prices
                        WHERE intPlanID = :planID
                        AND intCurrencyID = :thisCurrencyID
                    "
                )

                if (!qCheckPrice.recordCount) {

                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            planID: {type: "numeric", value: form.edit_prices},
                            thisCurrencyID: {type: "numeric", value: thisCurrencyID}
                        },
                        sql = "
                            INSERT INTO plan_prices (intPlanID, intCurrencyID)
                            VALUES (:planID, :thisCurrencyID)
                        "
                    )

                }

                pricemonthly = 0;
                priceyearly = 0;

                if (thisField eq "pricemonthly") {
                    pricemonthly = evaluate("pricemonthly_#thisCurrencyID#");
                    if (isNumeric(pricemonthly)) {
                        queryExecute(
                            options = {datasource = application.datasource},
                            params = {
                                planID: {type: "numeric", value: form.edit_prices},
                                thisCurrencyID: {type: "numeric", value: thisCurrencyID},
                                pricemonthly: {type: "decimal", value: pricemonthly, scale: 2}

                            },
                            sql = "
                                UPDATE plan_prices
                                SET decPriceMonthly = :pricemonthly
                                WHERE intPlanID = :planID
                                AND intCurrencyID = :thisCurrencyID
                            "
                        )
                    }
                }

                if (thisField eq "priceyearly") {
                    priceyearly = evaluate("priceyearly_#thisCurrencyID#");
                    if (isNumeric(priceyearly)) {
                        queryExecute(
                            options = {datasource = application.datasource},
                            params = {
                                planID: {type: "numeric", value: form.edit_prices},
                                thisCurrencyID: {type: "numeric", value: thisCurrencyID},
                                priceyearly: {type: "decimal", value: priceyearly, scale: 2}
                            },
                            sql = "
                                UPDATE plan_prices
                                SET decPriceYearly = :priceyearly
                                WHERE intPlanID = :planID
                                AND intCurrencyID = :thisCurrencyID
                            "
                        )
                    }
                }
            }
        }

        vat = 0;
        type = 1;
        isNetto = 0;
        onRequest = 0;
        if (isNumeric(form.vat)) {
            vat = form.vat;
        }
        if (isNumeric(form.type)) {
            type = form.type;
        }
        if (structKeyExists(form, "netto")) {
            isNetto = 1;
        }
        if (structKeyExists(form, "request")) {
            onRequest = 1;
        }

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                planID: {type: "numeric", value: form.edit_prices},
                vat: {type: "decimal", value: vat, scale: 2},
                type: {type: "numeric", value: type},
                isNetto: {type: "boolean", value: isNetto},
                onRequest: {type: "boolean", value: onRequest}
            },
            sql = "
                UPDATE plan_prices
                SET decVat = :vat,
                    intVatType = :type,
                    blnIsNet = :isNetto,
                    blnOnRequest = :onRequest
                WHERE intPlanID = :planID
            "
        )

        getAlert('Prices saved.');
        location url="#application.mainURL#/sysadmin/plan/edit/#form.edit_prices#?tab=prices" addtoken="false";

    }

}



if (structKeyExists(form, "new_feature")) {

    qNexPrio = queryExecute(
        options = {datasource = application.datasource},
        sql = "
            SELECT COALESCE(MAX(intPrio),0)+1 as nextPrio
            FROM plan_features
        "
    )

    param name="form.feature_name" default="";
    param name="form.feature_variable" default="";
    param name="form.description" default="";
    param name="category" default=0;

    if (structKeyExists(form, "category")) {
        category = 1;
        form.feature_variable = "";
    }

    variableExists = false;

    if( len(trim(form.feature_variable))){

        chkName = queryExecute(
            options = {
                datasource = application.datasource
            },
            params = {
                customvariable: {type: "varchar", value: form.feature_variable}
            },
            sql = "
                SELECT intPlanFeatureID FROM plan_features
                WHERE strVariable = :customvariable
            "
        );

        if(chkName.recordCount){
            variableExists = true;
        }

    }


    if( !variableExists ){

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    feature_name: {type: "nvarchar", value: form.feature_name},
                    feature_variable: {type: "varchar", value: trim(form.feature_variable)},
                    description: {type: "nvarchar", value: form.description},
                    category: {type: "boolean", value: category},
                    nextPrio: {type: "numeric", value: qNexPrio.nextPrio}
                },
                sql = "
                    INSERT INTO plan_features (strFeatureName, strDescription, strVariable, blnCategory, intPrio)
                    VALUES (:feature_name, :description, :feature_variable, :category, :nextPrio)
                "
            )

            getAlert('Feature saved.');

        } catch (any e) {

            getAlert(e.message, 'danger');

        }

    }else{
        getAlert('Variable name already exists. Please choose another name.', 'danger');
    }

    location url="#application.mainURL#/sysadmin/planfeatures" addtoken="false";

}


if (structKeyExists(form, "edit_feature")) {

    if (isNumeric(form.edit_feature)) {

        param name="form.feature_name" default="";
        param name="form.feature_variable" default="";
        param name="form.description" default="";
        param name="category" default=0;

        if (structKeyExists(form, "category")) {
            category = 1;
            form.feature_variable = "";
        }

        variableExists = false;

        if( len(trim(form.feature_variable))){

            chkName = queryExecute(
                options = {
                    datasource = application.datasource
                },
                params = {
                    featureID: {type: "numeric", value: form.edit_feature},
                    customvariable: {type: "varchar", value: form.feature_variable}
                },
                sql = "
                    SELECT intPlanFeatureID FROM plan_features
                    WHERE strVariable = :customvariable
                    AND intPlanFeatureID != :featureID
                "
            );

            if(chkName.recordCount){
                variableExists = true;
            }

        }


        if( !variableExists ){

            try {

                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        featureID: {type: "numeric", value: form.edit_feature},
                        feature_name: {type: "nvarchar", value: trim(form.feature_name)},
                        feature_variable: {type: "varchar", value: trim(form.feature_variable)},
                        description: {type: "nvarchar", value: form.description},
                        category: {type: "boolean", value: category}
                    },
                    sql = "
                        UPDATE plan_features
                        SET strFeatureName = :feature_name,
                            strDescription = :description,
                            blnCategory = :category,
                            strVariable = :feature_variable
                        WHERE intPlanFeatureID = :featureID
                    "
                )

                getAlert('Feature updated.');

            } catch (any e) {

                getAlert(e.message, 'danger');

            }

        }else{
            getAlert('Variable name already exists. Please choose another name.', 'danger');
        }

        location url="#application.mainURL#/sysadmin/planfeatures" addtoken="false";

    }

}


if (structKeyExists(url, "delete_feature")) {

    if (isNumeric(url.delete_feature)) {

        qFeature = queryExecute(
            options = {datasource = application.datasource},
            params = {
                featureID: {type: "numeric", value: url.delete_feature}
            },
            sql = "
                SELECT intPrio
                FROM plan_features
                WHERE intPlanFeatureID = :featureID
            "
        )

        try {

            queryExecute(
                options = {datasource = application.datasource},
                params = {
                    featureID: {type: "numeric", value: url.delete_feature},
                    currPrio: {type: "numeric", value: qFeature.intPrio}
                },
                sql = "
                    DELETE FROM plan_features WHERE intPlanFeatureID = :featureID;
                    UPDATE plan_features SET intPrio = intPrio-1 WHERE intPrio > :currPrio
                "
            )

            getAlert('Feature deleted successfully!', 'success');


        } catch (any e) {

            getAlert(e.message, 'danger');

        }

        location url="#application.mainURL#/sysadmin/planfeatures" addtoken="false";


    }

}


if (structKeyExists(form, "edit_features")) {

    if (isNumeric(form.edit_features)) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                planID: {type: "numeric", value: form.edit_features}
            },
            sql = "
                UPDATE plans_plan_features
                SET blnCheckmark = 0
                WHERE intPlanID = :planID
            "
        )

        cfloop( list = form.fieldnames, index = "f" ) {

            thisFeatureID = listLast(f, "_");
            thisField = listFirst(f, "_");

            if (thisField neq "edit") {

                // Look if we find an entry in the table
                qCheckFeature = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        planID: {type: "numeric", value: form.edit_features},
                        featureID: {type: "numeric", value: thisFeatureID}
                    },
                    sql = "
                        SELECT intPlanFeatureID
                        FROM plans_plan_features
                        WHERE intPlanID = :planID
                        AND intPlanFeatureID = :featureID
                    "
                )

                if (!qCheckFeature.recordCount) {

                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            planID: {type: "numeric", value: form.edit_features},
                            featureID: {type: "numeric", value: thisFeatureID}
                        },
                        sql = "
                            INSERT INTO plans_plan_features (intPlanID, intPlanFeatureID)
                            VALUES (:planID, :featureID)
                        "
                    )

                }

                checkmark = 0;
                thisText = "";

                if (thisField eq "checkmark") {
                    checkmark = evaluate("checkmark_#thisFeatureID#");

                    if (checkmark eq "on") {
                        checkmark = 1;
                    }
                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            planID: {type: "numeric", value: form.edit_features},
                            thisFeatureID: {type: "numeric", value: thisFeatureID},
                            checkmark: {type: "boolean", value: checkmark}
                        },
                        sql = "
                            UPDATE plans_plan_features
                            SET blnCheckmark = :checkmark
                            WHERE intPlanID = :planID
                            AND intPlanFeatureID = :thisFeatureID
                        "
                    )
                }
                if (thisField eq "text") {
                    thisText = evaluate("text_#thisFeatureID#");
                    queryExecute(
                        options = {datasource = application.datasource},
                        params = {
                            planID: {type: "numeric", value: form.edit_features},
                            thisFeatureID: {type: "numeric", value: thisFeatureID},
                            thisText: {type: "nvarchar", value: thisText}
                        },
                        sql = "
                            UPDATE plans_plan_features
                            SET strValue = :thisText
                            WHERE intPlanID = :planID
                            AND intPlanFeatureID = :thisFeatureID
                        "
                    )
                }

            }

        }

        getAlert('Features saved.');
        location url="#application.mainURL#/sysadmin/plan/edit/#form.edit_features#?tab=features" addtoken="false";

    }

}



if (structKeyExists(form, "plan_modules")) {

    if (isNumeric(form.plan_modules)) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                planID: {type: "numeric", value: form.plan_modules}
            },
            sql = "
                DELETE FROM plans_modules
                WHERE intPlanID = :planID
            "
        )

        if (structKeyExists(form, "moduleID")) {

            cfloop( list = form.moduleID, index = "i" ) {
                queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        planID: {type: "numeric", value: form.plan_modules},
                        moduleID: {type: "numeric", value: i}
                    },
                    sql = "
                        INSERT INTO plans_modules (intPlanID, intModuleID)
                        VALUES (:planID, :moduleID)
                    "
                )
            }

        }

        getAlert('Modules saved.');
        location url="#application.mainURL#/sysadmin/plan/edit/#form.plan_modules#?tab=modules" addtoken="false";

    }

}




// ---- Edit booked plan or book via sysadmin

if (structKeyExists(url, "booking")) {

    param name="url.b" default=0;
    param name="url.c" default=0;
    param name="url.p" default=0;
    param name="url.r" default="";

    // Get some customer data
    customerData = application.objCustomer.getCustomerData(url.c);
    custLanguage = customerData.language;
    custCurrency = customerData.currencyStruct.iso;
    custCurrencyID = customerData.currencyStruct.id;


    // Edit the booked period
    if (structKeyExists(url, "period")) {

        bookingStruct = structNew();
        bookingStruct['bookingID'] = url.b;

        if (structKeyExists(form, "start_date") and dateFormat(form.start_date, "yyyy-mm-dd") <= dateFormat(now(), "yyyy-mm-dd")) {
            bookingStruct['dateStart'] = form.start_date;
        }
        if (structKeyExists(form, "end_date") and dateFormat(form.end_date, "yyyy-mm-dd") >= dateFormat(now(), "yyyy-mm-dd")) {
            bookingStruct['dateEnd'] = form.end_date;
        }

        updateBooking = new backend.core.com.book('plan', custLanguage).updateBooking(bookingStruct);

        getAlert('Plan period saved.');
        location url="#application.mainURL#/sysadmin/customers/details/#url.c###plans" addtoken="false";

    }


    // Cancel a booked plan
    if (structKeyExists(url, "cancel")) {

        // Cancel plan
        cancelPlan = new backend.core.com.cancel(customerID=url.c, thisID=url.p, what='plan').cancel();

        if (cancelPlan.success) {
            getAlert('Plan canceled. The schedule task will do the rest.');
        } else {
            getAlert(cancelPlan.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/customers/details/#url.c###plans" addtoken="false";

    }


    // Revoke cancellation
    if (structKeyExists(url, "revoke")) {

        // Cancel module
        revoke = new backend.core.com.cancel(customerID=url.c, thisID=url.p, what='plan').revoke();

        if (revoke.success) {
            getAlert('Cancellation revoked');
        } else {
            getAlert(revoke.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/customers/details/#url.c###plans" addtoken="false";

    }


    // Book plan right now (for free)
    if (structKeyExists(url, "free")) {

        // Get plan infos of the plan to be booked
        planDetails = new backend.core.com.plans(language=custLanguage, currencyID=custCurrencyID).getPlanDetail(url.p);

        structUpdate(planDetails, "priceMonthly", 0);
        structUpdate(planDetails, "priceMonthlyAfterVAT", 0);
        structUpdate(planDetails, "priceYearly", 0);
        structUpdate(planDetails, "priceYearlyAfterVAT", 0);
        structUpdate(planDetails, "testDays", 0);

        structInsert(planDetails, "priceOnetime", 0);
        structInsert(planDetails, "priceOneTimeAfterVAT", 0);

        // Make booking right now
        makeBooking = new backend.core.com.book('plan', custLanguage).checkBooking(customerID=url.c, bookingData=planDetails, recurring='onetime', makeBooking=true);

        if (makeBooking.success) {
            getAlert('Plan activated for free.');
        } else {
            getAlert(makeBooking.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/customers/details/#url.c###plans" addtoken="false";

    }


    // Make invoice which the client can then pay to activate the plan
    if (structKeyExists(url, "invoice")) {

        // Get plan infos of the plan to be booked
        planDetails = new backend.core.com.plans(language=custLanguage, currencyID=custCurrencyID).getPlanDetail(url.p);

        // Set the test days to 0 in order to make the invoice immediately
        structUpdate(planDetails, "testDays", 0);

        // Make booking and invoice right now
        makeBooking = new backend.core.com.book('plan', custLanguage).checkBooking(customerID=url.c, bookingData=planDetails, recurring=url.r, makeBooking=true, makeInvoice=true, chargeInvoice=false);

        if (makeBooking.success) {
            getAlert('The invoice was successfully created. You can now make changes if you wish. If all is well, you can send it to the customer by clicking on the email button.');
            session.comingfrom = "sysadmin_plans";
            location url="#application.mainURL#/sysadmin/invoice/edit/#makeBooking.invoiceID#" addtoken="false";
        } else {
            getAlert(makeBooking.message, 'danger');
            location url="#application.mainURL#/sysadmin/customers/details/#url.c###plans" addtoken="false";
        }




    }


    // Activate the test time
    if (structKeyExists(url, "test")) {

        // Get plan infos of the plan to be booked
        planDetails = new backend.core.com.plans(language=custLanguage, currencyID=custCurrencyID).getPlanDetail(url.p);

        // Make booking with test phase
        makeBooking = new backend.core.com.book('plan', custLanguage).checkBooking(customerID=url.c, bookingData=planDetails, recurring="test", makeBooking=true, makeInvoice=false, chargeInvoice=false);

        if (makeBooking.success) {
            getAlert('The plan has been successfully activated.');
        } else {
            getAlert(makeBooking.message, 'danger');
        }

        location url="#application.mainURL#/sysadmin/customers/details/#url.c###plans" addtoken="false";


    }


    // Change the cycle of a module
    if (structKeyExists(url, "change")) {

        // Get plan infos of the plan to be booked
        planDetails = new backend.core.com.plans(language=custLanguage, currencyID=custCurrencyID).getPlanDetail(url.p);

        objBooking = new backend.core.com.book('plan', custLanguage);

        // Check booking
        checkBooking = objBooking.checkBooking(customerID=url.c, bookingData=planDetails, recurring=url.r, makeBooking=false);


        // If the amount to pay is greater than 0, make invoice
        if (checkBooking.amountToPay gt 0) {

            // Make booking and invoice right now
            makeBooking = objBooking.checkBooking(customerID=url.c, bookingData=planDetails, recurring=url.r, makeBooking=true, makeInvoice=true, chargeInvoice=false);

            if (makeBooking.success) {
                getAlert('The invoice was successfully created, check it out!');
            } else {
                getAlert(makeBooking.message, 'danger');
            }

            location url="#application.mainURL#/sysadmin/invoice/edit/#makeBooking.invoiceID#" addtoken="false";

        } else {

            // Save the new plan
            makeBooking = objBooking.checkBooking(customerID=url.c, bookingData=planDetails, recurring=url.r, makeBooking=true, makeInvoice=false, chargeInvoice=false);

            if (makeBooking.success) {
                getAlert('The cycle was changed.');
            } else {
                getAlert(makeBooking.message, 'danger');
            }

            location url="#application.mainURL#/sysadmin/customers/details/#url.c###plans" addtoken="false";

        }


    }


    // Delete the plan (the booking)
    if (structKeyExists(url, "delete")) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                bookingID: {type: "numeric", value: url.b},
                planID: {type: "numeric", value: url.p},
                customerID: {type: "numeric", value: url.c}
            },
            sql = "

                DELETE FROM bookings
                WHERE intCustomerID = :customerID
                AND intPlanID = :planID;

                DELETE FROM invoices
                WHERE intBookingID = :bookingID
                AND intPaymentStatusID != 3
                AND intPaymentStatusID != 4;

            "
        )

        getAlert('The plan was withdrawn from the customer.');

        location url="#application.mainURL#/sysadmin/customers/details/#url.c###plans" addtoken="false";


    }


}


</cfscript>