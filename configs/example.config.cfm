
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

// Password for the Scheduler (url.pass)
variables.schedulePassword = "saaster2022";



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

// Set allowed image file types
variables.imageFileTypes = ["jpeg","png","jpg","gif","bmp"]; // Svg type will not work for image file upload
variables.documentsFileTypes = ["pdf"];



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

// Enter an email address for error messages
variables.errorEmail = "error@saaster.io";

// ####################################
//  CUSTOMER SETTINGS
// ####################################

// To simulate a customer in local environment, enter a public IP address here.
variables.usersIP = "62.171.127.255";

// This is a placeholder for the user image. Please only enter an absolute path that can be called up online.
variables.userTempImg = "../dist/img/user-solid.svg";



// ####################################
//  PAYREXX SETTINGS
// ####################################

// The basic URL to the Payrexx API
variables.payrexxAPIurl = "https://api.payrexx.com/v1.0/";

// Your personal Payrexx instance
variables.payrexxAPIinstance = "";

// Your API key from Payrexx
variables.payrexxAPIkey = "";

// Look and feel of your payment page (id from Payrexx)
variables.payrexxDesignID = "";

// Webhook directory for developing environment
variables.payrexxWebhookDev = "";



// ####################################
//  Footer text variable
// ####################################

cfsavecontent (variable="variables.footerText") {
    echo("<div><p>Open source software running under the <a href='https://github.com/git/git-scm.com/blob/main/MIT-LICENSE.txt' target='_blank'>MIT license</a> - #dateFormat(now(), 'yyyy')# by #variables.appOwner#</p></div>");
}


</cfscript>
