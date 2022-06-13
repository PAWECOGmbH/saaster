
<cfscript>

// ####################################
// DATABASE SETTINGS
// ####################################

variables.datasource = "database";



// ####################################
//  SERVER SETTINGS
// ####################################

// The domain of your local environment
variables.devDomain = "localhost";

// Enter the URL of your project (incl. http:// or https://)
variables.mainURL = "http://localhost";



// ####################################
//  APPLICATION SETTINGS
// ####################################

// The name of your application.cfc
variables.applicationname = "saaster.io";

// Please use the timespan tag directly
variables.sessiontimeout = createTimespan(00,03,00,00);

// You can use "modern" or "classic" for lucee pdf print
variables.pdf_type = "classic";

// RequestTimeout in seconds
variables.requesttimeout = 60;



// ####################################
//  OPERATOR SETTINGS
// ####################################

// Here you can choose any name
variables.appName = "SaaSTER";

// Enter the name of the operator (Your company)
variables.appOwner = "The SaaSTER Company ltd.";

// From which e-mail address should the system e-mails be sent?
variables.fromEmail = "SaaSTER Company <info@saaster.io>";

// Enter the email address of the administrator
variables.toEmail = "info@saaster.io";



// ####################################
//  CUSTOMER SETTINGS
// ####################################

// To simulate a customer in local environment, enter a public IP address here.
variables.usersIP = "62.171.127.255";

// This is a placeholder for the user image. Please only enter an absolute path that can be called up online.
variables.userTempImg = "http://www.clker.com/cliparts/A/Y/O/m/o/N/placeholder-md.png";



</cfscript>
