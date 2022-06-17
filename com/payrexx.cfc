
component displayname="payrexx" output="false" {

    variables.payrexxAPIurl = application.payrexxStruct.payrexxAPIurl;
    variables.payrexxAPIinstance = application.payrexxStruct.payrexxAPIinstance;
    variables.payrexxAPIkey = application.payrexxStruct.payrexxAPIkey;

    if (!len(trim(variables.payrexxAPIurl)) or !len(trim(variables.payrexxAPIinstance)) or !len(trim(variables.payrexxAPIkey))) {
        throw("Please check your Payrexx API data!");
    }


    // Create a gateway
    public struct function createGateway(required struct payload) {

        local.payloadStruct = structNew();
        local.payloadStruct['amount'] = "1";
        local.payloadStruct['currency'] = "USD";
        local.payloadStruct['skipResultPage'] = true;

        if (structKeyExists(arguments.payload, "amount") and isNumeric(arguments.payload.amount)) {
            local.payloadStruct['amount'] = arguments.payload.amount * 100;
        }
        if (structKeyExists(arguments.payload, "currency")) {
            local.payloadStruct['currency'] = arguments.payload.currency;
        }
        if (structKeyExists(arguments.payload, "purpose")) {
            local.payloadStruct['purpose'] = arguments.payload.purpose;
        }
        if (structKeyExists(arguments.payload, "successRedirectUrl")) {
            local.payloadStruct['successRedirectUrl'] = arguments.payload.successRedirectUrl;
        }
        if (structKeyExists(arguments.payload, "failedRedirectUrl")) {
            local.payloadStruct['failedRedirectUrl'] = arguments.payload.failedRedirectUrl;
        }
        if (structKeyExists(arguments.payload, "cancelRedirectUrl")) {
            local.payloadStruct['cancelRedirectUrl'] = arguments.payload.cancelRedirectUrl;
        }
        if (structKeyExists(arguments.payload, "referenceId")) {
            local.payloadStruct['referenceId'] = arguments.payload.referenceId;
        }
        if (structKeyExists(arguments.payload, "subscriptionState") and isBoolean(arguments.payload.subscriptionState)) {
            local.payloadStruct['subscriptionState'] = arguments.payload.subscriptionState;
        }
        if (structKeyExists(arguments.payload, "subscriptionInterval")) {
            local.payloadStruct['subscriptionInterval'] = arguments.payload.subscriptionInterval;
        }
        if (structKeyExists(arguments.payload, "lookAndFeelProfile")) {
            local.payloadStruct['lookAndFeelProfile'] = arguments.payload.lookAndFeelProfile;
        }

        return callPayrexx(local.payloadStruct, "POST", "Gateway");

    }



    public struct function callPayrexx(required struct payload, string method, string object, numeric thisID) {

        local.method = "GET";
        local.object = "SignatureCheck";
        local.thisID = "";

        if (structKeyExists(arguments, "method")) {
            local.method = arguments.method;
        }
        if (structKeyExists(arguments, "object")) {
            local.object = arguments.object;
        }
        if (structKeyExists(arguments, "thisID") and isNumeric(arguments.thisID)) {
            local.thisID = arguments.thisID;
        }
        if (structKeyExists(arguments, "apiSignature")) {
            local.apiSignature = arguments.apiSignature;
        }

        local.apiSignature = makeAPISignature(arguments.payload);

        switch (local.method) {

            case "GET":

                if (isNumeric(local.thisID)) {
                    local.callingURL = variables.payrexxAPIurl & local.object & "/" & local.thisID & "/?instance=" &  variables.payrexxAPIinstance & "&" & local.apiSignature;
                } else {
                    local.callingURL = variables.payrexxAPIurl & local.object & "/?instance=" &  variables.payrexxAPIinstance & "&" & local.apiSignature;
                }

                cfhttp( url=local.callingURL, result="httpRes", method="GET" ) {};


            case "POST":

                local.callingURL = variables.payrexxAPIurl & local.object & "/?instance=" &  variables.payrexxAPIinstance;
                local.bodyString = structToQueryString(arguments.payload) & "&" & local.apiSignature;

                cfhttp( url=local.callingURL, result="httpRes", method="POST" ) {
                    cfhttpparam( name="Content-Type", type="header", value="application/json" );
                    cfhttpparam( name="Accept", type="header", value="application/x-www-form-urlencoded" );
                    cfhttpparam( type="body", value=local.bodyString );
                }




        }

        if (httpRes.status_text eq "OK" and isJSON(httpRes.filecontent)) {
            local.respond = deserializeJSON(httpRes.filecontent);
        } else {
            local.respond = httpRes.errordetail;
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