<cfscript>
    if (structKeyExists(form, "new_api")) {
        param name="form.api_key" default="";
        param name="form.api_name" default="";
        param name="form.api_until_date" default="";

        if(form.api_key neq "" and form.api_name neq "" and form.api_until_date neq ""){

            if(form.api_key.length() lt 35){
                getAlert("Please choose an API Key with at least 35 characters!", 'danger');
                location url="#application.mainURL#/sysadmin/api-settings" addtoken="false";
            }

            hashedStruct = application.objGlobal.generateHash(form.api_key);

            qCreateAPI = queryExecute (
                options = {datasource = application.datasource},
                params = {
                    apiKeyHash: {type: "varchar", value: hashedStruct.thisHash},
                    apiKeySalt: {type: "varchar", value: hashedStruct.thisSalt},
                    apiName: {type: "varchar", value: form.api_name},
                    apiValidDate: {type: "datetime", value: form.api_until_date}
                },
                sql = "
                    INSERT INTO api_management (strApiName, strApiKeyHash, strApiKeySalt, dtmValidUntil)
                    VALUES (:apiName, :apiKeyHash, :apiKeySalt, :apiValidDate)
                "
            )
        }

        getAlert('API successfuly created! Key: #form.api_key#');
        location url="#application.mainURL#/sysadmin/api-settings" addtoken="false";
    }

    if (structKeyExists(url, "deleteAPI") and isNumeric(url.deleteAPI)) {
        qDeleteApi = queryExecute (
            options = {datasource = application.datasource},
            params = {
                apiToDelete: {type: "numeric", value: url.deleteAPI}
            },
            sql = "
                DELETE FROM api_management WHERE intApiID = :apiToDelete;
            "
        )

        getAlert('API successfuly deleted!');
        location url="#application.mainURL#/sysadmin/api-settings" addtoken="false";
    }
    
    location url="#application.mainURL#/sysadmin/api-settings" addtoken="false";
    
</cfscript>