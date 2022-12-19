component extends="taffy.core.api" {
    
    // Including config file
    include template="../config.cfm";

    // Set application variables
    application.datasource = variables.datasource;

    // Disable dashboard
    variables.framework = {
        disableDashboard = true,
        disabledDashboardRedirect = "/",
    };

    // Add mappings for the api
    this.mappings["/resources"] = expandPath("./resources");
    this.mappings["/taffy"] = expandPath("./taffy");

    // this function is called after the request has been parsed and all request details are known
    function onTaffyRequest(verb, cfc, requestArguments, mimeExt){

        local.loginData = getBasicAuthCredentials();

        // Return 401 if no basic auth is provided
        if(not structKeyExists(local.loginData, "username") and not structKeyExists(local.loginData, "password")){
            return noData().withStatus(401);
        }

        // Return 401 if no api key is provided
        if(not structKeyExists(arguments.requestArguments, "apiKey")){
            return noData().withStatus(401);
        }
        
        // Check provided basic auth and api key
        if(local.loginData.username eq "admin" and local.loginData.password eq "testtest"){
            return true;
        }else {
            return noData().withStatus(401);
        }

    }

}