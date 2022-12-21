component extends="taffy.core.api" {
    
    // Including config file
    include template="../config.cfm";

    // Set application variables
    application.datasource = variables.datasource;

    // Instantiate jwt
    application.jwt = new jwt.models.jwt();
    application.apiSecret = variables.apiSecret;
    application.issJWT = variables.appName;

    // Object initialising
    this.mappings["/saaster"] = ExpandPath("../com");

    application.objLanguage = new com.language();
    application.objSettings = new com.settings();
    application.objLog = new com.log();
    logWrite = application.objLog.logWrite;

    application.objGlobal = new com.global();
    application.objCustomer = new com.customer();
    application.objUser = new com.user();

    // Load language struct and save it into the application scope
    application.langStruct = application.objLanguage.initLanguages();

    // Load system setting struct and save it into the application scope
    application.systemSettingStruct = application.objSettings.initSystemSettings();

    // Set timezone
    setTimezone("UTC+00:00");

    // Set taffy framework settings
    variables.framework = {
        reloadKey = "reload",
        reloadPassword = variables.apiReloadPassword,
        reloadOnEveryRequest = false,
        disableDashboard = true,
        disabledDashboardRedirect = "/",
    }; 

    // Add mappings for the api
    this.mappings["/resources"] = expandPath("./resources");
    this.mappings["/taffy"] = expandPath("./taffy");

    // this function is called after the request has been parsed and all request details are known
    function onTaffyRequest(verb, cfc, requestArguments, mimeExt, headers){

        if(arguments.cfc eq "authenticate") {
            return true;
        }

        // Check if authorization header exists
        if(not structKeyExists(arguments.headers, "Authorization")){
            return noData().withStatus(401);
        }
        
        // Remove bearer keyword and parse only token
        local.token = trim(ReplaceNoCase(arguments.headers.Authorization, "Bearer", ""));

        // Check if token is valid
        try {
            local.decodedJWT = application.jwt.decode(local.token, application.apiSecret, "HS256")
            local.isValidToken = true;
        }catch(any e) {
            if(structKeyExists(e, "message") and e.message eq "Token has expired"){
                // Get nonce from token
                local.tokenNonce = application.jwt.decode(token = local.token, verify = false).nonce;
                
                // Delete orphan nonce entry
                local.qOrphanDeleteNonce = queryExecute(
                    options = {datasource = application.datasource},
                    params = {
                        thisOrphanNonceUUID: {type: "string", value: local.tokenNonce}
                    },
                    sql = "
                        DELETE FROM api_nonce
                        WHERE strNonceUUID = :thisOrphanNonceUUID
                    "
                )
                
                local.isValidToken = false;
            }else {
                local.isValidToken = false;
            }
        }

        // Return 401 when token isn't valid
        if(not local.IsValidToken){
            return noData().withStatus(401);
        }

        // Check nonce and delete if exists
        queryExecute(
            options = {datasource = application.datasource, result="local.qCheckNonce"},
            params = {
                thisNonceUUID: {type: "string", value: local.decodedJWT.nonce}
            },
            sql = "
                DELETE FROM api_nonce
                WHERE strNonceUUID = :thisNonceUUID
            "
        )
 
        // Return 401 when no matching nonce entry is found
        if(not local.qCheckNonce.recordCount){
            return noData().withStatus(401);
        }

        logWrite("API", 1, "File: #callStackGet("string", 0 , 1)#, API call on #arguments.cfc# resource!", false);

        return true;
    }

}