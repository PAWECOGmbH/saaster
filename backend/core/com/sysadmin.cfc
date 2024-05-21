
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
                    strCompanyName LIKE '%#arguments.search#%' OR
                    strContactPerson LIKE '%#arguments.search#%' OR
                    strZIP LIKE '%#arguments.search#%' OR
                    strCity LIKE '%#arguments.search#%'
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
        
        local.qTotalCountries = queryExecute(
            options = {datasource = application.datasource},
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
                #arguments.search#
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

        local.entries = 10;

        local.qCountries = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT countries.*, languages.strLanguageEN
                FROM countries
                LEFT JOIN languages ON countries.intLanguageID = languages.intLanguageID
                WHERE blnActive = 1
                AND MATCH (countries.strCountryName, countries.strLocale, countries.strISO1, countries.strISO2, countries.strCurrency, countries.strRegion, countries.strSubRegion)
                #arguments.search#
                ORDER BY #arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qCountries;
    }

    public query function getCountriesImportSearch(required string search, required string sort){

        local.qCountries = queryExecute (
            options = {datasource = application.datasource},
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
                #arguments.search#
                ORDER BY #arguments.sort#
            "
        );

        return local.qCountries;
    }

    public query function getCountries(required numeric start, required string sort){

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

        local.entries = 10;

        local.qTotalCustomers = queryExecute(
            options = {datasource = application.datasource},
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
                #arguments.search#
                ORDER BY #arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qTotalCustomers;
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

        local.entries = 10;

        local.qCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT DISTINCT customers.intCustomerID, customers.strCompanyName, customers.strContactPerson,
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
                #arguments.search#
                ORDER BY #arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qCustomers;
    }

    public query function getCustomer(required numeric start, required string sort){

        local.entries = 10;

        local.qCustomers = queryExecute(
            options = {datasource = application.datasource},
            sql = "
                SELECT customers.*, countries.strCountryName
                FROM customers
                LEFT JOIN countries ON countries.intCountryID = customers.intCountryID
                WHERE customers.blnActive = 1
                ORDER BY #arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qCustomers;
    }

    public query function getTotalInvoicesSearch(required string search, required string term, required numeric start, required string status, required string sort){

        local.entries = 10;

        local.qTotalInvoices = queryExecute (
            options = {datasource = application.datasource},
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
                    #arguments.search#
                    OR
                    MATCH (customers.strCompanyName, customers.strContactPerson, customers.strAddress, customers.strZIP, customers.strCity, customers.strEmail)
                    #arguments.search#
                    OR invoices.intInvoiceNumber = '#arguments.term#'
                )

                ORDER BY #arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qTotalInvoices;
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

                WHERE (
                    MATCH (invoices.strInvoiceTitle, invoices.strCurrency)
                    #arguments.search#
                    OR
                    MATCH (customers.strCompanyName, customers.strContactPerson, customers.strAddress, customers.strZIP, customers.strCity, customers.strEmail)
                    #arguments.search#
                    OR invoices.intInvoiceNumber = '#arguments.term#'
                )

                ORDER BY #arguments.sort#
                LIMIT #arguments.start#, #local.entries#
            "
        );

        return local.qInvoices;
    }

    public query function getAllInvoices(required numeric start, required string status, required string sort){

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

    public query function getFrontendMappings(){

        local.qSystemMappings = queryExecute (
            options = {datasource = application.datasource},
            sql = "
                SELECT *
                FROM frontend_mappings
            "
        );

        return local.qSystemMappings;
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

        // Custom results
        defaultQueryCustom = "
            SELECT *
            FROM custom_translations
            WHERE strVariable LIKE '%#arguments.search#%'
        ";
        orListCustom = "";
        orderQryCustom = "
            ORDER BY strVariable
        ";

        qLanguages = getLanguages();

        // Loop over query and append to query string
        loop query=qLanguages {
            orListCustom = listAppend(orListCustom, "OR strString#qLanguages.strLanguageISO# LIKE '%#arguments.search#%'", " ");
        }

        cfquery(datasource=application.datasource name="qCustomResults") {
            writeOutput(defaultQueryCustom & orListCustom & orderQryCustom);
        }

        return qCustomResults;
    }

    public query function searchSystemTranslations(required string search){

        // System results
        defaultQuerySys = "
        SELECT *
        FROM system_translations
        WHERE strVariable LIKE '%#arguments.search#%'
        ";
        orListCustom = "";
        orderQrySys = "
            ORDER BY strVariable
        ";

        qLanguages = getLanguages();

        // Loop over query and append to query string
        loop query=qLanguages {
            orListCustom = listAppend(orListCustom, "OR strString#qLanguages.strLanguageISO# LIKE '%#arguments.search#%'", " ");
        }

        cfquery(datasource=application.datasource name="qSystemResults") {
            writeOutput(defaultQuerySys & orListCustom & orderQrySys);
        }

        return qSystemResults;
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




}