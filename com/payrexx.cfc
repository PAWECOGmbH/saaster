
component displayname="payrexx" output="false" {

    variables.payrexxAPIurl = application.payrexxStruct.payrexxAPIurl;
    variables.payrexxAPIinstance = application.payrexxStruct.payrexxAPIinstance;
    variables.payrexxAPIkey = application.payrexxStruct.payrexxAPIkey;

    if (!len(trim(variables.payrexxAPIurl)) or !len(trim(variables.payrexxAPIinstance)) or !len(trim(variables.payrexxAPIkey))) {
        throw("Please check your Payrexx API data!");
    }


    // Get the webhook data
    public query function getWebhook(required numeric customerID, required string status, any default, string includingFailed) {

        local.sql_default = (structKeyExists(arguments, "default") and isBoolean(arguments.default) ? "AND blnDefault = " & arguments.default : "");
        local.sql_failed = (structKeyExists(arguments, "includingFailed") and arguments.includingFailed eq "yes" ? "" : "AND blnFailed = 0");    


        local.qWebhook = queryExecute(
            options: {datasource = application.datasource},
            params: {
                customerID = {type: "numeric", value: arguments.customerID},
                status = {type: "varchar", value: arguments.status}
            },
            sql = "
                SELECT *
                FROM payrexx
                WHERE intCustomerID = :customerID
                AND strStatus = :status
                #local.sql_default#
                #local.sql_failed#
                ORDER BY dtmTimeUTC DESC
            "
        )

        return local.qWebhook;

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

        local.apiSignature = makeAPISignature(arguments.payload);

        switch (local.method) {

            case "GET":

                local.callingURL = (isNumeric(local.thisID) ? variables.payrexxAPIurl & local.object & "/" & local.thisID & "/?instance=" &  variables.payrexxAPIinstance & "&" & local.apiSignature : variables.payrexxAPIurl & local.object & "/?instance=" &  variables.payrexxAPIinstance & "&" & local.apiSignature);

                cfhttp( url=local.callingURL, result="httpRes", method="GET" ) {};

                break;


            case "POST":

                local.callingURL = (isNumeric(local.thisID) ? variables.payrexxAPIurl & local.object &"/" & local.thisID & "/?instance=" &  variables.payrexxAPIinstance : variables.payrexxAPIurl & local.object & "/?instance=" &  variables.payrexxAPIinstance);

                local.bodyString = structToQueryString(arguments.payload) & "&" & local.apiSignature;

                cfhttp( url=local.callingURL, result="httpRes", method="POST" ) {
                    cfhttpparam( name="Content-Type", type="header", value="application/json" );
                    cfhttpparam( name="Accept", type="header", value="application/x-www-form-urlencoded" );
                    cfhttpparam( type="body", value=local.bodyString );
                }

                break;


            case "DEL":

                local.callingURL = (isNumeric(local.thisID) ? variables.payrexxAPIurl & local.object &"/" & local.thisID & "/?instance=" &  variables.payrexxAPIinstance : variables.payrexxAPIurl & local.object & "/?instance=" &  variables.payrexxAPIinstance);

                local.bodyString = structToQueryString(arguments.payload) & "&" & local.apiSignature;

                cfhttp( url=local.callingURL, result="httpRes", method="DELETE" ) {
                    cfhttpparam( name="Content-Type", type="header", value="application/json" );
                    cfhttpparam( name="Accept", type="header", value="application/x-www-form-urlencoded" );
                    cfhttpparam( type="body", value=local.bodyString );
                }

                break;

        }



        local.respond = (httpRes.status_text eq "OK" and isJSON(httpRes.filecontent) ? deserializeJSON(httpRes.filecontent) : httpRes.errordetail);
    
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