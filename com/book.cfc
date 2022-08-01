
component displayname="book" output="false" {

    public any function init(string type, string language) {

        param name="arguments.type" default="plan";
        variables.type = arguments.type;

        param name="arguments.language" default="en";
        variables.language = arguments.language;

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
            local.argsJSon['recurring'] = "monthly";
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


    // We prepare the booking requested by the customer and return the data. If required, an entry can be made in the DB immediately.
    public struct function checkBooking(required numeric customerID, required struct bookingData, required string recurring, boolean makeBooking, boolean makeInvoice) {

        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";

        local.getTrans = application.objGlobal.getTrans;
        local.bookingData = arguments.bookingData;
        local.planID = "";
        local.moduleID = "";
        local.startDate = "";
        local.endDate = "";
        local.recurring = arguments.recurring;
        local.canBook = true;
        local.message = "";
        local.priceBeforeVat = 0;
        local.amountToPay = 0;
        local.status = "";
        local.bookingID = 0;
        local.invoiceID = 0;
        local.insertPlan = false;
        local.insertModule = false;

        local.getTime = new com.time(arguments.customerID);

        local.argsReturnValue = structNew();

        local.messageStruct = structNew();
        local.messageStruct['title'] = "";
        local.messageStruct['message'] = "";

        local.invoiceTitle = "";
        local.invoicePositionTitle = "";
        local.invoiceCurrency = "";
        local.invoiceLanguage = "";

        local.objPrices = new com.prices(vat=bookingData.vat, vat_type=bookingData.vatType, isnet=bookingData.isNet);


        if (structKeyExists(local.bookingData, "planID")) {
            local.planID = local.bookingData.planID;
        }
        if (structKeyExists(local.bookingData, "moduleID")) {
            local.moduleID = local.bookingData.moduleID;
        }
        if (structKeyExists(local.bookingData, "currencyID") and isNumeric(local.bookingData.currencyID)) {
            local.currencyID = local.bookingData.currencyID;
        } else {
            local.currencyID = getCurrency().id;
        }


        // We have to book a plan
        if (local.planID gt 0) {

            // Get the current plan of the customer
            local.objPlans = new com.plans(currencyID=local.currencyID);
            local.currentPlan = local.objPlans.getCurrentPlan(arguments.customerID);

            // It's the first plan
            if (!len(trim(local.currentPlan.status))) {

                local.insertPlan = true;

                local.startDate = dateFormat(now(), "yyyy-mm-dd");

                // Do we have to provide any test days?
                if (local.bookingData.testDays gt 0) {

                    local.endDate = dateFormat(dateAdd("d", local.bookingData.testDays, local.startDate), "yyyy-mm-dd");
                    local.status = "test";
                    local.recurring = "test";

                } else {

                    // Is it a free plan?
                    if (local.bookingData.itsFree) {

                         local.recurring = "onetime";
                         local.status = "free";

                         // Set the end time to a date that will probably never be reached
                         local.endDate = dateFormat(createDate(3000, 1, 1), "yyyy-mm-dd");

                    } else {

                        // Define the end date
                        if (local.recurring eq "monthly") {
                            local.endDate = dateFormat(dateAdd("m", 1, local.startDate), "yyyy-mm-dd");
                            local.priceBeforeVat = local.bookingData.priceMonthly;
                        } else if (local.recurring eq "yearly") {
                            local.endDate = dateFormat(dateAdd("yyyy", 1, local.startDate), "yyyy-mm-dd");
                            local.priceBeforeVat = local.bookingData.priceYearly;
                        }

                        local.amountToPay = local.objPrices.getPriceData(local.priceBeforeVat).priceAfterVAT;

                        local.status = "active";

                         // Set some invoice variables
                        local.invoiceTitle = local.getTrans('titPlan') & ": " & local.bookingData.planName;
                        local.invoicePositionTitle = local.bookingData.planName & ' ' & lsDateFormat(local.getTime.utc2local(utcDate=local.startDate)) & ' - ' & lsDateFormat(local.getTime.utc2local(utcDate=local.endDate));
                        local.invoiceCurrency = local.bookingData.currency;
                        local.invoiceLanguage = variables.language;

                    }

                }


            // The customer has already a plan
            } else {


                // If the user is in test time
                if (local.currentPlan.recurring eq "test") {

                    // Define the start date
                    local.startDate = dateFormat(now(), "yyyy-mm-dd");

                    // Check whether the customer has registered more users than the new plan provides
                    if ((local.bookingData.maxUsers gt 0) and (application.objUser.getAllUsers(arguments.customerID).recordCount gt local.bookingData.maxUsers)) {

                        local.canBook = false;
                        local.usersToDelete = application.objUser.getAllUsers(arguments.customerID).recordCount - local.bookingData.maxUsers;

                        local.messageStruct['title'] = local.getTrans('titDowngradeNotPossible');
                        local.messageStruct['message'] = local.getTrans('txtDowngradeNotPossibleText') & " " & local.usersToDelete;
                        local.messageStruct['button'] = local.getTrans('btnToTheUsers');
                        local.messageStruct['link'] = application.mainURL & "/account-settings/users";

                    } else {

                        // Is it a free plan?
                        if (local.bookingData.itsFree) {

                            local.recurring = "onetime";
                            local.status = "free";

                            // Set the end time to a date that will probably never be reached
                            local.endDate = dateFormat(createDate(3000, 1, 1), "yyyy-mm-dd");

                        }


                        // Define the end date
                        if (local.recurring eq "monthly") {
                            local.endDate = dateFormat(dateAdd("m", 1, local.startDate), "yyyy-mm-dd");
                            local.priceBeforeVat = local.bookingData.priceMonthly;
                        } else if (local.recurring eq "yearly") {
                            local.endDate = dateFormat(dateAdd("yyyy", 1, local.startDate), "yyyy-mm-dd");
                            local.priceBeforeVat = local.bookingData.priceYearly;
                        }

                        local.amountToPay = local.objPrices.getPriceData(local.priceBeforeVat).priceAfterVAT;

                        local.messageStruct['title'] = local.getTrans('titUpgrade');
                        local.messageStruct['message'] = local.getTrans('txtYouAreUpgrading');
                        local.messageStruct['button'] = local.getTrans('btnYesUpgrade');

                        if (local.amountToPay gt 0) {

                            local.status = "active";

                            // Set some invoice variables
                            local.invoiceTitle = local.getTrans('titPlan') & ": " & local.bookingData.planName;
                            local.invoicePositionTitle = local.bookingData.planName & ' ' & lsDateFormat(local.getTime.utc2local(utcDate=local.startDate)) & ' - ' & lsDateFormat(local.getTime.utc2local(utcDate=local.endDate));
                            local.invoiceCurrency = local.bookingData.currency;
                            local.invoiceLanguage = variables.language;

                        }

                    }


                // If the user has an active plan it must be an up- or downgrade
                } else if (local.currentPlan.status eq "active" or local.currentPlan.status eq "free") {

                    // The customer wants to change the cycle (same plan)
                    if (local.currentPlan.planID eq local.bookingData.planID) {

                        // From monthly to yearly
                        if (local.currentPlan.recurring eq "monthly" and local.recurring eq "yearly") {

                            // Define the start date
                            local.startDate = dateFormat(now(), "yyyy-mm-dd");

                            // Define the end date
                            local.endDate = dateFormat(dateAdd("yyyy", 1, local.startDate), "yyyy-mm-dd");
                            local.planPrice = local.bookingData.priceYearly;

                            // Get the diffrence to pay today
                            local.calculateUpgrade = local.objPlans.calculateUpgrade(arguments.customerID, local.planID, local.recurring);
                            if (structKeyExists(local.calculateUpgrade, "toPayNow")) {
                                local.priceBeforeVat = local.calculateUpgrade.toPayNow;
                            } else {
                                local.priceBeforeVat = local.planPrice;
                            }

                            local.amountToPay = local.objPrices.getPriceData(local.priceBeforeVat).priceAfterVAT;

                            local.status = "active";

                            local.messageStruct['title'] = local.getTrans('titCycleChange');
                            local.messageStruct['message'] = local.getTrans('txtYouAreUpgrading');
                            local.messageStruct['button'] = local.getTrans('btnYesUpgrade');

                            // Set some invoice variables
                            local.invoiceTitle = local.getTrans('titCycleChange') & " " & lcase(local.getTrans('txtMonthly')) & "/" & lcase(local.getTrans('txtYearly'));
                            local.invoicePositionTitle = local.bookingData.planName & ' ' & lsDateFormat(local.getTime.utc2local(utcDate=local.startDate)) & ' - ' & lsDateFormat(local.getTime.utc2local(utcDate=local.endDate));
                            local.invoiceCurrency = local.bookingData.currency;
                            local.invoiceLanguage = variables.language;


                        } else {


                            // Define the start date (a downgrade begins at the end of the current plan)
                            local.startDate = dateFormat(dateAdd("d", 1, local.currentPlan.endDate), "yyyy-mm-dd");

                            // Define the end date
                            local.endDate = dateFormat(dateAdd("m", 1, local.startDate), "yyyy-mm-dd");

                            local.status = "waiting";

                            local.messageStruct['title'] = local.getTrans('titCycleChange');
                            local.messageStruct['message'] = local.getTrans('txtYouAreDowngrading') & " " & lsDateFormat(application.getTime.utc2local(utcDate=local.startDate));
                            local.messageStruct['button'] = local.getTrans('btnYesDowngrade');


                        }



                    } else {


                        // Upgrade
                        if (local.bookingData.priceMonthly gt local.currentPlan.priceMonthly) {

                            // Define the start date
                            local.startDate = dateFormat(now(), "yyyy-mm-dd");

                            // Define the end date
                            if (local.recurring eq "monthly") {
                                local.endDate = dateFormat(dateAdd("m", 1, local.startDate), "yyyy-mm-dd");
                                local.planPrice = local.bookingData.priceMonthly;
                            } else if (local.recurring eq "yearly") {
                                local.endDate = dateFormat(dateAdd("yyyy", 1, local.startDate), "yyyy-mm-dd");
                                local.planPrice = local.bookingData.priceYearly;
                            }

                            local.status = "active";

                            // Get the amount to pay
                            local.calculateUpgrade = local.objPlans.calculateUpgrade(arguments.customerID, local.planID, local.recurring);
                            if (structKeyExists(local.calculateUpgrade, "toPayNow")) {
                                local.priceBeforeVat = local.calculateUpgrade.toPayNow;
                            } else {
                                local.priceBeforeVat = local.planPrice;
                            }

                            local.amountToPay = local.objPrices.getPriceData(local.priceBeforeVat).priceAfterVAT;

                            local.messageStruct['title'] = local.getTrans('titUpgrade');
                            local.messageStruct['message'] = local.getTrans('txtYouAreUpgrading');
                            local.messageStruct['button'] = local.getTrans('btnYesUpgrade');

                            // Set some invoice variables
                            local.invoiceTitle = local.getTrans('titUpgrade') & ": " & local.bookingData.planName;
                            local.invoicePositionTitle = local.bookingData.planName & ' ' & lsDateFormat(local.getTime.utc2local(utcDate=local.startDate)) & ' - ' & lsDateFormat(local.getTime.utc2local(utcDate=local.endDate));
                            local.invoiceCurrency = local.bookingData.currency;
                            local.invoiceLanguage = variables.language;



                        // Downgrade
                        } else {


                            // Check whether the customer has registered more users than the new plan provides
                            if ((local.bookingData.maxUsers gt 0) and (application.objUser.getAllUsers(arguments.customerID).recordCount gt local.bookingData.maxUsers)) {

                                local.canBook = false;
                                local.usersToDelete = application.objUser.getAllUsers(arguments.customerID).recordCount - local.bookingData.maxUsers;

                                local.messageStruct['title'] = local.getTrans('titDowngradeNotPossible');
                                local.messageStruct['message'] = local.getTrans('txtDowngradeNotPossibleText') & " " & local.usersToDelete;
                                local.messageStruct['button'] = local.getTrans('btnToTheUsers');
                                local.messageStruct['link'] = application.mainURL & "/account-settings/users";

                            } else {


                                // Define the start date (a downgrade begins at the end of the current plan)
                                local.startDate = dateFormat(dateAdd("d", 1, local.currentPlan.endDate), "yyyy-mm-dd");

                                // Define the end date
                                if (local.recurring eq "monthly") {
                                    local.endDate = dateFormat(dateAdd("m", 1, local.startDate), "yyyy-mm-dd");
                                } else if (local.recurring eq "yearly") {
                                    local.endDate = dateFormat(dateAdd("yyyy", 1, local.startDate), "yyyy-mm-dd");
                                }

                                local.status = "waiting";


                                local.messageStruct['title'] = local.getTrans('titDowngrade');
                                local.messageStruct['message'] = local.getTrans('txtYouAreDowngrading') & " " & lsDateFormat(application.getTime.utc2local(utcDate=local.startDate));
                                local.messageStruct['button'] = local.getTrans('btnYesDowngrade');


                            }

                        }

                    }


                }

            }



        // We have to book a module
        } else if (local.moduleID gt 0) {

            // Has the module already been booked and is the test phase over?
            local.qCheckTestPhase = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID},
                    moduleID: {type: "numeric", value: local.moduleID}
                },
                sql = "
                    SELECT intBookingID
                    FROM bookings
                    WHERE intCustomerID = :customerID
                    AND intModuleID = :moduleID
                    AND strRecurring = 'test'
                "
            )

            if (local.qCheckTestPhase.recordCount) {

                // Delete the module
                queryExecute (
                    options = {datasource = application.datasource},
                    params = {
                        customerID: {type: "numeric", value: arguments.customerID},
                        bookingID: {type: "numeric", value: local.qCheckTestPhase.intBookingID}
                    },
                    sql = "
                        DELETE FROM bookings
                        WHERE intBookingID = :bookingID
                    "
                )

                local.bookingData.testDays = 0;

            }

            // At the moment we can not change any module bookings, so we insert each module
            local.insertModule = true;

            local.startDate = dateFormat(now(), "yyyy-mm-dd");

            // Do we have to provide any test days?
            if (local.bookingData.testDays gt 0) {

                local.endDate = dateFormat(dateAdd("d", local.bookingData.testDays, local.startDate), "yyyy-mm-dd");
                local.status = "test";
                local.recurring = "test";

            } else {

                // Is it a free module?
                if (local.bookingData.priceYearly eq 0 and local.bookingData.priceMonthly eq 0 and local.bookingData.priceOnetime eq 0) {

                    local.recurring = "onetime";
                    local.status = "free";

                    // Set the end time to a date that will probably never be reached
                    local.endDate = dateFormat(createDate(3000, 1, 1), "yyyy-mm-dd");

                } else {

                    // Define the end date
                    if (local.recurring eq "monthly") {
                        local.endDate = dateFormat(dateAdd("m", 1, local.startDate), "yyyy-mm-dd");
                        local.priceBeforeVat = local.bookingData.priceMonthly;
                        local.invoicePositionTitle = local.bookingData.name & ' ' & lsDateFormat(local.getTime.utc2local(utcDate=local.startDate)) & ' - ' & lsDateFormat(local.getTime.utc2local(utcDate=local.endDate));
                    } else if (local.recurring eq "yearly") {
                        local.endDate = dateFormat(dateAdd("yyyy", 1, local.startDate), "yyyy-mm-dd");
                        local.priceBeforeVat = local.bookingData.priceYearly;
                        local.invoicePositionTitle = local.bookingData.name & ' ' & lsDateFormat(local.getTime.utc2local(utcDate=local.startDate)) & ' - ' & lsDateFormat(local.getTime.utc2local(utcDate=local.endDate));
                    } else {
                        local.endDate = dateFormat(createDate(3000, 1, 1), "yyyy-mm-dd");
                        local.priceBeforeVat = local.bookingData.priceOnetime;
                        local.invoicePositionTitle = local.getTrans('titModule') & ": " & local.bookingData.name;
                    }

                    local.amountToPay = local.objPrices.getPriceData(local.priceBeforeVat).priceAfterVAT;

                    // Set some invoice variables
                    local.invoiceTitle = local.getTrans('titModule') & ": " & local.bookingData.name;
                    local.invoiceCurrency = local.bookingData.currency;
                    local.invoiceLanguage = variables.language;

                    local.status = "active";

                }

            }


        // Neither plan nor module
        } else {

            local.argsReturnValue['message'] = "Neither plan nor module found!";
            return local.argsReturnValue;

        }

        // If desired, we save the plan or module
        if (structKeyExists(arguments, "makeBooking") and arguments.makeBooking) {


            // If there is a new plan or new module
            if (local.insertPlan or local.insertModule) {

                queryExecute (
                    options = {datasource = application.datasource, result="newID"},
                    params = {
                        customerID: {type: "numeric", value: arguments.customerID},
                        planID: {type: "numeric", value: local.planID},
                        moduleID: {type: "numeric", value: local.moduleID},
                        dateStart: {type: "date", value: local.startDate},
                        dateEnd: {type: "date", value: local.endDate},
                        recurring: {type: "varchar", value: local.recurring},
                        status: {type: "varchar", value: local.status}
                    },
                    sql = "
                        INSERT INTO bookings (intCustomerID, intPlanID, intModuleID, dteStartDate, dteEndDate, strRecurring, strStatus)
                        VALUES (:customerID, :planID, :moduleID, :dateStart, :dateEnd, :recurring, :status)
                    "
                )

                local.bookingID = newID.generated_key;

            }


            // If the new status is waiting
            if (local.status eq "waiting") {

                // Let's have a look if there is already a waiting entry
                local.checkWaiting = queryExecute (
                    options = {datasource = application.datasource},
                    params = {
                        customerID: {type: "numeric", value: arguments.customerID}
                    },
                    sql = "
                        SELECT intBookingID
                        FROM bookings
                        WHERE intCustomerID = :customerID
                        AND strStatus = 'waiting'
                    "
                )

                // Update
                if (local.checkWaiting.recordCount) {


                    // Update the existing booking
                    local.updateStruct = structNew();
                    local.updateStruct['customerID'] = arguments.customerID;
                    local.updateStruct['planID'] = local.planID;
                    local.updateStruct['dateStart'] = local.startDate;
                    local.updateStruct['dateEnd'] = local.endDate;
                    local.updateStruct['recurring'] = local.recurring;
                    local.updateStruct['status'] = local.status;
                    local.updateStruct['bookingID'] = local.checkWaiting.intBookingID;

                    local.bookingID = updateBooking(local.updateStruct);


                // Insert
                } else {

                    queryExecute (
                        options = {datasource = application.datasource, result="newID"},
                        params = {
                            customerID: {type: "numeric", value: arguments.customerID},
                            planID: {type: "numeric", value: local.planID},
                            moduleID: {type: "numeric", value: local.moduleID},
                            dateStart: {type: "date", value: local.startDate},
                            dateEnd: {type: "date", value: local.endDate},
                            recurring: {type: "varchar", value: local.recurring},
                            status: {type: "varchar", value: local.status}
                        },
                        sql = "
                            INSERT INTO bookings (intCustomerID, intPlanID, intModuleID, dteStartDate, dteEndDate, strRecurring, strStatus)
                            VALUES (:customerID, :planID, :moduleID, :dateStart, :dateEnd, :recurring, :status)
                        "
                    )

                    local.bookingID = newID.generated_key;

                }


            // The new status is NOT waiting (only plans)
            } else {

                if (local.planID gt 0) {

                    // DELETE the waiting entry if exists
                    local.qCheckBooking = queryExecute (
                        options = {datasource = application.datasource},
                        params = {
                            customerID: {type: "numeric", value: arguments.customerID}
                        },
                        sql = "
                            DELETE FROM bookings
                            WHERE intCustomerID = :customerID
                            AND strStatus = 'waiting'
                            AND intPlanID > 0
                        "
                    )

                    // Get the ID of the main entry
                    local.qBookings = queryExecute (
                        options = {datasource = application.datasource},
                        params = {
                            customerID: {type: "numeric", value: arguments.customerID}
                        },
                        sql = "
                            SELECT intBookingID
                            FROM bookings
                            WHERE intCustomerID = :customerID
                            AND intPlanID > 0
                        "
                    )

                    // Update the existing booking
                    local.updateStruct = structNew();
                    local.updateStruct['customerID'] = arguments.customerID;
                    local.updateStruct['planID'] = local.planID;
                    local.updateStruct['dateStart'] = local.startDate;
                    local.updateStruct['dateEnd'] = local.endDate;
                    local.updateStruct['recurring'] = local.recurring;
                    local.updateStruct['status'] = local.status;
                    local.updateStruct['bookingID'] = local.qBookings.intBookingID;

                    local.bookingID = updateBooking(local.updateStruct);



                }

            }



            // If desired, we make an invoice and try to charge the amount via Payrexx
            if (structKeyExists(arguments, "makeInvoice") and arguments.makeInvoice) {

                local.objInvoice = new com.invoices();
                local.objPrices = new com.prices(
                    vat=local.bookingData.vat,
                    vat_type=local.bookingData.vatType,
                    isnet=local.bookingData.isNet,
                    language=local.invoiceLanguage,
                    currency=local.invoiceCurrency
                );

                // Make invoice struct
                local.invoiceStruct = structNew();
                local.invoiceStruct['bookingID'] = local.bookingID;
                local.invoiceStruct['customerID'] = arguments.customerID;
                local.invoiceStruct['title'] = local.invoiceTitle;
                local.invoiceStruct['currency'] = local.invoiceCurrency;
                local.invoiceStruct['isNet'] = local.bookingData.isNet;
                local.invoiceStruct['vatType'] = local.bookingData.vatType;
                local.invoiceStruct['paymentStatusID'] = 2;
                local.invoiceStruct['language'] = local.invoiceLanguage;
                local.invoiceStruct['invoiceDate'] = now();
                local.invoiceStruct['dueDate'] = now();

                // Make invoice and get invoice id
                local.newInvoice = local.objInvoice.createInvoice(local.invoiceStruct);

                if (local.newInvoice.success) {
                    local.invoiceID = newInvoice.newInvoiceID;
                } else {
                    local.argsReturnValue['message'] = local.newInvoice.message;
                    local.argsReturnValue['success'] = false;
                    return local.argsReturnValue;
                }

                // Insert a position
                local.posInfo = structNew();
                local.posInfo['invoiceID'] = local.invoiceID;
                local.posInfo['append'] = false;

                local.positionArray = arrayNew(1);

                local.position = structNew();
                local.position[1]['title'] = local.invoicePositionTitle;
                local.position[1]['description'] = local.bookingData.shortDescription;
                local.position[1]['quantity'] = 1;
                local.position[1]['discountPercent'] = 0;
                local.position[1]['vat'] = local.bookingData.vat;
                local.position[1]['price'] = local.priceBeforeVat;
                if (local.recurring eq 'monthly') {
                    local.position[1]['unit'] = local.getTrans('TitMonth', local.invoiceLanguage);
                } else {
                    local.position[1]['unit'] = local.getTrans('TitYear', local.invoiceLanguage);
                }
                arrayAppend(local.positionArray, local.position[1]);
                local.posInfo['positions'] = local.positionArray;

                local.insPositions = local.objInvoice.insertInvoicePositions(local.posInfo);

                if (!local.insPositions.success) {
                    local.objInvoice.deleteInvoice(local.invoiceID);
                    local.argsReturnValue['message'] = local.insPositions.message;
                    local.argsReturnValue['success'] = false;
                    return local.argsReturnValue;
                }

                // Charge the amount now (Payrexx)
                local.chargeNow = local.objInvoice.payInvoice(local.invoiceID);
                if (!local.chargeNow.success) {
                    local.objInvoice.deleteInvoice(local.invoiceID);
                    local.argsReturnValue['message'] = local.chargeNow.message;
                    local.argsReturnValue['success'] = false;
                    return local.argsReturnValue;
                }


            }


        }



        local.argsReturnValue['planID'] = local.planID;
        local.argsReturnValue['moduleID'] = local.moduleID;
        local.argsReturnValue['startDate'] = local.startDate;
        local.argsReturnValue['endDate'] = local.endDate;
        local.argsReturnValue['recurring'] = local.recurring;
        local.argsReturnValue['currencyID'] = local.currencyID;
        local.argsReturnValue['canBook'] = local.canBook;
        local.argsReturnValue['message'] = local.messageStruct;
        local.argsReturnValue['amountToPay'] = local.amountToPay;
        local.argsReturnValue['status'] = local.status;
        local.argsReturnValue['bookingID'] = local.bookingID;
        local.argsReturnValue['invoiceID'] = local.invoiceID;
        local.argsReturnValue['success'] = true;

        return local.argsReturnValue;



    }



    // Update the desired booking
    public numeric function updateBooking(required struct bookingData) {

        if (!structKeyExists(arguments.bookingData, "bookingID")) {
            return 0;
        }

        local.bookingID = arguments.bookingData.bookingID;

        // Get the current data
        local.qBooking = queryExecute (
            options = {datasource = application.datasource},
            params = {
                bookingID: {type: "numeric", value: local.bookingID}
            },
            sql = "
                SELECT *
                FROM bookings
                WHERE intBookingID = :bookingID
            "
        )

        if (structKeyExists(arguments.bookingData, "planID")) {
            local.planID = arguments.bookingData.planID;
        } else {
            local.planID = local.qBooking.intPlanID;
        }
        if (structKeyExists(arguments.bookingData, "dateStart")) {
            local.dateStart = arguments.bookingData.dateStart;
        } else {
            local.dateStart = local.qBooking.dteStartDate;
        }
        if (structKeyExists(arguments.bookingData, "dateEnd")) {
            local.dateEnd = arguments.bookingData.dateEnd;
        } else {
            local.dateEnd = local.qBooking.dteEndDate;
        }
        if (structKeyExists(arguments.bookingData, "recurring")) {
            local.recurring = arguments.bookingData.recurring;
        } else {
            local.recurring = local.qBooking.strRecurring;
        }
        if (structKeyExists(arguments.bookingData, "status")) {
            local.status = arguments.bookingData.status;
        } else {
            local.status = local.qBooking.strStatus;
        }

        queryExecute (
            options = {datasource = application.datasource},
            params = {
                bookingID: {type: "numeric", value: local.bookingID},
                planID: {type: "numeric", value: local.planID},
                dateStart: {type: "date", value: local.dateStart},
                dateEnd: {type: "date", value: local.dateEnd},
                recurring: {type: "varchar", value: local.recurring},
                status: {type: "varchar", value: local.status}
            },
            sql = "
                UPDATE bookings
                SET intPlanID = :planID,
                    dteStartDate = :dateStart,
                    dteEndDate = :dateEnd,
                    strRecurring = :recurring,
                    strStatus = :status
                WHERE intBookingID = :bookingID
            "
        )

        return local.qBooking.intBookingID;

    }



}