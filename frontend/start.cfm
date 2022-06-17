start

<cfscript>

objPayrexx = new com.payrexx();

testBody = structNew();
testBody['referenceId'] = "12345678";
testBody['purpose'] = "Test";
testBody['amount'] = "10";
testBody['currency'] = "CHF";


/* test = objPayrexx.createGateway(testBody);

dump(test); */

abort;


toString2 = objPayrexx.structToQueryString(testBody);
//toString2 = "amount=10&currency=CHF";
toHash =  "ApiSignature=" & urlEncode(objPayrexx.getApiSignature(toString2));



dump(toString2);
dump(toHash);

testBody = toString2 & "&" & toHash;
dump(testBody);

/* abort; */

/* apiSignature = objPayrexx.getRequestURL(testBody);

dump(apiSignature);
abort; */

/* requestURL = requestURL & apiSignature;


dump(requestURL);
abort;
 */

cfhttp( url="https://api.payrexx.com/v1.0/Gateway/?instance=paweco", result="result", method="POST" ) {
	cfhttpparam( name="Content-Type", type="header", value="application/json" );
	cfhttpparam( name="Accept", type="header", value="application/x-www-form-urlencoded" );
	cfhttpparam( type="body", value=testBody );
}


dump(result);



/* api_name = "saaster";
api_key = "gO9ZSiXRRZ9Pj5uxrSGcD0YvE4rfZ4";
query_string = urlEncodedFormat("model=Page&id=17");
apy_key_hashed = hmac(query_string, api_key, "HmacSHA256");
apy_key_base64 = toBase64(apy_key_hashed);
payrexx = "https://api.payrexx.com/v1.0/#apy_key_base64#?instance=paweco";




cfhttp( url=payrexx, result="result", method="GET" ) {
	//cfhttpparam( name="Content-Type", type="header", value="application/json" );
	//cfhttpparam( name="Accept", type="header", value="application/json; charset=utf-8" );
	//cfhttpparam( name="Authorization", type="header", value="Basic #ToBase64()#" );
	//cfhttpparam( type="body", value=serializeJSON(arguments.body) );
}


dump(result); */







</cfscript>


