
component displayname="payrexx" output="false" {

    variables.payrexxAPIurl = application.payrexxStruct.payrexxAPIurl;
    variables.payrexxAPIinstance = application.payrexxStruct.payrexxAPIinstance;
    variables.payrexxAPIkey = application.payrexxStruct.payrexxAPIkey;

    if (!len(trim(variables.payrexxAPIurl)) or !len(trim(variables.payrexxAPIinstance)) or !len(trim(variables.payrexxAPIkey))) {
        throw("Please check your Payrexx API data!");
    }


    // Get the webhook data
    public query function getWebhook(required numeric customerID, required string status, any default, string includingFailed, numeric gatewayID) {

        if (structKeyExists(arguments, "default") and isBoolean(arguments.default)) {
            local.sql_default = "AND blnDefault = " & arguments.default;
        } else {
            local.sql_default = "";
        }
        if (structKeyExists(arguments, "includingFailed") and arguments.includingFailed eq "yes") {
            local.sql_failed = "";
        } else {
            local.sql_failed = "AND blnFailed = 0";
        }


        local.queryParams = {
            customerID: {type: "numeric", value: arguments.customerID},
            status: {type: "varchar", value: arguments.status}
        };
        if (structKeyExists(arguments, "gatewayID") and arguments.gatewayID gt 0) {
            local.sql_gateway = "AND intGatewayID = :gatewayID";
            local.queryParams.gatewayID = {type: "numeric", value: arguments.gatewayID};
        } else {
            local.sql_gateway = "";
        }

        local.qWebhook = queryExecute(
            options: {datasource = application.datasource},
            params: local.queryParams,
            sql = "
                SELECT *
                FROM payrexx
                WHERE intCustomerID = :customerID
                AND strStatus = :status
                #local.sql_default#
                #local.sql_failed#
                #local.sql_gateway#
                ORDER BY dtmTimeUTC DESC
            "
        )

        return local.qWebhook;

    }



    public struct function callPayrexx(required struct payload, string method, string object, numeric thisID) {

        local.method = "GET";
        local.object = "SignatureCheck";
        local.thisID = "";
        local.errorResponse = {
            status: "error",
            message: "Payrexx could not be reached.",
            httpStatus: 0,
            transportError: true,
            requestOutcomeUnknown: true
        };

        if (structKeyExists(arguments, "method")) {
            local.method = arguments.method;
        }
        if (structKeyExists(arguments, "object")) {
            local.object = arguments.object;
        }
        if (structKeyExists(arguments, "thisID") and isNumeric(arguments.thisID)) {
            local.thisID = arguments.thisID;
        }

        local.apiSignature = makeAPISignature(arguments.payload);

        try {
            switch (local.method) {

                case "GET":

                    if (isNumeric(local.thisID)) {
                        local.callingURL = variables.payrexxAPIurl & local.object & "/" & local.thisID & "/?instance=" &  variables.payrexxAPIinstance & "&" & local.apiSignature;
                    } else {
                        local.callingURL = variables.payrexxAPIurl & local.object & "/?instance=" &  variables.payrexxAPIinstance & "&" & local.apiSignature;
                    }

                    cfhttp( url=local.callingURL, result="httpRes", method="GET", timeout=20 ) {};

                    break;


                case "POST":

                    if (isNumeric(local.thisID)) {
                        local.callingURL = variables.payrexxAPIurl & local.object &"/" & local.thisID & "/?instance=" &  variables.payrexxAPIinstance;
                    } else {
                        local.callingURL = variables.payrexxAPIurl & local.object & "/?instance=" &  variables.payrexxAPIinstance;
                    }

                    local.bodyString = structToQueryString(arguments.payload) & "&" & local.apiSignature;

                    cfhttp( url=local.callingURL, result="httpRes", method="POST", timeout=20 ) {
                        cfhttpparam( name="Content-Type", type="header", value="application/x-www-form-urlencoded" );
                        cfhttpparam( name="Accept", type="header", value="application/json" );
                        cfhttpparam( type="body", value=local.bodyString );
                    }

                    break;


                case "DEL":

                    if (isNumeric(local.thisID)) {
                        local.callingURL = variables.payrexxAPIurl & local.object &"/" & local.thisID & "/?instance=" &  variables.payrexxAPIinstance;
                    } else {
                        local.callingURL = variables.payrexxAPIurl & local.object & "/?instance=" &  variables.payrexxAPIinstance;
                    }

                    // Payrexx expects DELETE parameters (including the signature) in the URL.
                    local.queryString = structToQueryString(arguments.payload);
                    if (len(local.queryString)) {
                        local.callingURL &= "&" & local.queryString;
                    }
                    local.callingURL &= "&" & local.apiSignature;

                    cfhttp( url=local.callingURL, result="httpRes", method="DELETE", timeout=20 ) {
                        cfhttpparam( name="Accept", type="header", value="application/json" );
                    }

                    break;

                default:
                    local.errorResponse.message = "Unsupported Payrexx request method: " & local.method;
                    local.errorResponse.requestOutcomeUnknown = false;
                    return local.errorResponse;
            }
        } catch (any e) {
            local.errorResponse.message = "Payrexx request failed: " & e.message;
            return local.errorResponse;
        }

        local.httpStatus = 0;
        if (structKeyExists(httpRes, "statusCode") and isNumeric(listFirst(httpRes.statusCode, " "))) {
            local.httpStatus = int(listFirst(httpRes.statusCode, " "));
        }

        if (!structKeyExists(httpRes, "fileContent") or !isJSON(httpRes.fileContent)) {
            local.errorResponse.httpStatus = local.httpStatus;
            local.errorResponse.message = structKeyExists(httpRes, "errorDetail") and len(trim(httpRes.errorDetail))
                ? httpRes.errorDetail
                : "Payrexx returned an invalid response.";
            return local.errorResponse;
        }

        local.respond = deserializeJSON(httpRes.fileContent);
        if (!isStruct(local.respond)) {
            local.errorResponse.httpStatus = local.httpStatus;
            local.errorResponse.message = "Payrexx returned an unexpected response.";
            return local.errorResponse;
        }

        local.respond.httpStatus = local.httpStatus;
        local.respond.transportError = false;
        local.respond.requestOutcomeUnknown = local.httpStatus gte 500;

        if (!structKeyExists(local.respond, "status")) {
            local.respond.status = "error";
        }
        if (!structKeyExists(local.respond, "message")) {
            local.respond.message = local.respond.status eq "success"
                ? "Payrexx request completed successfully."
                : "Payrexx rejected the request.";
        }

        return local.respond;

    }




    public string function makeAPISignature(struct postData) {

        if (structKeyExists(arguments, "postData")) {
            local.queryString = structToQueryString(arguments.postData);
            local.queryString = replace(local.queryString, "%20", "+", "all");
            local.urlString = "ApiSignature=" & urlEncode(getApiSignature(local.queryString));
        } else {
            local.urlString = "ApiSignature=" & urlEncode(getApiSignature(""));
        }

        return local.urlString;

    }

    public string function structToQueryString(required struct postData) {

        local.qstr = "";
        local.delim1 = "=";
        local.delim2 = "&";

        switch (arrayLen(arguments)) {
            case "3":
                local.delim2 = arguments[3];
            case "2":
                local.delim1 = arguments[2];
        }

        for (key in arguments.postData) {
            local.qstr = listAppend(local.qstr, urlEncode(key) & local.delim1 & urlEncode(arguments.postData[key]), local.delim2);
        }

        local.qstr = replace(local.qstr, "+", "%20", "all");

        return local.qstr;

    }

    public string function getApiSignature(required string encodedData) {

        local.hmacHex = hmac(arguments.encodedData, variables.payrexxAPIkey, 'HmacSHA256');
        local.encodedString = binaryEncode(binaryDecode(local.hmacHex, "hex"), "base64");

        return local.encodedString;

    }

}
