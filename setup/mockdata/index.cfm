<cfscript>
    objFunctions = new functions()

    if(structKeyExists(url, "method")){
        switch (url.method) {
            case "createCustomers":
                callFunc = objFunctions.createCustomers(form.amount);
                if(callFunc){
                    location("index.cfm?cc", false);
                }
                break;
            case "createInvoices":
                callFunc = objFunctions.createInvoices(form.amount, form.customer);
                if(callFunc){
                    location("index.cfm?ci", false);
                }
                break;
            default:
                dump("Please provide a valid method!");
                break;
        }
    }
</cfscript>
<h1 style="margin-bottom: 4px;">Mockdata generator:</h1>
<hr style="float: left; width: 400px;"><br>
<h3 style="margin-bottom: 4px; margin-top: 8px;">Create customers:</h3>
<p style="margin-bottom: 0px; margin-top: 0px;">Enter the amount of customers you want to generate.</p><br>
<form action="index.cfm?method=createCustomers" method="post">
    <label>Amount:</label>
    <input type="number" name="amount" value="10">
    <input type="submit" value="Create">
    <cfif structKeyExists(url, "cc")>
        done!
    </cfif>
</form>

<hr style="float: left; width: 400px;"><br>

<h3 style="margin-bottom: 4px; margin-top: 8px;">Create invoices:</h3>
<p style="margin-bottom: 0px; margin-top: 0px;">
    If you want to generate invoices for a certain customer, fill out the ID field
</p>
<p style="margin-bottom: 0px; margin-top: 0px;">
    with the CustomerID. Leave the ID field at zero if you want to use random
</p>
<p style="margin-bottom: 0px; margin-top: 0px;">
    customers.
</p>
<br>
<form action="index.cfm?method=createInvoices" method="post">
    <label>Amount:</label>
    <input style="width: 75px;" type="number" name="amount" value="10">
    <label> ID:</label>
    <input style="width: 75px;" type="number" name="customer" value="0">

    <input type="submit" value="Create">

    <cfif structKeyExists(url, "ci")>
        done!
    </cfif>
</form>

<hr style="float: left; width: 400px;"><br>
