
component displayname="sysadmin" output="false" {

    public struct function getSysAdminData() {

        local.sysadminStruct = structNew();

        local.qCustomer = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT customers.*
                FROM users
                INNER JOIN customers ON users.intCustomerID = customers.intCustomerID
                WHERE users.blnSysAdmin = 1
            "
        )

        local.customerStruct['customerID'] = local.qCustomer.intCustomerID;
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

        return local.customerStruct;

    }

    public query function getCountryAjax(required numeric countryID){

        local.qCountry = queryExecute(
            options = {datasource = application.datasource},
            params = {
                countryID: {type: "numeric", value: arguments.countryID}
            },
            sql = "
                SELECT *
                FROM countries
                WHERE intCountryID = :countryID
            "
        )

        return local.qCountry;
    }

    public query function getCountriesAjax(){

        local.qCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intCountryID) as totalCountries
                FROM countries
                WHERE blnActive = 1
            "
        )

        return local.qCountries;
    }

    public query function getCustomerAjax(required string search){

        local.qCustomer = queryExecute (
            options = {datasource = application.datasource},
            params = {
                searchLike: {type: "varchar", value: "%" & arguments.search & "%"}
            },
            sql = "
                SELECT intCustomerID, strZIP, strCity,
                    IF(
                        LENGTH(customers.strCompanyName),
                        customers.strCompanyName,
                        customers.strContactPerson
                    ) as customerName
                FROM customers
                WHERE blnActive = 1
                AND (
                    strCompanyName LIKE :searchLike OR
                    strContactPerson LIKE :searchLike OR
                    strZIP LIKE :searchLike OR
                    strCity LIKE :searchLike
                )
                ORDER BY strCompanyName
                LIMIT 10
            "
        )

        return local.qCustomer;
    }

    public query function getApi(){

        local.qApiUser = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT intApiID, strApiName, dtmValidUntil
                FROM api_management
            "
        )

        return local.qApiUser;
    }

    public query function getTotalCountriesSearch(required string search){

        // Only a valid boolean-mode expression may reach MATCH ... AGAINST (global.cfc::fullTextSearch)
        arguments.search = application.objGlobal.fullTextSearch(arguments.search);

        local.qTotalCountries = queryExecute(
            options = {datasource = application.datasource},
            params = {
                search: {type: "varchar", value: arguments.search}
            },
            sql = "
                SELECT COUNT(intCountryID) as totalCountries
                FROM countries
                WHERE blnActive = 1
                AND MATCH (
                    countries.strCountryName,
                    countries.strLocale,
                    countries.strISO1,
                    countries.strISO2,
                    countries.strCurrency,
                    countries.strRegion,
                    countries.strSubRegion
                )
                AGAINST (:search IN BOOLEAN MODE)
            "
        );

        return local.qTotalCountries;
    }

    public query function getTotalCountries(){

        local.qTotalCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intCountryID) as totalCountries
                FROM countries
                WHERE blnActive = 1
            "
        );

        return local.qTotalCountries;
    }


    public query function getTotalCountriesImport(){

        local.qTotalCountries = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intCountryID) as totalCountries
                FROM countries
                WHERE blnActive = 0
            "
        );

        return local.qTotalCountries;
    }

    public query function getCountriesSearch(required string search, required numeric start, required string sort){

        // Only a valid boolean-mode expression may reach MATCH ... AGAINST (global.cfc::fullTextSearch)
        arguments.search = application.objGlobal.fullTextSearch(arguments.search);

        // Only allow known ORDER BY expressions (defense against SQL injection via the sort parameter)
        arguments.sort = application.objGlobal.safeOrderBy(arguments.sort, ["intPrio", "intPrio ASC", "intPrio DESC", "blnDefault DESC", "strCountryName ASC", "strCountryName DESC", "strRegion ASC", "strRegion DESC"], "intPrio");

        local.entries = 10;

        local.qCountries = queryExecute(
            options = {datasource = application.datasource},
            params = {
                search: {type: "varchar", value: arguments.search}
            },
            sql = "
                SELECT countries.*, languages.strLanguageEN
                FROM countries
                LEFT JOIN languages ON countries.intLanguageID = languages.intLanguageID
                WHERE blnActive = 1
                AND MATCH (countries.strCountryName, countries.strLocale, countries.strISO1, countries.strISO2, countries.strCurrency, countries.strRegion, countries.strSubRegion)
                AGAINST (:search IN BOOLEAN MODE)
                ORDER BY #arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qCountries;
    }

    public query function getCountriesImportSearch(required string search, required string sort){

        // Only a valid boolean-mode expression may reach MATCH ... AGAINST (global.cfc::fullTextSearch)
        arguments.search = application.objGlobal.fullTextSearch(arguments.search);

        // Only allow known ORDER BY expressions (defense against SQL injection via the sort parameter)
        arguments.sort = application.objGlobal.safeOrderBy(arguments.sort, ["strCountryName ASC", "strCountryName DESC", "strRegion ASC", "strRegion DESC", "strSubRegion ASC", "strSubRegion DESC"], "strCountryName ASC");

        local.qCountries = queryExecute (
            options = {datasource = application.datasource},
            params = {
                search: {type: "varchar", value: arguments.search}
            },
            sql = "
                SELECT *
                FROM countries
                WHERE blnActive = 0
                AND MATCH (
                    countries.strCountryName,
                    countries.strLocale,
                    countries.strISO1,
                    countries.strISO2,
                    countries.strCurrency,
                    countries.strRegion,
                    countries.strSubRegion
                )
                AGAINST (:search IN BOOLEAN MODE)
                ORDER BY #arguments.sort#
            "
        );

        return local.qCountries;
    }

    public query function getCountries(required numeric start, required string sort){

        // Only allow known ORDER BY expressions (defense against SQL injection via the sort parameter)
        arguments.sort = application.objGlobal.safeOrderBy(arguments.sort, ["intPrio", "intPrio ASC", "intPrio DESC", "blnDefault DESC", "strCountryName ASC", "strCountryName DESC", "strRegion ASC", "strRegion DESC"], "intPrio");

        local.entries = 10;

        local.qCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT countries.*, languages.strLanguageEN
                FROM countries
                LEFT JOIN languages ON countries.intLanguageID = languages.intLanguageID
                WHERE blnActive = 1
                ORDER BY #arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qCountries;
    }

    public query function getCountriesImport(required string sort){

        // Only allow known ORDER BY expressions (defense against SQL injection via the sort parameter)
        arguments.sort = application.objGlobal.safeOrderBy(arguments.sort, ["strCountryName ASC", "strCountryName DESC", "strRegion ASC", "strRegion DESC", "strSubRegion ASC", "strSubRegion DESC"], "strCountryName ASC");

        local.qCountries = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM countries
                WHERE blnActive = 0
                ORDER BY #arguments.sort#
            "
        );

        return local.qCountries;
    }

    public query function getCurrencies(){

        local.qCurrencies = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM currencies
                ORDER BY intPrio
            "
        );

        return local.qCurrencies;
    }

    public query function getCurrentModules(required numeric customerID){

        local.qCurrentModules = queryExecute (
            options = {datasource = application.datasource},
            params = {
                customerID: {type: "numeric", value: arguments.customerID}
            },
            sql = "
                SELECT *
                FROM bookings
                WHERE intCustomerID = :customerID
                AND intModuleID > 0
            "
        );

        return local.qCurrentModules;
    }

    public query function getTotalCustomersSearch(required string search, required numeric start, required string sort){

        // Only a valid boolean-mode expression may reach MATCH ... AGAINST (global.cfc::fullTextSearch)
        arguments.search = application.objGlobal.fullTextSearch(arguments.search);

        // Only allow known ORDER BY expressions (defense against SQL injection via the sort parameter)
        arguments.sort = application.objGlobal.safeOrderBy(arguments.sort, ["strCompanyName ASC", "strCompanyName DESC", "strContactPerson ASC", "strContactPerson DESC", "strCity ASC", "strCity DESC", "dtmInsertDate ASC", "dtmInsertDate DESC"], "strCompanyName ASC");

        local.entries = 10;

        local.qTotalCustomers = queryExecute(
            options = {datasource = application.datasource},
            params = {
                search: {type: "varchar", value: arguments.search}
            },
            sql = "
                SELECT COUNT(DISTINCT customers.intCustomerID) as totalCustomers, customers.strCompanyName, customers.strContactPerson,
                customers.strCity, customers.strEmail, customers.strLogo, customers.strPhone
                FROM customers

                INNER JOIN users
                ON customers.intCustomerID = users.intCustomerID
                OR customers.intCustParentID = users.intCustomerID

                WHERE customers.blnActive = 1
                AND MATCH (
                    customers.strCompanyName,
                    customers.strContactPerson,
                    customers.strAddress,
                    customers.strZIP,
                    customers.strCity,
                    customers.strEmail
                )
                AGAINST (:search IN BOOLEAN MODE)
                GROUP BY customers.intCustomerID
                ORDER BY customers.#arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );
        if(local.qTotalCustomers.recordCount > 0){
            return local.qTotalCustomers;
        }else{
            /* return 0 in a query */
            local.simulatedQuery = QueryNew("totalCustomers", "integer");
            QueryAddRow(simulatedQuery, 1);
            QuerySetCell(simulatedQuery, "totalCustomers", 0);
            return local.simulatedQuery;
        }
    }

    public query function getTotalCustomers(){

        local.qTotalCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intCustomerID) as totalCustomers
                FROM customers
                WHERE blnActive = 1
            "
        );

        return local.qTotalCustomers;
    }

    public query function getCustomerSearch(required string search, required numeric start, required string sort){

        // Only a valid boolean-mode expression may reach MATCH ... AGAINST (global.cfc::fullTextSearch)
        arguments.search = application.objGlobal.fullTextSearch(arguments.search);

        // Only allow known ORDER BY expressions (defense against SQL injection via the sort parameter)
        arguments.sort = application.objGlobal.safeOrderBy(arguments.sort, ["strCompanyName ASC", "strCompanyName DESC", "strContactPerson ASC", "strContactPerson DESC", "strCity ASC", "strCity DESC", "dtmInsertDate ASC", "dtmInsertDate DESC"], "strCompanyName ASC");

        local.entries = 10;

        // Sorting logic dependent on arguments.sort
        switch (arguments.sort){
            case "strCompanyName ASC":
                local.orderClause = "
                    CASE
                        WHEN customers.strCompanyName IS NULL OR customers.strCompanyName = '' THEN 1
                        ELSE 0
                    END,
                    customers.strCompanyName ASC";
                break;

                case "strCompanyName DESC":
                    local.orderClause = "
                        CASE
                            WHEN customers.strCompanyName IS NULL OR customers.strCompanyName = '' THEN 1
                            ELSE 0
                        END,
                        customers.strCompanyName DESC";
                    break;

            default:
                local.orderClause = arguments.sort;
        }

        local.qCustomers = queryExecute(
            options = {datasource = application.datasource},
            params = {
                search: {type: "varchar", value: arguments.search}
            },
            sql = "
                SELECT DISTINCT customers.intCustomerID, customers.strCompanyName, customers.strContactPerson,
                customers.strCity, customers.strEmail, customers.strLogo, customers.strPhone, customers.dtmInsertDate
                FROM customers

                INNER JOIN users
                ON customers.intCustomerID = users.intCustomerID
                OR customers.intCustParentID = users.intCustomerID

                WHERE customers.blnActive = 1
                AND MATCH (
                    customers.strCompanyName,
                    customers.strContactPerson,
                    customers.strAddress,
                    customers.strZIP,
                    customers.strCity,
                    customers.strEmail
                )
                AGAINST (:search IN BOOLEAN MODE)
                ORDER BY #local.orderClause#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qCustomers;

    }

    public query function getCustomer(required numeric start, required string sort){

        // Only allow known ORDER BY expressions (defense against SQL injection via the sort parameter)
        arguments.sort = application.objGlobal.safeOrderBy(arguments.sort, ["strCompanyName ASC", "strCompanyName DESC", "strContactPerson ASC", "strContactPerson DESC", "strCity ASC", "strCity DESC", "dtmInsertDate ASC", "dtmInsertDate DESC"], "strCompanyName ASC");

        local.entries = 10;

        // Sorting logic dependent on arguments.sort
        switch (arguments.sort){
            case "strCompanyName ASC":
                local.orderClause = "
                    CASE
                        WHEN customers.strCompanyName IS NULL OR customers.strCompanyName = '' THEN 1
                        ELSE 0
                    END,
                    customers.strCompanyName ASC";
                break;

                case "strCompanyName DESC":
                    local.orderClause = "
                        CASE
                            WHEN customers.strCompanyName IS NULL OR customers.strCompanyName = '' THEN 1
                            ELSE 0
                        END,
                        customers.strCompanyName DESC";
                    break;

            default:
                local.orderClause = arguments.sort;
        }

        local.qCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT customers.*, countries.strCountryName
                FROM customers
                LEFT JOIN countries
                ON countries.intCountryID = customers.intCountryID
                WHERE customers.blnActive = 1
                ORDER BY #local.orderClause#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qCustomers;

    }

    public query function getTotalInvoicesSearch(required string search, required string term, required numeric start, required string status, required string sort){

        // Only a valid boolean-mode expression may reach MATCH ... AGAINST (global.cfc::fullTextSearch)
        arguments.search = application.objGlobal.fullTextSearch(arguments.search);

        // Only allow known ORDER BY expressions (defense against SQL injection via the sort parameter)
        arguments.sort = application.objGlobal.safeOrderBy(arguments.sort, ["invoiceNumber ASC", "invoiceNumber DESC", "dtmInvoiceDate ASC", "dtmInvoiceDate DESC", "dtmDueDate ASC", "dtmDueDate DESC"], "invoiceNumber DESC");

        local.entries = 10;

        local.qTotalInvoices = queryExecute (
            options = {datasource = application.datasource},
            params = {
                search: {type: "varchar", value: arguments.search},
                term: {type: "varchar", value: arguments.term}
            },
            sql = "
                SELECT  COUNT(intInvoiceID) as totalInvoices,
                        CONCAT(invoices.strPrefix, '', invoices.intInvoiceNumber) as invoiceNumber,
                        invoices.strInvoiceTitle,
                        invoices.dtmInvoiceDate,
                        invoices.dtmDueDate,
                        invoices.strCurrency,
                        invoices.decTotalPrice,
                        invoices.intPaymentStatusID,
                        invoice_status.strInvoiceStatusVariable,
                        invoice_status.strColor,
                        IF(
                            LENGTH(customers.strCompanyName),
                            customers.strCompanyName,
                            IF(
                                LENGTH(invoices.intUserID),
                                (
                                    SELECT CONCAT(users.strFirstName, ' ', users.strLastName)
                                    FROM users
                                    WHERE intUserID = invoices.intUserID
                                ),
                                customers.strContactPerson
                            )
                        ) as customerName

                FROM invoices

                INNER JOIN invoice_status ON 1=1
                AND invoices.intPaymentStatusID = invoice_status.intPaymentStatusID
                #arguments.status#

                INNER JOIN customers ON 1=1
                AND invoices.intCustomerID = customers.intCustomerID

                WHERE (
                    MATCH (invoices.strInvoiceTitle, invoices.strCurrency)
                    AGAINST (:search IN BOOLEAN MODE)
                    OR
                    MATCH (customers.strCompanyName, customers.strContactPerson, customers.strAddress, customers.strZIP, customers.strCity, customers.strEmail)
                    AGAINST (:search IN BOOLEAN MODE)
                    OR invoices.intInvoiceNumber = :term
                    OR CONCAT(invoices.strPrefix, '', invoices.intInvoiceNumber) = :term
                )
                GROUP BY invoices.intInvoiceID
                ORDER BY #arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        if(local.qTotalInvoices.recordCount > 0){
            return local.qTotalInvoices;
        }else{
            /* return 0 in a query */
            local.simulatedQuery = QueryNew("totalInvoices", "integer");
            QueryAddRow(simulatedQuery, 1);
            QuerySetCell(simulatedQuery, "totalInvoices", 0);
            return local.simulatedQuery;
        }
    }

    public query function getTotalInvoices(required string status){

        local.qTotalInvoices = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT COUNT(intInvoiceID) as totalInvoices
                FROM invoices
                WHERE 1=1
                #arguments.status#
            "
        );

        return local.qTotalInvoices;
    }

    public query function getAllInvoicesSearch(required string search, required string term, required numeric start, required string status, required string sort){

        // Only a valid boolean-mode expression may reach MATCH ... AGAINST (global.cfc::fullTextSearch)
        arguments.search = application.objGlobal.fullTextSearch(arguments.search);

        // Only allow known ORDER BY expressions (defense against SQL injection via the sort parameter)
        arguments.sort = application.objGlobal.safeOrderBy(arguments.sort, ["invoiceNumber ASC", "invoiceNumber DESC", "dtmInvoiceDate ASC", "dtmInvoiceDate DESC", "dtmDueDate ASC", "dtmDueDate DESC"], "invoiceNumber DESC");

        local.entries = 10;

        local.qInvoices = queryExecute (
            options = {datasource = application.datasource},
            params = {
                search: {type: "varchar", value: arguments.search},
                term: {type: "varchar", value: arguments.term}
            },
            sql = "
                SELECT  invoices.intInvoiceID,
                        CONCAT(invoices.strPrefix, '', invoices.intInvoiceNumber) as invoiceNumber,
                        invoices.strInvoiceTitle,
                        invoices.dtmInvoiceDate,
                        invoices.dtmDueDate,
                        invoices.strCurrency,
                        invoices.decTotalPrice,
                        invoices.intPaymentStatusID,
                        invoice_status.strInvoiceStatusVariable,
                        invoice_status.strColor,
                        IF(
                            LENGTH(customers.strCompanyName),
                            customers.strCompanyName,
                            IF(
                                LENGTH(invoices.intUserID),
                                (
                                    SELECT CONCAT(users.strFirstName, ' ', users.strLastName)
                                    FROM users
                                    WHERE intUserID = invoices.intUserID
                                ),
                                customers.strContactPerson
                            )
                        ) as customerName

                FROM invoices

                INNER JOIN invoice_status ON 1=1
                AND invoices.intPaymentStatusID = invoice_status.intPaymentStatusID
                #arguments.status#

                INNER JOIN customers ON 1=1
                AND invoices.intCustomerID = customers.intCustomerID

                WHERE (
                    MATCH (invoices.strInvoiceTitle, invoices.strCurrency)
                    AGAINST (:search IN BOOLEAN MODE)
                    OR
                    MATCH (customers.strCompanyName, customers.strContactPerson, customers.strAddress, customers.strZIP, customers.strCity, customers.strEmail)
                    AGAINST (:search IN BOOLEAN MODE)
                    OR invoices.intInvoiceNumber = :term
                    OR CONCAT(invoices.strPrefix, '', invoices.intInvoiceNumber) = :term
                )

                ORDER BY #arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qInvoices;
    }

    public query function getAllInvoices(required numeric start, required string status, required string sort){

        // Only allow known ORDER BY expressions (defense against SQL injection via the sort parameter)
        arguments.sort = application.objGlobal.safeOrderBy(arguments.sort, ["invoiceNumber ASC", "invoiceNumber DESC", "dtmInvoiceDate ASC", "dtmInvoiceDate DESC", "dtmDueDate ASC", "dtmDueDate DESC"], "invoiceNumber DESC");

        local.entries = 10;

        local.qInvoices = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT  invoices.intInvoiceID,
                        CONCAT(invoices.strPrefix, '', invoices.intInvoiceNumber) as invoiceNumber,
                        invoices.strInvoiceTitle,
                        invoices.dtmInvoiceDate,
                        invoices.dtmDueDate,
                        invoices.strCurrency,
                        invoices.decTotalPrice,
                        invoices.intPaymentStatusID,
                        invoice_status.strInvoiceStatusVariable,
                        invoice_status.strColor,
                        IF(
                            LENGTH(customers.strCompanyName),
                            customers.strCompanyName,
                            IF(
                                LENGTH(invoices.intUserID),
                                (
                                    SELECT CONCAT(users.strFirstName, ' ', users.strLastName)
                                    FROM users
                                    WHERE intUserID = invoices.intUserID
                                ),
                                customers.strContactPerson
                            )
                        ) as customerName

                FROM invoices

                INNER JOIN invoice_status ON 1=1
                AND invoices.intPaymentStatusID = invoice_status.intPaymentStatusID
                #arguments.status#

                INNER JOIN customers ON 1=1
                AND invoices.intCustomerID = customers.intCustomerID

                ORDER BY #arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qInvoices;
    }

    public query function getCustomMappings(){

        local.qCustomMappings = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM custom_mappings
                ORDER BY intCustomMappingID DESC
            "
        );

        return local.qCustomMappings;
    }

    public query function getSystemMappings(){

        local.qSystemMappings = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM system_mappings
            "
        );

        return local.qSystemMappings;
    }

    public query function getFrontendMappings(numeric mappingID){

        if (structKeyExists(arguments, "mappingID")) {

            local.qFrontendMappings = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    mappingID: {type: "numeric", value: arguments.mappingID}
                },
                sql = "
                    SELECT *
                    FROM frontend_mappings
                    WHERE intFrontendMappingsID = :mappingID
                "
            );

        } else {

            local.qFrontendMappings = queryExecute (
                options = {datasource = application.datasource},
                sql = "
                    SELECT *
                    FROM frontend_mappings
                    ORDER BY intFrontendMappingsID DESC
                "
            );

        }

        return local.qFrontendMappings;

    }

    public query function getModule(required numeric modulID){

        local.qModule = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisModuleID: {type: "numeric", value: arguments.modulID}
            },
            sql = "
                SELECT *
                FROM modules
                WHERE intModuleID = :thisModuleID
            "
        );

        return local.qModule;
    }

    public query function getPricesModule(required numeric modulID){

        local.qPrices = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisModuleID: {type: "numeric", value: arguments.modulID}
            },
            sql = "
                SELECT currencies.strCurrencyEN, currencies.strCurrencyISO, currencies.intCurrencyID as currID, modules_prices.*
                FROM currencies
                LEFT JOIN modules_prices
                ON currencies.intCurrencyID = modules_prices.intCurrencyID
                AND modules_prices.intModuleID = :thisModuleID
                WHERE blnActive = 1
                ORDER BY currencies.intPrio
            "
        );

        return local.qPrices;
    }

    public query function getModules(){

        local.qModules = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM modules
                ORDER BY intPrio
            "
        );

        return local.qModules;
    }

    public query function getNonDefLng(){

        local.qNonDefLng = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM languages
                WHERE blnDefault = 0
                ORDER BY intPrio
            "
        );

        return local.qNonDefLng;
    }

    public query function getPlanGroups(){

        local.qPlanGroups = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM plan_groups
                ORDER BY intPrio
            "
        )

        return local.qPlanGroups;
    }

    public query function getPlan(required numeric planID){

        local.qPlan = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisPlanID: {type: "numeric", value: arguments.planID}
            },
            sql = "
                SELECT plans.*, plan_groups.strGroupName
                FROM plans INNER JOIN plan_groups ON plans.intPlanGroupID = plan_groups.intPlanGroupID
                WHERE plans.intPlanID = :thisPlanID
            "
        );

        return local.qPlan;
    }

    public query function getFeatures(required numeric planID){

        local.qFeatures = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisPlanID: {type: "numeric", value: arguments.planID}
            },
            sql = "
                SELECT plan_features.strFeatureName, plan_features.blnCategory, plan_features.intPlanFeatureID as currID,
                    plans_plan_features.*
                FROM plan_features
                LEFT JOIN plans_plan_features
                ON plan_features.intPlanFeatureID = plans_plan_features.intPlanFeatureID
                AND plans_plan_features.intPlanID = :thisPlanID
                ORDER BY plan_features.intPrio
            "
        );

        return local.qFeatures;
    }

    public query function getPlanFeatures(){

        local.qPlanFeatures = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM plan_features
                ORDER BY intPrio
            "
        );

        return local.qPlanFeatures;
    }

    public query function getPlanGroupsCountry(){

        local.qPlanGroups = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT plan_groups.*, countries.strCountryName
                FROM plan_groups
                LEFT JOIN countries ON plan_groups.intCountryID = countries.intCountryID
                ORDER BY plan_groups.intPrio
            "
        );

        return local.qPlanGroups;
    }

    public query function getPlanGroupsCountries(){

        local.qCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT intCountryID, strCountryName
                FROM countries
                WHERE blnActive = 1
                ORDER BY intPrio
            "
        );

        return local.qCountries;
    }

    public query function getPlanModules(required numeric planID){

        local.qModules = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisPlanID: {type: "numeric", value: arguments.planID}
            },
            sql = "
                SELECT modules.*, plans_modules.intModuleID as currModule
                FROM modules
                LEFT JOIN plans_modules
                ON modules.intModuleID = plans_modules.intModuleID
                AND plans_modules.intPlanID = :thisPlanID
                WHERE modules.blnActive = 1
                ORDER BY modules.intPrio
            "
        );

        return local.qModules;
    }

    public query function getPlanPrices(required numeric planID){

        local.qPrices = queryExecute(
            options = {datasource = application.datasource},
            params = {
                thisPlanID: {type: "numeric", value: arguments.planID}
            },
            sql = "
                SELECT currencies.strCurrencyEN, currencies.strCurrencyISO, currencies.intCurrencyID as currID, plan_prices.*
                FROM currencies
                LEFT JOIN plan_prices
                ON currencies.intCurrencyID = plan_prices.intCurrencyID
                AND plan_prices.intPlanID = :thisPlanID
                WHERE blnActive = 1
                ORDER BY currencies.intPrio
            "
        );

        return local.qPrices;
    }

    public query function getAllPlanGroups(){

        local.qPlanGroups = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM plan_groups
                ORDER BY intPrio
            "
        );

        return local.qPlanGroups;
    }

    public query function getAllPlans(){

        local.qPlans = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT plans.*, plan_groups.strGroupName
                FROM plans INNER JOIN plan_groups ON plans.intPlanGroupID = plan_groups.intPlanGroupID
                ORDER BY plan_groups.intPrio, plans.intPrio
            "
        );

        return local.qPlans;
    }

    public query function getAllCountries(){

        local.qCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT intCountryID, strCountryName
                FROM countries
                WHERE blnActive = 1
                ORDER BY intPrio
            "
        );

        return local.qCountries;
    }

    public query function getSystemSetting(required string settingVariable){

        local.qSystemSettings = queryExecute (
            options = {datasource = application.datasource},
            params = {
                settingVariable: {type: "varchar", value: arguments.settingVariable}
            },
            sql = "
                SELECT *
                FROM system_settings
                WHERE strSettingVariable = :settingVariable
            "
        );

        return local.qSystemSettings;
    }

    public query function getLanguages(){

        local.qLanguages = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT intLanguageID, strLanguageISO, strLanguageEN, strLanguage, blnDefault, intPrio
                FROM languages
                ORDER BY blnDefault DESC, intPrio
            "
        )

        return local.qLanguages;
    }

    public query function searchCustomTranslations(required string search){

        // Search in the variable name and in every language column (column names come from the languages table, the search value is a bound parameter)
        local.qLanguages = getLanguages();
        local.orList = "";
        loop query=local.qLanguages {
            local.orList &= " OR strString" & local.qLanguages.strLanguageISO & " LIKE :searchLike";
        }

        local.qCustomResults = queryExecute(
            options = {datasource = application.datasource},
            params = {
                searchLike: {type: "varchar", value: "%" & arguments.search & "%"}
            },
            sql = "
                SELECT *
                FROM custom_translations
                WHERE strVariable LIKE :searchLike
                #local.orList#
                ORDER BY strVariable
            "
        );

        return local.qCustomResults;
    }

    public query function searchSystemTranslations(required string search){

        // Search in the variable name and in every language column (column names come from the languages table, the search value is a bound parameter)
        local.qLanguages = getLanguages();
        local.orList = "";
        loop query=local.qLanguages {
            local.orList &= " OR strString" & local.qLanguages.strLanguageISO & " LIKE :searchLike";
        }

        local.qSystemResults = queryExecute(
            options = {datasource = application.datasource},
            params = {
                searchLike: {type: "varchar", value: "%" & arguments.search & "%"}
            },
            sql = "
                SELECT *
                FROM system_translations
                WHERE strVariable LIKE :searchLike
                #local.orList#
                ORDER BY strVariable
            "
        );

        return local.qSystemResults;
    }

    public query function getSystemTranslations(){

        local.qSystemResults = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM system_translations
            "
        );

        return local.qSystemResults;
    }

    public query function getCustomTranslations(){

        local.qCustomResults = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM custom_translations
            "
        );

        return local.qCustomResults;
    }

    public query function getWidgets(){

        local.qWidgets = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT widgets.*, widget_ratio.strDescription,
                (
                    SELECT GROUP_CONCAT(intPlanID)
                    FROM widgets_plans
                    WHERE intWidgetID = widgets.intWidgetID
                ) as planList,
                (
                    SELECT GROUP_CONCAT(intModuleID)
                    FROM widgets_modules
                    WHERE intWidgetID = widgets.intWidgetID
                ) as moduleList
                FROM widgets
                INNER JOIN widget_ratio ON widgets.intRatioID = widget_ratio.intRatioID
            "
        );

        return local.qWidgets;
    }

    public query function getWidgetRatio(){

        local.qWidgetRatio = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM widget_ratio
            "
        );

        return local.qWidgetRatio;
    }

    public query function getPlans(){

        local.qPlans = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT intPlanID, strPlanName
                FROM plans
                ORDER BY intPrio
            "
        );

        return local.qPlans;
    }

    public query function getModulesWidget(){

        local.qModules = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT intModuleID, strModuleName
                FROM modules
                ORDER BY intPrio
            "
        );

        return local.qModules;
    }


    public query function getScheduleTasksOfModule(required numeric moduleID) {

        local.qScheduleTasksModule = queryExecute(
            options = {datasource = application.datasource},
            params = {
                moduleID: {type: "numeric", value: arguments.moduleID}
            },
            sql = "
                SELECT *
                FROM scheduletasks
                WHERE intModuleID = :moduleID
            "
        );

        return local.qScheduleTasksModule;

    }

    public query function getScheduleTask(required numeric taskID) {

        local.qScheduleTask = queryExecute(
            options = {datasource = application.datasource},
            params = {
                taskID: {type: "numeric", value: arguments.taskID}
            },
            sql = "
                SELECT *
                FROM scheduletasks
                WHERE intScheduletaskID = :taskID
            "
        );

        return local.qScheduleTask;

    }

    public void function deactivateTask(required numeric taskID) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                taskID: {type: "numeric", value: arguments.taskID}
            },
            sql = "
                UPDATE scheduletasks
                SET blnActive = 0
                WHERE intScheduletaskID = :taskID
            "
        )

    }

    public datetime function calcNextRun(required datetime maxStartTime, required numeric numMinutes) {

        local.thisTime = now();

        // If the start time is in the future, set this start time as next run
        if (local.thisTime lt arguments.maxStartTime) {

            local.nextRun = arguments.maxStartTime;

        } else {

            // Define start time and interval
            local.startDate = parseDateTime(arguments.maxStartTime);
            local.minutesToAdd = arguments.numMinutes;



            // Calculate how many minutes have passed since the original start date
            local.pastMinutes = dateDiff("n", local.startDate, local.thisTime);

            // Calculate how many intervals have elapsed since the original start date
            local.pastIntervals = ceiling(local.pastMinutes / local.minutesToAdd);

            // Calculate the next start time based on the previous intervals
            local.nextRun = dateAdd("n", local.pastIntervals * local.minutesToAdd, local.startDate);

            // If the current time falls exactly on an interval, set the next run to the next interval
            if (local.nextRun lte local.thisTime) {
                local.nextRun = dateAdd("n", local.minutesToAdd, local.nextRun);
            }

        }

        return local.nextRun;

    }


    // Unconditional release of a shard. Kept for backwards compatibility;
    // tasks.cfm uses claimScheduleControl() / releaseScheduleControl() instead.
    public void function stopScheduleControl(required numeric task) {

        queryExecute(
            options = {datasource = application.datasource},
            params = {
                utcDate: {type: "datetime", value: now()},
                taskName: {type: "string", value: "task_" & arguments.task}
            },
            sql = "
                UPDATE schedulecontrol
                SET dtmEnd = :utcDate,
                    blnIsRunning = 0,
                    strRunToken = NULL
                WHERE strTaskName = :taskName
            "
        )

    }


    // Claim a scheduler shard (task_01..task_20) for one run.
    // The claim is a single atomic UPDATE: it succeeds if the shard is idle, or if the
    // previous run has held the shard longer than the lease (stale run that was killed,
    // or a zombie request Lucee could not stop). The returned struct contains the run
    // token the caller needs to release the shard again, and whether a stale lease was
    // taken over so the caller can log it.
    public struct function claimScheduleControl(required string task, required numeric leaseMinutes) {

        local.result = {
            "claimed": false,
            "takenOver": false,
            "runToken": "",
            "staleSince": ""
        };

        local.taskName = "task_" & arguments.task;
        local.runToken = createUUID();
        local.staleBefore = dateAdd("n", -arguments.leaseMinutes, now());

        // Read the current state first, only used for logging a takeover
        local.qControl = queryExecute(
            options = {datasource = application.datasource},
            params = {
                taskName: {type: "string", value: local.taskName}
            },
            sql = "
                SELECT dtmStart, blnIsRunning
                FROM schedulecontrol
                WHERE strTaskName = :taskName
            "
        );

        if (!local.qControl.recordCount) {
            return local.result;
        }

        queryExecute(
            options = {datasource = application.datasource, result = "local.claimResult"},
            params = {
                taskName: {type: "string", value: local.taskName},
                runToken: {type: "string", value: local.runToken},
                utcDate: {type: "datetime", value: now()},
                staleBefore: {type: "datetime", value: local.staleBefore}
            },
            sql = "
                UPDATE schedulecontrol
                SET dtmStart = :utcDate,
                    blnIsRunning = 1,
                    strRunToken = :runToken
                WHERE strTaskName = :taskName
                AND (
                    blnIsRunning = 0
                    OR blnIsRunning IS NULL
                    OR dtmStart IS NULL
                    OR dtmStart < :staleBefore
                )
            "
        );

        if (local.claimResult.recordCount eq 1) {
            local.result["claimed"] = true;
            local.result["runToken"] = local.runToken;
            if (local.qControl.blnIsRunning eq 1) {
                local.result["takenOver"] = true;
                local.result["staleSince"] = local.qControl.dtmStart;
            }
        }

        return local.result;

    }


    // Release a shard, but only if this run still owns it. A run that lost its lease
    // to a takeover must not clear the flag of the run that replaced it.
    public boolean function releaseScheduleControl(required string task, required string runToken) {

        queryExecute(
            options = {datasource = application.datasource, result = "local.releaseResult"},
            params = {
                taskName: {type: "string", value: "task_" & arguments.task},
                runToken: {type: "string", value: arguments.runToken},
                utcDate: {type: "datetime", value: now()}
            },
            sql = "
                UPDATE schedulecontrol
                SET dtmEnd = :utcDate,
                    blnIsRunning = 0,
                    strRunToken = NULL
                WHERE strTaskName = :taskName
                AND strRunToken = :runToken
            "
        );

        return local.releaseResult.recordCount eq 1;

    }




}