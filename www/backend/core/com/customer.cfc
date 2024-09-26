
component displayname="customer" output="false" {

    // Get the users data using an ID
    public query function getUserDataByID(required numeric userID) {

        local.userQuery = queryNew('');

        if (len(trim(arguments.userID)) and arguments.userID gt 0) {

            local.qUser = queryExecute(

                options = {datasource = application.datasource},
                params = {
                    thisUserID: {type: "numeric", value = arguments.userID}
                },
                sql = "
                    SELECT DISTINCT
                    users.intUserID,
                    users.strSalutation,
                    users.strFirstName,
                    users.strLastName,
                    users.strEmail,
                    users.strPhone,
                    users.strMobile,
                    users.strLanguage,
                    users.strPhoto,
                    users.blnActive,
                    users.dtmLastLogin,
                    users.blnAdmin,
                    users.blnSuperAdmin,
                    users.strUUID,
                    users.intMfaCode,
                    users.dtmMfaDateTime,
                    users.blnMfa,
                    customers.intCustomerID,
                    customers.intCustParentID,
                    customers.blnActive,
                    customers.strCompanyName,
                    customers.strContactPerson,
                    customers.strAddress,
                    customers.strAddress2,
                    customers.strZIP,
                    customers.strCity,
                    customers.strPhone,
                    customers.strEmail,
                    customers.strWebsite,
                    customers.strLogo,
                    customers.strBillingAccountName,
                    customers.strBillingEmail,
                    customers.strBillingAddress,
                    customers.strBillingInfo,
                    customers.intCountryID
                    FROM customer_user
                    INNER JOIN users ON customer_user.intUserID = users.intUserID
                    INNER JOIN customers ON users.intCustomerID = customers.intCustomerID
                    WHERE customer_user.intUserID = :thisUserID
                "
            )

            local.userQuery = local.qUser;

        }

        return local.userQuery;

    }



    // Update customer
    public struct function updateCustomer(required struct customerStruct, required numeric customerID) {

        // Default variables
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        local.company = '';
        local.contact = '';
        local.address = '';
        local.address2 = '';
        local.zip = '';
        local.city = '';
        local.countryID = 0;
        local.timezoneID = application.objGlobal.getCountry(local.countryID).intTimezoneID;
        local.email = '';
        local.phone = '';
        local.website = '';
        local.billing_name = '';
        local.billing_email = '';
        local.billing_address = '';
        local.billing_info = '';

        if (structKeyExists(arguments.customerStruct, "company")) {
            local.company = application.objGlobal.cleanUpText(arguments.customerStruct.company, 100);
        }
        if (structKeyExists(arguments.customerStruct, "contact")) {
            local.contact = application.objGlobal.cleanUpText(arguments.customerStruct.contact, 100);
        }
        if (structKeyExists(arguments.customerStruct, "address")) {
            local.address = application.objGlobal.cleanUpText(arguments.customerStruct.address, 100);
        }
        if (structKeyExists(arguments.customerStruct, "address2")) {
            local.address2 = application.objGlobal.cleanUpText(arguments.customerStruct.address2, 100);
        }
        if (structKeyExists(arguments.customerStruct, "zip")) {
            local.zip = application.objGlobal.cleanUpText(arguments.customerStruct.zip, 10);
        }
        if (structKeyExists(arguments.customerStruct, "city")) {
            local.city = application.objGlobal.cleanUpText(arguments.customerStruct.city, 100);
        }
        if (structKeyExists(arguments.customerStruct, "countryID") and isNumeric(arguments.customerStruct.countryID)) {
            local.countryID = arguments.customerStruct.countryID;
        }
        if (structKeyExists(arguments.customerStruct, "timezoneID") and isNumeric(arguments.customerStruct.timezoneID) and arguments.customerStruct.timezoneID gt 0) {
            local.timezoneID = arguments.customerStruct.timezoneID;
        }
        if (structKeyExists(arguments.customerStruct, "email")) {
            local.email = application.objGlobal.cleanUpText(arguments.customerStruct.email, 100);
        }
        if (structKeyExists(arguments.customerStruct, "phone")) {
            local.phone = application.objGlobal.cleanUpText(arguments.customerStruct.phone, 100);
        }
        if (structKeyExists(arguments.customerStruct, "website")) {
            local.website = application.objGlobal.cleanUpText(arguments.customerStruct.website, 100);
        }
        if (structKeyExists(arguments.customerStruct, "billing_name")) {
            local.billing_name = application.objGlobal.cleanUpText(arguments.customerStruct.billing_name, 100);
        }
        if (structKeyExists(arguments.customerStruct, "billing_email")) {
            local.billing_email = application.objGlobal.cleanUpText(arguments.customerStruct.billing_email, 100);
        }
        if (structKeyExists(arguments.customerStruct, "billing_address")) {
            local.billing_address = application.objGlobal.cleanUpText(arguments.customerStruct.billing_address);
        }
        if (structKeyExists(arguments.customerStruct, "billing_info")) {
            local.billing_info = application.objGlobal.cleanUpText(arguments.customerStruct.billing_info);
        }

        try {

            queryExecute(

                options = {datasource = application.datasource},
                params = {
                    mutDate: {type: "datetime", value: now()},
                    customerID: {type: "numeric", value: arguments.customerID},
                    company: {type: "nvarchar", value: local.company},
                    contact: {type: "nvarchar", value: local.contact},
                    address: {type: "nvarchar", value: local.address},
                    address2: {type: "nvarchar", value: local.address2},
                    zip: {type: "nvarchar", value: local.zip},
                    city: {type: "nvarchar", value: local.city},
                    countryID: {type: "numeric", value: local.countryID},
                    timezoneID: {type: "numeric", value: local.timezoneID},
                    email: {type: "nvarchar", value: local.email},
                    phone: {type: "nvarchar", value: local.phone},
                    website: {type: "nvarchar", value: local.website},
                    billing_name: {type: "nvarchar", value: local.billing_name},
                    billing_email: {type: "nvarchar", value: local.billing_email},
                    billing_address: {type: "nvarchar", value: local.billing_address},
                    billing_info: {type: "nvarchar", value: local.billing_info}
                },
                sql = "

                    UPDATE customers
                    SET dtmMutDate = :mutDate,
                        strCompanyName = :company,
                        strContactPerson = :contact,
                        strAddress = :address,
                        strAddress2 = :address2,
                        strZIP = :zip,
                        strCity = :city,
                        intCountryID = :countryID,
                        intTimezoneID = :timezoneID,
                        strPhone = :phone,
                        strEmail = :email,
                        strWebsite = :website,
                        strBillingAccountName = :billing_name,
                        strBillingEmail = :billing_email,
                        strBillingAddress = :billing_address,
                        strBillingInfo = :billing_info
                    WHERE intCustomerID = :customerID

                "

            );

            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        } catch(any){

            local.argsReturnValue['message'] = cfcatch.message;


        }


        return local.argsReturnValue;

    }


    // Insert tenant (only the most important data)
    public struct function insertTenant(required struct tenantStruct) {

        // Default variables
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        param name="local.company_name" default="";
        param name="local.contact_person" default="";

        // Needed values
        if (!structKeyExists(tenantStruct, "customerID") or !isNumeric(tenantStruct.customerID)) {
            local.argsReturnValue['message'] = "customerID not valid!";
            return local.argsReturnValue;
        }
        if (!structKeyExists(tenantStruct, "userID") or !isNumeric(tenantStruct.userID)) {
            local.argsReturnValue['message'] = "userID not valid!";
            return local.argsReturnValue;
        }

        local.customerID = tenantStruct.customerID;
        local.userID = tenantStruct.userID;

        local.company_name = application.objGlobal.cleanUpText(tenantStruct.company_name, 100) ?: '';
        local.contact_person = application.objGlobal.cleanUpText(tenantStruct.contact_person, 100) ?: 'untitled company';

        try {

            queryExecute(
                options = {datasource = application.datasource, result="newTenant"},
                params = {
                    company_name: {type: "nvarchar", value: local.company_name},
                    contact_person: {type: "nvarchar", value: local.contact_person},
                    intCustParentID: {type: "numeric", value: local.customerID},
                    intUserID: {type: "numeric", value: local.userID},
                    dateNow: {type: "datetime", value: now()}
                },
                sql = "
                    INSERT INTO customers (intCustParentID, dtmInsertDate, dtmMutDate, blnActive, strCompanyName, intCountryID, strContactPerson)
                    VALUES (:intCustParentID, :dateNow, :dateNow, 1, :company_name,
                        (SELECT intCountryID FROM countries WHERE blnDefault = 1), :contact_person)

                "
            )

            local.newCustomerID = newTenant.generatedKey;

            // Insert the current admin as user for the new tenant
            queryExecute(
                options = {datasource = application.datasource, result="newTenant"},
                params = {
                    intUserID: {type: "numeric", value: local.userID},
                    newCustomerID: {type: "numeric", value: local.newCustomerID}
                },
                sql = "
                    INSERT INTO customer_user (intCustomerID, intUserID, blnStandard)
                    VALUES (:newCustomerID, :intUserID, 0);
                "
            )

            // Set the default plan, if defined
            local.objPlans = new backend.core.com.plans();
            local.planGroup = new backend.core.com.plans().prepareForGroupID(local.newCustomerID, session.usersIP);
            local.objPlans.setDefaultPlan(local.newCustomerID, local.planGroup.groupID);

            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;
            return local.argsReturnValue;

        } catch (any e) {

            local.argsReturnValue['message'] = e.message;
            return local.argsReturnValue;

        }

    }


    // Get all tenants
    public query function getAllTenants(required numeric userID) {

        if (arguments.userID gt 0) {

            local.qTenants = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    userID: {type: "numeric", value: arguments.userID}
                },
                sql = "
                    SELECT customer_user.blnStandard, customers.*, users.blnSuperAdmin, users.blnAdmin
                    FROM customer_user
                    INNER JOIN customers ON customer_user.intCustomerID = customers.intCustomerID
                    INNER JOIN users ON customer_user.intUserID = users.intUserID
                    WHERE customer_user.intUserID = :userID
                    GROUP BY customers.intCustomerID, customer_user.blnStandard, users.blnSuperAdmin, users.blnAdmin
                    ORDER BY customer_user.blnStandard DESC
                "
            )

            return local.qTenants;

        }

    }


    // Get customer data
    public struct function getCustomerData(required numeric customerID) {

        if (arguments.customerID gt 0) {

            local.objPrices = new backend.core.com.prices();
            local.objInvoices = new backend.core.com.invoices();
            local.objCurrency = new backend.core.com.currency();
            local.customerStruct = structNew();

            local.qCustomer = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID}
                },
                sql = "
                    SELECT *
                    FROM customers
                    WHERE intCustomerID = :customerID
                "
            )

            local.customerStruct['customerID'] = local.qCustomer.intCustomerID;
            local.customerStruct['custParentID'] = local.qCustomer.intCustParentID;
            local.customerStruct['insertDate'] = local.qCustomer.dtmInsertDate;
            local.customerStruct['mutDate'] = local.qCustomer.dtmMutDate;
            local.customerStruct['active'] = local.qCustomer.blnActive;
            local.customerStruct['companyName'] = local.qCustomer.strCompanyName;
            local.customerStruct['contactPerson'] = local.qCustomer.strContactPerson;
            local.customerStruct['address'] = local.qCustomer.strAddress;
            local.customerStruct['address2'] = local.qCustomer.strAddress2;
            local.customerStruct['zip'] = local.qCustomer.strZIP;
            local.customerStruct['city'] = local.qCustomer.strCity;
            local.customerStruct['countryID'] = local.qCustomer.intCountryID;
            local.customerStruct['timezoneID'] = local.qCustomer.intTimezoneID;
            local.customerStruct['phone'] = local.qCustomer.strPhone;
            local.customerStruct['email'] = local.qCustomer.strEmail;
            local.customerStruct['website'] = local.qCustomer.strWebsite;
            local.customerStruct['logo'] = local.qCustomer.strLogo;
            local.customerStruct['billingAccountName'] = local.qCustomer.strBillingAccountName;
            local.customerStruct['billingEmail'] = local.qCustomer.strBillingEmail;
            local.customerStruct['billingAddress'] = local.qCustomer.strBillingAddress;
            local.customerStruct['billingInfo'] = local.qCustomer.strBillingInfo;

            local.customerStruct['currencyStruct'] = {};
            local.language = "";
            local.countryName = "";
            local.countryIso = "";

            // Check currency via country first
            if (local.qCustomer.intCountryID gt 0) {
                local.country = application.objGlobal.getCountry(local.qCustomer.intCountryID);
                local.countryName = local.country.strCountryName;
                local.countryIso = local.country.strISO1;
                if (len(trim(local.country.strCurrency))) {
                    local.language = application.objLanguage.getAnyLanguage(local.country.intLanguageID).iso;
                    local.currency = local.objCurrency.getCurrency(local.country.strCurrency);
                    if (isStruct(local.currency) and !structIsEmpty(local.currency)) {
                        if (local.currency.active) {
                            local.customerStruct['currencyStruct'] = local.currency;
                        }
                    }
                }
            }

            // If the currency struct is empty, get the currency via the last invoice, if they have any
            if (structIsEmpty(local.customerStruct.currencyStruct)) {
                local.invoiceArray = objInvoices.getInvoices(arguments.customerID).arrayInvoices;
                if (isArray(local.invoiceArray) and !arrayIsEmpty(local.invoiceArray)) {
                    local.lastInvoice = arrayLast(invoiceArray);
                    local.language = local.lastInvoice.invoiceLanguage;
                    local.currency = local.objCurrency.getCurrency(lastInvoice.invoiceCurrency);
                    if (local.currency.active) {
                        local.customerStruct['currencyStruct'] = local.currency;
                    }
                }
            }

            // If the currency is still empty, get default currency
            if (structIsEmpty(local.customerStruct.currencyStruct)) {
                local.currency = local.objCurrency.getCurrency();
                local.customerStruct['currencyStruct'] = local.currency;
            }

            // Default language
            if (!len(trim(local.language))) {
                local.language = application.objLanguage.getDefaultLanguage().iso;
            }

            local.customerStruct['language'] = local.language;
            local.customerStruct['countryName'] = local.countryName;
            local.customerStruct['countryISO'] = local.countryIso;


            return local.customerStruct;

        }

    }


    // Save the current plan, the current modules and also the custom settings into a session
    public void function setProductSessions(required numeric customerID, required string language) {

        // Save current plan into a session
        checkPlan = new backend.core.com.plans(language=arguments.language).getCurrentPlan(arguments.customerID);
        session.currentPlan = checkPlan;

        // Save current modules into a session
        checkModules = new backend.core.com.modules(language=arguments.language).getBookedModules(arguments.customerID);
        session.currentModules = checkModules;

    }


    // Delete account right now
    public struct function deleteAccount(required numeric customerID) {

        // Default variables
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        if (arguments.customerID gt 0) {

            // Get all registered tenants
            local.qCheckTenants = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID}
                },
                sql = "
                    SELECT intCustomerID
                    FROM customers
                    WHERE intCustParentID = :customerID
                "
            )

            loop query="local.qCheckTenants" {

                // Get users of the tenant
                local.qCheckTenants = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        customerID: {type: "numeric", value: local.qCheckTenants.intCustomerID}
                    },
                    sql = "
                        SELECT intUserID
                        FROM users
                        WHERE intCustomerID = :customerID
                        AND blnSuperAdmin = 1
                    "
                )

                // If there is a tenant without user with super privileges, stop deleting
                if (!local.qCheckTenants.recordCount) {
                    local.argsReturnValue['message'] = application.objLanguage.getTrans('alertCantDeleteAccount');
                    return local.argsReturnValue;
                }

            }

            // Get all users of the customer
            local.qCustomer = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID}
                },
                sql = "
                    SELECT users.strPhoto, customers.strLogo
                    FROM customers
                    LEFT JOIN users ON customers.intCustomerID = users.intCustomerID
                    WHERE customers.intCustomerID = :customerID
                "
            )

            // Delete the customers logo
            if (local.qCustomer.recordCount) {
                if (len(trim(local.qCustomer.strPhoto))) {
                    if (fileExists(expandPath("/userdata/images/logos/#local.qCustomer.strLogo#"))) {
                        fileDelete(expandPath("/userdata/images/logos/#local.qCustomer.strLogo#"));
                    }
                }
            }

            // Loop over the users and delete pictures
            loop query="local.qCustomer" {
                if (len(trim(local.qCustomer.strPhoto))) {
                    if (fileExists(expandPath("/userdata/images/users/#local.qCustomer.strPhoto#"))) {
                        fileDelete(expandPath("/userdata/images/users/#local.qCustomer.strPhoto#"));
                    }
                }
            }

            // Delete the customer (the foreign key does the rest)
            local.qCustomer = queryExecute(
                options = {datasource = application.datasource},
                params = {
                    customerID: {type: "numeric", value: arguments.customerID}
                },
                sql = "

                    UPDATE customers
                    SET intCustParentID = 0
                    WHERE intCustParentID = :customerID;

                    DELETE FROM customers
                    WHERE intCustomerID = :customerID;

                "
            )

            local.argsReturnValue['success'] = true;
            return local.argsReturnValue;

        }

        return local.argsReturnValue;

    }

}
