<cfscript>

    if (!structKeyExists(url, "plan") and !structKeyExists(url, "module")) {
        location url="#application.mainURL#" addtoken=false;
    }

    // The user must already be logged in
    if (!structKeyExists(session, "customer_id")) {
        location url="#application.mainURL#/login" addtoken=false;
    }

    // Include the plan process
    if (structKeyExists(url, "plan")) {
        include template="/backend/core/handler/book_plan.cfm";
    }

    // Include the module process
    if (structKeyExists(url, "module")) {
        include template="/backend/core/handler/book_module.cfm";
    }

    location url="#application.mainURL#/dashboard" addtoken=false;


</cfscript>