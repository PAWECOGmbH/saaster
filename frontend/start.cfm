start

<cfscript>

objPayrexx = new com.payrexx();

/* dump(objPayrexx.getGateway(6437208)); */

payloadStruct = structNew();
paymentStruct['amount'] = 100;
paymentStruct['purpose'] = "test";
paymentStruct['referenceId'] = session.customer_id;

test = objPayrexx.callPayrexx(paymentStruct, "POST", "Transaction", 5589914);

dump(test);

/* dump(objPayrexx.callPayrexx(payloadStruct, "GET", "Transaction")); */

</cfscript>


