
component displayname="customer" output="false" {

    variables.argsReturnValue = structNew();
    variables.argsReturnValue['message'] = "";
    variables.argsReturnValue['success'] = false;

    // Insert optin
    public struct function insertOptin(required struct optinValues) {

        local.first_name = '';
        local.name = '';
        local.company = '';
        local.email = '';
        local.language = application.objLanguage.getDefaultLanguage().iso;
        local.newUUID = application.objGlobal.getUUID();

        if (structKeyExists(arguments.optinValues, "first_name")) {
            local.first_name = application.objGlobal.cleanUpText(arguments.optinValues.first_name, 100);
        }
        if (structKeyExists(arguments.optinValues, "name")) {
            local.name = application.objGlobal.cleanUpText(arguments.optinValues.name, 100);
        }
        if (structKeyExists(arguments.optinValues, "company")) {
            local.company = application.objGlobal.cleanUpText(arguments.optinValues.company, 100);
        }
        if (structKeyExists(arguments.optinValues, "email")) {
            local.email = application.objGlobal.cleanUpText(arguments.optinValues.email, 100);
        }
        if (structKeyExists(arguments.optinValues, "language")) {
            local.language = arguments.optinValues.language;
        }
        if (structKeyExists(arguments.optinValues, "newUUID")) {
            local.newUUID = arguments.optinValues.newUUID;
        }

        // Delete already existing records in optin table
        queryExecute(

            options = {datasource = '#application.datasource#'},
            params = {
                check_mail: {type: "varchar", value: local.email},
            },
            sql = "
                DELETE FROM optin
                WHERE strEmail = :check_mail;
            "

        );

        try {

            queryExecute(

                options = {datasource = '#application.datasource#', result = 'getNewID'},
                params = {
                    first_name: {type: "nvarchar", value: local.first_name},
                    name: {type: "nvarchar", value: local.name},
                    company: {type: "nvarchar", value: local.company},
                    email: {type: "varchar", value: local.email},
                    language: {type: "varchar", value: local.language},
                    newUUID: {type: "nvarchar", value: local.newUUID}
                },
                sql = "
                    INSERT INTO optin (strFirstName, strLastName, strCompanyName, strEmail, strLanguage, strUUID)
                    VALUES (:first_name, :name, :company, :email, :language, :newUUID)
                "

            );

            variables.argsReturnValue['newID'] = getNewID.generated_key;
            variables.argsReturnValue['success'] = true;

        } catch(any e) {

            variables.argsReturnValue['message'] = e.message;
            variables.argsReturnValue['newID'] = 0;

        }

        return variables.argsReturnValue;

    }


    // Insert customer: used for register
    public struct function insertCustomer(required struct customerStruct) {

        // Default variables
        local.argsReturnValue = structNew();
        local.argsReturnValue['message'] = "";
        local.argsReturnValue['success'] = false;

        param name="local.company_name" default="";
        param name="local.first_name" default="";
        param name="local.last_name" default="";
        param name="local.email" default="";
        param name="local.language" default="";
        param name="local.password" default=""; //(the password must be hashed already!)
        param name="local.uuid" default="";

        local.company_name = '';
        local.first_name = '';
        local.last_name = '';
        local.email = '';
        local.language = application.objLanguage.getDefaultLanguage().iso;
        local.hash = '';
        local.salt = '';
        local.uuid = '';

        if (structKeyExists(arguments.customerStruct, "strCompanyName")) {
            local.company_name = application.objGlobal.cleanUpText(arguments.customerStruct.strCompanyName, 100);
        }
        if (structKeyExists(arguments.customerStruct, "strFirstName")) {
            local.first_name = application.objGlobal.cleanUpText(arguments.customerStruct.strFirstName, 100);
        }
        if (structKeyExists(arguments.customerStruct, "strLastName")) {
            local.last_name = application.objGlobal.cleanUpText(arguments.customerStruct.strLastName, 100);
        }
        if (structKeyExists(arguments.customerStruct, "strEmail")) {
            local.email = application.objGlobal.cleanUpText(arguments.customerStruct.strEmail, 100);
        }
        if (structKeyExists(arguments.customerStruct, "strLanguage")) {
            local.language = arguments.customerStruct.strLanguage;
        }
        if (structKeyExists(arguments.customerStruct, "hash")) {
            local.hash = trim(arguments.customerStruct.hash);
        }
        if (structKeyExists(arguments.customerStruct, "salt")) {
            local.salt = trim(arguments.customerStruct.salt);
        }
        if (structKeyExists(arguments.customerStruct, "strUUID")) {
            local.uuid = trim(arguments.customerStruct.strUUID);
        }



        try {

            queryExecute(

                options = {datasource = application.datasource},
                params = {
                    company_name: {type: "nvarchar", value: local.company_name},
                    first_name: {type: "nvarchar", value: local.first_name},
                    last_name: {type: "nvarchar", value: local.last_name},
                    email: {type: "nvarchar", value: local.email},
                    language: {type: "varchar", value: local.language},
                    hash: {type: "nvarchar", value: local.hash},
                    salt: {type: "nvarchar", value: local.salt},
                    uuid: {type: "nvarchar", value: local.uuid},
                    dateNow: {type: "datetime", value: now()}
                },
                sql = "

                    INSERT INTO customers (intCustParentID, dtmInsertDate, dtmMutDate, blnActive, strCompanyName, intCountryID, strContactPerson, strEmail)
                    VALUES (0, :dateNow, :dateNow, 1, :company_name,
                        (SELECT intCountryID FROM countries WHERE blnDefault = 1), CONCAT(:first_name, ' ', :last_name), :email);

                    SET @last_inserted_customer_id = LAST_INSERT_ID();

                    INSERT INTO users (intCustomerID, dtmInsertDate, dtmMutDate, strFirstName, strLastName, strEmail, strPasswordHash, strPasswordSalt, strLanguage, blnActive, blnAdmin, blnSuperAdmin, blnSysAdmin)
                    VALUES (@last_inserted_customer_id, :dateNow, :dateNow, :first_name, :last_name, :email, :hash, :salt, :language, 1, 1, 1,
                        IF(
                            (
                                SELECT COUNT(intCustomerID)
                                FROM customers
                                WHERE intCustomerID <> @last_inserted_customer_id
                            ) > 0,
                            0,
                            1
                        )
                    );

                    DELETE FROM optin WHERE strUUID = :uuid;

                "

            );

            local.argsReturnValue['message'] = "OK";
            local.argsReturnValue['success'] = true;

        } catch(any e){

            local.argsReturnValue['message'] = e;


        }

        return local.argsReturnValue;

    }


    // Check whether the required data of a client has already been filled in
    public boolean function checkFilledData(required numeric customerID) {

        local.getCustomerData = application.objCustomer.getCustomerData(arguments.customerID);

        if (!len(trim(local.getCustomerData.address))) {
            return false;
        }
        if (!len(trim(local.getCustomerData.zip))) {
            return false;
        }
        if (!len(trim(local.getCustomerData.city))) {
            return false;
        }
        if (application.objGlobal.getCountry().recordCount) {
            if (local.getCustomerData.countryID eq 0 or !len(trim(getCustomerData.countryID))) {
                return false;
            }
        } else {
            if (local.getCustomerData.timezoneID eq 0 or !len(trim(getCustomerData.timezoneID))) {
                return false;
            }
        }

        return true;

    }


    public boolean function verifyGoogleToken(required string googleToken, required string secretKey) {

        local.secretKey = arguments.secretKey;
        local.result = {};

        cfhttp(
            url="https://www.google.com/recaptcha/api/siteverify",
            method="post",
            result="local.result") {
            cfhttpparam(type="formfield", name="secret", value=local.secretKey);
            cfhttpparam(type="formfield", name="response", value=arguments.googleToken);
            cfhttpparam(type="formfield", name="remoteip", value=cgi.remote_addr);
        };

        local.response = deserializeJson(local.result.fileContent);
        return local.response.success;

    }



}