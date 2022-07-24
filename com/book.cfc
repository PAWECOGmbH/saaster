
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
        local.amountToPay = 0;
        local.status = "";
        local.bookingID = 0;
        local.invoiceID = 0;
        local.firstPlan = false;
        local.firstModule = false;

        local.getTime = application.getTime;
        local.theDateNow = local.getTime.utc2local(utcDate=now());

        local.argsReturnValue = structNew();

        local.messageStruct = structNew();
        local.messageStruct['title'] = "";
        local.messageStruct['message'] = "";

        local.invoiceTitle = "";
        local.invoicePositionTitle = "";
        local.invoiceCurrency = "";
        local.invoiceLanguage = "";


        //dump(local.bookingData);


        if (structKeyExists(local.bookingData, "planID")) {
            local.planID = local.bookingData.planID;
        }
        if (structKeyExists(local.bookingData, "moduleID")) {
            local.moduleID = local.bookingData.moduleID;
        }
        if (structKeyExists(local.bookingData, "currencyID") and isNumeric(local.bookingData.currencyID)) {
            local.currencyID = local.bookingData.currencyID;
        } else {
            local.currencyID = new com.prices().getCurrency().id;
        }


        // We have to book a plan
        if (local.planID gt 0) {

            // Get the current plan of the customer
            local.objPlans = new com.plans(currencyID=local.currencyID);
            local.currentPlan = local.objPlans.getCurrentPlan(arguments.customerID);


            // It's the first plan
            if (!len(trim(local.currentPlan.status))) {

                local.firstPlan = true;

                local.startDate = dateFormat(local.theDateNow, "yyyy-mm-dd");

                // Do we have to provide any test days?
                if (local.bookingData.testDays gt 0) {

                    local.endDate = dateFormat(dateAdd("d", local.bookingData.testDays, local.startDate), "yyyy-mm-dd");
                    local.status = "test";

                } else {

                    // Is it a free plan?
                    if (local.bookingData.itsFree) {

                         local.recurring = "onetime";
                         local.endDate = dateFormat(createDate(3000, 1, 1), "yyyy-mm-dd");

                    } else {

                        // Define the end date
                        if (local.recurring eq "monthly") {
                            local.endDate = dateFormat(dateAdd("m", 1, local.startDate), "yyyy-mm-dd");
                            local.amountToPay = local.bookingData.priceMonthlyAfterVAT;
                        } else if (local.recurring eq "yearly") {
                            local.endDate = dateFormat(dateAdd("yyyy", 1, local.startDate), "yyyy-mm-dd");
                            local.amountToPay = local.bookingData.priceYearlyAfterVAT;
                        }

                    }

                    local.status = "active";

                    // Set some invoice variables
                    local.invoiceTitle = local.getTrans('titPlan') & ": " & local.bookingData.planName;
                    local.invoicePositionTitle = local.bookingData.planName & ' ' & lsDateFormat(local.getTime.utc2local(utcDate=local.startDate)) & ' - ' & lsDateFormat(local.getTime.utc2local(utcDate=local.endDate));
                    local.invoiceCurrency = local.bookingData.currency;
                    local.invoiceLanguage = variables.language;


                }


            // The customer has already a plan
            } else {


                // If the user is in test time
                if (local.currentPlan.status eq "test") {

                    // Define the start date
                    local.startDate = dateFormat(dateAdd("d", 1, local.currentPlan.endDate), "yyyy-mm-dd");

                    // Define the end date
                    if (local.recurring eq "monthly") {
                        local.endDate = dateFormat(dateAdd("m", 1, local.startDate), "yyyy-mm-dd");
                        local.amountToPay = local.bookingData.priceMonthlyAfterVAT;
                    } else if (local.recurring eq "yearly") {
                        local.endDate = dateFormat(dateAdd("yyyy", 1, local.startDate), "yyyy-mm-dd");
                        local.amountToPay = local.bookingData.priceYearlyAfterVAT;
                    }

                    local.status = "active";

                    // Set some invoice variables
                    local.invoiceTitle = local.getTrans('titPlan') & ": " & local.bookingData.planName;
                    local.invoicePositionTitle = local.bookingData.planName & ' ' & lsDateFormat(local.getTime.utc2local(utcDate=local.startDate)) & ' - ' & lsDateFormat(local.getTime.utc2local(utcDate=local.endDate));
                    local.invoiceCurrency = local.bookingData.currency;
                    local.invoiceLanguage = variables.language;


                // If the user has an active plan it must be an up- or downgrade
                } else if (local.currentPlan.status eq "active") {

                    // The customer wants to change the cycle (same plan)
                    if (local.currentPlan.planID eq local.bookingData.planID) {

                        // From monthly to yearly
                        if (local.currentPlan.recurring eq "monthly" and local.recurring eq "yearly") {

                            // Define the start date
                            local.startDate = dateFormat(local.theDateNow, "yyyy-mm-dd");

                            // Define the end date
                            local.endDate = dateFormat(dateAdd("yyyy", 1, local.startDate), "yyyy-mm-dd");
                            local.planPrice = local.bookingData.priceYearlyAfterVAT;

                            // Get the diffrence to pay today
                            local.calculateUpgrade = local.objPlans.calculateUpgrade(arguments.customerID, local.planID, local.recurring);
                            if (structKeyExists(local.calculateUpgrade, "toPayNow")) {
                                local.amountToPay = local.calculateUpgrade.toPayNow;
                            } else {
                                local.amountToPay = local.planPrice;
                            }

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
                            local.startDate = dateFormat(local.theDateNow, "yyyy-mm-dd");

                            // Define the end date
                            if (local.recurring eq "monthly") {
                                local.endDate = dateFormat(dateAdd("m", 1, local.startDate), "yyyy-mm-dd");
                                local.planPrice = local.bookingData.priceMonthlyAfterVAT;
                            } else if (local.recurring eq "yearly") {
                                local.endDate = dateFormat(dateAdd("yyyy", 1, local.startDate), "yyyy-mm-dd");
                                local.planPrice = local.bookingData.priceYearlyAfterVAT;
                            }

                            local.status = "active";

                            // Get the amount to pay
                            local.calculateUpgrade = local.objPlans.calculateUpgrade(arguments.customerID, local.planID, local.recurring);
                            if (structKeyExists(local.calculateUpgrade, "toPayNow")) {
                                local.amountToPay = local.calculateUpgrade.toPayNow;
                            } else {
                                local.amountToPay = local.planPrice;
                            }

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
        } else {

            local.firstModule = true;


        }



        // If desired, we save the plan or module
        if (structKeyExists(arguments, "makeBooking") and arguments.makeBooking) {

            try {

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

            } catch (any e) {

                local.argsReturnValue['message'] = e.message;
                local.argsReturnValue['success'] = false;
                return local.argsReturnValue;

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
                local.position[1]['price'] = local.amountToPay;
                local.priceAfterVAT = local.objPrices.getPriceData(local.amountToPay);
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
                    local.argsReturnValue['message'] = local.chargeNow.message;
                    local.argsReturnValue['success'] = false;
                    return local.argsReturnValue;
                }

                // Insert payment
                local.payment = structNew();
                local.payment['invoiceID'] = local.invoiceID;
                local.payment['customerID'] = arguments.customerID;
                local.payment['date'] = now();
                local.payment['amount'] = local.priceAfterVAT;

                local.insPayment = local.objInvoice.insertPayment(local.payment);

                if (!local.insPayment.success) {
                    local.argsReturnValue['message'] = local.insPayment.message;
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



    // If something went wrong, delete the entry
    public void function deleteBooking(required numeric customerID, required numeric bookingID) {

        queryExecute (
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID},
                bookingID: {type: "numeric", value: arguments.bookingID}
            },
            sql = "
                DELETE FROM bookings
                WHERE intBookingID = :bookingID
                AND intCustomerID = :customerID
            "
        )

    }


}